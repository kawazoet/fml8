#-*- perl -*-
#
# Copyright (C) 2000-2001 Ken'ichi Fukamachi
#          All rights reserved. 
#
# $FML: ThreadTrack.pm,v 1.16 2001/11/20 07:32:37 fukachan Exp $
#

package FML::Process::ThreadTrack;

use vars qw($debug @ISA @EXPORT @EXPORT_OK);
use strict;
use Carp;

use FML::Process::Kernel;
use FML::Log qw(Log LogWarn LogError);
use FML::Config;

@ISA = qw(FML::Process::Kernel);


=head1 NAME

FML::Process::ThreadTrack -- primitive thread tracking system

=head1 SYNOPSIS

See C<Mail::ThreadTrack> module.

=head1 DESCRIPTION

This class drives thread tracking system in the top level.

=head1 METHOD

=head2 C<new($args)>

create a C<FML::Process::Kernel> object and return it.

=head2 C<prepare()>

dummy.

=cut


sub new
{
    my ($self, $args) = @_;
    my $type    = ref($self) || $self;
    my $curproc = new FML::Process::Kernel $args;
    return bless $curproc, $type;
}


# Descriptions: dummy to avoid to take data from STDIN 
#    Arguments: $self $args
# Side Effects: 
# Return Value: none
sub prepare
{
    ;
}


=head2 C<run($args)>

call the actual thread tracking system.

=cut

sub run
{
    my ($curproc, $args) = @_;
    my $config  = $curproc->{ config };
    my $myname  = $curproc->myname();
    my $argv    = $curproc->command_line_argv();
    my $options = $curproc->command_line_options();
    my $mydir   = defined $options->{spool_dir} ? $options->{spool_dir} : '';
    my $command = $argv->[ 0 ] || '';

    #  argumente for thread track module
    my $ml_name       = $config->{ ml_name };
    my $thread_db_dir = $config->{ thread_db_dir };
    my $spool_dir     = $mydir || $config->{ spool_dir };
    my $max_id        = $curproc->_speculate_max_id($spool_dir);
    my $ttargs        = {
	myname        => $myname,
	logfp         => \&Log,
	fd            => \*STDOUT,
	db_base_dir   => $thread_db_dir,
	ml_name       => $ml_name,
	spool_dir     => $spool_dir,
	max_id        => $max_id,
	reverse_order => (defined $options->{ reverse } ? 1 : 0),
    };


    use Mail::ThreadTrack;
    my $thread = new Mail::ThreadTrack $ttargs;
    $thread->set_mode('text');

    if (defined $options->{ f }) {
	_read_filter_list($thread, $options->{ f });
    }

    $curproc->lock();

    if ($command eq 'list') {
	$thread->list();
    }
    elsif ($command eq 'summary') {
	$thread->summary();
    }
    elsif ($command eq 'review') {
	my $str = defined $argv->[2] ? $argv->[ 2 ] : 'last:100';
	$thread->review( $str , 1, $max_id );
    }
    elsif ($command eq 'db_dump') {
	my $type = defined $argv->[ 2 ] ? $argv->[ 2 ] : 'status';
	$thread->db_open();
	$thread->db_dump( $type );
	$thread->db_close();
    }
    elsif ($command eq 'db_update') {
	my $last_id = $curproc->_speculate_last_id($thread);
	print STDERR "db_update: $last_id -> $max_id\n";
	$thread->db_mkdb($last_id, $max_id);	
    }
    elsif ($command eq 'db_rebuild') {
	print STDERR "\$thread->db_mkdb(1, $max_id);\n" if $ENV{'debug'};
	$thread->db_mkdb(1, $max_id);
    }
    elsif ($command eq 'db_clear') {
	$thread->db_open();
	$thread->db_clear();
	$thread->db_close();
    }
    elsif ($command eq 'close') {
	my $thread_id = $argv->[ 2 ];
	if (defined $thread_id) {
	    _close($thread, $thread_id, 1, $max_id);
	}
	else {
	    croak("specify \$thread_id");
	}
    }
    else {
	if ($argv->[ 0 ] ne '') {
	    push(@ISA, 'FML::Process::ThreadTrack::CUI');
	    $ttargs->{ ml_name } = $argv->[ 0 ];
	    $curproc->interactive($args, $thread, $ttargs);
	}
	else {
	    help();
	}
    }

    $curproc->unlock();
}


sub _speculate_last_id
{
    my ($curproc, $thread) = @_;
    my $last_id = 0;

    $thread->db_open();

    my $rh = $thread->db_hash( 'date' );
    if (defined $rh) {
	eval q{
	    use File::Sequence;
	    my $obj = new File::Sequence;
	    $last_id = $obj->search_max_id( { hash => $rh } );
	};
	warn($@) if $@;
    }

    $thread->db_close();

    return $last_id;
}


sub _speculate_max_id
{
    my ($curproc, $spool_dir) = @_;
    my $options = $curproc->command_line_options();

    if (defined $options->{ article_id_max }) {
	return $options->{ article_id_max };
    }
    else {
	my $max_id = $curproc->speculate_max_id();

	# XXX check whether $max_id > 1 or not since
	# XXX speculate_max_id() returns 1 by default
 	if ($max_id > 1) {
	    return $max_id;
	}
	else {
	    eval q{ 
		use FML::Article; 
		push(@ISA, 'FML::Article');
		$max_id = $curproc->speculate_max_id($spool_dir);
	    };
	    warn($@) if $@;
	}

	if ($max_id > 0) {
	    return $max_id;
	}
    }

    warn("cannot determine max_id");
    return undef;
}


sub _read_filter_list
{
    my ($thread, $file) = @_;

    if (-f $file) {
	use FileHandle;
	my $fh = new FileHandle $file;
	if (defined $fh) {
	    my ($key, $value);
	    while (<$fh>) {
		chop;
		($key, $value) = split(/\s+/, $_, 2);
		if ($key) {
		    $thread->add_filter( { $key => $value });
		}
	    }
	    $fh->close();
	}
    }
}


# $thread_id accepts MH style format.
# MH style is expanded by C<Mail::Messsage::MH>.
sub _close
{
    my ($thread, $thread_id, $min, $max) = @_;

    # expand MH style variable: e.g. last:100 -> [ 100 .. 200 ]
    use Mail::Message::MH;
    my $ra = Mail::Message::MH->expand($thread_id, $min, $max);
    $ra = [ $thread_id ] unless defined $ra;

    for my $id (@$ra) {
	# e.g. 100 -> elena/100
	if ($id =~ /^\d+$/) { $id = $thread->_create_thread_id_strings($id);}

	# check "elena/100" exists ?
	if ($thread->exist($id)) {
	    Log("close thread_id=$id");
	    $thread->close($id);
	}
	else {
	    Log("thread_id=$id not exists") if $ENV{'debug'};
	}
    }
}


sub help
{
    use File::Basename;
    my $name = basename($0);

print <<"_EOF_";

Usage: $name \$command \$ml_name [options]

$name list       \$ml_name      list up summary
$name summary    \$ml_name      list up summary
$name close      \$ml_name id   close ticket specified by id (MH style)
$name db_update  \$ml_name      rebuild database for latest articles
$name db_rebuild \$ml_name      rebuild database for whole of ML
$name db_clear   \$ml_name      clear thread database for \$ml_name ML

_EOF_
}


sub DESTROY {}

# Descriptions: dummy routine to avoid errors
#               since we need all methods defined in FML::Process::Flow.
#    Arguments: $self $args
# Side Effects: none
# Return Value: none
sub AUTOLOAD
{
    my ($curproc, $args) = @_;
    1;
}


package FML::Process::ThreadTrack::CUI;

use vars qw($debug @ISA @EXPORT @EXPORT_OK);
use strict;
use Carp;


sub interactive
{
    my ($curproc, $args, $thread, $ttargs) = @_;

    eval q{
	use Term::ReadLine;
	my $term    = new Term::ReadLine "fmlthread";
	my $ml_name = $ttargs->{ ml_name };
	my $prompt  = "$ml_name thread> ";
	my $OUT     = $term->OUT || \*STDOUT;
	my $res     = '';

	# main loop;
	no strict;
	while ( defined ($_ = $term->readline($prompt)) ) {
	    _exec($curproc, $args, $thread, $ttargs, $_);
	    warn $@ if $@;
	    $term->addhistory($_) if /\S/;
	}
    };
    carp($@) if $@;
}


sub _exec
{
    my ($curproc, $args, $xthread, $ttargs, $buf) = @_;
    my ($command, @argv) = ();

    use Mail::ThreadTrack;
    my $thread = new Mail::ThreadTrack $ttargs;
    $thread->set_mode('text');

    # clean up
    if (defined $buf && $buf) {
	$buf =~ s/^\s*//;
	$buf =~ s/\s*$//;
	($command, @argv) = split(/\s+/, $buf);
    }

    if ($command eq '') {
	help();
    }
    elsif ($command eq 'quit' || $command eq 'exit' || $command eq 'end') {
	exit(0);
    }
    elsif ($command eq 'list') {
	$thread->list();
    }
    elsif ($command eq 'show') {
	for my $id (@argv) {
	    if ($id =~ /^\d+$/) { 
		my $xid = $thread->_create_thread_id_strings($id);
		use FileHandle;
		my $wh = new FileHandle "| less";
		my $saved_fd = $thread->get_fd( $wh );
		$thread->set_fd( $wh );
		$thread->show($xid);
		$thread->set_fd( $saved_fd );
	    }
	    else {
		print "sorry, cannot show $id\n";
	    }
	}
    }
    elsif ($command eq 'close') {
	my $max_id = $ttargs->{ max_id };
	for my $id (@argv) {
	    print "close $id\n";
	    &FML::Process::ThreadTrack::_close($thread, $id, 1, $max_id);
	}
    }
    else {
	help();
    }
}


#
# commands
#

sub help 
{ 
    print "Usage: $0\n\n";

    print "list         show thread summary (without article summary)\n";
    print "show  id(s)  show articles in thread_id\n";
    print "close id(s)  close thread specified by thread_id\n";
    print "quit         to end\n";
    print "Ctl-D        to end\n";
    print "\n";
    print "Typical Usage:\n";
    print "  > list\n ... \n";
    print "  > show 100\n";
    print "  > close 100\n";
    print "\n";
}


=head1 AUTHOR

Ken'ichi Fukamachi

=head1 COPYRIGHT

Copyright (C) 2001 Ken'ichi Fukamachi

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself. 

=head1 HISTORY

FML::Process::Kernel appeared in fml5 mailing list driver package.
See C<http://www.fml.org/> for more details.

=cut


1;
