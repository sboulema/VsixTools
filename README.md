# Vsix Tools

[![Build Status](https://dev.azure.com/sboulema/VsixTools/_apis/build/status/VsixTools-CI)](https://dev.azure.com/sboulema/VsixTools/_build/latest?definitionId=3)
[![Beerpay](https://img.shields.io/beerpay/sboulema/VsixTools.svg?style=flat)](https://beerpay.io/sboulema/VsixTools)

Vsix Tools is a set of extensions for Azure DevOps that:
1. Populates the version in a vsix manifest file from a build.
2. Uploads the vsix to the [Open VSIX gallery](http://vsixgallery.com/).
3. Uploads the vsix to a [MyGet Vsix Feed](https://www.myget.org/vsix).
4. Uploads the vsix to the [Visual Studio Marketplace](https://marketplace.visualstudio.com/).
5. Signs the vsix.

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
    UploadTo: 'OpenGallery' # Options: 'OpenGallery', 'MyGetVsix', 'Marketplace'; Default: OpenGallery
    WorkingDirectory: '$(Build.ArtifactStagingDirectory)' # Default: '$(Build.ArtifactStagingDirectory)'
    ConnectedServiceName: 'MyGetVsix'
    PublishManifest: '**\*.json'
    PersonalAccessToken: '***'
```

### Arguments
| Argument      | Description   |
| ------------- |:------------- |
| UploadTo             | (Optional) Destination for the uploaded Vsix               |
| WorkingDirectory     | (Optional) Location of the folder containing the Vsix file |
| ConnectedServiceName | (Required if UploadTo set to MyGetVsix) Name of the MyGet Vsix service connection to use for upload |
| PublishManifest      | (Required if UploadTo set to Marketplace) Location of the publish manifest json file |
| PersonalAccessToken  | (Required if UploadTo set to Marketplace) Token for publishing to the Marketplace |

## SignVsix
```yml
steps:
- task: VsixToolsSignVsix@1
  displayName: 'Sign Vsix'
  inputs:
    CertFile: 'GUID'
    Password: '***' 
    SHA1: 'xx xx xx'
    WorkingDirectory: '$(Build.ArtifactStagingDirectory)' # Default: '$(Build.ArtifactStagingDirectory)'
```

### Arguments
| Argument      | Description   |
| ------------- |:------------- |
| CertFile              | (Optional) Must be a Secure File Id |
| CertificatePath       | (Optional) Location of the certificate file |
| Password              | (Required) Password for the Certificate |
| SHA1                  | (Required) SHA1 Hash of the Certificate |
| Username              | (Optional) Username for retrieving the CertFile |
| Personal Access Token | (Optional) PAT for retrieving the CertFile |
| TimestampURL          | (Optional) URL to a timestamp server |
| WorkingDirectory      | (Optional) Location of the folder containing the Vsix file |

## Thanks
- [Bleddyn Richards](https://github.com/BMuuN/vsts-assemblyinfo-task) basing this task on his Assembly Info task
- [Mads Kristensen](https://github.com/madskristensen/ExtensionScripts) for his Vsix Appveyor module
- [Utkarsh Shigihalli](https://www.visualstudiogeeks.com/devops/continuous-build-and-deployment-of-visual-studio-extensions) for his 'Continuous build and deployment of Visual Studio extensions using Azure Pipelines' article
- [Mario Majcica](https://github.com/Microsoft/azure-pipelines-task-lib/issues/280) for showing how to download Secure Files
- [Jeff Bramwell](https://blog.devmatter.com/calling-vsts-apis-with-powershell/) for showing how to authenticate using PAT
