function UpdateVersion {
    $manifestFilePath = Get-VstsInput -Name "FileName";
    if ([string]::IsNullOrEmpty($manifestFilePath)) 
    {
        $manifestFilePath = ".\source.extension.vsixmanifest";
    }

    $buildNumber = Get-VstsInput -Name "VersionNumber";
    if ([string]::IsNullOrEmpty($buildNumber)) 
    {
        $buildNumber = $env:BUILD_BUILDNUMBER;
    }

    "Incrementing VSIX version..." | Write-Host  -ForegroundColor Cyan -NoNewline
    
    $matches = (Get-ChildItem $manifestFilePath -Recurse)
    $vsixManifest = $matches[$matches.Count - 1] # Get the last one which matches the top most file in the recursive matches
    [xml]$vsixXml = Get-Content $vsixManifest

    $ns = New-Object System.Xml.XmlNamespaceManager $vsixXml.NameTable
    $ns.AddNamespace("ns", $vsixXml.DocumentElement.NamespaceURI) | Out-Null

    $attrVersion = ""

    if ($vsixXml.SelectSingleNode("//ns:Identity", $ns)){ # VS2012 format
        $attrVersion = $vsixXml.SelectSingleNode("//ns:Identity", $ns).Attributes["Version"]
    }
    elseif ($vsixXml.SelectSingleNode("//ns:Version", $ns)){ # VS2010 format
        $attrVersion = $vsixXml.SelectSingleNode("//ns:Version", $ns)
    }

    $attrVersion.InnerText = $buildNumber

    $vsixXml.Save($vsixManifest) | Out-Null

    $buildNumber | Write-Host -ForegroundColor Green
}

Function Main() {

    UpdateVersion

}

Main