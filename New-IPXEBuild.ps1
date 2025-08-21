<#
.SYNOPSIS
    A short one-line action-based description, e.g. 'Tests if a function is valid'
.DESCRIPTION
    A longer description of the function, its purpose, common use cases, etc.
.EXAMPLE
    Test-MyTestFunction -Verbose
    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
#>
[CmdletBinding()]
param (
    [string] $Config = 'DeploymentLive',
    [string] $WSLipxe = '~/ipxe',
    [string] $WSLscript = '~/ipxebuild',
    [string] $Tag  =  'build'
)

#region Initialize 

$ScriptRoot = '.'
if (![string]::IsNullOrEmpty($PSscriptRoot)) { 
    $ScriptRoot = $PSScriptRoot
}

if ( -not ( test-path "$scriptroot\..\iPXEPreProcessor\Invoke-IPXEPreProcessor.ps1" )) { Throw "Missing Pre-Compiler" }
$iPXEPreCompiler = "$scriptroot\..\iPXEPreProcessor\Invoke-IPXEPreProcessor.ps1"

import-module DeploymentLiveModule -force -ErrorAction stop

$ConfigDir = "$ScriptRoot/customers/$Config"
$WSLTarget = "$WSLScript/Build"

$WSLFullTarget = wsl --cd ~ -- echo $WSLTarget
$WSLFullConfig = wsl --cd ~ -- echo "$WSLscript/customers/$Config"

$TargetDir = "$ScriptRoot/Build"

foreach ( $Dir in @( $TargetDir,"$TargetDir/Tmp","$TargetDir/Unsigned","$TargetDir/Signed","$TargetDir/Block" )) {
    new-item -ItemType Directory $Dir -ErrorAction SilentlyContinue | Write-Verbose
}

$BuildSummary = @{ FilePath = "$ScriptRoot\build\BuildSummary.txt"; Append = $True }
('*' * 80) | out-file @BuildSummary

while ( $true ) { try { stop-transcript } catch { break} }
Start-Transcript -OutputDirectory $TargetDir <# -UseMinimalHeader #> | out-file @BuildSummary

#region Generate Version

if ( !(test-path "$ConfigDir\Assets\Version.clixml" )) { throw "Missing version.clixml" }

$Oldversion = import-clixml "$ConfigDir\Assets\Version.clixml"
$YearMonth = ([datetime]::now.year -2000) * 100 + [datetime]::now.month
$DayHour = ([datetime]::now.day) * 100 + [datetime]::now.hour
$NewVersion = [version]::new($OldVersion.Major,$YearMonth,$DayHour,$OldVersion.revision + 1)
$NewVersion | Export-Clixml "$ConfigDir\Assets\Version.clixml"
$NewVersion | write-verbose

#endregion

#endregion 

#region Build binaries.

$Builds = Import-CSV $ConfigDir\Assets\build.csv
$i = 0
foreach ( $Build in $Builds ) {
    $Build | Write-Verbose
    write-progress -Activity $Build.FriendlyName -PercentComplete ( $i++ / $Builds.count * 100 ) -ErrorAction 'SilentlyContinue'

    #region Filter out only those that match the tag
    if( (![string]::IsNullOrEmpty($Tag)) -and ( $Build.tag -notmatch $Tag ) ) {
        write-verbose "Skip Type: $($Build.Tag) not match [$Tag]    $($build.FriendlyName)"
        "    SKIP: $($build.FriendlyName)" | out-file @BuildSummary
        continue
    }
    #endregion

    #region Build Embedded scripts
    # I prefer to put the friendly name and version in for testing.
    $ScriptSources = @( "$ConfigDir\Assets\embedded.sh","$ScriptRoot/customers\_common\common.sh" )
    if ( Compare-FilesIfNewer -dest "$TargetDir/Tmp/$($Build.FriendlyName).ipxe" -Path $ScriptSources ) {
        write-verbose "Invoke-PXEPreCompiler.ps1  $ConfigDir\Assets\embedded.sh"
        "set build_type $($Build.FriendlyName)" | Out-File -FilePath "$TargetDir/Tmp/version.ipxe" -Encoding utf8 -Force 
        "set script_version $NewVersion" | Out-File -FilePath "$TargetDir/Tmp/version.ipxe" -Encoding utf8 -Append
        & $iPXEPreCompiler -path $ConfigDir\Assets\embedded.sh -include ( "$TargetDir/Tmp" ) | out-file -Encoding ascii "$TargetDir\Tmp\$($Build.FriendlyName).ipxe"

        # & "c:\Program Files\7-Zip\7z.exe" a -tgzip -mx9 "$TargetDir\Tmp\$($Build.FriendlyName).ipxe.gz" "$TargetDir\Tmp\$($Build.FriendlyName).ipxe"
    }
    #endregion

    #region Construct iPXE MAKE command line for WSL
    $iPXECommandLine = @(
        "make"    
        $build.MakeTarget
        "CONFIG=$Config"
        # "DEBUG=asn1" # ,validator,x509,tls,httpcore:3" # cursor
        
        # "EMBED=$WSLFullTarget/tmp/$($Build.FriendlyName).ipxe.gz,$WSLFullConfig/Assets/Logo.png"
        "EMBED=$WSLFullTarget/tmp/$($Build.FriendlyName).ipxe,$WSLFullConfig/Assets/Logo.png"
        "--assume-new=config/config_http.c"
        )

    if ( $Build.Tag -match 'BC' ) {
        $iPXECommandLine += "EXTRA_CFLAGS=""-DHTTP_ENC_PEERDIST=1"""
    }

    if ( $Build.Tag -match 'ImgTrust' ) {
        $iPXECommandLine += "EXTRA_CFLAGS=""-DIMAGE_TRUST_CMD=1"""
    }

    if ( $Build.Certs -eq 'CA' ) {
        Write-Verbose "Only include the CA cert"
        $iPXECommandLine += "CERT=$WSLFullConfig/Certs/ca.crt","TRUST=$WSLFullConfig/Certs/ca.crt"
    }
    elseif ( $Build.Certs -ne 'BOTH' ) {
        Write-Verbose "Include only ipxe CA certs"
    }
    else {
        Write-Verbose "Include All certs"
        $iPXECommandLine += "CERT=$WSLFullConfig/Certs/ca.crt,$WSLscript/customers/_common/ca.crt","TRUST=$WSLFullConfig/Certs/ca.crt,$WSLscript/customers/_common/ca.crt"
    }

    if ( $Build.MakeTarget -match '\-arm64\-' ) {
        $iPXECommandLine += "CROSS=aarch64-linux-gnu-"
    }

    $iPXECommandLine += '2>&1'

    $iPXECommandLine -join " " | Tee-Object @BuildSummary | Write-Verbose
    wsl.exe --cd "$WSLipxe/src" -- $iPXECommandLine 2>&1 
    if ( $LASTEXITCODE -ne 0 ) { 
        write-warning "Failure in Make command"
        "    BUILD COMMAND FAILURE: $($build.FriendlyName)" | out-file @BuildSummary
        continue
    }

    wsl --cd "$WSLipxe/src" ls -la $build.maketarget
    if ( $LASTEXITCODE -eq 0 ) {
        "    BUILD SUCCESS: $($build.FriendlyName)" | out-file @BuildSummary      
        wsl --cd "$WSLipxe/src" cp $build.MakeTarget "$WSLTarget/Unsigned/$($build.FriendlyName)"
    }
    else {
        "    BUILD OUTPUT MISSING: $($build.FriendlyName)" | out-file @BuildSummary
    }

    #endregion

} 

write-progress -Completed -Activity "Done"

#endregion

#region Cleanup
write-verbose "DONE"
Stop-Transcript -ErrorAction SilentlyContinue
#endregion