Function SignVsix 
{
    $Password = Get-VstsInput -Name "Password";
    $SHA1 = Get-VstsInput -Name "SHA1";
    $Username = Get-VstsInput -Name "Username";
    $PersonalAccessToken = Get-VstsInput -Name "PAT";
    $CertificatePath = Get-VstsInput -Name "CertificatePath";
    $TimestampURL = Get-VstsInput -Name "TimestampURL";
    $TimestampAlgorithm = Get-VstsInput -Name "TimestampAlgorithm";
    $WorkingDirectory = Get-VstsInput -Name "WorkingDirectory";
    if ([string]::IsNullOrEmpty($WorkingDirectory)) 
    {
        $WorkingDirectory = $env:BUILD_ARTIFACTSTAGINGDIRECTORY;
    }

    if (![string]::IsNullOrEmpty($PersonalAccessToken) -AND ![string]::IsNullOrEmpty($Username)) {
        # Base64-encodes the Personal Access Token (PAT) appropriately
        $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $Username,$PersonalAccessToken)))

        Write-Host 'Getting Secure Certificate'

        $secFileId = Get-VstsInput -Name CertFile -Require
        $secTicket = Get-VstsSecureFileTicket -Id $secFileId
        $secName = Get-VstsSecureFileName -Id $secFileId
        $tempDirectory = Get-VstsTaskVariable -Name "Agent.TempDirectory" -Require
        $collectionUrl = Get-VstsTaskVariable -Name "System.TeamFoundationCollectionUri" -Require
        $project = Get-VstsTaskVariable -Name "System.TeamProject" -Require

        $CertificatePath = Join-Path $tempDirectory $secName

        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Authorization", "Basic $base64AuthInfo")
        $headers.Add("Accept", 'application/octet-stream')

        Invoke-RestMethod -Uri "$collectionUrl/$project/_apis/distributedtask/securefiles/$($secFileId)?ticket=$($secTicket)&download=true" -Headers $headers -OutFile $CertificatePath
    }

    Write-Host 'Installing VsixSignTool...'

    & nuget install Microsoft.VSSDK.Vsixsigntool -ExcludeVersion -OutputDirectory $tempDirectory | out-null
    $VsixSignTool = "$tempDirectory\Microsoft.VSSDK.VsixSignTool\tools\vssdk\VSIXSignTool.exe";

    Write-Host 'Signing VSIX...'

    $fileNames = (Get-ChildItem $WorkingDirectory -Recurse -Include *.vsix -File) 

    $args = @()
    $args += "sign"
    $args += "/f"
    $args += "$CertificatePath"
    $args += "/p"
    $args += $Password
    $args += "/sha1"
    $args += "$SHA1"

    if (![string]::IsNullOrEmpty($TimestampURL)) {
        $args += "/tr"
        $args += $TimestampURL
        $args += "/td"
        $args += $TimestampAlgorithm
    }

    foreach($vsixFile in $fileNames)
    {
        & "$VsixSignTool" $args /v $vsixFile
    }
}

Function Main 
{
    SignVsix
}

Main