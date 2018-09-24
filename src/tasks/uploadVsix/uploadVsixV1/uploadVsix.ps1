[CmdletBinding()]
param (
    [Parameter(Mandatory=$True)]
    [String]$WorkingDirectory
)

# Set a flag to force verbose as a default
$VerbosePreference = 'Continue' # equiv to -verbose

$vsixUploadEndpoint = "http://vsixgallery.com/api/upload"

function Vsix-PublishToGallery {
    [cmdletbinding()]
    param (
        [Parameter(Position=0, Mandatory=0)]
        [string]$workingDirectory = $env:BUILD_ARTIFACTSTAGINGDIRECTORY
    )
    process {
        $repo = ""
        $issueTracker = ""

        $repoUrl = $env:BUILD_REPOSITORY_URI
        if ($baseRepoUrl -ne "") {
            [Reflection.Assembly]::LoadWithPartialName("System.Web") | Out-Null
            $repo = [System.Web.HttpUtility]::UrlEncode($repoUrl)
            $issueTracker = [System.Web.HttpUtility]::UrlEncode(($repoUrl + "/issues/"))
        }

        'Publish to VSIX Gallery...' | Write-Host -ForegroundColor Cyan -NoNewline

        $fileNames = (Get-ChildItem $workingDirectory -Recurse -Include *.vsix)

        foreach($vsixFile in $fileNames)
        {
            [string]$url = ($vsixUploadEndpoint + "?repo=" + $repo + "&issuetracker=" + $issueTracker)
            [byte[]]$bytes = [System.IO.File]::ReadAllBytes($vsixFile)

            try {
                $response = Invoke-WebRequest $url -Method Post -Body $bytes -UseBasicParsing
                'OK' | Write-Host -ForegroundColor Green
            }
            catch{
                'FAIL' | Write-Error
                $_.Exception.Response.Headers["x-error"] | Write-Error
            }
        }
    }
}

Function Main() {

    Vsix-PublishToGallery $WorkingDirectory

}

Main