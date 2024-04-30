@echo off
mode con cols=30 lines=10&color 9f&cls
set "dir=%LocalAppData%\Imageio"
set "tmp=%temp%\yanderify-tmp"
if not exist "%dir%" (md "%dir%")
if not exist "%tmp%" (md "%tmp%")
if not exist "%dir%\Ffmpeg" (md "%dir%\Ffmpeg")

:: �˵���
echo.
echo 1����װ
echo.
echo 2��ж��
echo.
echo ---------------
set /p choice=���ѡ���ǣ�
if "%choice%"=="1" (
	mode con cols=85 lines=40&color 9f&cls
    goto :install
) else if "%choice%"=="2" (
    goto :uninstall
) else (
    echo ��Ч��ѡ��
    pause
	exit 1
)

:install
:: ����Ƿ�װ�� Python
py --version >nul 2>nul
if %errorlevel% neq 0 (
    echo Pythonδ��װ�����԰�װ...
    if exist "%tmp%\python.exe" (
        %tmp%\python.exe /quiet InstallAllUsers=1 PrependPath=1
    ) else (
        curl -o "%tmp%\python.exe" https://www.python.org/ftp/python/3.12.3/python-3.12.3-amd64.exe
        %tmp%\python.exe /quiet InstallAllUsers=1 PrependPath=1
    )
    py --version >nul 2>nul
    if %errorlevel% neq 0 (
        echo Python��װʧ��...&& pause 
        exit /b 1
    )
) else (
    echo Python�Ѱ�װ��
)

:: yanderify��������
:: ��� yanderify.exe �Ƿ����
if exist "%dir%\yanderify\yanderify.exe" (
    echo yanderify�Ѵ��ڣ��������ء�
) else (
    :: �����ʱ�ļ������Ƿ���yanderify.zip
    if not exist "%tmp%\yanderify.zip" (
        echo ��������yanderify����...
        curl -o "%tmp%\yanderify.zip" https://gh.ddlc.top/https://github.com/dunnousername/yanderifier/releases/download/v4.0.3-stable/yanderify.zip
        if %errorlevel% neq 0 (echo yanderify����ʧ��... && rm "%tmp%\yanderify.zip" && pause && exit 1
        )
    )
    echo ���ڽ�ѹyanderify����...  
    powershell -command Expand-Archive -Path %tmp%\yanderify.zip -DestinationPath %dir%
	if exist "%dir%\yanderify\yanderify.exe" (
        echo yanderify��ѹ��ϣ�
    ) else (
        echo yanderify��ѹʧ�ܣ�
        del "%tmp%\yanderify.zip"
        pause
        exit 1
    )
)



:: checkpoint.tarģ������
if exist "%dir%\yanderify\checkpoint.tar" (
	echo ģ�ʹ��ڣ���������
) else (
	echo ��������ģ��......
	curl -o %dir%\yanderify\checkpoint.tar https://gh.ddlc.top/https://github.com/dunnousername/yanderifier/releases/download/model/checkpoint.tar
	if %errorlevel% == 0 (echo checkpoint.tar�������!) else (echo checkpoint.tar����ʧ�ܣ�&& pause && exit 1)
)

:: ffmpeg����
if exist "%dir%\Ffmpeg\ffmpeg-win32-v3.2.4.exe" (
	echo ffmpeg���ڣ���������
) else (
	echo ��������ffmpeg.....
	curl -o  %tmp%\ffmpeg.zip https://gh.ddlc.top/https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip
		if %errorlevel% neq 0 (echo ffmpeg����ʧ�ܣ�&& pause && exit 1)
			powershell -command Expand-Archive -Path %tmp%\ffmpeg.zip -DestinationPath %tmp%
	       	if exist %tmp%\ffmpeg-master-latest-win64-gpl\bin\ffmpeg.exe (
	       		copy %tmp%\ffmpeg-master-latest-win64-gpl\bin\ffmpeg.exe %dir%\Ffmpeg\ffmpeg-win32-v3.2.4.exe
				echo ffmpeg��ѹ��ϣ�
			) else (
				echo ffmpeg��ѹʧ�ܣ�
				del "%tmp%\ffmpeg.zip"
				echo �����Դ�ffmpeg
				copy %dir%\yanderify\ffmpeg.exe %dir%\Ffmpeg\ffmpeg-win32-v3.2.4.exe
				if not exist %dir%\Ffmpeg\ffmpeg-win32-v3.2.4.exe (echo ����ʧ�� && pause && exit 1)
			)
)

:: ��������ͼ��
set "target=%dir%\yanderify\yanderify.exe"
set "workingDirectory=%dir%\yanderify\"
set "shortcutName=Yanderify"
powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%userprofile%\Desktop\%shortcutName%.lnk');$s.TargetPath='%target%';$s.WorkingDirectory='%workingDirectory%';$s.Save()"
echo ��ݷ�ʽ�Ѵ����������ϣ�%shortcutName%.lnk
echo ������......
start %userprofile%\Desktop\%shortcutName%.lnk
goto:eof

:uninstall
rd /S /Q %dir%<nul
rd /S /Q %tmp%<nul
del /S /F /Q %userprofile%\Desktop\*yanderify*.lnk<nul
echo ɾ����ϣ�
pause
goto:eof
