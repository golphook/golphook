module golphook

pub struct RenderQueue {
pub mut:
	queue shared []&Drawable

}

pub fn (mut r RenderQueue) push(drawable &Drawable) {
	lock r.queue {
		r.queue << drawable
	}
}

pub fn (r RenderQueue) len() int {
	mut to_ret := 0
	rlock r.queue {
		to_ret = r.queue.len
	}
	return to_ret
}

pub fn (r RenderQueue) at(index int) &Drawable {
	mut to_ret := &Drawable(voidptr(0))
	rlock r.queue {
		to_ret = &r.queue[index]
	}
	return to_ret
}

pub fn (mut r RenderQueue) clear(i int) {
	lock r.queue {
		//r.queue.clear()
		for o in 0..i {
			free(r.queue[o])
		}
		r.queue.delete_many(0, i)
	}
}

pub fn (mut r RenderQueue) draw_queue() {
	queue_lenght := r.len()

	rlock r.queue {
		for d in r.queue {
			d.draw()
		}
	}

	r.clear(queue_lenght)
}
