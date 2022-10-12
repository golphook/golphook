import os
import v.vmod

mut ref := os.args[1] or { "nightly" }
if ref == "main" {
	ref = "prod"
}
m := vmod.from_file("v.mod") ?
vmod_raw := os.read_file("v.mod") ?
f_v := vmod_raw.replace(m.version, "${m.version}-${ref}")
os.write_file("v.mod", f_v) ?
