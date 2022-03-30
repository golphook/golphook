module utils

const errors = {
	'Failed to initialize app':     0
	'Failed to initialize console': 1
	'Failed to get inferface':      2
	'Failed to hook function':      3
	'Error with a minhook fn':      4
	"Failed to find window with name": 5
	"D3D failed to create drawing component": 6
}

pub fn error_critical(withError string, andErrorComplement string) {

	mut err_msg := '$withError: $andErrorComplement'

	$if prod {
		err_msg = 'Error code: ${errors["withError"]}'
	}

	C.MessageBoxA(0, &char(err_msg.str), c'[golphook] Critical error', u32(C.MB_OK | C.MB_ICONERROR))

	$if prod {
		//panic(err_msg)
	}
}
