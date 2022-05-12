module valve

// import utils
//
// struct UIEngine {}
//
// type P_access_engine = fn(voidptr, usize) &UIEngine
//
// pub fn (u &UIEngine) access_engine() &UIEngine {
// 	return utils.call_vfunc<P_access_engine>(u, 11)(u, 0)
// }
//
// struct IPanoramaUIEngine {}
//
// type P_access_engine = fn() &UIEngine
//
// pub fn (mut i IPanoramaUIEngine) access_engine() &UIEngine {
// 	o_fn_add := utils.get_virtual(i, 11)
//
// 	o_fn := &P_access_engine(o_fn_add)
// 	C.load_this(i)
//
// 	rs := o_fn()
// 	return rs
// }
