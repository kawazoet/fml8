#-*- perl -*-
#
#  Copyright (C) 2002,2003 Ken'ichi Fukamachi
#   All rights reserved. This program is free software; you can
#   redistribute it and/or modify it under the same terms as Perl itself.
#
# $FML: Analyze.pm,v 1.20 2003/05/28 13:14:05 fukachan Exp $
#

package FML::Error::Analyze;
use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK $AUTOLOAD);
use Carp;
use FML::Log qw(Log LogWarn LogError);


my $debug = 1;


=head1 NAME

FML::Error::Analyze - provide model specific analyzer routines.

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 C<new()>

=cut


# Descriptions: standard constructor
#    Arguments: OBJ($self) HASH_REF($curproc)
# Side Effects: none
# Return Value: OBJ
sub new
{
    my ($self, $curproc) = @_;
    my ($type) = ref($self) || $self;
    my $me     = { _curproc => $curproc };
    return bless $me, $type;
}


=head1 METHODS

=head2 summary()

return summary of points of addresses as HASH_REF.

    $summary = {
	address1 => point,
	address2 => point,	
    };

=head2 removal_address()

return addresses to be removed.

=cut


# Descriptions: return summary 
#    Arguments: OBJ($self)
# Side Effects: none
# Return Value: HASH_REF
sub summary
{
    my ($self) = @_;
    my $analyzer = $self->{ _analyzer };

    if (defined $analyzer) {
	return $analyzer->summary();
    }
    else {
	return {};
    }
}


# Descriptions: return removal address candidates
#    Arguments: OBJ($self)
# Side Effects: none
# Return Value: ARRAY_REF
sub removal_address
{
    my ($self) = @_;
    my $analyzer = $self->{ _analyzer };
	
    if (defined $analyzer) {
	return $analyzer->removal_address();
    }
    else {
	return [];
    }
}


# Descriptions: print address and the status summary.
#    Arguments: OBJ($self) STR($addr)
# Side Effects: none
# Return Value: none
sub print
{
    my ($self, $addr) = @_;
    my $analyzer = $self->{ _analyzer };
	
    if (defined $analyzer) {
	return $analyzer->print($addr);
    }
}


=head2 C<AUTOLOAD()>

the command dispatcher.
It hooks up the C<$command> request and loads the module in
C<FML::Command::$MODE::$command>.

=cut


# Descriptions: run FML::Error::Analyze::XXX()
#    Arguments: OBJ($self) OBJ($curproc) HASH_REF($anal_args)
# Side Effects: load appropriate module
# Return Value: none
sub AUTOLOAD
{
    my ($self, $curproc, $anal_args) = @_;

    # we need to ignore DESTROY()
    return if $AUTOLOAD =~ /DESTROY/;

    my $fp = $AUTOLOAD;
    $fp =~ s/.*:://;
    my $pkg = "FML::Error::Analyze::${fp}";

    Log("load $pkg") if 1; # debug

    my $analyzer = undef;
    eval qq{ use $pkg; \$analyzer = new $pkg;};
    unless ($@) {
	# run the actual process
	if ($analyzer->can('process')) {
	    $analyzer->process($curproc, $anal_args);
	    $self->{ _analyzer } = $analyzer;
	}
	else {
	    LogError("${pkg} has no process method");
	}
    }
    else {
	LogError($@) if $@;
	LogError("$pkg module is not found");
	croak("$pkg module is not found"); # upcall to FML::Error
    }
}


=head1 $data STRUCTURE

C<$data> is passed to the error analyer function 
C<FML::Error::Analyze::${fp}> (as $anal_args in AUTOLOAD()).

	 $data = {
	    address => [
	           error_info_1,
	           error_info_2, ...
	    ]
	 };

where the error_info_* has error reasons (STR).  $fp parses it, count
up.  FML::Error or FML::Error::Analyze can retrieve the result via
summary() method.

=head1 CODING STYLE

See C<http://www.fml.org/software/FNF/> on fml coding style guide.

=head1 AUTHOR

Ken'ichi Fukamachi

=head1 COPYRIGHT

Copyright (C) 2002,2003 Ken'ichi Fukamachi

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

=head1 HISTORY

FML::Error::Analyze first appeared in fml8 mailing list driver package.
See C<http://www.fml.org/> for more details.

=cut


1;
