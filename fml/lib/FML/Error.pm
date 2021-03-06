#-*- perl -*-
#
#  Copyright (C) 2002,2003,2004,2005,2006 Ken'ichi Fukamachi
#   All rights reserved. This program is free software; you can
#   redistribute it and/or modify it under the same terms as Perl itself.
#
# $FML: Error.pm,v 1.39 2006/03/05 08:08:36 fukachan Exp $
#

package FML::Error;
use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK $AUTOLOAD);
use Carp;


my $debug = 0;


=head1 NAME

FML::Error - front end of error messages analyzer.

=head1 SYNOPSIS

    use FML::Error;
    my $error = new FML::Error $curproc;

    # analyze error messages and holds the result within the object.
    $error->analyze();

    # remove addresses analyze() determined as bouncers.
    $error->delete_bouncers();

=head1 DESCRIPTION

This class provides top level dispatcher to analyze error messages.
It can parse error messages and classifies them into error or not
messages.

You can use delete_bouncers() method to remove bounce addresses.

=head1 METHODS

=head2 new($curproc)

constructor.

=cut


# Descriptions: constructor.
#    Arguments: OBJ($self) HASH_REF($curproc)
# Side Effects: none
# Return Value: none
sub new
{
    my ($self, $curproc) = @_;
    my ($type) = ref($self) || $self;
    my $me     = { _curproc => $curproc };
    my $config = $curproc->config();
    my $fp     = $config->{ error_mail_analyzer_function } || 'simple_count';

    # default analyzer function
    set_analyzer_function($me, $fp);

    return bless $me, $type;
}


=head2 get_lock_channel_name()

return the lock channel name to be used to lock/unlock error related
functions.

=cut


# Descriptions: lock channel we should use to lock this object.
#    Arguments: OBJ($self)
# Side Effects: lock "error_mail_analyzer_cache_dir" channel
# Return Value: STR
sub get_lock_channel_name
{
    my ($self) = @_;

    # LOCK_CHANNEL: error_analyzer_cache
    return 'error_analyzer_cache';
}


=head1 LOCK ACCESS TO ERROR CACHE DB

=head2 lock()

=head2 unlock()

=cut


# Descriptions: lock.
#    Arguments: OBJ($self)
# Side Effects: none
# Return Value: none
sub lock
{
    my ($self) = @_;
    my $curproc = $self->{ _curproc };
    my $channel = $self->get_lock_channel_name();
    $curproc->lock($channel);
}


# Descriptions: unlock.
#    Arguments: OBJ($self)
# Side Effects: none
# Return Value: none
sub unlock
{
    my ($self) = @_;
    my $curproc = $self->{ _curproc };
    my $channel = $self->get_lock_channel_name();
    $curproc->unlock($channel);
}


=head1 DATABASE

=head2 db_open()

open cache database.

=head2 db_close()

close cache database (dummy).

=cut


# Descriptions: open cache database.
#    Arguments: OBJ($self)
# Side Effects: none
# Return Value: OBJ
sub db_open
{
    my ($self)  = @_;
    my $curproc = $self->{ _curproc };

    use FML::Error::Cache;
    $self->{ _db } = new FML::Error::Cache $curproc;
    return $self->{ _db };
}


# Descriptions: dummy.
#    Arguments: OBJ($self)
# Side Effects: none
# Return Value: none
sub db_close
{
    my ($self) = @_;
}


=head2 add($info)

add bounce information into cache where $info is a HASH_REF.  Currently,
$info expects "address", "status" (status code) and "reason".
"address" and "status" are mandatory.

    $info = {
	address => $address,
	status  => $status,
	reason  => $reason,
    };

The format to store these information depends on FML::Error::Cache
module, which conceals the detail of the cache structure.

=cut


# Descriptions: add bounce information into cache.
#               in fact, this is a wrapper of FML::Error::Cache::add()
#               to clarify that we should lock.
#    Arguments: OBJ($self) HASH_REF($info)
# Side Effects: update cache
# Return Value: none
sub add
{
    my ($self, $info) = @_;
    my $curproc = $self->{ _curproc };
    my $db      = $self->{ _db };
    my $addr    = $info->{ address };

    if (defined $db) {
	$self->lock();
	$db->add($addr, $info);
	$self->unlock();
    }
    else {
	$curproc->logerror("db not open");
    }
}


=head2 analyze()

open error message cache and analyze the data by the analyzer
function.  The function is specified by $config->{
error_mail_analyzer_function }.  Available functions are located in
C<FML::Error::Analyze>.  C<simple_count> function is used by default
if $config->{ error_mail_analyzer_function } is unspecified.

=cut


# Descriptions: open error message cache and analyze the data by
#               the specified analyzer function.
#    Arguments: OBJ($self)
# Side Effects: set up $self->{ _list_to_be_removed }.
# Return Value: none
sub analyze
{
    my ($self)  = @_;
    my $curproc = $self->{ _curproc };
    my $cache   = $self->db_open();
    my $rdata   = $cache->get_all_values_as_hash_ref();

    use FML::Error::Analyze;
    my $analyzer = new FML::Error::Analyze $curproc;
    my $fp       = $self->get_analyzer_function();

    # critical region: access to db under locked.
    $self->lock();
    $analyzer->$fp($curproc, $rdata);
    $self->unlock();

    # saved for further reference.
    $self->{ _analyzer } = $analyzer;
    $self->{ _list_to_be_removed } = $analyzer->get_address_to_be_deleted();

    # clean up.
    $self->db_close();
}


=head2 set_analyzer_function($fp)

set the function for error cost evaluator. Acutually, the content
locates at C<FML::Error::Analyze::$fp>.

=head2 get_analyzer_function($fp)

get the current function.

=cut


# Descriptions: set analyzer function name.
#    Arguments: OBJ($self) STR($fp)
# Side Effects: one
# Return Value: STR
sub set_analyzer_function
{
    my ($self, $fp) = @_;
    $self->{ _analyzer_function_name } = $fp;
}


# Descriptions: get analyzer function name.
#    Arguments: OBJ($self)
# Side Effects: one
# Return Value: STR
sub get_analyzer_function
{
    my ($self) = @_;
    return $self->{ _analyzer_function_name };
}


=head1 ADDRESS MANIPULATION

=head2 is_list_address($addr)

check whether $addr is one of addresses this ML uses, such as
elena, elena-ctl, elena-admin ... for elena ML.

We need this function to exclude list related addresses from removal
target.

=cut


# Descriptions: check whether $addr is one of addresses this ML uses.
#    Arguments: OBJ($self) STR($addr)
# Side Effects: none
# Return Value: NUM
sub is_list_address
{
    my ($self, $addr)  = @_;
    my $curproc = $self->{ _curproc };
    my $config  = $curproc->config();
    my $cred    = $curproc->credential();
    my $addrs   = $config->get_as_array_ref('list_addresses');
    my $match   = 0;

    my $compare_level = $cred->get_compare_level();
    $cred->set_compare_level(100); # match strictly!

    for my $sysaddr (@$addrs) {
	if (defined $sysaddr && $sysaddr) {
	    $curproc->logdebug("check is_same_address($addr, $sysaddr)");
	    if ($cred->is_same_address($addr, $sysaddr)) {
		$curproc->log("matched") if $debug;
		$match++;
	    }
	    else {
		$curproc->log("not matched") if $debug;
	    }
	}
    }

    $cred->set_compare_level( $compare_level );
    return $match;
}


=head2 delete_bouncers()

delete mail addresses, determined by analyze() as bouncers, by
delete_address() method.

You need to call analyze() method before calling delete_bouncers() to
list up addresses to remove.

=cut


# Descriptions: delete addresses determined by analyze() as bouncers.
#    Arguments: OBJ($self)
# Side Effects: update user address lists.
# Return Value: none
sub delete_bouncers
{
    my ($self)  = @_;
    my $curproc = $self->{ _curproc };
    my $cred    = $curproc->credential();
    my $list    = $self->{ _list_to_be_removed } || [];
    my $myname  = "delete_bouncers";

    use FML::Restriction::Base;
    my $safe = new FML::Restriction::Base;

    # XXX need no lock here since lock is done in FML::Command::* class.
    if (defined $list) {
      ADDR:
	for my $addr (@$list) {
	    unless ($self->is_list_address($addr)) {
		# check if $address is a safe string.
		if ($safe->regexp_match('address', $addr)) {
		    if ($cred->is_member( $addr ) ||
			$cred->is_recipient( $addr )) {
			$self->delete_address( $addr );
		    }
		    else {
			my $s = "$myname: <$addr> seems not a member";
			$curproc->logwarn($s);
		    }
		}
		else {
		    $curproc->logerror("$myname: <$addr> unsafe expression");
		    next ADDR;
		}
	    }
	    else {
		my $s = "$myname: <$addr> is one of ml addr. ignored";
		$curproc->logwarn($s);
	    }
	}
    }
    else {
	$curproc->logerror("$myname: undefined list to remove");
    }
}


=head2 delete_address( $address )

delete the specified address by C<FML::Command::Admin::unsubscribe>.

=cut


# Descriptions: delete the specified address.
#    Arguments: OBJ($self) STR($address)
# Side Effects: none
# Return Value: none
sub delete_address
{
    my ($self, $address) = @_;
    my $curproc = $self->{ _curproc };
    my $config  = $curproc->config();
    my $ml_name = $config->{ ml_name };

    use FML::Restriction::Base;
    my $safe = new FML::Restriction::Base;

    # check if $address is a safe string.
    if ($safe->regexp_match('address', $address)) {
	$curproc->log("delete_address <$address>");
    }
    else {
	my $s = "delete_address: invalid address syntax: <$address>";
	$curproc->logerror($s);
	return;
    }

    # We call FML::Command::Admin::unsubscribe not FML::User::Control
    # since FML::User::Control is too raw.
    my $method          = 'unsubscribe';
    my $command_context = $curproc->command_context_init("$method $address");
    $command_context->set_mode("Admin");
    $command_context->set_cooked_command($method);
    $command_context->set_clean_command("$method $address");
    $command_context->set_ml_name($ml_name);
    $command_context->set_options( [ $address ] );

    # here we go
    require FML::Command;
    my $obj = new FML::Command;

    if (defined $obj) {
        # execute command ($comname method) under eval().
        eval q{
            $obj->$method($curproc, $command_context);
        };
        unless ($@) {
            ; # log nothing.
        }
        else {
            my $r = $@;
            $curproc->logerror("command $method fail");
            $curproc->logerror($r);
            if ($r =~ /^(.*)\s+at\s+/) {
                my $reason = $1;
                $curproc->logerror($reason); # pick up reason
                croak($reason);
            }
        }
    }
}


=head1 DUMP ADDRESS AND STATUS

=head2 print([$handle])

print list of addresses and the corresponding point.

=cut


# Descriptions: list up addresses.
#    Arguments: OBJ($self) HANDLE($handle)
# Side Effects: none
# Return Value: none
sub print
{
    my ($self, $handle) = @_;
    my $wh       = $handle || \*STDOUT;
    my $analyzer = $self->{ _analyzer };

    if (defined $analyzer) {
	my $info = $analyzer->get_summary();
	for my $k (keys %$info) {
	    $analyzer->print($k);
	}
    }
}


=head1 CODING STYLE

See C<http://www.fml.org/software/FNF/> on fml coding style guide.

=head1 AUTHOR

Ken'ichi Fukamachi

=head1 COPYRIGHT

Copyright (C) 2002,2003,2004,2005,2006 Ken'ichi Fukamachi

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

=head1 HISTORY

FML::Error first appeared in fml8 mailing list driver package.
See C<http://www.fml.org/> for more details.

=cut


1;
