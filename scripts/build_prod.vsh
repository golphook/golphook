cc := '-m32 -w /we4013 /volatile:ms /Fo"C:\\Users\\fleur\\AppData\\Local\\Temp\\v_0\\golphook.dll.2955990008440974231.tmp.so.c.obj" /F 16777216 /MD /DNDEBUG /LD "C:\\Users\\fleur\\AppData\\Local\\Temp\\golphook\\build\\golphook-debug_p.c" -I "C:\\Program Files (x86)\\Windows Kits\\10\\Include\\10.0.19041.0\\ucrt" -I "C:\\Program Files (x86)\\Microsoft Visual Studio\\2019\\Community\\VC\\Tools\\MSVC\\14.29.30133\\include" -I "C:\\Program Files (x86)\\Windows Kits\\10\\Include\\10.0.19041.0\\um" -I "C:\\Program Files (x86)\\Windows Kits\\10\\Include\\10.0.19041.0\\shared" -I "C:\\v\\thirdparty\\cJSON" -I "C:\\v\\thirdparty\\stdatomic\\win" -I "C:\\Users\\fleur\\AppData\\Local\\Temp\\golphook\\exts\\directx" -I "C:\\Users\\fleur\\AppData\\Local\\Temp\\golphook\\golphook\\c" -I "C:\\Users\\fleur\\AppData\\Local\\Temp\\golphook\\exts\\bass" -I "C:\\Users\\fleur\\AppData\\Local\\Temp\\golphook\\exts\\subhook" -I "C:\\Users\\fleur\\AppData\\Local\\Temp\\golphook\\exts\\minhook" "C:\\v/thirdparty/cJSON/cJSON.obj" kernel32.lib user32.lib advapi32.lib dbghelp.lib advapi32.lib d3d9.lib d3dx9.lib minhook.lib /link /NOLOGO /OUT:"C:\\Users\\fleur\\AppData\\Local\\Temp\\golphook\\build\\golphook.dll" /LIBPATH:"C:\\Program Files (x86)\\Windows Kits\\10\\Lib\\10.0.19041.0\\ucrt\\X86" /LIBPATH:"C:\\Program Files (x86)\\Windows Kits\\10\\Lib\\10.0.19041.0\\um\\X86" /LIBPATH:"C:\\Program Files (x86)\\Microsoft Visual Studio\\2019\\Community\\VC\\Tools\\MSVC\\14.29.30133\\lib\\X86" /DEBUG:FULL /INCREMENTAL:NO /OPT:REF /OPT:ICF /LIBPATH:"C:\\Users\\fleur\\AppData\\Local\\Temp\\golphook\\exts\\directx" /LIBPATH:"C:\\Users\\fleur\\AppData\\Local\\Temp\\golphook\\exts\\directx\\msvc" /LIBPATH:"C:\\Users\\fleur\\AppData\\Local\\Temp\\golphook\\exts\\bass" /LIBPATH:"C:\\Users\\fleur\\AppData\\Local\\Temp\\golphook\\exts\\bass\\msvc" /LIBPATH:"C:\\Users\\fleur\\AppData\\Local\\Temp\\golphook\\exts\\minhook" /LIBPATH:"C:\\Users\\fleur\\AppData\\Local\\Temp\\golphook\\exts\\minhook\\msvc"'

execute("nmake debug-cp")
execute("cl $cc")
