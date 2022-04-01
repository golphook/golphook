module utils

import math

pub fn distance_from(firstEnt Vec3, toEnt Vec3) f32 {
	return f32(math.sqrt(math.pow(firstEnt.x - toEnt.x, 2) + math.pow(firstEnt.y - toEnt.y, 2) + math.pow(firstEnt.z - toEnt.z, 2)))
}
