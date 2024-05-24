extends RefCounted
## A single job to be executed.
##
## Connect to the `finished` signal to receive the result either manually
## or by calling `then`/`then_deferred`.
class_name Job

## Emitted after all Jobs in the group finish, passing the results Array as argument.
## The signal is emitted in the same Thread that executed the last pending Job, so you
## need to connect with CONNECT_DEFERRED if you want to call non Thread-safe APIs.
## The job being connected via then/then_deferred will need to have the following signature:
##   func task_02(result: Array)
signal job_finished(result)

var callable: Callable
var group: JobGroup = null
var id_in_group: int = -1


## Helper method for connecting to the "finished" signal.
##
## This enables the following pattern:
##   dispatch_queue.dispatch(callable).then(continuation_callable)
func then(_callable: Callable, flags: int = 0) -> int:
	return job_finished.connect(_callable, flags | CONNECT_ONE_SHOT)


## Alias for `then` that also adds CONNECT_DEFERRED to flags.
func then_deferred(_callable: Callable, flags: int = 0) -> int:
	return then(_callable, flags | CONNECT_DEFERRED)


func execute() -> void:
	var result = callable.call()
	job_finished.emit(result)
	if group:
		group.mark_job_finished(self, result)
