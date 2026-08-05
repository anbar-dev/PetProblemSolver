Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = "Stop"

$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$BrandRoot = Join-Path $Root "assets\brand"
$ImageRoot = Join-Path $Root "assets\images"

function New-Dir($Path) {
  if (-not (Test-Path $Path)) {
    New-Item -ItemType Directory -Path $Path | Out-Null
  }
}

function New-Brush($Hex) {
  $Color = [System.Drawing.ColorTranslator]::FromHtml($Hex)
  New-Object System.Drawing.SolidBrush($Color)
}

function New-Pen($Hex, $Width) {
  $Color = [System.Drawing.ColorTranslator]::FromHtml($Hex)
  New-Object System.Drawing.Pen($Color, $Width)
}

function Draw-CenteredText($Graphics, $Text, $Font, $Brush, $Rect) {
  $Format = New-Object System.Drawing.StringFormat
  $Format.Alignment = [System.Drawing.StringAlignment]::Center
  $Format.LineAlignment = [System.Drawing.StringAlignment]::Center
  $Graphics.DrawString($Text, $Font, $Brush, $Rect, $Format)
  $Format.Dispose()
}

function Save-ProfileImage($Path) {
  $Size = 800
  $Bitmap = New-Object System.Drawing.Bitmap($Size, $Size)
  $Graphics = [System.Drawing.Graphics]::FromImage($Bitmap)
  $Graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $Graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

  $Ink = New-Brush "#1f2523"
  $Cream = New-Brush "#fbfaf6"
  $Teal = New-Brush "#24463f"
  $Coral = New-Brush "#c76b57"
  $Gold = New-Brush "#e7b85d"

  $Graphics.FillRectangle($Teal, 0, 0, $Size, $Size)
  $Graphics.FillEllipse($Cream, 96, 96, 608, 608)
  $Graphics.FillEllipse($Gold, 548, 150, 82, 82)
  $Graphics.FillEllipse($Coral, 160, 540, 64, 64)

  $BigFont = New-Object System.Drawing.Font("Segoe UI", 156, [System.Drawing.FontStyle]::Bold)
  $SmallFont = New-Object System.Drawing.Font("Segoe UI", 38, [System.Drawing.FontStyle]::Bold)
  $TinyFont = New-Object System.Drawing.Font("Segoe UI", 25, [System.Drawing.FontStyle]::Regular)

  Draw-CenteredText $Graphics "CPS" $BigFont $Ink (New-Object System.Drawing.RectangleF(90, 210, 620, 220))
  Draw-CenteredText $Graphics "CAT PROBLEM" $SmallFont $Coral (New-Object System.Drawing.RectangleF(90, 455, 620, 58))
  Draw-CenteredText $Graphics "SOLVER" $TinyFont $Ink (New-Object System.Drawing.RectangleF(90, 514, 620, 48))

  $Bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)

  $BigFont.Dispose(); $SmallFont.Dispose(); $TinyFont.Dispose()
  $Ink.Dispose(); $Cream.Dispose(); $Teal.Dispose(); $Coral.Dispose(); $Gold.Dispose()
  $Graphics.Dispose(); $Bitmap.Dispose()
}

function Save-FaviconPng($Path, $Size) {
  $Bitmap = New-Object System.Drawing.Bitmap($Size, $Size)
  $Graphics = [System.Drawing.Graphics]::FromImage($Bitmap)
  $Graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $Graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

  $Teal = New-Brush "#24463f"
  $Cream = New-Brush "#fbfaf6"
  $Coral = New-Brush "#c76b57"
  $Outline = New-Pen "#fbfaf6" ([Math]::Max(2, [int]($Size * 0.045)))

  $Graphics.FillRectangle($Teal, 0, 0, $Size, $Size)
  $Padding = [int]($Size * 0.13)
  $Graphics.FillEllipse($Cream, $Padding, $Padding, $Size - ($Padding * 2), $Size - ($Padding * 2))
  $Graphics.DrawEllipse($Outline, $Padding, $Padding, $Size - ($Padding * 2), $Size - ($Padding * 2))

  $FontSize = [Math]::Max(10, [int]($Size * 0.55))
  $Font = New-Object System.Drawing.Font("Segoe UI", $FontSize, [System.Drawing.FontStyle]::Bold)
  Draw-CenteredText $Graphics "C" $Font $Coral (New-Object System.Drawing.RectangleF(0, -($Size * 0.03), $Size, $Size))

  $Bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)

  $Font.Dispose(); $Teal.Dispose(); $Cream.Dispose(); $Coral.Dispose(); $Outline.Dispose()
  $Graphics.Dispose(); $Bitmap.Dispose()
}

function Save-HeroImage($Path) {
  $W = 1800
  $H = 1100
  $Bitmap = New-Object System.Drawing.Bitmap($W, $H)
  $Graphics = [System.Drawing.Graphics]::FromImage($Bitmap)
  $Graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $Graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

  $Bg = New-Brush "#24463f"
  $Panel = New-Brush "#fbfaf6"
  $Teal2 = New-Brush "#6f8f86"
  $Coral = New-Brush "#c76b57"
  $Gold = New-Brush "#e7b85d"
  $Ink = New-Brush "#1f2523"
  $Line = New-Pen "#dedbd2" 6
  $Whisker = New-Pen "#fbfaf6" 8

  $Graphics.FillRectangle($Bg, 0, 0, $W, $H)
  $Graphics.FillEllipse($Teal2, 1080, 90, 520, 520)
  $Graphics.FillEllipse($Coral, 1180, 610, 210, 210)
  $Graphics.FillEllipse($Gold, 1460, 500, 120, 120)
  $Graphics.FillRectangle($Panel, 880, 700, 520, 170)
  $Graphics.DrawRectangle($Line, 880, 700, 520, 170)

  $Graphics.FillEllipse($Panel, 500, 300, 500, 410)
  $Graphics.FillPolygon($Panel, @(
    (New-Object System.Drawing.Point(570, 330)),
    (New-Object System.Drawing.Point(650, 165)),
    (New-Object System.Drawing.Point(725, 345))
  ))
  $Graphics.FillPolygon($Panel, @(
    (New-Object System.Drawing.Point(845, 345)),
    (New-Object System.Drawing.Point(950, 180)),
    (New-Object System.Drawing.Point(940, 405))
  ))
  $Graphics.FillEllipse($Ink, 655, 455, 34, 34)
  $Graphics.FillEllipse($Ink, 820, 455, 34, 34)
  $Graphics.FillEllipse($Coral, 740, 535, 34, 24)
  $Graphics.DrawLine($Whisker, 735, 555, 590, 525)
  $Graphics.DrawLine($Whisker, 735, 575, 585, 585)
  $Graphics.DrawLine($Whisker, 775, 555, 925, 525)
  $Graphics.DrawLine($Whisker, 775, 575, 930, 585)

  $TitleFont = New-Object System.Drawing.Font("Segoe UI", 58, [System.Drawing.FontStyle]::Bold)
  $SmallFont = New-Object System.Drawing.Font("Segoe UI", 32, [System.Drawing.FontStyle]::Bold)
  $Graphics.DrawString("LITTER", $SmallFont, $Ink, 930, 735)
  $Graphics.DrawString("SCRATCH", $SmallFont, $Ink, 1115, 735)
  $Graphics.DrawString("CLEAN", $SmallFont, $Ink, 930, 800)
  $Graphics.DrawString("FEED", $SmallFont, $Ink, 1128, 800)
  $Graphics.DrawString("Cat Problem Solver", $TitleFont, $Panel, 120, 855)

  $Bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)

  $TitleFont.Dispose(); $SmallFont.Dispose()
  $Bg.Dispose(); $Panel.Dispose(); $Teal2.Dispose(); $Coral.Dispose(); $Gold.Dispose(); $Ink.Dispose(); $Line.Dispose(); $Whisker.Dispose()
  $Graphics.Dispose(); $Bitmap.Dispose()
}

New-Dir $BrandRoot
New-Dir $ImageRoot

Save-ProfileImage (Join-Path $BrandRoot "pinterest-profile.png")
Save-FaviconPng (Join-Path $BrandRoot "favicon-512.png") 512
Save-FaviconPng (Join-Path $BrandRoot "favicon-192.png") 192
Save-FaviconPng (Join-Path $BrandRoot "favicon-32.png") 32
Save-HeroImage (Join-Path $ImageRoot "cat-problem-solver-hero.png")

Write-Host "Built Cat Problem Solver brand assets into assets/brand/ and assets/images/"
