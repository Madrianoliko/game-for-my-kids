extends RefCounted

const PRESENT := Color("#79dd88")
const EMPTY := Color("#ff7974")

static func mark(mesh:MeshInstance3D, number:int, missing:=false, lift:=.55) -> void:
	var color:=EMPTY if missing else PRESENT
	var material:=mesh.material_override as StandardMaterial3D
	material.emission_enabled=true
	material.emission=color
	material.emission_energy_multiplier=.48
	var badge:=mesh.get_node_or_null("CountBadge") as Label3D
	if not badge:
		badge=Label3D.new()
		badge.name="CountBadge"
		mesh.add_child(badge)
		badge.billboard=BaseMaterial3D.BILLBOARD_ENABLED
		badge.no_depth_test=true
		badge.font_size=46
		badge.outline_size=10
		badge.pixel_size=.014
		badge.global_transform=Transform3D(Basis.IDENTITY,mesh.global_position+Vector3.UP*lift)
	badge.modulate=color
	badge.text=str(number)
	badge.show()

static func clear(mesh:MeshInstance3D) -> void:
	var badge:=mesh.get_node_or_null("CountBadge") as Label3D
	if badge: badge.hide()
	mesh.material_override.emission_enabled=false

# Starszy zapis zawiera maskę dotknięć, bez ich kolejności.
static func order(saved:Array, mask:int, size:int) -> Array:
	var result:Array=[]
	for i in saved:
		if i>=0 and i<size and mask & (1<<i) and not result.has(i): result.append(i)
	for i in size:
		if mask & (1<<i) and not result.has(i): result.append(i)
	return result
