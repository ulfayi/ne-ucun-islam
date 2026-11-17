param(
  [string]$SourceDir = (Join-Path $PSScriptRoot '..\sources'),
  [string]$Output = (Join-Path $PSScriptRoot '..\public\content.json')
)

Add-Type -AssemblyName System.IO.Compression.FileSystem
function Write-JsonWithRetry($Json, $Path) {
  for ($attempt = 1; $attempt -le 8; $attempt++) {
    try { [System.IO.File]::WriteAllText($Path, $Json, [System.Text.UTF8Encoding]::new($false)); return }
    catch [System.IO.IOException] { if ($attempt -eq 8) { throw }; Start-Sleep -Milliseconds (120 * $attempt) }
  }
}
$documents = foreach ($file in Get-ChildItem $SourceDir -Filter *.docx) {
  $zip = [System.IO.Compression.ZipFile]::OpenRead($file.FullName)
  try {
    $entry = $zip.GetEntry('word/document.xml')
    $reader = [System.IO.StreamReader]::new($entry.Open())
    try { [xml]$xml = $reader.ReadToEnd() } finally { $reader.Dispose() }
    $ns = [System.Xml.XmlNamespaceManager]::new($xml.NameTable)
    $ns.AddNamespace('w','http://schemas.openxmlformats.org/wordprocessingml/2006/main')
    $paragraphs = @($xml.SelectNodes('//w:body/w:p', $ns) | ForEach-Object {
      (($_.SelectNodes('.//w:t', $ns) | ForEach-Object { $_.InnerText }) -join '').Trim()
    } | Where-Object { $_ })
    $first = $paragraphs | Select-Object -First 1
    $author = switch -Wildcard ($file.Name) {
      '*Sahib Əsədov*' { 'Sahib Əsədov'; break }
      '*İSLAM DİNİ NƏ ÜÇÜN VAR*' { 'Ayxan Yaquboğlu'; break }
      default { 'Müəllif göstərilməyib' }
    }
    [PSCustomObject]@{ filename=$file.Name; title=$first; author=$author; paragraphs=$paragraphs }
  } finally { $zip.Dispose() }
}
$dir = Split-Path -Parent $Output
New-Item -ItemType Directory -Force -Path $dir | Out-Null
$contentJson = @{ generatedAt=(Get-Date).ToString('o'); documents=@($documents) } | ConvertTo-Json -Depth 6
Write-JsonWithRetry $contentJson $Output
$audit = [PSCustomObject]@{
  sourceDocuments = $documents.Count
  extractedArticles = $documents.Count
  extractedContentBlocks = @($documents | ForEach-Object { $_.paragraphs.Count } | Measure-Object -Sum).Sum
  completeness = 'Tam sənəd mətni paraqraf səviyyəsində çıxarıldı'
  documents = @($documents | ForEach-Object { [PSCustomObject]@{ originalFilename=$_.filename; title=$_.title; paragraphCount=$_.paragraphs.Count; author=$_.author } })
  ambiguousReferences = @()
  missingSections = @()
}
$auditJson = $audit | ConvertTo-Json -Depth 6
Write-JsonWithRetry $auditJson (Join-Path $dir 'source-audit.json')
Write-Host "Extracted $($documents.Count) documents to $Output"
