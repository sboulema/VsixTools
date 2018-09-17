# Vsix Tools
Vsix Tools is an extension for Azure DevOps that populates the version in a vsix manifest file from a build.

## YAML example
```
steps:
- task: SamirBoulema.Vsix-Tools.Vsix-Tools-Update-Version.Vsix-Tools-Update-Version@1
  displayName: 'Set Vsix Version'
  inputs:
    FileName: source.extension.vsixmanifest
    VersionNumber: 1.0.0
```

```
steps:
- task: SamirBoulema.Vsix-Tools.Vsix-Tools-Upload-Vsix.Vsix-Tools-Upload-Vsix@1
  displayName: 'Upload Vsix to VsixGallery'
  inputs:
    WorkingDirectory: '$(Build.ArtifactStagingDirectory)'
```

## Documentation
Read more about using the available tasks at the [Overview](Overview.md)

## Thanks
- [Bleddyn Richards](https://github.com/BMuuN/vsts-assemblyinfo-task) basing this task on his Assembly Info task
- [Mads Kristensen](https://github.com/madskristensen/ExtensionScripts) for his Vsix Appveyor module