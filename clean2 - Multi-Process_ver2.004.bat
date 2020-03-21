@echo off &&　SETLOCAL ENABLEDELAYEDEXPANSION
Rem Harry ver2.004 20200321
GOTO GetAdmin
:Start
:: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 自行設定區/ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
:: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 直接依照格式新增即可 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:: 腳本類型1:清理C槽下所有【副檔名】文件，每一行均是獨立運行腳本
SET "Ext[1]=.tmp,.syd,.---,.$$$,.@@@,.??$,.??~,.err,.prv"
SET "Ext[2]=.xlk,.diz,.dmp,._mp,.gid,.chk,.old,.wbk,.ftg,.fts"

:: 腳本類型2:指令直接執行
SET Command[1]=del /f /s /q %systemdrive%\mscreate.dir
SET Command[2]=del /f /s /q %systemdrive%\chklist.*
SET Command[3]=del /f /s /q %systemdrive%\recycled\*.*
SET Command[4]=del /f /s /q %systemdrive%\*.~*
SET Command[5]=del /f /s /q %windir%\*.bak
SET Command[6]=del /f /s /q %windir%\prefetch\*.*
SET Command[7]=del /s /f /q "%systemroot%\Temp\*.*"
SET Command[8]=del /f /s /q /a %systemdrive%\*.sqm
SET Command[9]=del /s /f /q "%AllUsersProfile%\「開始」功能表\程式集\Windows Messenger.lnk"
SET Command[10]=rd /s /q %windir%\temp 
SET Command[11]=md %windir%\temp
SET Command[12]=rd /s /q "%systemdrive%\Program Files\Temp"
SET Command[13]=md "%systemdrive%\Program Files\Temp"
SET Command[14]=rd /s /q "%systemdrive%\d"

:: 腳本類型3：清除C:\Users\所有個人設定檔\【路徑】；另外firefox快取因路徑特殊，因此強制清理。
SET "Path[1]=\Local Settings\Temporary Internet Files\"
SET "Path[2]=\appdata\recent\"
SET "Path[3]=\Local Settings\Temp\"
SET "Path[4]=\recent\"
SET "Path[5]=\appdata\Local\Google\Chrome\User Data\Default\Cache\"
SET "Path[6]=\appdata\AppData\Local\UCBrowser\User Data\Default\Cache\"

:: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ /自行設定區 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
:: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
GOTO Start2

:GetAdmin
:: BatchGotAdmin (Run as Admin code starts)
REM --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
echo Requesting administrative privileges...
goto UACPrompt
) else ( goto gotAdmin )
:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
exit /B
:gotAdmin
if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
pushd "%CD%"
CD /D "%~dp0"
:: BatchGotAdmin (Run as Admin code ends)
:: Your codes should start from the following line
GOTO Start
:Start2

:: 清除殘留檔
IF EXIST "%appdata%\IT_Clean_Tool" RD /S /Q "%appdata%\IT_Clean_Tool"

:: 建立暫存資料夾
MKDIR %appdata%\IT_Clean_Tool\Count

:: 計時模組START
SET "INSTR="
FOR %%I IN (%*) DO (
    SET "INSTR=!INSTR!%%I "
)
SET A=%TIME%

SET A_HOUR=%A:~0,2%
SET A_MINS=%A:~3,2%
SET A_SECS=%A:~6,2%
SET A_MSEC=%A:~9,2%
%INSTR%

:: 腳本啟動日期與時間
SET RunDate=%DATE:~0,4%%DATE:~5,2%%DATE:~8,2%
SET RunDate=%RunDate: =0%_%A: =%

:: 執行紀錄與啟動系統清理
ECHO 執行紀錄:
FOR /F "tokens=1,2,3,4,*" %%i IN ('reg query "HKEY_LOCAL_MACHINE\software\ItCleanTool" ^| find /i "RunDate"') DO SET "RunDate_=%%k"

IF defined RunDate_ (
    START cleanmgr /sagerun:99
    ECHO 上次執行時間為：%RunDate_%
    goto _SKIPSAVE
)

START cleanmgr /sageset:99
ECHO.
ECHO 此為首次執行設定，請於設定好磁碟清理工具清理項目後再按任意鍵繼續
SET "RunDate_=None"
ECHO.
pause
START cleanmgr
(
ECHO Windows Registry Editor Version 5.00
ECHO.
ECHO [HKEY_LOCAL_MACHINE\SOFTWARE\ItCleanTool]
ECHO "Note"="This key is stored for record after the IT Clean Tool has been run"
ECHO "RunDate"="%RunDate%"
)>%appdata%\IT_Clean_Tool\ItCleanTool.reg
regedit /s %appdata%\IT_Clean_Tool\ItCleanTool.reg
DEL /Q %appdata%\IT_Clean_Tool\ItCleanTool.reg

:_SKIPSAVE

:: 紀錄清理前C槽空間
FOR /F "delims= tokens=1" %%a in ('fsutil volume diskfree c:') do set DiskFreeS=%%a

::設定獨立腳本數量變數
SET SNUMB=0

CLS
TITLE SyS Clean 正在清除系統垃圾檔案中，請稍候......ver2.001


:: 創建獨立清除腳本/
:: ~~~~~~~~~~~~~~~~

:: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 清除腳本類型1/ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
:: ~~~~~~~~~~~~~~~~~~~~ 刪除C:\副檔名為【變數%EXT*%】的所有文件 ~~~~~~~~~~~~~~~~~~~~~~~~
SET Ext_Index=1
:ExtLoopStart
if defined Ext[%Ext_Index%] (
    SET /A SNUMB=%SNUMB%+1
    ECHO 創建 SyS clean !SNUMB! 清除程序
    (
        ECHO @echo off ^&^& SETLOCAL ENABLEDELAYEDEXPANSION
        ECHO set "sch=!Ext[%Ext_Index%]!"
        ECHO for %%%%a in (!Ext[%Ext_Index%]!^) do (
        SETLOCAL DISABLEDELAYEDEXPANSION
        SET sch_=!sch:%%%%a=  【%%%%a】  !
        SETLOCAL ENABLEDELAYEDEXPANSION
        ECHO title SyS Clean !SNUMB! !sch_!
        ECHO del /f /s /q C:\*%%%%a
        ECHO ^)
        ECHO echo "!SNUMB!"^>%appdata%\IT_Clean_Tool\Count\!SNUMB!.txt^&^&exit
    )>%appdata%\IT_Clean_Tool\Clean_tmp!SNUMB!.bat
    start "" "%appdata%\IT_Clean_Tool\Clean_tmp!SNUMB!.bat"
    SET /A Ext_Index=%Ext_Index%+1
    GOTO ExtLoopStart
)

setlocal enabledelayedexpansion
:: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ /清除腳本類型1 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
:: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


:: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 清除腳本類型2/ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
:: ~~~~~~~~~~~~~~~~~~~~~~~~~~ 依序執行【Command[*]】指令 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SET /A SNUMB=%SNUMB%+1
ECHO 創建 SyS clean %SNUMB% 清除程序
(
ECHO @echo off
ECHO title SyS Clean %SNUMB%
)>%appdata%\IT_Clean_Tool\Clean_tmp%SNUMB%.bat
SET Com_Index=1
:ComLoopStart
if defined Command[%Com_Index%] (
    echo !Command[%Com_Index%]!>>%appdata%\IT_Clean_Tool\Clean_tmp%SNUMB%.bat
    SET /A Com_Index=%Com_Index%+1
    GOTO ComLoopStart
)
(
ECHO echo "%SNUMB%"^>%appdata%\IT_Clean_Tool\Count\%SNUMB%.txt^&^&exit
)>>%appdata%\IT_Clean_Tool\Clean_tmp%SNUMB%.bat
start "" "%appdata%\IT_Clean_Tool\Clean_tmp%SNUMB%.bat"
:: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ /清除腳本類型2 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
:: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


:: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 清除腳本類型3/ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
:: ~~~~~~~~~~~~~~~~~ 遍歷C:\Users\* 下使用者資料夾並刪除指定資料夾檔案 ~~~~~~~~~~~~~~~~~~
SET /A SNUMB=%SNUMB%+1
ECHO 創建 SyS clean %SNUMB% 清除程序
(
ECHO @echo off ^&^& SETLOCAL ENABLEDELAYEDEXPANSION
ECHO echo 清除個別使用者暫存檔
)>%appdata%\IT_Clean_Tool\Clean_tmp%SNUMB%.bat
SET Pat_Index=1
:PatLoopStart
if defined Path[%Pat_Index%] (
    echo SET "Path[%Pat_Index%]_=!Path[%Pat_Index%]!">>%appdata%\IT_Clean_Tool\Clean_tmp%SNUMB%.bat
    SET /A Pat_Index=%Pat_Index%+1
    GOTO PatLoopStart
)
(
ECHO SET Pat_Index_=1
ECHO :PatLoopStart_
ECHO if defined Path[%%Pat_Index_%%]_ (
ECHO     for /f "delims= " %%%%i in ('DIR /B /ON C:\users'^) do (
ECHO       title SyS Clean %SNUMB% 清理 %%%%i 暫存檔
ECHO       del /f /s /q "C:\Users\%%%%i^!Path[%%Pat_Index_%%]_:~^!*.*"
ECHO       for /f "delims= " %%%%j in ('DIR /B /ON C:\users\%%%%i\AppData\Local\Mozilla\Firefox\Profiles'^) do (
ECHO         del /f /s /q "C:\users\%%%%i\AppData\Local\Mozilla\Firefox\Profiles\%%%%j\cache2\entries\*.*"
ECHO       ^)
ECHO     ^)
ECHO     SET /A Pat_Index_=%%Pat_Index_%%+1
ECHO     GOTO PatLoopStart_
ECHO ^)
ECHO echo "%SNUMB%"^>%appdata%\IT_Clean_Tool\Count\%SNUMB%.txt^&^&exit
)>>%appdata%\IT_Clean_Tool\Clean_tmp%SNUMB%.bat
start "" "%appdata%\IT_Clean_Tool\Clean_tmp%SNUMB%.bat"
:: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ /清除腳本類型3 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
:: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


:: /創建獨立清除腳本
:: ~~~~~~~~~~~~~~~~
ECHO.
ECHO 正在清除系統垃圾檔案中，請稍候......
ECHO.


:: 等待獨立清除腳本完成
:: ~~~~~~~~~~~~~~~~~~~
:_WAIT01
ECHO 使用者列表: 
DIR /B /ON C:\users
ECHO.
ECHO C槽清除前：%DiskFreeS%
SET /P= ■<nul
for /L %%i in (1 1 30) do set /p a=■<nul&ping /n 1 127.0.0.1>nul
for /f %%i in ('dir "%appdata%\IT_Clean_Tool\Count" /a-h-s /s^| find "個檔案"') do (Set /A "TOTAL=%%i")
TITLE SyS Clean 正在清除系統垃圾檔案中，請稍候 Done: %TOTAL% / Total: %SNUMB%......ver2.001
cls
ECHO 清除中，進度 Done: %TOTAL% / Total: %SNUMB%
ECHO.
ECHO 上次執行時間為：%RunDate_%
ECHO.
IF %TOTAL% LSS %SNUMB% GOTO _WAIT01


:: 計時模組END
:: ~~~~~~~~~~~
SET B=%TIME%


SET B_HOUR=%B:~0,2%
SET B_MINS=%B:~3,2%
SET B_SECS=%B:~6,2%
SET B_MSEC=%B:~9,2%

ECHO.
ECHO START TIME:%A%
ECHO END   TIME:%B%

SET /A C_MSEC=B_MSEC-A_MSEC
SET /A C_SECS=B_SECS-A_SECS
SET /A C_MINS=B_MINS-A_MINS
SET /A C_HOUR=B_HOUR-A_HOUR

IF %C_MSEC% LSS 0  SET /A C_MSEC+=100 & SET /A C_SECS-=1
IF %C_MSEC% LSS 10 SET C_MSEC=0%C_MSEC%

IF %C_SECS% LSS 0  SET /A C_SECS+=60  & SET /A C_MINS-=1
IF %C_SECS% LSS 10 SET C_SECS=0%C_SECS%

IF %C_MINS% LSS 0  SET /A C_MINS+=60  & SET /A C_HOUR-=1
IF %C_MINS% LSS 10 SET C_MINS=0%C_MINS%

IF %C_HOUR% LSS 0  SET /A C_HOUR+=24
IF %C_HOUR% LSS 10 SET C_HOUR=0%C_HOUR%

ECHO ELAPSE    :%C_HOUR%:%C_MINS%:%C_SECS%.%C_MSEC%

FOR /F "delims= tokens=1" %%a in ('fsutil volume diskfree c:') do set DiskFreeE=%%a
ECHO.
ECHO C槽清除前：%DiskFreeS%
ECHO C槽清除後：%DiskFreeE%

TITLE SYS Clean 已完成......%C_HOUR%:%C_MINS%:%C_SECS%.%C_MSEC% ver2.001
ENDLOCAL

:: 紀錄清理後C槽空間

:: 清除暫存檔。
:: ~~~~~~~~~~~
RD /S /Q "%appdata%\IT_Clean_Tool"
ECHO.
ECHO 全部清除已完成。
ECHO.& pause 