[CmdletBinding()]
param (
    [Parameter(Mandatory=$True)]
    [String]$FileName,

    [Parameter(Mandatory=$True)]
    [string]$VersionNumber
)

. "$PSScriptRoot\Vsix.ps1"

# Set a flag to force verbose as a default
$VerbosePreference = 'Continue' # equiv to -verbose

Function Main() {

    Vsix-IncrementVsixVersion $FileName $VersionNumber

}

Main