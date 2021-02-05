#!/usr/bin/env python3

import argparse
import logging
import os
import sys


BASHRC = '.bashrc'
GITCONFIG = '.gitconfig'
TMUX_CONF = '.tmux.conf'
VIMRC = '.vimrc'

HOME = os.environ['HOME']
HOME_BASHRC = os.path.join(HOME, BASHRC)
HOME_GITCONFIG = os.path.join(HOME, GITCONFIG)
HOME_TMUX_CONF = os.path.join(HOME, TMUX_CONF)
HOME_VIMRC = os.path.join(HOME, VIMRC)

DF = os.path.join(HOME, '.dotfiles')
DF_BASHRC = os.path.join(DF, BASHRC)
DF_CROS_SDK_BASHRC = os.path.join(DF, '.cros_sdk_bashrc')
DF_GITCONFIG = os.path.join(DF, GITCONFIG)
DF_TMUX_CONF = os.path.join(DF, TMUX_CONF)
DF_VIMRC = os.path.join(DF, VIMRC)


def parse_args(argv):
    parser = argparse.ArgumentParser()
    parser.add_argument("--cros_sdk",
                        help="Apply CrOS SDK-specific changes",
                        action="store_true")
    parser.add_argument("--pretend",
                        help="Don't actually change anything",
                        action="store_true")
    return parser.parse_args(argv)


class FSInterface(object):
    """Class to interact with the filesystem."""
    def __init__(self, pretend=False):
        self.pretend = pretend

    def append_to_file(self, filename, lines):
        assert type(lines) is list
        if self.pretend:
            logging.info('PRETEND: Append these lines to %s:', filename)
            lines = [line.replace('\t', ' '*4) for line in lines]
            longest = max([len(line) for line in lines])
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

    def create_link(self, target, link_name):
        assert os.path.isfile(target)
        if self.pretend:
            logging.info('PRETEND: Create link to %s at %s', target, link_name)
            return
        logging.info('Creating link to %s at %s', target, link_name)
        os.link(target, link_name)


def setup_bashrc(fsi, cros_sdk=False):
    logging.info('Sourcing %s in %s', DF_BASHRC, HOME_BASHRC)
    lines = ['',
             '# Import my standard .bashrc',
             'export DF="%s"' % DF,
             'source %s' % DF_BASHRC]
    if cros_sdk:
        logging.info('Also sourcing %s in %s', DF_CROS_SDK_BASHRC, HOME_BASHRC)
        lines.extend(['',
                      '# Import my cros_sdk .bashrc',
                      'source %s', DF_CROS_SDK_BASHRC])
    fsi.append_to_file(HOME_BASHRC, lines)


def setup_gitconfig(fsi):
    logging.info('Including %s in %s', DF_GITCONFIG, HOME_GITCONFIG)
    lines = ['[include]',
             '\tpath = %s' % DF_GITCONFIG]
    fsi.append_to_file(HOME_GITCONFIG, lines)


def setup_tmux(fsi):
    if os.path.isfile(HOME_TMUX_CONF):
        logging.warning('%s exists. Not linking %s.', HOME_TMUX_CONF, TMUX_CONF)
        return
    fsi.create_link(DF_TMUX_CONF, HOME_TMUX_CONF)


def setup_vimrc(fsi):
    if os.path.isfile(HOME_VIMRC):
        logging.warning('%s exists. Appending "source %s".', HOME_VIMRC, DF_VIMRC)
        fsi.append_to_file(HOME_VIMRC, ['source %s' % DF_VIMRC])
    else:
        fsi.create_link(DF_VIMRC, HOME_VIMRC)


def main(argv):
    logging.basicConfig(level=logging.INFO)
    args = parse_args(argv)
    fsi = FSInterface(args.pretend)
    setup_bashrc(fsi, args.cros_sdk)
    setup_gitconfig(fsi)
    setup_tmux(fsi)
    setup_vimrc(fsi)


if __name__ == '__main__':
    main(sys.argv[1:])
