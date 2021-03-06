#-*- perl -*-
#
#  Copyright (C) 2001,2002,2003,2004,2005,2006 Ken'ichi Fukamachi
#   All rights reserved. This program is free software; you can
#   redistribute it and/or modify it under the same terms as Perl itself.
#
# $FML: summary.pm,v 1.22 2006/03/04 13:48:29 fukachan Exp $
#

package FML::Command::User::summary;
use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK $AUTOLOAD);
use Carp;

use FML::Command::SendFile;
@ISA = qw(FML::Command::SendFile);


=head1 NAME

FML::Command::User::summary - send back ML's summary file.

=head1 SYNOPSIS

See C<FML::Command> for more details.

=head1 DESCRIPTION

send back summary file.

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
sub lock_channel { return 'article_spool_modify';}


# Descriptions: send summary file by FML::Command::SendFile.
#    Arguments: OBJ($self) OBJ($curproc) OBJ($command_context)
# Side Effects: none
# Return Value: none
sub process
{
    my ($self, $curproc, $command_context) = @_;
    my $config               = $curproc->config();
    my $article_summary_file = $config->{ "article_summary_file" };

    if (-f $article_summary_file) {
	# XXX-TODO: method-fiy
	$command_context->{ _filepath_to_send } = $article_summary_file;
	$self->send_file($curproc, $command_context);
	delete $command_context->{ _filepath_to_send };
    }
    else {
	$curproc->reply_message_nl('error.no_such_file',
				   'summary not found',
				   {
				       _arg_file => 'summary',
				   });
    }
}


=head1 CODING STYLE

See C<http://www.fml.org/software/FNF/> on fml coding style guide.

=head1 AUTHOR

Ken'ichi Fukamachi

=head1 COPYRIGHT

Copyright (C) 2001,2002,2003,2004,2005,2006 Ken'ichi Fukamachi

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

=head1 HISTORY

FML::Command::User::summary first appeared in fml8 mailing list driver package.
See C<http://www.fml.org/> for more details.

=cut


1;
