extends Control
var counts := Vector2i(4,0)

func _draw() -> void:
	var ink := Color("#ffefbc")
	draw_rect(Rect2(Vector2.ZERO,size),Color("#294b58"))
	for x in range(0,int(size.x),16): draw_line(Vector2(x,0),Vector2(x,size.y),Color("#375c68"))
	for y in range(0,int(size.y),16): draw_line(Vector2(0,y),Vector2(size.x,y),Color("#375c68"))
	if counts.y==0:
		var spacing := minf(29,(size.x-32)/counts.x)
		var left := (size.x-spacing*counts.x)/2
		for y in [33,57]: draw_line(Vector2(left-6,y),Vector2(size.x-left+6,y),ink,4)
		for i in counts.x:
			var plank := Rect2(left+i*spacing+2,18,spacing-4,56)
			draw_rect(plank,Color("#bd905c"))
			draw_rect(plank,ink,false,2)
			for y in [30,59]: draw_circle(Vector2(plank.get_center().x,y),2,Color("#754b34"))
	else:
		for side in 2:
			var amount := counts.x if side==0 else counts.y
			var middle := size.x*(.25 if side==0 else .75)
			for i in amount:
				var x := middle+(i-(amount-1)*.5)*30
				draw_arc(Vector2(x,34),8,PI,TAU,12,ink,2)
				draw_rect(Rect2(x-10,36,20,25),Color("#ffd15e"))
				draw_rect(Rect2(x-13,33,26,5),Color("#84ab94"))
				draw_rect(Rect2(x-12,61,24,5),Color("#84ab94"))
		draw_line(size/2-Vector2(8,0),size/2+Vector2(8,0),ink,3)
		draw_line(size/2-Vector2(0,8),size/2+Vector2(0,8),ink,3)
