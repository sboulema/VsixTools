[CmdletBinding()]
param (
    [string][Parameter(Mandatory=$False)]$Url,
    [string][Parameter(Mandatory=$False)]$Token,
    [string][Parameter(Mandatory=$False)]$Directory
)

if (![string]::IsNullOrEmpty($Url)) 
{
    $url = $Url
    $token = $Token
    $WorkingDirectory = $Directory
}
else 
{
    $WorkingDirectory = Get-VstsInput -Name "WorkingDirectory";
    if ([string]::IsNullOrEmpty($WorkingDirectory)) 
    {
        $WorkingDirectory = $env:BUILD_ARTIFACTSTAGINGDIRECTORY;
    }

    $ConnectedServiceName = Get-VstsInput -Name "ConnectedServiceName";
    $endpoint = Get-VstsEndpoint -Name "$ConnectedServiceName"
    $url = $endpoint.url
    $token = $endpoint.auth.parameters.apitoken

    # Make sure we are using the upload endpoint of the Vsix feed
    if (!$url.endswith("/upload")) 
    {
        $url += "/upload"
    }
}

Write-Host 'Publish to MyGet VSIX Feed...'

$fileNames = (Get-ChildItem $WorkingDirectory -Recurse -Include *.vsix)

foreach($vsixFile in $fileNames)
{
    $bytes = [System.IO.File]::ReadAllBytes($vsixFile)

    try {
        # $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        # $headers.Add('X-NuGet-ApiKey', $token)
        # $response = Invoke-WebRequest $url -Method Post -Body $bytes -Headers $headers
        $response = Invoke-WebRequest $url -Method Post -Body $bytes -Headers @{"X-NuGet-ApiKey"=$token}
        Write-Host $response.StatusCode $response.StatusDescription
    }
    catch [Exception] 
    {
        Write-Error $_.Exception.Message
        Write-Error $_
    }
}