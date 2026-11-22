extends RefCounted

const MARKS := {
	"Jajka": '<path d="M31 26c0 14-23 14-23 0C8 18 15 4 20 4s11 14 11 22Z" fill="#ffe8c3" stroke="#855f43" stroke-width="2"/>',
	"Mleko": '<path d="M26 13q13-3 10 8-1 6-10 6" fill="none" stroke="#b67d50" stroke-width="4"/><path d="M10 5h16l-2 9q12 20 0 22H12Q2 35 10 17l3-7Z" fill="#a6d6df" stroke="#527889" stroke-width="2"/><path d="M10 22h16q6 12-3 12H13q-7-1-3-12Z" fill="#fff4d9"/>',
	"Zebrane": '<circle cx="20" cy="20" r="18" fill="#234a38" stroke="#f3ffca" stroke-width="2"/><path d="m9 20 7 8 15-17" fill="none" stroke="#9ffa88" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/>',
	"Wyjdź na plac": '<path fill="none" stroke="#e9bf82" stroke-width="4" d="M5 36V5h19v8M5 36h18v-7"/><path fill="#92df95" d="M13 17h13v-7l12 11-12 11v-7H13Z"/>',
	"Tak": '<path fill="#94e18d" d="M3 18h7v18H3zm10-1 8-11q5-5 6 1l-2 9h9q5 0 3 6l-4 12q-1 3-5 3H13Z"/>',
	"Nie teraz": '<g transform="rotate(180 20 20)"><path fill="#ffa183" d="M3 18h7v18H3zm10-1 8-11q5-5 6 1l-2 9h9q5 0 3 6l-4 12q-1 3-5 3H13Z"/></g>',
	"Deska": '<path fill="#c1894e" stroke="#ffdb95" stroke-width="2" d="m6 8 26-3 3 27-27 4Z"/><path fill="none" stroke="#8f613d" stroke-width="2" d="m12 12 2 16m7-18 3 18"/><circle cx="27" cy="10" r="2" fill="#554431"/>',
	"Dzwonek": '<path fill="#ffd15f" stroke="#8d6234" stroke-width="2" d="M6 28q5-4 5-12 0-8 9-9 9 0 10 9 0 7 5 12Z"/><circle cx="20" cy="32" r="4" fill="#ffdf96"/><circle cx="20" cy="6" r="3" fill="#deb266"/>',
	"Mąka": '<path fill="#f5e4be" stroke="#9a795f" stroke-width="2" d="m14 10-3-6 17 1-4 6q16 23 4 25H12Q0 32 14 10Z"/><path stroke="#ad7748" stroke-width="3" d="m13 11 13 1"/>',
	"Słoma": '<g stroke="#e8b953" stroke-width="5" stroke-linecap="round"><path d="m7 33 8-24m0 24 4-29m3 29 2-27m5 27-2-24m8 24-5-21"/></g><path stroke="#97683c" stroke-width="4" d="M11 21h20"/>',
	"Głośnik": '<path fill="#ffe6a3" d="M3 15h7L21 6v28l-11-9H3Z"/><path fill="none" stroke="#ffe6a3" stroke-width="3.5" stroke-linecap="round" d="M26 13q7 7 0 14m5-19q12 12 0 24"/>',
	"Dalej": '<path fill="#83ea83" stroke="#244f37" stroke-width="1.5" stroke-linejoin="round" d="M3 14h18V4l16 16-16 16V26H3Z"/>',
	"Ręka": '<path fill="#ffd39d" stroke="#865338" stroke-width="1.5" stroke-linejoin="round" d="M12 23V10q0-5 4-3l1 12V5q2-4 5 0v13l1-13q3-3 5 1v13l1-9q3-4 5 1v14q-1 11-10 12-6 1-10-3L4 23q-2-5 3-5Z"/>',
	"Tarcza": '<path fill="#91c8e4" stroke="#e0efeb" stroke-width="2" d="m20 3 14 5v11q-1 12-14 18Q7 31 6 19V8Z"/><path fill="#4e7998" d="M20 8v23q9-6 9-14v-6Z"/>',
	"Łuk": '<path fill="none" stroke="#e9b867" stroke-width="4" d="M7 4q30 5 29 29"/><path fill="none" stroke="#d6e5e8" d="m7 4 29 29"/><path fill="none" stroke="#e7ecec" stroke-width="3" d="m6 34 23-24m-9 2 9-2-2 9"/>',
	"Jabłko": '<path fill="#eb7457" d="M19 10C4 2 1 22 10 32q5 6 10 2 8 4 13-8 8-22-12-16Z"/><path fill="#91b865" d="M19 12Q19 1 31 2q-1 9-12 10"/>',
	"Ser": '<path fill="#f5bb53" d="m3 18 23-13 11 10v17L3 36Z"/><path fill="#ffe293" d="m3 18 23-13 11 10Z"/><g fill="#ce883e"><circle cx="11" cy="25" r="3"/><circle cx="26" cy="22" r="3"/><circle cx="29" cy="30" r="2"/></g>',
	"Ciastko": '<circle cx="20" cy="20" r="17" fill="#cd8c56"/><g fill="#71472f"><circle cx="14" cy="13" r="3"/><circle cx="27" cy="19" r="3"/><circle cx="17" cy="28" r="3"/></g>',
	"Kałuża": '<ellipse cx="20" cy="25" rx="19" ry="9" fill="#589cb5"/><path d="M8 25q8-6 16-4" fill="none" stroke="#a8dfed" stroke-width="3"/>',
	"Pień": '<path fill="#885835" d="m8 15 25-1 3 21H5Z"/><ellipse cx="20" cy="14" rx="13" ry="8" fill="#e5b574"/><ellipse cx="20" cy="14" rx="7" ry="4" fill="none" stroke="#a57546" stroke-width="2"/>',
	"Liść": '<path fill="#74a65a" d="M5 32Q0 5 36 3q0 29-31 29"/><path stroke="#e8ce7e" stroke-width="2" d="m5 34 24-24"/>',
	"Łapka": '<g fill="#98643e"><ellipse cx="20" cy="27" rx="11" ry="8"/><circle cx="8" cy="17" r="4"/><circle cx="16" cy="10" r="4"/><circle cx="25" cy="10" r="4"/><circle cx="33" cy="17" r="4"/></g>',
	"Machnij mieczem": '<path fill="#a9d5df" d="m10 25 18-21 8-2-1 9-21 18Z"/><path stroke="#916533" stroke-width="5" d="m6 23 12 12m-6-6-8 9"/>'
}
const ACTIONS := {
	"Posłuchaj": "Głośnik", "Posłuchaj bobra": "Głośnik", "Na drugi brzeg!": "Dalej",
	"Pomogę!": "Dalej", "Ekran startowy": "Dalej", "Wróć do mapy": "Dalej",
	"Odskocz": "Dalej", "Obejdź tarczę": "Dalej", "Do słomy!": "Dalej",
	"Zablokuj": "Tarcza", "Przetnij nić": "Machnij mieczem",
	"Strzel do szyszki": "Łuk", "Strzel w szpulkę": "Łuk",
	"O kałużę": "Kałuża", "O pień": "Pień", "Zapytaj o deski": "Deska"
}

static var textures := {}

static func apply(b:Button, label:String) -> void:
	b.accessibility_name=label
	b.tooltip_text=label
	b.custom_minimum_size=Vector2(116,82)
	if label.is_valid_int():
		b.text=label
		b.add_theme_font_size_override("font_size",38)
		return
	var key:String=ACTIONS.get(label,label)
	if not MARKS.has(key): key="Ręka"
	b.icon=picture(key)
	b.text=""
	b.icon_alignment=HORIZONTAL_ALIGNMENT_CENTER
	for kind in ["normal","hover","pressed"]:
		var box:=StyleBoxFlat.new()
		box.bg_color=Color("#23563f") if key=="Dalej" else Color("#324858")
		if kind=="pressed": box.bg_color=box.bg_color.lightened(.18)
		box.border_color=Color("#9ac6a7") if key=="Dalej" else Color("#849daa")
		box.set_border_width_all(2)
		box.set_corner_radius_all(16)
		b.add_theme_stylebox_override(kind,box)

static func picture(key:String) -> Texture2D:
	if not textures.has(key):
		var img:=Image.new()
		var svg:='<svg xmlns="http://www.w3.org/2000/svg" width="62" height="62" viewBox="0 0 40 40">'+str(MARKS[key])+'</svg>'
		img.load_svg_from_string(svg)
		textures[key]=ImageTexture.create_from_image(img)
	return textures[key]
