extends AnimationPlayer

## Allow player movement during cinematic
@export var allow_player_movement: bool = true

## Player movement speed during cinematic
@export var movement_speed: float = 300.0

var character_sprite: AnimatedSprite2D
var is_cinematic_animation_playing: bool = false
var manual_animation_control: bool = false

func _ready() -> void:
	# Busca directamente el AnimatedSprite2D
	var node = get_node_or_null("../Character")
	if node and node is AnimatedSprite2D:
		character_sprite = node
	else:
		print("Warning: '../Character' no es AnimatedSprite2D")
	
	# Connect animation signals with error checking
	if not animation_started.is_connected(_on_animation_started):
		animation_started.connect(_on_animation_started)
	if not animation_finished.is_connected(_on_animation_finished):
		animation_finished.connect(_on_animation_finished)

func _process(delta: float) -> void:
	if allow_player_movement and character_sprite != null and not manual_animation_control:
		handle_player_movement(delta)

func handle_player_movement(delta: float) -> void:
	if not character_sprite:
		return

	var input_vector = Vector2.ZERO

	if Input.is_action_pressed("ui_right") or (InputMap.has_action("move_right") and Input.is_action_pressed("move_right")):
		input_vector.x += 1
		character_sprite.flip_h = false
	elif Input.is_action_pressed("ui_left") or (InputMap.has_action("move_left") and Input.is_action_pressed("move_left")):
		input_vector.x -= 1
		character_sprite.flip_h = true

	if Input.is_action_pressed("ui_down") or (InputMap.has_action("move_down") and Input.is_action_pressed("move_down")):
		input_vector.y += 1
	elif Input.is_action_pressed("ui_up") or (InputMap.has_action("move_up") and Input.is_action_pressed("move_up")):
		input_vector.y -= 1

	if input_vector != Vector2.ZERO:
		# Movimiento simple sin colisiones
		character_sprite.position += input_vector.normalized() * movement_speed * delta
		
		# Animación caminando
		if not is_cinematic_animation_playing and character_sprite.sprite_frames:
			if character_sprite.sprite_frames.has_animation("walk"):
				character_sprite.animation = "walk"
	else:
		# Animación idle
		if not is_cinematic_animation_playing and character_sprite.sprite_frames:
			if character_sprite.sprite_frames.has_animation("idle"):
				character_sprite.animation = "idle"

func _on_animation_started(anim_name: StringName) -> void:
	# Mark cinematic animations
	if anim_name in ["walk_on", "walk_off"]:
		is_cinematic_animation_playing = true
		manual_animation_control = true

func _on_animation_finished(anim_name: StringName) -> void:
	# Release control after cinematic animations
	if anim_name in ["walk_on", "walk_off"]:
		is_cinematic_animation_playing = false
		manual_animation_control = false

## Call this function to disable player movement
func disable_player_movement() -> void:
	allow_player_movement = false

## Call this function to enable player movement
func enable_player_movement() -> void:
	allow_player_movement = true

## Call this function to temporarily disable movement during specific sequences
func lock_movement_for_animation() -> void:
	manual_animation_control = true

## Call this function to restore movement after specific sequences
func unlock_movement_after_animation() -> void:
	manual_animation_control = false

## Move character to specific position with animation
func move_character_to(target_position: Vector2, duration: float = 1.0) -> void:
	if not character_sprite:
		print("Warning: Cannot move character - character node not found")
		return
		
	manual_animation_control = true
	var tween = create_tween()
	if tween:
		tween.tween_property(character_sprite, "position", target_position, duration)
		await tween.finished
	manual_animation_control = false

## Set character animation manually (useful for cutscenes)
func set_character_animation(animation_name: String) -> void:
	if character_sprite and character_sprite.sprite_frames and character_sprite.sprite_frames.has_animation(animation_name):
		character_sprite.animation = animation_name
	else:
		print("Warning: Cannot set animation '" + animation_name + "' - character or animation not found")

## Play a cinematic animation sequence
func play_cinematic_sequence(anim_name: String, disable_movement: bool = true) -> void:
	if not has_animation(anim_name):
		print("Warning: Animation '" + anim_name + "' not found")
		return
		
	if disable_movement:
		manual_animation_control = true
	
	play(anim_name)
	await animation_finished
	
	if disable_movement:
		manual_animation_control = false
