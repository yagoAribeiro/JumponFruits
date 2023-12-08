@tool
extends Interactable

class_name MovingStructure

##The moving speed of the structure. If 0 the structure won't move.
@export_range(0, 480, 0.5) var speed: float
##The 8x8 trail that indicates the path for the structure.
@export var trail: TextureRect

##The texture of the trail.
@export var trail_texture: Texture2D:
	set(value):
		if trail!=null:
			trail.texture = value
			trail_texture = value
##The position marking the start of the trail.
@export var start: Marker2D
##The position marking the end of the trail.
@export var end: Marker2D
##The node that will move.
@export var structure: Node2D:
	set(value):
		structure_node = value
		structure = value
##The max travelling range for the structure.
@export_range(8, 2400, 8) var trail_length: float = 8 :
	set(value): 
		trail_length = value
		if all_not_null():
			trail.size.x = value
			end.position.x = trail_length
			progress = progress

##The rotation of the trail in degrees.
@export_range(-360, 360, 1) var trail_rotation: float = 0:
	set(value):
		trail_rotation = value
		if all_not_null():
			trail.rotation_degrees = trail_rotation
			progress = progress
		

##The start point of the moving node.
@export_range(0, 1, 0.0001) var progress: float = 0:
	set(value):
		progress = value
		if all_not_null():
			structure.global_position = start.global_position + (end.global_position - start.global_position)*value
			
const Direction = {
	Going = 0,
	Coming = 1
}
var tween: Tween 
var structure_node: Node
var	direction: int = Direction.Going

func _ready() -> void:
	progress = progress
	trail_length = trail_length
	trail_rotation = trail_rotation
	structure = structure
	if all_not_null() && !Engine.is_editor_hint():
		tween = create_tween()
		moves(structure, end, speed)

func toggle() -> void:
	super.toggle()
	if structure_node is Interactable:
		if active: (structure_node as Interactable).toggle_on()
		else :(structure_node as Interactable).toggle_off()

##Return [code]true[/code] if all reference nodes aren't null		
func all_not_null() -> bool:
	return trail!=null && start!=null && end!=null && structure!=null

##Linearly moves [node_a] to [node_b] by [velocity] as constant in pixels per second.
func moves(node_a: Node2D, node_b: Node2D, velocity: float) -> void:
	var time: float = get_delta_time(node_a, node_b, velocity)
	tween.tween_property(node_a, "global_position", node_b.global_position, time)\
	.from(node_a.global_position)\
	.set_ease(Tween.EASE_IN_OUT)\
	.set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(on_move_finished)
	tween.play()

##Average velocity physics formula.
##Returns the time elapsed for [node_a] reach [node_b] by [velocity] in pixels per second. 
func get_delta_time(node_a: Node2D, node_b: Node2D, velocity: float) -> float:
	var distance: float = abs(node_b.global_position.distance_to(node_a.global_position))
	return distance/velocity
	
func on_move_finished() -> void:
	tween.kill()
	tween = create_tween()
	if direction == Direction.Going:
		direction = Direction.Coming
		moves(structure, start, speed)
	else:
		direction = Direction.Going
		moves(structure, end, speed)
