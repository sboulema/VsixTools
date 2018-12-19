Function SignVsix 
{
    $Password = Get-VstsInput -Name "Password";
    $SHA1 = Get-VstsInput -Name "SHA1";
    $Username = Get-VstsInput -Name "Username";
    $PersonalAccessToken = Get-VstsInput -Name "PAT";
    $WorkingDirectory = Get-VstsInput -Name "WorkingDirectory";
    if ([string]::IsNullOrEmpty($WorkingDirectory)) 
    {
        $WorkingDirectory = $env:BUILD_ARTIFACTSTAGINGDIRECTORY;
    }

    # Base64-encodes the Personal Access Token (PAT) appropriately
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $Username,$PersonalAccessToken)))

    Write-Host 'Getting Secure Certificate'

    $secFileId = Get-VstsInput -Name CertFile -Require
    $secTicket = Get-VstsSecureFileTicket -Id $secFileId
    $secName = Get-VstsSecureFileName -Id $secFileId
    $tempDirectory = Get-VstsTaskVariable -Name "Agent.TempDirectory" -Require
    $collectionUrl = Get-VstsTaskVariable -Name "System.TeamFoundationCollectionUri" -Require
    $project = Get-VstsTaskVariable -Name "System.TeamProject" -Require

    $filePath = Join-Path $tempDirectory $secName

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Basic $base64AuthInfo")
    $headers.Add("Accept", 'application/octet-stream')

    Invoke-RestMethod -Uri "$collectionUrl/$project/_apis/distributedtask/securefiles/$($secFileId)?ticket=$($secTicket)&download=true" -Headers $headers -OutFile $filePath

    Write-Host 'Installing VsixSignTool...'

    & nuget install Microsoft.VSSDK.Vsixsigntool -ExcludeVersion -OutputDirectory $tempDirectory | out-null
    $VsixSignTool = "$tempDirectory\Microsoft.VSSDK.VsixSignTool\tools\vssdk\VSIXSignTool.exe";

    Write-Host 'Signing VSIX...'

    $fileNames = (Get-ChildItem $WorkingDirectory -Recurse -Include *.vsix -File)

    foreach($vsixFile in $fileNames)
    {
        & "$VsixSignTool" sign /f "$filePath" /p $Password /sha1 "$SHA1" /v $vsixFile
    }
}

Function Main 
{
    SignVsix
}

Main