#-*- perl -*-
#
# Copyright (C) 2000,2001,2002 Ken'ichi Fukamachi
#          All rights reserved.
#
# $FML: Command.pm,v 1.37 2002/03/17 06:24:31 fukachan Exp $
#

package FML::Process::Command;

use vars qw($debug @ISA @EXPORT @EXPORT_OK);
use strict;
use Carp;

use FML::Process::Kernel;
use FML::Log qw(Log LogWarn LogError);
use FML::Config;

@ISA = qw(FML::Process::Kernel);


=head1 NAME

FML::Process::Command -- command dispacher.

=head1 SYNOPSIS

   use FML::Process::Command;
   ...

See L<FML::Process::Flow> for details of fml process flow.

=head1 DESCRIPTION

C<FML::Process::Command> is a command wrapper and top level
dispatcher for commands.
It kicks off corresponding

   FML::Command->$command($curproc, $command_args)

for the given C<$command>.

=head1 METHODS

=head2 C<new($args)>

make fml process object, which inherits C<FML::Process::Kernel>.

=cut


# Descriptions: standard constructor.
#    Arguments: OBJ($self) HASH_REF($args)
# Side Effects: inherit FML::Process::Kernel
# Return Value: OBJ
sub new
{
    my ($self, $args) = @_;
    my $type    = ref($self) || $self;
    my $curproc = new FML::Process::Kernel $args;
    return bless $curproc, $type;
}


=head2 C<prepare($args)>

forward the request to SUPER CLASS.

=cut

# Descriptions: dummy
#    Arguments: OBJ($self) HASH_REF($args)
# Side Effects: none
# Return Value: none
sub prepare
{
    my ($self, $args) = @_;
    my $config = $self->{ config };

    my $eval = $config->get_hook( 'command_prepare_start_hook' );
    if ($eval) { eval qq{ $eval; }; LogWarn($@) if $@; }

    $self->SUPER::prepare($args);

    $eval = $config->get_hook( 'command_prepare_end_hook' );
    if ($eval) { eval qq{ $eval; }; LogWarn($@) if $@; }
}


=head2 C<verify_request($args)>

verify the sender is a valid member or not.

=cut


# Descriptions: verify the sender of this process is an ML member.
#    Arguments: OBJ($self) HASH_REF($args)
# Side Effects: none
# Return Value: 1 or 0
sub verify_request
{
    my ($curproc, $args) = @_;
    my $config = $curproc->{ config };

    my $eval = $config->get_hook( 'command_verify_request_start_hook' );
    if ($eval) { eval qq{ $eval; }; LogWarn($@) if $@; }

    $curproc->verify_sender_credential();

    $eval = $config->get_hook( 'command_verify_request_end_hook' );
    if ($eval) { eval qq{ $eval; }; LogWarn($@) if $@; }
}


=head2 C<run($args)>

dispatcher to run correspondig C<FML::Command::command> for
C<command>. Standard style follows:

    lock
    execute FML::Command::command
    unlock

XXX Each command determines need of lock or not.

=cut


# Descriptions: call _evaluate_command()
#    Arguments: OBJ($self) HASH_REF($args)
# Side Effects: none
# Return Value: none
sub run
{
    my ($curproc, $args) = @_;
    $curproc->_evaluate_command($args);
}


=head2 help()

show help.

=cut


# Descriptions: show help
#    Arguments: none
# Side Effects: none
# Return Value: none
sub help
{
print <<"_EOF_";

Usage: $0 \$ml_home_prefix/\$ml_name [options]

   For example, process command of elena ML
   $0 /var/spool/ml/elena

_EOF_
}


=head2 C<finish($args)>

    $curproc->inform_reply_messages();

=cut


# Descriptions: finalize command process.
#               reply messages, command results et. al.
#    Arguments: OBJ($self) HASH_REF($args)
# Side Effects: queue manipulation
# Return Value: none
sub finish
{
    my ($curproc, $args) = @_;
    my $config = $curproc->{ config };

    my $eval = $config->get_hook( 'command_finish_start_hook' );
    if ($eval) { eval qq{ $eval; }; LogWarn($@) if $@; }

    $curproc->inform_reply_messages();
    $curproc->queue_flush();

    $eval = $config->get_hook( 'command_finish_end_hook' );
    if ($eval) { eval qq{ $eval; }; LogWarn($@) if $@; }
}


# Descriptions: check message of the current process
#               whether it contais keyword e.g. "confirm".
#    Arguments: OBJ($self) STR_REF($ra_body)
# Side Effects: none
# Return Value: ARRAY
sub _pre_scan
{
    my ($curproc, $ra_body) = @_;
    my $config  = $curproc->{ config };

    # special traps
    my $confirm_prefix = $config->{ confirm_command_prefix };
    my $admin_prefix   = $config->{ privileged_command_prefix };
    my $confirm_found  = '';
    my $admin_found    = '';

    # clean up
    $confirm_prefix =~ s/\s*$//;
    $admin_prefix   =~ s/\s*$//;

    for (@$ra_body) {
	if (/$confirm_prefix\s+\w+\s+([\w\d]+)/) {
	    $confirm_found = $1;
	}

	if (/$admin_prefix\s+\w+\s+([\w\d]+)/) {
	    $admin_found = $1;
	}
    }

    return ($confirm_found, $admin_found);
}


# Descriptions: check command (specified in $opts) content:
#               syntax check, permission of command use et. al.
#    Arguments: OBJ($self) HASH_REF($args) HASH_REF($opts)
# Side Effects: none
# Return Value: 1 or 0
sub _is_valid_command
{
    my ($curproc, $args, $mode, $opts) = @_;
    my $config  = $curproc->{ config };
    my $cred    = $curproc->{ credential }; # user credential
    my $prompt  = $config->{ command_prompt } || '>>>';
    my $comname = $opts->{ comname };
    my $command = $opts->{ command };

    # 1. simple command syntax check
    use FML::Restriction::Command;
    unless (FML::Restriction::Command::is_secure_command_string( $command )) {
	LogError("insecure command: $command");
	$curproc->reply_message("\n$prompt $command");
	$curproc->reply_message_nl('command.insecure',
				   "insecure, so ignored.");
	return 0;
    }

    # 2. use of this command is allowed in FML::Config or not ?
    unless ($config->has_attribute("available_commands_for_$mode", $comname)) {
	$curproc->reply_message("\n$prompt $command");
	$curproc->reply_message_nl('command.not_command',
				   "not command, ignored.");
	return 0;
    }

    if (0) {
	# 3. Even new comer need to use commands [ guide, subscirbe, confirm ].
	unless ($cred->is_member($curproc, $args)) {
	    unless ($config->has_attribute("available_commands_for_stranger",
					   $comname)) {
		$curproc->reply_message("\n$prompt $command");
		$curproc->reply_message_nl('command.deny',
					   "not allowed to use this command.");
		return 0;
	    }
	    else {
		return 1;
		Log("permit command $comname for stranger");
	    }
	}

	# not reach here
	LogWarn("_is_member: invalid condition");
	return 0;
    }

    return 1; # o.k. accpet this command.
}


# Descriptions: parse command buffer to make
#               argument vector after command name
#    Arguments: STR($command) STR($comname)
# Side Effects: none
# Return Value: HASH_ARRAY
sub _parse_command_options
{
    my ($command, $comname) = @_;
    my $found = 0;
    my (@options) = ();

    for (split(/\s+/, $command)) {
	push(@options, $_) if $found;
	$found = 1 if $_ eq $comname;
    }

    return \@options;
}


# Descriptions: return command name ( ^\S+ in $command ).
#               remove the prepending strings such as \s, #, ...
#    Arguments: STR($command)
# Side Effects: none
# Return Value: ARRAY
sub _get_command_name
{
    my ($command) = @_;

    # cut off the prepended strings
    $command =~ s/^[\#\s]*//;

    my ($comname, $comsubname) = split(/\s+/, $command);
    return ($comname, $comsubname);
}


# Descriptions: scan message body and execute approviate command
#               with dynamic loading of command definition.
#               It resolves your customized command easily.
#    Arguments: OBJ($self) HASH_REF($args)
# Side Effects: loading FML::Command::command.
#               prepare messages to return.
# Return Value: none
sub _evaluate_command
{
    my ($curproc, $args) = @_;
    my $config  = $curproc->{ config };
    my $ml_name = $config->{ ml_name };
    my $argv    = $curproc->command_line_argv();
    my $prompt  = $config->{ command_prompt } || '>>>';
    my $mode    = 'user';
    my $rbody   = $curproc->{ incoming_message }->{ body };
    my $msg     = $rbody->find_first_plaintext_message();
    my $body    = $msg->message_text;
    my @body    = split(/\n/, $body);

    # preliminary scanning for message to find "confirm" or "admin"
    my ($id, $admin_password) = $curproc->_pre_scan( \@body );

    # special traps are needed for "confirm" and "admin" commands.
    my $confirm_prefix = $config->{ confirm_command_prefix };
    my $admin_prefix   = $config->{ privileged_command_prefix };

    my $eval = $config->get_hook( 'command_run_start_hook' );
    if ($eval) { eval qq{ $eval; }; LogWarn($@) if $@; }

    # 
    # credential
    # 
    my $cred      = $curproc->{ credential };
    my $is_member = $cred->is_member($curproc, $args);
    my $is_admin  = $cred->is_privileged_member($curproc, $args);

    # 
    # main loop
    # 
    my ($command, $comname, $comsubname, $opts);

    # firstly, prompt (for politeness :) to show processing ...
    $curproc->reply_message("result for your command requests follows:");

  COMMAND:
    for my $orig_command (@body) {
	next COMMAND if $orig_command =~ /^\s*$/; # ignore empty lines

	Log("input: $orig_command"); # log raw buffer

	# command = line itsetlf, it contains superflous strings
	# comname = command name
	# for example, command = "# help", comname = "help"
	($comname, $comsubname) = _get_command_name($orig_command);
	$command = $orig_command;
	$mode    = 'unknown';

	# Case: "confirm" command.
	#        It is exceptional strangers can use.
	#        validate general command except for confirmation
	#        if $id is 1, this message must be confirmation reply.
	if ($command =~ /$confirm_prefix/ && $id) {
	    # XXX $command may be "> confirm chaddr ...".
	    $comname = $confirm_prefix;          # comname = confirm
	    $command =~ s/^.*$comname/$comname/; # normalize $command
	    $opts    = { comname => $comname, command => $command };

	    if ($curproc->_is_valid_command($args, "stranger", $opts)) {
		$mode = 'user';
	    }
	    else {
		# no, we do not accept this command.
		Log("invalid command: $command");
		next COMMAND;
	    }
	}
	# Case: "admin" command is exceptional. try priviledged mode.
	elsif ($comname =~ /$admin_prefix/) {
	    if ($is_admin) {
		$comname = $comsubname;
		$command =~ s/^.*$comname/admin $comname/;
		$opts    = { comname => $comname, command => $command };

		my $xmode = 'privileged_user';
		if ($curproc->_is_valid_command($args, $xmode, $opts)) {
		    $mode = 'admin';
		}
		else {
		    # no, we do not accept this command.
		    Log("invalid command(priv mode): $command");
		    next COMMAND;
		}
	    }
	    else {
		LogError("privileged command from not an admin user");
		LogError("command processing stop.");
		last COMMAND;
	    }
	}
	# Case: use command (commands "a usual member" can use)
	else {
	    if ($is_member) {
		$opts = { comname => $comname, command => $command };
		if ($curproc->_is_valid_command($args, "user", $opts)) {
		    $mode = 'user';
		}
		else {
		    # no, we do not accept this command.
		    Log("invalid command: $command");
		    next COMMAND;
		}
	    }
	    else {
		LogError("command from not member.");
		LogError("command processing stop.");
		last COMMAND;
	    }
	}

	# cheap sanity condition
	unless ($mode eq 'user' || $mode eq 'admin' || $mode eq 'special') {
	    LogError("command processing looks insane. stop.");
	    last COMMAND;
	}

	# o.k. here we go to execute command
	use FML::Command;
	my $obj = new FML::Command;
	if (defined $obj) {
	    $curproc->reply_message("\n$prompt $orig_command");

	    # arguments to pass off to each method
	    my $command_args = {
		command_mode => $mode,
		comname      => $comname,
		command      => $command,
		ml_name      => $ml_name,
		options      => _parse_command_options($command, $comname),
		argv         => $argv,
		args         => $args,
	    };

	    # execute command ($comname method) under eval().
	    eval q{
		$obj->$comname($curproc, $command_args);
	    };
	    unless ($@) {
		$curproc->reply_message_nl('command.ok', "ok.");
	    }
	    else { # error trap
		my $reason = $@;
		Log($reason);

		$curproc->reply_message_nl('command.fail', "fail.");
		LogError("command ${comname} fail");

		if ($reason =~ /^(.*)\s+at\s+/) {
		    my $reason = $1;
		    Log($reason); # pick up reason
		}
	    }
	}
    } # END OF FOR LOOP: for my $command (@body) { ... }

    $eval = $config->get_hook( 'command_run_end_hook' );
    if ($eval) { eval qq{ $eval; }; LogWarn($@) if $@; }
}


=head1 AUTHOR

Ken'ichi Fukamachi

=head1 COPYRIGHT

Copyright (C) 2000,2001,2002 Ken'ichi Fukamachi

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

=head1 HISTORY

FML::Process::Command appeared in fml5 mailing list driver package.
See C<http://www.fml.org/> for more details.

=cut


1;
