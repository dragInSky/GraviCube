extends KinematicBody2D

const GRAVIGUN = preload("res://scenes/GraviGun.tscn")

const AIR_RESISTANCE = 0.02
const MAX_SPEED = 64
const JUMP_FORCE = 92

var gravity = 400
var acceleration = 512
var friction = 0.2
var projectile = 1
#var touch = 1

var idleSwitch = true
var is_jumping = false
var is_GraviJump = false
var dropped = false
#var touched = false
var GraviShot = false

#var touch_position = Vector2()
#var cameraLeftTop = Vector2()
var gravigun
#var mousePos
var LinePos = Vector2()

var motion = Vector2.ZERO

#func _input(event):
#	if event is InputEventScreenTouch:
#		touch *= -1
#		if touch == -1:
#			touched = true
#			touch_position = cameraLeftTop + event.position
#			$Timers/Touched.start()
#			if motion.x < 3 and motion.y < 7: 
#				var direction_of_view = (global_position - touch_position).normalized()
#				turn(direction_of_view.x)
#Считывает, двигается ли мышка в данный момент, чтобы флипнуть спрайт
#	if event is InputEventMouseMotion and motion.x < 3 and motion.y < 7:
#		var direction_of_view = (global_position - get_global_mouse_position()).normalized()
#		turn(direction_of_view.x)

func _physics_process(delta):
	#cameraLeftTop = $Camera2D.get_camera_screen_center() - get_viewport_rect().size / 2
	
	var x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if x_input != 0:
		motion.x += x_input * acceleration * delta
		motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
		$player.flip_h = x_input < 0
	
	motion.y += gravity * delta
	
	if $IceCast.is_colliding() or $IceCast2.is_colliding():
		friction = 0.02
		acceleration = 256
	else:
		friction = 0.2
		acceleration = 512
	
	if is_on_floor():
		is_jumping = false
		if idleSwitch == true:
			$AnimationPlayer.play("idle")
		
		if x_input == 0:
			motion.x = lerp(motion.x, 0, friction)
		
		if Input.is_action_pressed("ui_up"):
			is_jumping = true
			motion.y = -JUMP_FORCE
	else:
		if Input.is_action_just_released("ui_up") and motion.y < -JUMP_FORCE/2:
			motion.y = -JUMP_FORCE/2
		
		if x_input == 0:
			motion.x = lerp(motion.x, 0, AIR_RESISTANCE)
	
	print(global_position)
	
	if not is_on_floor():
		dropped = false
		$Timers/Dropped.start()
	
	#Вызывает гравитационный выстрел
	if G.GraviSwitch == true:
		if GraviShot == true and projectile > 0:
			#mousePos = get_global_mouse_position()
			LinePos = $"/root/World/Player/RayCast2D/Line2D/Node2D".global_position
			GraviShot = false
			projectile -= 1
			gravigun = GRAVIGUN.instance()
			get_parent().add_child(gravigun)
			gravigun.position = $Position2D.global_position
	
	#Плавно возвращает время на единицу
	if Engine.time_scale >= 0.6:
		if Engine.time_scale < 0.975:
			Engine.time_scale += 0.025
		else:
			Engine.time_scale = 1
	
	animation()
	
	motion = move_and_slide(motion, Vector2.UP)

func animation():
	if motion.y < -92:
		$AnimationPlayer.play("downGravi")
	if motion.y == -92:
		$AnimationPlayer.play("downFast")
	if (is_jumping == false and is_GraviJump == false) and (motion.y > 7 and motion.y < 14):
		$AnimationPlayer.play("downNoJump")
	if dropped == true:
		idleSwitch = false
		$Timers/idleSwitch.start()
		$AnimationPlayer.play("downFloor")
	if not is_on_floor() and motion.y > -12 and motion.y < 12 and is_GraviJump == true:
		$AnimationPlayer.play("downMiddle")

func turn(direction_of_view):
	if direction_of_view > 0:
		$player.set_flip_h(true)
	else:
		$player.set_flip_h(false)

#Вектор направления отталкивая от гравитационного выстрела
func Vector():
	is_GraviJump = true
	var graviMotion = 50 * ((global_position - gravigun.global_position).normalized())
	motion.y = 3 * graviMotion.y
	motion.x = 4 * graviMotion.x
	Engine.time_scale = 0.7 #Небольшое замедление времени во время взрыва

#Timers
func _on_idleSwitch_timeout():
	idleSwitch = true
func _on_Dropped_timeout():
	if is_on_floor():
		dropped = true
#func _on_Touched_timeout():
#	touched = false

func _return_drop():
	dropped = false

#Рестартает сцену, если игрок вышел за лимит камеры
func _on_VisibilityNotifier2D_screen_exited():
	get_tree().reload_current_scene()
