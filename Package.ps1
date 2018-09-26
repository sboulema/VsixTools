Remove-Item *.vsix

$vsixToolsExtension = (Get-Item -Path ".\" -Verbose).FullName + "\src" 
tfx extension create --manifest-globs vss-extension.json --root $vsixToolsExtension

# Task - UpdateVersion
tfx build tasks delete --task-id 8aa837cb-7cd5-45f5-b7df-3ed54593621a
tfx build tasks upload --task-path "$vsixToolsExtension\tasks\updateVersion"

# Task - UploadVsix
tfx build tasks delete --task-id 76c103d8-c5e8-4f03-acaf-e31fbb276c84
tfx build tasks upload --task-path "$vsixToolsExtension\tasks\uploadVsix"

#tfx extension install --service-url "https://dev.azure.com/sboulema" --vsix (Get-Item -Path ".\*.vsix" -Verbose).FullName