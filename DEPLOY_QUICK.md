# 🚀 AQUAMIND - Déploiement GitHub Rapide

## Méthode 1: Script Automatisé (RECOMMANDÉ)

### Windows PowerShell:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
cd "c:\Users\user\Desktop\PROJET _PROJET\AQUAMIND"
.\deploy-github.ps1
```

### Windows Command Prompt:
```cmd
cd "c:\Users\user\Desktop\PROJET _PROJET\AQUAMIND"
deploy-github.bat
```

Le script demande:
1. ✅ Votre GitHub username
2. ✅ Votre email GitHub
3. ✅ Confirmation avant push
4. ✅ Configure automatiquement le remote et pousse

---

## Méthode 2: Commandes Manuelles

### Étape 1: Préparer GitHub
1. Aller à: https://github.com/new
2. **Repository name**: `AQUAMIND`
3. **Description**: "AI-powered water management system with ML forecasting"
4. **Public**: ✅ (pour que ce soit accessible)
5. Cliquer: "Create repository"

### Étape 2: Configurer Git
```bash
cd "c:\Users\user\Desktop\PROJET _PROJET\AQUAMIND"

# Remplacer YOUR_USERNAME par votre username GitHub
git remote add origin https://github.com/YOUR_USERNAME/AQUAMIND.git
git branch -M main
git push -u origin main
```

### Étape 3: Entrez vos credentials
- **Username GitHub**: YOUR_USERNAME
- **Token Personnel**: Créer à https://github.com/settings/tokens/new
  - Sélectionner: `repo`, `workflow`
  - Copier le token
  - L'utiliser comme password

---

## Étape 4: Activer GitHub Pages

1. Aller à: `https://github.com/YOUR_USERNAME/AQUAMIND`
2. Cliquer: **Settings** (en haut à droite)
3. Aller à: **Pages** (menu de gauche)
4. **Source**: "Deploy from a branch"
5. **Branch**: Sélectionner `main`
6. **Folder**: Sélectionner `/frontend/public`
7. Cliquer: **Save**
8. **Attendre 1-2 minutes** pour la build

---

## ✅ Résultat Final

Votre site AQUAMIND sera accessible à:
```
https://YOUR_USERNAME.github.io/AQUAMIND/
```

Par exemple:
- Repository: `https://github.com/YOUR_USERNAME/AQUAMIND`
- Site Live: `https://YOUR_USERNAME.github.io/AQUAMIND`

---

## 📱 Pages Disponibles

Une fois déployé:

| Page | URL |
|------|-----|
| **Accueil** | `/AQUAMIND/` |
| **Dashboard** | `/AQUAMIND/dashboard.html` |
| **Prédictions** | `/AQUAMIND/forecast.html` |
| **Analyse IA** | `/AQUAMIND/analytics.html` |
| **Démo** | `/AQUAMIND/DEMO.html` |

---

## 🆘 Troubleshooting

### "fatal: not a git repository"
```powershell
cd "c:\Users\user\Desktop\PROJET _PROJET\AQUAMIND"
git init
git add .
git commit -m "Initial commit"
```

### "Authentication failed"
1. Vérifier le username: `git config --global user.name`
2. Créer un token: https://github.com/settings/tokens/new
3. Utiliser le token comme password

### "Remote already exists"
```bash
git remote remove origin
git remote add origin https://github.com/YOUR_USERNAME/AQUAMIND.git
```

### GitHub Pages ne se met pas à jour
1. Vérifier Settings → Pages → Source
2. Vérifier que folder est `/frontend/public`
3. Attendre 3-5 minutes
4. Rafraîchir le navigateur (Ctrl+F5)

---

## 💡 Variables à Remplacer

Partout où vous voyez: `YOUR_USERNAME`

Remplacez par votre vrai username GitHub!

Exemple:
- ❌ `https://github.com/YOUR_USERNAME/AQUAMIND.git`
- ✅ `https://github.com/pierre123/AQUAMIND.git`

---

## 🎉 Vous Avez Terminé!

Partagez votre site:
- 📊 Repository: `https://github.com/YOUR_USERNAME/AQUAMIND`
- 🌐 Site Live: `https://YOUR_USERNAME.github.io/AQUAMIND`

Il contient:
- ✅ Landing page premium
- ✅ Dashboard temps réel (KPI auto-mise à jour)
- ✅ Système de prédictions 7 jours
- ✅ Analytics IA avec modèles (LSTM, Transformer, etc.)
- ✅ Cartes Leaflet interactive
- ✅ 100% responsive (mobile + desktop)
- ✅ Animations smooth
- ✅ Données simulées réalistes
