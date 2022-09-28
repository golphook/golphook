project_name = golphook

cc_options=-m32
cc=-cc cl $(cc_options)

temp_path=%temp%
temp_project_path=$(temp_path)\$(project_name)
bin_folder=$(temp_project_path)\build

move_to_temp=xcopy /e /y * $(temp_project_path) &&
move_back=&& del $(temp_project_path)\*.c.exp && del $(temp_project_path)\*.c.lib && xcopy /e /y $(temp_project_path)\* .

build-prod:
	$(move_to_temp) v $(cc) -prod -shared -showcc -autofree -skip-unused -o $(bin_folder)\$(project_name).dll $(temp_project_path) $(move_back)
build-debug:
	$(move_to_temp) v $(cc) -cflags /NODEFAULTLIB:library -g -showcc -keepc -shared -autofree -gc none -o $(bin_folder)\$(project_name)-debug.dll $(temp_project_path) $(move_back)
debug-c:
	$(move_to_temp) v $(cc) -g -shared -autofree -o $(bin_folder)\$(project_name)-debug.c $(temp_project_path)  $(move_back)
debug-cp:
	$(move_to_temp) v $(cc) -prod -autofree -shared -o $(bin_folder)\$(project_name)-debug_p.c $(temp_project_path)  $(move_back)
fmt:
	$(move_to_temp) v fmt -w . $(move_back)

ci-build-prod:
	v $(cc) -prod -autofree -shared -showcc -keep-c -o build\$(project_name).dll .
ci-build-cp:
	v $(cc) -prod -autofree -shared -keep-c -o build\$(project_name)-debug_p.c .
ci-build-debug:
	v $(cc) -g -shared -o build\$(project_name)-debug.dll .
