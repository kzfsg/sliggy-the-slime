extends Node

var deaths = 0
var time_elapsed = 0

func _process(delta):
	time_elapsed += delta
	var time_str = str(snapped(time_elapsed, 0.01))
	var pad = 2 - time_str.split('.')[-1].length()
	for i in range(pad):
		time_str += '0'
	if '.' not in time_str:
		time_str += '.00'
