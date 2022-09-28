import os

// this file is necessary to build a 'production' version
// you can't inject with any of /Ox optimizations

mut ls := os.ls(".") or { panic("$err") }
if "build" !in ls {
	os.mkdir("build") or { panic("$err") }
}

//og_prod_res := os.execute("nmake ci-build-prod")
og_prod_res := execute("${@VEXE} -cc cl -m32 -prod -autofree -shared -showcc -keepc -gc none . -o build\\golphook.dll")
og_cmd := og_prod_res.output.split_into_lines().filter(it.contains("/O2"))[0]
fixed_cmd := og_cmd.replace("/O2", "")


execute("cl $fixed_cmd")

ls = os.ls(".") or { panic("$err") }

for fl in ls {
	fl_n := if fl.split(".").len == 2 {
		fl.split(".")[1]
	} else {
		""
	}
	if fl_n in ["ilk", "pdb"] {
		os.rm("./$fl") or { panic("$err") }
	}
}
