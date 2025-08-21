
wsl.exe -- rm -r -f ~/ipxe/src/bin* 

while ( $true ) { try { stop-transcript } catch { break} }
if (![string]::IsNullOrEmpty($PSScriptRoot)) {
    remove-item -Recurse -Force $PSScriptRoot\Build\Block
    remove-item -Recurse -Force $PSScriptRoot\Build\signed
    remove-item -Recurse -Force $PSScriptRoot\Build\tmp
    remove-item -Recurse -Force $PSScriptRoot\Build\Unsigned
}
