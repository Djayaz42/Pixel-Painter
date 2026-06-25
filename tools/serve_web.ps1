$ErrorActionPreference = "Stop"

$stateLog = "C:\tmp\pixel_static_state.log"
"starting" | Set-Content -LiteralPath $stateLog
$root = Resolve-Path (Join-Path $PSScriptRoot "..\build\web")
"root=$($root.Path)" | Add-Content -LiteralPath $stateLog
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, 53217)
$listener.Start()
"listening" | Add-Content -LiteralPath $stateLog

function Get-ContentType([string] $path) {
  switch ([System.IO.Path]::GetExtension($path).ToLowerInvariant()) {
    ".html" { "text/html; charset=utf-8" }
    ".js" { "application/javascript; charset=utf-8" }
    ".css" { "text/css; charset=utf-8" }
    ".json" { "application/json; charset=utf-8" }
    ".png" { "image/png" }
    ".jpg" { "image/jpeg" }
    ".jpeg" { "image/jpeg" }
    ".svg" { "image/svg+xml" }
    ".wasm" { "application/wasm" }
    ".otf" { "font/otf" }
    ".ttf" { "font/ttf" }
    default { "application/octet-stream" }
  }
}

function Send-Response($stream, [int] $status, [string] $contentType, [byte[]] $body) {
  $reason = if ($status -eq 200) { "OK" } elseif ($status -eq 404) { "Not Found" } else { "Error" }
  $headers = "HTTP/1.1 $status $reason`r`nContent-Type: $contentType`r`nContent-Length: $($body.Length)`r`nConnection: close`r`nCache-Control: no-cache`r`n`r`n"
  $headerBytes = [System.Text.Encoding]::ASCII.GetBytes($headers)
  $stream.Write($headerBytes, 0, $headerBytes.Length)
  if ($body.Length -gt 0) {
    $stream.Write($body, 0, $body.Length)
  }
}

while ($true) {
  $client = $listener.AcceptTcpClient()
  try {
    $stream = $client.GetStream()
    $buffer = New-Object byte[] 4096
    $read = $stream.Read($buffer, 0, $buffer.Length)
    $request = [System.Text.Encoding]::ASCII.GetString($buffer, 0, $read)
    $firstLine = ($request -split "`r?`n")[0]
    $path = "/"
    if ($firstLine -match "^[A-Z]+\s+([^\s]+)") {
      $path = $matches[1].Split("?")[0]
    }

    $relativePath = [Uri]::UnescapeDataString($path.TrimStart("/"))
    if ([string]::IsNullOrWhiteSpace($relativePath)) {
      $relativePath = "index.html"
    }

    $candidate = Join-Path $root $relativePath
    if (-not (Test-Path -LiteralPath $candidate -PathType Leaf)) {
      $candidate = Join-Path $root "index.html"
    }

    $resolved = Resolve-Path -LiteralPath $candidate
    if (-not $resolved.Path.StartsWith($root.Path)) {
      Send-Response $stream 404 "text/plain; charset=utf-8" ([System.Text.Encoding]::UTF8.GetBytes("Not found"))
      continue
    }

    $bytes = [System.IO.File]::ReadAllBytes($resolved.Path)
    Send-Response $stream 200 (Get-ContentType $resolved.Path) $bytes
  } catch {
    $body = [System.Text.Encoding]::UTF8.GetBytes("Server error")
    Send-Response $stream 500 "text/plain; charset=utf-8" $body
  } finally {
    $client.Close()
  }
}
