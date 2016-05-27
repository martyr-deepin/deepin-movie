#! /usr/bin/env python
# -*- coding: utf-8 -*-

import os
import subprocess

from ConfigParser import RawConfigParser as ConfigParser
from collections import OrderedDict
from contextlib import contextmanager
import sys
import traceback

def touch_file(filepath):
    '''
    If filepath's parent directory is not exist, this function will create parent directory first.
    @param filepath: Target path to touch.
    '''
    dir = os.path.dirname(filepath)
    if not os.path.exists(dir):
        os.makedirs(dir)

    # Touch file.
    if os.path.exists(filepath):
        os.utime(filepath, None)
    else:
        open(filepath, 'w').close()

def get_command_output_first_line(commands, in_shell=False):
    '''
    Run command and return first line of output.

    @param commands: Input commands.
    @return: Return first line of command output.
    '''
    process = subprocess.Popen(commands, stdout=subprocess.PIPE, shell=in_shell)
    process.wait()
    return process.stdout.readline()

class Config(object):
    '''
    Config module to read *.ini file.
    '''
    def __init__(self,
                 config_file,
                 default_config=None):
        '''
        Init config module.

        @param config_file: Config filepath.
        @param default_config: Default config value use when config file is empty.
        '''
        self.config_parser = ConfigParser()
        self.remove_option = self.config_parser.remove_option
        self.has_option = self.config_parser.has_option
        self.add_section = self.config_parser.add_section
        self.getboolean = self.config_parser.getboolean
        self.getint = self.config_parser.getint
        self.getfloat = self.config_parser.getfloat
        self.options = self.config_parser.options
        self.items = self.config_parser.items
        self.config_file = config_file
        self.default_config = default_config

        # Load default configure.
        self.load_default()

    def load_default(self):
        '''
        Load config items with default setting.
        '''
        # Convert config when config is list format.
        if isinstance(self.default_config, list):
            self.default_config = self.convert_from_list(self.default_config)

        if self.default_config:
            for section, items in self.default_config.iteritems():
                self.add_section(section)
                for key, value in items.iteritems():
                    self.config_parser.set(section, key, value)

    def load(self):
        '''
        Load config items from the file.
        '''
        self.config_parser.read(self.config_file)

    def has_option(self, section, option):
        return self.config_parser.has_option(section, option)

    def get(self, section, option, default=None, debug=False):
        '''
        Get specified the section for read the option value.

        @param section: Section to index item.
        @param option: Option to index item.
        @param default: Default value if item is not exist.
        @return: Return item value with match in config file.
        '''
        try:
            return self.config_parser.get(section, option)
        except Exception, e:
            if debug:
                print "function get got error: %s" % (e)
                traceback.print_exc(file=sys.stdout)

            return default

    def set(self, section, option, value, debug=False):
        '''
        Set item given value.

        @param section: Section to setting.
        @param option: Option to setting.
        @param value: Item value to save.
        '''
        if not self.config_parser.has_section(section):
            if debug:
                print "Section \"%s\" not exist. create..." % (section)
            self.add_section(section)

        self.config_parser.set(section, option, value)

    def write(self, given_filepath=None):
        '''
        Save configure to file.

        @param given_filepath: If given_filepath is None, save to default filepath, otherwise save to given filepath.
        '''
        if given_filepath:
            f = file(given_filepath, "w")
        else:
            f = file(self.config_file, "w")
        self.config_parser.write(f)
        f.close()

    def get_default(self):
        '''
        Get default config value.

        @return: Return default config value.
        '''
        return self.default_config

    def set_default(self, default_config):
        '''
        Set default config value and load it.

        @param default_config: Default config value.
        '''
        self.default_config = default_config
        self.load_default()

    def convert_from_list(self, config_list):
        '''
        Convert to dict from list format.

        @param config_list: Config value as List format.
        @return: Return config value as Dict format.
        '''
        config_dict = OrderedDict()
        for (section, option_list) in config_list:
            option_dict = OrderedDict()
            for (option, value) in option_list:
                option_dict[option] = value
            config_dict[section] = option_dict

        return config_dict

    @contextmanager
    def save_config(self, debug=False):
        # Load default config if config file is not exists.
        if not os.path.exists(self.config_file):
            touch_file(self.config_file)
            self.load_default()
        try:
            # So setting change operations.
            yield
        except Exception, e:
            if debug:
                print 'function save_config got error: %s' % e
                traceback.print_exc(file=sys.stdout)
        else:
            # Save setting config last.
            self.write()

    def get_config(self, selection, option, default=None):
        try:
            return self.get(selection, option, default)
        except:
            return dict(dict(self.default_config)[selection])[option]
