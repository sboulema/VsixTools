Function UploadToOpenGallery 
{
    $WorkingDirectory = Get-VstsInput -Name "WorkingDirectory";
    if ([string]::IsNullOrEmpty($WorkingDirectory)) 
    {
        $WorkingDirectory = $env:BUILD_ARTIFACTSTAGINGDIRECTORY;
    }

    $vsixUploadEndpoint = "http://vsixgallery.com/api/upload"
    $repo = ""
    $issueTracker = ""
    $url = ""

    $repoUrl = $env:BUILD_REPOSITORY_URI
    if ($baseRepoUrl -ne "") {
        [Reflection.Assembly]::LoadWithPartialName("System.Web") | Out-Null
        $repo = [System.Web.HttpUtility]::UrlEncode($repoUrl)
        $issueTracker = [System.Web.HttpUtility]::UrlEncode(($repoUrl + "/issues/"))
        $url = ($vsixUploadEndpoint + "?repo=" + $repo + "&issuetracker=" + $issueTracker)
    }

    Write-Host 'Publish to VSIX Gallery...'

    $fileNames = (Get-ChildItem $WorkingDirectory -Recurse -Include *.vsix)

    foreach($vsixFile in $fileNames)
    {
        $bytes = [System.IO.File]::ReadAllBytes($vsixFile)

        try {
            $response = Invoke-WebRequest $url -Method Post -Body $bytes
            Write-Host $response.StatusCode $response.StatusDescription
        }
        catch [Exception] 
        {
            Write-Error $_.Exception.Message
            Write-Error $_
        }
    }
}

Function UploadToMyGet() 
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

    Write-Host 'Publish to MyGet VSIX Feed...'

    $fileNames = (Get-ChildItem $WorkingDirectory -Recurse -Include *.vsix)
    
    foreach($vsixFile in $fileNames)
    {
        $bytes = [System.IO.File]::ReadAllBytes($vsixFile)
    
        try {
            $response = Invoke-WebRequest $url -Method Post -Body $bytes -Headers @{"X-NuGet-ApiKey"=$token}
            Write-Host $response.StatusCode $response.StatusDescription
        }
        catch [Exception] 
        {
            Write-Error $_.Exception.Message
            Write-Error $_
        }
    }
}

Function Main 
{
    $UploadTo = Get-VstsInput -Name "UploadTo";
    
    if ($UploadTo -eq "MyGetVsix") 
    {
        UploadToMyGet
    }
    else 
    {
        UploadToOpenGallery
    }
}

Main