
Param(
    # Specifies a Path to the CSV output file of PSScriptAnalyser.
    [Parameter(Mandatory=$true,
               Position=0,
               ParameterSetName="Path",
               ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true,
               HelpMessage="Path to the CSV output file of PSScriptAnalyser.")]
    [ValidateNotNullOrEmpty()]
    [string]
    $CsvPath
    ,
    # Specifies the path to save the HTML report to.
    [Parameter(Mandatory=$true,
               Position=1,
               ParameterSetName="Path",
               ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true,
               HelpMessage="Path to save the HTML report to.")]
    [ValidateNotNullOrEmpty()]
    [string]
    $OutputPath
    ,
    # Specifies the friendly name of the report to show in the HTML
    [Parameter(Mandatory=$false,
               Position=2,
               ParameterSetName="Path",
               ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true,
               HelpMessage="The friendly name of the report to show in the HTML.")]
    [ValidateNotNullOrEmpty()]
    [string]
    $ReportName = 'PSScriptAnalyzer Report'
)

if (!(Test-Path -Path $CsvPath))
{
    Write-Error -Message "Cannot find CSV File: $CsvPath";
    Exit;
}

# output file
$outputFile = Join-Path -Path $OutputPath -ChildPath "$(Split-Path -Path $CsvPath -Leaf).html";

# get the report
$scriptReportCsv = Import-Csv -Path $CsvPath;

$icons = @{
    Information = 'images\Information_xsmall.png';
    Success = 'images\Success_xsmall.png';
    Warning = 'images\Warning_xsmall.png';
    Critical = 'images\Critical_xsmall.png';
}
$cssPath = '.\css\PSScriptAnalyzerReporter.css';

[string]$htmlReportHdr = @"
<html>
<head>
    <style>
        .tblIssue
        {
            border-style: solid;
            border-width: 1px;
            width: 80%;
        }
        .tdBordered
        {
            border-style: solid;
            border-width: 1px;
        }
        .tdCritical 
        {
            background-color: DarkRed;
            color: White;
        }
        .tdWarning 
        {
            background-color: Orange;
            color: Black;
        }
        .tdLow 
        {
            background-color: Blue;
            color: White;
        }
        .tdInformation 
        {
            background-color: Green;
            color: White;
        }
        .tdColHdr
        {
            align: center;
        }
        .tdText
        {
            align: Left;
        }
        .ReportHeader
        {
            font-size: 24pt;
            align: center;
            max-width: 800px;
        }
        .ReportSubHeader
        {
            font-size: 18pt;
            align: center;
            max-width: 800px;
        }
        .ReportDateTime
        {
            font-size: 12pt;
            align: center;
            max-width: 800px;
        }
        .Spacer
        {
            height: 15px;
        }
    </style>
</head>
<body>
<div class="ReportHeader">[ReportName]</div>
<div class="ReportDateTime">[ReportDateTime]</div>
"@;

[string]$htmlReportFtr = @"
<div class="spacer"></div>
<hr />
<div class="spacer"></div>
<div class="ReportDateTime">[ReportDateTime]</div>
</body>
</html>
"@;

[string]$htmlScriptHdr = @"
<hr />
<div class="spacer"></div>
<div class="ReportHeader">[ScriptName]</div>
"@

[string]$htmlScriptFtr = @"
<div class="spacer"></div>
<div class="spacer"></div>
"@

[string]$htmlIssueTemplate = @"
<table class="tblIssue">
<tr>
    <td class="tdBordered tdColHdr"><img src="images\[Severity]_xsmall.png" alt="[Severity]"></td>
    <th class="tdBordered tdText">[Message]</th>
</tr>
<tr>
    <th class="tdBordered tdColHdr">Rule</th>
    <td class="tdBordered tdText">[RuleName]</td>
</tr>
<tr>
    <th class="tdBordered tdColHdr" rowspan="2">Source</th>
    <td class="tdBordered tdText">[Extent]</td>
</tr>
<tr>
    <td class="tdBordered tdText">Line: [Line] Column: [Column]</td>
</tr>
</table>
<div class="spacer"></div>
"@;




function Add-ReportValues 
{
    [CmdletBinding()]
    Param(
        [string]$Html
        ,
        $object
    )

    $knownVariables = @('[ScriptName]'
        , '[ReportDateTime]'
        , '[Severity]'
        , '[RuleName]'
        , '[Message]'
        , '[Line]'
        , '[Column]'
        , '[Extent]'
    )

    foreach($var in $knownVariables)
    {
        if ($Html.Contains($var))
        {
            $propName = $var.Replace('[','').Replace(']','');
            if ($null -ne ($object | get-member -MemberType Properties -Name $propName))
            {
                $Html = $Html.Replace($var, $($object.$propName));
            }
        }
    }

    return $Html;
}




# build the report and replace the variables

Add-ReportValues -Html $htmlReportHdr -object ([PSCustomObject]@{ReportName = $ReportName; ReportDateTime = Get-Date;})  | Out-File -FilePath $outputFile;



# loop on scripts
foreach ($script in ($scriptReportCsv.ScriptName | Sort-object -Unique))
{
    Add-ReportValues -Html $htmlScriptHdr -object ([PSCustomObject]@{ScriptName = $script;})  | Out-File -FilePath $outputFile -Append;

    foreach ($issue in ($scriptReportCsv | Where-Object ScriptName -eq $script))
    {
        Add-ReportValues -Html $htmlIssueTemplate -object $issue | Out-File -FilePath $outputFile -Append;
    }

    Add-ReportValues -Html $htmlScriptFtr -object ([PSCustomObject]@{ScriptName = $script;})  | Out-File -FilePath $outputFile -Append;
}

Add-ReportValues -Html $htmlReportFtr -object ([PSCustomObject]@{ReportDateTime = Get-Date;}) | Out-File -FilePath $outputFile -Append;