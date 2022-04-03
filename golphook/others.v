module golphook

import utils
import offsets

pub fn others_on_frame() {
	bop()
}


pub fn bop() {
	mut app_ctx := unsafe { app() }

	if C.GetAsyncKeyState(C.VK_SPACE) > 1 && (app_ctx.ent_cacher.local_player.flags() & (1 << 0) == 1) {
		mut force_jump := utils.get_val_offset<u32>(app_ctx.h_client, offsets.db.signatures.force_jump)
		unsafe { *force_jump = 6 }
	}
}
