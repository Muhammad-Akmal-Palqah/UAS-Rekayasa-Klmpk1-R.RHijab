$out = 'C:\Users\POLYTRON\rr-hijab-integration\rr-hijab-backend\storage\cacert.pem'
$uri = 'https://curl.se/ca/cacert.pem'
Try {
    Invoke-WebRequest -Uri $uri -OutFile $out -UseBasicParsing -ErrorAction Stop
    Write-Output "DOWNLOADED:$out"
} Catch {
    Write-Output "DOWNLOAD_FAILED:$($_.Exception.Message)"
    exit 1
}