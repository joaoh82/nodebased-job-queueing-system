extends Node3D

## JobQueueManager Node
@export var _job_queue_manager : JobQueueManager

var job_queue : JobQueue = JobQueue.new()

func _ready():
	# Setting JobQueue to serial and single threaded
	job_queue.create_serial()
	
	# Dispatching a group of jobs
	var job_list : Array[Callable]
	job_list.append(_task_01)
	job_list.append(_task_02.bind(0))
	job_list.append(_task_03)
	job_queue.dispatch_group(job_list)
	
	# Dispatching single jobs
	#job_queue.dispatch(self._task_01).then(self._task_02)
	#job_queue.dispatch(_task_03)
	
	
	
	pass
	
func _task_01() -> int:
	printt("_task_01 executing...")
	for i in range(1000):
		printt(i)
	printt("_task_01 done...")
	
	return 1
	
	
func _task_02(result) -> void:
	printt("_task_02 executing...")
	printt("result", result)
	printt("_task_02 done...")
	
	
func _task_03() -> void:
	printt("_task_03 executing...")

	printt("_task_03 done...")
