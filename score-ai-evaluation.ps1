$expectedPath = Join-Path $PSScriptRoot "expected-results.csv"
$actualPath = Join-Path $PSScriptRoot "actual-results.csv"

$expected = Import-Csv $expectedPath
$actual = Import-Csv $actualPath

$results = @()

foreach ($test in $expected) {

    $match = $actual | Where-Object {
        $_.testId -eq $test.testId
    } | Select-Object -First 1

    $categoryPass = $false
    $reviewPass = $false

    if ($null -ne $match) {
        $categoryPass = (
            $match.category -eq $test.expectedCategory
        )

        $reviewPass = (
            $match.requiresHumanReview.ToString().ToLower() -eq
            $test.expectedReview.ToString().ToLower()
        )
    }

    $results += [PSCustomObject]@{
        Test = $test.testName
        Found = ($null -ne $match)
        CategoryPass = $categoryPass
        ReviewPass = $reviewPass
        OverallPass = (
            $categoryPass -and $reviewPass
        )
    }
}

$results | Format-Table -AutoSize

$total = @($results).Count
$passed = @($results | Where-Object OverallPass).Count

if ($total -eq 0) {
    Write-Host "No evaluation cases found."
    exit 1
}

$accuracy = [math]::Round(($passed / $total) * 100, 2)

Write-Host ""
Write-Host "Total Tests: $total"
Write-Host "Passed: $passed"
Write-Host "Overall Pass Rate: $accuracy%"

$reportPath = Join-Path $PSScriptRoot "evaluation-report.csv"

$results | Export-Csv -Path $reportPath -NoTypeInformation

Write-Host "Report saved to: $reportPath"
