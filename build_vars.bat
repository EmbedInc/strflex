@echo off
rem
rem   Define the variables for running builds from this source library.
rem
set srcdir=strflex
set buildname=
call treename_var "(cog)source/strflex" sourcedir
set libname=strflex
set fwname=
call treename_var "(cog)src/%srcdir%/debug_%fwname%.bat" tnam
make_debug "%tnam%"
call "%tnam%"
