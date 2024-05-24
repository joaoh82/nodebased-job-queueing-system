@icon("res://addons/jqs/icons/job.png")
extends Node
class_name JobNode

## Arguments to be passed to the `execute` method of this job.
@export var _args : Array[Variant]
## JobNode to run when this is finished. And feed as parameters, the return value of this job execute.
@export var _then : JobNode

#func execute(a, b) -> void:
	#pass
