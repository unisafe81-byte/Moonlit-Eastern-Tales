param(
  [string]$Message = ""
)

$ErrorActionPreference = "Stop"
Set-Location -LiteralPath $PSScriptRoot

Write-Host ""
Write-Host "Moonlit Eastern Tales GitHub Pages deployment" -ForegroundColor Cyan
Write-Host "------------------------------------------------" -ForegroundColor Cyan

$status = git status --short
if (-not $status) {
  Write-Host "No local changes to deploy." -ForegroundColor Yellow
  exit 0
}

Write-Host ""
Write-Host "Changes to deploy:" -ForegroundColor Yellow
$status | ForEach-Object { Write-Host "  $_" }

Write-Host ""
$confirm = Read-Host "GitHub public link에 반영할까요? Type YES to continue"
if ($confirm -ne "YES") {
  Write-Host "Deployment cancelled." -ForegroundColor Yellow
  exit 0
}

if (Test-Path -LiteralPath "index.html") {
  node -e "new Function(require('fs').readFileSync('index.html','utf8').match(/<script>([\s\S]*)<\/script>/)[1]); console.log('js-ok')"
}

if (-not $Message.Trim()) {
  $Message = Read-Host "Commit message"
}

if (-not $Message.Trim()) {
  $Message = "Update Moonlit Eastern Tales app"
}

git add -- index.html prompt-data.js *.txt deploy-github-pages.ps1

$staged = git diff --cached --name-only
if (-not $staged) {
  Write-Host "No staged changes after filtering deployable files." -ForegroundColor Yellow
  exit 0
}

Write-Host ""
Write-Host "Staged files:" -ForegroundColor Yellow
$staged | ForEach-Object { Write-Host "  $_" }

git commit -m $Message
git push origin main
git push origin main:gh-pages

$hash = git rev-parse --short HEAD
Write-Host ""
Write-Host "Deployment pushed." -ForegroundColor Green
Write-Host "Commit: $hash" -ForegroundColor Green
Write-Host "Public link: https://unisafe81-byte.github.io/Moonlit-Eastern-Tales/?v=$hash" -ForegroundColor Green
