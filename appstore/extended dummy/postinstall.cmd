@echo off
rem Ce script r�alise les op�rations de postinstallation.
rem Ces op�rations se limite au d�placement des racourci du menu d�marrer.
set StartMenuPath=\Microsoft\Windows\Start Menu\Programs
set AllUsersStartMenuPath=%ALLUSERSPROFILE%%StartMenuPath%
set LocalStartMenuPath=%APPDATA%%StartMenuPath%
echo a dummy extented postinstaller installer... dummy application fixed