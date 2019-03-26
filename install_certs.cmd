@echo off

ECHO ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
ECHO :: This script is used to install server public certificate.            ::
ECHO :: It will automatically detect the Java installation folder.           ::
ECHO :: Make sure that Java is available in execution path.                  ::
ECHO :: Otherwise it will ask to provide keytool.exe path.                   ::
ECHO :: Certificate alise will be set same as certificate file name.         ::
ECHO :: If certificate is already installed then the certificate will be     ::
ECHO :: reinstalled. In that case previously installed certificate will be   ::
ECHO :: replaced with the new provided certificate.                          ::
ECHO ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
ECHO All installed certificated will be moved to installed directory
ECHO ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SETLOCAL EnableDelayedExpansion 

Rem dir C:\Users\725252\Desktop\certsAD /A:-D /S /B
Rem FOR /f "tokens=*" %%G IN ('dir %cert_path%\*.cer* /A:-D /S ^| find "/"') DO ()

::list only files in the specified directory
::for %%A in ("C:\Users\sarkasur\Desktop\cert\*.cer") do echo %%~fA


set store_pass="changeit"
if "%JAVA_HOME%"=="" (
	echo "JAVA_HOME not found"
	set /p store_path="Enter certificate store path:"
) else (
	echo -----------------------------------JAVA_HOME found----------------------------------
	set store_path="%JAVA_HOME%\jre\lib\security\cacerts"
	set keytool="%JAVA_HOME%\bin\keytool"
)
echo Use default certificate store for installation?????????
CHOICE /C YNC /M "Press Y for Yes, N for No or C for Cancel."
if errorlevel 3 goto :End
if '%ERRORLEVEL%'=='2' (
	set /p store_path="Enter certificate store path:"
)
set /p store_pass="Enter store password[Press enter for default password] :"
set /p cert_path="Enter certificate path[Default current directory] :"

IF '%cert_path%'=='' (
	set cert_path=%~dp0
)

::Remove trailing / if available
if "%cert_path:~-1%"=="\" (
	echo Found /
	set cert_path=%cert_path:~0,-1%
)

echo Using following store configuration:--------------------------
echo Store path: %store_path%
echo Store password: %store_pass%
echo Cert path: %cert_path%

::Move certificates here on successful installation
set installed_path="%cert_path%\installed"
::Move certificates here on installation error
set error_path="%cert_path%\error"
mkdir %installed_path% > nul
mkdir %error_path% > nul

if %keytool%=="" (
	set /p keytool="Enter keytool executable path :"
)

echo Using %keytool% for certificate installation

dir /b /s %cert_path%\*.cer* > list
FOR /f "tokens=*" %%G IN (list) DO (
	echo -----------------------------Installing certificate %%~nG ----------------------------------
	Rem %keytool% -import -trustcacerts -keystore %store_path% -storepass %store_pass% -noprompt -alias %%~nG -file "%%G"
	call :InstallCertificate %%~nG "%%G"
	if ERRORLEVEL 1 (
		call :ECHORED "Cretificate already installed......."
		call :ECHOGREEN "Removing certificate from keystore............"
		%keytool% -delete -noprompt -alias  %%~nG  -keystore %store_path% -storepass %store_pass%
		if ERRORLEVEL 1 (
			call :MoveCertificate "%%G" error
		) else (
			call :ECHOGREEN "Reinstalling certificate................"
			call :InstallCertificate %%~nG "%%G"
			if ERRORLEVEL 1 (
				call :MoveCertificate "%%G" error
			) else (
				call :MoveCertificate "%%G"
			)
		)
	) else ( 
		call :MoveCertificate "%%G"
	)
	echo ---------------------------------------------------------------------------------------------
)

goto :End

:InstallCertificate
echo Alias: %1
echo Path : %2
%keytool% -import -trustcacerts -keystore %store_path% -storepass %store_pass% -noprompt -alias "%1" -file "%2"
goto :EOF

:MoveCertificate
set argCount=0
for %%x in (%*) do (
   set /A argCount+=1
)
if %argCount% LSS 2 (
	move /y "%1" "%installed_path%" > nul
	call :ECHOGREEN "Certificate installed successfully..........."
) else (
	move /y "%1" "%error_path%" > nul
	call :ECHORED "Certificate install error............."
)
goto :EOF

:Error
call :ECHORED "Certificate install error............."
goto :End

:ECHORED
%Windir%\System32\WindowsPowerShell\v1.0\Powershell.exe write-host -foregroundcolor Red %1
goto :EOF

:ECHOGREEN
%Windir%\System32\WindowsPowerShell\v1.0\Powershell.exe write-host -foregroundcolor Green %1
goto :EOF

:End
ENDLOCAL
IF EXIST list DEL /F list
EXIT /B %ERRORLEVEL%