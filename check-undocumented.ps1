$xmlContent = Get-Content -Path "Docs/xml/index.xml" -Raw
[xml]$doxygenXml = $xmlContent

$undocumentedMethods = $doxygenXml.SelectNodes("//member[@kind='function'][not(comment) or not(comment/briefdescription) or not(comment/detaileddescription) or not(comment/inbodydescription)]")

if ($undocumentedMethods.Count -gt 0) {
    Write-Host "Undocumented methods found or incomplete documentation. Build failed."

    foreach ($method in $undocumentedMethods) {
        $methodName = $method.name
        $methodLocation = $method.SelectSingleNode("ancestor::compound/compoundname").InnerText
        Write-Host "Undocumented method: $methodName (Location: $methodLocation)"
    }

    exit 1
} else {
    Write-Host "All methods have complete documentation. Build successful."
}
