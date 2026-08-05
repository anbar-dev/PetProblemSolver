Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = "Stop"

$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$PromoRoot = Join-Path $Root "promo"
$BaseUrl = "https://catproblemsolver.com"

function New-Dir($Path) {
  if (-not (Test-Path $Path)) {
    New-Item -ItemType Directory -Path $Path | Out-Null
  }
}

function Escape-Csv($Value) {
  $Text = [string]$Value
  '"' + $Text.Replace('"', '""') + '"'
}

function Add-TrackingUrl($Url, $Slug, $PinFile) {
  $Content = ($PinFile -replace '\.png$', '') -replace '[^a-zA-Z0-9_-]', '-'
  $Separator = if ($Url.Contains("?")) { "&" } else { "?" }
  return "$Url$Separator" + "utm_source=pinterest&utm_medium=social&utm_campaign=cat_problem_promo&utm_content=$Slug-$Content"
}

function Get-PinKey($Slug, $PinFile) {
  $Content = ($PinFile -replace '\.png$', '') -replace '[^a-zA-Z0-9_-]', '-'
  return "$Slug/$Content"
}

function Get-LedgerMap($Path) {
  $Map = @{}
  if (Test-Path $Path) {
    Import-Csv -Path $Path | ForEach-Object {
      if ($_.pin_key) { $Map[$_.pin_key] = $_ }
    }
  }
  return $Map
}

function New-PinterestCsvRow($Title, $MediaUrl, $Board, $Description, $DestinationUrl, $PublishDate, $Keywords) {
  return ((Escape-Csv $Title), (Escape-Csv $MediaUrl), (Escape-Csv $Board), "", (Escape-Csv $Description), (Escape-Csv $DestinationUrl), (Escape-Csv $PublishDate), (Escape-Csv $Keywords) -join ",")
}

function New-LedgerCsvRow($PinKey, $ArticleSlug, $PinFile, $Title, $Board, $MediaUrl, $DestinationUrl, $PublishDate, $Status, $PinterestUrl, $Notes) {
  return ((Escape-Csv $PinKey), (Escape-Csv $ArticleSlug), (Escape-Csv $PinFile), (Escape-Csv $Title), (Escape-Csv $Board), (Escape-Csv $MediaUrl), (Escape-Csv $DestinationUrl), (Escape-Csv $PublishDate), (Escape-Csv $Status), (Escape-Csv $PinterestUrl), (Escape-Csv $Notes) -join ",")
}

function New-Brush($Hex) {
  $Color = [System.Drawing.ColorTranslator]::FromHtml($Hex)
  New-Object System.Drawing.SolidBrush($Color)
}

function Add-RoundedRect($Graphics, $Brush, $X, $Y, $W, $H, $R) {
  $Path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $D = $R * 2
  $Path.AddArc($X, $Y, $D, $D, 180, 90)
  $Path.AddArc($X + $W - $D, $Y, $D, $D, 270, 90)
  $Path.AddArc($X + $W - $D, $Y + $H - $D, $D, $D, 0, 90)
  $Path.AddArc($X, $Y + $H - $D, $D, $D, 90, 90)
  $Path.CloseFigure()
  $Graphics.FillPath($Brush, $Path)
  $Path.Dispose()
}

function Draw-WrappedText($Graphics, $Text, $Font, $Brush, $X, $Y, $MaxWidth, $LineHeight) {
  $Words = ([string]$Text).Split(" ")
  $Line = ""
  $CurrentY = $Y
  foreach ($Word in $Words) {
    $Candidate = if ($Line.Length) { "$Line $Word" } else { $Word }
    $Size = $Graphics.MeasureString($Candidate, $Font)
    if ($Size.Width -gt $MaxWidth -and $Line.Length) {
      $Graphics.DrawString($Line, $Font, $Brush, $X, $CurrentY)
      $CurrentY += $LineHeight
      $Line = $Word
    } else {
      $Line = $Candidate
    }
  }
  if ($Line.Length) {
    $Graphics.DrawString($Line, $Font, $Brush, $X, $CurrentY)
    $CurrentY += $LineHeight
  }
  return $CurrentY
}

function Draw-Pin($Pin, $Article, $OutPath) {
  $W = 1000
  $H = 1500
  $Bitmap = New-Object System.Drawing.Bitmap($W, $H)
  $Graphics = [System.Drawing.Graphics]::FromImage($Bitmap)
  $Graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $Graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

  $Bg = New-Brush $Pin.Bg
  $Ink = New-Brush $Pin.Ink
  $Muted = New-Brush $Pin.Muted
  $Panel = New-Brush $Pin.Panel
  $Accent = New-Brush $Pin.Accent
  $Paper = New-Brush "#fbfaf6"

  $Graphics.FillRectangle($Bg, 0, 0, $W, $H)
  Add-RoundedRect $Graphics $Panel 70 86 860 1228 36
  Add-RoundedRect $Graphics $Accent 70 86 860 18 9
  Add-RoundedRect $Graphics $Paper 770 1130 112 112 24

  $BrandFont = New-Object System.Drawing.Font("Segoe UI", 25, [System.Drawing.FontStyle]::Bold)
  $PillFont = New-Object System.Drawing.Font("Segoe UI", 23, [System.Drawing.FontStyle]::Bold)
  $TitleFont = New-Object System.Drawing.Font("Segoe UI", 66, [System.Drawing.FontStyle]::Bold)
  $SubFont = New-Object System.Drawing.Font("Segoe UI", 34, [System.Drawing.FontStyle]::Regular)
  $BulletFont = New-Object System.Drawing.Font("Segoe UI", 30, [System.Drawing.FontStyle]::Bold)
  $SmallFont = New-Object System.Drawing.Font("Segoe UI", 24, [System.Drawing.FontStyle]::Regular)
  $LogoFont = New-Object System.Drawing.Font("Segoe UI", 58, [System.Drawing.FontStyle]::Bold)

  $Y = 145
  $Graphics.DrawString("Cat Problem Solver", $BrandFont, $Muted, 120, $Y)
  $Y += 86
  Add-RoundedRect $Graphics $Accent 120 $Y 330 54 18
  $Graphics.DrawString($Article.Category.ToUpperInvariant(), $PillFont, $Paper, 142, $Y + 10)
  $Y += 105

  $Y = Draw-WrappedText $Graphics $Pin.Title $TitleFont $Ink 120 $Y 760 78
  $Y += 34
  $Y = Draw-WrappedText $Graphics $Pin.Subtitle $SubFont $Muted 122 $Y 720 45
  $Y += 72

  foreach ($Bullet in $Pin.Bullets) {
    Add-RoundedRect $Graphics $Accent 124 ($Y + 9) 18 18 9
    $Y = Draw-WrappedText $Graphics $Bullet $BulletFont $Ink 164 $Y 670 40
    $Y += 28
  }

  Add-RoundedRect $Graphics $Ink 120 1140 520 84 24
  $Graphics.DrawString("Read the full fix", $BulletFont, $Paper, 154, 1161)
  $Graphics.DrawString("C", $LogoFont, $Accent, 805, 1148)
  $Graphics.DrawString("catproblemsolver.com", $SmallFont, $Muted, 120, 1270)
  $Graphics.DrawString("#ad", $SmallFont, $Muted, 800, 1270)

  $Bitmap.Save($OutPath, [System.Drawing.Imaging.ImageFormat]::Png)

  $BrandFont.Dispose(); $PillFont.Dispose(); $TitleFont.Dispose(); $SubFont.Dispose(); $BulletFont.Dispose(); $SmallFont.Dispose(); $LogoFont.Dispose()
  $Bg.Dispose(); $Ink.Dispose(); $Muted.Dispose(); $Panel.Dispose(); $Accent.Dispose(); $Paper.Dispose()
  $Graphics.Dispose(); $Bitmap.Dispose()
}

$Articles = @(
  [pscustomobject]@{
    Slug = "litter-tracking-everywhere"; Category = "Litter Box"; Board = "Cat Litter Box Fixes"; Url = "$BaseUrl/problems/litter-box/litter-tracking-everywhere/"; Keywords = "cat litter tracking, litter mat, litter stuck in cat paws, cat litter cleanup, litter box tips"; VideoHook = "If cat litter is everywhere, fix the exit path before buying another tiny mat."
    Pins = @(
      [pscustomobject]@{ File="pin-01.png"; Title="Cat Litter Tracking Everywhere?"; Subtitle="Start with the box exit path, not random mats your cat jumps over."; Bullets=@("Large mat placement","Low-tracking litter","Daily edge cleanup"); Description="A practical fix for cat litter tracking everywhere, with what to buy first and what to skip. This page contains Amazon affiliate links. #ad"; Bg="#24463f"; Panel="#fbfaf6"; Ink="#1f2523"; Muted="#62685f"; Accent="#c76b57" },
      [pscustomobject]@{ File="pin-02.png"; Title="Stop Litter Before It Hits the Bed"; Subtitle="Catch litter near the box before paws carry it into soft surfaces."; Bullets=@("Mat at the exit","Vacuum the spread zone","Change litter slowly"); Description="Cat litter tracking setup for floors, hallways, and bedding, with a compact product checklist. #ad"; Bg="#3f6f8f"; Panel="#fbfaf6"; Ink="#1f2523"; Muted="#62685f"; Accent="#e7b85d" },
      [pscustomobject]@{ File="pin-03.png"; Title="Do Not Buy the Tiny Mat First"; Subtitle="If your cat steps past it, the mat is decoration."; Bullets=@("Measure the exit","Watch the paw path","Clean daily"); Description="What to buy first when cat litter tracks everywhere: mat, litter, paw wipes, and cleanup tools. #ad"; Bg="#c76b57"; Panel="#fbfaf6"; Ink="#1f2523"; Muted="#62685f"; Accent="#24463f" }
    )
  },
  [pscustomobject]@{
    Slug = "cat-scratching-couch"; Category = "Scratching"; Board = "Cat Scratching Fixes"; Url = "$BaseUrl/problems/scratching/cat-scratching-couch/"; Keywords = "cat scratching couch, stop cat scratching sofa, couch protector for cats, cat scratcher placement, cat claw care"; VideoHook = "If your cat scratches the couch, put the better scratch target where the couch is already winning."
    Pins = @(
      [pscustomobject]@{ File="pin-01.png"; Title="Cat Scratching the Couch?"; Subtitle="Start with the scratcher position, not another random deterrent."; Bullets=@("Match the angle","Guard one sofa spot","Reward the switch"); Description="A practical setup to stop cat scratching on couch corners and sofa arms, with what to buy first and what to skip. This page contains Amazon affiliate links. #ad"; Bg="#24463f"; Panel="#fbfaf6"; Ink="#1f2523"; Muted="#62685f"; Accent="#e7b85d" },
      [pscustomobject]@{ File="pin-02.png"; Title="Do Not Hide the Scratcher"; Subtitle="If the couch is in the social zone, the scratcher needs to start there too."; Bullets=@("Beside the couch","Tall and stable","Move it slowly"); Description="Stop cat scratching on the sofa by matching the scratching angle and protecting the target zone while the new habit sticks. #ad"; Bg="#3f6f8f"; Panel="#fbfaf6"; Ink="#1f2523"; Muted="#62685f"; Accent="#c76b57" },
      [pscustomobject]@{ File="pin-03.png"; Title="Protect the Sofa Without Making It Weird"; Subtitle="Cover the claw target, then give your cat a better legal target."; Bullets=@("Couch guard","Sisal post","Nail tip care"); Description="Couch protector for cats plus the scratcher placement logic that actually matters. Full checklist on Cat Problem Solver. #ad"; Bg="#c76b57"; Panel="#fbfaf6"; Ink="#1f2523"; Muted="#62685f"; Accent="#24463f" }
    )
  },
  [pscustomobject]@{
    Slug = "litter-box-smell-small-home"; Category = "Litter Box"; Board = "Cat Litter Box Fixes"; Url = "$BaseUrl/problems/litter-box/litter-box-smell-small-home/"; Keywords = "litter box smell small home, cat box smell even when clean, litter odor setup, cat urine smell cleaner, litter pail"; VideoHook = "If your small home smells like the litter box, fix the waste path before buying air freshener."
    Pins = @(
      [pscustomobject]@{ File="pin-01.png"; Title="Litter Box Smell in a Small Home?"; Subtitle="Start with the odor source, not perfume on top of it."; Bullets=@("Scoop and seal","Hard clumps","Clean the box"); Description="A practical odor-control setup for litter box smell in a small home, with what to buy first and what to skip. This page contains Amazon affiliate links. #ad"; Bg="#24463f"; Panel="#fbfaf6"; Ink="#1f2523"; Muted="#62685f"; Accent="#c76b57" },
      [pscustomobject]@{ File="pin-02.png"; Title="Do Not Buy Air Freshener First"; Subtitle="If waste is still in the room, fragrance just rides on top."; Bullets=@("Seal waste","Use enzyme cleaner","Skip perfume first"); Description="How to reduce litter box odor in a small room with a source-first setup. Full checklist on Cat Problem Solver. #ad"; Bg="#3f6f8f"; Panel="#fbfaf6"; Ink="#1f2523"; Muted="#62685f"; Accent="#e7b85d" },
      [pscustomobject]@{ File="pin-03.png"; Title="Why the Box Still Smells After Scooping"; Subtitle="Check the pail, clumps, box plastic, and floor around it."; Bullets=@("Better pail","Cleaner clumps","Box hygiene"); Description="A small-home cat litter odor checklist: what to buy first, what to skip, and when it is not just a gear problem. #ad"; Bg="#c76b57"; Panel="#fbfaf6"; Ink="#1f2523"; Muted="#62685f"; Accent="#24463f" }
    )
  }
)

New-Dir $PromoRoot

$CsvHeader = "Title,Media URL,Pinterest board,Thumbnail,Description,Link,Publish date,Keywords"
$LedgerHeader = "pin_key,article_slug,pin_file,title,board,media_url,destination_url,publish_date,status,pinterest_url,notes"
$LedgerPath = Join-Path $PromoRoot "PINTEREST_LEDGER.csv"
$ExistingLedger = Get-LedgerMap $LedgerPath

$AllCsvRows = New-Object System.Collections.Generic.List[string]
$NextCsvRows = New-Object System.Collections.Generic.List[string]
$NowCsvRows = New-Object System.Collections.Generic.List[string]
$ScheduledCsvRows = New-Object System.Collections.Generic.List[string]
$LedgerRows = New-Object System.Collections.Generic.List[string]
$AllCsvRows.Add($CsvHeader); $NextCsvRows.Add($CsvHeader); $NowCsvRows.Add($CsvHeader); $ScheduledCsvRows.Add($CsvHeader); $LedgerRows.Add($LedgerHeader)
$ImmediateUploadLimit = 9
$NextUploadCount = 0
$ScheduledUploadOffset = 0
$ScheduleStart = (Get-Date).ToUniversalTime().Date.AddDays(1).AddHours(15)

foreach ($Article in $Articles) {
  $ArticleDir = Join-Path $PromoRoot $Article.Slug
  $PinsDir = Join-Path $ArticleDir "pins"
  New-Dir $ArticleDir
  New-Dir $PinsDir
  $ArticleAllCsvRows = New-Object System.Collections.Generic.List[string]
  $ArticleNextCsvRows = New-Object System.Collections.Generic.List[string]
  $ArticleAllCsvRows.Add($CsvHeader)
  $ArticleNextCsvRows.Add($CsvHeader)

  $CopyLines = @("# Pinterest Copy - $($Article.Slug)", "", "Article URL: $($Article.Url)", "Board: $($Article.Board)", "", "## Pins")

  foreach ($Pin in $Article.Pins) {
    $OutPath = Join-Path $PinsDir $Pin.File
    Draw-Pin $Pin $Article $OutPath
    $PinKey = Get-PinKey $Article.Slug $Pin.File
    $MediaUrl = "$BaseUrl/promo/$($Article.Slug)/pins/$($Pin.File)"
    $TrackedUrl = Add-TrackingUrl $Article.Url $Article.Slug $Pin.File
    $Existing = $ExistingLedger[$PinKey]
    $PublishDate = ""
    $Status = "ready"
    $PinterestUrl = ""
    $Notes = ""

    if ($Existing) {
      $PublishDate = $Existing.publish_date
      $Status = $Existing.status
      $PinterestUrl = $Existing.pinterest_url
      $Notes = $Existing.notes
    }

    $ShouldExportNext = @("ready", "exported", "error") -contains $Status
    if ($ShouldExportNext) {
      $Status = "exported"
      $ExportPublishDate = ""
      if ($NextUploadCount -ge $ImmediateUploadLimit) {
        $ExportPublishDate = $ScheduleStart.AddDays($ScheduledUploadOffset).ToString("yyyy-MM-ddTHH:mm:ss", [Globalization.CultureInfo]::InvariantCulture)
        $ScheduledUploadOffset += 1
      }
      $PublishDate = $ExportPublishDate
      $Notes = if ($ExportPublishDate) { "Included in scheduled and next upload CSV; set status to uploaded after successful import." } else { "Included in now and next upload CSV; set status to uploaded after successful import." }
      $NextCsvRow = New-PinterestCsvRow $Pin.Title $MediaUrl $Article.Board $Pin.Description $TrackedUrl $ExportPublishDate $Article.Keywords
      $NextCsvRows.Add($NextCsvRow)
      $ArticleNextCsvRows.Add($NextCsvRow)
      if ($ExportPublishDate) { $ScheduledCsvRows.Add($NextCsvRow) } else { $NowCsvRows.Add($NextCsvRow) }
      $NextUploadCount += 1
    }

    $CsvRow = New-PinterestCsvRow $Pin.Title $MediaUrl $Article.Board $Pin.Description $TrackedUrl $PublishDate $Article.Keywords
    $AllCsvRows.Add($CsvRow)
    $ArticleAllCsvRows.Add($CsvRow)
    $LedgerRows.Add((New-LedgerCsvRow $PinKey $Article.Slug $Pin.File $Pin.Title $Article.Board $MediaUrl $TrackedUrl $PublishDate $Status $PinterestUrl $Notes))
    $CopyLines += @("", "### $($Pin.File)", "", "Title: $($Pin.Title)", "", "Description: $($Pin.Description)", "", "Media URL after publishing: $MediaUrl", "", "Tracked destination URL: $TrackedUrl", "", "Scheduled publish date: $PublishDate UTC", "", "Keywords: $($Article.Keywords)")
  }

  Set-Content -Path (Join-Path $ArticleDir "pinterest-copy.md") -Value ($CopyLines -join "`r`n") -Encoding UTF8
  Set-Content -Path (Join-Path $ArticleDir "pinterest-bulk-upload.csv") -Value ($ArticleAllCsvRows -join "`r`n") -Encoding UTF8
  Set-Content -Path (Join-Path $ArticleDir "pinterest-upload-next.csv") -Value ($ArticleNextCsvRows -join "`r`n") -Encoding UTF8

  $Video = @"
# Short Video Script - $($Article.Slug)

Length: 20-30 seconds
Format: 9:16 vertical
Destination: Pinterest video pin, YouTube Shorts, TikTok

Hook:
$($Article.VideoHook)

Beat 1:
Show the cat problem in one sentence.

Beat 2:
Show the 3-part fix logic from the Pin bullets.

Beat 3:
Show one fast "what to skip" warning.

Close:
Full practical checklist on Cat Problem Solver.

On-screen disclosure:
#ad - page contains Amazon affiliate links.
"@
  Set-Content -Path (Join-Path $ArticleDir "short-video-script.md") -Value $Video -Encoding UTF8

  $Fiverr = @"
# Fiverr Brief - $($Article.Slug)

Create one 20-30 second vertical video, 1080x1920, using the script in short-video-script.md.

Style:
- Clean, practical cat-care aesthetic.
- Large readable text.
- Calm practical pacing, not flashy.
- Use the colors from the included Pin PNGs.
- No fake prices, ratings, discounts, or Amazon logos.

Deliverables:
- 1 MP4 vertical video.
- 1 editable project file if possible.
- 1 thumbnail frame.

Required text:
- Cat Problem Solver
- #ad
- Full checklist: $($Article.Url)
"@
  Set-Content -Path (Join-Path $ArticleDir "fiverr-brief.md") -Value $Fiverr -Encoding UTF8

  $Reddit = @"
# Reddit Angle - $($Article.Slug)

Use manually only where it is genuinely relevant. Do not drop links as the first move.

Helpful no-link reply angle:
$($Article.VideoHook)

Suggested approach:
1. Answer the person's specific cat problem.
2. Mention the 3-part checklist in plain text.
3. Link only if the subreddit allows it or the person asks.

Disclosure if linking:
I made a full checklist; it contains affiliate links.
"@
  Set-Content -Path (Join-Path $ArticleDir "reddit-angle.md") -Value $Reddit -Encoding UTF8
}

Set-Content -Path (Join-Path $PromoRoot "pinterest-bulk-upload.csv") -Value ($AllCsvRows -join "`r`n") -Encoding UTF8
Set-Content -Path (Join-Path $PromoRoot "pinterest-upload-next.csv") -Value ($NextCsvRows -join "`r`n") -Encoding UTF8
Set-Content -Path (Join-Path $PromoRoot "pinterest-upload-now.csv") -Value ($NowCsvRows -join "`r`n") -Encoding UTF8
Set-Content -Path (Join-Path $PromoRoot "pinterest-upload-scheduled.csv") -Value ($ScheduledCsvRows -join "`r`n") -Encoding UTF8
Set-Content -Path $LedgerPath -Value ($LedgerRows -join "`r`n") -Encoding UTF8

Write-Host "Built promo assets for $($Articles.Count) cat problem articles into promo/ ($NextUploadCount rows in pinterest-upload-next.csv)"
