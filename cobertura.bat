dotnet test --verbosity normal --collect:"XPlat Code Coverage"
reportgenerator "-reports:**/coverage.cobertura.xml" "-targetdir:coveragereport" -reporttypes:Html
reportgenerator "-reports:**/coverage.cobertura.xml" "-targetdir:assets" -reporttypes:Badges
start coveragereport\index.html
pause