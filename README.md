# Vsix Tools

[![Build Status](https://dev.azure.com/sboulema/VsixTools/_apis/build/status/VsixTools-CI)](https://dev.azure.com/sboulema/VsixTools/_build/latest?definitionId=3)
[![Beerpay](https://beerpay.io/sboulema/VsixTools/badge.svg?style=flat)](https://beerpay.io/sboulema/VsixTools)

Vsix Tools is a set of extensions for Azure DevOps that:
1. Populates the version in a vsix manifest file from a build.
2. Uploads the vsix to the [Open VSIX gallery](http://vsixgallery.com/).
3. Uploads the vsix to a MyGet Vsix Feed.

## Examples
## UpdateVersion
```yml
steps:
- task: VsixToolsUpdateVersion@1
  displayName: 'Set Vsix Version'
  inputs:
    FileName: 'source.extension.vsixmanifest' # Default: 'source.extension.vsixmanifest'
    VersionNumber: 1.0.0 # Default: '$(Build.BuildNumber)'
```

### Arguments
| Argument      | Description   |
| ------------- |:------------- |
| FileName      | (Optional) Path to the source.extension.vsixmanifest file                                   |
| VersionNumber | (Optional) Version number to use in the manifest file, must be a valid version eg. 4.5.12.0 |

## UploadVsix
```yml
steps:
- task: VsixToolsUploadVsix@1
  displayName: 'Upload Vsix'
  inputs:
    UploadTo: 'OpenGallery' # Options: 'OpenGallery', 'MyGetVsix'; Default: OpenGallery
    WorkingDirectory: '$(Build.ArtifactStagingDirectory)' # Default: '$(Build.ArtifactStagingDirectory)'
    ConnectedServiceName: 'MyGetVsix'
```

### Arguments
| Argument      | Description   |
| ------------- |:------------- |
| UploadTo             | (Optional) Destination for the uploaded Vsix               |
| WorkingDirectory     | (Optional) Location of the folder containing the Vsix file |
| ConnectedServiceName | (Required if UploadTo set MyGetVsix) Name of the MyGet Vsix service connection to use for upload                      |

## Thanks
- [Bleddyn Richards](https://github.com/BMuuN/vsts-assemblyinfo-task) basing this task on his Assembly Info task
- [Mads Kristensen](https://github.com/madskristensen/ExtensionScripts) for his Vsix Appveyor module
