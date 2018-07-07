#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

AUTHOR = 'Ben Gnoinski'
AUTHOR_TITLE = 'DevOps Engineer'

SITENAME = 'Ben Gnoinski'
SITEURL = ''

PATH = 'content'
STATIC_PATHS = ['images']
TIMEZONE = 'America/Vancouver'

DEFAULT_LANG = 'en'

# Feed generation is usually not desired when developing
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
AUTHOR_FEED_ATOM = None
AUTHOR_FEED_RSS = None

# Blogroll
LINKS = (('Pelican', 'http://getpelican.com/'),
         ('Python.org', 'http://python.org/'),
         ('Jinja2', 'http://jinja.pocoo.org/'),
         ('You can modify those links in your config file', '#'),)

# Social widget
SOCIAL = (('Github', 'https://github.com/BGnoinski'),
          ('Linkedin', 'https://www.linkedin.com/in/ben-gnoinski-34b10890/'),)

DEFAULT_PAGINATION = False
DISPLAY_CATEGORIES_ON_MENU = False
THEME = 'pelican-twitchy'

# Uncomment following line if you want document-relative URLs when developing
#RELATIVE_URLS = True

# Theme Settings
DISPLAY_PAGES_ON_MENU = False
CUSTOM_CSS = "theme/css/custom.css"
#GOOGLE_ANALYTICS = "UA-117528368-1"
