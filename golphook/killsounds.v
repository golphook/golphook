module golphook

import utils
import offsets
import rand
import d3d
import v.embed_file

#flag -lwinmm

#include "mmsystem.h"

fn C.PlaySound(voidptr, voidptr, u32) bool

fn get_asset_for_kill(kills int) string {
	$if prod {
		C.VMProtectBeginMutation(c'killsound.asset_for_kill')
	}

	if kills > 5 {
		return 'k_five'
	}

	match kills {
		1 { return 'k_one' }
		2 { return 'k_two' }
		3 { return 'k_three' }
		4 { return 'k_four' }
		else { return 'k_five' }
	}

	$if prod {
		C.VMProtectEnd()
	}
}

struct KillSound {
pub mut:
	old_kill    int
	old_kill_hs int
	kill_streak int

	last_tick int

	texture d3d.D3dTexture
	sprite d3d.D3dSprite


	imgs map[string]embed_file.EmbedFileData = {
		"k_one": $embed_file('../ressources/images/k1.png')
		"k_two": $embed_file('../ressources/images/k2.png')
		"k_three": $embed_file('../ressources/images/k3.png')
		"k_four": $embed_file('../ressources/images/k4.png')
		"k_five": $embed_file('../ressources/images/k5.png')	
	}

	sounds map[string]embed_file.EmbedFileData = {
		'k_one':   $embed_file('../ressources/sounds/k_one.wav')
		'k_two':   $embed_file('../ressources/sounds/k_two.wav')
		'k_three': $embed_file('../ressources/sounds/k_three.wav')
		'k_four':  $embed_file('../ressources/sounds/k_four.wav')
		'k_five':  $embed_file('../ressources/sounds/k_five.wav')
		'hs':      $embed_file('../ressources/sounds/hs.wav')
		'woof':    $embed_file('../ressources/sounds/woof.wav')
		'db_woof': $embed_file('../ressources/sounds/db_woof.wav')
	}
	messages []string = [
		"level 180 sur steam mais je cheat, t'as raison oui",
		'mon steam vaut plus cher que ta vie',
		"jsuis a moitié dans l'coma les yeux rouges et jrecois des nudes",
		'Depuis le vacban les filles on prit leur jambe à leur cou',
		'ya des fois jaimerais etre gay, les mecs c moins compliqués',
		'facile a hacker les succes steam mdrr',
		"Tout mon détail, j’le foutais dans ma p'tite trousse",
		"Et j'm'en rappelle du premier jour d'la rentrée: cent-trente euros en barrette",
		'ma Beyoncé elle msuce la bite negro',
		"mon gar je trouve que jeter de l'argent sur un account sa va servir a rien je gaspile de l'argent sur quelque chose qui vaut la peine sale geek et mon main coute dans les 800 dollar il est locked par volvo",
		'merci qd mm la mission local pr la garantie jeune ca ma bien depannnn',
		'Mets ça sur ton pain ça sera moins sec',
		'Attention les filles en mode enflure',
		'et ma bitch a toujours le xanax et la og dans le purse',
		"truc d'africain de ce lever pour le pain",
		'Transaction en monero même allah sait pas à qui j’envoie',
		'full awall comme au bataclan s/o golphook',
		'Nouveaux calçon vuitton, merci a mes nugget pour le coton',
		'trop d’halu jvois les hillus en chams crystal blue',
	]

}


fn (k &KillSound) play_sound(withSound string) {
	$if prod {
		C.VMProtectBeginMutation(c'killsound.play_sound')
	}

	mut file := k.sounds[withSound]
	
	C.PlaySound(voidptr(file.data()), 0, u32(C.SND_ASYNC | C.SND_MEMORY))

	$if prod {
		C.VMProtectEnd()
	}
}

fn (mut k KillSound) display_img(with_img string) {

	$if prod {
		C.VMProtectBeginMutation(c'killsound.display_img')
	}

	mut app_ctx := unsafe { app() }

	k.last_tick = 0

	if !isnil(k.texture.i_dxtexture) && !isnil(k.sprite.i_dxsprite) {
		unsafe {	
			//k.texture.release()
			//k.sprite.release()
		}
	}

	mut file := k.imgs[with_img]
	C.D3DXCreateTextureFromFileInMemory(app_ctx.d3d.device, voidptr(file.data()), file.len, &k.texture.i_dxtexture)
	C.D3DXCreateSprite(app_ctx.d3d.device, &k.sprite.i_dxsprite)

	k.last_tick = app_ctx.interfaces.c_global_vars.tickcount
	
	$if prod {
		C.VMProtectEnd()
	}
}

fn (mut k KillSound) on_end_scenes() {

	$if prod {
		C.VMProtectBeginMutation(c'killsound.on_endsene')
	}

	mut app_ctx := unsafe { app() }

	if !app_ctx.interfaces.cdll_int.is_in_game() && !app_ctx.interfaces.cdll_int.is_connected() {
		k.last_tick = 0
		return
	}
	

	if !isnil(k.texture.i_dxtexture) && !isnil(k.sprite.i_dxsprite) && !(app_ctx.interfaces.c_global_vars.tickcount > (k.last_tick + 335))  {
		pos := utils.new_vec3(f32((app_ctx.wnd_width / 2) - 50), (f32(app_ctx.wnd_height) / 1.3), 0)
		unsafe {
			k.sprite.begin(C.D3DXSPRITE_ALPHABLEND)
			k.sprite.draw(k.texture.i_dxtexture, voidptr(0), voidptr(0), &pos, utils.color_rbga<u8>(255, 255, 255, 255))
			k.sprite.end()
		}
	}

	$if prod {
		C.VMProtectEnd()
	}
}

pub fn (mut k KillSound) get_kill() int {
	$if prod {
		C.VMProtectBeginMutation(c'killsound.get_kill')
	}

	mut app_ctx := unsafe { app() }

	a := *(&usize(usize(app_ctx.h_client) + offsets.db.signatures.player_resource))
	lcp_id := app_ctx.ent_cacher.local_player.index()
	kills_total := &int(a + usize(offsets.db.netvars.match_stats_kills_total) + usize(lcp_id * 0x4))

	$if prod {
		C.VMProtectEnd()
	}

	return *kills_total
}

pub fn (mut k KillSound) get_kill_hs() int {
	$if prod {
		C.VMProtectBeginMutation(c'killsound.get_kill_hs')
	}

	mut app_ctx := unsafe { app() }

	a := *(&usize(usize(app_ctx.h_client) + offsets.db.signatures.player_resource))
	lcp_id := app_ctx.ent_cacher.local_player.index()
	hs_kills := &int(a + usize(offsets.db.netvars.match_stats_headshot_kills_total) +
		usize(lcp_id * 0x4))

	$if prod {
		C.VMProtectEnd()
	}

	return *hs_kills
}

fn (mut k KillSound) is_freeze_time() bool {
	$if prod {
		C.VMProtectBeginMutation(c'killsound.is_freeze_time')
	}

	mut app_ctx := unsafe { app() }

	a := *(&usize(usize(app_ctx.h_client) + offsets.db.signatures.game_rules_proxy))
	is_freeze_time := &bool(a + usize(offsets.db.netvars.freeze_period))

	$if prod {
		C.VMProtectEnd()
	}

	return *is_freeze_time
}

fn (mut k KillSound) on_frame() {
	$if prod {
		C.VMProtectBeginMutation(c'killsound.on_frame')
	}

	mut app_ctx := unsafe { app() }

	if k.is_freeze_time() {
		k.kill_streak = 0
		k.last_tick = 0
	}

	if k.get_kill() > k.old_kill {
		if app_ctx.config.active_config.killsay {
			// using rand module cause crash
			// user array[idx] cause crash ...
			// using a const array don't give any result

			
			a := C.rand() % k.messages.len
			mut f_msg := ''

			for idx, msg in k.messages {
				if idx == a {
					f_msg = msg
				}
			}

			app_ctx.interfaces.cdll_int.client_cmd('say $f_msg')
		}

		if app_ctx.config.active_config.killsound {
			if k.get_kill_hs() > k.old_kill_hs {
				k.kill_streak++
				k.display_img(get_asset_for_kill(k.kill_streak))
				if app_ctx.config.active_config.killsound_type == 1 {
						k.play_sound('hs')
				} else {
						k.play_sound('db_woof')
				}
			} else {
				k.kill_streak++
				k.display_img(get_asset_for_kill(k.kill_streak))
				if app_ctx.config.active_config.killsound_type == 1 {
						k.play_sound(get_asset_for_kill(k.kill_streak))
				} else {
						k.play_sound('woof')
				}
			}
		}
	}

	k.old_kill = k.get_kill()
	k.old_kill_hs = k.get_kill_hs()

	$if prod { C.VMProtectEnd() }
}
