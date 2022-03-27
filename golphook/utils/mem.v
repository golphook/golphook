module utils


pub fn get_virtual(inThis voidptr, at_index int) voidptr {
	return unsafe { (*(&&&voidptr(inThis)))[at_index] }
}
