param(
    [string] $ProfilePattern = ".*",
    [switch] $Clear,
    [switch] $Install
)

$config = @{
    "Default" = @("humao.rest-client")
    "pwsh"    = @("ms-vscode.powershell")
    "py"      = @("ms-python.python")
    "az"      = @("humao.rest-client", "ms-vscode.azure-account", "ms-vscode.azurecli")
    "dotnet"  = @("humao.rest-client", "ms-dotnettools.csharp")
}

if ($Clear) {
    foreach ($p in ($config.Keys | ? { $_ -match $ProfilePattern })) {
        Write-Host "clear profile" $p
        code --profile $p --list-extensions | % { code --profile $p --uninstall-extension $_ --force }
    }
}

if ($Install) {
    foreach ($p in ($config.Keys | ? { $_ -match $ProfilePattern })) {
        Write-Host "install profile" $p "extensions"
        foreach ($e in $config[$p]) {
            code --profile $p --install-extension $e --force
        }
    }
}