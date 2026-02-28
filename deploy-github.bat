@echo off
REM AQUAMIND - GitHub Deployment Script (Batch)
REM Simple version for Windows Command Prompt

setlocal enabledelayedexpansion

cls
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║  AQUAMIND - GitHub Deployment                                 ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

REM Verifier que git est installe
git --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: Git n'est pas installe!
    echo Telecharger depuis: https://git-scm.com/download/win
    echo.
    pause
    exit /b 1
)

echo.
echo --- CONFIGURATION GITHUB ---
echo.
set /p username="Entrez votre GitHub username: "

if "!username!"=="" (
    echo.
    echo ERROR: Username vide!
    echo.
    pause
    exit /b 1
)

set "repoUrl=https://github.com/!username!/AQUAMIND.git"

echo.
echo --- CONFIGURATION ---
echo Username: !username!
echo Repository: AQUAMIND
echo URL: !repoUrl!
echo.

echo --- CONFIGURATION GIT ---
set /p email="Entrez votre email GitHub: "

git config --global user.name "!username!"
git config --global user.email "!email!"

echo.
echo --- AJOUT DU REMOTE ---
git remote remove origin 2>nul
git remote add origin !repoUrl!

echo.
echo --- ETAT DU REPOSITORY ---
git status --short

echo.
echo.
echo *** ATTENTION ***
echo Ceci va pousser TOUS les fichiers sur GitHub a: !repoUrl!
echo.
set /p confirm="Continuer? (oui/non): "

if /i not "!confirm!"=="oui" (
    if /i not "!confirm!"=="o" (
        if /i not "!confirm!"=="y" (
            echo.
            echo Operationannulee.
            echo.
            pause
            exit /b 0
        )
    )
)

echo.
echo --- DEPLOIEMENT EN COURS ---
echo.
echo 1. Renommer la branche a 'main'...
git branch -M main 2>nul
echo    OK
echo.

echo 2. Pousser vers GitHub...
git push -u origin main

if errorlevel 0 (
    echo.
    echo SUCCESS! Projet pousse sur GitHub!
    echo.
    echo --- INFOS ---
    echo Repository: https://github.com/!username!/AQUAMIND
    echo.
    echo --- PROCHAINES ETAPES (GitHub Pages) ---
    echo 1. Aller sur: https://github.com/!username!/AQUAMIND
    echo 2. Cliquer sur 'Settings'
    echo 3. Aller a 'Pages'
    echo 4. Source: Deploy from a branch
    echo 5. Branch: main, Folder: /frontend/public
    echo 6. Sauvegarder et attendre 1-2 minutes
    echo.
    echo Votre site sera a: https://!username!.github.io/AQUAMIND/
    echo.
) else (
    echo.
    echo ERROR lors du push!
    echo Verifier: username, token, et que le repo existe sur GitHub
    echo.
)

pause
