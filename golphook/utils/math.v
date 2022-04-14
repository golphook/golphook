module utils

import math

const radian = math.pi / 180.0

pub fn distance_from(firstEnt Vec3, toEnt Vec3) f32 {
	return f32(math.sqrt(math.pow(firstEnt.x - toEnt.x, 2) + math.pow(firstEnt.y - toEnt.y, 2) + math.pow(firstEnt.z - toEnt.z, 2)))
}

pub fn sin_cos(withRadian f32) (f32, f32) {
	return math.sinf(withRadian), math.cosf(withRadian)
}

pub fn angle_to_vectors(withAngle Angle) (Vec3, Vec3, Vec3) {
	sp, cp := sin_cos(radian * withAngle.pitch)
	sy, cy := sin_cos(radian * withAngle.yaw)
	sr, cr := sin_cos(radian * withAngle.roll)

	mut fwd_bwd := new_vec3(0,0,0)
	mut lft_rght := new_vec3(0,0,0)
	mut up_dwn := new_vec3(0,0,0)

	fwd_bwd.x = cp * cy
	fwd_bwd.y = cp * sy
	fwd_bwd.z = -sp

	lft_rght.x = -1.0 * sr * sp * cy + -1.0 * cr * -sy
	lft_rght.y = -1.0 * sr * sp * sy + -1.0 * cr * cy
	lft_rght.z = -1.0 * sr * cp

	up_dwn.x = cr * sp * cy + -sr * -sy
	up_dwn.y = cr * sp * sy + -sr * cy
	up_dwn.z = cr * cp

	return fwd_bwd, lft_rght, up_dwn
}
