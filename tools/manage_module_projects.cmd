@setlocal EnableExtensions EnableDelayedExpansion
@echo off

set current-path=%~dp0

rem // remove trailing slash
set current-path=%current-path:~0,-1%

set build-root=%current-path%\..
rem // resolve to fully qualified path
for %%i in ("%build-root%") do set build-root=%%~fi

set cmake_root=%build-root%\build

set samples_path=%build-root%\samples
set samples_modules_path=%samples_path%\dotnet_core_module_sample\modules
set managed_gateway_csproj_path=..\samples\dotnet_core_managed_gateway\dotnet_core_managed_Gateway.csproj
set core_gateway_csproj_path=..\bindings\dotnetcore\dotnet-core-binding\Microsoft.Azure.Devices.Gateway\Microsoft.Azure.Devices.Gateway.csproj
set gateway_sln_path=..\bindings\dotnetcore\dotnet-core-binding\dotnet-core-binding.sln
set target_path=%build-root%\build\samples\dotnet_core_module_sample\Debug

if "%1" equ "" goto usage
set buildAndRun=false
if "%1" equ "--buildRun" (
    set buildAndRun=true
    goto buildRun
)
if "%1" equ "--build" (
    set buildAndRun=false
    goto buildRun
)

if "%1" equ "--switch" goto switch

set command=%1

shift
if "%1" equ "" goto usage
set module_name=%1
set module_directory_name=%module_name%Module
set module_directory_path=%samples_modules_path%\%module_directory_name%
set module_csproj_path=%module_directory_path%\%module_directory_name%.csproj

if "%command%" equ "--new" goto new
if "%command%" equ "--delete" goto delete

:usage
echo manage_module_projects.cmd [options]
echo options:
echo  --build            Build the modules and copy to the gateway project
echo  --buildRun         Build and run gateway with all modules
echo  --new ^<value^>      Create new module with name value (e.g. Printer or Sensor)
echo  --delete ^<value^>   Delete existing module with name value (e.g. Printer or Sensor)
echo  --switch ^<value^>   Switch .net version between two supported values: 1 (for .net 1.1.1) and 2 (for .net 2.0 RC)
goto :eof

:switch
shift
set version=0
if "%1" equ "1" (
    set version=1
    del /Q %build-root%\tools\switch2
)
if "%1" equ "2" (
    set version=2
    echo Flag to use .net 2.0 > %build-root%\tools\switch2
)
if "%version%" equ "0" (
    echo version MUST be 1 or 2
    goto :usage
)

Powershell.exe -executionpolicy remotesigned -File %build-root%\tools\change_dotnet_core_version.ps1 -dotnet_version %version% -root_path %build-root%
set buildAndRun=false
rmdir /s/q %cmake_root%

:buildRun
if NOT EXIST %build-root%\tools\switch2 (
    set netstandard=netstandard1.3
    set dot_net_version=1.1.1
) else (
    set netstandard=netstandard2.0
    set dot_net_version=2.0.0-preview1-002111-00
)

if NOT EXIST %cmake_root% (
    %build-root%\tools\build.cmd --platform x64 --enable-dotnet-core-binding
) else (
    for /f "tokens=*" %%G in ('dir /b %samples_modules_path%') do (
        set local_module_path=%samples_modules_path%\%%G
        REM We are cd'ing in because the project could be csproj or fsproj
        pushd !local_module_path!
        dotnet build
        popd
        set base_source_path=!local_module_path!\bin\Debug\%netstandard%\%%G
        set source_dll=!base_source_path!.dll
        set source_pdb=!base_source_path!.pdb
        copy !source_dll! %target_path%
        copy !source_pdb! %target_path%
    )
)

if %buildAndRun% equ false goto :eof
set config_path=%samples_path%\dotnet_core_managed_gateway\dotnet_core_managed_gateway_win.json
%target_path%\dotnet_core_module_sample.exe %config_path%
goto :eof

:new
if EXIST %module_directory_path% (
    echo %module_directory_path% already exists. Please remove before trying command.
    goto :eof
)

set framework=
if NOT EXIST %build-root%\tools\switch2 (
    set framework=-f netstandard1.3
)

dotnet new classlib -o %module_directory_path% %framework%
del %module_directory_path%\Class1.cs
set module_cs_path=%module_directory_path%\DotNet%module_name%Module.cs
copy %samples_modules_path%\HelloWorldModule\DotNetHelloWorldModule.cs %module_cs_path%

powershell -Command "(Get-Content %module_cs_path%) | ForEach-Object { $_ -replace 'HelloWorld','%module_name%'} | Set-Content %module_cs_path%"

dotnet add %module_csproj_path% reference %core_gateway_csproj_path%

dotnet add %managed_gateway_csproj_path% reference %module_csproj_path%

dotnet sln %gateway_sln_path% add %module_csproj_path%

dotnet restore %module_csproj_path%

goto :eof

:delete
if NOT EXIST %module_directory_path% (
    echo The directory %module_directory_path% doesn't exist.
    goto :eof
)

dotnet remove %module_csproj_path% reference %core_gateway_csproj_path%

dotnet remove %managed_gateway_csproj_path% reference %module_csproj_path%

dotnet sln %gateway_sln_path% remove %module_csproj_path%

rmdir /s /q %module_directory_path%
goto :eof