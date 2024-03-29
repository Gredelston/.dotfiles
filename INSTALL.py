#!/usr/bin/env python3

import argparse
import logging
import os
import sys
from typing import List


BASHRC = '.bashrc'
GITCONFIG = '.gitconfig'
INITVIM = 'init.vim'
TMUX_CONF = '.tmux.conf'
VIMRC = '.vimrc'

HOME = os.environ['HOME']
HOME_BASHRC = os.path.join(HOME, BASHRC)
HOME_INITVIM = os.path.join(HOME, '.config', 'nvim', INITVIM)
HOME_GITCONFIG = os.path.join(HOME, GITCONFIG)
HOME_TMUX_CONF = os.path.join(HOME, TMUX_CONF)
HOME_VIMRC = os.path.join(HOME, VIMRC)

DF = os.path.join(HOME, '.dotfiles')
DF_BASHRC = os.path.join(DF, BASHRC)
DF_CROS_SDK_BASHRC = os.path.join(DF, '.cros_sdk_bashrc')
DF_INITVIM = os.path.join(DF, INITVIM)
DF_GITCONFIG = os.path.join(DF, GITCONFIG)
DF_TMUX_CONF = os.path.join(DF, TMUX_CONF)
DF_VIMRC = os.path.join(DF, VIMRC)


def parse_args(argv: List[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--pretend",
                        help="Don't actually change anything",
                        action="store_true")
    return parser.parse_args(argv)


def _in_chroot() -> bool:
    return os.path.isfile('/etc/cros_chroot_version')


class FSInterface():
    """Class to interact with the filesystem."""
    def __init__(self, pretend: bool=False):
        self.pretend = pretend

    def append_to_file(self, filename: str, lines: List[str]):
        assert type(lines) is list
        if self.pretend:
            logging.info('PRETEND: Append these lines to %s:', filename)
            lines = [line.replace('\t', ' '*4) for line in lines]
            longest = max([len(line) for line in lines] or [0])
            logging.info('-' * (longest + 4))
            for line in lines:
                logging.info('| %s |', line.ljust(longest))
            logging.info('-' * (longest + 4))
            return
        with open(filename, 'a') as f:
            logging.info('Appending %d lines to %s', len(lines), filename)
            for line in lines:
                f.write('\n')
                f.write(line)

    def create_link(self, target: str, link_name: str):
        assert os.path.isfile(target)
        if self.pretend:
            logging.info('PRETEND: Create link to %s at %s', target, link_name)
            return
        logging.info('Creating link to %s at %s', target, link_name)
        os.link(target, link_name)

    def ensure_dir_exists(self, dirname: str):
        """If the dir does not exist, create it."""
        if not os.path.exists(dirname):
            self.mkdir(dirname)

    def mkdir(self, dirname: str, mode: int=0o777):
        """Create a directory, recursively."""
        if self.pretend:
            logging.info('PRETEND: Create directory(s): %s', dirname)
            return
        os.makedirs(dirname, mode)


def _file_contains_string(filepath: str, string: str) -> bool:
    with open(filepath) as f:
        return string in ''.join(f.readlines())


def setup_bashrc(fsi: FSInterface):
    """Setup .bashrc, the config file for Bash"""
    logging.info('Sourcing %s in %s', DF_BASHRC, HOME_BASHRC)
    bashrcs_to_source: List[str] = [DF_BASHRC]
    if _in_chroot():
        bashrcs_to_source.append(DF_CROS_SDK_BASHRC)
        logging.info(f'Sourcing the following .bashrc files in {HOME_BASHRC}:')
        logging.info(bashrcs_to_source)
    lines = []
    for bashrc_to_source in bashrcs_to_source:
        if _file_contains_string(HOME_BASHRC, f'source {DF_BASHRC}'):
            logging.info(f'{bashrc_to_source} already sourced. Skipping.')
            continue
        lines.extend(['',
                 '# Import my standard .bashrc',
                 'source %s' % DF_BASHRC])
    fsi.append_to_file(HOME_BASHRC, lines)


def setup_gitconfig(fsi: FSInterface):
    """Setup .gitconfig, the config file for Git"""
    logging.info('Including %s in %s', DF_GITCONFIG, HOME_GITCONFIG)
    lines = ['[include]',
             '\tpath = %s' % DF_GITCONFIG]
    fsi.append_to_file(HOME_GITCONFIG, lines)


def setup_tmux(fsi: FSInterface):
    """Setup .tmux.conf, the config file for Tmux"""
    if os.path.isfile(HOME_TMUX_CONF):
        logging.warning('%s exists. Not linking %s.', HOME_TMUX_CONF, TMUX_CONF)
        return
    fsi.create_link(DF_TMUX_CONF, HOME_TMUX_CONF)


def setup_vimrc(fsi: FSInterface):
    """Setup .vimrc, the config file for vi/vim"""
    if os.path.isfile(HOME_VIMRC):
        logging.warning('%s exists. Appending "source %s".', HOME_VIMRC, DF_VIMRC)
        fsi.append_to_file(HOME_VIMRC, ['source %s' % DF_VIMRC])
    else:
        fsi.create_link(DF_VIMRC, HOME_VIMRC)

def setup_initvim(fsi: FSInterface):
    """Setup init.vim, the config file for Neovim"""
    fsi.ensure_dir_exists(os.path.dirname(HOME_INITVIM))
    if os.path.isfile(HOME_INITVIM):
        logging.warning('%s exists. Appending "source %s".', HOME_INITVIM,
                DF_INITVIM)
        fsi.append_to_file(HOME_INITVIM, ['source %s' % DF_INITVIM])
    else:
        fsi.create_link(DF_INITVIM, HOME_INITVIM)


def main(argv: List[str]):
    logging.basicConfig(level=logging.INFO)
    args = parse_args(argv)
    fsi = FSInterface(args.pretend)
    setup_bashrc(fsi)
    setup_gitconfig(fsi)
    setup_tmux(fsi)
    setup_vimrc(fsi)
    setup_initvim(fsi)


if __name__ == '__main__':
    main(sys.argv[1:])
