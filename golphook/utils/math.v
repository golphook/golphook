module utils

import math

pub const radian = math.pi / 180.0

pub fn distance_from(from_ent Vec3, to_ent Vec3) f32 {

	return f32(math.sqrt(math.pow(from_ent.x - to_ent.x, 2) + math.pow(from_ent.y - to_ent.y, 2) + math.pow(from_ent.z - to_ent.z, 2)))
}

pub fn sin_cos(with_radion f32) (f32, f32) {

	return math.sinf(with_radion), math.cosf(with_radion)
}

pub fn angle_to_vectors(with_angle Angle) (Vec3, Vec3, Vec3) {

	$if prod { C.VMProtectBeginMutation(c"utils.angle_to_vec") }

	sp, cp := sin_cos(radian * with_angle.pitch)
	sy, cy := sin_cos(radian * with_angle.yaw)
	sr, cr := sin_cos(radian * with_angle.roll)

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

	$if prod { C.VMProtectEnd() }

	return fwd_bwd, lft_rght, up_dwn
}
