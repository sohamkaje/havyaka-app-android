# Creates the upload keystore for Google Play release signing.
# Run from PowerShell: .\android\create-upload-keystore.ps1
#
# Back up upload-keystore.jks and your passwords securely.
# If lost, you cannot publish updates to the same Play Store listing.

$keystorePath = Join-Path $env:USERPROFILE "upload-keystore.jks"

if (Test-Path $keystorePath) {
    Write-Host "Keystore already exists: $keystorePath"
    exit 0
}

Write-Host "Creating upload keystore at: $keystorePath"
Write-Host "You will be prompted for keystore and key passwords."

keytool -genkeypair -v `
    -keystore $keystorePath `
    -storetype JKS `
    -alias upload `
    -keyalg RSA `
    -keysize 2048 `
    -validity 10000 `
    -dname "CN=HAA Convention, OU=Havyaka, O=Havyaka Association of the Americas, L=Aurora, ST=IL, C=US"

if ($LASTEXITCODE -ne 0) {
    Write-Error "keytool failed. Ensure Java JDK is installed and keytool is on PATH."
    exit 1
}

$keyPropertiesPath = Join-Path $PSScriptRoot "key.properties"
$storeFileEscaped = $keystorePath -replace '\\', '\\'

Write-Host ""
Write-Host "Next: copy android/key.properties.example to android/key.properties"
Write-Host "Set storeFile=$storeFileEscaped"
Write-Host "Set storePassword and keyPassword to the values you chose above."
