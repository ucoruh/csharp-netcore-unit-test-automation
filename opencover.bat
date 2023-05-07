dotnet test /p:CollectCoverage=true /p:CoverletOutputFormat=opencover
reportgenerator "-reports:**/coverage.opencover.xml" "-targetdir:coveragereport" -reporttypes:Html
start coveragereport\index.html
pause