# $File: /local/member/autrijus/Win32-Exe//lib/Win32/Exe/DebugTable.pm $ $Author: autrijus $
# $Revision: #8 $ $Change: 3896 $ $Date: 2004-02-17T01:28:40.619691Z $

package Win32::Exe::DebugTable;

use strict;
use base 'Win32::Exe::Base';
use constant FORMAT => (
    'DebugDirectory'	=> [ 'a28', '*', 1 ],
);

1;
