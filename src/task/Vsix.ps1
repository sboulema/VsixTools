function Vsix-IncrementVsixVersion {
    [cmdletbinding()]
    param (
        [Parameter(Position=0, Mandatory=0)]
        [string[]]$manifestFilePath = ".\source.extension.vsixmanifest",

        [Parameter(Position=1, Mandatory=0)]
        [string]$buildNumber = $env:BUILD_BUILDNUMBER
    )
    process {
        foreach($manifestFile in $manifestFilePath)
        {
            "Incrementing VSIX version..." | Write-Host  -ForegroundColor Cyan -NoNewline
            $matches = (Get-ChildItem $manifestFile -Recurse)
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
    }
}