#!/usr/bin/env perl
# $File: /local/member/autrijus/Win32-Exe//Makefile.PL $ $Author: autrijus $
# $Revision: #9 $ $Change: 3896 $ $Date: 2004-02-17T01:28:40.619691Z $

use inc::Module::Install;

name		('Win32-Exe');
author		('Autrijus Tang <autrijus@autrijus.org>');
abstract	('Manipulate Win32 executable files');
license		('perl');
install_script	('script/exe_update.pl');
version_from	('lib/Win32/Exe.pm');

requires	(
    perl	    => '5.6.0',
    'Parse::Binary' => 0.05,
);
build_requires	('Test::More');

auto_include();
WriteAll( sign => 1 );
