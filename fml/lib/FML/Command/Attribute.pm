#-*- perl -*-
#
#  Copyright (C) 2001 Ken'ichi Fukamachi
#   All rights reserved. This program is free software; you can
#   redistribute it and/or modify it under the same terms as Perl itself. 
#
# $FML: Command::Attribute.pm,v 1.1 2001/08/26 05:45:50 fukachan Exp $
#

package FML::Command::Attribute;
use strict;
use vars qw($FML_USER_COMMAND $FML_ADMIN_COMMAND);

$FML_USER_COMMAND = {
    '__default__' => {
	'require_lock' => 1,	 
    },

    'newml' => { 
	'require_lock' => 0,
    },
};


sub get_attribute
{
    my ($self, $mode, $comname, $attribute) = @_;

    # aligned to lowercase
    $mode      =~ tr/A-Z/a-z/;
    $comname   =~ tr/A-Z/a-z/;
    $attribute =~ tr/A-Z/a-z/;

    if ($mode eq 'user') {
	if (defined $FML_USER_COMMAND->{ $comname }->{ $attribute }) {
	    return $FML_USER_COMMAND->{ $comname }->{ $attribute };
	}
	elsif (defined $FML_USER_COMMAND->{ '__default__' }->{ $attribute }) {
	    return $FML_USER_COMMAND->{ '__default__' }->{ $attribute };
	}
	else {
	    return undef;
	}
    }
    elsif ($mode eq 'admin') {
	if (defined $FML_ADMIN_COMMAND->{ $comname }->{ $attribute }) {
	    return $FML_ADMIN_COMMAND->{ $comname }->{ $attribute };
	}
	elsif (defined $FML_ADMIN_COMMAND->{ '__default__' }->{ $attribute }) {
	    return $FML_ADMIN_COMMAND->{ '__default__' }->{ $attribute };
	}
	else {
	    return undef;
	}
    }
    else {
	return undef;
    }
}


=head1 NAME

FML::Command::Attribute - attribute for each command

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 AUTHOR

Ken'ichi Fukamachi

=head1 COPYRIGHT

Copyright (C) 2001 Ken'ichi Fukamachi

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself. 

=head1 HISTORY

FML::Command::Attribute appeared in fml5 mailing list driver package.
See C<http://www.fml.org/> for more details.

=cut


1;
