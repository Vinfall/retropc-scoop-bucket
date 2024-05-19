@echo off
setlocal
set VERSION=20240519
echo FreeDOS 1.3 instant QEMU VM script version %VERSION%

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
set hdd=%persist_dir%\freedos_hdd.img
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
set freedos=%SCOOP_APP_DIR%\freedos-dos\current
set freedos_fd=%freedos%\FD13BOOT.img
set freedos_cd=%freedos%\FD13LIVE.iso
set freedos_bonus_cd=%freedos%\FD13BNS.iso

if not exist "%freedos%" (
  echo ERROR: Missing freedos-dos manifest directory at %freedos%
  goto :JABEND
)
if not exist "%freedos_fd%" echo WARN: Missing FreeDOS boot image %freedos_fd%
if not exist "%freedos_cd%" echo WARN: Missing FreeDOS CD image %freedos_cd%

:JSTEP11
echo.
echo Run %architecture% QEMU ...

set qemu=qemu-system-x86_64w
if "%architecture%"=="32bit" set qemu=qemu-system-i386w

if "%qemu_mem%"=="" set qemu_mem=16M
if "%qemu_nic%"=="" set qemu_nic=-net nic,model=ne2k_pci -net user
if "%qemu_audio%"=="" set qemu_audio=-device adlib -device sb16
if "%qemu_opts%"=="" set qemu_opts=-boot order=ac -fda "%freedos_fd%" -cdrom "%freedos_cd%"

@echo on
%qemu% -m %qemu_mem% -rtc base=localtime -drive format=raw,cache=writeback,file="%hdd%" %qemu_nic% %qemu_audio% %qemu_opts%
@echo off
if ERRORLEVEL 1 goto :JABEND

echo.
echo INFO: if FreeDOS is installed, you will execute "set qemu_opts=-boot order=c" and restart the vm for booting from HDD.

:JEND
echo.
echo Job end normal.
endlocal
goto :EOF

:JABEND
echo.
echo Job ends abnormal(%ERRORLEVEL%).
endlocal
