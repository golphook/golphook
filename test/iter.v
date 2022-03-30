module main


struct RenderQueue {
pub mut:
	arr []string

	to_draw_cnt int
	idx int
	drawing bool
}

fn (mut r RenderQueue) next() ?&string {

	if !r.drawing {
		r.drawing = true
		r.to_draw_cnt = r.arr.len
	}

	if r.idx == r.to_draw_cnt {
		r.drawing = false
		r.arr.delete_many(0, r.to_draw_cnt)
		r.to_draw_cnt = 0
		r.idx = 0
		return error("")
	}

	defer {
		r.idx++
	}
	return &r.arr[r.idx]
}

fn main() {

	mut a := map[string]map[int]int{}
	a["dd"][1] = 2
	a["dd"][2] = 2
	a["dd"][3] = 2

	a["zz"][1] = 3
	a["zz"][2] = 3
	a["zz"][3] = 3

	for k,v  in a {
		dump(k)
		dump(v)
	}

}
