#-*- perl -*-
#
#  Copyright (C) 2001 Ken'ichi Fukamachi
#   All rights reserved. This program is free software; you can
#   redistribute it and/or modify it under the same terms as Perl itself. 
#
# $Id$
# $FML$
#

package FML::Process::Switch;

use strict;
use Carp;
use vars qw($debug);
use Standalone;

sub main::Bootstrap2
{
    my ($main_cf_file) = @_;

    # 2. pick up *.cf files to read and set them to @cf.
    #    We pass it to fml_loader.
    # pass *.cf files to libexec/{distribute,command}
    # for example
    # @cf = ( /etc/fml/defaults/$VERSION/default_config.cf 
    #         /etc/fml/site_default_config.cf (required ?)
    #         /etc/fml/domains/$DOMAIN/default_config.cf
    #         /var/spool/ml/elena/config.cf
    #        );
    my @argv    = @ARGV; # save the original arguments
    my @cf      = ();
    my %options = ();
    my $my_default_config = '';
    my $ml_home_dir       = ''; # e.g. /var/spool/ml/elena

    # inspect my name from $0
    use File::Basename;
    my $myname = basename($0);


    # parse command line options (preliminary)
    use Getopt::Long;
    GetOptions(\%options, _module_specific_options($myname));

    my $main_cf = Standalone::load_cf($options{'c'} || $main_cf_file,
				      $options{'params'}
				      );

    my $default_config = $my_default_config || $main_cf->{ default_config };
    
    # 2.2 parse @ARGV ..
    my $ml_home_prefix = $main_cf->{ ml_home_prefix };
    my $found_cf       = 0;
    for (@ARGV) {
	# elena is translated to "/var/spool/ml/elena"
	unless ($found_cf) {
	    my $x = "$ml_home_prefix/$_";
	    if (-d $x && -f "$x/config.cf") {
		$found_cf = 1;
		$ml_home_dir = $x;
		push(@cf, "$x/config.cf"); 
	    }
	}

	if (-d $_) {
	    $ml_home_dir = $_;
	    if (-f "$_/config.cf") {
		push(@cf, "$_/config.cf");
		$found_cf = 1;
	    }
	}
	elsif (-f $_) {
	    push(@cf, $_);
	}
    }

    # 2.3 prepare @cf
    # XXX hmm, .. '/etc/fml/site_default_config.cf' is good ???
    unshift(@cf, '/etc/fml/site_default_config.cf');
    unshift(@cf, $default_config);

    # 3. reset @INC 
    unshift(@INC, split(/\s+/, $main_cf->{ lib_dir }));	    
    unshift(@INC, split(/\s+/, $main_cf->{ local_lib_dir }));

    # 3.1 useful for e.g. "fmldoc"
    $ENV{'PERL5LIB'} = $main_cf->{ lib_dir };

    # 4. debug
    if ($0 =~ /loader/) {
	eval q#
	    require Data::Dumper; 
	    Data::Dumper->import();
	    print Dumper( $main_cf );
	    sleep 3;
	#;
    }

    # 5. o.k. here we go!
    my ($args, $pkg);

    $args = {
	fml_version    => $main_cf->{ fml_version },
	
	myname         => $myname,
	ml_home_prefix => $main_cf->{ ml_home_prefix },
	ml_home_dir    => $ml_home_dir,
	
	cf_list        => \@cf,
	options        => \%options,

	# pass the original information to each process
	argv           => \@argv,
	ARGV           => \@ARGV,

	# options
	need_ml_name   => _ml_name_is_required($myname),
    };

    # See libexec/process_switch on ProcessSwitch()
    $pkg = ProcessSwitch($args);

    # See FML::Process::Kernel module on ProcessStart()
    FML::Process::Flow::ProcessStart($pkg, $args);
}


# Descriptions: top level process switch
#               emulates "use $package" but $package is dynamically 
#               determined by e.g. $0.
#    Arguments: $args
#               XXX non OO interface
# Side Effects: process switching :-)
#               ProcessSwtich() is exported to main:: Name Space.
# Return Value: package name
sub ProcessSwitch
{
    my ($args) = @_;

    # Firstly, create process 
    # $pkg is a  package name, for exampl,e "FML::Process::Distribute".
    my $pkg = _module_we_use($args);
    croak("$args->{ myname } is unknown program\n") unless ($pkg);

    eval qq{ require $pkg; }; # XXX require() needs bare words.
    croak($@) if $@;
    $pkg->import();   # fake to use() method.

    return $pkg;
}


sub _module_specific_options
{
    my ($myname) = @_;

    if ($myname eq 'fml.pl' || 
	$myname eq 'loader' ) { 
	return qw(ctladdr! debug! params=s -c=s);
    }
    elsif ($myname eq 'fmlticket'|| $myname eq 'fmlticket.cgi') {
	return qw(debug! params=s -c=s -A=s -R=s);
    }
    elsif ($myname eq 'fmlconf') {
	return qw(ctladdr! debug! params=s -c=s n!);
    }
    elsif ($myname eq 'fmldoc') {
	return qw(ctladdr! debug! params=s -c=s n!);	
    }
    else {
	croak "options for $myname are not defined.\n";
    }
}


sub _ml_name_is_required
{
    my ($myname) = @_;

    if ($myname eq 'fmldoc') {
	return 0;
    }
    elsif ($myname eq 'fmlticket.cgi') {
	return 0;
    }
    else {
	return 1;
    }
}


# Descriptions: determine package we need and require() it if needed.
#    Arguments: $args
#               XXX non OO interface
# Side Effects: none
# Return Value: FML::Process::SOMETHING process object
sub _module_we_use
{
    my ($args) = @_;    
    my $name   = $args->{ myname };
    my $pkg    = '';

    if (($name eq 'fml.pl' && $args->{ options }->{ ctladdr }) || 
	   $name eq 'command') {
	$pkg = 'FML::Process::Command';
    }
    elsif ($name eq 'fml.pl' || $name eq 'distribute' || $name eq 'loader') {
	$pkg = 'FML::Process::Distribute';
    }
    elsif ($name eq 'fmlserv') {
	$pkg = 'FML::Process::ListServer';
    }
    elsif ($name eq 'fmlconf' || $name eq 'fmldoc' || $name eq 'makefml') {
	$pkg = 'FML::Process::Configure';
    }
    elsif ($name eq 'fmlticket.cgi') {
	$pkg = 'FML::CGI::TicketSystem';
    }
    elsif ($name eq 'fmlticket') {
	$pkg = 'FML::Process::TicketSystem';
    }
    elsif ($name eq 'mead') {
	$pkg = 'FML::Process::MailErrorAnalyzer';
    }
    elsif ($name eq 'qmail-ext') {
	$pkg = 'FML::Process::QMail';
    }
    else {
	return '';
    }

    return $pkg;
}


=head1 NAME

process_switch - switch or dispacther table to execute real fml programs

=head1 SYNOPSIS

	require "$libexec_dir/process_switch";
	ProcessSwitch( 
		      {
			  fml_version    => $main_cf->{ fml_version },

			  myname         => $myname,
			  ml_home_prefix => $main_cf->{ ml_home_prefix },
			  ml_home_dir    => $ml_home_dir,

			  cf_list        => \@cf,
			  options        => \%options,
		      });

See also C<libexec/fml/loader>.

=head1 DESCRIPTION

C<libexec/loader>
(C<libexec/fml/loader>), 
the wrapper, loads this program and calls C<ProcessSwitch()>.  
C<ProcessSwitch()> emulates "use $package" for a program specified by
the arguments.

The details of each program exists in FML::Process:: class.

=head1 SEE ALSO

L<FML::Process::Distribute>,
L<FML::Process::Command>,
L<FML::Process::ListServer>,
L<FML::Process::Configure>,
L<FML::Process::TicketSystem>,
L<FML::Process::MailErrorAnalyzer>

=cut

1;
