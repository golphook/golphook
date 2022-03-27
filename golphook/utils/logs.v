module utils

#include "windows.h"

// hi

[typedef]
struct C.FILE {}

fn C.AllocConsole() bool
fn C.FreeConsole() bool

fn C.freopen_s(&&C.FILE, &char, &char, &C.FILE) u32
fn C.fclose(&C.FILE) u32

fn C.puts(&char)

[unsafe]
pub fn load_unload_console(switch bool, andFile &C.FILE) {

	if switch {
		C.Beep(670, 667)
		C.AllocConsole()
		C.freopen_s(&andFile, c"CONOUT$", c"w", C.stdout)
		C.Beep(670, 667)
	} else {
		//C.fclose(andFile)
		//C.FreeConsole()
	}

}

pub fn print(withContent string) {
	C.puts(&char(withContent.str))
}
