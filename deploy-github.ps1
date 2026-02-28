# AQUAMIND - GitHub Deployment Script
# Ce script configure et pousse le projet sur GitHub

Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  🧠 AQUAMIND - GitHub Deployment Wizard                       ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Vérifier que git est installé
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Git n'est pas installé! " -ForegroundColor Red
    Write-Host "   Télécharger depuis: https://git-scm.com/download/win" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Git trouvé: $(git --version)`n" -ForegroundColor Green

# Demander le GitHub username
Write-Host "📝 Configuration de GitHub" -ForegroundColor Yellow
$username = Read-Host "Entrez votre GitHub username"

if (-not $username) {
    Write-Host "❌ Username vide! Complétion annulée." -ForegroundColor Red
    exit 1
}

$repoUrl = "https://github.com/$username/AQUAMIND.git"
$sshUrl = "git@github.com:$username/AQUAMIND.git"

Write-Host "`n📋 Configuration:" -ForegroundColor Cyan
Write-Host "   Username: $username"
Write-Host "   Repo: AQUAMIND"
Write-Host "   URL: $repoUrl`n"

# Demander la méthode d'authentification
Write-Host "🔐 Choisir la méthode d'authentification:" -ForegroundColor Yellow
Write-Host "1. HTTPS (Recommandé - demande token)"
Write-Host "2. SSH (Avancé - nécessite clé SSH)"
$authChoice = Read-Host "Choisir [1 ou 2]"

if ($authChoice -eq "2") {
    $remoteUrl = $sshUrl
    Write-Host "`n⚠️  SSH sélectionné" -ForegroundColor Yellow
    Write-Host "   Assurez-vous d'avoir une clé SSH configurée." -ForegroundColor Yellow
    Write-Host "   Guide: https://docs.github.com/en/authentication/connecting-to-github-with-ssh`n"
} else {
    $remoteUrl = $repoUrl
    Write-Host "`n✅ HTTPS sélectionné" -ForegroundColor Green
    Write-Host "   Vous serez demandé d'authentifier avec GitHub" -ForegroundColor Gray
}

# Vérifier si le repo existe déjà
Write-Host "`n🔍 Vérification du repository local...`n"
if (git rev-parse --git-dir 2>$null) {
    Write-Host "✅ Git repository déjà initialisé`n" -ForegroundColor Green
} else {
    Write-Host "⚠️  Git pas encore initialisé, initialisation..." -ForegroundColor Yellow
    git init | Out-Null
}

# Configurer le user
Write-Host "⚙️  Configuration du user git..."
$email = Read-Host "Entrez votre email GitHub"
git config --global user.name "$username"
git config --global user.email "$email"
Write-Host "✅ User configuré: $username <$email>`n" -ForegroundColor Green

# Ajouter le remote
Write-Host "🔗 Configuration du remote GitHub..."
git remote remove origin 2>$null
git remote add origin $remoteUrl
Write-Host "✅ Remote ajouté: $remoteUrl`n" -ForegroundColor Green

# Vérifier l'état git
Write-Host "📊 État du repository:"
git status --short | Out-Host

# Confirmation avant push
Write-Host "`n⚠️  ATTENTION!" -ForegroundColor Yellow
Write-Host "   Ceci va pousser TOUS les fichiers sur GitHub"
Write-Host "   Repository: $remoteUrl`n"
$confirm = Read-Host "Continuer? (oui/non)"

if ($confirm -ne "oui" -and $confirm -ne "o" -and $confirm -ne "yes" -and $confirm -ne "y") {
    Write-Host "`n❌ Opération annulée." -ForegroundColor Red
    exit 0
}

# Exécuter le push
Write-Host "`n🚀 Déploiement en cours...`n" -ForegroundColor Cyan

try {
    Write-Host "1️⃣  Renommer la branche à 'main'..."
    git branch -M main 2>$null
    Write-Host "   ✅ Branche renommée`n"

    Write-Host "2️⃣  Pousser vers GitHub..."
    git push -u origin main
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ SUCCÈS! Projet poussé sur GitHub!`n" -ForegroundColor Green
        
        Write-Host "📌 Infos importantes:" -ForegroundColor Cyan
        Write-Host "   Repository: https://github.com/$username/AQUAMIND"
        Write-Host "   Voir le code: https://github.com/$username/AQUAMIND/blob/main/README.md"
        Write-Host "   Fichiers: https://github.com/$username/AQUAMIND/tree/main/frontend/public"
        
        Write-Host "`n📱 Options de déploiement public:" -ForegroundColor Yellow
        Write-Host "   1. Vercel: https://vercel.com/import (instant)"
        Write-Host "   2. Netlify: https://app.netlify.com/start"
        Write-Host "   3. GitHub Pages: Settings → Pages"
        
        Write-Host "`n💡 Prochaines étapes:" -ForegroundColor Cyan
        Write-Host "   1. Aller sur https://github.com/$username/AQUAMIND"
        Write-Host "   2. Cliquer sur 'Settings' → 'Pages'"
        Write-Host "   3. Source: Deploy from a branch"
        Write-Host "   4. Branch: main, Folder: /frontend/public"
        Write-Host "   5. Sauvegarder et attendre 1-2 minutes"
        Write-Host ""
        Write-Host "🎉 Votre site sera accessible à:" -ForegroundColor Green
        Write-Host "   https://$username.github.io/AQUAMIND/" -ForegroundColor Cyan
        Write-Host ""
    } else {
        Write-Host "`n❌ Erreur lors du push. Vérifier:" -ForegroundColor Red
        Write-Host "   1. Username GitHub correct: $username"
        Write-Host "   2. Token/SSH configuré"
        Write-Host "   3. Repo créé sur https://github.com/new"
    }
} catch {
    Write-Host "`n❌ Erreur: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`n" -ForegroundColor Gray
Read-Host "Appuyer sur Entrée pour terminer"
