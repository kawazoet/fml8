#!/usr/local/bin/perl -w
#-*- perl -*-
#
# Copyright (C) 2000 Ken'ichi Fukamachi
#          All rights reserved. 
#
# $FML$
#

package FML::Process::Distribute;

use vars qw($debug @ISA @EXPORT @EXPORT_OK);
use strict;
use Carp;

use FML::Process::Kernel;
use FML::Log qw(Log);
use FML::Config;

require Exporter;
@ISA = qw(FML::Process::Kernel Exporter);


sub new
{
    my ($self, $args) = @_;
    my $type    = ref($self) || $self;
    my $curproc = new FML::Process::Kernel $args;
    return bless $curproc, $type;
}


sub prepare
{
    my ($self, $args) = @_;
    $self->SUPER::prepare($args);
}


sub run
{
    my ($curproc, $args) = @_;

    $curproc->verify_sender_credential();

    $curproc->lock();
    {
	# user credential
	my $cred = $curproc->{ credential };

	# Q: the mail sender is a ML member?
	if ($cred->is_member) {
	    # A: If so, we try to distribute this article.
	    _distribute( $curproc ); 
	}
    }
    $curproc->unlock();
}


sub finish
{
    my ($curproc, $args) = @_;

    $curproc->inform_reply_messages();
}


# $article->header_rewrite;
# $article->increment_id;
# $article->spool;
# distribute( $article );
sub _distribute
{
    my ($curproc, $args) = @_;

    # XXX   $ah is "article handler" object.
    # XXX   $ah != $curproc->{ article } (which is just a key)
    # XXX   $curproc->{ article } is prepared as a side effect.
    my $ah = $curproc->_prepare_article($args);

    # get sequence number
    my $id = $ah->increment_id;

    # header operations
    # XXX we need $curproc->{ article }, which is prepared above.
    $curproc->_header_rewrite({ id => $id });

    # spool in the article before delivery
    $ah->spool_in($id);

    # delivery starts !
    $curproc->_deliver_article($args);
}


sub _prepare_article
{
    my ($curproc, $args) = @_;

    # create aritcle to distribute
    use FML::Article;

    # Side Effects: $article->{ curproc } = $curproc;
    return new FML::Article $curproc;
}


sub _header_rewrite
{
    my ($curproc, $args) = @_;

    my $config = $curproc->{ config };
    my $header = $curproc->{ article }->{ header };
    my $rules  = $curproc->{ config }->{ header_rewrite_rules };
    my $id     = $args->{ id };

    for my $rule (split(/\s+/, $rules)) {
	Log("_header_rewrite( $rule )");

	if ($rule eq 'rewrite_subject_tag') {
	    $header->rewrite_subject_tag($config, { id => $id } );
	}

	if ($rule eq 'add_software_info') {
	    $header->add_software_info($config, { id => $id } );
	}

	if ($rule eq 'add_fml_ml_name') {
	    $header->add_fml_ml_name($config, { id => $id } );
	}

	if ($rule eq 'add_fml_article_id') {
	    $header->add_fml_article_id($config, { id => $id } );
	}

	if ($rule eq 'add_x_sequence') {
	    $header->add_x_sequence($config, { 
		name => $config->{ address_for_post },
		id   => $id,
	    });
	}

	if ($rule eq 'add_rfc2369') {
	    $header->add_rfc2369($config, {
		id   => $id,
		mode => 'distribute',
	    });
	}
    }
}


sub _deliver_article
{
    my ($curproc, $args) = @_;

    my $config  = $curproc->{ config };  # FML::Config object
    my $body    = $curproc->{ article }->{ body };  # Netlib::Messages
    my $header  = $curproc->{ article }->{ header };# FML::Header

    # distribute article
    use Netlib::SMTP;
    my $fp  = sub { Log(@_);}; # pointer to the log function
    my $sfp = sub { my ($s) = @_; print $s; print "\n" if $s !~ /\n$/o;};
    my $service = new Netlib::SMTP {
	log_function       => $fp,
	smtp_log_function  => $sfp,
	socket_timeout     => 2,     # XXX 2 for debug but 10 by default
    };
    if ($service->error) { Log($service->error); return;}

    $service->deliver(
		      {
			  'mta'             => $config->{'mta'},

			  'smtp_sender'     => 'rudo',
			  'recipient_maps'  => $config->{recipient_maps},
			  'recipient_limit' => $config->{recipient_limit},

			  'header'          => $header,
			  'body'            => $body,
		      });
    if ($service->error) { Log($service->error); return;}
}



=head1 NAME

distribute -- fml5 article distributer program.

=head1 SYNOPSIS

   distribute [-d] config.cf

=head1 DESCRIPTION

libexec/fml.pl, the wrapper, executes this program. For example, The
incoming mail to elena@fml.org kicks off libexec/distribute via
libexec/fml.pl, whereas mail to elena-ctl@fml.org kicks off
libexec/command finally.

   incoming_mail =>
      elena@fml.org       => fml.pl => libexec/distribute
      elena-ctl@fml.org   => fml.pl => libexec/command
      elena-admin@fml.org => forwarded to administrator(s)
                                  OR
                          => libexec/mead

C<-d>
    debug on.

=head1 FLOW AROUND COMPONENTS

   |  <=> FML::BaseSystem
   |      load configuration files
   |      start logging service
   |
   |  STDIN                     => FML::Parse
   |  $CurProc->{'incoming_mail'} <=
   |  $CurProc->{'credential'}
   | 
   |  (lock)
   |  prepare article
   |  $CurProc->{'article'} is spooled in.
   |  $CurProc->{'article'}    <=> Service::SMTP
   |  (unlock)
   V

=cut

1;
