extends RigidBody2D
class_name Ragdoll2D

var collision: CollisionShape2D
var out_of_camera: VisibleOnScreenNotifier2D
var sprite: Sprite2D
var sprite_ref: Sprite2D


func _init(
	rag_collision: CollisionShape2D,
	rag_sprite: Sprite2D,
	rag_inertia: float = 0,
	impact: float = 1,
	impulse: Vector2 = Vector2.ZERO,
	offset: Vector2 = Vector2.ZERO
) -> void:
	collision = rag_collision.duplicate()
	out_of_camera = VisibleOnScreenNotifier2D.new()
	out_of_camera.connect("screen_exited", func() -> void: queue_free())
	sprite_ref = rag_sprite
	sprite = rag_sprite.duplicate()
	out_of_camera.rect = sprite.region_rect
	inertia = rag_inertia
	apply_torque(impact)
	apply_impulse(impulse, offset)
	add_child(collision)
	add_child(sprite)
	add_child(out_of_camera)
	collision.set_deferred("disabled", true)


func _physics_process(_delta: float) -> void:
	update_sprite()


func update_sprite() -> void:
	if weakref(sprite_ref).get_ref() != null:
		sprite.texture = sprite_ref.texture
		sprite.hframes = sprite_ref.hframes
		sprite.vframes = sprite_ref.vframes
		sprite.flip_h = sprite_ref.flip_h
		sprite.flip_v = sprite_ref.flip_v
		sprite.frame = sprite_ref.frame
