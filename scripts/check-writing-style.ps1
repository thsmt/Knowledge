$ErrorActionPreference = "Stop"

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$targetFiles = Get-ChildItem -LiteralPath $repositoryRoot -Recurse -File |
    Where-Object {
        $_.Extension -in ".html", ".md" -and
        $_.FullName -notmatch "[\\/]\.git[\\/]"
    }

$fullStop = [char]0x3002
$patterns = @(
    [regex]::Escape($fullStop) + "\s*</(p|li|td|th|strong|div|h[1-6]|figcaption)>",
    [regex]::Escape($fullStop) + "\s*$"
)

$violations = foreach ($file in $targetFiles) {
    Select-String -LiteralPath $file.FullName -Encoding UTF8 -Pattern $patterns
}

if ($violations) {
    $violations | ForEach-Object {
        "{0}:{1}: {2}" -f $_.Path, $_.LineNumber, $_.Line.Trim()
    }
    throw "Japanese full stop found at the end of a sentence"
}

Write-Host "Writing style check passed"
