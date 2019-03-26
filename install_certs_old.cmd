@echo off

ECHO ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
ECHO :: This script is used to install server public certificate.            ::
ECHO :: It will automatically detect the Java installation folder.           ::
ECHO :: Make sure that Java is available in execution path.                  ::
ECHO :: Otherwise it will ask to provide keytool.exe path.                   ::
ECHO :: Certificate alise will be set same as certificate file name.         ::
ECHO :: If certificate is already installed then the certificate will be     ::
ECHO :: reinstalled. In that case previously installed certificate will be   ::
ECHO :: replaced with the new provided certificate.
ECHO ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SETLOCAL EnableDelayedExpansion 
Rem default values
set cert_path="C:\Users\725252\Desktop\certs AD"


Rem dir C:\Users\725252\Desktop\certsAD /A:-D /S /B
Rem FOR /f "tokens=*" %%G IN ('dir %cert_path%\*.cer* /A:-D /S ^| find "/"') DO ()

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
set /p cert_path="Enter certificate path :"

echo Using following store configuration:--------------------------
echo Store path: %store_path%
echo Store password: %store_pass%
echo Cert path: %cert_path%

if %keytool%=="" (
	set /p keytool="Enter keytool executable path :"
)

echo Using %keytool% for certificate installation

dir /b /s %cert_path%\*.cer* > list
FOR /f "tokens=*" %%G IN (list) DO (
	echo -----------------------------Installing certificate %%~nG ----------------------------------
	%keytool% -import -trustcacerts -keystore %store_path% -storepass %store_pass% -noprompt -alias %%~nG -file "%%G"
	if ERRORLEVEL 1 (
		call :ECHORED "Cretificate already installed......."
		call :ECHOGREEN "Removing certificate from keystore............"
		%keytool% -delete -noprompt -alias  %%~nG  -keystore %store_path% -storepass %store_pass%
		if ERRORLEVEL 1 goto :Error
		call :ECHOGREEN "Reinstalling certificate................"
		%keytool% -import -trustcacerts -keystore %store_path% -storepass %store_pass% -noprompt -alias %%~nG -file "%%G"
		if ERRORLEVEL 1 goto :Error
	) else call :ECHOGREEN Certificate installed successfully
	echo ---------------------------------------------------------------------------------------------
)

goto :End


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
IF EXIST test.txt DEL /F list
EXIT /B %ERRORLEVEL%