@icon("res://addons/jqs/icons/job.png")
extends Node
class_name JobNode

## Arguments to be passed to the `execute` method of this job.
@export var args : Array[Variant]
## JobNode to run when this is finished. And feed as parameters, 
## the return value of this job execute.
@export var then : JobNode
## If true, this is a callback.
@export var is_callback : bool = false

# INTERFACE

#func execute(params...) -> void:
	#pass
