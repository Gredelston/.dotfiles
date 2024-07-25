#!/usr/bin/env python3

import argparse
import logging
import os
from pathlib import Path
import sys
from typing import Any


BASHRC = '.bashrc'
GITCONFIG = '.gitconfig'
INITVIM = 'init.vim'
TMUX_CONF = '.tmux.conf'
VIMRC = '.vimrc'
ZSHRC = '.zshrc'

HOME = Path.home()
HOME_BASHRC = HOME / BASHRC
HOME_INITVIM = HOME / '.config' / 'nvim' / INITVIM
HOME_GITCONFIG = HOME / GITCONFIG
HOME_TMUX_CONF = HOME / TMUX_CONF
HOME_VIMRC = HOME / VIMRC
HOME_ZSHRC = HOME / ZSHRC

DF = HOME / '.dotfiles'
DF_BASHRC = DF / BASHRC
DF_CROS_SDK_BASHRC = DF / '.cros_sdk_bashrc'
DF_INITVIM = DF / INITVIM
DF_GITCONFIG = DF / GITCONFIG
DF_TMUX_CONF = DF / TMUX_CONF
DF_VIMRC = DF / VIMRC
DF_ZSHRC = DF / ZSHRC


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--pretend",
                        help="Don't actually change anything",
                        action="store_true")
    return parser.parse_args(argv)


def _in_chroot() -> bool:
    return os.path.isfile('/etc/cros_chroot_version')


class FSInterface:
    """Class to interact with the filesystem."""
    def __init__(self, pretend: bool = False) -> None:
        self.pretend = pretend

    def append_to_file(self, filepath: Path, lines: list[str]) -> None:
        """Add lines to the end of a file."""
        assert type(lines) is list
        if not lines:
            logging.info('No lines to append to %s', filepath)
            return
        if self.pretend:
            logging.info('PRETEND: Append these lines to %s:', filepath)
            lines = [line.replace('\t', ' '*4) for line in lines]
            longest = max([len(line) for line in lines] or [0])
            logging.info('-' * (longest + 4))
            for line in lines:
                logging.info('| %s |', line.ljust(longest))
            logging.info('-' * (longest + 4))
            return
        with filepath.open('a') as f:
            logging.info('Appending %d lines to %s', len(lines), filepath)
            for line in lines:
                f.write('\n')
                f.write(line)

    def create_link(self, target: Path, link_path: Path) -> None:
        assert target.is_file()
        if self.pretend:
            logging.info('PRETEND: Create link to %s at %s', target, link_path)
            return
        logging.info('Creating link to %s at %s', target, link_path)
        link_path.hardlink_to(target)

    def ensure_dir_exists(self, dir_path: Path) -> None:
        """If the dir does not exist, create it."""
        if not dir_path.exists():
            self.mkdir(dir_path)

    def mkdir(self, dir_path: Path, **kwargs: Any) -> None:
        """Create a directory."""
        if self.pretend:
            logging.info('PRETEND: Create directory: {dir_path}')
            return
        dir_path.mkdir(**kwargs)


def _file_contains_string(filepath: Path, string: str) -> bool:
    with filepath.open() as f:
        return string in '\n'.join(f.readlines())


def setup_bashrc(fsi: FSInterface) -> None:
    """Setup .bashrc, the config file for Bash."""
    logging.info('Sourcing %s in %s', DF_BASHRC, HOME_BASHRC)
    bashrcs_to_source: list[Path] = [DF_BASHRC]
    if _in_chroot():
        bashrcs_to_source.append(DF_CROS_SDK_BASHRC)
        logging.info('Sourcing the following .bashrc files in %s:', HOME_BASHRC)
        logging.info(bashrcs_to_source)
    lines = []
    for bashrc_to_source in bashrcs_to_source:
        if _file_contains_string(HOME_BASHRC, f'source {DF_BASHRC}'):
            logging.info('%s already sourced. Skipping.', bashrc_to_source)
            continue
        lines.extend(
            ['', '# Import my standard .bashrc', f'source {DF_BASHRC}'])
    fsi.append_to_file(HOME_BASHRC, lines)


def setup_zshrc(fsi: FSInterface) -> None:
    """Setup .zshrc, the config file for Zsh."""
    logging.info('Sourcing %s in %s', DF_ZSHRC, HOME_ZSHRC)
    zshrcs_to_source: list[Path] = [DF_ZSHRC]
    if _in_chroot():
        zshrcs_to_source.append(DF_CROS_SDK_ZSHRC)
        logging.info('Sourcing the following .zshrc files in %s:', HOME_ZSHRC)
        logging.info(zshrcs_to_source)
    lines = []
    for zshrc_to_source in zshrcs_to_source:
        if _file_contains_string(HOME_ZSHRC, f'source {DF_ZSHRC}'):
            logging.info('%s already sourced. Skipping.', zshrc_to_source)
            continue
        lines.extend(['', '# Import my standard .zshrc', f'source {DF_ZSHRC}'])
    fsi.append_to_file(HOME_ZSHRC, lines)


def setup_gitconfig(fsi: FSInterface) -> None:
    """Setup .gitconfig, the config file for Git."""
    logging.info('Including %s in %s', DF_GITCONFIG, HOME_GITCONFIG)
    lines = ['[include]', f'\tpath = {DF_GITCONFIG}']
    fsi.append_to_file(HOME_GITCONFIG, lines)


def setup_tmux(fsi: FSInterface) -> None:
    """Setup .tmux.conf, the config file for Tmux."""
    if HOME_TMUX_CONF.is_file():
        logging.warning('%s exists. Not linking %s.', HOME_TMUX_CONF, TMUX_CONF)
        return
    fsi.create_link(DF_TMUX_CONF, HOME_TMUX_CONF)


def setup_vimrc(fsi: FSInterface) -> None:
    """Setup .vimrc, the config file for vi/vim."""
    if HOME_VIMRC.is_file():
        logging.warning(
            '%s exists. Appending "source %s".', HOME_VIMRC, DF_VIMRC)
        fsi.append_to_file(HOME_VIMRC, [f'source {DF_VIMRC}'])
    else:
        fsi.create_link(DF_VIMRC, HOME_VIMRC)

def setup_initvim(fsi: FSInterface) -> None:
    """Setup init.vim, the config file for Neovim."""
    fsi.ensure_dir_exists(HOME_INITVIM.parent)
    if HOME_INITVIM.is_file():
        logging.warning(
            '%s exists. Appending "source %s".', HOME_INITVIM, DF_INITVIM)
        fsi.append_to_file(HOME_INITVIM, [f'source {DF_INITVIM}'])
    else:
        fsi.create_link(DF_INITVIM, HOME_INITVIM)


def main(argv: list[str]) -> None:
    logging.basicConfig(level=logging.INFO)
    args = parse_args(argv)
    fsi = FSInterface(args.pretend)
    setup_bashrc(fsi)
    setup_gitconfig(fsi)
    setup_tmux(fsi)
    setup_vimrc(fsi)
    setup_initvim(fsi)
    setup_zshrc(fsi)


if __name__ == '__main__':
    main(sys.argv[1:])
