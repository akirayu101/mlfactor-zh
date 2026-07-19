param(
  [string]$ProjectRoot = (Split-Path -Parent $PSScriptRoot)
)

$pwaHead = @'
<!-- PWA reader enhancements -->
<link rel="manifest" href="manifest.webmanifest"/>
<meta content="width=device-width, initial-scale=1, viewport-fit=cover" name="viewport"/>
<meta content="#173f5f" name="theme-color"/>
<meta content="yes" name="mobile-web-app-capable"/>
<meta content="yes" name="apple-mobile-web-app-capable"/>
<meta content="black-translucent" name="apple-mobile-web-app-status-bar-style"/>
<meta content="&#22240;&#23376;&#25237;&#36164; ML" name="apple-mobile-web-app-title"/>
<link href="images/pwa-icon-180.png" rel="apple-touch-icon" sizes="180x180"/>
<link href="images/pwa-icon.svg" rel="icon" type="image/svg+xml"/>
<script src="theme-init.js"></script>
<link href="pwa.css" rel="stylesheet"/>
<script defer="" src="pwa.js"></script>
<!-- /PWA reader enhancements -->
'@

$pwaStartMarker = '<!-- PWA reader enhancements -->'
$pwaEndMarker = '<!-- /PWA reader enhancements -->'
$legacyEndMarker = '<script defer="" src="pwa.js"></script>'

Get-ChildItem -LiteralPath $ProjectRoot -File -Filter '*.html' |
  Where-Object { $_.Name -ne 'offline.html' } |
  Sort-Object Name |
  ForEach-Object {
    $html = [System.IO.File]::ReadAllText($_.FullName, [System.Text.Encoding]::UTF8)
    if ($html.Contains($pwaStartMarker)) {
      $blockStart = $html.IndexOf($pwaStartMarker, [System.StringComparison]::Ordinal)
      $blockEnd = $html.IndexOf($pwaEndMarker, $blockStart, [System.StringComparison]::Ordinal)
      if ($blockEnd -ge 0) {
        $blockEnd += $pwaEndMarker.Length
      } else {
        $blockEnd = $html.IndexOf($legacyEndMarker, $blockStart, [System.StringComparison]::Ordinal)
        if ($blockEnd -lt 0) {
          Write-Warning "Skipping $($_.Name): incomplete PWA block"
          return
        }
        $blockEnd += $legacyEndMarker.Length
      }

      $updated = $html.Substring(0, $blockStart) + $pwaHead + $html.Substring($blockEnd)
      [System.IO.File]::WriteAllText($_.FullName, $updated, [System.Text.UTF8Encoding]::new($false))
      Write-Output "Refreshed $($_.Name)"
      return
    }
    if (-not $html.Contains('</head>')) {
      Write-Warning "Skipping $($_.Name): missing </head>"
      return
    }

    $headEnd = $html.IndexOf('</head>', [System.StringComparison]::OrdinalIgnoreCase)
    $updated = $html.Insert($headEnd, "$pwaHead`n")
    [System.IO.File]::WriteAllText($_.FullName, $updated, [System.Text.UTF8Encoding]::new($false))
    Write-Output "Updated $($_.Name)"
  }
