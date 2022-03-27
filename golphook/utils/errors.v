module utils

const errors = {
	'Failed to initialize app':     0
	'Failed to initialize console': 1
	'Failed to get inferface':      2
	'Failed to hook function':      3
	'Error with a minhook fn':      4
}

pub fn error_critical(withError string, andErrorComplement string) {
	C.Beep(667, 670)
	mut err_msg := '$withError: $andErrorComplement'
	/*
	$if prod {
		err_msg = 'Error code: ${errors["withError"]}'
	}*/

	C.MessageBoxA(0, &char(err_msg.str), c'[golphook] Critical error', u32(C.MB_OK | C.MB_ICONERROR))
	panic(err_msg)
}
