extends JobNode
class_name nested_job

func execute(_result):
	printt("nested_job","_execute")
	for i in range(1000):
		printt(i)
