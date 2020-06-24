if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    Start-Process powershell -Verb RunAs
    exit;
}

# $pandaProds = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "Panda *" };
# if ( -not $pandaProds ) { 
#     Write-Host "No Panda products were found, skip uninstall";
# }
# else {  
#     foreach ($app in $pandaProds) {    
#         Write-Host "Uninstalling $($app.Name) in 3 seconds... " -NoNewline;    
#         Start-Sleep -Seconds 3;    
#         try {      
#             $app.Uninstall();      
#             Write-Host "Done";
#         }    
#         catch {      
#             Write-Host "FAIL" -ForegroundColor Red;    
#         }  
#     }
# }

# Check if reg keys are set correctly
$Keys = @(
    "DisableAntiSpyware",
    "DisableAntiVirus"
)
Foreach ($Key in $Keys) {
    $KeyValue = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows Defender" -Name $Key 
    if ($KeyValue -ne 0) {
        Write-Host "Windows Defender registry key: " $Key " is not configured correctly" -ForegroundColor Red
        Write-Host "Attempting to configure..."
        try {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Defender" -Name $Key -Value 0 -Type REG_DWORD
        }
        catch {
            Write-Host "Failed to configure registry key" -ForegroundColor Red
            Read-Host -Prompt "Press Enter to exit"
        }
    }
    else {
        Write-Host "Windows Defender registry key: " $Key " is configured correctly" -ForegroundColor Green
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
Write-Host "Attempting to configure Defender"
try {
    Set-MpPreference -EnableNetworkProtection Enabled
    Set-MpPreference -HighThreatDefaultAction 2
    Set-MpPreference -SevereThreatDefaultAction 2
    Set-MpPreference -DisableRealtimeMonitoring $false
    Set-MpPreference -SubmitSamplesConsent 3
    Write-Host "Done"
}
catch {
    Write-Host "Failed to configure Windows Defender"
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

Read-Host -Prompt "Press Enter to restart PC"
Restart-Computer
