$UninstallFolder = "C:\PandaAvinstallation"

if(!(Test-Path $UninstallFolder)) {
    try {
        New-Item -Path $UninstallFolder -ItemType Directory | Out-Null   
    }
    catch {
        Write-Host "Could not create folder" $Error[0]
    }

    if (![System.IO.File]::Exists("$UninstallFolder\DG_AETHER.exe")) {
        Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/sbrathwaite/Hors/master/dg_aether/DG_AETHER.exe" -OutFile $UninstallFolder\DG_AETHER.exe    
    }
    
    if (![System.IO.File]::Exists("$UninstallFolder\DG_PANDAPROT8_XX.exe")) {
        Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/sbrathwaite/Hors/master/dg_aether/DG_PANDAPROT8_XX.exe" -OutFile $UninstallFolder\DG_PANDAPROT8_XX.exe    
    }
    
    # Download Upgrade assistant for Windows
    Invoke-WebRequest -Uri "https://download.microsoft.com/download/8/3/c/83c39dca-2d27-4c24-b98b-0a4d6d921c80/Windows10Upgrade9252.exe" -OutFile "C:\temp\Windows10Upgrade9252.exe";
    
    # Download Script
    if (![System.IO.File]::Exists("C:\PandaAvinstallation\uninstaller.exe")) {
        Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/sbrathwaite/Hors/master/EnableDefender.ps1" -OutFile $UninstallFolder\EnableDefender.ps1
    }
    
    Write-Host "Files downloaded to $UninstallFolder" -ForegroundColor Green
} else {
    Write-Warning "Files Already exists in $UninstallFolder";
}
