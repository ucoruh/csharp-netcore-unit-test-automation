$ErrorActionPreference = 'Stop'
$coverageThreshold = 100.00
$coverageReportPath = Get-ChildItem -Recurse -Filter 'coverage.cobertura.xml' | Select-Object -ExpandProperty FullName

$lines = Get-Content $coverageReportPath
$xmlContent = $lines -join "`n"

$coverageXmlList = $xmlContent -split "<\?xml"

$totalLines = 0
$coveredLines = 0

foreach ($coverageXmlString in $coverageXmlList) {
    if ($coverageXmlString.Trim() -ne '') {
        $coverageXmlString = "<?xml" + $coverageXmlString
        [xml]$coverageXml = $coverageXmlString

        $lineRate = $coverageXml.SelectSingleNode("//coverage").GetAttribute("line-rate")
        $coverage = [float]$lineRate * 100.00

        if ($coverage -lt $coverageThreshold) {
            Write-Host "Current test coverage is below the threshold of $coverageThreshold%."
            Write-Host "Current test coverage: $coverage%."
            exit 1
        }
    }
}
