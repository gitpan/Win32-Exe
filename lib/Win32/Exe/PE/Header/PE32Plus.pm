#--------------------------------------------------------------------
# 64 bit PE+ header as per 'Microsoft PE and COFF Specification' from
# http://www.microsoft.com/whdc/system/platform/firmware/PECOFF.mspx
#--------------------------------------------------------------------

package Win32::Exe::PE::Header::PE32Plus;
use strict;
use base 'Win32::Exe::PE::Header';

use constant SUBFORMAT => (
    ImageBase       => 'Q',
    SectionAlign    => 'V',
    FileAlign       => 'V',
    OSMajor     => 'v',
    OSMinor     => 'v',
    UserMajor       => 'v',
    UserMinor       => 'v',
    SubsysMajor     => 'v',
    SubsysMinor     => 'v',
    _           => 'a4',
    ImageSize       => 'V',
    HeaderSize      => 'V',
    FileChecksum    => 'V',
    SubsystemTypeId => 'v',
    DLLFlags        => 'v',
    StackReserve    => 'Q',
    StackCommit     => 'Q',
    HeapReserve     => 'Q',
    HeapCommit      => 'Q',
    LoaderFlags     => 'V',
    NumDataDirs     => 'V',
    'DataDirectory' => [
    'a8', '{$NumDataDirs}', 1
    ],
    'Section'       => [
    'a40', '{$NumSections}', 1
    ],
    Data        => 'a*',
);
use constant SUBSYSTEM_TYPES => [qw(
    _       native  windows     console _
    _       _       posix       _       windowsce
)];
use constant ST_TO_ID => {
    map { (SUBSYSTEM_TYPES->[$_] => $_) } (0 .. $#{+SUBSYSTEM_TYPES})
};
use constant ID_TO_ST => { reverse %{+ST_TO_ID} };

# Quads are endian?
use Config;
die 'Cannot parse 64 bit PE+ headers on big endian systems' if $Config{byteorder} !~ /^1234/;

eval { my $qp = pack('Q', 0); };
die 'Cannot parse 64 bit PE+ headers - no Quad support in this Perl' if $@ =~ /Invalid type/i; 

sub st_to_id {
    my ($self, $name) = @_;
    return $name unless $name =~ /\D/;
    return(+ST_TO_ID->{lc($name)} || die "No such type: $name");
}

sub id_to_st {
    my ($self, $id) = @_;
    return(+ID_TO_ST->{$id} || $id);
}

sub Subsystem {
    my ($self) = @_;
    return $self->id_to_st($self->SubsystemTypeId);
}

sub SetSubsystem {
    my ($self, $type) = @_;
    $self->SetSubsystemTypeId($self->st_to_id($type));
}

sub ExpectedOptHeaderSize { 240 };
    


1;
