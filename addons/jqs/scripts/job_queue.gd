extends RefCounted
class_name JobQueue

## Signal emitted when the last job in queue finishes
## This signal is emitted deferred, so it is safe to call non Thread-safe APIs.
signal all_jobs_finished()

var _job_queue = []
var _workers: WorkerPool = null


## Creates a Thread of execution to process jobs.
## If queue was already serial, this is a no-op, otherwise calls `shutdown` and create a new Thread.
func create_serial() -> void:
	create_concurrent(1)


## Creates `thread_count` Threads of execution to process jobs.
## If queue was already concurrent with `thread_count` Threads, this is a no-op.
## Otherwise calls `shutdown` and create new Threads.
## If `thread_count <= 1`, creates a serial queue.
func create_concurrent(thread_count: int = 1) -> void:
	if thread_count == get_thread_count():
		return

	if is_threaded():
		shutdown()

	_workers = WorkerPool.new()
	var run_loop = self._run_loop.bind(_workers)
	for i in max(1, thread_count):
		var thread = Thread.new()
		_workers.threads.append(thread)
		thread.start(run_loop)


func _run_loop(pool: WorkerPool) -> void:
	while true:
		pool.semaphore.wait()
		if pool.should_shutdown:
			break

		pool.mutex.lock()
		var job = _pop_job()
		pool.mutex.unlock()
		if job:
			job.execute()


## Create a Job for executing `callable`.
## On threaded mode, the Job will be executed on a Thread when there is one available.
## On synchronous mode, the Job will be executed on the next frame.
func dispatch(callable: Callable) -> Job:
	var job = Job.new()
	if callable.is_valid():
		job.callable = callable
		if is_threaded():
			_workers.mutex.lock()
			_job_queue.append(job)
			_workers.mutex.unlock()
			_workers.semaphore.call_deferred("post")
		else:
			if _job_queue.is_empty():
				call_deferred("_sync_run_next_job")
			_job_queue.append(job)
	else:
		push_error("Trying to dispatch an invalid callable, ignoring it")
	return job


## Create all jobs in `job_list` by calling `dispatch` on each value,
## returning the JobGroup associated with them.
func dispatch_group(job_list: Array[Callable]) -> JobGroup:
	var group = JobGroup.new(is_threaded())
	for callable in job_list:
		var job: Job = dispatch(callable)
		group.add_job(job)

	return group


func _sync_run_next_job() -> void:
	var job = _pop_job()
	if job:
		job.execute()
		call_deferred("_sync_run_next_job")


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and self:
		shutdown()


## Cancel pending Jobs, clearing the current queue.
## Jobs that are being processed will still run to completion.
func clear() -> void:
	if is_threaded():
		_workers.mutex.lock()
		_job_queue.clear()
		_workers.mutex.unlock()
	else:
		_job_queue.clear()


## Cancel pending Jobs, wait and release the used Threads.
## The queue now runs in synchronous mode, so that new jobs will run in the main thread.
## Call `create_serial` or `create_concurrent` to recreate the worker threads.
## This method is called automatically on `NOTIFICATION_PREDELETE`.
## It is safe to call this more than once.
func shutdown() -> void:
	clear()
	if is_threaded():
		var current_workers = _workers
		_workers = null
		current_workers.shutdown()

## Returns whether queue is threaded or synchronous.
func is_threaded() -> bool:
	return _workers != null


## Returns the current Thread count.
## Returns 0 on synchronous mode.
func get_thread_count() -> int:
	if is_threaded():
		return _workers.threads.size()
	else:
		return 0


## Returns the number of queued jobs.
func size() -> int:
	var result
	if is_threaded():
		_workers.mutex.lock()
		result = _job_queue.size()
		_workers.mutex.unlock()
	else:
		result = _job_queue.size()
	return result


## Returns whether queue is empty, that is, there are no jobs queued.
func is_empty() -> bool:
	return size() <= 0


## This function pops a job (job) from the job queue.
## If the job queue is empty after the pop, it defers the _on_last_job_finished function.
## It then returns the popped job.
func _pop_job() -> Job:
	var job: Job = _job_queue.pop_front()
	if job and _job_queue.is_empty():
		job.then_deferred(self._on_last_job_finished)
	return job


func _on_last_job_finished(_result):
	if is_empty():
		all_jobs_finished.emit()
