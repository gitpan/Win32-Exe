#!/usr/bin/env perl
# Copyright 2004, 2007, 2010 by Audrey Tang <cpan@audreyt.org>

use inc::Module::Install;

name        ('Win32-Exe');
author      ('Audrey Tang <cpan@audreyt.org>');
abstract    ('Manipulate Win32 executable files');
license     ('perl');
install_script  ('script/exe_update.pl');
version_from    ('lib/Win32/Exe.pm');

requires    (
    perl        => '5.6.0',
    'Parse::Binary' => 0.11,
    'XML::Simple'   => 2.18,
    'XML::Parser'   => 2.36,
);
build_requires  ('Test::More', 'File::Copy' );

auto_include();
WriteAll( sign => 1 );
