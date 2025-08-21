#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Script to install and configure WSL on Windows Host
.DESCRIPTION
    Install and Prepare machine for Windows Services for Linux
.NOTES
    May need to be executed more than once due to reboots. 
.LINK
    https://github.com/DeploymentLive/ipxe
#>

[CmdletBinding()]
param (
    $Distro = 'ubuntu',
    $ipxeRepo = 'https://github.com/DeploymentLive/ipxe.git',
    $ipxeLocal = '~/ipxe',
    $ipxeBuildLocal = '~/ipxebuild'
)

#region Step 0 Initialize 

# https://stackoverflow.com/questions/66127118/why-cannot-i-match-for-strings-from-wsl-exe-output
$env:WSL_UTF8=1 

$ScriptRoot = '.'
if (![string]::IsNullOrEmpty($PSscriptRoot)) { 
    $ScriptRoot = $PSScriptRoot
}

#endregion 

#region Step 1 Ensure WSL Feature is installed

$state = (Get-WindowsOptionalFeature -online -FeatureName Microsoft-Windows-Subsystem-Linux).State

if ( $state -ne [Microsoft.Dism.Commands.FeatureState]::Enabled ) {
    write-verbose "Enable Optional Feature Microsoft-Windows-Subsystem-Linux (May require RESTART)"
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
}

if ( -not ( get-command wsl.exe -ErrorAction SilentlyContinue )) { throw "bad build of Windows no wsl.exe"}

#endregion

#region Step 2 Install Linux Distro 

wsl.exe --status | Write-Verbose
# wsl.exe --version | Write-Verbose

wsl.exe --list  | Write-Verbose
if ( $LASTEXITCODE -eq -1 ) {
    write-verbose "install Linux Distro Ubuntu" 
    wsl.exe --install -d $Distro  --web-download
    echo "launch Ubuntu terminal window and create your default user account."
    Read-Host -Prompt "Press enter to continue"
}

#endregion

#region Step 3 Update everything

write-verbose "Update manifest"
wsl.exe -u root -- apt-get -y update
# wsl.exe -u root -- apt-get -y full-upgrade

#endregion

#region Step 4 Install required tools through apt

if (!((wsl -- apt list --installed gcc ) -match 'gcc' )) {

    write-verbose "Install Required Components"

    # From: https://ipxe.org/download
    $Packages = @"
gcc
gcc-aarch64-linux-gnu
gcc-arm-linux-gnueabi
binutils
binutils-arm-linux-gnueabi
make
perl
liblzma-dev
mtools
mkisofs
syslinux
isolinux
"@ -split "`r`n"

    foreach ( $Package in $Packages ) {

        write-verbose "Install $Package"
        wsl.exe -u root -- apt install -y $Package
    }

}

#endregion

#region Step 5 Upgrade everything

write-verbose "Full Upgrade"
wsl.exe -u root -- apt-get -y full-upgrade

#endregion

#region Step 6 clone or update git repo

wsl -- ls ~/ipxe/src/include
if ( $LASTEXITCODE -eq 2 ) {
    write-verbose "clone repo $ipxeRepo"
    wsl --cd ~ git clone $ipxeRepo
}
else {
    write-verbose "update repo"
    wsl -- cd ~/ipxe ';' git pull origin master
}

#endregion

#region Step 7 Mount remaining folders 

# Mount THIS local directory into WSL is $ipxeBuildLocal
wsl -- ls "$ipxeBuildLocal/customers/branding.h"
if ( $LASTEXITCODE -eq 2 ) {
    write-verbose "Create Shortcut in WSL to this folder."
    $WSLHomePath = wsl -- pwd
    wsl ln -s $WSLHomePath $ipxeBuildLocal
}

# Create Symbolic Links for config/local/*
foreach ( $path in get-item $ScriptRoot\customers\* -exclude _common ) {

    wsl -- ls "$ipxeLocal/src/config/local/$($path.Name)"
    if ( $LASTEXITCODE -eq 2 ) {
        write-verbose "Create a SymLink '$ipxeBuildLocal/customers/$($path.Name)' to '$ipxeLocal/src/config/local/$($path.Name)'"
        wsl -- ln -s "$ipxeBuildLocal/customers/$($path.Name)" "$ipxeLocal/src/config/local/$($path.Name)" -v
    }
}

#endregion
