#-*- perl -*-
#
#  Copyright (C) 2001 Ken'ichi Fukamachi
#   All rights reserved. This program is free software; you can
#   redistribute it and/or modify it under the same terms as Perl itself. 
#
# $FML: Utils.pm,v 1.2 2001/03/30 09:18:44 fukachan Exp $
#

package FML::Filter::Utils;
use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK $AUTOLOAD);
use Carp;

=head1 NAME

FML::Filter::Utils - what is this

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 C<new()>

usual constructor.

=cut


sub new
{
    my ($self) = @_;
    my ($type) = ref($self) || $self;
    my $me     = {};
    return bless $me, $type;
}


=head2 C<clean_up_buffer($args)>

remove some special syntax pattern for further check.
For example, the pattern is a mail address.
We remove it and check the remained buffer whether it is safe or not.

=cut

sub clean_up_buffer
{
    my ($self, $xbuf) = @_;

    # 1. cut off Email addresses (exceptional).
    $xbuf =~ s/\S+@[-\.0-9A-Za-z]+/account\@domain/g;

    # 2. remove invalid syntax seen in help file with the bug? ;D
    $xbuf =~ s/^_CTK_//g;
    $xbuf =~ s/\n_CTK_//g;

    $xbuf;
}


# XXX fml 4.0: EUCCompare($buf, $pat) 
# XXX          where $pat should be $& (matched pattern)
sub euc_compare
{
    my ($self, $a, $pat) = @_;

    # (Refeence: jcode 2.12)
    # $re_euc_c    = '[\241-\376][\241-\376]';
    # $re_euc_kana = '\216[\241-\337]';
    # $re_euc_0212 = '\217[\241-\376][\241-\376]';
    my ($re_euc_c, $re_euc_kana, $re_euc_0212);
    $re_euc_c    = '[\241-\376][\241-\376]';
    $re_euc_kana = '\216[\241-\337]';
    $re_euc_0212 = '\217[\241-\376][\241-\376]';

    # always true if given buffer is not EUC.
    if ($a !~ /($re_euc_c|$re_euc_kana|$re_euc_0212)/) {
	&Log("EUCCompare: do nothing for non EUC strings");# if $debug;
	return 1;
    }

    # extract EUC code (e.g. .*EUC_PATTERN.*)
    # but how to do for "EUC ASCII EUC" case ???
    my ($pa, $loc, $i);
    do {
	if ($a =~ /(($re_euc_c|$re_euc_kana|$re_euc_0212)+)/) {
	    $pa  = $1;
	    $loc = index($pa, $pat);
	}

	print "buf = <$a> pa=<$pa> pat=<$pat> loc=$loc\n";

	return 1 if ($loc % 2) == 0;

	$a = substr($a, index($a, $pa) + length($pa) );
    } while ($i++ < 16);

    0;
}


=head1 AUTHOR

Ken'ichi Fukamachi

=head1 COPYRIGHT

Copyright (C) 2001 Ken'ichi Fukamachi

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself. 

=head1 HISTORY

FML::Filter::Utils appeared in fml5 mailing list driver package.
See C<http://www.fml.org/> for more details.

=cut


1;
