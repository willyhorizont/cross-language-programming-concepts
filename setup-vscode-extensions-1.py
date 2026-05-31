import argparse
import re
import subprocess
import sys

# Konfigurasi data profil dan ekstensinya
CONFIG = {
    "Default": ["humao.rest-client"],
    "pwsh": ["ms-vscode.powershell"],
    "py": ["ms-python.python"],
    "az": ["humao.rest-client", "ms-vscode.azure-account", "ms-vscode.azurecli"],
    "dotnet": ["humao.rest-client", "ms-dotnettools.csharp"]
}

def run_command(cmd):
    """Menjalankan command CLI dan mengembalikan output teks."""
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return result.stdout.splitlines()
    except subprocess.CalledProcessError as e:
        print(f"Error running command {' '.join(cmd)}: {e.stderr}", file=sys.stderr)
        return []

def main():
    # Setup CLI arguments
    parser = argparse.ArgumentParser(description="Manage VS Code Profile Extensions")
    parser.add_argument("--profile-pattern", default=".*", help="Regex pattern to match profiles")
    parser.add_argument("--clear", action="store_true", help="Uninstall extensions for matched profiles")
    parser.add_argument("--install", action="store_true", help="Install extensions for matched profiles")
    args = parser.parse_args()

    # Filter profil berdasarkan regex pattern
    pattern = re.compile(args.profile_pattern)
    matched_profiles = [p for p in CONFIG.keys() if pattern.search(p)]

    for p in matched_profiles:
        # Proses CLEAR jika flag aktif
        if args.clear:
            print(f"clear profile {p}")
            extensions = run_command(["code", "--profile", p, "--list-extensions"])
            for ext in extensions:
                if ext.strip():
                    print(f"  Uninstalling {ext}...")
                    subprocess.run(["code", "--profile", p, "--uninstall-extension", ext, "--force"], capture_output=True)

        # Proses INSTALL jika flag aktif
        if args.install:
            print(f"install profile {p} extensions")
            for e in CONFIG[p]:
                print(f"  Installing {e}...")
                subprocess.run(["code", "--profile", p, "--install-extension", e, "--force"], capture_output=True)

if __name__ == "__main__":
    main()
