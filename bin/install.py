#!/usr/bin/env python3

"""Install any dotfiles that aren't already linked to this repo."""

import argparse
import enum
import logging
from pathlib import Path
import subprocess
import sys
from typing import Any


BASHRC = ".bashrc"
GITCONFIG = ".gitconfig"
TMUX_CONF = ".tmux.conf"
VIMRC = ".vimrc"
ZSHRC = ".zshrc"

HOME = Path.home()
HOME_BASHRC = HOME / BASHRC
HOME_GITCONFIG = HOME / GITCONFIG
HOME_TMUX_CONF = HOME / TMUX_CONF
HOME_VIMRC = HOME / VIMRC
HOME_ZSHRC = HOME / ZSHRC

DF = HOME / ".dotfiles"
DF_BASHRC = DF / BASHRC
DF_CORP_DOTFILES = DF / "corp-dotfiles"
DF_GITCONFIG = DF / GITCONFIG
DF_TMUX_CONF = DF / TMUX_CONF
DF_VIMRC = DF / VIMRC
DF_ZSHRC = DF / ZSHRC


class Target(enum.StrEnum):
    """Things we might want to install."""
    BASHRC = ".bashrc"
    CORP_DOTFILES = "corp-dotfiles"
    GITCONFIG = ".gitconfig"
    TMUX_CONF = ".tmux.conf"
    VIMRC = ".vimrc"
    ZSHRC = ".zshrc"


def parse_args(argv: list[str]) -> argparse.Namespace:
    """Interpret command-line options for this script."""
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--pretend", help="Don't actually change anything", action="store_true"
    )
    parser.add_argument(
        "--only",
        nargs="*",
        help="Only install the selected config(s)",
        dest="targets",
        choices=[target.value for target in Target],
        default=[target.value for target in Target],
    )
    return parser.parse_args(argv)


class FSInterface:
    """Class to interact with the filesystem."""

    def __init__(self, pretend: bool = False) -> None:
        self.pretend = pretend

    def append_to_file(self, filepath: Path, lines: list[str]) -> None:
        """Add lines to the end of a file."""
        assert isinstance(lines, list)
        if not lines:
            logging.info("No lines to append to %s", filepath)
            return
        if filepath.is_file() and filepath.read_text()[-2:] != "\n\n":
            lines = ["\n", *lines]
        if self.pretend:
            logging.info("PRETEND: Append these lines to %s:", filepath)
            lines = [line.replace("\t", " " * 4) for line in lines]
            longest = max([len(line) for line in lines] or [0])
            logging.info("-" * (longest + 4))
            for line in lines:
                logging.info("| %s |", line.ljust(longest))
            logging.info("-" * (longest + 4))
            return
        with filepath.open("a") as f:
            logging.info("Appending %d lines to %s", len(lines), filepath)
            for line in lines:
                f.write(line + "\n")

    def create_symlink(self, target: Path, link_path: Path) -> None:
        """Create a symlink to target at link_path."""
        assert target.is_file()
        if self.pretend:
            logging.info("PRETEND: Create symlink to %s at %s", target, link_path)
            return
        logging.info("Creating symlink to %s at %s", target, link_path)
        link_path.symlink_to(target)

    def ensure_dir_exists(self, dir_path: Path) -> None:
        """If the dir does not exist, create it."""
        if not dir_path.exists():
            self.mkdir(dir_path)

    def mkdir(self, dir_path: Path, **kwargs: Any) -> None:
        """Create a directory."""
        if self.pretend:
            logging.info("PRETEND: Create directory: %s", dir_path)
            return
        dir_path.mkdir(**kwargs)

    def run(self, cmd: list[str | Path], **kwargs: Any) -> None:
        """Run a command."""
        if self.pretend:
            logging.info("PRETEND: Run command %s (kwargs=%s)", cmd, kwargs)
            return
        logging.info("Running command %s (kwargs=%s)", cmd, kwargs)
        subprocess.run(cmd, check=True, **kwargs)


def _file_contains_string(filepath: Path, string: str) -> bool:
    if not filepath.is_file():
        return False
    return string in filepath.read_text()


def append_import_lines(
    fsi: FSInterface, home_filepath: Path, import_lines: list[str]
) -> None:
    """Append lines that let home_filepath import from .dotfiles."""
    if _file_contains_string(home_filepath, "\n".join(import_lines).strip()):
        logging.info("%s already imports from dotfiles. Skipping.", home_filepath.name)
        return
    fsi.append_to_file(home_filepath, import_lines)


def setup_corp_dotfiles(fsi: FSInterface) -> None:
    """Set up additional dotfiles that live on-corp."""
    if DF_CORP_DOTFILES.is_dir():
        logging.info("%s exists. Skipping.", DF_CORP_DOTFILES)
        return
    fsi.run(
        [
            "git",
            "clone",
            "sso://user/gredelston/.dotfiles",
            str(DF_CORP_DOTFILES),
        ],
    )


def setup_bashrc(fsi: FSInterface) -> None:
    """Setup .bashrc, the config file for Bash."""
    append_import_lines(
        fsi, HOME_BASHRC, ["# Import my standard .bashrc", f"source {DF_BASHRC}"]
    )


def setup_zshrc(fsi: FSInterface) -> None:
    """Setup .zshrc, the config file for Zsh."""
    append_import_lines(
        fsi, HOME_ZSHRC, ["# Import my standard .zshrc", f"source {DF_ZSHRC}"]
    )


def setup_gitconfig(fsi: FSInterface) -> None:
    """Setup .gitconfig, the config file for Git."""
    append_import_lines(
        fsi,
        HOME_GITCONFIG,
        ["[include]", f"\tpath = {DF_GITCONFIG}"],
    )


def setup_tmux(fsi: FSInterface) -> None:
    """Setup .tmux.conf, the config file for Tmux."""
    if HOME_TMUX_CONF.is_file():
        logging.info("%s exists. Not linking %s.", HOME_TMUX_CONF, TMUX_CONF)
        return
    fsi.create_symlink(DF_TMUX_CONF, HOME_TMUX_CONF)


def setup_vimrc(fsi: FSInterface) -> None:
    """Setup .vimrc, the config file for vi/vim."""
    append_import_lines(fsi, HOME_VIMRC, [f"source {DF_VIMRC}"])


def main(argv: list[str]) -> None:
    """Main script entrypoint. Install relevant dotfiles."""
    logging.basicConfig(level=logging.INFO)
    args = parse_args(argv)
    fsi = FSInterface(args.pretend)
    if Target.CORP_DOTFILES in args.targets:
        setup_corp_dotfiles(fsi)
    if Target.BASHRC in args.targets:
        setup_bashrc(fsi)
    if Target.GITCONFIG in args.targets:
        setup_gitconfig(fsi)
    if Target.TMUX_CONF in args.targets:
        setup_tmux(fsi)
    if Target.VIMRC in args.targets:
        setup_vimrc(fsi)
    if Target.ZSHRC in args.targets:
        setup_zshrc(fsi)


if __name__ == "__main__":
    main(sys.argv[1:])
