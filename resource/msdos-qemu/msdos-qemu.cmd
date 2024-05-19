@echo off
setlocal
set VERSION=20240519
echo MS-DOS 4.01 instant QEMU VM script version %VERSION%

:JINIT
set global=false
for /f "tokens=3 delims=\ " %%i in ('whoami /groups ^| find "Mandatory"') do set USER_LEVEL=%%i
if "%USER_LEVEL%"=="High" set global=true

set scoopdir=%USERPROFILE%\scoop
set globaldir=%ProgramData%\scoop
if %global%==true (
  if "%SCOOP%"=="" set SCOOP=%globaldir%
) else (
  if "%SCOOP%"=="" set SCOOP=%scoopdir%
)
if not "%DEBUG%"=="" echo Scoop directory: %SCOOP%

if not exist "%SCOOP%" echo WARN: Missing Scoop directory %SCOOP%
set SCOOP_APP_DIR=%SCOOP%\apps
set SCOOP_PERSIST_DIR=%SCOOP%\persist

rem https://github.com/ScoopInstaller/Scoop/wiki/Pre-Post-(un)install-scripts

set app=machine-dos
for %%i in (%CD%) do set app=%%~nxi
if not "%DEBUG%"=="" echo Name of application: %app%

set architecture=64bit
if "%PROCESSOR_ARCHITECTURE%"=="x86" set architecture=32bit
if not "%DEBUG%"=="" echo CPU architecture: %architecture%

rem cfg

if not "%DEBUG%"=="" echo Global: %global%

rem manifest

rem version

set dir=%SCOOP_APP_DIR%\%app%\current
if not "%DEBUG%"=="" echo dir: %dir%

set persist_dir=%SCOOP_PERSIST_DIR%\%app%
if not "%DEBUG%"=="" echo persist_dir: %persist_dir%

set bucketsdir=%SCOOP%\buckets
if not "%DEBUG%"=="" echo bucketsdir: %bucketsdir%

set cachedir=%SCOOP%\cache
if not "%DEBUG%"=="" echo cachedir: %cachedir%

set cfgpath=%USERPROFILE%\.scoop
if not "%DEBUG%"=="" echo cfgpath: %cfgpath%

if not "%DEBUG%"=="" echo globaldir: %globaldir%

set modulesdir=%SCOOP%\modules
if not "%DEBUG%"=="" echo modulesdir: %modulesdir%

set oldscoopdir=%USERPROFILE%\AppData\Local\scoop
if not "%DEBUG%"=="" echo oldscoopdir: %oldscoopdir%

:JBEGIN

:JSTEP01
echo.
echo Checking persist directory ...
if not exist "%persist_dir%" (
  echo WARN: Missing Scoop persist directory %persist_dir%
  mkdir "%persist_dir%"
)

:JSTEP02
echo.
echo Checking HDD image ...
set hdd=%persist_dir%\%app%_hdd.img
rem Least 200MB for FreeDOS full installation.
set hdd_size=512M
if not exist "%hdd%" (
  @echo on
  qemu-img create %hdd% %hdd_size%
  @echo off
)
if not exist "%hdd%" (
  echo ERROR: Cannot create HDD image at %hdd%
  goto :JABEND
)

:JSTEP03
echo.
echo Checking FreeDOS image ...
set msdos=%SCOOP_APP_DIR%\msdos-dos\current
set msdos_fda=%msdos%\v4.0-ozzie\bin\DRDOS1_IMD.img
set msdos_fdb=%msdos%\v4.0-ozzie\bin\DRDOS2_IMD.img
set msdos_cd=%SCOOP_PERSIST_DIR%\machine-dos\msdos-iso\msdos.iso

if not exist "%msdos%" (
  echo ERROR: Missing msdos-dos manifest directory at %msdos%
  goto :JABEND
)
if not exist "%msdos_fda%" echo WARN: Missing DR-DOS Disk 1 image %msdos_fda%
if not exist "%msdos_fdb%" echo WARN: Missing DR-DOS Disk 2 image %msdos_fdb%
if not exist "%msdos_cd%" echo WARN: Missing MS-DOS Git repository ISO image %msdos_cd%

:JSTEP11
echo.
echo Run %architecture% QEMU ...

set qemu=qemu-system-x86_64
if "%architecture%"=="32bit" set qemu=qemu-system-i386

if "%qemu_mem%"=="" set qemu_mem=16M
if "%qemu_nic%"=="" set qemu_nic=-net nic,model=ne2k_isa -net user
if "%qemu_audio%"=="" set qemu_audio=-device adlib -device sb16
if "%qemu_opts%"=="" set qemu_opts=-boot order=a -fda "%msdos_fda%" -fdb "%msdos_fdb%" -cdrom "%msdos_cd%"

@echo on
%qemu% -machine isapc -m %qemu_mem% -rtc base=localtime -drive format=raw,cache=writeback,file="%hdd%" %qemu_nic% %qemu_audio% %qemu_opts%
@echo off
if ERRORLEVEL 1 goto :JABEND

:JEND
echo.
echo Job end normal.
endlocal
goto :EOF

:JABEND
echo.
echo Job ends abnormal(%ERRORLEVEL%).
endlocal

