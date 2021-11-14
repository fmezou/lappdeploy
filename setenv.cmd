@echo off
rem Set the environment variables for the project
rem Add the source root
set CONTENTROOT=%~dp0
set PYTHONPATH=%CONTENTROOT%;%CONTENTROOT%lappdeploy\;%PYTHONPATH%
ver
echo Environment tuned for the lAppDeploy project
