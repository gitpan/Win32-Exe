# $File: //member/autrijus/.vimrc $ $Author: autrijus $
# $Revision: #14 $ $Change: 4137 $ $DateTime: 2003/02/08 11:41:59 $

package Win32::Exe::PE;

use strict;
use base 'Win32::Exe';
use constant SUBFORMAT => (
    Machine	    => 'v',
    NumSections	    => 'v',
    TimeStamp	    => 'V',
    SymbolTable	    => 'V',
    PEPad1	    => 'a4',
    OptHeaderSize   => 'v',
    Characteristics => 'v',
    Data	    => 'a*',
);
use constant DISPATCH_FIELD => 'OptHeaderSize';
use constant DISPATCH_TABLE => (
    '0' => '',
    '*' => 'PE::Header',
);

1;
