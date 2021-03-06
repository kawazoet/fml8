#-*- perl -*-
#
#  Copyright (C) 2001,2002,2003,2004,2005,2006,2008 Ken'ichi Fukamachi
#   All rights reserved. This program is free software; you can
#   redistribute it and/or modify it under the same terms as Perl itself.
#
# $FML: subscribe.pm,v 1.38 2006/03/05 08:08:37 fukachan Exp $
#

package FML::Command::User::subscribe;
use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK $AUTOLOAD);
use Carp;


=head1 NAME

FML::Command::User::subscribe - subscribe request handling.

=head1 SYNOPSIS

See C<FML::Command> for more details.

=head1 DESCRIPTION

Firstly try confirmation before real subscribe process starts.
After confirmation succeeds, subcribe process proceeds.

=head1 METHODS

=head2 process($curproc, $command_context)

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


# Descriptions: subscribe adapter.
#               we confirm it before real subscribe process.
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
    # XXX    for example, $member_maps contains differenct classes.
    my $member_map    = $config->{ primary_member_map };
    my $recipient_map = $config->{ primary_recipient_map };
    my $cache_dir     = $config->{ db_dir };
    my $keyword       = $config->{ confirm_command_prefix };
    my $command       = $command_context->get_clean_command();
    my $options       = $command_context->get_options();
    my $cui_options   = $curproc->command_line_cui_specific_options() || {};
    my $address       = $cui_options->{ 'send-to' } || $cred->sender();

    # fundamental check
    croak("\$member_map unspecified")    unless $member_map;
    croak("\$recipient_map unspecified") unless $recipient_map;
    croak("\$address unspecified")       unless $address;

    # XXX extension: fml --allow-send-message or fml --allow-reply-message
    unless ($cred->sender()) {
	if ($curproc->is_allow_reply_message()) {
	    $cred->set_sender($address);
	}
    }

    # exact match as could as possible.
    my $compare_level = $cred->get_compare_level();
    $cred->set_compare_level( 100 );

    # if already member, subscriber request is wrong.
    if ($cred->is_member($address)) {
	$cred->set_compare_level( $compare_level );
	$curproc->reply_message_nl('error.already_member',
				   'already member',
				   {
				       _arg_address => $address
				   });
	croak("already member");
    }
    # if not, try confirmation before subscribe
    else {
	$cred->set_compare_level( $compare_level );

	$curproc->log("new subscriber, try confirmation");
	use FML::Confirm;
	my $confirm = new FML::Confirm $curproc, {
	    keyword   => $keyword,
	    cache_dir => $cache_dir,
	    class     => 'subscribe',
	    address   => $address,
	    buffer    => $command,
	};

	use FML::Command::Message;
	my $_msg    = new FML::Command::Message;
	my $sc_args = { command => "subscribe" };
	$_msg->send_confirmation($curproc, $command_context, $confirm, $sc_args);
    }
}


# Descriptions: show cgi menu for subscribe command for an anonymous user.
#    Arguments: OBJ($self) OBJ($curproc) OBJ($command_context)
# Side Effects: update $member_map $recipient_map
# Return Value: none
sub cgi_menu
{
    my ($self, $curproc, $command_context) = @_;
    my $r = '';

    # XXX-TODO: $command_context checked ?
    eval q{
        use FML::CGI::User;
        my $submit = new FML::CGI::User;
        $submit->anonymous_cgi_menu($curproc, $command_context);
    };
    if ($r = $@) {
        croak($r);
    }
}


=head1 CODING STYLE

See C<http://www.fml.org/software/FNF/> on fml coding style guide.

=head1 AUTHOR

Ken'ichi Fukamachi

=head1 COPYRIGHT

Copyright (C) 2001,2002,2003,2004,2005,2006,2008 Ken'ichi Fukamachi

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

=head1 HISTORY

FML::Command::User::subscribe first appeared in fml8 mailing list driver package.
See C<http://www.fml.org/> for more details.

=cut


1;
