# $File: //member/autrijus/.vimrc $ $Author: autrijus $
# $Revision: #14 $ $Change: 4137 $ $DateTime: 2003/02/08 11:41:59 $

package Win32::Exe::DataDirectory;

use strict;
use base 'Win32::Exe::Base';
use constant FORMAT => (
    VirtualAddress  => 'V',
    Size	    => 'V',
);

1;
