# $File: /local/member/autrijus/Win32-Exe//lib/Win32/Exe/DebugDirectory.pm $ $Author: autrijus $
# $Revision: #7 $ $Change: 3896 $ $Date: 2004-02-17T01:28:40.619691Z $

package Win32::Exe::DebugDirectory;

use strict;
use base 'Win32::Exe::Base';
use constant FORMAT => (
    Flags	    => 'V',
    TimeStamp	    => 'V',
    VersionMajor    => 'v',
    VersionMinor    => 'v',
    Type	    => 'V',
    Size	    => 'V',
    VirtualAddress  => 'V',
    Offset	    => 'V',
);

1;
