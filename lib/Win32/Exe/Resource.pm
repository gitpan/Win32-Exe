# $File: //member/autrijus/.vimrc $ $Author: autrijus $
# $Revision: #14 $ $Change: 4137 $ $DateTime: 2003/02/08 11:41:59 $

package Win32::Exe::Resource;

use strict;
use base 'Win32::Exe::Base';

sub object {
    my ($self) = @_;
    return $self;
}

sub path {
    my ($self) = @_;
    return $self->parent->path;
}

sub CodePage {
    return 1252;
}

sub PathName {
    my ($self) = @_;
    return $self->{pathname} || $self->first_parent('ResourceEntry')->PathName;
}

sub SetPathName {
    my ($self, $value) = @_;
    $self->{pathname} = $value;
}

sub Data {
    my ($self) = @_;
    return $self->dump;
}

1;
