# --------------------------------------
# League of Legends Ultimate Bravery Generator
# Author: Simon Pichler
# --------------------------------------

# TLS aktivieren für HTTPS-Zugriff
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Aktuelle DDragon-Version
$ddVersion = "15.11.1"

# --------------------------------------
# Champion-Daten abrufen
# --------------------------------------

$championsUrl = "https://ddragon.leagueoflegends.com/cdn/$ddVersion/data/en_US/champion.json"
$championJson = Invoke-RestMethod -Uri $championsUrl

# Championnamen extrahieren
$championNames = @($championJson.data.PSObject.Properties.Name)

if ($championNames.Count -eq 0) {
    Write-Error "Error: No Champions loaded."
    exit
} else {
    Write-Host "`n$($championNames.Count) Champions loaded."
}

# Zufälliger Champion
$randomChampion = Get-Random -InputObject $championNames
Write-Host "Random Champion: $randomChampion" -ForegroundColor Yellow

# --------------------------------------
# Items abrufen
# --------------------------------------

$itemsUrl = "https://ddragon.leagueoflegends.com/cdn/$ddVersion/data/en_US/item.json"
$itemJson = Invoke-RestMethod -Uri $itemsUrl

# Zugriff auf alle Items
$itemList = @($itemJson.data.PSObject.Properties)

# Debug: Beispielhafte Items anzeigen
Write-Host "`nBeispielhafte Items:"
$itemList | Select-Object -First 5 | ForEach-Object {
    Write-Host "- $($_.Value.name) [Tags: $($_.Value.tags -join ', ')]"
}

# Robuster Item-Filter (inkl. Map-Fallback)
$allItems = $itemList | Where-Object {
    $_.Value.gold.purchasable -eq $true -and
    $_.Value.name -ne "" -and
    $_.Value.plaintext -ne "" -and
    $_.Value.gold.purchasable -eq $true -and
    $_.Value.name -ne "" -and
    $_.Value.plaintext -ne ""
}


# Boots-Filter (nur echte Boots, kein Grunditem "Boots")
$bootItems = $allItems | Where-Object {
    $_.Value.tags -contains "Boots" -and $_.Value.name -ne "Boots"
}

# Debug-Ausgabe Boots
Write-Host "`nGefundene Boots: $($bootItems.Count)"
$bootItems | ForEach-Object { Write-Host "- $($_.Value.name)" }

# Usable Items (keine Boots, Jungle, Support, Trinket)
$usableItems = $allItems | Where-Object {
    ($_.Value.tags -notcontains "Boots") -and
    ($_.Value.description -notmatch "Jungle|support|starter|trinket")
}

# Item-Auswahl
$randomItems = $usableItems | Get-Random -Count 5

# Boots-Auswahl
if ($bootItems.Count -gt 0) {
    $randomBoot = Get-Random -InputObject $bootItems
} else {
    Write-Warning "Keine Boots gefunden!"
    $randomBoot = $null
}

# --------------------------------------
# Ausgabe
# --------------------------------------

Write-Host "`n--- Tag-basierte Item-Kategorien (Test) ---" -ForegroundColor Cyan

# AP-Items
$apItems = $usableItems | Where-Object {
    $_.Value.tags -contains "SpellDamage"
}
Write-Host "AP-Items gefunden: $($apItems.Count)"

# AD-Items
$adItems = $usableItems | Where-Object {
    $_.Value.tags -contains "AttackDamage"
}
Write-Host "AD-Items gefunden: $($adItems.Count)"

# Tank-Items
$tankItems = $usableItems | Where-Object {
    $_.Value.tags -contains "Health" -or $_.Value.tags -contains "Armor" -or $_.Value.tags -contains "SpellBlock"
}
Write-Host "Tank-Items gefunden: $($tankItems.Count)"

# Crit-Items
$critItems = $usableItems | Where-Object {
    $_.Value.tags -contains "CriticalStrike"
}
Write-Host "Crit-Items gefunden: $($critItems.Count)"

# Support-Items
$supportItems = $usableItems | Where-Object {
    $_.Value.tags -contains "Active" -or $_.Value.tags -contains "Aura"
}
Write-Host "Support-Items gefunden: $($supportItems.Count)"


Write-Host "`n--- Ultimate Bravery Build ---" -ForegroundColor Cyan
Write-Host "Champion: $randomChampion" -ForegroundColor Yellow
Write-Host "`nItems:" -ForegroundColor Green
$randomItems | ForEach-Object { Write-Host "- $($_.Value.name)" }

if ($randomBoot) {
    Write-Host "`nBoots: $($randomBoot.Value.name)" -ForegroundColor Green
} else {
    Write-Host "`nBoots: [Keine gefunden]" -ForegroundColor Red
}
