Function UploadToOpenGallery 
{
    $WorkingDirectory = Get-VstsInput -Name "WorkingDirectory";
    if ([string]::IsNullOrEmpty($WorkingDirectory)) 
    {
        $WorkingDirectory = $env:BUILD_ARTIFACTSTAGINGDIRECTORY;
    }

    [Reflection.Assembly]::LoadWithPartialName("System.Web") | Out-Null
    $repo = [System.Web.HttpUtility]::UrlEncode($env:BUILD_REPOSITORY_URI)
    $issueTracker = [System.Web.HttpUtility]::UrlEncode(($env:BUILD_REPOSITORY_URI + "/issues/"))
    $url = ("https://www.vsixgallery.com/api/upload?repo=" + $repo + "&issuetracker=" + $issueTracker)

    Write-Host 'Publish to VSIX Gallery...'
    Write-Host $url

    $fileNames = (Get-ChildItem $WorkingDirectory -Recurse -Include *.vsix)

    foreach($fileName in $fileNames)
    {   
        try {
            $webclient = New-Object System.Net.WebClient
            $webclient.UploadFile($url, $fileName) | Out-Null
            'OK' | Write-Host -ForegroundColor Green
        }
        catch{
            'FAIL' | Write-Error
            $_.Exception.Response.Headers["x-error"] | Write-Error
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

Function UploadToMarketplace() 
{
    $PersonalAccessToken = Get-VstsInput -Name "PersonalAccessToken";
    $PublishManifest = Get-VstsInput -Name "PublishManifest";

    $WorkingDirectory = Get-VstsInput -Name "WorkingDirectory";
    if ([string]::IsNullOrEmpty($WorkingDirectory)) 
    {
        $WorkingDirectory = $env:BUILD_ARTIFACTSTAGINGDIRECTORY;
    }

    Install-PackageProvider nuget -force
    Install-Module -Name VSSetup -RequiredVersion 2.2.16 -Scope CurrentUser -Force
    Import-Module -Name VSSetup -Version 2.2.16
    
    $VSSetupInstance = Get-VSSetupInstance | Select-VSSetupInstance -Product * -Require 'Microsoft.VisualStudio.Component.VSSDK'
    $VSInstallDir=$VSSetupInstance.InstallationPath
    $VsixPublisherPath="$VSInstallDir\VSSDK\VisualStudioIntegration\Tools\Bin\VsixPublisher.exe"
    
    Write-Host 'Publish to Marketplace...'

    if (Test-Path $WorkingDirectory -PathType Leaf)
    {
        Write-Host 'Publishing ' + $WorkingDirectory + ' to Marketplace...'

        $result = & "$VSIXPublisherPath" publish -payload "$WorkingDirectory" -publishManifest "$PublishManifest" -personalAccessToken $PersonalAccessToken 2>&1 | Out-String
        if ($result -match "error") 
        {
            exit 1
        }
    }
    else
    {
        $fileNames = (Get-ChildItem $WorkingDirectory -Recurse -Include *.vsix -File)
    
        foreach($vsixFile in $fileNames)
        {    
            Write-Host 'Publishing ' + $vsixFile + ' to Marketplace...'

            $result = & "$VSIXPublisherPath" publish -payload "$vsixfile" -publishManifest "$PublishManifest" -personalAccessToken $PersonalAccessToken 2>&1 | Out-String
            if ($result -match "error") 
            {
                exit 1
            }
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
    elseif ($UploadTo -eq "Marketplace") 
    {
        UploadToMarketplace
    }
    else 
    {
        UploadToOpenGallery
    }
}

Main