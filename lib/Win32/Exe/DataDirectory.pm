# $File: /local/member/autrijus/Win32-Exe//lib/Win32/Exe/DataDirectory.pm $ $Author: autrijus $
# $Revision: #8 $ $Change: 3896 $ $Date: 2004-02-17T01:28:40.619691Z $

package Win32::Exe::DataDirectory;

use strict;
use base 'Win32::Exe::Base';
use constant FORMAT => (
    VirtualAddress  => 'V',
    Size	    => 'V',
);

1;
