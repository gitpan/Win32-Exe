# $File: /local/member/autrijus/Win32-Exe//lib/Win32/Exe/PE.pm $ $Author: autrijus $
# $Revision: #8 $ $Change: 3896 $ $Date: 2004-02-17T01:28:40.619691Z $

package Win32::Exe::PE;

use strict;
use base 'Win32::Exe';
use constant SUBFORMAT => (
    Machine	    => 'v',
    NumSections	    => 'v',
    TimeStamp	    => 'V',
    SymbolTable	    => 'V',
    _		    => 'a4',
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
