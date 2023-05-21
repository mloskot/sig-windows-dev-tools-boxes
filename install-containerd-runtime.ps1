# Source: https://raw.githubusercontent.com/microsoft/Windows-Containers/Main/helpful_tools/Install-ContainerdRuntime/install-containerd-runtime.ps1
# Changes (mloskot):
# - Bump versions of containerd and nerdctl to latest.
# - Assuming Windows Feature Containers is already installed
# - Remove tests, staging and related functions as unused.
# - Removed unused script arameters
############################################################
# Script to set up a VM instance to run with containerd and nerdctl
############################################################

<#
    .NOTES
        Copyright (c) Microsoft Corporation.  All rights reserved.

        Use of this sample source code is subject to the terms of the Microsoft
        license agreement under which you licensed this sample source code. If
        you did not accept the terms of the license agreement, you are not
        authorized to use this sample source code. For the terms of the license,
        please see the license agreement between you and Microsoft or, if applicable,
        see the LICENSE.RTF on your install media or the root of your tools installation.
        THE SAMPLE SOURCE CODE IS PROVIDED "AS IS", WITH NO WARRANTIES.

    .SYNOPSIS
        Installs the prerequisites for creating Windows containers

    .DESCRIPTION
        Installs the prerequisites for creating Windows containers

    .PARAMETER ContainerDVersion
        Version of containerd to use

    .PARAMETER NerdCTLVersion
        Version of nerdctl to use

    .PARAMETER WinCNIVersion

    .PARAMETER ContainerBaseImage
        Use this to specifiy the URI of the container base image you wish to pull

    .EXAMPLE
        .\install-containerd-runtime.ps1

#>
#Requires -Version 5.0

[CmdletBinding(DefaultParameterSetName="Standard")]
param(
    [string]
    [ValidateNotNullOrEmpty()]
    $ContainerDVersion = "1.7.0",

    [string]
    [ValidateNotNullOrEmpty()]
    $NerdCTLVersion = "1.4.0",

    [string]
    [ValidateNotNullOrEmpty()]
    $WinCNIVersion = "0.3.0",

    [string]
    $ContainerBaseImage
)

$global:ErrorFile = "$pwd\install-container-runtime.err"

function
Install-ContainerDHost
{
    "If this file exists when Install-ContainerDHost.ps1 exits, the script failed!" | Out-File -FilePath $global:ErrorFile

    #
    # Install, register, and start Containerd
    #
    if (Test-Containerd)
    {
        Write-Output "Containerd is already installed."
    }
    else
    {
        Install-Containerd -ContainerDVersion $ContainerDVersion -NerdCTLVersion $NerdCTLVersion -ContainerBaseImage $ContainerBaseImage
    }

    Remove-Item $global:ErrorFile

    Write-Output "Script complete!"
}

$global:AdminPriviledges = $false
$global:ContainerDDataPath = "$($env:ProgramFiles)\container"
$global:ContainerDServiceName = "containerd"

function
Copy-File
{
    [CmdletBinding()]
    param(
        [string]
        $SourcePath,
        
        [string]
        $DestinationPath
    )
    
    if ($SourcePath -eq $DestinationPath)
    {
        return
    }
          
    if (Test-Path $SourcePath)
    {
        Copy-Item -Path $SourcePath -Destination $DestinationPath
    }
    elseif ($null -ne ($SourcePath -as [System.URI]).AbsoluteURI)
    {
        if ($PSVersionTable.PSVersion.Major -ge 5)
        {
            #
            # We disable progress display because it kills performance for large downloads (at least on 64-bit PowerShell)
            #
            $ProgressPreference = 'SilentlyContinue'
            Invoke-WebRequest -Uri $SourcePath -OutFile $DestinationPath -UseBasicParsing
            $ProgressPreference = 'Continue'
        }
        else
        {
            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFile($SourcePath, $DestinationPath)
        } 
    }
    else
    {
        throw "Cannot copy from $SourcePath"
    }
}

function 
Test-Admin()
{
    # Get the ID and security principal of the current user account
    $myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
    $myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
  
    # Get the security principal for the Administrator role
    $adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
  
    # Check to see if we are currently running "as Administrator"
    if ($myWindowsPrincipal.IsInRole($adminRole))
    {
        $global:AdminPriviledges = $true
        return
    }
    else
    {
        #
        # We are not running "as Administrator"
        # Exit from the current, unelevated, process
        #
        throw "You must run this script as administrator"   
    }
}

function 
Install-Containerd()
{
    [CmdletBinding()]
    param(
        [string]
        [ValidateNotNullOrEmpty()]
        $ContainerdVersion,

        [string]
        [ValidateNotNullOrEmpty()]
        $NerdCTLVersion,

        [string]
        [ValidateNotNullOrEmpty()]
        $WinCNIVersion,

        [string]
        $ContainerBaseImage
    )

    Test-Admin

    Write-Output "Downloading containerd, nerdCTL, and Windows CNI binaries..."

    $ContainerdPath = "$Env:ProgramFiles\containerd"
    $NerdCTLPath = "$Env:ProgramFiles\nerdctl"
    $WinCNIPath = "$ContainerdPath\cni\bin"

    # Download and extract desired containerd Windows binaries
    if (!(Test-Path $ContainerdPath)) { mkdir -Force -Path $ContainerdPath | Out-Null }
    if (!(Test-Path $NerdCTLPath)) { mkdir -Force -Path $NerdCTLPath | Out-Null }
    if (!(Test-Path $WinCNIPath)) { mkdir -Force -Path $WinCNIPath | Out-Null }

    $ContainerdZip = "containerd-$ContainerDVersion-windows-amd64.tar.gz"
    Copy-File "https://github.com/containerd/containerd/releases/download/v$ContainerDVersion/$ContainerdZip" "$ContainerdPath\$ContainerdZip"
    tar.exe -xvf "$ContainerdPath\$ContainerdZip" -C $ContainerdPath
    Write-Output "Containerd binaries added to $ContainerdPath"

    #Download and extract nerdctl binaries
    $NerdCTLZip = "nerdctl-$NerdCTLVersion-windows-amd64.tar.gz"
    Copy-File "https://github.com/containerd/nerdctl/releases/download/v$NerdCTLVersion/$NerdCTLZip" "$NerdCTLPath\$NerdCTLZip"
    tar.exe -xvf "$NerdCTLPath\$NerdCTLZip" -C $NerdCTLPath
    Write-Output "NerdCTL binary added to $NerdCTLPath"

    #Download and extract win cni binaries
    $WinCNIZip = "windows-container-networking-cni-amd64-v$WinCNIVersion.zip"
    Copy-File "https://github.com/microsoft/windows-container-networking/releases/download/v$WinCNIVersion/$WinCNIZip" "$WinCNIPath\$WinCNIZip"
    tar.exe -xvf "$WinCNIPath\$WinCNIZip" -C $WinCNIPath
    Write-Output "CNI plugin binaries added to $WinCNIPath"

    Write-Output "Adding $ContainerdPath, $NerdCTLPath, $WinCNIPath to the path"

    $NewPath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name path).path
    if($NewPath.contains("containerd")) {
        Write-Output "$ContainerdPath already in PATH"
    } else {
        $NewPath = "$NewPath;$ContainerdPath\bin;"
    }

    if($NewPath.contains("nerdctl")) {
        Write-Output "$NerdCTLPath already in PATH"
    } else {
        $NewPath = "$NewPath;$NerdCTLPath;"
    }

    Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $NewPath
    $env:Path = $NewPath


    Write-Output "Configuring the containerd service"

    #Configure containerd service
    containerd.exe config default | Out-File $ContainerdPath\config.toml -Encoding ascii

    # Review the configuration. Depending on setup you may want to adjust:
    # - the sandbox_image (Kubernetes pause image)
    # - cni bin_dir and conf_dir locations
    Get-Content $ContainerdPath\config.toml

    # Register and start service
    containerd.exe --register-service

    Start-Containerd

    #
    # Waiting for containerd to come to steady state
    #
    Wait-Containerd

    if(-not [string]::IsNullOrEmpty($ContainerBaseImage)) {
        Write-Output "Attempting to pull specified base image: $ContainerBaseImage"
        nerdctl pull $ContainerBaseImage
    }

    Write-Output "The following images are present on this machine:"
    
    nerdctl images -a | Write-Output
}

function 
Start-Containerd()
{
    Start-Service -Name $global:ContainerdServiceName
}


function 
Stop-Containerd()
{
    Stop-Service -Name $global:ContainerdServiceName
}

function
Remove-Containerd() 
{
    Stop-Containerd
    (Get-WmiObject -Class Win32_Service -Filter "Name='containerd'").delete()
    Remove-Item -r -Force "$Env:ProgramFiles\containerd"
    Remove-Item -r -Force "$Env:ProgramFiles\nerdctl"
}

function 
Test-Containerd()
{
    $service = Get-Service -Name $global:ContainerdServiceName -ErrorAction SilentlyContinue

    return ($null -ne $service)
}


function 
Wait-Containerd()
{
    Write-Output "Waiting for Containerd daemon..."
    $containerdReady = $false
    $startTime = Get-Date

    while (-not $containerdReady)
    {
        try
        {
            nerdctl version | Out-Null

            if (-not $?)
            {
                throw "Containerd daemon is not running yet"
            }

            $containerdReady = $true
        }
        catch 
        {
            $timeElapsed = $(Get-Date) - $startTime

            if ($($timeElapsed).TotalMinutes -ge 1)
            {
                throw "Containerd Daemon did not start successfully within 1 minute."
            } 

            # Swallow error and try again
            Start-Sleep -sec 1
        }
    }
    Write-Output "Successfully connected to Containerd Daemon."
}

try
{
    Install-ContainerDHost
}
catch 
{
    Write-Error $_
}