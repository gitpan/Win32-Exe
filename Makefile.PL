#!/usr/bin/env perl
# $File: //member/autrijus/Win32-Exe/Makefile.PL $ $Author: autrijus $
# $Revision: #2 $ $Change: 9927 $ $DateTime: 2004/02/06 19:31:24 $

use inc::Module::Install;

name		('Win32-Exe');
author		('Autrijus Tang <autrijus@autrijus.org>');
abstract	('Manipulate Win32 executable files');
license		('perl');
install_script	('script/exe_update.pl');
version_from	('lib/Win32/Exe.pm');

requires	(
    perl	    => '5.6.0',
    'Parse::Binary' => 0.04,
);
build_requires	('Test::More');

auto_include();
WriteAll( sign => 1 );
