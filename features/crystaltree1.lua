
local featureDef	=	{
	alwaysvisible		= true,
	name				= "Crystal Tree",
	blocking			= true,
	category			= "tree",
	damage				= 10000,
	description			= "Crystal Tree",
	energy				= 600,
	flammable			= 0,
	footprintX			= 3,
	footprintZ			= 3,
	height				= "8",
	hitdensity			= "100",
	metal				= 20,
	object				= "crystaltree1.dae",
	reclaimable			= true,
	autoreclaimable		= true, 	
	world				= "All Worlds",
}
return lowerkeys({crystaltree1 = featureDef})
