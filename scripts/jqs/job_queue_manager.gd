## Node that wraps a JobQueue.
## Creates the Threads when entering tree and shuts down when exiting tree.
## If `thread_count == 0`, runs queue in synchronous mode.
## If `thread_count < 0`, creates `OS.get_processor_count()` Threads.
extends Node
class_name JobQueueManager

signal all_jobs_finished()

@export var thread_count: int = -1: set = set_thread_count

var _job_queue = JobQueue.new()

func _enter_tree() -> void:
	set_thread_count(thread_count)


func _exit_tree() -> void:
	_job_queue.shutdown()


func set_thread_count(value: int) -> void:
	if value < 0:
		value = OS.get_processor_count()
	thread_count = value
	if thread_count == 0:
		_job_queue.shutdown()
	else:
		_job_queue.create_concurrent(thread_count)

# DispatchQueue wrappers
func dispatch(callable: Callable) -> Job:
	return _job_queue.dispatch(callable)


func dispatch_group(job_list: Array[Callable]) -> JobGroup:
	return _job_queue.dispatch_group(job_list)

func is_threaded() -> bool:
	return _job_queue.is_threaded()


func get_thread_count() -> int:
	return _job_queue.get_thread_count()


func size() -> int:
	return _job_queue.size()


func is_empty() -> bool:
	return _job_queue.is_empty()


func clear() -> void:
	_job_queue.clear()


func shutdown() -> void:
	_job_queue.shutdown()


# Private functions
func _on_all_jobs_finished() -> void:
	all_jobs_finished.emit()
