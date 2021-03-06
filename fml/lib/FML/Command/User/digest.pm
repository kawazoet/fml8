#-*- perl -*-
#
#  Copyright (C) 2002,2003,2004,2005,2006 MURASHITA Takuya
#   All rights reserved. This program is free software; you can
#   redistribute it and/or modify it under the same terms as Perl itself.
#
# $FML: digest.pm,v 1.19 2006/03/05 08:08:37 fukachan Exp $
#

package FML::Command::User::digest;
use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK $AUTOLOAD);
use Carp;


=head1 NAME

FML::Command::User::digest - change delivery mode between digest and real time.

=head1 SYNOPSIS

See C<FML::Command> for more details.

=head1 DESCRIPTION

change delivery mode among real time and digest.

=head1 METHODS

=head2 new()

constructor.

=head2 need_lock()

need lock or not.

=head2 lock_channel()

return lock channel name.

=head2 verify_syntax($curproc, $command_context)

provide command specific syntax checker.

=head2 process($curproc, $command_context)

main command specific routine.

=cut


# Descriptions: constructor.
#    Arguments: OBJ($self)
# Side Effects: none
# Return Value: OBJ
sub new
{
    my ($self) = @_;
    my ($type) = ref($self) || $self;
    my $me     = {};
    return bless $me, $type;
}


# Descriptions: need lock or not.
#    Arguments: none
# Side Effects: none
# Return Value: NUM( 1 or 0)
sub need_lock { 1;}


# Descriptions: lock channel.
#    Arguments: none
# Side Effects: none
# Return Value: STR
sub lock_channel { return 'command_serialize';}


# Descriptions: digest off/on adapter.
#    Arguments: OBJ($self) OBJ($curproc) OBJ($command_context)
# Side Effects: update database for confirmation.
#               prepare reply message.
# Return Value: none
sub process
{
    my ($self, $curproc, $command_context) = @_;
    my $config = $curproc->config();
    my $cred   = $curproc->credential();

    # XXX We should always add/rewrite only $primary_*_map maps via
    # XXX command mail, CUI and GUI.
    # XXX Rewriting of maps not $primary_*_map is
    # XXX 1) may be not writable.
    # XXX 2) ambigous and dangerous
    # XXX    since the map is under controlled by other module.
    # XXX    for example, $member_maps contains different classes.
    my $member_map    = $config->{ primary_member_map };
    my $recipient_map = $config->{ primary_recipient_map };
    my $cache_dir     = $config->{ db_dir };
    my $keyword       = $config->{ confirm_command_prefix };
    my $command       = $command_context->get_clean_command();
    my $address       = $cred->sender();
    my $mode          = '';

    # fundamental check
    croak("\$member_map is not specified")    unless $member_map;
    croak("\$recipient_map is not specified") unless $recipient_map;

    # 1. check if the sender is a member or not.
    #    if not member, "on" request is wrong.
    # 2. not check if the sender is a recipient or not in this stage.
    unless ($cred->is_member($address)) {
	$curproc->reply_message_nl('error.not_member');
	$curproc->logerror("digest request from not member");
	croak("digest request from not member");
	return;
    }

    if ($command =~ /digest\s+(\w+)/o) {
    	$mode = $1;
    }

    if ($mode) {
	$curproc->log("digest $mode");

	# emulate options ARRAY_REF.
	$command_context->set_data($address);
	$command_context->set_options( [ $address, $mode ] );

	# XXX-TODO: direct call of Admin::digest is correct?
	# XXX-TODO: confirmation ?
	use FML::Command::Admin::digest;
	my $obj = new FML::Command::Admin::digest;
	if ($mode eq "on" || $mode eq 'off') {
	    $obj->process($curproc, $command_context);
	}
	else {
	    my $r = "digest: unknown mode: $mode";
	    $curproc->logerror($r);
	    croak($r);
	}
    }
    else {
	$curproc->logerror("digest: mode unspecified");
	croak("digest: mode unspecified");
    }
}


=head1 CODING STYLE

See C<http://www.fml.org/software/FNF/> on fml coding style guide.

=head1 AUTHOR

MURASHITA Takuya

=head1 COPYRIGHT

Copyright (C) 2002,2003,2004,2005,2006 MURASHITA Takuya

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

=head1 HISTORY

FML::Command::User::digest first appeared in fml8 mailing list driver package.
See C<http://www.fml.org/> for more details.

=cut


1;
