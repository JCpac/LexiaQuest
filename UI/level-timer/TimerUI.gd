class_name TimerUI extends PanelContainer


# SIGNALS
signal timeout

# VARS
var paused: bool = false setget _pauseTimer

onready var _label: Label = $Label
onready var _timer: Timer = $Timer

# METHODS
func _process(_delta):
	_label.text = _toFormattedMinuteString(_timer.time_left as int)

func start(timeInSeconds: int) -> void:
	_timer.start(timeInSeconds)

func _pauseTimer(pausedValue: bool) -> void:
	paused = pausedValue
	
	_timer.paused = paused

func isRunning() -> bool:
	return bool(_timer.time_left as int)

func _toFormattedMinuteString(timeInSeconds: int) -> String:
	var minutes: int = 0

	while(timeInSeconds >= 60):
		timeInSeconds -= 60
		minutes += 1

	var formattedSeconds: String = "0%s" % timeInSeconds if timeInSeconds < 10 else "%s" % timeInSeconds
	return "%s:%s" % [minutes, formattedSeconds]

# SIGNAL CALLBACKS
func _on_Timer_timeout():
	emit_signal("timeout")
