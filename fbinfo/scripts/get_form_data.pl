#!/usr/bin/perl -w

use DBI;
use DBD::Pg;
use CGI;
use strict;
use Data::Dumper;
my $cgi = CGI->new;
print $cgi->header();

sub get_form_data {
	my %form;
	my $buffer = "";

	if ($ENV{'REQUEST_METHOD'} eq 'GET') {
		$buffer = $ENV{'QUERY_STRING'};
	}
	else {
		read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
	}

	foreach (split(/&/, $buffer)) {
		my($key, $value) = split(/=/, $_);
        	$key   = decodeURL($key);
        	$value = decodeURL($value);
        	$form{$key} = $value;
	}
	%form;
}

sub decodeURL {
	$_ = shift;
	tr/+/ /;
	s/%(..)/pack('c', hex($1))/eg;
	return($_);
}

sub get_form_property {
	my($key, $value);
	my %temp = get_form_data();
	while (($key, $value)= each( %temp )) {
		if ($key eq "@_") {
			return $value;
		}
	}
}

sub db_connect {
        DBI->connect("DBI:Pg:dbname=perl;host=localhost", "kosyo", "123456", {'RaiseError' => 1});
}

my $uid = get_form_property('uid');
my $db = db_connect();
$db->prepare("INSERT INTO addresses (address, uid) VALUES ('" . get_form_property('address') . "', " . $uid . ")")->execute();
$db->prepare("INSERT INTO birthdays (birthday, uid) VALUES ('" . get_form_property('birthday') . "', " . $uid . ")")->execute();

$db->disconnect();

print "Your info has been saved!";
