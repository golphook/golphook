module valve

pub struct CGlobalVarsBase {
pub:
	realtime f32
	framecount int
	absoluteframetime f32
	absoluteframestarttimestddev f32
	curtime f32
	frametime f32
	max_clients int
	tickcount int
	interval_per_tick f32
	interpolation_amount f32
	sim_ticks_this_frame int
	network_protocol int
	p_save_data voidptr
	bclient bool
	bremoteclient bool
	timestamp_networking_base int
	timestamp_randomize_window int
}
