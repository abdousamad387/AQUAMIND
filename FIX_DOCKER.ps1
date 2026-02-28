# ==================================================================================
# DOCKER DESKTOP FIX SCRIPT
# Verifie et installe les prerequisites manquants pour Docker Desktop
# ==================================================================================

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "   DIAGNOSTIC ET REPARATION DE DOCKER DESKTOP" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""

# Fonction pour afficher les messages
function Show-Message {
    param($message, $type = "info")
    $prefix = switch($type) {
        "success" { "[+] " }
        "error"   { "[-] " }
        "warning" { "[!] " }
        "info"    { "[*] " }
        default   { "    " }
    }
    
    $color = switch($type) {
        "success" { "Green" }
        "error"   { "Red" }
        "warning" { "Yellow" }
        "info"    { "Cyan" }
        default   { "White" }
    }
    
    Write-Host "$prefix$message" -ForegroundColor $color
}

# ==================================================================================
# ETAPE 1: Verifier WSL2
# ==================================================================================

Write-Host ""
Show-Message "ETAPE 1: Verification de WSL2" "info"
Show-Message "================================" "info"
Write-Host ""

try {
    $wslStatus = wsl --version 2>$null
    if ($wslStatus) {
        Show-Message "WSL2 est INSTALLEE" "success"
        Write-Host "Details: $wslStatus" -ForegroundColor Green
    } else {
        Show-Message "WSL2 n'est PAS installee" "error"
        Write-Host ""
        Show-Message "Installation de WSL2..." "warning"
        Write-Host ""
        Write-Host "Deux options:" -ForegroundColor Yellow
        Write-Host "1. AUTOMATIQUE (recommande):" -ForegroundColor Green
        Write-Host "   Lancez cette commande dans PowerShell EN ADMINISTRATEUR:" 
        Write-Host ""
        Write-Host "   wsl --install" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "2. MANUEL:" -ForegroundColor Green
        Write-Host "   Allez sur: https://aka.ms/wsl2kernel" -ForegroundColor Cyan
        Write-Host "   Telecharge et installe le package" 
        Write-Host ""
        Write-Host "Apres installation, redemarrez votre ordinateur." -ForegroundColor Yellow
    }
} catch {
    Show-Message "Erreur lors de la verification de WSL2" "error"
}

Write-Host ""

# ==================================================================================
# ETAPE 2: Verifier Hyper-V
# ==================================================================================

Show-Message "ETAPE 2: Verification de Hyper-V" "info"
Show-Message "=================================" "info"
Write-Host ""

try {
    $hypervStatus = Get-WindowsOptionalFeature -Online -FeatureName "Hyper-V" -ErrorAction SilentlyContinue
    
    if ($null -ne $hypervStatus) {
        if ($hypervStatus.State -eq "Enabled") {
            Show-Message "Hyper-V est ACTIVE" "success"
        } else {
            Show-Message "Hyper-V est DESACTIVEE" "error"
            Write-Host ""
            Write-Host "Pour l'activer:" -ForegroundColor Yellow
            Write-Host "1. Ouvrez PowerShell EN ADMINISTRATEUR" -ForegroundColor Green
            Write-Host "2. Lancez:" -ForegroundColor Green
            Write-Host ""
            Write-Host "   Enable-WindowsOptionalFeature -Online -FeatureName Hyper-V -All" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "3. Redemarrez votre ordinateur" -ForegroundColor Yellow
        }
    }
} catch {
    Show-Message "Hyper-V n'est pas disponible sur votre systeme" "warning"
}

Write-Host ""

# ==================================================================================
# ETAPE 3: Verifier Docker Desktop
# ==================================================================================

Show-Message "ETAPE 3: Verification de Docker Desktop" "info"
Show-Message "========================================" "info"
Write-Host ""

$dockerPath = "C:\Program Files\Docker\Docker\Docker.exe"
if (Test-Path $dockerPath) {
    Show-Message "Docker Desktop trouve a: $dockerPath" "success"
} else {
    Show-Message "Docker Desktop n'est pas trouve au chemin standard" "error"
    Write-Host ""
    Write-Host "Cherche dans d'autres emplacements..." -ForegroundColor Yellow
    
    $dockerPaths = @(
        "C:\Program Files\Docker"
        "C:\Program Files (x86)\Docker"
        "$env:ProgramFiles\Docker"
    )
    
    $found = $false
    foreach ($path in $dockerPaths) {
        if (Test-Path $path) {
            Show-Message "Docker trouve dans: $path" "success"
            $found = $true
            break
        }
    }
    
    if (-not $found) {
        Show-Message "Docker Desktop n'est pas installe" "error"
        Write-Host ""
        Write-Host "Telechargez Docker Desktop:" -ForegroundColor Yellow
        Write-Host "https://www.docker.com/products/docker-desktop" -ForegroundColor Cyan
    }
}

Write-Host ""

# ==================================================================================
# ETAPE 4: Verifier les permissions
# ==================================================================================

Show-Message "ETAPE 4: Verification des permissions" "info"
Show-Message "=====================================" "info"
Write-Host ""

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if ($isAdmin) {
    Show-Message "Vous avez les droits ADMINISTRATEUR" "success"
} else {
    Show-Message "Vous N'AVEZ PAS les droits administrateur" "warning"
    Write-Host ""
    Write-Host "Docker Desktop necessites les droits admin." -ForegroundColor Yellow
    Write-Host "Relancez PowerShell EN ADMINISTRATEUR pour installer les updates." -ForegroundColor Yellow
}

Write-Host ""

# ==================================================================================
# RESUME ET SOLUTIONS
# ==================================================================================

Write-Host ""
Show-Message "SOLUTIONS RAPIDES" "info"
Show-Message "=================" "info"
Write-Host ""

Write-Host "Si rien ne s'affiche:" -ForegroundColor Yellow
Write-Host "  1. Ouvrez PowerShell EN ADMINISTRATEUR" -ForegroundColor Cyan
Write-Host "  2. Lancez: wsl --install" -ForegroundColor Cyan
Write-Host "  3. Redemarrez votre ordinateur" -ForegroundColor Cyan
Write-Host "  4. Essayez Docker Desktop a nouveau" -ForegroundColor Cyan
Write-Host ""

Write-Host "Si vous avez encore des problemes:" -ForegroundColor Yellow
Write-Host "  - Desinstallez Docker Desktop" -ForegroundColor Cyan
Write-Host "  - Redemarrez" -ForegroundColor Cyan
Write-Host "  - Reinstallez Docker Desktop" -ForegroundColor Cyan
Write-Host ""

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "   FIN DU DIAGNOSTIC" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "Appuyez sur une touche pour fermer..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
