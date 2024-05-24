extends JobNode
class_name nested_job

func execute():
	printt("nested_job","_execute")
	for i in range(1000):
		printt(i)
