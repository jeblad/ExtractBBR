#!/usr/bin/perl

use utf8;
use Getopt::Args;
use URI;
use WWW::REST;
use JSON;

opt language => (
	isa => 'Str',
	alias => 'l',
	comment => 'the language for the dataset, usually an established IANA code',
);

opt code => (
	isa => 'Str',
	alias => 'n',
	comment => 'limit the request to given municipality code',
);

opt error => (
	isa => 'Str',
	alias => 'e',
	comment => 'the error file, if missing use STDERR',
);

opt output => (
	isa => 'Str',
	alias => 'o',
	comment => 'the output file, if missing use STDOUT',
);

opt endpoint => (
	isa => 'Str',
	alias => 'ep',
	default => 'https://services.datafordeler.dk//BBR/BBRPublic/1/REST/bygning',
	comment => 'the endpoint of the service',
);

arg user => (
	isa => 'Str',
	required => 1,
	comment => 'the username, usually a service name',
);

arg pass => (
	isa => 'Str',
	required => 1,
	comment => 'the password for the given username',
);

opt size => (
	isa => 'Int',
	default => 10000,
	comment => 'the page size',
);

opt format => (
	isa => 'Str',
	default => 'JSON',
	comment => 'the format from the server',
);

my $oa = optargs;

if ($oa->{error}) {
	open STDERR, ">", $oa->{error} or die "$0: open: $!";
}
binmode(STDERR, ":utf8");
STDERR->autoflush(1);

if ($oa->{output}) {
	open STDOUT, ">", $oa->{output} or die "$0: open: $!";
}
binmode(STDOUT, ":utf8");
STDOUT->autoflush(1);

my $page = 0;
my $entries = 0;

my %query = (
	#municipalities are missing
	username => $oa->{user},
	password => $oa->{pass},
	pagesize => $oa->{size},
	format => $oa->{format},
);

if ($oa->{code}) {
	$query{KommuneKode} = $oa->{code};
}

my $rest = WWW::REST->new($oa->{endpoint});

$rest->dispatch( sub {
	my $self = shift;
	warn $query{page} . "\n";
	warn "page: " . $page . "\n";
	#die $self->status_line if $self->is_error;
	if ($self->is_error) {
		warn $self->status_line . "\n";
		return 1;
	}
	return 1 if $self->is_error;
	my $parser = JSON->new;
	my $json = $parser->decode($self->content);
	warn "scalar: ". scalar(@{$json}) . "\n";

	foreach my $entry (@{$json}) {
		$entries++;
		#print to_json($entry, {utf8 => 1});
	}

	warn $oa->{size} . "<" . scalar(@{$json}) . "\n";
	warn to_json($json->[0], {utf8 => 1}) ."\n";

	return $oa->{size}>scalar(@{$json});
} );

do { $query{page} = ++$page; } until $rest->get(%query);

$rest->delete;

warn "Num pages: " . $page . "\n";
warn "Num entries: " . $entries . "\n";

exit
