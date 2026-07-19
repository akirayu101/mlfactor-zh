param(
  [string]$ProjectRoot = (Split-Path -Parent $PSScriptRoot)
)

$pwaHead = @'
<!-- PWA reader enhancements -->
<link rel="manifest" href="manifest.webmanifest"/>
<meta content="#173f5f" name="theme-color"/>
<meta content="yes" name="mobile-web-app-capable"/>
<meta content="yes" name="apple-mobile-web-app-capable"/>
<meta content="black-translucent" name="apple-mobile-web-app-status-bar-style"/>
<meta content="因子投资 ML" name="apple-mobile-web-app-title"/>
<link href="images/pwa-icon-192.png" rel="apple-touch-icon"/>
<link href="images/pwa-icon.svg" rel="icon" type="image/svg+xml"/>
<script src="theme-init.js"></script>
<link href="pwa.css" rel="stylesheet"/>
<script defer="" src="pwa.js"></script>
'@

Get-ChildItem -LiteralPath $ProjectRoot -File -Filter '*.html' |
  Where-Object { $_.Name -ne 'offline.html' } |
  Sort-Object Name |
  ForEach-Object {
    $html = [System.IO.File]::ReadAllText($_.FullName, [System.Text.Encoding]::UTF8)
    if ($html.Contains('<!-- PWA reader enhancements -->')) {
      if (-not $html.Contains('<script src="theme-init.js"></script>')) {
        $updated = $html.Replace(
          '<link href="pwa.css" rel="stylesheet"/>',
          "<script src=`"theme-init.js`"></script>`n<link href=`"pwa.css`" rel=`"stylesheet`"/>"
        )
        [System.IO.File]::WriteAllText($_.FullName, $updated, [System.Text.UTF8Encoding]::new($false))
        Write-Output "Added theme initialization to $($_.Name)"
      }
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
