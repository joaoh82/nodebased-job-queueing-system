@tool
extends EditorPlugin
class_name JQS

func _enter_tree():
	add_custom_type("JobQueueManager", "Node", preload("res://addons/jqs/scripts/job_queue_manager.gd"), preload("res://addons/jqs/icons/queue.png"))
	add_custom_type("Job", "Node", preload("res://addons/jqs/scripts/job_node.gd"), preload("res://addons/jqs/icons/job.png"))


func _exit_tree():
	remove_custom_type("JobQueueManager")
	remove_custom_type("Job")
