#!/usr/local/bin/perl
# $File: //member/autrijus/Win32-Exe/script/exe_update.pl $ $Author: autrijus $
# $Revision: #1 $ $Change: 9927 $ $DateTime: 2004/02/06 19:31:24 $

use strict;
use File::Basename;
use Win32::Exe;
use Getopt::Long;

my $Options = {};
Getopt::Long::GetOptions( $Options,
    'g|gui',            # No console window
    'c|console',        # Use console window
    'i|icon:s',         # Icon file
    'N|info:s@',        # Executable header info
);

my $exe = shift or die "Usage: " . basename($0) .
    " [--gui | --console] [--icon file.ico] [--info key=value] file.exe\n";

print "Updating $exe... ";

Win32::Exe->new($exe)->update(
    gui	    => $Options->{g},
    console => $Options->{c},
    icon    => $Options->{i},
    info    => $Options->{N},
) or die "failed!\n";

print "success!\n";
