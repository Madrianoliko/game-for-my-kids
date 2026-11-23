extends ColorRect

signal resume_requested
signal camp_requested
signal classic_requested
signal play_requested
signal sound_requested
signal exit_requested

const TITLES := ["Dolina Hobbitów", "Hot Wheels", "Harry Potter"]
const STORIES := [
	"Most nad Bystrą Wodą",
	"W przygotowaniu: wyprawa po pomarańczowym torze.",
	"W przygotowaniu: tajemnica zamku i magiczne zagadki."
]
const GOLD := Color("#ffcf58")
const NAVY := Color("#252d45")
var margin := MarginContainer.new()
var image := TextureRect.new()
var heading := Label.new()
var story := Label.new()
var selected_world := 0
var resume := Button.new()
var camp_trial := Button.new()
var classic := Button.new()
var can_resume := false
var play := Button.new()
var stars := Label.new()
var volume := Button.new()
var illustrations: Array[Texture2D] = []
var cards: Array[Button] = []

func set_insets(inset: Vector2) -> void:
	for side in ["left","right"]:
		margin.add_theme_constant_override("margin_" + side, roundi(inset.x))
	for side in ["top","bottom"]:
		margin.add_theme_constant_override("margin_" + side, roundi(inset.y))

func style(background: Color, border: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = background
	box.border_color = border
	box.set_border_width_all(2)
	box.set_corner_radius_all(12)
	box.set_content_margin(SIDE_LEFT,14)
	box.set_content_margin(SIDE_RIGHT,14)
	return box

func format_button(b: Button, primary := false) -> void:
	b.custom_minimum_size.y = 56
	b.add_theme_font_size_override("font_size",20)
	var normal := style(GOLD, Color("#ffe291")) if primary else style(NAVY, Color("#46506a"))
	for kind in ["normal","hover","pressed"]:
		b.add_theme_stylebox_override(kind,normal)
		b.add_theme_color_override("font_color" if kind == "normal" else "font_" + kind + "_color",Color("#322810") if primary else Color.WHITE)

func picture(file: String) -> Texture2D:
	var data := Image.new()
	data.load_webp_from_buffer(FileAccess.get_file_as_bytes("res://art/menu/" + file + ".webp"))
	return ImageTexture.create_from_image(data)

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	color = Color("#101527")
	add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var column := VBoxContainer.new()
	margin.add_child(column)
	column.add_theme_constant_override("separation",9)
	var bar := HBoxContainer.new()
	column.add_child(bar)
	var brand := Label.new()
	brand.text = "Mały Odkrywca"
	brand.add_theme_font_size_override("font_size",29)
	brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_child(brand)
	bar.add_child(stars)
	stars.add_theme_font_size_override("font_size",22)
	stars.modulate = GOLD
	bar.add_child(volume)
	format_button(volume)
	volume.pressed.connect(func(): sound_requested.emit())
	var leave := Button.new()
	leave.text = "Wyjdź"
	format_button(leave)
	bar.add_child(leave)
	leave.pressed.connect(func(): exit_requested.emit())

	var hero := Control.new()
	hero.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hero.clip_contents = true
	column.add_child(hero)
	hero.add_child(image)
	hero.resized.connect(frame_illustration)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade := TextureRect.new()
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color("#10211ffa"),Color("#10211feb"),Color("#10211f00")])
	gradient.offsets = PackedFloat32Array([0,.32,.79])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	shade.texture = texture
	shade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hero.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var copy := VBoxContainer.new()
	hero.add_child(copy)
	copy.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	copy.offset_left = 28
	copy.alignment = BoxContainer.ALIGNMENT_CENTER
	copy.add_child(heading)
	heading.add_theme_font_size_override("font_size",43)
	heading.modulate = GOLD
	copy.add_child(story)
	story.add_theme_font_size_override("font_size",19)
	var actions := HBoxContainer.new()
	copy.add_child(actions)
	actions.add_child(resume)
	format_button(resume,true)
	resume.text="Wznów"
	resume.pressed.connect(func(): resume_requested.emit())
	actions.add_child(play)
	play.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	format_button(play,true)
	actions.add_child(camp_trial)
	camp_trial.text="Obóz trolli (próba)"
	camp_trial.icon=preload("res://scripts/river_icons.gd").picture("Troll")
	camp_trial.add_theme_constant_override("icon_max_width",42)
	format_button(camp_trial)
	camp_trial.pressed.connect(func(): camp_requested.emit())
	actions.add_child(classic)
	classic.text="Wyprawa Leo"
	format_button(classic)
	classic.pressed.connect(func(): classic_requested.emit())
	play.pressed.connect(func(): play_requested.emit())

	var choose := Label.new()
	choose.text = "Wybierz świat"
	choose.add_theme_font_size_override("font_size",24)
	column.add_child(choose)
	var row := HBoxContainer.new()
	column.add_child(row)
	illustrations.assign([preload("res://art/title.webp"),picture("race"),picture("magic")])
	var thumbs := [picture("hillhouse"),illustrations[1],illustrations[2]]
	for i in TITLES.size():
		var card := Button.new()
		card.text = TITLES[i]
		card.icon = thumbs[i]
		card.expand_icon = true
		card.add_theme_constant_override("icon_max_width",78)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		format_button(card)
		card.custom_minimum_size.y = 72
		row.add_child(card)
		cards.append(card)
		card.pressed.connect(select_world.bind(i))

func select_world(index: int) -> void:
	selected_world = index
	frame_illustration()
	heading.text = TITLES[index]
	story.text = STORIES[index]
	resume.visible=index==0 and can_resume
	camp_trial.visible=index==0
	classic.visible=index==0
	play.text = "Nowa przygoda" if index == 0 else "W przygotowaniu"
	play.disabled = index != 0
	for i in cards.size():
		var skin := style(NAVY,GOLD if i == index else Color("#46506a"))
		for kind in ["normal","hover","pressed"]:
			cards[i].add_theme_stylebox_override(kind,skin)

func update_status(best: int, sound: bool) -> void:
	stars.text = "Rekord: ★ %d / 4   " % best
	volume.text = "Dźwięk: wł." if sound else "Dźwięk: wył."

func frame_illustration() -> void:
	if illustrations.is_empty(): return
	var original := illustrations[selected_world]
	var hero_size := image.get_parent_area_size()
	if selected_world != 0 or hero_size.x <= 0 or hero_size.y <= 0:
		image.texture = original
		return
	var crop_height := minf(original.get_height(),original.get_width()*hero_size.y/hero_size.x)
	var crop := AtlasTexture.new()
	crop.atlas = original
	crop.region = Rect2(0,0,original.get_width(),crop_height)
	image.texture = crop
