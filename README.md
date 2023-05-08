basic calculator library and unit test for .NET Core 6.0 in C#.

[![GitHub release badge](https://badgen.net/github/release/ucoruh/csharp-netcore-unit-test-automation/stable)](https://github.com/ucoruh/csharp-netcore-unit-test-automation/releases/latest)

![Ubuntu badge](assets/badge-ubuntu.svg)
![macOS badge](assets/badge-macos.svg)
![Windows badge](assets/badge-windows.svg)

![Tests](badge.svg)

First, let's create a new solution and project using the .NET Core CLI:

```bash
dotnet new sln -n CalculatorLibrary
dotnet new classlib -n CalculatorLibrary
dotnet sln add CalculatorLibrary
```

Then, let's create a `Calculator` class in the `CalculatorLibrary` project with some basic arithmetic methods:

```csharp
namespace CalculatorLibrary
{
    public class Calculator
    {
        public int Add(int a, int b)
        {
            return a + b;
        }

        public int Subtract(int a, int b)
        {
            return a - b;
        }

        public int Multiply(int a, int b)
        {
            return a * b;
        }

        public int Divide(int a, int b)
        {
            if (b == 0)
            {
                throw new DivideByZeroException();
            }
            return a / b;
        }
    }
}
```

Next, let's create a unit test project using the .NET Core CLI:

```bash
dotnet new xunit -n CalculatorLibrary.Tests
dotnet add CalculatorLibrary.Tests/CalculatorLibrary.Tests.csproj reference CalculatorLibrary/CalculatorLibrary.csproj
```

This creates a new xUnit project and adds a reference to the `CalculatorLibrary` project. Also install the `coverlet.msbuild` NuGet package, which will be used to generate test coverage reports in unit test project.

Now, let's write some unit tests for the `Calculator` class in the `CalculatorLibrary.Tests` project:

```csharp
using Xunit;
using CalculatorLibrary;

namespace CalculatorLibrary.Tests
{
    public class CalculatorTests
    {
        [Fact]
        public void TestAdd()
        {
            Calculator calc = new Calculator();
            Assert.Equal(4, calc.Add(2, 2));
        }

        [Fact]
        public void TestSubtract()
        {
            Calculator calc = new Calculator();
            Assert.Equal(2, calc.Subtract(4, 2));
        }

        [Fact]
        public void TestMultiply()
        {
            Calculator calc = new Calculator();
            Assert.Equal(8, calc.Multiply(2, 4));
        }

        [Fact]
        public void TestDivide()
        {
            Calculator calc = new Calculator();
            Assert.Equal(2, calc.Divide(4, 2));
        }

        [Fact]
        public void TestDivideByZero()
        {
            Calculator calc = new Calculator();
            Assert.Throws<DivideByZeroException>(() => calc.Divide(4, 0));
        }
    }
}
```

Finally, we need to configure GitHub Actions to automatically run our tests and release a Windows build of our library. Here's an example `workflow.yml` file:

```yaml
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: windows-latest
    steps:
    - name: Checkout
      uses: actions/checkout@v2

    - name: Setup .NET Core
      uses: actions/setup-dotnet@v1
      with:
        dotnet-version: '6.0.x'

    - name: Install coverlet.msbuild
      run: dotnet add package coverlet.msbuild --version 3.1.0

    - name: Build
      run: dotnet build --configuration Release

    - name: Test
      run: dotnet test --no-build --verbosity normal --collect:"XPlat Code Coverage"

    - name: Generate Coverage Report
      run: reportgenerator "-reports:**/coverage.opencover.xml" "-targetdir:coveragereport" -reporttypes:Html

    - name: Generate Doxygen HTML Report
      uses: doxygen/doxygen-action@v2.2.1
      with:
        config-file: ./Doxyfile

    - name: Compress Doxygen HTML Report
      run: tar -czvf doxygen-report.tar.gz html

    - name: Publish
      run: dotnet publish --configuration Release --output publish

    - name: Create Release
      id: create_release
      uses: actions/create-release@v1
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      with:
        tag_name: ${{ github.ref }}
        release_name: Release ${{ github.ref }}
        body: |
          Changes in this release:
          - Added support for basic arithmetic operations
        draft: false
        prerelease: false

    - name: Upload Release Asset
      uses: actions/upload-release-asset@v1
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      with:
        upload_url: ${{ steps.create_release.outputs.upload_url }}
        asset_path: ./publish/CalculatorLibrary.dll
        asset_name: CalculatorLibrary.dll
        asset_content_type: application/octet-stream

    - name: Upload Coverage Report
      uses: actions/upload-artifact@v2
      with:
        name: coverage-report
        path: coveragereport

    - name: Upload Doxygen HTML Report
      uses: actions/upload-release-asset@v1
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      with:
        upload_url: ${{ steps.create_release.outputs.upload_url }}
        asset_path: ./doxygen-report.tar.gz
        asset_name: doxygen-report.tar.gz
        asset_content_type: application/x-gzip
```

This workflow has two jobs: `build` and `release`. The `build` job runs on every push to or pull request against the `main` branch. It builds the solution in Release configuration and runs the unit tests using the `dotnet build` and `dotnet test` commands. The `release` job runs only after the `build` job succeeds. It publishes the library using the `dotnet publish` command, creates a new release in GitHub with a tag corresponding to the Git ref, and uploads the `CalculatorLibrary.dll` asset to the release.

To set up this workflow in your GitHub repository, create a new file named `.github/workflows/workflow.yml` with the above content, commit and push it to the `main` branch. When a new commit is pushed to the `main` branch or a pull request is created against the `main` branch, GitHub Actions will automatically run the `build` job, and if it succeeds, it will run the `release` job, which will create a new release and upload the `CalculatorLibrary.dll` asset to it.

1. `Install coverlet.msbuild`: Installs the `coverlet.msbuild` NuGet package to enable test coverage collection.

2. `Test`: Runs tests with the `--collect:"XPlat Code Coverage"` flag to enable coverage collection.

3. `Generate Coverage Report`: Generates an HTML coverage report using the `reportgenerator` tool. We assume that the coverage data has been written to an `opencover.xml` file in the `coverage` folder.

4. `Upload Coverage Report`: Uploads the coverage report to the GitHub release as an artifact. The `actions/upload-artifact` action is used for this purpose. The `coveragereport` folder is used as the source directory for the artifact.

Here's an example of how to use the `CalculatorLibrary` in a console application within the same solution:

1. Open Visual Studio and create a new console application project in the same solution where you created the `CalculatorLibrary` project.
2. Add a reference to the `CalculatorLibrary` project by right-clicking on the `Dependencies` node in the `Solution Explorer`, selecting `Add Reference`, and selecting the `CalculatorLibrary` project from the `Projects` tab.
3. In the `Program.cs` file, add the following code:

```csharp
using System;
using CalculatorLibrary;

namespace CalculatorConsoleApp
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Enter two numbers to add:");
            double num1 = double.Parse(Console.ReadLine());
            double num2 = double.Parse(Console.ReadLine());

            double result = Calculator.Add(num1, num2);

            Console.WriteLine($"Result: {result}");
        }
    }
}
```

4. Build and run the console application, and you should see a prompt asking you to enter two numbers to add. After entering the numbers, the application will call the `Add` method of the `Calculator` class from the `CalculatorLibrary`, and display the result.

This is just a simple example, but you can use the `CalculatorLibrary` in your console application to perform other arithmetic operations as well. Just make sure to add the necessary `using` directives and reference the `CalculatorLibrary` project.
