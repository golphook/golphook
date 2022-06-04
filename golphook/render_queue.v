module golphook

pub struct RenderQueue {
pub mut:
	queue shared []Drawable
}

pub fn (mut r RenderQueue) push(drawable Drawable) {

	lock r.queue {
		r.queue << drawable
	}
}

pub fn (r &RenderQueue) len() int {

	mut to_ret := 0
	rlock r.queue {
		to_ret = r.queue.len
	}
	return to_ret
}

pub fn (mut r RenderQueue) clear(i int) {

	lock r.queue {
		if i == -1 {
			r.queue.clear()
			return
		}

		r.queue.clear()
	}
}

pub fn (mut r RenderQueue) draw_queue() {

	queue_lenght := r.len()

	rlock r.queue {
		for d in r.queue {
			d.draw()
			d.free()
		}
	}

	r.clear(queue_lenght)
}
