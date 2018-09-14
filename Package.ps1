Remove-Item *.vsix

$vsixToolsExtension = (Get-Item -Path ".\" -Verbose).FullName + "\src" 
tfx extension create --manifest-globs vss-extension.json --root $vsixToolsExtension