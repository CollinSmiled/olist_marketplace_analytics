Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$environmentFile = Join-Path $projectRoot ".env"
$rawDataDirectory = Join-Path $projectRoot "data\raw"


function Invoke-ComposeStep {
    param(
        [Parameter(Mandatory)]
        [string]$Description,

        [Parameter(Mandatory)]
        [string[]]$ComposeArguments
    )

    Write-Host "`n==> $Description" -ForegroundColor Cyan

    & docker compose @ComposeArguments

    if ($LASTEXITCODE -ne 0) {
        throw "$Description failed with exit code $LASTEXITCODE."
    }
}


if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw "Docker is not installed or is not available on PATH."
}

if (-not (Test-Path -LiteralPath $environmentFile -PathType Leaf)) {
    throw "Missing .env file. Copy .env.example to .env first."
}

$csvFiles = @(
    Get-ChildItem `
        -LiteralPath $rawDataDirectory `
        -Filter "*.csv" `
        -File `
        -ErrorAction SilentlyContinue
)

if ($csvFiles.Count -eq 0) {
    throw "No CSV files were found in data/raw."
}

Push-Location $projectRoot

try {
    Invoke-ComposeStep `
        -Description "Validating Docker Compose configuration" `
        -ComposeArguments @("config", "--quiet")

    Invoke-ComposeStep `
        -Description "Building ingestion and dbt images" `
        -ComposeArguments @(
            "--profile",
            "tools",
            "build",
            "ingestion",
            "dbt"
        )

    Invoke-ComposeStep `
        -Description "Starting PostgreSQL" `
        -ComposeArguments @("up", "-d", "postgres")

    Invoke-ComposeStep `
        -Description "Loading raw Olist data" `
        -ComposeArguments @(
            "--profile",
            "tools",
            "run",
            "--rm",
            "ingestion"
        )

    Invoke-ComposeStep `
        -Description "Building and testing dbt models" `
        -ComposeArguments @(
            "--profile",
            "tools",
            "run",
            "--rm",
            "dbt",
            "build"
        )
}
finally {
    Pop-Location
}

Write-Host "`nPipeline completed successfully." -ForegroundColor Green
Write-Host "PostgreSQL remains running for Power BI."