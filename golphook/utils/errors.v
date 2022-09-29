module utils

const errors = {
	'Failed to initialize app':     0
	'Failed to initialize console': 1
	'Failed to get inferface':      2
	'Failed to hook function':      3
	'Error with a minhook fn':      4
	"Failed to find window with name": 5
	"D3D failed to create drawing component": 6
	"Failed to create ressource configs": 7
	"Failed to access ressource configs": 8
	"Failed to resolve resolve sig": 9
	"Some module arn't loaded": 10
	"Failed to scan for patern:": 11
}

pub fn error_critical(with_error string, and_error_complement string) {

	$if prod { C.VMProtectBeginMutation(c"utils.error_critical") }

	mut err_msg := '$with_error: $and_error_complement'

	$if prod {
		err_msg = 'Error code: ${errors["with_error"]}'
	}

	C.MessageBoxA(0, &char(err_msg.str), c'[golphook] Critical error', u32(C.MB_OK | C.MB_ICONERROR))

	$if prod {
		panic(err_msg)
	}

	$if prod { C.VMProtectEnd() }
}

pub fn client_error(with_error string) {

	$if prod { C.VMProtectBeginMutation(c"utils.client_error") }

	C.MessageBoxA(0, &char(with_error.str), c'[golphook] error', u32(C.MB_OK | C.MB_ICONERROR))

	$if prod { C.VMProtectEnd() }

}
