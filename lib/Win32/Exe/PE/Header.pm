# $File: //member/autrijus/.vimrc $ $Author: autrijus $
# $Revision: #14 $ $Change: 4137 $ $DateTime: 2003/02/08 11:41:59 $

package Win32::Exe::PE::Header;

use strict;
use base 'Win32::Exe::PE';
use constant SUBFORMAT => (
    Magic2	    => 'v',
    LMajor	    => 'C',
    LMinor	    => 'C',
    CodeSize	    => 'V',
    IDataSize	    => 'V',
    UDataSize	    => 'V',
    EntryPointRVA   => 'V',
    BaseOfCode	    => 'V',
    Data	    => 'a*',
);
use constant MEMBER_CLASS => 'Data';
use constant DISPATCH_FIELD => 'Magic2';
use constant DISPATCH_TABLE => (
    0x20b   => 'PE::Header::PE32Plus',
    '*'     => 'PE::Header::PE32',
);

1;
