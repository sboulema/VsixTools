# Vsix Tools
Vsix Tools is an extension for Azure DevOps that populates the version in a vsix manifest file from a build.

## YAML example
```
steps:
- task: SamirBoulema.Vsix-Tools.Vsix-Tools.Vsix-Tools@1
  displayName: 'Set Vsix Version'
  inputs:
    FileName: source.extension.vsixmanifest
    VersionNumber: 1.0.0
```

## Documentation
Read more about using this task at the [Overview](Overview.md)

## Thanks
- [Bleddyn Richards](https://github.com/BMuuN/vsts-assemblyinfo-task) basing this task on his Assembly Info task
- [Mads Kristensen](https://github.com/madskristensen/ExtensionScripts) for his Vsix Appveyor module