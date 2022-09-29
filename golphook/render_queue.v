module golphook

pub struct RenderQueue {
pub mut:
	queue shared []Drawable
}

pub fn (mut r RenderQueue) push(drawable Drawable) {

	$if prod { C.VMProtectBeginMutation(c"render_queur.push") }
	
	lock r.queue {
		r.queue << drawable
	}
	
	$if prod { C.VMProtectEnd() }
}

pub fn (r &RenderQueue) len() int {

	$if prod { C.VMProtectBeginMutation(c"render_queue.len") }

	mut to_ret := 0
	rlock r.queue {
		to_ret = r.queue.len
	}

	$if prod { C.VMProtectEnd() }

	return to_ret
}

pub fn (mut r RenderQueue) clear(i int) {

	$if prod { C.VMProtectBeginMutation(c"render_queue.clear") }

	lock r.queue {
		if i == -1 {
			r.queue.clear()
			return
		}

		r.queue.clear()
	}

	$if prod { C.VMProtectEnd() }
}

pub fn (mut r RenderQueue) draw_queue() {

	$if prod { C.VMProtectBeginMutation(c"render_queue.draw_queue") }

	queue_lenght := r.len()

	rlock r.queue {
		for d in r.queue {
			d.draw()
			d.free()
		}
	}

	r.clear(queue_lenght)

	$if prod { C.VMProtectEnd() }
}
