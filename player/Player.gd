class_name Player extends KinematicBody2D


# PRELOADS
const dustCloudScene: PackedScene =  preload("res://player/dust-cloud/DustCloud.tscn")

# SIGNALS
signal died

# EXPORTS

# CONSTS
# Vertical movement properties
const ACCEL_GRAVITY: int = 35	# In 1 frame, how many units of space the player will accelerate downwards
const MAX_SPEED_UP: int = -1500
const MAX_SPEED_DOWN: int = 1500
const ACCEL_JUMP: int = -500
# Horizontal movement properties
const ACCEL_WALK: int = 20	# In 1 frame, how many units of space the player will accelerate horizontaly when walking
const ACCEL_WALK_FRICTION: float = 0.6	# In 1 frame, percentage of horizontal ground speed the player will keep
const ACCEL_AIR_FRICTION: float = 0.9	# In 1 frame, percentage of horizontal aerial speed the player will keep
const MAX_SPEED_WALK: int = 280
# Wall sliding properties
const ACCEL_WALL_SLIDE: int = 10
const MAX_SPEED_WALL_SLIDE: int = 150

# ENUMS
enum STATES {WALKING, FALLING, WALL_SLIDING}

# VARS
onready var wallSlidingDetector: WallSlidingDetector = $WallSlidingDetector
onready var hitbox: CollisionShape2D = $CollisionShape2D
onready var sprite: AnimatedSprite = $AnimatedSprite
onready var jumpSFX: AudioStreamPlayer = $JumpSFX
onready var deathSFX: AudioStreamPlayer = $DeathSFX
onready var animationPlayer: AnimationPlayer = $AnimationPlayer
onready var dustCloudTimer: Timer = $DustCloudTimer
onready var wallJumpFrictionTimer: Timer = $WallJumpFrictionTimer
var velocity: Vector2 = Vector2()
var canWallSlide: bool = true
var paused: bool = false
var previousState = null
var state = STATES.FALLING setget _setState

func _setState(newState):
	previousState = state
	state = newState
	print_debug("New state: ", newState)

# METHODS
func _ready():
	sprite.animation = "idle"
	sprite.speed_scale = 1
	sprite.play()

func _input(event: InputEvent):
	if paused:
		return

	if event is InputEventKey:
		if event.is_action_pressed("jump"):
			_jump()

func _physics_process(delta: float):
	if paused:
		return

	# Apply input-based movement velocities and relevant friction
	_applyMovement(delta)

	# Move player and store remaining velocity after collisions
	velocity = move_and_slide(velocity, Vector2(0, -1))

	# Change player state to most appropriate
	_changeState()

	# Check if wall-sliding can be enabled
	_checkCanWallSlideProcess()

func _process(_delta: float):
	if paused:
		return

	_dustCloudsProcess()

# Calculate and apply player horizontal movement changes made by their inputs.
# Only meant to be used in `_physics_process()`.
func _applyMovement(_delta: float) -> void:
	var pressingRight: bool = Input.is_action_pressed("move_right")
	var pressingLeft: bool = Input.is_action_pressed("move_left")
	var intendedDirection: int = int(pressingRight) - int(pressingLeft)	# -1 (left), 0 (both/none) or 1 (right)

	match state:
		STATES.WALKING, STATES.FALLING:
			# Apply gravity
			velocity.y += ACCEL_GRAVITY

			# Apply movement acceleration in the player's intended direction
			# If player is pressing both movement keys or none, don't apply movement acceleration
			velocity.x += ACCEL_WALK * intendedDirection

			# Apply friction influence
			if STATES.WALL_SLIDING != previousState or not wallJumpFrictionTimer.time_left:
				_applyHorizontalFriction(intendedDirection)

			# Clamp vertical and horizontal movement
			velocity.y = clamp(velocity.y, MAX_SPEED_UP, MAX_SPEED_DOWN)
			velocity.x = clamp(velocity.x, -MAX_SPEED_WALK, MAX_SPEED_WALK)

			# Change sprite direction
			_changeSpriteDirection(intendedDirection)

			# Change sprite animation state
			_changeSpriteAnimation()

		STATES.WALL_SLIDING:
			velocity.y += ACCEL_WALL_SLIDE if velocity.y > 0 else ACCEL_GRAVITY

			# Clamp vertical movement
			velocity.y = clamp(velocity.y, MAX_SPEED_UP, MAX_SPEED_WALL_SLIDE)

		_:
			push_error("No matching state found in _physics_process()")

# Calculates and applies the friction to be applied to the player.
# No friction is applied if the player is moving in the same direction as their current velocity.
# `intended_direction` must be an integer of value -1, 0 or 1, each representing a movement direction intended by the player, respectively: left, both/none and right.
# Only meant to be used in `_physics_process()`.
func _applyHorizontalFriction(intended_direction: int) -> void:
	# If player wants to move in the same direction as their current movement, don't apply friction
	if intended_direction * velocity.x > 0:
		return

	if abs(velocity.x) > 1:
		velocity.x *= ACCEL_WALK_FRICTION if STATES.WALKING == state else ACCEL_AIR_FRICTION
	else:
		velocity.x = 0

func _changeSpriteDirection(intendedDirection: int) -> void:
	if 0 != intendedDirection:
		sprite.flip_h = bool(1 - intendedDirection)

func _changeSpriteAnimation() -> void:
	var absVelocityX: float = abs(velocity.x)

	match state:
		STATES.WALKING:
			if velocity.x:
				sprite.animation = "walking"
				sprite.speed_scale = absVelocityX/MAX_SPEED_WALK
			else:
				sprite.animation = "idle"
				sprite.speed_scale = 1

		STATES.FALLING:
			sprite.animation = "falling"
			sprite.speed_scale = 1

		_:
			sprite.animation = "idle"
			sprite.speed_scale = 1

# Checks some conditions to determine which state the player should be in and applies it.
# Only meant to be used in `_physics_process()`.
func _changeState() -> void:
	if STATES.WALKING != state and is_on_floor():
		self.state = STATES.WALKING
		wallJumpFrictionTimer.stop()

	elif (STATES.WALL_SLIDING != state
	and STATES.WALKING != state
	and wallSlidingDetector.getCollisionSide()
	and canWallSlide):
		self.state = STATES.WALL_SLIDING
		velocity.x = 0

	elif STATES.FALLING != state and not is_on_floor() and not wallSlidingDetector.getCollisionSide():
		self.state = STATES.FALLING

# Controls the creation of dust clouds when wall-sliding
func _dustCloudsProcess() -> void:
	if STATES.WALL_SLIDING == state and not dustCloudTimer.time_left:
		var dustCloud: DustCloud = dustCloudScene.instance()
		var positionX: float = global_position.x + ((hitbox.shape.extents.x / 2) * wallSlidingDetector.getCollisionSide())
		var positionY: float = global_position.y + (hitbox.shape.extents.y / 2)
		dustCloud.global_position = Vector2(positionX, positionY)
		get_tree().current_scene.add_child(dustCloud)

		dustCloudTimer.start(dustCloudTimer.wait_time)

		print_debug("Created dust cloud (%s, %s)" % [dustCloud.global_position.x, dustCloud.global_position.y])

# Contains all the jumping and wall-jumping logic
func _jump() -> void:
	match state:
		# Jump
		STATES.WALKING:
			velocity.y = ACCEL_JUMP
			self.state = STATES.FALLING
			jumpSFX.play()

		# Wall jump
		STATES.WALL_SLIDING:
			var wallCollisionSide: int = wallSlidingDetector.getCollisionSide()

			self.state = STATES.FALLING
			velocity.y = ACCEL_JUMP
			velocity.x = -MAX_SPEED_WALK if 1 == wallCollisionSide else MAX_SPEED_WALK
			_changeSpriteDirection(-wallCollisionSide)
			canWallSlide = false
			jumpSFX.play()

			wallJumpFrictionTimer.start()

		# Nothing happens
		_:
			pass

# Checks if wall-sliding detectors are no longer colliding with the previous wall
# Only meant to be used in `_physics_process()`
func _checkCanWallSlideProcess() -> void:
	if not canWallSlide and not wallSlidingDetector.getCollisionSide():
		canWallSlide = true

# Triggers player death
func kill() -> void:
	# Pause player
	paused = true

	# Play death animation and SFX
	# "died" signal is emitted when animation is over
	animationPlayer.play("Death")
	deathSFX.play()

func _on_AnimationPlayer_animation_finished(anim_name:String):
	match anim_name:
		"Death":
			emit_signal("died")

		_:
			pass
