package Win32::Exe;
$Win32::Exe::VERSION = '0.12_03';

=head1 NAME

Win32::Exe - Manipulate Win32 executable files

=head1 VERSION

This document describes version 0.12_03 of Win32::Exe, released
April 23, 2010.

=head1 SYNOPSIS

    use Win32::Exe;
    my $exe = Win32::Exe->new('c:/windows/notepad.exe');

    # Get version information
    print $exe->version_info->get('FileDescription'), ": ",
    $exe->version_info->get('LegalCopyright'), "\n";

    # Dump icons in an executable
    foreach my $icon ($exe->icons) {
    printf "Icon: %s x %s (%s colors)\n",
           $icon->Width, $icon->Height, 2 ** $icon->BitCount;
    }

    # Import icons from a .exe or .ico file and writes back the file
    $exe->update( icon => '/c/windows/taskman.exe' );

    # Change it to a console application, then save to another .exe
    $exe->SetSubsystem('console');
    $exe->write('c:/windows/another.exe');
    
    # Add a manifest section
    $exe->update( manifest => $mymanifestxml );
    # or a default
    $exe->update( defaultmanifest => 1 );
    
    # Get manifest object
    $manifest = $exe->get_manifest if $exe->has_manifest 
    

=head1 DESCRIPTION

This module parses and manipulating Win32 PE/COFF executable headers,
including version information, icons, manifest and other resources.
The module Win32::Exe::Manifest can be used for manifest handling.

Also, please see the test files in the source distributions
F<t/> directory for examples of using this module.

=cut

use strict;
use base 'Win32::Exe::Base';
use constant FORMAT => (
    Magic       => 'a2',    # "MZ"
    _           => 'a58',
    PosPE       => 'V',
    _           => 'a{($PosPE > 64) ? $PosPE - 64 : "*"}',
    PESig       => 'a4',
    Data        => 'a*',
);
use constant DELEGATE_SUBS => (
    'IconFile'  => [ 'dump_iconfile', 'write_iconfile' ],
);
use constant DISPATCH_FIELD => 'PESig';
use constant DISPATCH_TABLE => (
    "PE\0\0"    => "PE",
    '*'     => sub { die "Incorrect PE header -- not a valid .exe file" },
);
use constant DEBUG_INDEX         => 6;
use constant DEBUG_ENTRY_SIZE    => 28;

use File::Basename ();
use Win32::Exe::IconFile;
use Win32::Exe::DebugTable;
use Win32::Exe::Manifest;

sub is_application { ( $_[0]->is_assembly ) ? 0 : 1; }

sub is_assembly { $_[0]->Characteristics & 0x2000; }

sub resource_section {
    my ($self) = @_;
    $self->first_member('Resources');
}

sub sections {
    my ($self) = @_;
    my $method = (wantarray ? 'members' : 'first_member');
    return $self->members('Section');
}

sub data_directories {
    my ($self) = @_;
    return $self->members('DataDirectory');
}

sub update_debug_directory {
    my ($self, $boundary, $extra) = @_;

    $self->SetSymbolTable( $self->SymbolTable + $extra )
    if ($boundary <= $self->SymbolTable);

    my @dirs = $self->data_directories;
    return if DEBUG_INDEX > $#dirs;

    my $dir = $dirs[DEBUG_INDEX] or return;
    my $size = $dir->Size;
    my $addr = $dir->VirtualAddress;

    return unless $size or $addr;

    my $count = $size / DEBUG_ENTRY_SIZE or return;

    (($size % DEBUG_ENTRY_SIZE) == 0) or return;

    foreach my $section ($self->sections) {
    my $offset = $section->FileOffset;
    my $f_size = $section->FileSize;
    my $v_addr = $section->VirtualAddress;

    next unless $v_addr <= $addr;
    next unless $addr < ($v_addr + $f_size);
    next unless ($addr + $size) < ($v_addr + $f_size);

    $offset += $addr - $v_addr;
    my $data = $self->substr($offset, $size);

    my $table = Win32::Exe::DebugTable->new(\$data);

    foreach my $dir ($table->members) {
        next unless $boundary <= $dir->Offset;

        $dir->SetOffset($dir->Offset + $extra);
        $dir->SetVirtualAddress($dir->VirtualAddress + $extra)
        if $dir->VirtualAddress > 0;
    }

    $self->substr($offset, $size, $table->dump);
    last;
    }
}

sub default_info {
    my $self = shift;

    my $filename = File::Basename::basename($self->filename);

    return join(';',
    "CompanyName=",
    "FileDescription=",
    "FileVersion=0.0.0.0",
    "InternalName=$filename",
    "LegalCopyright=",
    "LegalTrademarks=",
    "OriginalFilename=$filename",
    "ProductName=",
    "ProductVersion=0.0.0.0",
    );
}

sub update {
    my ($self, %args) = @_;
    
    if ($args{defaultmanifest}) {
            $self->add_default_manifest();
    }
    
    if (my $manifest = $args{manifest}) {
        $self->set_manifest($manifest);
    }

    if (my $icon = $args{icon}) {
    my @icons = Win32::Exe::IconFile->new($icon)->icons;
    $self->set_icons(\@icons) if @icons;
    }

    if (my $info = $args{info}) {
    my @info = ($self->default_info, @$info);

    my @pairs;
    foreach my $pairs (map split(/\s*;\s*(?=[\w\\\/]+\s*=)/, $_), @info) {
        my ($key, $val) = split(/\s*=\s*/, $pairs, 2);
        next if $key =~ /language/i;

        if ($key =~ /^(product|file)version$/i) {
        $key = "\u$1Version";
        $val =~ /^(?:\d+\.)+\d+$/ or die "$key cannot be '$val'";
        $val .= '.0' while $val =~ y/.,// < 3;

        push(@pairs,
            [ $key => $val ],
            [ "/StringFileInfo/#1/$key", $val ]);
        }
        else {
        push(@pairs, [ $key => $val ]);
        }
    }

    $self->set_version_info(\@pairs) if @pairs;
    }

    die "'gui' and 'console' cannot both be true"
    if $args{gui} and $args{console};

    $self->SetSubsystem("windows") if $args{gui};
    $self->SetSubsystem("console") if $args{console};
    $self->write;
}

sub icons {
    my ($self) = @_;
    my $rsrc = $self->resource_section or return;
    my @icons = map $_->members, $rsrc->objects('GroupIcon');
    wantarray ? @icons : \@icons;
}

sub set_icons {
    my ($self, $icons) = @_;

    my $rsrc = $self->resource_section;
    my $name = eval { $rsrc->first_object('GroupIcon')->PathName }
        || '/#RT_GROUP_ICON/#1/#0';

    $rsrc->remove('/#RT_GROUP_ICON');
    $rsrc->remove('/#RT_ICON');

    my $group = $self->require_class('Resource::GroupIcon')->new;
    $group->SetPathName($name);
    $group->set_parent($rsrc);
    $rsrc->insert($group->PathName, $group);

    $group->set_icons($icons);
    $group->refresh;
}

sub version_info {
    my ($self) = @_;
    my $rsrc = $self->resource_section or return;

    # XXX - return a hash in list context?

    return $rsrc->first_object('Version');
}

sub set_version_info {
    my ($self, $pairs) = @_;
    my $rsrc = $self->resource_section or return;
    my $version = $rsrc->first_object('Version');
    $version->set(@$_) for @$pairs;
    $version->refresh;
}

sub manifest {
    my ($self) = @_;
    my $rsrc = $self->resource_section or return;
    if( my $obj = $rsrc->first_object('Manifest') ) {
        return $obj;
    } else {
        return $self->require_class('Resource::Manifest')->new;
    }
}    

sub has_manifest {
    my ($self) = @_;
    my $rsrc = $self->resource_section or return 0;
    if( my $obj = $rsrc->first_object('Manifest') ) {
        return 1;
    } else {
        return 0;
    }
}

sub set_manifest {
    my ($self, $xml) = @_;
    # support code that passes xml and objects
    my $resid = 0;
    if(ref($xml) && $xml->isa('Win32::Exe::Manifest')) {
        $resid = $xml->get_resource_id;
        $xml = $xml->output ;
    }
    $resid ||= 1;
    my $rsrc = $self->resource_section;
    my $name = '/#RT_MANIFEST/#' . $resid . '/#0';
    $rsrc->remove("/#RT_MANIFEST");
    my $manifest = $self->require_class('Resource::Manifest')->new;
    $manifest->SetPathName( $name ); 
    $manifest->set_parent( $rsrc );
    $manifest->update_manifest( $xml );
    $rsrc->insert($manifest->PathName, $manifest);
    $rsrc->refresh;
}

sub get_manifest {
    my ($self) = @_;
    my $mtype = ($self->is_assembly) ? 'assembly' : 'application';
    my $mfestxml = $self->manifest->get_manifest;
    my $mfest = Win32::Exe::Manifest->new($mfestxml, $mtype);
    $mfest->set_resource_id( $self->manifest->get_manifest_id );
    return $mfest;
}

sub add_default_manifest {
    my ($self) = @_;
    my $rsrc = $self->resource_section;
    my $name = '/#RT_MANIFEST/#1/#0';
    $rsrc->remove("/#RT_MANIFEST");
    my $manifest = $self->require_class('Resource::Manifest')->new;
    my $xml = $manifest->default_manifest;
    $manifest->SetPathName( $name ); 
    $manifest->set_parent( $rsrc );
    $manifest->update_manifest( $xml );
    $rsrc->insert($manifest->PathName, $manifest);
    $rsrc->refresh;
}

sub merge_manifest {
    my ($self, $mnf) = @_;
    return if !(ref($mnf) && $mnf->isa('Win32::Exe::Manifest'));
    my $main = $self->get_manifest;
    $main->merge_manifest($mnf);
    $self->set_manifest($main);
}

1;

__END__

=head1 AUTHORS

Audrey Tang E<lt>cpan@audreyt.orgE<gt>

Mark Dootson E<lt>mdootson@cpan.orgE<gt>

Steffen Mueller E<lt>smueller@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2004-2007, 2010 by Audrey Tang E<lt>cpan@audreyt.orgE<gt>.

This program is free software; you can redistribute it and/or 
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
