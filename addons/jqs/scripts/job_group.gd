extends RefCounted
## Helper object that emits "finished" after all Jobs in a list finish.
class_name JobGroup

## Emitted after Job executes, passing the result as argument.
## The signal is emitted in the same Thread that executed the Job, so you
## need to connect with CONNECT_DEFERRED if you want to call non Thread-safe APIs.
signal finished(results)

var job_count := 0
var job_results = []
var mutex: Mutex = null


func _init(threaded: bool) -> void:
	if threaded:
		mutex = Mutex.new()


## Helper method for connecting to the "finished" signal.
##
## This enables the following pattern:
##   job_queue.dispatch_group(job_list).then(continuation_callable)
func then(callable: Callable, flags: int = 0) -> int:
	return finished.connect(callable, flags | CONNECT_ONE_SHOT)


## Alias for `then` that also adds CONNECT_DEFERRED to flags.
func then_deferred(callable: Callable, flags: int = 0) -> int:
	return then(callable, flags | CONNECT_DEFERRED)


func add_job(job: Job) -> void:
	job.group = self
	job.id_in_group = job_count
	job_count += 1
	job_results.resize(job_count)


func mark_job_finished(job: Job, result) -> void:
	if mutex:
		mutex.lock()
	job_count -= 1
	job_results[job.id_in_group] = result
	var is_last_job = job_count == 0
	if mutex:
		mutex.unlock()
	if is_last_job:
		finished.emit(job_results)
