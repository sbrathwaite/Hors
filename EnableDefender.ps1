if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    Start-Process powershell -Verb RunAs "iwr -UseBasicParsing https://raw.githubusercontent.com/sbrathwaite/Hors/master/EnableDefender.ps1 | iex"
    exit;
}

# $pandaProds = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "Panda *" };
# if ( $pandaProds ) { 
#     Write-Host "One or more Panda products are still installed." -ForegroundColor Red;
# }

# Check if reg keys are set correctly
$Keys = @(
    "DisableAntiSpyware",
    "DisableAntiVirus"
)
Foreach ($Key in $Keys) {
    # Check if keys exists first
    # Get-MpComputerStatus | Select -Property AntispywareEnabled, AntivirusEnabled
    $KeyValue = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows Defender" -Name $Key
    if (!(Test-Path $KeyValue)) {
        Write-Host "Reg key for AntiSpyware, AntiVirus does not exists, using alternative check...";
        break;
    }
    if ($KeyValue -ne 0) {
        Write-Host "Windows Defender registry key: " $Key " is not configured correctly" -ForegroundColor Red;
        Write-Host "Attempting to configure...";
        try {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Defender" -Name $Key -Value 0 -Type REG_DWORD;
        }
        catch {
            Write-Host "Failed to configure registry key" -ForegroundColor Red;
            Read-Host -Prompt "Press Enter to exit";
        }
    }
    else {
        Write-Host "Windows Defender registry key: " $Key " is configured correctly" -ForegroundColor Green;
    }
}

# Change some Defender configurations
# Action mapping
# 0 - Clean
# 1 - Quarantine
# 2 - Remove
# 3 - Allow
# 4 - UserDefined
# 5 - NoAction
# 6 - Block
if((Get-Module -ListAvailable -Name defender) -ne $null) {
    Write-Host "Attempting to configure Defender"
    try {
        Set-MpPreference -EnableNetworkProtection Enabled | Out-Null
        Set-MpPreference -HighThreatDefaultAction 2 | Out-Null
        Set-MpPreference -SevereThreatDefaultAction 2 | Out-Null
        Set-MpPreference -DisableRealtimeMonitoring $false | Out-Null
        Set-MpPreference -SubmitSamplesConsent 3 | Out-Null
        Write-Host "Done"
    }
    catch {
        Write-Host "Failed to set preferences"
    }
} else {
    Write-Host "Defender module does not exists" -ForegroundColor Red
}


# Enable Windows Firewall on all network profiles
try {
    Write-Host "Enabling Windows Firewall";
    Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled True;
}
catch {
    Write-Host "Failed to enable Windows Firewall" -ForegroundColor Red;
}

#Check to see if Windows Defender service is running
$Service = Get-Service WinDefend
if ($Service.Status -eq "Running") {
    Write-Host $Service.DisplayName" is running" -ForegroundColor Green
}
else {
    Write-Host $Service.DisplayName" is not running" -ForegroundColor Yellow
    Write-Host "Attempting to start..."
    try {
        Start-Service $Service              
    }
    catch {
        Write-Host "Failed to start service: " $Service.DisplayName -ForegroundColor Red
        Read-Host -Prompt "Press Enter to exit"
        exit
    }
}
# Set spotify Firewall exceptions

# Exe
try {
    New-NetFirewallRule -DisplayName "Allow Spotify" -Direction Outbound -Program "%APPDATA%\Spotify\Spotify.exe" -Action Allow -Profile Domain,Public,Private    
}
catch {
    Write-Warning "Could not create Windows Firewall rule for spotify, do it manually."
}

try {
    Remove-Item -Path "C:\PandaAvinstallation" -Recurse -Force
}
catch {
    Write-Warning "Could not remove 'PandaAvinstalltion' folder, remove it manually"    
}

Read-Host -Prompt "Press Enter to restart PC"
Restart-Computer
