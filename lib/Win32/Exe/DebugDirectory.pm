# $File: //member/autrijus/.vimrc $ $Author: autrijus $
# $Revision: #14 $ $Change: 4137 $ $DateTime: 2003/02/08 11:41:59 $

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
