module valve

[callconv: "fastcall"]
type P_get_convar = fn (voidptr, usize, &u8) &CVar


pub struct ICvar {}

/*
pub fn (i &ICvar) get_convar(with_name string) &CVar {

	return utils.call_vfunc<P_get_convar>(i, 15)(i, 0, &u8(with_name.str))
}¨*/



pub struct CVar {}
