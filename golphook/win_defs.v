module golphook

#flag -I @VMODROOT/exts/bass
#flag -I @VMODROOT/exts/minhook
#flag -I @VMODROOT/exts/vmp

#flag -L @VMODROOT/exts/bass
#flag -L @VMODROOT/exts/minhook

#flag -L @VMODROOT/exts/vmp

#flag -l minhook
$if prod {
	#flag -l vmp32
}

#include "windows.h"
#include "TlHelp32.h"

#include "minhook.h"
$if prod {
	#include "vmp.h"
}

[typedef]
pub struct C.FILE {}

fn C.MessageBoxA(int, &char, &char, int) int
fn C.FreeLibraryAndExitThread(voidptr, u32) bool
fn C.Beep(u32, u32) bool
fn C.GetModuleHandleA(&char) C.HMODULE
fn C.GetProcAddress(C.HMODULE, &char) voidptr
fn C.GetAsyncKeyState(int) u16
fn C.Sleep(u32)
fn C.FindWindowA(&char, &char) C.HWND

fn C.AllocConsole() bool
fn C.FreeConsole() bool

fn C.freopen_s(&&C.FILE, &char, &char, &C.FILE) u32
fn C.fclose(&C.FILE) u32

fn C.CreateToolhelp32Snapshot(int, int) C.HANDLE
fn C.Module32FirstW(C.HANDLE, voidptr) bool
fn C.Module32NextW(C.HANDLE, voidptr) bool

fn C.CallWindowProcW(voidptr, C.HWND, u32, u32, int) bool
fn C.SetWindowLongA(C.HWND, i32, i32) i32

fn C.GetWindowRect(C.HWND, &C.RECT) bool

fn C.GetCurrentProcessId() u32

fn C.DisableThreadLibraryCalls(C.HMODULE) bool

fn C.rand() int

fn C.MH_Initialize() int
fn C.MH_CreateHook(voidptr, voidptr, &voidptr) int
fn C.MH_EnableHook(voidptr) int
fn C.MH_DisableHook(voidptr) int
fn C.MH_Uninitialize() int

fn C.VMProtectBeginMutation(&u8)
fn C.VMProtectEnd()

