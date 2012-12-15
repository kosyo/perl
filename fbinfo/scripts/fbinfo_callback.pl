#!/usr/bin/perl -w

use DBI;
use DBD::Pg;
use CGI;
use CGI::Session;
use strict;
use Net::Facebook::Oauth2;
use Data::Dumper;
my $q = CGI->new;
print $q->header();
sub acctoken_session {
	(my $acctoken) = @_;
	my $sid = $q->cookie('acctok2') || $q->param('acctok2') || undef;
	my $session = new CGI::Session("driver:File", $sid, {Directory=>'/tmp'});
	if (!$sid) {
		my $cookie = $q->cookie('acctok2' => $session->id);
		print $q->header( -cookie => $cookie );
	}

	if ($session->param("acctoken")) {
		return $_;
	} else {
		$session->param("acctoken", $acctoken);
	}
	$session->param("acctoken");
}

sub have_acctoken_session {
	$q->cookie('acctok2') || $q->param('acctok2') || undef;
}

sub fb_get_info {
	my $app_secret = '4b8b3ced7f75401c4f4d7274546fcc2e';
	my $app_id = '304631152969790';
	my $call_back = 'http://77.85.27.24/perl/fbinfo/scripts/fbinfo_callback.pl';

	my $fb = Net::Facebook::Oauth2->new(
        	application_id => $app_id,
   		application_secret => $app_secret,
        	callback => $call_back
	);
	my $access_token;
	
	if (have_acctoken_session()) {
#		print "ima";
		$access_token = acctoken_session();
	} else {
#		print "nqma";
		$access_token = $fb->get_access_token(code => $q->param('code'));
		acctoken_session($access_token);
	}
#	print $access_token;

	$fb = Net::Facebook::Oauth2->new(
        	access_token => $access_token
	);
	my $info = $fb->get(
        	'https://graph.facebook.com/me' ##Facebook API URL
	);
	$info->as_hash->{"@_"};
}
																										
sub db_connect {
        DBI->connect("DBI:Pg:dbname=perl;host=localhost", "kosyo", "123456", {'RaiseError' => 1});
}

sub exec_sql_file {
	my $dbc = db_connect();
        open(SQL,"@_");
        while(<SQL>) {
                $dbc->prepare($_)->execute();
        }
	$dbc->disconnect;
}
#exec_sql_file("../sql/create_tables.sql");

my $dbc = db_connect();
my $fuid =  fb_get_info('id');
print $fuid . ":ds";
my $db_fuid = $dbc->prepare("SELECT fuid FROM fuids WHERE fuids.fuid = '" . $fuid . "'");
$db_fuid->execute();
print Dumper $db_fuid;
if (!$db_fuid->fetch()) {
	print "true";
	$dbc->prepare("INSERT INTO fuids (fuid) VALUES (" . $fuid . ")")->execute();
}
$db_fuid->finish();
$dbc->disconnect();
