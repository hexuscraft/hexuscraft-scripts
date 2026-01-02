@echo off
goto :main

:log
	>>"servers.log" echo [%date%] [%time%] %~1
	exit /b 0

:destroy
	if "%serverGroup%"=="Clans" (
		exit /b 0
	)
	if "%serverGroup%"=="Build" (
		exit /b 0
	)
	rmdir /S /Q "%USERPROFILE%\Minecraft\Servers\%serverName%" > nul
	exit /b 0

:main
	set serverName=%1
	set serverGroup=%2
	call :log "Killing %serverName% (%serverGroup%)"

	:: We run "taskkill" twice as ServerMonitor *could* attempt to start the same server while it's already running.
	:: To be clear: this should not happen, but this is a fallback just in-case it does.
	taskkill /f /fi "WINDOWTITLE eq %serverName%"
	taskkill /f /fi "WINDOWTITLE eq %serverName%"

	call :destroy

	call :log "Killed %serverName%"
	exit /b 0
