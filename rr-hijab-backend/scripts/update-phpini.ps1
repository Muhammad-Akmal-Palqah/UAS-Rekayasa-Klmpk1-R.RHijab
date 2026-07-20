$ini = 'C:\\tools\\php85\\php.ini'
if (-not (Test-Path $ini)) {
    Write-Output "INI_MISSING:$ini"
    exit 1
}
$text = Get-Content $ini -Raw
$text = [regex]::Replace($text, '^(?m)\s*;?\s*curl\.cainfo\s*=.*', 'curl.cainfo = "C:\\Users\\POLYTRON\\rr-hijab-integration\\rr-hijab-backend\\storage\\cacert.pem"')
$text = [regex]::Replace($text, '^(?m)\s*;?\s*openssl\.cafile\s*=.*', 'openssl.cafile = "C:\\Users\\POLYTRON\\rr-hijab-integration\\rr-hijab-backend\\storage\\cacert.pem"')
Set-Content -Path $ini -Value $text -Force
Write-Output "UPDATED_INI:$ini"