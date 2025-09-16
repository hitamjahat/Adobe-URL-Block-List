@echo off
REM Batch script to block Adobe executables in firewall, update hosts, stop/disable services/tasks
REM Run as administrator

REM Check if running as administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
  echo This script must be run as administrator.
  echo Right-click the .bat file and select "Run as administrator".
  pause
  exit /b 1
)

echo Running as administrator. Proceeding...

REM List of specific Adobe executables to block
echo.
echo Blocking specific Adobe executables in firewall...

REM Block each executable individually
call :blockexe "C:\Program Files\Adobe\Acrobat DC\Acrobat\Acrobat.exe"
call :blockexe "C:\Program Files\Adobe\Acrobat DC\Acrobat\AcrobatInfo.exe"
call :blockexe "C:\Program Files\Adobe\Acrobat DC\Acrobat\acrobat_sl.exe"
call :blockexe "C:\Program Files\Adobe\Acrobat DC\Acrobat\AcroBroker.exe"
call :blockexe "C:\Program Files\Adobe\Acrobat DC\Acrobat\acrodist.exe"
call :blockexe "C:\Program Files\Adobe\Acrobat DC\Acrobat\AcroShareTarget.exe"
call :blockexe "C:\Program Files\Adobe\Acrobat DC\Acrobat\AcroTextExtractor.exe"
call :blockexe "C:\Program Files\Adobe\Acrobat DC\Acrobat\acrotray.exe"
call :blockexe "C:\Program Files\Adobe\Acrobat DC\Acrobat\ADelRCP.exe"
call :blockexe "C:\Program Files\Adobe\Acrobat DC\Acrobat\AdobeCollabSync.exe"
call :blockexe "C:\Program Files\Adobe\Acrobat DC\Acrobat\CRLogTransport.exe"
call :blockexe "C:\Program Files\Adobe\Acrobat DC\Acrobat\CRWindowsClientService.exe"
call :blockexe "C:\Program Files\Adobe\Acrobat DC\Acrobat\Eula.exe"
call :blockexe "C:\Program Files\Adobe\Acrobat DC\Acrobat\LogTransport2.exe"
call :blockexe "C:\Program Files\Adobe\Acrobat DC\Acrobat\AcroCEF\AcroCEF.exe"
call :blockexe "C:\Program Files\Adobe\Acrobat DC\Acrobat\AcroCEF\AcroServicesUpdater.exe"
call :blockexe "C:\Program Files\Adobe\Acrobat DC\Acrobat\AcroCEF\SingleClientServicesUpdater.exe"
call :blockexe "C:\Program Files\Adobe\Acrobat DC\Acrobat\acrocef_1\AcroCEF.exe"
call :blockexe "C:\Program Files\Adobe\Acrobat DC\Acrobat\acrocef_1\AcroServicesUpdater.exe"
call :blockexe "C:\Program Files\Adobe\Acrobat DC\Acrobat\acrocef_1\SingleClientServicesUpdater.exe"
call :blockexe "C:\Program Files\Adobe\Acrobat DC\Acrobat\ADCNotificationClient\FullTrustNotifier.exe"
call :blockexe "C:\Program Files\Adobe\Acrobat DC\Acrobat\Browser\WCChromeExtn\WCChromeNativeMessagingHost.exe"
call :blockexe "C:\Program Files\Adobe\Acrobat DC\Acrobat\NGL\cefWorkflow\adobe_licensing_wf_acro.exe"
call :blockexe "C:\Program Files\Adobe\Acrobat DC\Acrobat\NGL\cefWorkflow\adobe_licensing_wf_helper_acro.exe"
call :blockexe "C:\Program Files\Adobe\Acrobat DC\Acrobat\plug_ins\pi_brokers\32BitMAPIBroker.exe"
call :blockexe "C:\Program Files\Adobe\Acrobat DC\Acrobat\plug_ins\pi_brokers\64BitMAPIBroker.exe"
call :blockexe "C:\Program Files\Adobe\Acrobat DC\Acrobat\plug_ins\pi_brokers\MSRMSPIBroker.exe"
call :blockexe "C:\Program Files\Adobe\Acrobat DC\Acrobat\plug_ins\Scan\AcroScanBroker.exe"
call :blockexe "C:\Program Files\Adobe\Acrobat DC\Acrobat\RDCNotificationClient\FullTrustNotifier.exe"
call :blockexe "C:\Program Files\Adobe\Acrobat DC\Acrobat\x64\CreatePDFPrinterUtility64.exe"
call :blockexe "C:\Program Files\Adobe\Acrobat DC\Acrobat\x86\Acrobat\Acrobat.exe"
call :blockexe "C:\Program Files\Adobe\Acrobat DC\Acrobat\Xtras\AdobePDF\PrintInf64.exe"
call :blockexe "C:\Program Files\Adobe\Acrobat DC\Acrobat Elements\Acrobat Elements.exe"
call :blockexe "C:\Program Files\Adobe\Acrobat DC\PDFMaker\Office\HTML2PDFWrapFor64Bit.exe"
call :blockexe "C:\Program Files (x86)\Common Files\Adobe\ARM\1.0\AdobeARM.exe"
call :blockexe "C:\Program Files (x86)\Common Files\Adobe\ARM\1.0\AdobeARMHelper.exe"
call :blockexe "C:\Program Files (x86)\Common Files\Adobe\ARM\1.0\armsvc.exe"
call :blockexe "C:\Program Files (x86)\Common Files\Adobe\ARM\1.0\UCB\AdobeARM_UCB.exe"

goto :continue

:blockexe
setlocal
set "exepath=%~1"
if exist "%exepath%" (
  echo Blocking: %~n1
  netsh advfirewall firewall add rule name="Block %~n1 Inbound" dir=in action=block program="%exepath%" enable=yes >nul 2>&1
  netsh advfirewall firewall add rule name="Block %~n1 Outbound" dir=out action=block program="%exepath%" enable=yes >nul 2>&1
  echo Successfully blocked %~n1
) else (
  echo Skipping: %~n1 (not found)
)
endlocal
goto :eof

:continue
echo.
echo Downloading and updating hosts file...
bitsadmin /transfer "AdobeHosts" https://raw.githubusercontent.com/hitamjahat/Adobe-URL-Block-List/master/hosts "%temp%\adobe_hosts.txt"
if exist "%temp%\adobe_hosts.txt" (
  echo # Block known Adobe hosts >> "%windir%\System32\drivers\etc\hosts"
  echo # From: https://github.com/hitamjahat/Adobe-URL-Block-List >> "%windir%\System32\drivers\etc\hosts"
  type "%temp%\adobe_hosts.txt" >> "%windir%\System32\drivers\etc\hosts"
  del "%temp%\adobe_hosts.txt"
) else (
  echo Failed to download hosts file.
)

echo.
echo Stopping and disabling Adobe services/tasks...
taskkill /f /im armsvc.exe 2>nul
sc config "AdobeARMservice" start= disabled 2>nul
sc stop "AdobeARMservice" 2>nul
schtasks /change /tn "Adobe Acrobat Update Task" /disable 2>nul

echo.
echo Done. Press any key to exit.
pause >nul
