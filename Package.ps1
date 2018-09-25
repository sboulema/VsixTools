Remove-Item *.vsix

$vsixToolsExtension = (Get-Item -Path ".\" -Verbose).FullName + "\src" 
tfx extension create --manifest-globs vss-extension.json --root $vsixToolsExtension
#tfx extension install --service-url "https://dev.azure.com/sboulema" --vsix (Get-Item -Path ".\*.vsix" -Verbose).FullName