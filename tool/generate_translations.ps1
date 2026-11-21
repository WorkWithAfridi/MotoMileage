param([string]$ProjectRoot = (Split-Path -Parent $PSScriptRoot))

# This developer tool sends extracted user-facing strings to Google Translate.
# Run it only when exporting that text to the third-party service is approved.

$ErrorActionPreference = 'Stop'
$sourceRoot = Join-Path $ProjectRoot 'lib/app'
$outputPath = Join-Path $sourceRoot 'localization/translations.g.dart'
$utf8 = New-Object System.Text.UTF8Encoding($false)
$languages = [ordered]@{
  en = 'en'; zh = 'zh-CN'; hi = 'hi'; es = 'es'; fr = 'fr'
  bn = 'bn'; pt = 'pt'; ru = 'ru'; id = 'id'
}

function ConvertFrom-DartLiteral([string]$value) {
  return $value.Replace("\'", "'").Replace('\n', "`n").Replace('\\', '\')
}

function ConvertTo-DartLiteral([string]$value) {
  return $value.Replace('\', '\\').Replace("'", "\'").Replace('$', '\$').Replace("`r", '').Replace("`n", '\n')
}

function Test-UserFacing([string]$value) {
  if ([string]::IsNullOrWhiteSpace($value) -or $value.Length -lt 2) { return $false }
  if ($value -match '^(package:|\.\.?/|assets/|lib/|https?://)') { return $false }
  if ($value -match '\.(dart|json|csv|db|png|jpg|jpeg)$') { return $false }
  if ($value -cmatch '^[a-z0-9_./-]+$') { return $false }
  if ($value -match '^(dd MMM yyyy|yyyy-MM|MM/yyyy)$') { return $false }
  return $value -match '[A-Za-z]'
}

function Protect-Placeholders([string]$value) {
  $script:placeholderCount = 0
  return [regex]::Replace($value, '\$\{[^}]+\}|\$[A-Za-z_][A-Za-z0-9_]*', {
    param($match)
    $token = "ZXQ$script:placeholderCount`QXZ"
    $script:placeholderCount++
    return $token
  })
}

function Restore-Placeholders([string]$value, [int]$count) {
  $result = $value
  for ($index = 0; $index -lt $count; $index++) {
    $result = $result.Replace("ZXQ$index`QXZ", "@p$index")
    $result = $result.Replace("zxq$index`qxz", "@p$index")
  }
  return $result
}

function Invoke-Translation([string]$text, [string]$targetLanguage) {
  if ($targetLanguage -eq 'en') { return $text }
  $encoded = [Uri]::EscapeDataString($text)
  $uri = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=$targetLanguage&dt=t&q=$encoded"
  for ($attempt = 1; $attempt -le 4; $attempt++) {
    try {
      $response = Invoke-RestMethod -Uri $uri -Method Get -TimeoutSec 30
      return (($response[0] | ForEach-Object { $_[0] }) -join '')
    } catch {
      if ($attempt -eq 4) { throw }
      Start-Sleep -Milliseconds (300 * $attempt)
    }
  }
}

function Invoke-TranslationBatch([string[]]$texts, [string]$targetLanguage) {
  if ($targetLanguage -eq 'en') { return $texts }
  $delimiter = '928374650192837465'
  $joined = [string]::Join("`n$delimiter`n", $texts)
  $translated = Invoke-Translation $joined $targetLanguage
  $parts = @([regex]::Split($translated, "\s*$delimiter\s*"))
  if ($parts.Count -eq $texts.Count) { return $parts }
  return @($texts | ForEach-Object { Invoke-Translation $_ $targetLanguage })
}

$catalog = New-Object 'System.Collections.Generic.HashSet[string]'
$files = Get-ChildItem $sourceRoot -Recurse -File -Filter *.dart |
  Where-Object { $_.FullName -notmatch '[\\/]localization[\\/]' }
foreach ($file in $files) {
  $content = [IO.File]::ReadAllText($file.FullName)
  foreach ($match in [regex]::Matches($content, "'((?:\\.|[^'])*)'")) {
    $value = ConvertFrom-DartLiteral $match.Groups[1].Value
    if (Test-UserFacing $value) { [void]$catalog.Add($value) }
  }
}
foreach ($value in @(
  'System default', 'App Language', 'English', 'Simplified Chinese', 'Hindi',
  'Spanish', 'French', 'Bengali', 'Portuguese', 'Russian', 'Indonesian',
  'KM', 'MILES', 'LITERS', 'GALLONS', 'PETROL', 'DIESEL', 'OCTANE',
  'ELECTRIC', 'CUSTOM', 'None', 'Required', 'Invalid'
)) { [void]$catalog.Add($value) }

$placeholderPattern = '\$\{[^}]+\}|\$[A-Za-z_][A-Za-z0-9_]*'
$staticKeys = @($catalog | Where-Object { $_ -notmatch $placeholderPattern } | Sort-Object)
$patternKeys = @(
  $catalog |
    Where-Object {
      $_ -match $placeholderPattern -and
      [regex]::Replace($_, $placeholderPattern, '') -match '[A-Za-z]'
    } |
    Sort-Object
)
$allKeys = @($staticKeys + $patternKeys)
$translations = @{}
foreach ($language in $languages.Keys) {
  $translations[$language] = @{}
  $target = $languages[$language]
  for ($offset = 0; $offset -lt $allKeys.Count; $offset += 12) {
    $last = [Math]::Min($offset + 11, $allKeys.Count - 1)
    $batchKeys = @($allKeys[$offset..$last])
    $prepared = @()
    $placeholderCounts = @()
    foreach ($key in $batchKeys) {
      $prepared += Protect-Placeholders $key
      $placeholderCounts += $script:placeholderCount
    }
    $batchTranslations = @(Invoke-TranslationBatch $prepared $target)
    for ($index = 0; $index -lt $batchKeys.Count; $index++) {
      $translations[$language][$batchKeys[$index]] = Restore-Placeholders $batchTranslations[$index] $placeholderCounts[$index]
    }
  }
}

$builder = New-Object System.Text.StringBuilder
[void]$builder.AppendLine("part of 'app_translations.dart';")
[void]$builder.AppendLine()
[void]$builder.AppendLine('const Map<String, Map<String, String>> appTranslationKeys = {')
foreach ($language in $languages.Keys) {
  [void]$builder.AppendLine("  '$language': {")
  foreach ($key in $staticKeys) {
    $escapedKey = ConvertTo-DartLiteral $key
    $escapedValue = ConvertTo-DartLiteral $translations[$language][$key]
    [void]$builder.AppendLine("    '$escapedKey': '$escapedValue',")
  }
  [void]$builder.AppendLine('  },')
}
[void]$builder.AppendLine('};')
[void]$builder.AppendLine()
[void]$builder.AppendLine('final List<AppTranslationPattern> appTranslationPatterns = [')
foreach ($key in $patternKeys) {
  $groups = [regex]::Matches($key, $placeholderPattern).Count
  $parts = [regex]::Split($key, $placeholderPattern)
  $regexBuilder = New-Object System.Text.StringBuilder
  [void]$regexBuilder.Append('^')
  for ($index = 0; $index -lt $parts.Count; $index++) {
    [void]$regexBuilder.Append([regex]::Escape($parts[$index]))
    if ($index -lt $groups) { [void]$regexBuilder.Append('(.+?)') }
  }
  [void]$regexBuilder.Append('$')
  $escapedRegex = ConvertTo-DartLiteral $regexBuilder.ToString()
  [void]$builder.AppendLine('  AppTranslationPattern(')
  [void]$builder.AppendLine("    RegExp('$escapedRegex'),")
  [void]$builder.AppendLine('    {')
  foreach ($language in $languages.Keys) {
    $escapedValue = ConvertTo-DartLiteral $translations[$language][$key]
    [void]$builder.AppendLine("      '$language': '$escapedValue',")
  }
  [void]$builder.AppendLine('    },')
  [void]$builder.AppendLine('  ),')
}
[void]$builder.AppendLine('];')
[IO.File]::WriteAllText($outputPath, $builder.ToString(), $utf8)
Write-Output "Generated $($staticKeys.Count) static and $($patternKeys.Count) parameterized translations."
