setlocal
@echo off
color E0
SET EXTFH=C:\WORK\EXTFH.CFG
echo Formatting casdumpa
if exist casdumpa.rec casdup /icasdumpa.rec /fcasdumpa.txt /w /d
echo Splitting casdumpa
if exist casdumpa.txt ESDumpSplitter casdumpa.txt
echo Formatting casdumpb
if exist casdumpb.rec casdup /icasdumpb.rec /fcasdumpb.txt /w /d
echo Splitting casdumpb
if exist casdumpb.txt ESDumpSplitter casdumpb.txt
echo Formatting casdumpx
if exist casdumpx.rec casdup /icasdumpx.rec /fcasdumpx.txt /w /d
echo Splitting casdumpb
if exist casdumpx.txt ESDumpSplitter casdumpx.txt
echo Formatting casauxta
if exist casauxta.rec casdup /icasauxta.rec /fcasauxta.txt /w /d
echo Formatting casauxtb
if exist casauxtb.rec casdup /icasauxtb.rec /fcasauxtb.txt /w /d
color
endlocal
