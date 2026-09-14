Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead("D:\PRM392_lab01\Lab 1_Setting Up Flutter and Running Your First App.docx")
$entry = $zip.GetEntry("word/document.xml")
$reader = new-object System.IO.StreamReader($entry.Open())
$xmlString = $reader.ReadToEnd()
$reader.Close()
$zip.Dispose()
$xml = [xml]$xmlString
$xml.DocumentElement.InnerText
