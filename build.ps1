param(
    [string[]]$Versions = @("3.9", "3.10", "3.11", "3.12", "3.13", "3.14")
)

$ErrorActionPreference = "Stop"

$variants = @{
    "3.9"  = "bookworm"
    "3.10" = "bookworm"
    "3.11" = "bookworm"
    "3.12" = "trixie"
    "3.13" = "trixie"
    "3.14" = "trixie"
}

foreach ($version in $Versions) {
    $variant = if ($variants.ContainsKey($version)) { $variants[$version] } else { "trixie" }
    $tag = "pterodactyl-python:$version"

    Write-Host ""
    Write-Host "========================================"
    Write-Host " Building Python $version"
    Write-Host " Base: $variant"
    Write-Host " Tag:  $tag"
    Write-Host "========================================"

    docker build `
        --build-arg "PYTHON_VERSION=$version" `
        --build-arg "PYTHON_VARIANT=$variant" `
        -t $tag `
        -f docker/python/Dockerfile .

    if ($LASTEXITCODE -ne 0) {
        throw "Build failed for Python $version"
    }

    docker run --rm --entrypoint python $tag --version

    if ($LASTEXITCODE -ne 0) {
        throw "Runtime test failed for Python $version"
    }
}
