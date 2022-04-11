module golphook

import utils
import offsets

#flag -lwinmm

#include "mmsystem.h"
fn C.PlaySound(voidptr, voidptr, u32) bool

fn get_sound_for_kill(kills int) string {
	if kills > 5 {
		return "k_five"
	}

	match kills {
		1 { return "k_one" }
		2 { return  "k_two"}
		3 { return "k_three" }
		4 { return "k_four" }
		else { return "k_five" }
	}
}


struct KillSound {
pub mut:
	old_kill int
	old_kill_hs int
	kill_streak int
}

fn (mut k KillSound) bootstrap() {

}

fn (k &KillSound) play_sound(withSound string) {

	sounds := {
		"k_one": $embed_file('../ressources/sounds/k_one.wav'),
		"k_two": $embed_file('../ressources/sounds/k_two.wav'),
		"k_three": $embed_file('../ressources/sounds/k_three.wav'),
		"k_four": $embed_file('../ressources/sounds/k_four.wav'),
		"k_five": $embed_file('../ressources/sounds/k_five.wav'),
		"hs": $embed_file('../ressources/sounds/hs.wav')
	}

	mut file := sounds[withSound]

	C.PlaySound(voidptr(file.data()), 0, u32(C.SND_ASYNC | C.SND_MEMORY))
}

fn (mut k KillSound) get_kill() int {
	mut app_ctx := unsafe { app() }
	a := *(&usize(usize(app_ctx.h_client) + offsets.db.signatures.player_resource))
	lcp_id := app_ctx.ent_cacher.local_player_id
	kills_total := &int(a + usize(offsets.db.netvars.match_stats_kills_total) + usize(lcp_id * 0x4))
	return *kills_total
}

fn (mut k KillSound) get_kill_hs() int {
	mut app_ctx := unsafe { app() }
	a := *(&usize(usize(app_ctx.h_client) + offsets.db.signatures.player_resource))
	lcp_id := app_ctx.ent_cacher.local_player_id
	hs_kills := &int(a + usize(offsets.db.netvars.match_stats_headshot_kills_total) + usize(lcp_id * 0x4))
	return *hs_kills
}

fn (mut k KillSound) is_freeze_time() bool {
	mut app_ctx := unsafe { app() }
	a := *(&usize(usize(app_ctx.h_client) + offsets.db.signatures.game_rules_proxy))
	is_freeze_time := &bool(a + usize(offsets.db.netvars.freeze_period))
	return *is_freeze_time
}


fn (mut k KillSound) on_frame() {
	mut app_ctx := unsafe { app() }
	
	if !app_ctx.config.active_config.killsound {
		return
	}

	if k.is_freeze_time() {
		k.kill_streak = 0
	}

	if k.get_kill() > k.old_kill {
		if k.get_kill_hs() > k.old_kill_hs {
			k.kill_streak++
			k.play_sound("hs")
		} else {
			k.kill_streak++
			k.play_sound(get_sound_for_kill(k.kill_streak))
		}
	}

	k.old_kill = k.get_kill()
	k.old_kill_hs = k.get_kill_hs()

}
