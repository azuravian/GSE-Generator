@echo off
powershell -Command "[Console]::CursorVisible=0"
mode con cols=120 lines=40
set TITLE=Goldberg Steam Emulator Generator
set HOME=%~dp0
title %TITLE%
cd /d "%HOME%"
chcp 65001>NUL
color 07


: ARGUMENTS
:: achievements toast
if /i [%1] == [-toast] set WantedName=achievements&set WantedExtension=.json&call :function_open_file_context&call :function_test_achievements_file&goto END
if /i [%1] == [-t] set WantedName=achievements&set WantedExtension=.json&call :function_open_file_context&call :function_test_achievements_file&goto END
if [%~nx1] == [achievements.json] set "FileDir=%~dp1"&call :function_test_achievements_file&goto END
:: steam_interfaces
if /i [%1] == [-interfaces] set WantedName=steam_api&set WantedExtension=.dll&call :function_open_file_context&set GOTO=:function_steam_interfaces&call :function_steam_api_file&goto END
if /i [%1] == [-i] set WantedName=steam_api&set WantedExtension=.dll&call :function_open_file_context&set GOTO=:function_steam_interfaces&call :function_steam_api_file&goto END
:: golberg emulator
if /i [%1] == [-emulator] set WantedName=steam_api&set WantedExtension=.dll&call :function_open_file_context&set GOTO=:function_goldberg_emulator_fork&call :function_steam_api_file&goto END
if /i [%1] == [-e] set WantedName=steam_api&set WantedExtension=.dll&call :function_open_file_context&set GOTO=:function_goldberg_emulator_fork&call :function_steam_api_file&goto END
:: steam_interfaces and golberg emulator
if /i [%1] == [--ie] set WantedName=steam_api&set WantedExtension=.dll&call :function_open_file_context&set GOTO=:function_steam_interfaces&call :function_steam_api_file&call :function_goldberg_emulator_fork&goto END
:: help
if /i [%1] == [-help] call :function_help&exit /b
if /i [%1] == [-h] call :function_help&exit /b
:: normal or steam_interfaces and golberg emulator
if not [%1] == [] (
	echo %1 | findstr /C:"steam_api" 1>nul
	if not errorlevel 1 (
		set "FileDir=%~dp1"
		set "FileName=%~nx1"
		Tools\7z\7z.exe l %1 1>NUL 2>NUL:&&(
			set GOTO=:function_steam_interfaces
			call :function_steam_api_file
			call :function_goldberg_emulator_fork
			goto END
		)||(
			call :function_help&exit /b
		)
	)
	call :function_help&exit /b
)

: START
call :function_banner
:: script achievement 
set TOASTNAME=ACHIEVEMENT_01&call :function_script_toast

: IMPUTTEXTBOX
call :function_search_id

: SEARCH_DLCS
call :function_search_dlcs

: CONFIGS_USER
call :function_configs_user

: SEARCH_ACHIEVEMENTS
call :function_achievements

: STEAM_API
if exist "*steam_api*" (
	for /f %%a in ('dir /A:A /B /O:N "*steam_api*"') do (
		set "FileDir=%HOME%"
		set "FileName=%%a"
		Tools\7z\7z.exe l "%HOME%%%a" 1>NUL 2>NUL:&&(set apihere=true&goto CONFIRM_API)||(set apihere=false)
	)
)

: OPEN_API
echo set outp=wscript.stdout : c=msgbox("Do you want to search the original steam_api of this game to continue?",vbInformation+vbYesNo,"STEAM_API"^) : outp.write(c^)>api.vbs
for /f "tokens=*" %%a in ('c:\windows\system32\cscript.exe /nologo api.vbs') do (
	if "%%a"=="6" set WantedName=steam_api&set WantedExtension=.dll&call :function_open_file_context&set GOTO=:function_steam_interfaces&call :function_steam_api_file&call :function_goldberg_emulator_fork
	if "%%a"=="7" goto END
)
goto DONE

: CONFIRM_API
if "%apihere%"=="true" (
	echo set outp=wscript.stdout : c=msgbox("This ''%FileName%'' is from this game?",vbInformation+vbYesNo,"STEAM_API"^) : outp.write(c^)>api.vbs
	for /f "tokens=*" %%a in ('c:\windows\system32\cscript.exe /nologo api.vbs') do (
		if "%%a"=="6" set GOTO=:function_steam_interfaces&call :function_steam_api_file&call :function_goldberg_emulator_fork
	)
)

: DONE
if exist "steam_api*dll" move "steam_api*dll" "%GameName%\">NUL
if exist "steam_interfaces.txt" move "steam_interfaces.txt" "%GameName%\steam_settings\">NUL
rem script achievement 
set TOASTNAME=ACHIEVEMENT_03&call :function_script_toast

: END
if exist "api.vbs" del "api.vbs">NUL
echo.
pause>NUL|echo  Press any key to exit . . .
exit


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::                                                           ::
::                         FUNCTIONS                         ::
::                                                           ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:function_banner
cls
echo.
echo   [44;4m                                                                                                                    [0m
echo   [104m                                                                                                                    [0m
echo   [104;97m                                         GOLDBERG STEAM EMULATOR GENERATOR                                          [0m
echo   [104;37m                                           generate steam_settings folder                                           [0m
echo   [104;4;30m                                                                                                                    [0m
echo   [44;30m                                                                                                                    [0m
echo.
goto :EOF

:function_search_id
set Search=
:: ImputTextBox / for multiline bypass characters like: ,;)=
for /f "tokens=1-9 delims=[]" %%1 in ('^
	powershell -Command^
		Add-Type -AssemblyName System.Windows.Forms^;^
		Add-Type -AssemblyName System.Drawing^;^
		$font ^= New-Object System.Drawing.Font^;^
^
		$form ^= New-Object Windows.Forms.Form -Property @{^
			StartPosition	^= [Windows.Forms.FormStartPosition]::CenterScreen^;^
			FormBorderStyle ^= [Windows.Forms.FormBorderStyle]::FixedDialog^;^
			MaximizeBox		^= $false^;^
			MinimizeBox		^= $false^;^
			Size			^= New-Object Drawing.Size 400^, 155^;^
			ForeColor		^= 'white'^;^
			BackColor		^= '#282828'^;^
			Text			^= '%TITLE%'^;^
			Topmost			^= $true^;^
			Font			^= 'Consolas^, 13'^
		}^;^
^
		$TextLabel ^= New-Object Windows.Forms.Label -Property @{^
			Location		^= New-Object Drawing.Point 10^, 5^;^
			Size			^= New-Object Drawing.Size 380^, 20^;^
			Text			^= 'Enter the ID of game:'^;^
			Font			^= 'Consolas^, 13'^
		}^;^
		$form.Controls.Add($TextLabel^)^;^
^
		$ImputTextBox ^= New-Object Windows.Forms.TextBox -Property @{^
			Location		^= New-Object Drawing.Point 10^, 35^;^
			Size			^= New-Object Drawing.Size 360^;^
			Text			^= ''^;^
			MaxLength		^= 39^;^
		}^;^
		$form.Controls.Add($ImputTextBox^)^;^
^
		$SearchButton ^= New-Object Windows.Forms.Button -Property @{^
			Location		^= New-Object Drawing.Point 100^, 75^;^
			Size			^= New-Object Drawing.Size 190^, 30^;^
			Text			^= 'SEARCH'^;^
			DialogResult	^= [Windows.Forms.DialogResult]::OK^;^
			Font			^= 'Microsoft Sans Serif^, 13'^
		}^;^
		$form.Controls.Add($SearchButton^)^;^
^
		$result ^= $form.ShowDialog(^)^;^
		if ($result -eq [Windows.Forms.DialogResult]::OK^) {^
			$Search ^= ($ImputTextBox^).Text^;^
			Write-Host $Search'[TEXTBOX_IS_EMPTY]'^;^
		} else {^
			Write-Host 'PRESSED_X_TO_EXIT'^;^
		}^
') do set "Search=%%1"
if "%Search%"=="TEXTBOX_IS_EMPTY" call :function_banner&call :function_search_id
if "%Search%"=="PRESSED_X_TO_EXIT" exit

set ID=%Search%

:function_search_id
set Search=
:: ImputTextBox / for multiline bypass characters like: ,;)=
for /f "tokens=1-9 delims=[]" %%1 in ('^
	powershell -Command^
		Add-Type -AssemblyName System.Windows.Forms^;^
		Add-Type -AssemblyName System.Drawing^;^
		$font ^= New-Object System.Drawing.Font^;^
^
		$form2 ^= New-Object Windows.Forms.Form -Property @{^
			StartPosition	^= [Windows.Forms.FormStartPosition]::CenterScreen^;^
			FormBorderStyle ^= [Windows.Forms.FormBorderStyle]::FixedDialog^;^
			MaximizeBox		^= $false^;^
			MinimizeBox		^= $false^;^
			Size			^= New-Object Drawing.Size 400^, 155^;^
			ForeColor		^= 'white'^;^
			BackColor		^= '#282828'^;^
			Text			^= '%TITLE%'^;^
			Topmost			^= $true^;^
			Font			^= 'Consolas^, 13'^
		}^;^
^
		$TextLabel2 ^= New-Object Windows.Forms.Label -Property @{^
			Location		^= New-Object Drawing.Point 10^, 5^;^
			Size			^= New-Object Drawing.Size 380^, 20^;^
			Text			^= 'Enter the name of game:'^;^
			Font			^= 'Consolas^, 13'^
		}^;^
		$form2.Controls.Add($TextLabel2^)^;^
^
		$NameTextBox ^= New-Object Windows.Forms.TextBox -Property @{^
			Location		^= New-Object Drawing.Point 10^, 35^;^
			Size			^= New-Object Drawing.Size 360^;^
			Text			^= ''^;^
			MaxLength		^= 39^;^
		}^;^
		$form2.Controls.Add($NameTextBox^)^;^
^
		$SearchButton2 ^= New-Object Windows.Forms.Button -Property @{^
			Location		^= New-Object Drawing.Point 100^, 75^;^
			Size			^= New-Object Drawing.Size 190^, 30^;^
			Text			^= 'SEARCH'^;^
			DialogResult	^= [Windows.Forms.DialogResult]::OK^;^
			Font			^= 'Microsoft Sans Serif^, 13'^
		}^;^
		$form2.Controls.Add($SearchButton2^)^;^
^
		$result2 ^= $form2.ShowDialog(^)^;^
		if ($result2 -eq [Windows.Forms.DialogResult]::OK^) {^
			$Search ^= ($NameTextBox^).Text^;^
			Write-Host $Search'[TEXTBOX_IS_EMPTY]'^;^
		} else {^
			Write-Host 'PRESSED_X_TO_EXIT'^;^
		}^
') do set "Search=%%1"
if "%Search%"=="TEXTBOX_IS_EMPTY" call :function_banner&call :function_search_id
if "%Search%"=="PRESSED_X_TO_EXIT" exit

set Name=%Search%

echo Game App ID=%ID%
echo Game Name=%Name%

:: Check if either ID or Name is empty, if so, ask again
if "%ID%"=="" goto :function_search_id
if "%Name%"=="" goto :function_search_id

:: If both are filled, assign to GameAppID and GameName
set GameAppID=%ID%
set GName=%Name%

:: Print variables (for testing purposes)
echo Game App ID=%GameAppID%
echo Game Name=%GName%

:: Continue with the rest of the script

:SEARCH_GAME
echo.
echo  [ ] Searching game . . .
rem chcp 65001>NUL
set GameName=
set "GameName=%GName:&=%"
set "GameName=%GName:'=%"
set "GameName=%GName:  = %"
for /f "tokens=*" %%a in ('powershell -Command "'%GName%'.ToLower()"') do set "game=%%a"
rem set "steamgame=%game: =+%"
set GameName=%game%

REM Tools\CURL\curl.exe -s --config Tools/CURL/config/safari15_5.config --header @Tools/CURL/config/safari15_5.header --url "https://www.google.com/search?q=%steamgame%+steamdb" -o google.html

REM pause

REM powershell -Command "(gc -LiteralPath '%HOME%google.html') -replace '<div><span jscontroller', \"`r`n^<GAME^>^<\" -replace 'href=""', '><' -replace '"""" data-', 'game><data' -replace \"'\", '' -replace '\\', '' -replace '\|', '' -replace '\?', '' -replace '\*', '' -replace '""', '' -replace '&apos;', '' -replace '&amp;', '' -replace '&#39;', '' | Out-File -LiteralPath '%HOME%google.html' -NoNewline -encoding Default">NUL
REM for /f "tokens=1-9 delims=<>" %%1 in (google.html) do (
	REM if "%%1"=="GAME" (
		REM if not defined GameAppID (
			REM for /f "tokens=1-9 delims=/" %%a in ("%%4") do (
				REM if "%%c"=="app" (
					REM if "%%e"=="game" (
						REM set GameAppID=%%d
					REM )
				REM )
			REM )
		REM )
	REM )
REM )
REM if defined GameAppID (
	REM for /f "tokens=1-10 delims=<>" %%a in (google.html) do (
		REM if "%%d"=="https://steamdb.info/app/%GameAppID%/game" (
			REM set "GameName=%%i"
		REM )
	REM )
REM )
REM del "google.html">NUL
REM if not defined GameName echo  [91mGAME NOT FOUND[0m&timeout 3&call :function_banner&call :function_search_id
REM set "GameName=%GameName: Price history=%"
REM set "GameName=%GameName: - SteamDB=%"

set "GameName=%GameName:<=%"
set "GameName=%GameName:>=%"
set "GameName=%GameName:/=%"
set "GameName=%GameName::=%"
set "GameName=%GameName:!=%"
set "GameName=%GameName:  = %"
set "GameNameShow=%GameName%"
set "GameName=%GameName% (%GameAppID%)"
echo   [90m%GameName%[0m

:SHOW_IMAGE
Tools\CURL\curl.exe -s "https://cdn.akamai.steamstatic.com/steam/apps/%GameAppID%/header.jpg" -o "%GameAppID%.jpg"
rem curl -s "https://cdn.akamai.steamstatic.com/steam/apps/%GameAppID%/logo.png" -o "%GameAppID%_logo.png"
rem curl -s "https://cdn.akamai.steamstatic.com/steam/apps/%GameAppID%/library_600x900.jpg" -o "%GameAppID%_cover.png"
powershell -Command^
	Add-Type -AssemblyName System.Windows.Forms;^
	Add-Type -AssemblyName System.Drawing;^
	$file = (get-item '%GameAppID%.jpg');^
	$img = [System.Drawing.Image]::Fromfile($file);^
	$form = New-Object Windows.Forms.Form -Property @{^
		StartPosition	= [Windows.Forms.FormStartPosition]::CenterScreen;^
		FormBorderStyle = [Windows.Forms.FormBorderStyle]::FixedDialog;^
		ControlBox		= $false;^
		Size			= New-Object Drawing.Size 500, 400;^
		ForeColor		= 'white';^
		BackColor		= '#282828';^
		Text			= '%TITLE%';^
		Topmost			= $true;^
		Font			= 'Consolas, 13';^
	};^
	$FoundLabel = New-Object Windows.Forms.Label -Property @{^
		Location		= New-Object Drawing.Point 10, 5;^
		Size			= New-Object Drawing.Size 500, 20;^
		Text			= 'Found this game:';^
		Font			= 'Consolas, 13'^
	};^
	$form.Controls.Add($FoundLabel);^
	$GameNameLabel = New-Object Windows.Forms.Label -Property @{^
		Location		= New-Object Drawing.Point 10, 25;^
		Size			= New-Object Drawing.Size 500, 20;^
		ForeColor		= 'gold';^
		Text			= '%GameNameShow%';^
		Font			= 'Consolas bold, 13'^
	};^
	$form.Controls.Add($GameNameLabel);^
	$Picture = New-Object Windows.Forms.PictureBox -Property @{^
		Location		= New-Object Drawing.Point 12, 55;^
		Size			= New-Object Drawing.Size 460, 215;^
		Image			= $img;^
	};^
	$form.Controls.Add($Picture);^
	$ContinueTextLabel = New-Object Windows.Forms.Label -Property @{^
		Location		= New-Object Drawing.Point 10, 280;^
		Size			= New-Object Drawing.Size 500, 20;^
		Text			= 'Do you want to continue?';^
		Font			= 'Consolas, 13'^
	};^
	$form.Controls.Add($ContinueTextLabel);^
	$YESButton = New-Object Windows.Forms.Button -Property @{^
		Location		= New-Object Drawing.Point 30, 310;^
		Size			= New-Object Drawing.Size 200, 30;^
		Text			= 'YES';^
		DialogResult	= [Windows.Forms.DialogResult]::YES;^
		Font			= 'Microsoft Sans Serif, 13'^
	};^
	$form.Controls.Add($YESButton);^
	$NOButton = New-Object Windows.Forms.Button -Property @{^
		Location		= New-Object Drawing.Point 260, 310;^
		Size			= New-Object Drawing.Size 200, 30;^
		Text			= 'NO';^
		DialogResult	= [Windows.Forms.DialogResult]::NO;^
		Font			= 'Microsoft Sans Serif, 13'^
	};^
	$form.Controls.Add($NOButton);^
	$result = $form.ShowDialog();^
	if ($result -eq [Windows.Forms.DialogResult]::YES) {^
		echo YES>Continue.txt;^
	} else {^
		echo NO>Continue.txt;^
	};
for /f "tokens=*" %%a in (Continue.txt) do set ANSWER=%%a
del "Continue.txt">NUL
if "%ANSWER%"=="NO" del "%GameAppID%.jpg">NUL&echo  [91mCANCELED[0m&timeout 3&call :function_banner&call :function_search_id
:: steam_settings - make dir
if not exist "%GameName%\steam_settings" mkdir "%GameName%\steam_settings">NUL
:: steam_settings - header image
move "%GameAppID%.jpg" "%GameName%\steam_settings\">NUL
:: steam_settings - steam_appid.txt
echo %GameAppID%>"%GameName%\steam_settings\steam_appid.txt"
echo  [x] Done!
goto :EOF

:function_search_dlcs
echo.
echo  [ ] Searching downloadable content . . .
set /a total=-1
if exist "Database\%GameAppID%.ini" (
	for /f "tokens=*" %%a in (Database\%GameAppID%.ini) do set /a total+=1
	echo set outp=wscript.stdout : c=msgbox("Allready exist a DLC list on database folder"+vbNewLine+"Do you want to search again?",vbInformation+vbYesNo,"Database"^) : outp.write(c^)>database.vbs
	for /f "tokens=*" %%a in ('c:\windows\system32\cscript.exe /nologo database.vbs') do set searchAnswer=%%a
	del "database.vbs">NUL
	goto :DATABASE
) else (
	goto :ONLINE
)

:DATABASE
if "%searchAnswer%"=="6" goto :ONLINE
if "%searchAnswer%"=="7" (
	if exist "configs.app.ini" del "configs.app.ini">NUL
	if not "%total%"=="0" echo [app::dlcs]>configs.app.ini&>>configs.app.ini echo unlock_all=0
	powershell -Command "(gc -LiteralPath '%HOME%Database\%GameAppID%.ini') -replace ' = ', '=' | Select-Object -Skip 1">>configs.app.ini
	if exist "%GameAppID%.json" del "%GameAppID%.json">NUL
	if exist "configs.app.ini" move "configs.app.ini" "%GameName%\steam_settings\configs.app.ini">NUL
	echo  [x] Done!
	goto :EOF
)

:ONLINE
set newdlcline=
for /f %%a in ('powershell -Command "[Console]::CursorTop"') do set /a PROGRESSBACKTOLINE=%%a
:: get dlcs list
echo %GameAppID%>dlcs_%GameAppID%.txt
Tools\CURL\curl.exe -s "https://store.steampowered.com/api/appdetails/?filters=basic&appids=%GameAppID%" -o %GameAppID%.json
for /f %%a in ('powershell -Command "$json = (gc -LiteralPath '%HOME%%GameAppID%.json') | ConvertFrom-Json; [bool]($json.PSobject.Properties.value.data -match 'dlc')"') do set ExistJsonDlc=%%a
if "%ExistJsonDlc%"=="True" (
	powershell -Command "$json = (gc -LiteralPath '%HOME%%GameAppID%.json') | ConvertFrom-Json; $json.PSobject.Properties.value.data.dlc | Sort-Object">>dlcs_%GameAppID%.txt
)
set /a total=-1
for /f "tokens=*" %%a in (dlcs_%GameAppID%.txt) do set /a total+=1
setlocal enabledelayedexpansion
set /a count=0
for /f "tokens=*" %%a in (dlcs_%GameAppID%.txt) do (
	set DlcId=%%a
	set AppName=
	set DLCList=
	rem get DLC name from DATABASE
	if not defined AppName (
		if exist "Database\%GameAppID%.ini" (
			for /f tokens^=1-9^ delims^=^= %%1 in (Database\%GameAppID%.ini) do (
				if "%%1"=="!DlcId! " (
					set "AppName=%%2"
					set "AppName=!AppName:~1!"
					set "AppName=!AppName:\/= /!"
					set "AppName=!AppName:"=lee.aspas!"
					set "EchoAppName=!AppName:&=lee.and!"
					set type=[Database]
				)
			)
		)
	)
	rem get DLC name from STEAM
	if not defined AppName (
		for /f "tokens=1-26 delims=," %%a in ('Tools\CURL\curl.exe -s "https://store.steampowered.com/api/appdetails/?filters=basic&appids=!DlcId!"') do (
			if "%%a"=="{"!DlcId!":{"success":true" (
				set "AppName=%%c"
				set "AppName=!AppName:"name":"=!"
				set "AppName=!AppName:\/= /!"
				set "AppName=!AppName:\"=lee.aspas!"
				set "AppName=!AppName:"=!"
				set "EchoAppName=!AppName:&=lee.and!"
				set type=[steam]
			)
		)
	)
	rem get DLC name from STEAMDB
	if not defined AppName (
		if not defined DLCList (
			set DLCList=steamdb.html
			Tools\CURL\curl.exe -s --config Tools/CURL/config/safari15_5.config --header @Tools/CURL/config/safari15_5.header --url https://steamdb.info/app/!DlcId!/ -o !DLCList!
			powershell -Command "(gc -LiteralPath '%HOME%!DLCList!') -replace '<h1 itemprop=\"name\"', \"`r`n^<!DlcId!\" -replace '<i class=\"muted\">', '' -replace '&apos;', \"'\" -replace '&amp;', '&' | Out-File -LiteralPath '%HOME%!DLCList!' -NoNewline -encoding Default">NUL
		)
		for /f "tokens=1-9 delims=<>" %%1 in (!DLCList!) do (
			if "%%1"=="!DlcId!" (
				set "AppName=%%2"
				set "AppName=!AppName:\/= /!"
				set "AppName=!AppName:"=lee.aspas!"
				set "EchoAppName=!AppName:&=lee.and!"
				set type=[steamdb]
			)
		)
	)
	rem get DLC name from STEAM API
	if not defined AppName (
		if not defined AppList (
			set AppList=AppList
			Tools\CURL\curl.exe -s "https://api.steampowered.com/ISteamApps/GetAppList/v2/" -o !AppList!.json
			powershell -Command "(gc -LiteralPath '%HOME%!AppList!.json') -replace '{\"appid\":', \"`r`n^<\" -replace ',\"name\":""', \"^>^<\" -replace '""""},', \"^>\" -replace '""""}]}}', \"^>\" | Out-File -LiteralPath '%HOME%!AppList!.txt' -NoNewline -encoding Default">NUL
		)
		for /f "tokens=1-10 delims=<>" %%a in (!AppList!.txt) do (
			if "%%a"=="!DlcId!" (
				set "AppName=%%b"
				set "AppName=!AppName:\/= /!"
				set "AppName=!AppName:\"=lee.aspas!"
				set "EchoAppName=!AppName:&=lee.and!"
				set type=[steam api]
			)
		)
	)
	rem DLC name unknown
	if not defined AppName set AppName=Unknown
	rem write database ini and steam_settings configs.app.ini
	set "writeDLC=!EchoAppName!"
	set "writeDLC=!writeDLC:lee.aspas="!"
	set "writeDLC=!writeDLC:lee.and=&!"
	if "!count!"=="0" (
		echo !DlcId! = !writeDLC!>%GameAppID%.ini
		if not "!total!"=="0" echo [app::dlcs]>configs.app.ini&>>configs.app.ini echo unlock_all=0
	)
	if not "!count!"=="0" (
		echo !DlcId! = !writeDLC!>>%GameAppID%.ini
		echo !DlcId!=!writeDLC!>>configs.app.ini
	)
	call :function_progress " [90m[!count!/!total!] [94m!DlcId! [90m= [92m!EchoAppName! [95m!type!"
	set /a count+=1
)
if exist "dlcs_%GameAppID%.txt" del "dlcs_%GameAppID%.txt">NUL
if exist "steamdb.html" del "steamdb.html">NUL
if exist "AppList.json" del "AppList.json">NUL
if exist "%GameAppID%.json" del "%GameAppID%.json">NUL
:: update database
if exist "%GameAppID%.ini" (
	if not exist "Database" mkdir "Database">NUL
	for /f "tokens=1-9 delims=^=" %%1 in (%GameAppID%.ini) do (
		if exist "Database\%GameAppID%.ini" (
			findstr /C:"%%1" "Database\%GameAppID%.ini" 1>NUL 2>NUL:&&(echo>nul)||(
				set newdlcline=true
				echo %%1=%%2>>"%HOME%Database\%GameAppID%.ini"
			)
		)
	)
)
if defined newdlcline (
	(for /f "tokens=1-9 delims=^=" %%a in (Database\%GameAppID%.ini) do (
		set sortnum=0000000000%%a
		echo ^<!sortnum:~-10,-1!^>%%a=%%b
	))>AppListSortNum
	sort AppListSortNum /O AppListSortNum
	(for /f "tokens=1-9 delims=<>" %%1 in (AppListSortNum) do (echo %%2))>%GameAppID%.ini
	del "AppListSortNum">NUL
)
if exist "%GameAppID%.ini" move "%GameAppID%.ini" "Database\">NUL
:: steam_settings - configs.app.ini
if exist "configs.app.ini" move "configs.app.ini" "%GameName%\steam_settings\configs.app.ini">NUL
call :function_progress "[x] Done!"
echo.
endlocal
goto :EOF

:function_configs_user
echo.
echo  [ ] Searching supported languages and configuring user . . .
Tools\CURL\curl.exe -s "https://store.steampowered.com/api/appdetails/?filters=basic&appids=%GameAppID%" -o %GameAppID%.json
::get suported languages list
for /f %%a in ('powershell -Command "$json = (gc -LiteralPath '%HOME%%GameAppID%.json') | ConvertFrom-Json; [bool]($json.PSobject.Properties.value.data -match 'supported_languages')"') do set ExistJsonLang=%%a
if "%ExistJsonLang%"=="True" (
	powershell -Command "$json = (gc -LiteralPath '%HOME%%GameAppID%.json') | ConvertFrom-Json; $json.PSobject.Properties.value.data.supported_languages -replace '<strong>\*</strong>', '' -replace '<br>languages with full audio support', '' -replace ', ', \"`r`n\"">languages.txt
	rem steam_settings - supported_languages.txt
	>"%GameName%\steam_settings\supported_languages.txt" (
		for /f "tokens=*" %%a in (languages.txt) do (
			if "%%a"=="Arabic" echo arabic
			if "%%a"=="Bulgarian" echo bulgarian
			if "%%a"=="Simplified Chinese" echo schinese
			if "%%a"=="Traditional Chinese" echo tchinese
			if "%%a"=="Czech" echo czech
			if "%%a"=="Danish" echo danish
			if "%%a"=="Dutch" echo dutch
			if "%%a"=="English" echo english
			if "%%a"=="Finnish" echo finnish
			if "%%a"=="French" echo french
			if "%%a"=="German" echo german
			if "%%a"=="Greek" echo greek
			if "%%a"=="Hungarian" echo hungarian
			if "%%a"=="Indonesian" echo indonesian
			if "%%a"=="Italian" echo italian
			if "%%a"=="Japanese" echo japanese
			if "%%a"=="Korean" echo koreana
			if "%%a"=="Norwegian" echo norwegian
			if "%%a"=="Polish" echo polish
			if "%%a"=="Portuguese - Portugal" echo portuguese
			if "%%a"=="Portuguese - Brazil" echo brazilian
			if "%%a"=="Romanian" echo romanian
			if "%%a"=="Russian" echo russian
			if "%%a"=="Spanish - Spain" echo spanish
			if "%%a"=="Spanish - Latin America" echo latam
			if "%%a"=="Swedish" echo swedish
			if "%%a"=="Thai" echo thai
			if "%%a"=="Turkish" echo turkish
			if "%%a"=="Ukrainian" echo ukrainian
			if "%%a"=="Vietnamese" echo vietnamese
		)
		del "languages.txt">NUL
	)
)
del "%GameAppID%.json">NUL
:: config user
for /f "tokens=1-9 delims=^=" %%a in ('mshta.exe "%HOME%Tools\GSE_user_configs.hta" "%GameName%\steam_settings\supported_languages.txt"') do set maybeinfuture=nil
:: steam_settings - configs.user.ini
if exist "configs.user.ini" move "configs.user.ini" "%GameName%\steam_settings\configs.user.ini">NUL
echo  [x] Done!
goto :EOF

:function_achievements
echo.
echo  [ ] Searching achievements . . .
:: Achievements language
for /f "tokens=*" %%a in ('mshta.exe "%HOME%Tools\GSE_achievements_language.hta" "%GameName%\steam_settings\supported_languages.txt"') do set AchievementsLanguage=%%a
if "%AchievementsLanguage%"=="ForceFix" (set AchLanguage=en) else (set AchLanguage=%AchievementsLanguage%)
:: get achievements from steam
Tools\CURL\curl.exe -s -H "Accept-Language: %AchLanguage%" -XGET "https://steamcommunity.com/stats/%GameAppID%/achievements/">steamachievements.html
powershell -Command "(gc -LiteralPath '%HOME%steamachievements.html') -replace '&apos;', \"'\" -replace '&amp;', '&' -replace '&quot;', 'lee.aspas' -replace '	', '' | Out-File -LiteralPath '%HOME%steamachievements.html' -NoNewline -encoding Default">NUL
powershell -Command "(gc -LiteralPath '%HOME%steamachievements.html') -replace 'images/apps/%GameAppID%/', \"`r`n^<ACHIEVEMENT^>^<\" -replace '(.jpg)(.*)(\"achievePercent\">)', '.jpg><' -replace '(</div>)(.*)(<h3>)', '><' -replace '</h3><h5>', '><' -replace '<</h5>.*', '< >' -replace '</h5>.*', '>' | Out-File -LiteralPath '%HOME%steamachievements.html' -encoding Default"
powershell -Command "(gc -LiteralPath '%HOME%steamachievements.html' | Select-Object -Skip 1) | Out-File -LiteralPath '%HOME%steamachievements.html' -encoding Default">NUL
:: get achievements from steamdb
Tools\CURL\curl.exe -s --config Tools/CURL/config/safari15_5.config --header @Tools/CURL/config/safari15_5.header --url "https://steamdb.info/app/%GameAppID%/stats/" -o steamdbachievements.html
powershell -Command "(gc -LiteralPath '%HOME%steamdbachievements.html') -replace '&apos;', \"'\" -replace '&amp;', '&' -replace '&quot;', 'lee.aspas' -replace '<tr id=""achievement-.+"">', \"`r`n^<ACHIEVEMENT^>\" | Out-File -LiteralPath '%HOME%steamdbachievements.html' -NoNewline -encoding Default">NUL
powershell -Command "(gc -LiteralPath '%HOME%steamdbachievements.html') -replace '<ACHIEVEMENT><td>', '<ACHIEVEMENT><' -replace '</td><td>', '><' -replace '<p class=\"i\">', '><' | Out-File -LiteralPath '%HOME%steamdbachievements.html' -encoding Default">NUL
powershell -Command "(gc -LiteralPath '%HOME%steamdbachievements.html') -replace '.jpg\" width.* data-name=\"', '.jpg><' -replace '<<svg width.* data-name=""', '<TRFOCULTO><' -replace '</p>><<.* data-name=""""', '><' -replace '.jpg"" width.*', '.jpg>' | Out-File -LiteralPath '%HOME%steamdbachievements.html' -encoding Default">NUL
powershell -Command "(gc -LiteralPath '%HOME%steamdbachievements.html' | Select-Object -Skip 1) | Out-File -LiteralPath '%HOME%steamdbachievements.html' -encoding Default">NUL

set /a total=0
for /f "tokens=1-9 delims=<>" %%1 in (steamdbachievements.html) do if "%%1"=="ACHIEVEMENT" set /a total+=1
if "%total%"=="0" (
	if exist "steamachievements.html" del "steamachievements.html">NUL
	if exist "steamdbachievements.html" del "steamdbachievements.html">NUL
	echo  [x] Done!
	goto :EOF
)
for /f %%a in ('powershell -Command "[Console]::CursorTop"') do set /a PROGRESSBACKTOLINE=%%a
setlocal enabledelayedexpansion
set NEW_ACHIEVEMENT=
set /a count=0
for /f "tokens=1-9 delims=<>" %%1 in (steamdbachievements.html) do (
	if "%%1"=="ACHIEVEMENT" (
		set LANG_description=
		set LANG_displayName=
		if "!count!"=="0" (
			if exist "%GameName%\steam_settings\achievements.json" del "%GameName%\steam_settings\achievements.json">NUL
			powershell -Command "Add-Content '[' -LiteralPath '%HOME%%GameName%\steam_settings\achievements.json' -encoding UTF8"
		)
		set "name=%%2"
		set "icon=%%5"
		set "icongray=%%6"
		rem get achievements name from steamdb
		set "ENG_achName=%%3"
		set "ENG_displayName=!ENG_achName:lee.aspas=\"!"
		set "ENG_achName=!ENG_achName:\/= /!"
		set "ENG_EchoachName=!ENG_achName:&=lee.and!"
		set "ENG_achdesc=%%4"
		echo !ENG_achdesc! | findstr /C:"TRFOCULTO" 1>nul
		if not errorlevel 1 (
			set hidden=1
			set ENG_achdesc=!ENG_achdesc:TRFOCULTO=!
		) else (
			set hidden=0
		)
		set "ENG_Echoachdesc=!ENG_achdesc:&=lee.and!"
		set "ENG_description=!ENG_achdesc:lee.aspas=\"!"
		set "ENG_achdesc=!ENG_achdesc:\/= /!"
		rem get achievements name from steam
		for /f "tokens=1-9 delims=<>" %%a in (steamachievements.html) do (
			if "%%b"=="!icon!" (
				set "globalstatistics=%%c%%"
				set "LANG_achName=%%d"
				set "LANG_displayName=!LANG_achName:lee.aspas=\"!"
				set "LANG_achName=!LANG_achName:\/= /!"
				set "LANG_EchoachName=!LANG_achName:&=lee.and!"
				set "LANG_achdesc=%%e"
				set "LANG_description=!LANG_achdesc:lee.aspas=\"!"
				set "LANG_achdesc=!LANG_achdesc:\/= /!"
				set "LANG_Echoachdesc=!LANG_achdesc:&=lee.and!"
			)
		)
		if "!LANG_description!"=="" set LANG_description=!ENG_description!
		if "!LANG_displayName!"=="" set LANG_displayName=!ENG_displayName!
		set /a count+=1
		call :function_progress " [90m[!count!/!total!] [94m!globalstatistics! [92m!ENG_EchoachName!"
		if "%AchievementsLanguage%"=="ForceFix" (set "displayName=!ENG_displayName!"&set "description=!ENG_description!") else (set "displayName=!LANG_displayName!"&set "description=!LANG_description!")
		>>"%GameName%\steam_settings\achievements.json" (
			echo 	{
			echo 		"description": "!description!",
			echo 		"displayName": "!displayName!",
			echo 		"hidden": !hidden!,
			echo 		"icon": "images/!icon!",
			echo 		"icongray": "images/!icongray!",
			echo 		"name": "!name!"
		)
		if not exist "%GameName%\steam_settings\images" mkdir "%GameName%\steam_settings\images">NUL
		if not exist "%GameName%\steam_settings\images\!icon!" Tools\CURL\curl.exe -s "https://cdn.akamai.steamstatic.com/steamcommunity/public/images/apps/%GameAppID%/!icon!" -o "!icon!"&move "!icon!" "%GameName%\steam_settings\images\">NUL
		if not exist "%GameName%\steam_settings\images\!icongray!" Tools\CURL\curl.exe -s "https://cdn.akamai.steamstatic.com/steamcommunity/public/images/apps/%GameAppID%/!icongray!" -o "!icongray!"&move "!icongray!" "%GameName%\steam_settings\images\">NUL
		if "!count!"=="!total!" (echo 	}>>"%GameName%\steam_settings\achievements.json") else (echo 	},>>"%GameName%\steam_settings\achievements.json") 
	)
)
endlocal
if exist "%GameName%\steam_settings\achievements.json" echo ]>>"%GameName%\steam_settings\achievements.json"
if not exist "%GameName%\steam_settings\images\*.jpg" rmdir /s /q "%GameName%\steam_settings\images">NUL
if exist "steamachievements.html" del "steamachievements.html">NUL
if exist "steamdbachievements.html" del "steamdbachievements.html">NUL

:: steam_settings configs.overlay.ini
if exist "%GameName%\steam_settings\achievements.json" (
	if exist "Tools\ACHIVEMENTS\configs.overlay.ini" (
		if exist "Tools\ACHIVEMENTS\fonts\*.ttf" (
			if not exist "%GameName%\steam_settings\fonts" mkdir "%GameName%\steam_settings\fonts">NUL
			start /wait call "Tools\FontsSelector.bat"
			for /f "tokens=1-2 delims=^= eol=#" %%1 in (Tools\ACHIVEMENTS\configs.overlay.ini) do if "%%1"=="Font_Override" copy "Tools\ACHIVEMENTS\fonts\%%2" "%GameName%\steam_settings\fonts\">NUL
		)
		copy "Tools\ACHIVEMENTS\configs.overlay.ini" "%GameName%\steam_settings\">NUL
	) else (
		>"%GameName%\steam_settings\configs.overlay.ini" (
			echo [overlay::general]
			echo enable_experimental_overlay=1
			echo.
			echo [overlay::appearance]
			echo Notification_Rounding=10.0
			echo Notification_Margin_x=5.0
			echo Notification_Margin_y=5.0
			echo Notification_Animation=0.35
			echo PosAchievement=bot_right
		)
	)
	if not exist "%GameName%\steam_settings\sounds\" if exist "Tools\ACHIVEMENTS\sounds" xcopy /e "Tools\ACHIVEMENTS\sounds" "%GameName%\steam_settings\sounds\">NUL
)
call :function_progress "[x] Done!"
echo.
goto :EOF

:function_progress
set "text=%1"
set "text=%text:lee.aspas="%"
set "text=%text:lee.and=^^^&%"
powershell -Command "[Console]::CursorTop=%PROGRESSBACKTOLINE%"&echo                                                                                                                         
powershell -Command "[Console]::CursorTop=%PROGRESSBACKTOLINE%"&echo  %text:~1,-1%[0m                                                                                                                        
powershell -Command "[Console]::CursorTop=%PROGRESSBACKTOLINE%"
goto :EOF

:function_script_toast
rem chcp 65001>NUL
for /f "tokens=*" %%a in ('powershell -Command "(gc -LiteralPath '%HOME%Tools\ACHIVEMENTS\achievements.json' | ConvertFrom-Json).%TOASTNAME%.earned"') do set "AchivementEarned=%%a"
if "%AchivementEarned%"=="False" (
	rem chcp 1252>NUL
	for /f "tokens=*" %%a in ('powershell -Command "(gc -LiteralPath '%HOME%Tools\ACHIVEMENTS\achievements.json' | ConvertFrom-Json).%TOASTNAME%.displayName"') do set "AchivementName=%%a"
	for /f "tokens=*" %%a in ('powershell -Command "(gc -LiteralPath '%HOME%Tools\ACHIVEMENTS\achievements.json' | ConvertFrom-Json).%TOASTNAME%.description"') do set "AchivementDescription=%%a"
	for /f "tokens=*" %%a in ('powershell -Command "(gc -LiteralPath '%HOME%Tools\ACHIVEMENTS\achievements.json' | ConvertFrom-Json).%TOASTNAME%.icon"') do set "AchivementImage=%HOME%Tools\ACHIVEMENTS\%%a"
	call :function_achivement_toast
	powershell -Command "$json = gc -LiteralPath '%HOME%Tools\ACHIVEMENTS\achievements.json' | ConvertFrom-Json; $json.%TOASTNAME%.earned = $true; $json | ConvertTo-Json | Out-File -LiteralPath '%HOME%Tools\ACHIVEMENTS\achievements.json' -encoding Default"
	powershell -Command "(gc -LiteralPath '%HOME%Tools\ACHIVEMENTS\achievements.json') -replace '                           ', '		' -replace '                       ', '	' -replace '    ', '	' -replace '  ', ' ' | Out-File -LiteralPath '%HOME%Tools\ACHIVEMENTS\achievements.json' -encoding Default"
)
goto :EOF

:function_test_achievements_file
echo.
echo  [ ] Showing achievements . . .
rem chcp 65001>NUL
set /a total=0
for /f "tokens=1-9 delims=	: usebackq" %%a in ("%FileDir%achievements.json") do if "%%a"==""name"" (set /a total+=1)
setlocal enabledelayedexpansion
set /a count=0
for /f "tokens=1-9 delims=	: usebackq" %%a in ("%FileDir%achievements.json") do (
	if "%%a"==""description"" (
		set "AchivementDescription=%%b"
		set "AchivementDescription=!AchivementDescription:~2,-2!"
	)
	if "%%a"==""displayName"" (
		set "AchivementName=%%b"
		set "AchivementName=!AchivementName:~2,-2!"
	)
	if "%%a"==""icon"" (
		set "AchivementImage=%%b"
		set "AchivementImage=!AchivementImage:~2,-2!"
		set "AchivementImage=%FileDir%!AchivementImage:/=\!"
		set /a count+=1
		echo    Show achievement [!count!/%total%]
		call :function_achivement_toast
	)
)
echo  [x] Done!
endlocal
:: script achievement 
set TOASTNAME=ACHIEVEMENT_04&call :function_script_toast
goto :EOF

:function_achivement_toast
:: .png for round corners | .jpg for rect corners
set Background=bg.png
:: tot_right | bot_right
set Position=bot_right
set Margin_x=10
set Margin_y=10
set Timeout=3
if not exist "%AchivementImage%" set "AchivementImage=Tools\ACHIVEMENTS\images\null.png
powershell -Command^
	Add-Type -AssemblyName System.Windows.Forms;^
	Add-Type -AssemblyName System.Drawing;^
	$monitor = [System.Windows.Forms.Screen]::AllScreens;^
	$bgimg = [System.Drawing.Image]::Fromfile('Tools\ACHIVEMENTS\images\%Background%');^
	$img = [System.Drawing.Image]::Fromfile(\"%AchivementImage%\");^
	$sound = New-Object System.Media.SoundPlayer;^
	$sound.SoundLocation = 'Tools\ACHIVEMENTS\sounds\overlay_achievement_notification.wav';^
	$sound.Play();^
	$form = New-Object system.Windows.Forms.Form;^
	$form.TopMost = $true;^
	$form.StartPosition = 0;^
	$form.FormBorderStyle = 0;^
	$form.BackgroundImage = $bgimg;^
	$form.BackgroundImageLayout = 'Stretch';^
	$form.AllowTransparency = $true;^
	$form.TransparencyKey = $form.BackColor;^
	$form.Width = 500;^
	$form.Height = 128;^
	if ($monitor.WorkingArea.x -eq 0) {^
		$top_right_x = $monitor.WorkingArea.Width-$form.Width-%Margin_x%;^
		$tot_right_y = %Margin_y%;^
		$tot_right =  $top_right_x, $tot_right_y;^
		$bot_right_x = $monitor.WorkingArea.Width-$form.Width-%Margin_x%;^
		$bot_right_y = $monitor.WorkingArea.Height-$form.Height-%Margin_y%;^
		$bot_right = $bot_right_x, $bot_right_y;^
	} else {^
		$%Position% = 0, 0;^
	};^
	$form.Location = New-object System.Drawing.Size($%Position%);^
	$form.Show();^
	$Picture = New-Object Windows.Forms.PictureBox -Property @{^
		Location	= New-Object Drawing.Point 32, 30;^
		Size		= New-Object Drawing.Size 64, 64;^
		Image		= $img;^
		SizeMode	= 'StretchImage';^
		BackColor	= '#00000000';^
	};^
	$form.Controls.Add($Picture);^
	$NameLabel = New-Object Windows.Forms.Label -Property @{^
		Location	= New-Object Drawing.Point(120, 25);^
		Size		= New-Object Drawing.Size(355, 43);^
		Text		= '%AchivementName%';^
		Font		= 'Arial, 14';^
		ForeColor	= '#dddddd';^
		BackColor	= '#00000000';^
	};^
	$form.Controls.Add($NameLabel);^
	$DescriptionLabel = New-Object Windows.Forms.Label -Property @{^
		Location	= New-Object Drawing.Point(120, 70);^
		Size		= New-Object Drawing.Size(355, 50);^
		Text		= '%AchivementDescription%';^
		Font		= 'Arial, 10';^
		ForeColor	= '#aaaaaa';^
		BackColor	= '#00000000';^
	};^
	$form.Controls.Add($DescriptionLabel);^
	Start-Sleep -Seconds %Timeout%;^
	$form.Close();^
	$form.Dispose();
goto :EOF

:function_open_file_context
for /f "tokens=*" %%a in ('powershell "Add-Type -AssemblyName System.windows.forms | Out-Null;$f=New-Object System.Windows.Forms.OpenFileDialog;$f.InitialDirectory='%cd%';$f.FileName='';$f.Filter='%WantedName% (*%WantedExtension%) | *%WantedExtension%';$f.showHelp=$false;$f.ShowDialog()|Out-Null;$f.FileName"') do set "FileDir=%%~dpa"&set "FileName=%%~nxa"
if "%FileDir%"=="" echo c=msgbox("If it is more convenient:"+vbNewLine+"Drag-and-drop the %WantedName% file into the "+chr(34)+"GSE_Generator.bat"+chr(34)+" file!",vbInformation,"INFO")>Info.vbs&Info.vbs&del Info.vbs>NUL&goto END
goto :EOF

:function_steam_api_file
for /f "tokens=1-9" %%1 in ('Tools\7z\7z.exe l "%FileDir%%FileName%"') do (
	if "%%1"=="Type" if "%%3"=="PE" set FType=OK
	if "%%1"=="Name" if "%%3"=="steam_api.dll" set FName=OK
	if "%%1"=="CPU" (
		if "%%3"=="x86" set apiBits=x32&set apiName=steam_api
		if "%%3"=="x64" set apiBits=x64&set apiName=steam_api64
	)
)
set APIConfirm=%FType%;%FName%
if "%APIConfirm%"=="OK;OK" goto %GOTO%
goto :EOF

:function_steam_interfaces
echo.
echo  [ ] Searching interfaces . . .
if exist "steam_interfaces.txt" del "steam_interfaces.txt">NUL
rem powershell -Command "(gc -LiteralPath '%FileDir%%FileName%') -creplace 'Steam', \"`r`nSteam\" -creplace 'STEAM', \"`r`nSTEAM\" | Select-String 'Steam.*[0-9]{3}' -AllMatches | ForEach-Object{$_.Matches.Value}">steam_interfaces.txt
powershell -Command "gc -LiteralPath \"%FileDir%%FileName%\" | Select-String 'SteamClient[0-9]{3}|SteamGameServerStats[0-9]{3}|SteamGameServer[0-9]{3}|SteamMatchMakingServers[0-9]{3}|SteamMatchMaking[0-9]{3}|SteamUser[0-9]{3}|SteamFriends[0-9]{3}|SteamUtils[0-9]{3}|STEAMUSERSTATS_INTERFACE_VERSION[0-9]{3}|STEAMAPPS_INTERFACE_VERSION[0-9]{3}|SteamNetworking[0-9]{3}|STEAMREMOTESTORAGE_INTERFACE_VERSION[0-9]{3}|STEAMSCREENSHOTS_INTERFACE_VERSION[0-9]{3}|STEAMHTTP_INTERFACE_VERSION[0-9]{3}|STEAMUNIFIEDMESSAGES_INTERFACE_VERSION[0-9]{3}|STEAMCONTROLLER_INTERFACE_VERSION[0-9]{3}|SteamController[0-9]{3}|STEAMUGC_INTERFACE_VERSION[0-9]{3}|STEAMAPPLIST_INTERFACE_VERSION[0-9]{3}|STEAMMUSIC_INTERFACE_VERSION[0-9]{3}|STEAMMUSICREMOTE_INTERFACE_VERSION[0-9]{3}|STEAMHTMLSURFACE_INTERFACE_VERSION_[0-9]{3}|STEAMINVENTORY_INTERFACE_V[0-9]{3}|STEAMVIDEO_INTERFACE_V[0-9]{3}|SteamMasterServerUpdater[0-9]{3}' -AllMatches | ForEach-Object{$_.Matches.Value} | Sort -unique">steam_interfaces.txt
for /f "tokens=1-9 delims= " %%1 in ('find /C "SteamUser0" "steam_interfaces.txt"') do set SteamUserCount=%%3
if "%SteamUserCount%"=="1" (
	rem script achievement 
	set TOASTNAME=ACHIEVEMENT_05&call :function_script_toast
	echo  [x] Done!
) else (
	del "steam_interfaces.txt">NUL
	echo c=msgbox("MUST BE A ORIGINAL API FILE",vbCritical,"%TITLE%"^)>Info.vbs&Info.vbs&del Info.vbs>NUL
	echo  [x] Done!
	goto END
)
goto :EOF

:function_goldberg_emulator_fork
:: INCONSISTENT STEAM API
if not "%FileName%"=="%apiName%.dll" (
	if "%FileName%"=="steam_api.dll" (
		echo c=MsgBox("The steam api filename is 'steam_api.dll' but has been verified as being 64-bit"+vbNewline+vbNewLine+"Press YES: Continue with 64-bits"+vbNewline+"Press NO: Continue with 32-bits", vbInformation+vbYesNo+vbDefaultButton1, "INCONSISTENT STEAMAPI"^): Wscript.echo(c^)>InconsistentAPI.vbs
	)
	if "%FileName%"=="steam_api64.dll" (
		echo c=MsgBox("The steam api filename is 'steam_api64.dll' but has been verified as being 32-bit"+vbNewline+vbNewLine+"Press YES: Continue with 32-bits"+vbNewline+"Press NO: Continue with 64-bits", vbInformation+vbYesNo+vbDefaultButton1, "INCONSISTENT STEAMAPI"^): Wscript.echo(c^)>InconsistentAPI.vbs
	)
)
set API_ANSWER=
set ChangeNameBits=
if exist "InconsistentAPI.vbs" for /f "tokens=*" %%a in ('cscript InconsistentAPI.vbs') do set API_ANSWER=%%a
if exist "InconsistentAPI.vbs" del InconsistentAPI.vbs>NUL
if defined API_ANSWER (
	rem API_AWSER=YES - prioritize detected bits
	if "%API_ANSWER%"=="6" (
		rem was detected 32bits - filename is from 64bits
		if "%apiName%"=="steam_api" set ChangeNameBits=yes&set Optapi=64
		rem was detected 64bits - filename is from 32bits
		if "%apiName%"=="steam_api64" set ChangeNameBits=yes&set Optapi=32
	)
	rem API_AWSER=NO - prioritize filename
	if "%API_ANSWER%"=="7" (
		rem was detected 32bits - filename is from 64bits
		if "%apiName%"=="steam_api" set apiBits=x64&set apiName=steam_api64&set Optapi=32
		rem was detected 64bits - filename is from 32bits
		if "%apiName%"=="steam_api64" set apiBits=x32&set apiName=steam_api&set Optapi=64
	)
)

echo.
echo  [ ] Searching emulator . . .
::get info from github gbe_fork
Tools\CURL\curl.exe -s "https://api.github.com/repos/Detanup01/gbe_fork/releases/latest" -o "gbe.json"
for /f "tokens=*" %%a in ('powershell -Command "(gc -LiteralPath '%HOME%gbe.json' | ConvertFrom-Json).name"') do set gberelease=%%a
for /f "tokens=*" %%a in ('powershell -Command "$json = (gc -LiteralPath '%HOME%gbe.json') | ConvertFrom-Json; $json.PSobject.Properties.value.name"') do echo %%a | findstr /C:"emu-win-release" 1>nul & if not errorlevel 1 set gbefile=%%a
del "gbe.json">NUL
if defined gberelease set latest=%gberelease%%gbefile:emu-win-release=%

if defined latest (
	rem download last version from github
	if not exist "Tools\GoldbergSteamEmulator\%latest%" (
		if not exist "Tools\GoldbergSteamEmulator" mkdir "Tools\GoldbergSteamEmulator">NUL
		if exist "Tools\GoldbergSteamEmulator\*" del /Q "Tools\GoldbergSteamEmulator\*">NUL
		Tools\CURL\curl.exe -s -L "https://github.com/Detanup01/gbe_fork/releases/latest/download/%gbefile%" -o "Tools\GoldbergSteamEmulator\%latest%"
	)
	rem allready have last version
	if exist "Tools\GoldbergSteamEmulator\%latest%" (
		rem script achievement 
		set TOASTNAME=ACHIEVEMENT_06&call :function_script_toast
		if "%FileDir%%FileName%"=="%HOME%%FileName%" (
			move "%FileName%" "%apiName%_o.dll">NUL
		) else (
			copy "%FileDir%%FileName%" "%apiName%_o.dll">NUL
		)
		Tools\7z\7z.exe e -y "Tools\GoldbergSteamEmulator\%latest%" "release\experimental\%apiBits%\%apiName%.dll">NUL
	)
)
if not defined latest (
	if not exist "Tools\GoldbergSteamEmulator" mkdir "Tools\GoldbergSteamEmulator">NUL
	Tools\CURL\curl.exe -s -L "https://github.com/brunolee-GIT/GSE-Generator/releases/download/backup/backup.7z" -o "Tools\GoldbergSteamEmulator\backup.7z"
	if exist "Tools\GoldbergSteamEmulator\backup.7z" (
		if "%FileDir%%FileName%"=="%HOME%%FileName%" (
			move "%FileName%" "%apiName%_o.dll">NUL
		) else (
			copy "%FileDir%%FileName%" "%apiName%_o.dll">NUL
		)
		Tools\7z\7z.exe e -y "Tools\GoldbergSteamEmulator\backup.7z" "release\experimental\%apiBits%\%apiName%.dll">NUL
	)
)
:: change API file name if different and priority bits are detected
if defined ChangeNameBits (
	if "%apiName%"=="steam_api" move "%apiName%.dll" "steam_api64.dll">NUL&move "%apiName%_o.dll" "steam_api64_o.dll">NUL
	if "%apiName%"=="steam_api64" move "%apiName%.dll" "steam_api.dll">NUL&move "%apiName%_o.dll" "steam_api_o.dll">NUL
)
if defined API_ANSWER echo c=msgbox("If doesn't work, you need the api %Optapi%-bit version",vbExclamation,"INCONSISTENT STEAMAPI INFORMATION"^)>Info.vbs&Info.vbs&del Info.vbs>NUL
echo  [x] Done!
goto :EOF

:function_help
echo.
echo  [0;7m ALGUMENTS [0m
echo.
echo     USAGE ON CMD: [92mGSSGenerator [90m[[93malgument[90m][0m
echo.
echo     [94malguments:[0m
echo        [93m-help[0;90m or [93m-h[90m ------------------------------- Show this help.
echo        [93m-toast[0;90m or [93m-t[90m ------------------------------ Test achievements.
echo        [93m-interfaces[0;90m or [93m-i[90m ------------------------- Generate steam_interfaces.txt file.
echo        [93m-emulator[0;90m or [93m-e[90m --------------------------- Download last Goldberg Steam emulator.
echo        [93m--ie[90m -------------------------------------- Will do the [93m-i[90m and [93m-e[90m alguments.
echo.
echo.
echo.
echo.
echo  [0;7m DRAG-AND-DROP [0m
echo.
echo     Drag-and-Drop files on [92mGSSGenerator[90m:
echo.
echo     [94mfiles:[0m
echo        [93machievements.json[0;90m ------------------------- Will do the same as -toast or -t alguments.
echo        [97moriginal [93msteam_api[0;90m file ------------------- Will do the same as [93m--ie[90m algument.[0m
echo.
echo.
:: script achievement 
set TOASTNAME=ACHIEVEMENT_02&call :function_script_toast
pause
goto :EOF
