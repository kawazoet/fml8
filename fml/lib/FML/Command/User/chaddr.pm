#-*- perl -*-
#
#  Copyright (C) 2001,2002,2003,2004,2005,2006,2008 Ken'ichi Fukamachi
#   All rights reserved. This program is free software; you can
#   redistribute it and/or modify it under the same terms as Perl itself.
#
# $FML: chaddr.pm,v 1.40 2006/10/08 06:06:47 fukachan Exp $
#

package FML::Command::User::chaddr;
use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK $AUTOLOAD);
use Carp;


=head1 NAME

FML::Command::User::chaddr - change subscribed address.

=head1 SYNOPSIS

See C<FML::Command> for more details.

=head1 DESCRIPTION

Firstly, apply confirmation before chaddr (change subscribed address)
processed. After confirmation succeeds, chaddr process proceeds.

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

If either old or new addresses in chaddr arguments is an ML member,
try to confirm this request. The confirmation is returned to "From:"
address in the mail header, "Reply-To" is ignored.

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


# Descriptions: verify the syntax command string.
#    Arguments: OBJ($self) OBJ($curproc) OBJ($command_context)
# Side Effects: none
# Return Value: NUM(1 or 0)
sub verify_syntax
{
    my ($self, $curproc, $command_context) = @_;
    my $comname    = $command_context->get_cooked_command() || '';
    my $options    = $command_context->get_options()        || [];
    my $command    = $comname;
    my $oldaddr    = $options->[ 0 ] || '';
    my $newaddr    = $options->[ 1 ] || '';
    my (@test)     = ($command);

    $curproc->log("command = $command, old = $oldaddr, new = $newaddr");

    my $ok = 0;

    use FML::Restriction::Base;
    my $dispatch = new FML::Restriction::Base;
    if ($dispatch->regexp_match('address', $oldaddr)) {
	$ok++;
    }
    else {
	$curproc->logerror("insecure address: <$oldaddr>");
	return 0;
    }

    if ($dispatch->regexp_match('address', $newaddr)) {
	$ok++;
    }
    else {
	$curproc->logerror("insecure address: <$newaddr>");
	return 0;
    }

    use FML::Command;
    $dispatch = new FML::Command;
    if ($dispatch->safe_regexp_match($curproc, $command_context, \@test)) {
	$ok++;
    }

    return( $ok == 3 ? 1 : 0 );
}


# Descriptions: chaddr adapter: confirm before real chaddr operation.
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
    my $comname       = $command_context->get_cooked_command();
    my $command       = $command_context->get_clean_command();
    my $sender        = $cred->sender();

    # cheap sanity checks
    croak("\$member_map is not specified")    unless $member_map;
    croak("\$recipient_map is not specified") unless $recipient_map;

    # exatct match as could as possible.
    my $compare_level = $cred->get_compare_level();
    $cred->set_compare_level( 100 );

    # addresses we check and send back confirmation messages to
    my $optargs = {};
    my $x = $command_context->get_clean_command();
    $x =~ s/^.*$comname\s+//;
    my ($old_addr, $new_addr) = split(/\s+/, $x);
    $optargs->{ recipient } = [ $sender, $old_addr, $new_addr ];

    # simple checks.
    use FML::Restriction::Base;
    my $safe = new FML::Restriction::Base;
    unless ($safe->regexp_match('address', $old_addr)) {
	$curproc->logerror("chaddr: unsafe address <$old_addr>");
	croak("chaddr: unsafe address");
    }
    unless ($safe->regexp_match('address', $new_addr)) {
	$curproc->logerror("chaddr: unsafe address <$new_addr>");
	croak("chaddr: unsafe address");
    }

    # prompt again (since recipient differs)
    my $prompt = $config->{ command_mail_reply_prompt } || '>>>';
    $curproc->reply_message("\n$prompt $command", $optargs);

    # if either old or new addresses in chaddr arguments is an ML member,
    # try to confirm this request irrespective of "From:" address.
    # 1. request from $old_addr : $old_addr (member now) -> $new_addr
    # 2. request from $new_addr : $old_addr -> $new_addr (member now)
    if ($cred->is_member($old_addr) || $cred->is_member($new_addr)) {
	$cred->set_compare_level( $compare_level );

	$curproc->log("chaddr request, try confirmation");

	# XXX-TODO: no confirmation case ?
	# XXX-TODO: change arg ? FML::Confirm { ... address => [ @addr ] }
	use FML::Confirm;
	my $confirm = new FML::Confirm $curproc, {
	    keyword   => $keyword,
	    cache_dir => $cache_dir,
	    class     => 'chaddr',
	    address   => "$old_addr $new_addr",
	    buffer    => $command,
	};

	use FML::Command::Message;
	my $_msg    = new FML::Command::Message;
	my $sc_args = {
	    command => "chaddr",
	    rm_args => $optargs,
	};
	$_msg->send_confirmation($curproc, $command_context, $confirm, $sc_args);
    }
    # try confirmation before chaddr.
    else {
	$curproc->reply_message_nl('error.not_member', '', $optargs);
	$cred->set_compare_level( $compare_level );
	croak("not member");
    }
}


# Descriptions: show cgi menu for chaddr command for an anonymous user.
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

FML::Command::User::chaddr first appeared in fml8 mailing list driver package.
See C<http://www.fml.org/> for more details.

=cut


1;
