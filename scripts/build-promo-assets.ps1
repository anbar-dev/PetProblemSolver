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
    Slug = "litter-box-smell-small-home"; Category = "Litter Box"; Board = "Cat Litter Box Fixes"; Url = "$BaseUrl/problems/litter-box/litter-box-smell-small-home/"; Keywords = "litter box smell, cat litter odor, small home cat box, odor control litter, cat box cleaning"; VideoHook = "If one litter box scents the whole room, perfume is not the first fix."
    Pins = @(
      [pscustomobject]@{ File="pin-01.png"; Title="Litter Box Smell in a Small Home"; Subtitle="Scoop rhythm, sealed waste, and box cleaning beat perfume-first fixes."; Bullets=@("Scoop daily","Seal waste fast","Avoid heavy fragrance"); Description="A small-home litter box smell setup with odor control, cleanup tools, and what to skip. #ad"; Bg="#6f8f86"; Panel="#fbfaf6"; Ink="#1f2523"; Muted="#62685f"; Accent="#c76b57" },
      [pscustomobject]@{ File="pin-02.png"; Title="Cat Box Smells Even When Clean?"; Subtitle="Check waste containment, box washing, litter type, and airflow."; Bullets=@("Better waste bin","Sturdy scoop","Careful airflow"); Description="How to reduce litter box smell without relying on strong scents around your cat. #ad"; Bg="#e7b85d"; Panel="#fbfaf6"; Ink="#1f2523"; Muted="#62685f"; Accent="#24463f" },
      [pscustomobject]@{ File="pin-03.png"; Title="Do Not Hide Smell in a Stale Cabinet"; Subtitle="Hidden boxes need ventilation and a real cleaning routine."; Bullets=@("No stale enclosure","No open trash","Vet check sudden changes"); Description="Litter box odor control for small homes, including when gear is not enough. #ad"; Bg="#3f6f8f"; Panel="#fbfaf6"; Ink="#1f2523"; Muted="#62685f"; Accent="#e7b85d" }
    )
  },
  [pscustomobject]@{
    Slug = "cat-scratching-couch"; Category = "Scratching"; Board = "Cat Scratching Solutions"; Url = "$BaseUrl/problems/scratching/cat-scratching-couch/"; Keywords = "cat scratching couch, couch protector cats, cat scratcher, stop cat scratching sofa, furniture protection"; VideoHook = "Couch protectors work better when a better scratcher is right next to the couch."
    Pins = @(
      [pscustomobject]@{ File="pin-01.png"; Title="Cat Scratching the Couch?"; Subtitle="Protect the damage zone and put the replacement scratcher beside it."; Bullets=@("Tall stable post","Couch guard","Nail care"); Description="A practical couch scratching fix with scratcher placement, surface protection, and what to skip. #ad"; Bg="#c76b57"; Panel="#fbfaf6"; Ink="#1f2523"; Muted="#62685f"; Accent="#24463f" },
      [pscustomobject]@{ File="pin-02.png"; Title="Tape Alone Will Not Save the Sofa"; Subtitle="Your cat still needs an acceptable scratching target nearby."; Bullets=@("Add a better target","Reward the switch","Skip punishment"); Description="How to stop cat scratching couch corners without turning it into a generic product list. #ad"; Bg="#24463f"; Panel="#fbfaf6"; Ink="#1f2523"; Muted="#62685f"; Accent="#e7b85d" },
      [pscustomobject]@{ File="pin-03.png"; Title="Couch Corner Protection for Cats"; Subtitle="A simple layered setup for the spot your cat already chose."; Bullets=@("Guard the corner","Place scratcher close","Trim gently"); Description="Couch protector and scratching post setup for cats that keep targeting sofa arms. #ad"; Bg="#3f6f8f"; Panel="#fbfaf6"; Ink="#1f2523"; Muted="#62685f"; Accent="#c76b57" }
    )
  },
  [pscustomobject]@{
    Slug = "cat-hair-everywhere"; Category = "Cleaning"; Board = "Cat Cleaning Tips"; Url = "$BaseUrl/problems/hair-cleaning/cat-hair-everywhere/"; Keywords = "cat hair everywhere, remove cat hair couch, cat hair laundry, cat grooming brush, pet hair remover"; VideoHook = "Cat hair everywhere needs a surface routine, not only more lint rollers."
    Pins = @(
      [pscustomobject]@{ File="pin-01.png"; Title="Cat Hair Everywhere?"; Subtitle="Split the fix into grooming, furniture, laundry, and washable nap zones."; Bullets=@("Reusable hair tool","Gentle brushing","Washable blanket"); Description="A practical cat hair cleanup setup for couches, clothes, bedding, and laundry. #ad"; Bg="#6f8f86"; Panel="#fbfaf6"; Ink="#1f2523"; Muted="#62685f"; Accent="#24463f" },
      [pscustomobject]@{ File="pin-02.png"; Title="Stop Using Lint Rollers for the Whole Home"; Subtitle="Use reusable tools where hair actually collects every day."; Bullets=@("Couch tool","Laundry helper","Favorite spot cover"); Description="What to buy first when cat hair is on everything, with skip notes and cleanup priorities. #ad"; Bg="#e7b85d"; Panel="#fbfaf6"; Ink="#1f2523"; Muted="#62685f"; Accent="#c76b57" },
      [pscustomobject]@{ File="pin-03.png"; Title="Make the Nap Spot Washable"; Subtitle="Hair cleanup gets easier when the favorite spot has a removable layer."; Bullets=@("Cover the favorite chair","Brush lightly","Vacuum seams"); Description="Cat hair furniture and laundry setup for people tired of cleaning the same couch twice. #ad"; Bg="#24463f"; Panel="#fbfaf6"; Ink="#1f2523"; Muted="#62685f"; Accent="#e7b85d" }
    )
  },
  [pscustomobject]@{
    Slug = "cat-water-bowl-mess"; Category = "Food And Water"; Board = "Cat Feeding Stations"; Url = "$BaseUrl/problems/feeding-water/cat-water-bowl-mess/"; Keywords = "cat water bowl mess, cat splashes water, cat pushes water bowl, cat water fountain, pet feeding mat"; VideoHook = "If your cat turns water into a splash zone, stabilize the station first."
    Pins = @(
      [pscustomobject]@{ File="pin-01.png"; Title="Cat Water Bowl Mess?"; Subtitle="Start with a splash mat and heavy bowl before replacing everything."; Bullets=@("Raised-edge mat","Heavy bowl","Separate water spot"); Description="A practical water bowl mess fix for cats that splash, push bowls, or leave wet floors. #ad"; Bg="#3f6f8f"; Panel="#fbfaf6"; Ink="#1f2523"; Muted="#62685f"; Accent="#e7b85d" },
      [pscustomobject]@{ File="pin-02.png"; Title="Cat Keeps Pushing the Water Bowl"; Subtitle="Weight, grip, and station placement usually matter first."; Bullets=@("Heavier bowl","Grippy mat","Clean weekly"); Description="Cat water station setup with bowls, mats, fountains, and what to skip. #ad"; Bg="#c76b57"; Panel="#fbfaf6"; Ink="#1f2523"; Muted="#62685f"; Accent="#24463f" },
      [pscustomobject]@{ File="pin-03.png"; Title="Before You Buy a Cat Fountain"; Subtitle="Fountains can help, but only if you will clean them often."; Bullets=@("Try bowl stability","Watch preference","Clean parts often"); Description="What to buy first for cat water bowl mess and when a fountain is worth it. #ad"; Bg="#6f8f86"; Panel="#fbfaf6"; Ink="#1f2523"; Muted="#62685f"; Accent="#c76b57" }
    )
  },
  [pscustomobject]@{
    Slug = "ants-in-cat-food"; Category = "Food And Water"; Board = "Cat Feeding Stations"; Url = "$BaseUrl/problems/feeding-water/ants-in-cat-food/"; Keywords = "ants in cat food, ant proof cat bowl, cat food storage, cat feeding mat, keep ants out of cat bowl"; VideoHook = "Ants in cat food need a cleaner station and sealed storage, not sprays beside the bowl."
    Pins = @(
      [pscustomobject]@{ File="pin-01.png"; Title="Ants in Cat Food?"; Subtitle="Isolate the bowl, seal the food, and clean crumbs daily."; Bullets=@("Ant moat bowl","Sealed food bin","Daily wipe-down"); Description="A practical ant-resistant cat food setup with bowl, storage, mat, and safety notes. #ad"; Bg="#e7b85d"; Panel="#fbfaf6"; Ink="#1f2523"; Muted="#62685f"; Accent="#24463f" },
      [pscustomobject]@{ File="pin-02.png"; Title="Do Not Spray Near the Cat Bowl"; Subtitle="Treat the entry point separately and keep the feeding station clean."; Bullets=@("No bowl-side sprays","Remove wet food","Use sealed storage"); Description="How to keep ants out of cat food without using unsafe shortcuts near the eating area. #ad"; Bg="#24463f"; Panel="#fbfaf6"; Ink="#1f2523"; Muted="#62685f"; Accent="#c76b57" },
      [pscustomobject]@{ File="pin-03.png"; Title="Ant-Proof Cat Food Station"; Subtitle="A simple setup for bowls, crumbs, wet food, and storage."; Bullets=@("Moat bowl","Silicone mat","Can lids"); Description="Cat food ant proof bowl and feeding station ideas for recurring ant problems. #ad"; Bg="#3f6f8f"; Panel="#fbfaf6"; Ink="#1f2523"; Muted="#62685f"; Accent="#e7b85d" }
    )
  },
  [pscustomobject]@{
    Slug = "cat-carrier-hates-carrier"; Category = "Travel"; Board = "Cat Carrier And Vet Tips"; Url = "$BaseUrl/problems/travel-carriers/cat-carrier-hates-carrier/"; Keywords = "cat hates carrier, top load cat carrier, anxious cat vet trip, carrier training cat, cat carrier pad"; VideoHook = "For cats that hate carriers, the best carrier is the one you can practice with before vet day."
    Pins = @(
      [pscustomobject]@{ File="pin-01.png"; Title="Cat Hates the Carrier?"; Subtitle="A top-load carrier and tiny treat sessions can make vet day less awful."; Bullets=@("Top-load access","Leave it out","Washable pad"); Description="A low-stress carrier setup for cats that hide, fight, or panic before vet trips. #ad"; Bg="#c76b57"; Panel="#fbfaf6"; Ink="#1f2523"; Muted="#62685f"; Accent="#24463f" },
      [pscustomobject]@{ File="pin-02.png"; Title="Do Not Hide the Carrier Until Vet Day"; Subtitle="Make the carrier normal before it becomes urgent."; Bullets=@("Open at home","Treat practice","Cover for calm"); Description="Cat carrier setup for cats that hate carriers, with what to buy first and what to skip. #ad"; Bg="#6f8f86"; Panel="#fbfaf6"; Ink="#1f2523"; Muted="#62685f"; Accent="#c76b57" },
      [pscustomobject]@{ File="pin-03.png"; Title="Top-Load Carrier for Scared Cats"; Subtitle="A wider opening can reduce the wrestling match."; Bullets=@("Sturdy latches","Soft pad","Short practice"); Description="Carrier tips for anxious cats and stressful vet trips, including gentle setup notes. #ad"; Bg="#24463f"; Panel="#fbfaf6"; Ink="#1f2523"; Muted="#62685f"; Accent="#e7b85d" }
    )
  },
  [pscustomobject]@{
    Slug = "cat-wakes-me-up-at-night"; Category = "Behavior"; Board = "Cat Behavior Support"; Url = "$BaseUrl/problems/behavior-support/cat-wakes-me-up-at-night/"; Keywords = "cat wakes me up at night, automatic cat feeder, cat meows at night, puzzle feeder cat, cat night routine"; VideoHook = "If your cat wakes you for food, move the food reward away from your pillow."
    Pins = @(
      [pscustomobject]@{ File="pin-01.png"; Title="Cat Wakes You Up at Night?"; Subtitle="Move food rewards to a timed feeder and play hard before bed."; Bullets=@("Timed feeder","Evening play","Consistent boundary"); Description="A practical setup for cats that wake owners at night for food, attention, or play. #ad"; Bg="#3f6f8f"; Panel="#fbfaf6"; Ink="#1f2523"; Muted="#62685f"; Accent="#e7b85d" },
      [pscustomobject]@{ File="pin-02.png"; Title="Stop the 4 AM Breakfast Routine"; Subtitle="If the wakeup works, your cat will keep using it."; Bullets=@("Auto feeder","Puzzle dinner","No bed feeding"); Description="What to buy first when a cat wakes you up at night, plus what to skip. #ad"; Bg="#e7b85d"; Panel="#fbfaf6"; Ink="#1f2523"; Muted="#62685f"; Accent="#24463f" },
      [pscustomobject]@{ File="pin-03.png"; Title="Night Waking Cat Setup"; Subtitle="Food timing, play, and quiet enrichment before more random toys."; Bullets=@("Wand play","Timed snack","Vet check sudden changes"); Description="Cat night waking setup with feeder, enrichment, and health boundary notes. #ad"; Bg="#c76b57"; Panel="#fbfaf6"; Ink="#1f2523"; Muted="#62685f"; Accent="#24463f" }
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
