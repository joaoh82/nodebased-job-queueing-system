extends Node3D

#@export var _job_queue_manager : JobQueueManager

var job_queue : JobQueue = JobQueue.new()

func _ready():
	#var job_list : Array[Callable]
	#job_list.append(_task_01)
	#job_list.append(_task_02)
	#job_list.append(_task_03)
	#_job_queue_manager.dispatch(_task_01).then(_task_02)
	
	
	job_queue.create_serial()
	job_queue.dispatch(self._task_01).then(self._task_02)
	#job_queue.dispatch(_task_03)
	
func _task_01() -> int:
	printt("_task_01 executing...")

	printt("_task_01 done...")
	
	return 1
	
	
func _task_02(result) -> void:
	printt("_task_02 executing...")
	printt("result", result)
	printt("_task_02 done...")
	
	
func _task_03() -> void:
	printt("_task_03 executing...")

	printt("_task_03 done...")
