# --------------------------------------
# League of Legends Ultimate Bravery Generator
# Author: Simon Pichler
# --------------------------------------

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# -------------------------------
# Champion zufällig auswählen
# -------------------------------
$championPath = ".\champion.json"
$championData = Get-Content $championPath -Raw | ConvertFrom-Json
$championNames = @($championData.data.PSObject.Properties.Name)

if ($championNames.Count -eq 0) {
    Write-Error "Keine Champions geladen!"
    exit
}

$randomChampion = Get-Random -InputObject $championNames

# -------------------------------
# Items laden & nach Rolle filtern
# -------------------------------
$itemsPath = ".\item.json"
$itemData = Get-Content $itemsPath -Raw | ConvertFrom-Json

# Definierte Rollen
$roles = @("Mage", "Fighter", "Tank", "Support Tank", "Support Enchanter", "Marksman", "Assassin")
$chosenRole = Get-Random -InputObject $roles
Write-Host "`nRandom Item-Role: $chosenRole" -ForegroundColor Cyan

# Boots: Alle Tier2-Boots mit passender Rolle (nicht auf legendary beschränkt)
$bootItems = $itemData.PSObject.Properties | Where-Object {
    $_.Value.tags -contains "Tier2_Boots" -and
    $_.Value.roleTags -contains $chosenRole
}

# Legendary Items ohne Boots
$usableItems = $itemData.PSObject.Properties | Where-Object {
    $_.Value.legendary -eq $true -and
    $_.Value.roleTags -contains $chosenRole -and
    ($_.Value.tags -notcontains "Tier2_Boots")
}

# 5 zufällige Legendary Items + 1 Boot (falls vorhanden)
$randomItems = $usableItems | Get-Random -Count ([Math]::Min(5, $usableItems.Count))
$randomBoot = if ($bootItems.Count -gt 0) { Get-Random -InputObject $bootItems } else { $null }

# -------------------------------
# Runen laden & generieren
# -------------------------------
$runesPath = ".\runes.json"
$runeData = Get-Content $runesPath -Raw | ConvertFrom-Json

$runePaths = $runeData.PSObject.Properties.Name
$primaryPath = Get-Random -InputObject $runePaths
$secondaryPath = Get-Random -InputObject ($runePaths | Where-Object { $_ -ne $primaryPath })

$primary = $runeData.$primaryPath
$secondary = $runeData.$secondaryPath

$runeSet = @{
    "Primary" = @{
        "Path"     = $primaryPath
        "Keystone" = Get-Random -InputObject $primary.keystone
        "Slot1"    = Get-Random -InputObject $primary.slots.slot1
        "Slot2"    = Get-Random -InputObject $primary.slots.slot2
        "Slot3"    = Get-Random -InputObject $primary.slots.slot3
    }
    "Secondary" = @{
        "Path"  = $secondaryPath
        "Slot1" = Get-Random -InputObject $secondary.slots.slot1
        "Slot2" = Get-Random -InputObject $secondary.slots.slot2
    }
}

# -------------------------------
# Ausgabe
# -------------------------------
Write-Host "`n--- Ultimate Bravery Build ---" -ForegroundColor Cyan
Write-Host "Champion: $randomChampion" -ForegroundColor Yellow

Write-Host "`nItems (Role: $chosenRole):" -ForegroundColor Green
$randomItems | ForEach-Object { Write-Host "- $($_.Value.name)" }

Write-Host "`nBoots:" -ForegroundColor Green
if ($randomBoot) {
    Write-Host "- $($randomBoot.Value.name)"
} else {
    Write-Host "- [Not Found]" -ForegroundColor Red
}

Write-Host "`nRunes:" -ForegroundColor Magenta
Write-Host "Primary Path: $($runeSet.Primary.Path)"
Write-Host "- Keystone: $($runeSet.Primary.Keystone)"
Write-Host "- Slot1: $($runeSet.Primary.Slot1)"
Write-Host "- Slot2: $($runeSet.Primary.Slot2)"
Write-Host "- Slot3: $($runeSet.Primary.Slot3)"

Write-Host "Secondary Path: $($runeSet.Secondary.Path)"
Write-Host "- Slot1: $($runeSet.Secondary.Slot1)"
Write-Host "- Slot2: $($runeSet.Secondary.Slot2)"
