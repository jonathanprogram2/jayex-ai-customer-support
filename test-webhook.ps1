$webhookUrl = $env:JAYEX_WEBHOOK_URL

if ([string]::IsNullOrWhiteSpace($webhookUrl)) {
    throw "JAYEX_WEBHOOK_URL environment variable is not set."
}

$secureKey = Read-Host "7CD197BD223CC5EFB68EAD1772973E8DE2D1D77729ACAC3DC211601CB6883565" -AsSecureString
$apikey = [System.Net.NetworkCredential]::new(
    "",
    $secureKey
).Password

$headers = @{
    "X-API-Key" = $apikey
}

# Test cases
$testCases = @(
    @{
        Name = "Valid inquiry"
        Data = @{
            customerName = "Alex Johnson"
            email = "alex@example.com"
            message = "What are your business hours?"
        }
        ExpectedStatus = 202
    },
    @{
        Name = "Missing email"
        Data = @{
            customerName = "Alex Johnson"
            message = "I need assistance."
        }
        ExpectedStatus = 400
    },
    @{
        Name = "Invalid email"
        Data = @{
            customerName = "Alex Johnson"
            email = "invalid-email"
            message = "Can I book an appointment?"
        }
        ExpectedStatus = 400
    }
)

foreach ($test in $testCases) {
    $body = $test.Data | ConvertTo-Json

    try {
        $response = Invoke-WebRequest `
            -Uri $webhookUrl `
            -Method POST `
            -Headers $headers `
            -ContentType "application/json" `
            -Body $body `
            -SkipHttpErrorCheck

        $actualStatus = [int]$response.StatusCode

        if ($actualStatus -eq $test.ExpectedStatus) {
            Write-Host "PASS: $($test.Name) — HTTP $actualStatus" -ForegroundColor Green
        }
        else {
            Write-Host "FAIL: $($test.Name) — Expected $($test.ExpectedStatus), got $actualStatus"  -ForegroundColor Red
        }
    }
    catch {
        Write-HOST "ERROR: $($test.Name) — $($_.Exception.Message)" -ForegroundColor Red
    }
}

Remove-Variable apiKey, secureKey, headers