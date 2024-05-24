extends RefCounted
class_name WorkerPool

var threads: Array[Thread] = []
var should_shutdown := false
var mutex := Mutex.new()
var semaphore := Semaphore.new()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and self:
		shutdown()


# Shuts down the worker pool.
#
# This function is called automatically when the worker pool is about to be
# deleted. It ensures that all threads are stopped and the worker pool is
# cleared.
#
# This function does not return anything.
func shutdown() -> void:
	if threads.is_empty():
		return
	should_shutdown = true
	for i in threads.size():
		semaphore.post()
	for t in threads:
		if t.is_alive():
			t.wait_to_finish()
	threads.clear()
	should_shutdown = false
