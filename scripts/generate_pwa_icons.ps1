param(
  [string]$OutputDirectory = (Join-Path $PSScriptRoot "..\images")
)

Add-Type -AssemblyName System.Drawing

function New-RoundedRectanglePath {
  param([System.Drawing.RectangleF]$Rectangle, [float]$Radius)
  $diameter = $Radius * 2
  $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
  $path.AddArc($Rectangle.X, $Rectangle.Y, $diameter, $diameter, 180, 90)
  $path.AddArc($Rectangle.Right - $diameter, $Rectangle.Y, $diameter, $diameter, 270, 90)
  $path.AddArc($Rectangle.Right - $diameter, $Rectangle.Bottom - $diameter, $diameter, $diameter, 0, 90)
  $path.AddArc($Rectangle.X, $Rectangle.Bottom - $diameter, $diameter, $diameter, 90, 90)
  $path.CloseFigure()
  return $path
}

function New-PwaIcon {
  param([int]$Size, [string]$Path)

  $bitmap = [System.Drawing.Bitmap]::new($Size, $Size)
  $bitmap.SetResolution(96, 96)
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

  $background = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml("#173f5f"))
  $paper = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml("#f7f4ed"))
  $accent = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml("#176b63"))
  $gold = [System.Drawing.Pen]::new([System.Drawing.ColorTranslator]::FromHtml("#e2a33a"), $Size * 0.047)
  $gold.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $gold.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $gold.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

  $outer = [System.Drawing.RectangleF]::new(0, 0, $Size, $Size)
  $outerPath = New-RoundedRectanglePath $outer ($Size * 0.2)
  $graphics.FillPath($background, $outerPath)
  $graphics.FillEllipse($paper, $Size * 0.2, $Size * 0.17, $Size * 0.6, $Size * 0.6)

  $font = [System.Drawing.Font]::new("Microsoft YaHei", $Size * 0.35, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $format = [System.Drawing.StringFormat]::new()
  $format.Alignment = [System.Drawing.StringAlignment]::Center
  $format.LineAlignment = [System.Drawing.StringAlignment]::Center
  $textRect = [System.Drawing.RectangleF]::new($Size * 0.17, $Size * 0.12, $Size * 0.66, $Size * 0.66)
  $iconGlyph = [char]0x56E0
  $graphics.DrawString($iconGlyph, $font, $accent, $textRect, $format)

  $points = [System.Drawing.PointF[]]@(
    [System.Drawing.PointF]::new($Size * 0.27, $Size * 0.70),
    [System.Drawing.PointF]::new($Size * 0.41, $Size * 0.56),
    [System.Drawing.PointF]::new($Size * 0.52, $Size * 0.64),
    [System.Drawing.PointF]::new($Size * 0.73, $Size * 0.40)
  )
  $graphics.DrawLines($gold, $points)
  $graphics.DrawLine($gold, $Size * 0.64, $Size * 0.40, $Size * 0.73, $Size * 0.40)
  $graphics.DrawLine($gold, $Size * 0.73, $Size * 0.40, $Size * 0.73, $Size * 0.49)

  $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)

  $format.Dispose()
  $font.Dispose()
  $gold.Dispose()
  $accent.Dispose()
  $paper.Dispose()
  $background.Dispose()
  $outerPath.Dispose()
  $graphics.Dispose()
  $bitmap.Dispose()
}

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
New-PwaIcon 180 (Join-Path $OutputDirectory "pwa-icon-180.png")
New-PwaIcon 192 (Join-Path $OutputDirectory "pwa-icon-192.png")
New-PwaIcon 512 (Join-Path $OutputDirectory "pwa-icon-512.png")
