# PSScriptAnalyzerReporter
Convert PSScriptAnalyzer output into HTML reports to make it easier to share and analyse the data

When I am providing assistance to customers with PowerShell scripts or even just working on my own projects I often use the [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer) to analyze the script for best practices. I started this project as I had a need to provide the output to a customer in a format that was easier for them to digest and share. 

## Required PowerShell Modules
The following PowerShell modules.
* PSScriptAnalyzer


## Example
The following example demonstrates how to run this tool

```
.\PSScriptAnalyzerReporter.ps1 -CsvPath C:\psscriptanalyzer.output.csv -OutputPath C:\psscriptanalyzerreports\
```

## Versions
This project uses [SemVer](http://semver.org/) for versioning. While the following is an overview of the offical releases, for the detailed versions available, see the [tags on this repository](https://github.com/Matticusau/PSScriptAnalyzerReporter/tags). 

### Unreleased

* None

### 1.0.0.0

* Initial push 

## I found a bug
Create an issue through GitHub and lets work on solving it together :)
	
## Contributing
If you are interested in contributing please check out common DSC Resources [contributing guidelines](https://github.com/PowerShell/DscResource.Kit/blob/master/CONTRIBUTING.md). These are the standards I try and adopt for ALL of my work as well.

## License
This project is released under the [MIT License](https://github.com/Matticusau/PSScriptAnalyzerReporter/blob/master/LICENSE)

## Contributors

* Matticusau [GitHub](https://github.com/Matticusau) | [twitter](https://twitter.com/matticusau)
