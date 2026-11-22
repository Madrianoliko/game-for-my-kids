extends Control

var counts := Vector2i(4,0)
const INK := Color("#ffefbc")

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size), Color("#294b58"))
	if counts.y == 0:
		var pitch := minf(86,(size.x-44)/counts.x)
		var left := (size.x-pitch*counts.x)/2
		for y in [.32,.68]:
			draw_line(Vector2(left-6,size.y*y),Vector2(size.x-left+6,size.y*y),INK,6)
		for i in counts.x:
			var plank := Rect2(left+i*pitch+5,12,pitch-10,size.y-24)
			draw_rect(plank,Color("#c9955a"))
			draw_rect(plank,INK,false,3)
			for y in [.32,.68]:
				draw_circle(Vector2(plank.get_center().x,size.y*y),3,Color("#754b34"))
	else:
		for side in 2:
			var amount := counts.x if side == 0 else counts.y
			var columns := mini(amount,4)
			var middle := size.x*(.25 if side == 0 else .75)
			for i in amount:
				var row := floori(i/4.0)
				var row_size := mini(4,amount-4*row)
				var pitch := minf(80,(size.x*.5-40)/columns)
				var x := middle+(i%4-(row_size-1)*.5)*pitch
				var y := size.y*.5 if amount<=4 else size.y*(.26 if row==0 else .74)
				draw_arc(Vector2(x,y-17),12,PI,TAU,16,INK,4,true)
				draw_rect(Rect2(x-17,y-17,34,39),Color("#ffce54"))
				draw_rect(Rect2(x-21,y-21,42,7),Color("#96c8b3"))
				draw_rect(Rect2(x-20,y+20,40,7),Color("#96c8b3"))
				draw_circle(Vector2(x,y+3),7,Color("#fff3bb"))
		draw_line(size/2-Vector2(11,0),size/2+Vector2(11,0),INK,4)
		draw_line(size/2-Vector2(0,11),size/2+Vector2(0,11),INK,4)
