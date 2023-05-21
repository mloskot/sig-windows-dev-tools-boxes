[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '', Justification = 'Script used internally with dummy password')]
[CmdletBinding(PositionalBinding = $False)]
param
(
    [Parameter(Mandatory = $true)]
    [string]$AdminUser,
    [Parameter(Mandatory = $true)]
    [string]$AdminPassword,
    [Parameter(Mandatory = $true)]
    [string]$NewHostname
)

Write-Host "[provision.ps1] Setting WinRM automatic start"
Set-Service -Name WinRM -StartupType Automatic
#sc config WinRM start= auto

Write-Host "[provision.ps1] Disabling Windows Updates"
Stop-Service wuauserv
Set-Service wuauserv -StartupType Disabled

Write-Host "[provision.ps1] Uninstalling Windows-Server-Antimalware"
Uninstall-WindowsFeature -Name Windows-Server-Antimalware

Write-Host "[provision.ps1] Uninstalling Windows Defender"
Uninstall-WindowsFeature -Name Windows-Defender

Write-Host "[provision.ps1] Uninstalling Windows Features"
Uninstall-WindowsFeature System-DataArchiver # arbitrary pick to die-hard slim down of image
Uninstall-WindowsFeature NET-WCF-Services45  # arbitrary pick to die-hard slim down of image

Write-Host "[provision.ps1] Installing Windows Features"
Install-WindowsFeature Containers # required by ContainerD

Write-Host "[provision.ps1] Setting PowerShell as OpenSSH default shell"
Set-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"

Write-Host "[provision.ps1] Changing computer name to $NewHostname"
$adminPasswordSecure = ConvertTo-SecureString $AdminPassword -AsPlainText -Force
$adminCredential = New-Object System.Management.Automation.PSCredential ($AdminUser, $AdminPasswordSecure)
Rename-Computer -NewName $NewHostname -DomainCredential $adminCredential
