@echo off
goto :main

:log
	>>"servers.log" echo [%date%] [%time%] %~1
	exit /b 0

:start
	title %serverName%
	call :log "Starting %serverName% (%serverGroup%)"

	robocopy "%USERPROFILE%\Minecraft\Jars" "%cwd%\plugins" "%plugin%" > nul
	robocopy "%USERPROFILE%\Minecraft\Jars\cache" "%cwd%\cache" > nul

	if "%worldEdit%"=="true" robocopy "%USERPROFILE%\Minecraft\Jars" "%cwd%\plugins" "WorldEdit.jar" > nul

	robocopy "%USERPROFILE%\Minecraft\Jars" "%cwd%\plugins" "ViaVersion.jar" > nul
	robocopy "%USERPROFILE%\Minecraft\Jars\ViaVersion" "%cwd%\plugins\ViaVersion" > nul

	>"%cwd%\eula.txt" echo eula=true

	>"%cwd%\server.properties" echo # Hexuscraft server.properties
	>>"%cwd%\server.properties" echo allow-flight=true
	>>"%cwd%\server.properties" echo allow-nether=false
	>>"%cwd%\server.properties" echo announce-player-achievements=false
	>>"%cwd%\server.properties" echo force-gamemode=true
	>>"%cwd%\server.properties" echo gamemode=2
	>>"%cwd%\server.properties" echo motd=
	:: --online-mode start-up flag does not work. We must use the server.properties setting.
	>>"%cwd%\server.properties" echo online-mode=false
	>>"%cwd%\server.properties" echo snooper-enabled=false
	>>"%cwd%\server.properties" echo spawn-protection=0
	>>"%cwd%\server.properties" echo view-distance=32
	
	>"%cwd%\bukkit.yml" echo # Hexuscraft bukkit.yml
	>>"%cwd%\bukkit.yml" echo settings:
	>>"%cwd%\bukkit.yml" echo   allow-end: false
	>>"%cwd%\bukkit.yml" echo   connection-throttle: 0
	>>"%cwd%\bukkit.yml" echo   query-plugins: false

	>"%cwd%\commands.yml" echo # Hexuscraft commands.yml
	>>"%cwd%\commands.yml" echo aliases: []

	>"%cwd%\spigot.yml" echo # Hexuscraft spigot.yml
	>>"%cwd%\spigot.yml" echo settings:
	>>"%cwd%\spigot.yml" echo   bungeecord: true
	>>"%cwd%\spigot.yml" echo commands:
	>>"%cwd%\spigot.yml" echo   spam-exclusions: []
	>>"%cwd%\spigot.yml" echo timings:
	>>"%cwd%\spigot.yml" echo   enabled: false
	>>"%cwd%\spigot.yml" echo messages:
	>>"%cwd%\spigot.yml" echo   whitelist: "&c&lYou are not whitelisted&r\n&fMaybe try again later?&r"
	>>"%cwd%\spigot.yml" echo   unknown-command: "&9Command Center>&r &7Unknown command. Type&r &e/help&r &7for help."
	>>"%cwd%\spigot.yml" echo   server-full: "&c&lThis server is full&r\n&fMaybe try again later?&r"
	>>"%cwd%\spigot.yml" echo   outdated-client: "&c&lUnsupported game version&r\n&fPlease use Minecraft 1.8&r"
	>>"%cwd%\spigot.yml" echo   outdated-server: "&c&lUnsupported game version&r\n&fPlease use Minecraft 1.8&r"
	>>"%cwd%\spigot.yml" echo world-settings:
	>>"%cwd%\spigot.yml" echo   default:
	>>"%cwd%\spigot.yml" echo     verbose: false
	if "%disableStats%"=="true" (
		>>"%cwd%\spigot.yml" echo stats:
		>>"%cwd%\spigot.yml" echo   disable-saving: true
		>>"%cwd%\spigot.yml" echo   forced-stats:
		>>"%cwd%\spigot.yml" echo     achievement.openInventory: 1
	)

	>"%cwd%\_name.dat" echo %serverName%
	>"%cwd%\_group.dat" echo %serverGroup%
	robocopy "%USERPROFILE%\Minecraft" "%cwd%" "_redis.dat" > nul

	:: --online-mode start-up flag does not work. We must use the server.properties setting.
	start "%serverName%" /D "%cwd%" java -Xms%ram%M -Xmx%ram%M -jar "%USERPROFILE%/Minecraft/Jars/paper.jar" --universe "universe" --host "127.0.0.1" --port "%port%" --max-players "%capacity%"
	call :log "Started %serverName% (%serverGroup%)"

	echo Success
	exit /b 0

:setup_basic
	rmdir /S /Q "%cwd%" > nul
	mkdir "%cwd%"
	mkdir "%cwd%\plugins"
	mkdir "%cwd%\cache"
	mkdir "%cwd%\universe"
	mkdir "%cwd%\universe\world"
	cd "%cwd%"

	powershell Expand-Archive "%USERPROFILE%\Minecraft\Worlds\%worldZip%" -DestinationPath "%cwd%\universe\world"

	set disableStats=true

	exit /b 0

:setup_webtranslator
	call :setup_basic
	if "%errorlevel%"=="1" exit /b 1

	robocopy "%USERPROFILE%\Minecraft\Jars" "%cwd%\plugins" "Tebex.jar" > nul
	robocopy "%USERPROFILE%\Minecraft\Jars\Tebex" "%cwd%\plugins\Tebex" > nul

	robocopy "%USERPROFILE%\Minecraft\Jars" "%cwd%\plugins" "NuVotifier.jar" > nul
	robocopy "%USERPROFILE%\Minecraft\Jars\Votifier" "%cwd%\plugins\Votifier" > nul

	exit /b 0

:setup_clans
	if not exist "%cwd%" (
		call :log "FATAL: Clans server %serverName% does not exist"
		echo UNKNOWN_CLANS
		exit /b 1
	)
	exit /b 0

:main
	set serverName=%1
	set serverGroup=%2
	set port=%3
	set ram=%4
	set capacity=%5
	set plugin=%6
	set worldZip=%7
	set worldEdit=%8

	if "%worldEdit%"=="" (
		call :log "Could not start %serverName% (%serverGroup%) as it does not have enough start parameters."
		echo Failure
		exit
	)

	call :log "Starting %serverName% (Group: %serverGroup%) (Port: %port%) (Ram: %ram% MB) (Capacity: %capacity%) (Plugin: %plugin%) (World: %worldZip%) (WorldEdit: %addWorldEdit%)"

	:: We run "taskkill" twice as ServerMonitor *could* attempt to start the same server while it's already running.
	:: To be clear: this should not happen, but this is a fallback just in-case it does.
	taskkill /f /fi "WINDOWTITLE eq %serverName%"
	taskkill /f /fi "WINDOWTITLE eq %serverName%"

	set cwd=%USERPROFILE%\Minecraft\Servers\%serverName%
	if "%serverGroup%"=="Clans" (
		call :setup_clans
		if "%errorlevel%"=="1" exit /b 1
	) else if "%serverGroup%"=="WebTranslator" (
		call :setup_webtranslator
		if "%errorlevel%"=="1" exit /b 1
	) else (
		call :setup_basic
		if "%errorlevel%"=="1" exit /b 1
	)
	
	call :start
	exit /b %errorlevel%
