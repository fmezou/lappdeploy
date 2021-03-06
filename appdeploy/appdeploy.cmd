@echo off
rem appdeploy
rem This script launches the installer package of the standard application. See 
rem Usage description syntax for details about used syntax. 
rem
rem Usage: appdeploy [set]
rem     set is the set name, the script use a file named applist-[set].txt which
rem     describing applications to install. 'all' is the default value.
rem 
rem Exit code
rem     0: no error
rem     1: an error occurred while filtering application
rem     2: invalid argument. An argument of the command line is not valid (see Usage)
rem 
setlocal
pushd "%~dp0"

rem Setting the environment
rem Execute initialization hook ***
if exist .\__init__.cmd call .\__init__.cmd

rem Theses settings may be overwritten in the current execution environment.
rem By default, data files including installer packages were stored in the appstore directory.
if not defined APP_STORE_DIR set APP_STORE_DIR=..\appstore

rem By default, no mail with the content of the below log files is sent to a sysadmin
rem (see _log2mail script). To prevent this behavior, you must set the LOGMAIL environment variable to 1.
if not defined LOGMAIL set LOGMAIL=0
if not defined SMTP_SERVER_PORT set SMTP_SERVER_PORT=25

rem By default, the message log are only write in the log file. To have a copy on the standard 
rem output, you must set the SILENT environment variable to 0. 
rem By default, only the Error, Warning or Informational entry are logged. You can tuned this behavior
rem by setting the LOGLEVEL environment variable.
rem     LOGLEVEL=ERROR: only the Error entry are logged  
rem     LOGLEVEL=WARNING: only the Error or Warning entry are logged
rem     LOGLEVEL=INFO: only the Error, Warning or Informational entry are logged
rem     LOGLEVEL=DEBUG: all the entry are logged
if not defined UPDATE_LOGFILE  set UPDATE_LOGFILE=%TEMP%\appdeploy_today.log
if not defined WARNING_LOGFILE set WARNING_LOGFILE=%TEMP%\appdeploy_warn_today.log
if not defined SUMMARY_LOGFILE set SUMMARY_LOGFILE=%TEMP%\appdeploy_summary_today.log
if not defined ARCHIVE_LOGFILE set ARCHIVE_LOGFILE=%SystemRoot%\appdeploy.log
if not defined SILENT          set SILENT=1
if not defined LOGLEVEL        set LOGLEVEL=INFO
Rem in case of error, the info level is selected
set LOGERROR=1
set LOGWARNING=1
set LOGINFO=1
set LOGDEBUG=
if %LOGLEVEL%==ERROR (
    set LOGERROR=1
    set LOGWARNING=
    set LOGINFO=
    set LOGDEBUG=
)
if %LOGLEVEL%==WARNING (
    set LOGERROR=1
    set LOGWARNING=1
    set LOGINFO=
    set LOGDEBUG=
)
if %LOGLEVEL%==DEBUG (
    set LOGERROR=1
    set LOGWARNING=1
    set LOGINFO=1
    set LOGDEBUG=1
)
rem Each release of lAppUpdate is identified by a version number that complies 
rem with the Semantic Versioning 2.0.0 standard (see http://semver.org/).
set APPDEPLOY_VERSION=0.3.1

goto Main  

rem **** This section contains the subroutine used by the script by a recurse call (see call)
rem ****
rem WriteErrorLog
rem     Write a error entry in log file or on console output (based on the syslog format) 
rem     Usage call :WriteErrorLog string...
rem         string: is the string explaining the log entry 
:WriteErrorLog
if not defined LOGERROR goto :EOF
echo %DATE% %TIME%; %COMPUTERNAME%; %~nx0 [ERROR]; %* >>"%UPDATE_LOGFILE%"
if %SILENT%==0 echo %DATE% %TIME%; %COMPUTERNAME%; %~nx0 [ERROR]; %*
echo %DATE% %TIME%; %COMPUTERNAME%; %~nx0 [ERROR]; %* >>"%WARNING_LOGFILE%"
goto :EOF

rem WriteWarningLog
rem     Write a warning entry in log file or on console output (based on the syslog format) 
rem     Usage call :WriteWarningLog string...
rem         string: is the string explaining the log entry 
:WriteWarningLog
if not defined LOGWARNING goto :EOF
echo %DATE% %TIME%; %COMPUTERNAME%; %~nx0 [WARNING]; %* >>"%UPDATE_LOGFILE%"
if %SILENT%==0 echo %DATE% %TIME%; %COMPUTERNAME%; %~nx0 [WARNING]; %*
echo %DATE% %TIME%; %COMPUTERNAME%; %~nx0 [WARNING]; %* >>"%WARNING_LOGFILE%"
goto :EOF

rem WriteInfoLog
rem     Write an informational entry in log file or on console output (based on the syslog format) 
rem     Usage call :WriteInfoLog string...
rem         string: is the string explaining the log entry 
:WriteInfoLog
if not defined LOGINFO goto :EOF
echo %DATE% %TIME%; %COMPUTERNAME%; %~nx0 [INFO]; %* >>"%UPDATE_LOGFILE%"
if %SILENT%==0 echo %DATE% %TIME%; %COMPUTERNAME%; %~nx0 [INFO]; %*
goto :EOF

rem WriteDebugLog
rem     Write a debugging entry in log file or on console output (based on the syslog format) 
rem     Usage call :WriteDebugLog string...
rem         string: is the string explaining the log entry 
:WriteDebugLog
if not defined LOGDEBUG goto :EOF
echo %DATE% %TIME%; %COMPUTERNAME%; %~nx0 [DEBUG]; %* >>"%UPDATE_LOGFILE%"
if %SILENT%==0 echo %DATE% %TIME%; %COMPUTERNAME%; %~nx0 [DEBUG]; %*
goto :EOF

rem WriteSummary
rem     Write a summary entry in summary log file or on console output
rem     Usage call :WriteSummary string...
rem         string: is the string explaining the log entry 
:WriteSummary
echo %* >>"%SUMMARY_LOGFILE%"
goto :EOF

rem ArchiveAndCleanUp
rem     Copy the today log file in the archive log file
rem     Usage call :ArchiveAndCleanUp
:ArchiveAndCleanUp
if exist "%ARCHIVE_LOGFILE%" echo -------------------------------------------------------------------------------->>"%ARCHIVE_LOGFILE%"
type "%UPDATE_LOGFILE%" >>"%ARCHIVE_LOGFILE%" 2>&1
if exist "%UPDATE_LOGFILE%" del "%UPDATE_LOGFILE%"
if exist "%WARNING_LOGFILE%" del "%WARNING_LOGFILE%"
if exist "%SUMMARY_LOGFILE%" del "%SUMMARY_LOGFILE%"
rem Execute completion hook ***
if exist .\__exit__.cmd call .\__exit__.cmd
goto :EOF

rem InstallExe
rem     Execute the installation package and the postinstall script if it exist.
rem     Usage call :InstallExe package option
rem         package: is the full name of the installation package
rem         option: is the command line options of the installation package (specific to the package).
rem                 If several options are present, the option argument must be enclosed with double quote (")
:InstallExe
set APP_ROOT=%~dp1
set APP_PKG=%~nx1
set APP_PKG_OPTIONS=%~2
call :WriteInfoLog Executing "%APP_PKG%" ("%APP_ROOT%%APP_PKG%" %APP_PKG_OPTIONS%)
call "%APP_ROOT%%APP_PKG%" %APP_PKG_OPTIONS%>>"%UPDATE_LOGFILE%" 2>&1
if errorlevel 1 (
    call :WriteWarningLog Installation of "%APP_PKG%" failed ^(Errorlevel: %errorlevel%^)
) else (
    call :WriteInfoLog Installation of "%APP_PKG%" succeded
)
if not exist "%APP_ROOT%__postinstall__.cmd" goto :EOF
call "%APP_ROOT%__postinstall__.cmd">>"%UPDATE_LOGFILE%" 2>&1
if errorlevel 1 (
    call :WriteWarningLog Post Installation of "%APP_PKG%" failed ^(Errorlevel: %errorlevel%^)
) else (
    call :WriteInfoLog Post Installation of "%APP_PKG%" succeded
)
goto :EOF

rem InstallMSI
rem     Execute the MSI package with the optional transform file and the postinstall script if it exist.
rem     Usage call :InstallMSI package option
rem         package: is the full name of the installation package
rem         option: is the command line options of the installation package (specific to the package).
rem                 If several options are present, the option argument must be enclosed with double quote (")
:InstallMSI
set APP_ROOT=%~dp1
set APP_PKG=%~nx1
set APP_PKG_TRANSF=%~n1.mst
set APP_PKG_LOG=%~n1.log
set APP_PKG_OPTIONS=%~2
if exist "%~dpn1.mst" (
  call :WriteInfoLog Installing "%APP_PKG%" ^("%APP_ROOT%%APP_PKG%" %APP_PKG_OPTIONS%^) using "%APP_PKG_TRANSF%"
  @%SystemRoot%\System32\msiexec.exe /package "%APP_ROOT%%APP_PKG%" ALLUSER=2 %APP_PKG_OPTIONS% TRANSFORMS="%APP_ROOT%%APP_PKG_TRANSF%" /quiet /norestart /log "%TEMP%\%APP_PKG_LOG%"
  if errorlevel 1 (
    call :WriteWarningLog Installation of "%APP_PKG%" failed ^(Errorlevel: %errorlevel%^)
  ) else (
    call :WriteInfoLog Installation of "%APP_PKG%" succeded
  )
) else (
  call :WriteInfoLog Installing "%APP_PKG%" ^(%APP_ROOT%%APP_PKG% %APP_PKG_OPTIONS%^)
  @%SystemRoot%\System32\msiexec.exe /package "%APP_ROOT%%APP_PKG%" ALLUSER=2 %APP_PKG_OPTIONS% /quiet /norestart /log "%TEMP%\%APP_PKG_LOG%"
  if errorlevel 1 (
    call :WriteWarningLog Installation of "%APP_PKG%" failed ^(Errorlevel: %errorlevel%^)
  ) else (
    call :WriteInfoLog Installation of "%APP_PKG%" succeded
  )
)
if not exist "%APP_ROOT%__postinstall__.cmd" goto :EOF
call "%APP_ROOT%__postinstall__.cmd">>"%UPDATE_LOGFILE%" 2>&1
if errorlevel 1 (
    call :WriteWarningLog Post Installation of "%APP_PKG%" failed ^(Errorlevel: %errorlevel%^)
) else (
    call :WriteInfoLog Post Installation of "%APP_PKG%" succeded
)
goto :EOF

rem RebootLog
rem     Reboot log files.
rem         If log files exist, it implies that the previous session crashed. So to find the root cause
rem         Log files are kept and a banner is simply added. As the ephemeral log files (UPDATE_LOGFILE,
rem         WARNING_LOGFILE and SUMMARY_LOGFILE) stand together, the detection is based only on UPDATE_LOGFILE. 
rem     Usage call :RebootLog
:RebootLog
if not exist "%UPDATE_LOGFILE%" goto :EOF
call :WriteWarningLog Previous execution of the script failed - Restart
call :WriteSummary #####################################################
call :WriteSummary # Previous execution of the script failed - Restart #
call :WriteSummary #####################################################
goto :EOF

:Main
rem *** Startup ***
call :RebootLog
call :WriteInfoLog Starting AppDeploy (%APPDEPLOY_VERSION%)
call :WriteSummary Starting AppDeploy (%APPDEPLOY_VERSION%)
call :WriteDebugLog Used path '%CD%' on %COMPUTERNAME% (user: %USERNAME%)
call :WriteDebugLog Command line  '%CMDCMDLINE%'

rem *** Setting the environment ***
set CSCRIPT_PATH=%SystemRoot%\System32\cscript.exe
if not exist %CSCRIPT_PATH% goto NoCScript
set REG_PATH=%SystemRoot%\System32\reg.exe
if not exist %REG_PATH% goto NoReg
if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
  set OS_ARCH=x64
) else (
  if /i "%PROCESSOR_ARCHITEW6432%"=="AMD64" (
    set OS_ARCH=x64
  ) else (
    set OS_ARCH=x86
  )
)

rem *** parsing the command line ***
set SETNAME=%1

call :WriteInfoLog Building the application list...
set APPLIST_PREFIX=applist-
set APPLIST=%TEMP%\applist.txt
if exist "%APPLIST%" del "%APPLIST%"
copy /Y "%APP_STORE_DIR%\%APPLIST_PREFIX%all.txt" "%APPLIST%" >nul
if "%SETNAME%"=="" goto :SkipSet
if exist "%APP_STORE_DIR%\%APPLIST_PREFIX%%SETNAME%.txt" (
    echo.>> "%APPLIST%"
    type "%APP_STORE_DIR%\%APPLIST_PREFIX%%SETNAME%.txt" >> "%APPLIST%"
    call :WriteInfoLog Set %SETNAME% selected
    call :WriteSummary Set %SETNAME% selected
) else (
    call :WriteWarningLog Set named %SETNAME% do not exist
)
:SkipSet
set APPLIST_TO_INSTALL=%TEMP%\apptoinstall.txt
call :WriteInfoLog Checking installed applications
if exist "%APPLIST_TO_INSTALL%" del "%APPLIST_TO_INSTALL%"
%CSCRIPT_PATH% //Nologo //Job:appfilter _appfilter.wsf %OS_ARCH%
if errorlevel 1 goto CustSoftFail

if not exist "%APPLIST_TO_INSTALL%" goto NoApp
call :WriteInfoLog Install the missing application or upgrade it
for /F "delims=; tokens=1,2,3*" %%i in (%APPLIST_TO_INSTALL%) do (
    call :WriteSummary Installing %%i ^(%%j^)
    call :WriteInfoLog Installing %%i ^(%%j^)
    if /i "%%~xk"==".msi" (
        call :InstallMSI "%%~k" "%%l"
    ) else (
        call :InstallEXE "%%~k" "%%l"
    )
)
del "%APPLIST_TO_INSTALL%"
del "%APPLIST%"
set APPINSTALLED=1
call :WriteInfoLog Applications installation completed
goto Cleanup

rem this section contain the exception and error treatment
:NoApp
set APPINSTALLED=
call :WriteInfoLog no application to install
goto cleanup

:CustSoftFail
call :WriteErrorLog Applications installation failed
rem archive the current log and send a mail to sysadmin
if %LOGMAIL%==1 %CSCRIPT_PATH% //Nologo //E:vbs _log2mail.vbs
call :ArchiveAndCleanUp
endlocal                                                       
exit /b 1

:NoCScript
call :WriteErrorLog VBScript interpreter %CSCRIPT_PATH% not found
rem archive the current log and send a mail to sysadmin
call :ArchiveAndCleanUp
endlocal                                                       
exit /b 1

:NoReg
call :WriteErrorLog Registry tool %REG_PATH% not found
rem archive the current log and send a mail to sysadmin
if %LOGMAIL%==1 %CSCRIPT_PATH% //Nologo //E:vbs _log2mail.vbs
call :ArchiveAndCleanUp
endlocal                                                       
exit /b 1

:Usage
call :WriteErrorLog  Usage: %0 [set].
call :WriteErrorLog  set is the set name, the script use a file named applist-[set].txt
call :WriteErrorLog  which describing applications to install. all is the default value.
rem archive the current log and send a mail to sysadmin
if %LOGMAIL%==1 %CSCRIPT_PATH% //Nologo //E:vbs _log2mail.vbs
call :ArchiveAndCleanUp
popd
endlocal
exit /b 2

:Cleanup 
rem archive the current log and send a mail to sysadmin
if defined APPINSTALLED (
    if %LOGMAIL%==1 %CSCRIPT_PATH% //Nologo //E:vbs _log2mail.vbs
)
call :ArchiveAndCleanUp
popd
endlocal
exit /b 0