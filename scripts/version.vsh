import os
import v.vmod

v_mod := vmod.decode(@VMOD_FILE) ?
os.write_file("version_", v_mod.version) ?
