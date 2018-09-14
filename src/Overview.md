# Vsix Tools
Vsix Tools is an extension for Azure DevOps that populates the version in a vsix manifest file from a build.

## Parameters

Filename:

VersionNumber:

## How to use the build task
### Configuration
1. Create or edit a build definition.
2. Click **Add build step...** and add the **Assembly Info** task from the Build category.
3. Move the **Vsix Tools** task to the desired position ensuring it precedes the Visual Studio Build task.  

  ![Vsix Tools task position](images/Task_List.png)

4. Configure the task by providing values for the attributes mentioned in the above table.  
> Ensure you specify the file names you wish to populate within the **Source Files** field: -  
> For .Net Framework specify files such as: *AssemblyInfo.cs, AssemblyInfo.vb, GlobalInfo.cs*  
> For .Net Core specify the project filename: *NetCoreLib.csproj*  

  ![Vsix Tools task parameters](images/Task_Parameters.png)

### Help and Support
Please visit our [wiki](https://github.com/BMuuN/vsts-assemblyinfo-task/wiki) for articles describing how to configure the task parameters, including the various version formats supported by the extension.

## Contributions
We welcome all contributions whether it's logging bugs, creating suggestions or submitting pull requests.  
If you wish to contributions to this project head on over to our [GitHub](https://github.com/BMuuN/vsts-assemblyinfo-task) page.

### Release Notes
See the [release notes](https://github.com/BMuuN/vsts-assemblyinfo-task/blob/master/ReleaseNotes.md) for all changes included in each release.