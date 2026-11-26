# Generates the transparent exercise artwork used by Flow.
# Run from the repository root: powershell -ExecutionPolicy Bypass -File tool/generate_assets.ps1
Add-Type -AssemblyName System.Drawing

$outDir = Join-Path $PSScriptRoot '..\assets\images'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$categories = @(
  @{ Name = 'yoga';        Color = '#B794F4'; Pose = 'seated' },
  @{ Name = 'upper-back';  Color = '#63B3ED'; Pose = 'twist' },
  @{ Name = 'lower-back';  Color = '#68D391'; Pose = 'fold' },
  @{ Name = 'split';       Color = '#F6AD55'; Pose = 'split' },
  @{ Name = 'neck';        Color = '#F687B3'; Pose = 'neck' },
  @{ Name = 'shoulder';    Color = '#4299E1'; Pose = 'reach' },
  @{ Name = 'chest';       Color = '#FC8181'; Pose = 'open' },
  @{ Name = 'arms';        Color = '#4FD1C5'; Pose = 'arms' },
  @{ Name = 'core';        Color = '#F6E05E'; Pose = 'plank' },
  @{ Name = 'hip';         Color = '#9F7AEA'; Pose = 'lunge' },
  @{ Name = 'glutes';      Color = '#ED8936'; Pose = 'bridge' },
  @{ Name = 'quads';       Color = '#48BB78'; Pose = 'kneel' },
  @{ Name = 'hamstrings';  Color = '#38B2AC'; Pose = 'fold' },
  @{ Name = 'calves';      Color = '#667EEA'; Pose = 'calf' },
  @{ Name = 'ankles';      Color = '#A0AEC0'; Pose = 'ankle' },
  @{ Name = 'morning';     Color = '#FBB6CE'; Pose = 'sunrise' },
  @{ Name = 'today-flow';  Color = '#4299E1'; Pose = 'run' }
)

function Convert-HexToColor([string]$hex, [int]$alpha = 255) {
  $hex = $hex.TrimStart('#')
  return [System.Drawing.Color]::FromArgb(
    $alpha,
    [Convert]::ToInt32($hex.Substring(0, 2), 16),
    [Convert]::ToInt32($hex.Substring(2, 2), 16),
    [Convert]::ToInt32($hex.Substring(4, 2), 16)
  )
}

function Mix-Color([System.Drawing.Color]$a, [System.Drawing.Color]$b, [double]$t) {
  return [System.Drawing.Color]::FromArgb(
    [int]($a.A + ($b.A - $a.A) * $t),
    [int]($a.R + ($b.R - $a.R) * $t),
    [int]($a.G + ($b.G - $a.G) * $t),
    [int]($a.B + ($b.B - $a.B) * $t)
  )
}

function New-RoundPen([System.Drawing.Color]$color, [float]$width) {
  $pen = New-Object System.Drawing.Pen($color, $width)
  $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
  return $pen
}

$script:size = 700
$script:center = 350

function Draw-Bone($g, [float]$x1, [float]$y1, [float]$x2, [float]$y2, [float]$width, [System.Drawing.Color]$color, [System.Drawing.Color]$halo) {
  $haloPen = New-RoundPen $halo ($width + 12)
  $g.DrawLine($haloPen, $x1, $y1, $x2, $y2)
  $haloPen.Dispose()
  $pen = New-RoundPen $color $width
  $g.DrawLine($pen, $x1, $y1, $x2, $y2)
  $pen.Dispose()
}

function Draw-Head($g, [float]$x, [float]$y, [float]$r, [System.Drawing.Color]$color, [System.Drawing.Color]$halo) {
  $haloBrush = New-Object System.Drawing.SolidBrush($halo)
  $g.FillEllipse($haloBrush, $x - $r - 6, $y - $r - 6, ($r + 6) * 2, ($r + 6) * 2)
  $haloBrush.Dispose()
  $brush = New-Object System.Drawing.SolidBrush($color)
  $g.FillEllipse($brush, $x - $r, $y - $r, $r * 2, $r * 2)
  $brush.Dispose()
}

function Draw-Figure($g, [string]$pose, [System.Drawing.Color]$tone, [System.Drawing.Color]$halo) {
  $w = 34.0
  switch ($pose) {
    'run' {
      Draw-Head $g 392 170 48 $tone $halo
      Draw-Bone $g 382 226 340 360 58 $tone $halo
      Draw-Bone $g 350 255 268 305 $w $tone $halo
      Draw-Bone $g 268 305 232 390 $w $tone $halo
      Draw-Bone $g 362 268 448 300 $w $tone $halo
      Draw-Bone $g 448 300 488 372 $w $tone $halo
      Draw-Bone $g 340 360 282 440 $w $tone $halo
      Draw-Bone $g 282 440 220 540 $w $tone $halo
      Draw-Bone $g 340 360 432 430 $w $tone $halo
      Draw-Bone $g 432 430 512 502 $w $tone $halo
      Draw-Bone $g 220 540 162 598 28 $tone $halo
      Draw-Bone $g 512 502 574 548 28 $tone $halo
    }
    'split' {
      Draw-Head $g 350 152 46 $tone $halo
      Draw-Bone $g 350 210 326 344 56 $tone $halo
      Draw-Bone $g 334 242 258 300 $w $tone $halo
      Draw-Bone $g 258 300 220 382 $w $tone $halo
      Draw-Bone $g 338 244 430 296 $w $tone $halo
      Draw-Bone $g 430 296 482 368 $w $tone $halo
      Draw-Bone $g 326 344 220 438 $w $tone $halo
      Draw-Bone $g 220 438 150 558 $w $tone $halo
      Draw-Bone $g 326 344 456 426 $w $tone $halo
      Draw-Bone $g 456 426 556 506 $w $tone $halo
    }
    'seated' {
      Draw-Head $g 402 192 50 $tone $halo
      Draw-Bone $g 396 250 340 368 58 $tone $halo
      Draw-Bone $g 368 280 292 352 $w $tone $halo
      Draw-Bone $g 292 352 248 430 $w $tone $halo
      Draw-Bone $g 372 276 454 340 $w $tone $halo
      Draw-Bone $g 454 340 506 414 $w $tone $halo
      Draw-Bone $g 340 368 238 436 $w $tone $halo
      Draw-Bone $g 238 436 340 500 $w $tone $halo
      Draw-Bone $g 340 368 452 444 $w $tone $halo
      Draw-Bone $g 452 444 504 520 $w $tone $halo
    }
    'fold' {
      Draw-Head $g 418 292 48 $tone $halo
      Draw-Bone $g 402 338 314 386 58 $tone $halo
      Draw-Bone $g 360 336 272 430 $w $tone $halo
      Draw-Bone $g 272 430 220 500 $w $tone $halo
      Draw-Bone $g 374 342 460 424 $w $tone $halo
      Draw-Bone $g 460 424 516 492 $w $tone $halo
      Draw-Bone $g 314 386 206 454 $w $tone $halo
      Draw-Bone $g 206 454 292 528 $w $tone $halo
      Draw-Bone $g 314 386 432 474 $w $tone $halo
      Draw-Bone $g 432 474 494 540 $w $tone $halo
    }
    'twist' {
      Draw-Head $g 350 178 48 $tone $halo
      Draw-Bone $g 350 234 350 370 58 $tone $halo
      Draw-Bone $g 350 258 268 318 $w $tone $halo
      Draw-Bone $g 268 318 208 392 $w $tone $halo
      Draw-Bone $g 350 258 446 310 $w $tone $halo
      Draw-Bone $g 446 310 506 246 $w $tone $halo
      Draw-Bone $g 350 370 292 470 $w $tone $halo
      Draw-Bone $g 292 470 292 590 $w $tone $halo
      Draw-Bone $g 350 370 420 470 $w $tone $halo
      Draw-Bone $g 420 470 440 590 $w $tone $halo
    }
    'neck' {
      Draw-Head $g 378 178 52 $tone $halo
      Draw-Bone $g 364 232 348 350 58 $tone $halo
      Draw-Bone $g 356 260 270 294 $w $tone $halo
      Draw-Bone $g 270 294 230 380 $w $tone $halo
      Draw-Bone $g 356 260 442 306 $w $tone $halo
      Draw-Bone $g 442 306 474 390 $w $tone $halo
      Draw-Bone $g 348 350 288 450 $w $tone $halo
      Draw-Bone $g 288 450 290 580 $w $tone $halo
      Draw-Bone $g 348 350 414 450 $w $tone $halo
      Draw-Bone $g 414 450 424 580 $w $tone $halo
    }
    'reach' {
      Draw-Head $g 350 170 48 $tone $halo
      Draw-Bone $g 350 228 350 366 58 $tone $halo
      Draw-Bone $g 350 254 270 224 $w $tone $halo
      Draw-Bone $g 270 224 226 138 $w $tone $halo
      Draw-Bone $g 350 254 432 224 $w $tone $halo
      Draw-Bone $g 432 224 478 138 $w $tone $halo
      Draw-Bone $g 350 366 298 464 $w $tone $halo
      Draw-Bone $g 298 464 300 590 $w $tone $halo
      Draw-Bone $g 350 366 408 464 $w $tone $halo
      Draw-Bone $g 408 464 418 590 $w $tone $halo
    }
    'open' {
      Draw-Head $g 350 168 48 $tone $halo
      Draw-Bone $g 350 226 350 366 58 $tone $halo
      Draw-Bone $g 350 256 246 278 $w $tone $halo
      Draw-Bone $g 246 278 156 254 $w $tone $halo
      Draw-Bone $g 350 256 454 278 $w $tone $halo
      Draw-Bone $g 454 278 544 254 $w $tone $halo
      Draw-Bone $g 350 366 284 462 $w $tone $halo
      Draw-Bone $g 284 462 260 588 $w $tone $halo
      Draw-Bone $g 350 366 420 462 $w $tone $halo
      Draw-Bone $g 420 462 448 588 $w $tone $halo
    }
    'arms' {
      Draw-Head $g 350 170 48 $tone $halo
      Draw-Bone $g 350 228 350 366 58 $tone $halo
      Draw-Bone $g 350 252 288 308 $w $tone $halo
      Draw-Bone $g 288 308 268 214 $w $tone $halo
      Draw-Bone $g 268 214 210 178 $w $tone $halo
      Draw-Bone $g 350 252 418 312 $w $tone $halo
      Draw-Bone $g 418 312 448 216 $w $tone $halo
      Draw-Bone $g 448 216 500 178 $w $tone $halo
      Draw-Bone $g 350 366 298 464 $w $tone $halo
      Draw-Bone $g 298 464 300 590 $w $tone $halo
      Draw-Bone $g 350 366 408 464 $w $tone $halo
      Draw-Bone $g 408 464 418 590 $w $tone $halo
    }
    'plank' {
      Draw-Head $g 220 302 46 $tone $halo
      Draw-Bone $g 264 314 402 362 58 $tone $halo
      Draw-Bone $g 292 326 236 404 $w $tone $halo
      Draw-Bone $g 236 404 218 470 $w $tone $halo
      Draw-Bone $g 330 342 326 434 $w $tone $halo
      Draw-Bone $g 326 434 330 494 $w $tone $halo
      Draw-Bone $g 402 362 510 448 $w $tone $halo
      Draw-Bone $g 510 448 578 482 $w $tone $halo
      Draw-Bone $g 402 362 490 424 $w $tone $halo
      Draw-Bone $g 490 424 566 456 $w $tone $halo
    }
    'lunge' {
      Draw-Head $g 370 164 48 $tone $halo
      Draw-Bone $g 370 222 352 354 58 $tone $halo
      Draw-Bone $g 362 250 288 300 $w $tone $halo
      Draw-Bone $g 288 300 262 384 $w $tone $halo
      Draw-Bone $g 380 252 454 312 $w $tone $halo
      Draw-Bone $g 454 312 482 392 $w $tone $halo
      Draw-Bone $g 352 354 268 452 $w $tone $halo
      Draw-Bone $g 268 452 248 580 $w $tone $halo
      Draw-Bone $g 352 354 446 442 $w $tone $halo
      Draw-Bone $g 446 442 512 520 $w $tone $halo
    }
    'bridge' {
      Draw-Head $g 244 366 46 $tone $halo
      Draw-Bone $g 286 356 408 300 58 $tone $halo
      Draw-Bone $g 320 338 290 430 $w $tone $halo
      Draw-Bone $g 290 430 312 500 $w $tone $halo
      Draw-Bone $g 408 300 484 386 $w $tone $halo
      Draw-Bone $g 484 386 500 488 $w $tone $halo
      Draw-Bone $g 408 300 476 250 $w $tone $halo
      Draw-Bone $g 476 250 540 300 $w $tone $halo
    }
    'kneel' {
      Draw-Head $g 356 162 48 $tone $halo
      Draw-Bone $g 356 220 344 348 58 $tone $halo
      Draw-Bone $g 348 244 286 300 $w $tone $halo
      Draw-Bone $g 286 300 286 394 $w $tone $halo
      Draw-Bone $g 366 248 430 308 $w $tone $halo
      Draw-Bone $g 430 308 432 392 $w $tone $halo
      Draw-Bone $g 344 348 290 438 $w $tone $halo
      Draw-Bone $g 290 438 236 482 $w $tone $halo
      Draw-Bone $g 344 348 412 432 $w $tone $halo
      Draw-Bone $g 412 432 470 500 $w $tone $halo
      Draw-Bone $g 470 500 542 470 $w $tone $halo
    }
    'calf' {
      Draw-Head $g 330 160 48 $tone $halo
      Draw-Bone $g 330 218 330 356 58 $tone $halo
      Draw-Bone $g 330 244 264 298 $w $tone $halo
      Draw-Bone $g 264 298 250 386 $w $tone $halo
      Draw-Bone $g 340 244 424 300 $w $tone $halo
      Draw-Bone $g 424 300 450 388 $w $tone $halo
      Draw-Bone $g 330 356 286 462 $w $tone $halo
      Draw-Bone $g 286 462 288 580 $w $tone $halo
      Draw-Bone $g 330 356 412 454 $w $tone $halo
      Draw-Bone $g 412 454 500 500 $w $tone $halo
    }
    'ankle' {
      Draw-Head $g 350 160 48 $tone $halo
      Draw-Bone $g 350 218 350 356 58 $tone $halo
      Draw-Bone $g 350 244 276 300 $w $tone $halo
      Draw-Bone $g 276 300 260 388 $w $tone $halo
      Draw-Bone $g 350 244 424 300 $w $tone $halo
      Draw-Bone $g 424 300 440 388 $w $tone $halo
      Draw-Bone $g 350 356 306 466 $w $tone $halo
      Draw-Bone $g 306 466 300 580 $w $tone $halo
      Draw-Bone $g 350 356 404 466 $w $tone $halo
      Draw-Bone $g 404 466 456 548 $w $tone $halo
      Draw-Bone $g 456 548 530 530 26 $tone $halo
    }
    'sunrise' {
      Draw-Head $g 330 174 48 $tone $halo
      Draw-Bone $g 330 232 330 370 58 $tone $halo
      Draw-Bone $g 330 256 254 206 $w $tone $halo
      Draw-Bone $g 254 206 214 124 $w $tone $halo
      Draw-Bone $g 338 256 430 224 $w $tone $halo
      Draw-Bone $g 430 224 512 266 $w $tone $halo
      Draw-Bone $g 330 370 290 472 $w $tone $halo
      Draw-Bone $g 290 472 284 590 $w $tone $halo
      Draw-Bone $g 330 370 398 468 $w $tone $halo
      Draw-Bone $g 398 468 430 590 $w $tone $halo
    }
  }
}

foreach ($category in $categories) {
  $size = 700
  $bmp = New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
  $g.Clear([System.Drawing.Color]::Transparent)

  $base = Convert-HexToColor $category.Color
  $light = Mix-Color $base ([System.Drawing.Color]::White) 0.72
  $tone = Mix-Color $base ([System.Drawing.Color]::FromArgb(255, 31, 41, 55)) 0.68
  $halo = [System.Drawing.Color]::FromArgb(37, 255, 255, 255)

  # Soft radial wash.
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $path.AddEllipse(58, 58, 584, 584)
  $brush = New-Object System.Drawing.Drawing2D.PathGradientBrush($path)
  $brush.CenterColor = [System.Drawing.Color]::FromArgb(235, $light.R, $light.G, $light.B)
  $brush.SurroundColors = @([System.Drawing.Color]::FromArgb(0, $base.R, $base.G, $base.B))
  try {
    $blend = New-Object System.Drawing.Drawing2D.ColorBlend(3)
    $blend.Colors = @(
      [System.Drawing.Color]::FromArgb(225, $light.R, $light.G, $light.B),
      [System.Drawing.Color]::FromArgb(130, $base.R, $base.G, $base.B),
      [System.Drawing.Color]::FromArgb(0, $base.R, $base.G, $base.B)
    )
    $blend.Positions = @(0.0, 0.62, 1.0)
    $brush.Blend = $blend
  } catch { }
  $g.FillPath($brush, $path)
  $brush.Dispose()
  $path.Dispose()

  # Thin decorative ring and orbiting dots.
  $ringPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(54, $base.R, $base.G, $base.B), 2)
  $g.DrawEllipse($ringPen, 104, 104, 492, 492)
  $ringPen.Dispose()
  $dotBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(95, $base.R, $base.G, $base.B))
  foreach ($dot in @(@(118, 208, 7), @(560, 172, 5), @(534, 486, 8), @(156, 512, 5), @(586, 340, 4))) {
    $g.FillEllipse($dotBrush, $dot[0], $dot[1], $dot[2], $dot[2])
  }
  $dotBrush.Dispose()

  Draw-Figure $g $category.Pose $tone $halo

  $file = Join-Path $outDir ($category.Name + '.png')
  $bmp.Save($file, [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose()
  $bmp.Dispose()
  Write-Output "wrote $file"
}
