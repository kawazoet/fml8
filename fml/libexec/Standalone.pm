#-*- perl -*-
#
#  Copyright (C) 2001 Ken'ichi Fukamachi
#   All rights reserved. This program is free software; you can
#   redistribute it and/or modify it under the same terms as Perl itself. 
#
# $Id$
# $FML$
#


package Standalone;

use strict;
use Carp;

# Descriptions: load "key = value" style configuration.
#               It is available to use the following style.
#                    key = value1 value2
#                          value3
#               XXX This file is non-Object Oriented style but 
#               XXX this is minimum module used in standalone program.
#    Arguments: $file $params
#               $params is 'key1=value1 key2=value2' syntax.
# Side Effects: $config (hash reference) is allocated on memory here.
# Return Value: hash reference to configuration parameters
sub load_cf
{
    my ($file, $params) = @_;
    my $config = $params ? _parse_params($params) : {};

    use FileHandle;
    my $fh = new FileHandle $file;

    if (defined $fh) {
	my $curkey;
	while (<$fh>) {
	    next if /^\#/;
	    chop;

	    if (/^([A-Za-z]\w+)\s+=\s*(.*)/) {
		my ($key, $value) = ($1, $2);
		$curkey           = $key;
		$config->{$key}   = $value;
	    }
	    if (/^\s+(.*)/) {
		$config->{ $curkey }  .= " ". $1;
	    }
	}
	$fh->close;
    }
    else {
	croak("Error: cannot open $file");
    }

    _expand_variables( $config );
    return $config;
}


# Descriptions: expand $var to the value of $var.
#    Arguments: $ref_to_config
# Side Effects: rewrite the given $config 
# Return Value: none
sub _expand_variables
{
    my ($config) = @_;

    # expand $xxx style variables
    no strict 'refs';
    for my $x (keys %$config) { $$x = $config->{ $x };}
    for (keys %$config) {
	$config->{ $_ } =~ s/\$([a-z_]+)/${$1}/g;
    }
}



sub _parse_params
{
    my ($params) = @_;
    my %config = ();

    for my $x (split(/\s+/, $params)) {
	my ($key, $value) = split(/=/, $x);
	$config{ $key } = $value;
    }

    \%config;
}


1;
