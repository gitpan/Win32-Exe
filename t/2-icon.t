# $File: //member/autrijus/.vimrc $ $Author: autrijus $
# $Revision: #14 $ $Change: 4137 $ $DateTime: 2003/02/08 11:41:59 $

use strict;
use FindBin;
use lib "$FindBin::Bin/../inc";
use lib "$FindBin::Bin/../lib";
use lib "$FindBin::Bin/../../Parse-Binary/lib";
use Test::More tests => 12;

$SIG{__DIE__} = sub { use Carp; Carp::confess(@_) };
$SIG{__WARN__} = sub { use Carp; Carp::cluck(@_) };

use_ok('Win32::Exe::IconFile');

my $hd_icon = "$FindBin::Bin/hd.ico";
my $par_icon = "$FindBin::Bin/par.ico";
my $exe_file = "$FindBin::Bin/par.exe";

ok(my $par_orig = Win32::Exe::IconFile->read_file($par_icon), 'read_file');

my $ico = Win32::Exe::IconFile->new($par_icon);
isa_ok($ico, 'Win32::Exe::IconFile');
is($ico->dump, $par_orig, 'roundtrip');
is($ico->dump_iconfile, $par_orig, 'roundtrip with dump_iconfile');

my ($icon1, $icon2) = $ico->icons;
is(length($icon1->Data), $icon1->ImageSize, 'Image1 size fits');
is(length($icon2->Data), $icon2->ImageSize, 'Image2 size fits');

my $exe = Win32::Exe::IconFile->new($exe_file);
isa_ok($exe, 'Win32::Exe');
is($exe->dump_iconfile, $par_orig, 'roundtrip with dump_iconfile');
$exe->set_icons(scalar $ico->icons);
is($exe->dump_iconfile, $par_orig, 'roundtrip after set_icons');

ok(my $hd_orig = Win32::Exe::IconFile->read_file($hd_icon), 'read_file');
my $ico_hd = Win32::Exe::IconFile->new($hd_icon);
$exe->set_icons(scalar $ico_hd->icons);
is(length($exe->dump), 49205, 'dump size correct after set_icons');

