Add-Content -Path "E:\Schule\Berufsschule\M122\LeagueofBravery\bravery-start.log" -Value "$(Get-Date): Watcher gestartet"

$lockfilePath = "E:\Valorant\Riot Games\League of Legends\lockfile"
$checkIntervalSeconds = 5
$braveryStarted = $false

Add-Type -TypeDefinition @"
using System.Net;
using System.Security.Cryptography.X509Certificates;

public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

while ($true) {
    try {
        if (!(Test-Path $lockfilePath)) {
            $braveryStarted = $false
        } else {
            $lockData = Get-Content $lockfilePath -Raw
            $parts = $lockData -split ":"
            $port = $parts[2]
            $password = $parts[3]
            $protocol = $parts[4]
            $authHeader = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("riot:$password"))
            $uri = "${protocol}://127.0.0.1:${port}/lol-gameflow/v1/session"

            $request = [System.Net.WebRequest]::Create($uri)
            $request.Method = "GET"
            $request.Headers["Authorization"] = $authHeader
            $request.Accept = "application/json"

            $response = $request.GetResponse()
            $reader = New-Object System.IO.StreamReader($response.GetResponseStream())
            $json = $reader.ReadToEnd() | ConvertFrom-Json
            $phase = $json.phase
            $braveryShortcut = "E:\Schule\Berufsschule\M122\LeagueofBravery\wt.exe.lnk"

            if ($phase -eq "ChampSelect" -and -not $braveryStarted) {
                Add-Content -Path "E:\Schule\Berufsschule\M122\LeagueofBravery\bravery-start.log" -Value "$(Get-Date): Starte LeagueOfBravery.ps1 über Windows Terminal"
    
                Start-Process -FilePath $braveryShortcut
    
                $braveryStarted = $true
            } elseif ($phase -ne "ChampSelect") {
                $braveryStarted = $false
            }
        }
    }
    catch {
        $braveryStarted = $false
    }

    Start-Sleep -Seconds $checkIntervalSeconds
}
