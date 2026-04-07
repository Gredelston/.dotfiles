#!/usr/bin/env python3

"""Helper script to transition existing environments to XDG dotfile paths."""

import logging
from pathlib import Path
import subprocess
import sys

def cleanup_legacy_symlinks() -> None:
    """Remove legacy configuration symlinks from the home directory."""
    home = Path.home()
    targets = [
        home / ".tmux.conf",
        home / ".init.vim",
    ]
    for target in targets:
        if target.exists() or target.is_symlink():
            logging.info("Removing legacy target: %s", target)
            target.unlink()

def run_installer() -> None:
    """Run the updated install.py to establish new XDG symlinks."""
    installer_path = Path.home() / ".dotfiles" / "bin" / "install.py"
    logging.info("Running installer: %s", installer_path)
    subprocess.run([sys.executable, str(installer_path)], check=True)

def main() -> None:
    logging.basicConfig(level=logging.INFO)
    logging.info("Starting XDG dotfiles migration...")
    cleanup_legacy_symlinks()
    run_installer()
    logging.info("Migration complete!")

if __name__ == "__main__":
    main()
