Function SignVsix 
{
    $Password = Get-VstsInput -Name "Password";
    $SHA1 = Get-VstsInput -Name "SHA1";
    $WorkingDirectory = Get-VstsInput -Name "WorkingDirectory";
    if ([string]::IsNullOrEmpty($WorkingDirectory)) 
    {
        $WorkingDirectory = $env:BUILD_ARTIFACTSTAGINGDIRECTORY;
    }

    Write-Host 'Getting Secure Certificate'

    $secFileId = Get-VstsInput -Name CertFile -Require
    $secTicket = Get-VstsSecureFileTicket -Id $secFileId
    $secName = Get-VstsSecureFileName -Id $secFileId
    $tempDirectory = Get-VstsTaskVariable -Name "Agent.TempDirectory" -Require
    $collectionUrl = Get-VstsTaskVariable -Name "System.TeamFoundationCollectionUri" -Require
    $project = Get-VstsTaskVariable -Name "System.TeamProject" -Require

    $filePath = Join-Path $tempDirectory $secName
    $fileName = $secName

    Invoke-RestMethod -Uri "$collectionUrl/$project/_apis/distributedtask/securefiles/$($secFileId)?ticket=$($secTicket)&download=true" -UseDefaultCredentials -OutFile $filePath

    Write-Host 'Installing VsixSignTool...'

    & nuget install Microsoft.VSSDK.Vsixsigntool -ExcludeVersion -OutputDirectory $WorkingDirectory
    $VsixSignTool = "$WorkingDirectory\Microsoft.VSSDK.VsixSignTool\tools\vssdk\VSIXSignTool.exe";

    Write-Host 'Signing VSIX...'

    $fileNames = (Get-ChildItem $WorkingDirectory -Recurse -Include *.vsix -File)

    foreach($vsixFile in $fileNames)
    {
        $result = & "$VsixSignTool" sign /f "$filePath" /p "$Password" /sha1 "$SHA1" $vsixFile 2>&1 | Out-String
        if ($result -match "error") 
        {
            Write-Error $result
            exit 1
        }
    }
}

Function Main 
{
    SignVsix
}

Main