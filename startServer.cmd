@echo off
goto :main

:log
	>>"startServer.log" echo [%date%] [%time%] %~1
	exit /b 0

:start
	call :log "Creating %serverName% (%serverGroup%)"

	robocopy "%USERPROFILE%\Minecraft\Jars" "%cwd%\plugins" "%plugin%" > nul
	robocopy "%USERPROFILE%\Minecraft\Jars\cache" "%cwd%\cache" > nul

	if "%serverGroup%"=="DEBUG" >"%cwd%\_debug.dat" echo.
	if "%worldEdit%"=="true" robocopy "%USERPROFILE%\Minecraft\Jars" "%cwd%\plugins" "WorldEdit.jar" > nul

	robocopy "%USERPROFILE%\Minecraft\Jars" "%cwd%\plugins" "ViaVersion.jar" > nul
	mkdir "%cwd%\plugins\ViaVersion"
	>"%cwd%\plugins\ViaVersion\config.yml" echo # Hexuscraft ViaVersion config.yml
	>>"%cwd%\plugins\ViaVersion\config.yml" echo check-for-updates: false
	
	>"%cwd%\eula.txt" echo eula=true

	>"%cwd%\server.properties" echo # Hexuscraft server.properties
	>>"%cwd%\server.properties" echo allow-flight=true
	>>"%cwd%\server.properties" echo allow-nether=false
	>>"%cwd%\server.properties" echo announce-player-achievements=false
	>>"%cwd%\server.properties" echo force-gamemode=true
	>>"%cwd%\server.properties" echo gamemode=2
	>>"%cwd%\server.properties" echo max-players=%capacity%
	>>"%cwd%\server.properties" echo motd=
	>>"%cwd%\server.properties" echo online-mode=false
	>>"%cwd%\server.properties" echo server-ip=%privateAddress%
	>>"%cwd%\server.properties" echo server-port=%port%
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

	>"%cwd%\_group.dat" echo %serverGroup%
	>"%cwd%\_name.dat" echo %serverName%

	>"%cwd%\_redis.dat" echo 127.0.0.1
	>>"%cwd%\_redis.dat" echo 6379

	call :log "Starting %serverName% (%serverGroup%)"
::	start "%serverName%" /D "%cwd%" java -Xms%ram%M -Xmx%ram%M -jar "%USERPROFILE%/Minecraft/Jars/paper.jar" --universe "universe" --nojline --host "%privateAddress%" --port "%port%" --online-mode "false" --max-players "%capacity%" --log-append "false"
	start "%serverName%" /D "%cwd%" java -Xmx4G -jar "%USERPROFILE%/Minecraft/Jars/paper.jar" --universe "universe" --nojline --host "%privateAddress%" --port "%port%" --online-mode "false" --max-players "%capacity%" --log-append "false"

	echo Success
	exit /B 0

:start_basic
	rmdir /S /Q "%cwd%" > nul
	mkdir "%cwd%"
	cd "%cwd%"

	mkdir "%cwd%\plugins"
	mkdir "%cwd%\cache"
	mkdir "%cwd%\universe"
	mkdir "%cwd%\universe\world"

	powershell Expand-Archive "%USERPROFILE%\Minecraft\Worlds\%worldZip%" -DestinationPath "%cwd%\universe\world"

	set disableStats=true
	goto :start

:start_clans
	if not exist "%cwd%" (
		call :log "Could not start %serverName% (%serverGroup%) as it does not exist."
		echo Failure
		exit
	)
	goto :start

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

	call :log "Creating %serverName% (%serverGroup%) (Port: %port%) (Ram: %ram% MB) (Capacity: %capacity%) (Plugin: %plugin%) (World: %worldZip%) (WorldEdit: %addWorldEdit%)"

	set cwd=%USERPROFILE%\Minecraft\Servers\%serverName%
	if "%serverGroup%"=="Clans" (
		call :start_clans
	) ELSE (
		call :start_basic
	)
	exit /B 0
