if(!Test-Path $UinstallFolder) {
    try {
        New-Item -Path $UinstallFolder -ItemType Directory        
    }
    catch {
        Write-Host "Could not create folder" $Error[0]
    }
}

if (![System.IO.File]::Exists("$UinstallFolder\DG_AETHER.exe")) {
    Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/sbrathwaite/Hors/master/dg_aether/DG_AETHER.exe" -OutFile $UinstallFolder\DG_AETHER.exe    
}

if (![System.IO.File]::Exists("$UinstallFolder\DG_PANDAPROT8_XX.exe")) {
    Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/sbrathwaite/Hors/master/dg_aether/DG_PANDAPROT8_XX.exe" -OutFile $UinstallFolder\DG_AETHER.exe    
}


# Download Script
if (![System.IO.File]::Exists("C:\PandaAvinstallation\uninstaller.exe")) {
    Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/sbrathwaite/Hors/master/EnableDefender.ps1" -OutFile $UinstallFolder\EnableDefender.ps1
}

Write-Host "Files downloaded to $UinstallFolder" -ForegroundColor Green