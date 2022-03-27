module golphook

#include "windows.h"

// hi

fn C.MessageBoxA(int, &char, &char, int) int
fn C.FreeLibraryAndExitThread(voidptr, u32) bool
fn C.Beep(u32, u32) bool
fn C.GetModuleHandleA(&char) C.HMODULE
fn C.GetProcAddress(C.HMODULE, &char) voidptr
