#-*- perl -*-
#
#  Copyright (C) 2001 Ken'ichi Fukamachi
#   All rights reserved. This program is free software; you can
#   redistribute it and/or modify it under the same terms as Perl itself. 
#
# $Id$
# $FML: Article.pm,v 1.20 2001/04/07 06:41:31 fukachan Exp $
#

package FML::Article;

use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK);
use Carp;
use FML::Log qw(Log LogWarn LogError);


=head1 NAME

FML::Article - article manipulation components

=head1 SYNOPSIS

   use FML::Article;
   $article = new FML::Article $curproc;
   $header  = $article->{ header };
   $body    = $article->{ body };

=head1 DESCRIPTION

$article object is just a container which holds 
C<header> and C<body> object as hash keys.
The C<header> is an FML::Header object and
the C<body> is a Mail::Message object.

=head1 METHODS

=head2 C<new(curproc)>

prepare a message duplicated from the incoming message holded in
C<$curproc->{ incoming_message }>.

=cut


# Descriptions: constructor
#    Arguments: $self $curproc
# Side Effects: none
# Return Value: FML::Article object
sub new
{
    my ($self, $curproc) = @_;
    my ($type) = ref($self) || $self;
    my $me     = {};

    _setup_article_template($curproc);
    $me->{ curproc } = $curproc;

    return bless $me, $type;
}


# Descriptions: prepare article template to distribute
#    Arguments: $self $curproc
# Side Effects: build $curproc->{ article }
# Return Value: none
sub _setup_article_template
{
    my ($curproc) = @_;

    # create an article template by duplicating the incoming message
    my $dupmsg  = $curproc->{'incoming_message'}->{ message }->dup_header;
    if (defined $dupmsg) {
	$curproc->{ article }->{ message } = $dupmsg;
	$curproc->{ article }->{ header }  = $dupmsg->rfc822_message_header;
	$curproc->{ article }->{ body }    = $dupmsg->rfc822_message_body;
    }
    else {
	croak("cannot duplicate message");
    }
}


=head2 C<increment_id()>

increment article sequence number and 
save it to C<$sequence_file>.

This routine uses C<File::Sequence> module. 

=head2 C<id()>

return the current article sequence number.

=cut


# Descriptions: determine article id (sequence number)
#    Arguments: $self
# Side Effects: record the current article sequence number
# Return Value: number (sequence identifier)
sub increment_id
{
    my ($self) = @_;
    my $curproc  = $self->{ curproc };
    my $config   = $curproc->{ config };
    my $pcb      = $curproc->{ pcb };
    my $seq_file = $config->{ sequence_file };

    use File::Sequence;
    my $sfh = new File::Sequence { sequence_file => $seq_file };
    my $id  = $sfh->increment_id;
    if ($sfh->error) { Log( $sfh->error ); }

    # save $id in pcb (process control block) and return $id
    $pcb->set('article', 'id', $id);
    $id;
}


# Descriptions: return the article id (sequence number)
#    Arguments: $self
# Side Effects: none
# Return Value: number (sequence number)
sub id
{
    my ($self) = @_;
    my $curproc = $self->{ curproc };    
    my $pcb     = $curproc->{ pcb };
    return $pcb->get('article', 'id');
}


=head2 C<spool_in(id)>

save the article to the file name C<id> in the article spool.
If the variable C<$use_spool> is 'yes', this routine works.

=cut


# Descriptions: spool in the article
#    Arguments: $self $curproc
# Side Effects: 
# Return Value: none
sub spool_in
{
    my ($self, $id) = @_;

    # configurations
    my $curproc   = $self->{ curproc };
    my $config    = $curproc->{ config };
    my $spool_dir = $config->{ spool_dir };

    if ( $config->yes( 'use_spool' ) ) {
	unless (-d $spool_dir) {
	    use File::Path;
	    mkpath( $spool_dir, 0, 0700 );
	}

	my $file = $spool_dir . "/" . $id;
	use FileHandle;
	my $fh = new FileHandle;
	$fh->open($file, "w");
	if (defined $fh) {
	    $curproc->{ article }->{ header }->print($fh);
	    print $fh "\n";
	    $curproc->{ article }->{ body }->print($fh);
	    $fh->close;
	    Log("Article $id");
	}
    }
    else {
	Log("not spool article");
    }
}


=head1 SEE ALSO

L<FML::Header>,
L<MailingList::Messsages>,
L<File::Sequence>

=head1 AUTHOR

Ken'ichi Fukamachi

=head1 COPYRIGHT

Copyright (C) 2001 Ken'ichi Fukamachi

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself. 

=head1 HISTORY

FML::Article appeared in fml5 mailing list driver package.
See C<http://www.fml.org/> for more details.

=cut


1;
