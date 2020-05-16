@echo off
rem
rem   BUILD_LIB
rem
rem   Build the STRFLEX library.
rem
setlocal
call build_pasinit

call src_insall %srcdir% %libname%

call src_pas %srcdir% %libname%_append
call src_pas %srcdir% %libname%_block
call src_pas %srcdir% %libname%_char
call src_pas %srcdir% %libname%_clear
call src_pas %srcdir% %libname%_copy
call src_pas %srcdir% %libname%_del
call src_pas %srcdir% %libname%_ins
call src_pas %srcdir% %libname%_len
call src_pas %srcdir% %libname%_pos
call src_pas %srcdir% %libname%_show
call src_pas %srcdir% %libname%_str
call src_pas %srcdir% %libname%_strmem

call src_lib %srcdir% %libname%
call src_msg %srcdir% %libname%
