@echo off
mode con cols=30 lines=10&color 9f&cls
set "dir=%LocalAppData%\Imageio"
set "tmp=%temp%\yanderify-tmp"
if not exist "%dir%" (md "%dir%")
if not exist "%tmp%" (md "%tmp%")
if not exist "%dir%\Ffmpeg" (md "%dir%\Ffmpeg")

:: 菜单区
echo.
echo 1）安装
echo.
echo 2）卸载
echo.
echo ---------------
set /p choice=你的选择是：
if "%choice%"=="1" (
	mode con cols=85 lines=40&color 9f&cls
    goto :install
) else if "%choice%"=="2" (
    goto :uninstall
) else (
    echo 无效的选择。
    pause
	exit 1
)

:install
:: 检测是否安装了 Python
py --version >nul 2>nul
if %errorlevel% neq 0 (
    echo Python未安装，尝试安装...
    if exist "%tmp%\python.exe" (
        %tmp%\python.exe /quiet InstallAllUsers=1 PrependPath=1
    ) else (
        curl -o "%tmp%\python.exe" https://www.python.org/ftp/python/3.12.3/python-3.12.3-amd64.exe
        %tmp%\python.exe /quiet InstallAllUsers=1 PrependPath=1
    )
    py --version >nul 2>nul
    if %errorlevel% neq 0 (
        echo Python安装失败...&& pause 
        exit /b 1
    )
) else (
    echo Python已安装！
)

:: yanderify本体下载
:: 检查 yanderify.exe 是否存在
if exist "%dir%\yanderify\yanderify.exe" (
    echo yanderify已存在！无需下载。
) else (
    :: 检查临时文件夹中是否有yanderify.zip
    if not exist "%tmp%\yanderify.zip" (
        echo 正在下载yanderify本体...
        curl -o "%tmp%\yanderify.zip" https://gh.ddlc.top/https://github.com/dunnousername/yanderifier/releases/download/v4.0.3-stable/yanderify.zip
        if %errorlevel% neq 0 (echo yanderify下载失败... && rm "%tmp%\yanderify.zip" && pause && exit 1
        )
    )
    echo 正在解压yanderify本体...  
    powershell -command Expand-Archive -Path %tmp%\yanderify.zip -DestinationPath %dir%
	if exist "%dir%\yanderify\yanderify.exe" (
        echo yanderify解压完毕！
    ) else (
        echo yanderify解压失败！
        del "%tmp%\yanderify.zip"
        pause
        exit 1
    )
)



:: checkpoint.tar模型下载
if exist "%dir%\yanderify\checkpoint.tar" (
	echo 模型存在！无需下载
) else (
	echo 正在下载模型......
	curl -o %dir%\yanderify\checkpoint.tar https://gh.ddlc.top/https://github.com/dunnousername/yanderifier/releases/download/model/checkpoint.tar
	if %errorlevel% == 0 (echo checkpoint.tar下载完毕!) else (echo checkpoint.tar下载失败！&& pause && exit 1)
)

:: ffmpeg下载
if exist "%dir%\Ffmpeg\ffmpeg-win32-v3.2.4.exe" (
	echo ffmpeg存在！无需下载
) else (
	echo 正在下载ffmpeg.....
	curl -o  %tmp%\ffmpeg.zip https://gh.ddlc.top/https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip
		if %errorlevel% neq 0 (echo ffmpeg下载失败！&& pause && exit 1)
			powershell -command Expand-Archive -Path %tmp%\ffmpeg.zip -DestinationPath %tmp%
	       	if exist %tmp%\ffmpeg-master-latest-win64-gpl\bin\ffmpeg.exe (
	       		copy %tmp%\ffmpeg-master-latest-win64-gpl\bin\ffmpeg.exe %dir%\Ffmpeg\ffmpeg-win32-v3.2.4.exe
				echo ffmpeg解压完毕！
			) else (
				echo ffmpeg解压失败！
				del "%tmp%\ffmpeg.zip"
				echo 尝试自带ffmpeg
				copy %dir%\yanderify\ffmpeg.exe %dir%\Ffmpeg\ffmpeg-win32-v3.2.4.exe
				if not exist %dir%\Ffmpeg\ffmpeg-win32-v3.2.4.exe (echo 方案失败 && pause && exit 1)
			)
)

:: 创建桌面图标
set "target=%dir%\yanderify\yanderify.exe"
set "workingDirectory=%dir%\yanderify\"
set "shortcutName=Yanderify"
powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%userprofile%\Desktop\%shortcutName%.lnk');$s.TargetPath='%target%';$s.WorkingDirectory='%workingDirectory%';$s.Save()"
echo 快捷方式已创建在桌面上：%shortcutName%.lnk
echo 启动中......
start %userprofile%\Desktop\%shortcutName%.lnk
goto:eof

:uninstall
rd /S /Q %dir%<nul
rd /S /Q %tmp%<nul
del /S /F /Q %userprofile%\Desktop\*yanderify*.lnk<nul
echo 删除完毕！
pause
goto:eof
