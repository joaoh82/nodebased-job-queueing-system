extends JobNode
class_name CallbackJob

func execute(_result):
	printt("nested_job","_execute")
	for i in range(1000):
		printt(i)
