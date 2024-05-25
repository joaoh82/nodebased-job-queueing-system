@icon("res://addons/jqs/icons/queue.png")
## Node that wraps a JobQueue.
## Creates the Threads when entering tree and shuts down when exiting tree.
## If `thread_count == 0`, runs queue in synchronous mode.
## If `thread_count < 0`, creates `OS.get_processor_count()` Threads.
extends Node
class_name JobQueueManager

signal all_jobs_finished()

## Automatically starts the JobQueue
@export var _auto_start : bool = true

## Number of Threads to use.
@export var thread_count: int = -1: set = set_thread_count

## The JobQueue
var _job_queue = JobQueue.new()

func _enter_tree() -> void:
	set_thread_count(thread_count)


func _exit_tree() -> void:
	_job_queue.shutdown()


func _ready():
	if _auto_start:
		# Starts the JobQueue if auto_start is true
		start_job_queue()
		

## Starts the JobQueue
func start_job_queue() -> void:
	_traverse_job_nodes()


## Traverses the JobNode tree passing execute methods to the JobQueue
## and calls `then` if it exists
func _traverse_job_nodes() -> void:
	for job_node in get_children():
		if (job_node as JobNode).then and ((job_node as JobNode).then as JobNode).is_callback:
			dispatch((job_node as JobNode).execute.bindv((job_node as JobNode).args)).then(((job_node as JobNode).then as JobNode).execute)
		else:
			dispatch((job_node as JobNode).execute.bindv((job_node as JobNode).args))


## Traverses the JobNode tree passing execute methods to the JobQueue recursively
func _traverse_job_nodes_recursive(job_node : Node) -> void:
	if job_node is JobNode:
		dispatch((job_node as JobNode).execute.bindv((job_node as JobNode).args))
	
	for child in job_node.get_children():
		_traverse_job_nodes_recursive(child)			
	
		
## Set the number of Threads
func set_thread_count(value: int) -> void:
	if value < 0:
		value = OS.get_processor_count()
	thread_count = value
	if thread_count == 0:
		_job_queue.shutdown()
	else:
		_job_queue.create_concurrent(thread_count)


# JobQueue wrappers
func dispatch(callable: Callable) -> Job:
	return _job_queue.dispatch(callable)


## Create all jobs in `job_list` by calling `dispatch` on each value,
func dispatch_group(job_list: Array[Callable]) -> JobGroup:
	return _job_queue.dispatch_group(job_list)


## Returns true if the JobQueue is threaded
func is_threaded() -> bool:
	return _job_queue.is_threaded()


## Returns the current Thread count
func get_thread_count() -> int:
	return _job_queue.get_thread_count()


## Returns the number of queued jobs
func size() -> int:
	return _job_queue.size()


## Returns true if the JobQueue is empty
func is_empty() -> bool:
	return _job_queue.is_empty()


## Cancel pending Jobs, clearing the current queue.
func clear() -> void:
	_job_queue.clear()


## Cancel pending Jobs, wait and release the used Threads.
## The queue now runs in synchronous mode, so that new jobs will run in the main thread.
## Call `create_serial` or `create_concurrent` to recreate the worker threads.
## This method is called automatically on `NOTIFICATION_PREDELETE`.
## It is safe to call this more than once.
func shutdown() -> void:
	_job_queue.shutdown()


# Private functions
func _on_all_jobs_finished() -> void:
	all_jobs_finished.emit()
