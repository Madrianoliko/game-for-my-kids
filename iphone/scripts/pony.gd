extends RefCounted

static func make(host,parent:Node3D,at:Vector3,coat:Color) -> Node3D:
	var pony:=Node3D.new()
	parent.add_child(pony)
	pony.position=at
	host.orb(pony,Vector3(0,.67,0),.52,coat).scale=Vector3(.74,.86,1.28)
	host.orb(pony,Vector3(0,1.12,.43),.36,coat)
	host.orb(pony,Vector3(0,1.08,.24),.21,Color("#805039")).scale.y=1.72
	host.orb(pony,Vector3(0,1,.66),.24,Color("#efd8af"))
	host.orb(pony,Vector3(0,.58,-.64),.19,Color("#78523e")).scale.y=1.6
	for side in [-1,1]:
		host.orb(pony,Vector3(side*.18,1.46,.40),.105,coat).scale.y=1.8
		host.orb(pony,Vector3(side*.26,1.2,.59),.045,Color("#211e21"))
		for z in [-.35,.35]:
			host.box(pony,Vector3(side*.22,.25,z),Vector3(.15,.5,.16),coat.darkened(.18))
	return pony
