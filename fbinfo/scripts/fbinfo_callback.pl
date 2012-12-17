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

sub fb_get_info {
	my $app_secret = '4b8b3ced7f75401c4f4d7274546fcc2e';
	my $app_id = '304631152969790';
	my $call_back = 'http://77.85.27.24/perl/fbinfo/scripts/fbinfo_callback.pl';

	my $fb = Net::Facebook::Oauth2->new(
		application_id => $app_id,
   		application_secret => $app_secret,
        	callback => $call_back
	);
	
	my $access_token = $fb->get_access_token(code => $q->param('code'));
	
	$fb = Net::Facebook::Oauth2->new(
        	access_token => $access_token
	);
	my $info = $fb->get(
        	'https://graph.facebook.com/me'
	);
	$info->as_hash;
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
my $fb_info = fb_get_info();
my $fuid =  $fb_info->{id};
my $db_fuid = $dbc->prepare("SELECT fuid FROM fuids WHERE fuids.fuid = '" . $fuid . "'");
$db_fuid->execute();
my $saved_user=$db_fuid->fetch();
my $db_id;

if (!$saved_user) {
	$dbc->prepare("INSERT INTO fuids (fuid) VALUES (" . $fuid . ")")->execute();
	$db_id = $dbc->prepare("SELECT id FROM fuids WHERE fuids.fuid = '" . $fuid . "'");
        $db_id->execute();	
	$db_id = $db_id->fetchrow_hashref()->{'id'};

	$dbc->prepare("INSERT INTO names (name, uid) VALUES ('" . $fb_info->{'name'} . "', " . $db_id . ")")->execute();
	$dbc->prepare("INSERT INTO genders (gender, uid) VALUES ('" . $fb_info->{'gender'} . "', " . $db_id . ")")->execute();
	$dbc->prepare("INSERT INTO locales (locale, uid) VALUES ('" . $fb_info->{'locale'} . "', " . $db_id . ")")->execute();
	$dbc->prepare("INSERT INTO usernames (username, uid) VALUES ('" . $fb_info->{'username'} . "', " . $db_id . ")")->execute();
}
my $db_info = $dbc->prepare("SELECT * FROM fuids, names, genders, addresses, birthdays, locales, usernames WHERE fuids.fuid = '" . $fuid . "'");
$db_info->execute();
$db_info = $db_info->fetchrow_hashref();
$db_fuid->finish();
$dbc->disconnect();
if (!$saved_user) {
print '
<HTML>
<HEAD>
<TITLE>Fbinfo app</TITLE>
</HEAD>
<BODY>
<FORM name = "info_form method = "post" action = "get_form_data.pl">
<INPUT type = "hidden" name = "uid" value="' . $db_id . '"> 
Address:
<INPUT type = "text" name = "address">
<BR>
Birthday:
<INPUT type = "text" name = "birthday">
<INPUT type = "submit" name ="subbtn" value="Submit">
</FORM>
</BODY>
</HTML>
';
} else {
print '
<HTML>
<HEAD>
<TITLE>Fbinfo app</TITLE>
</HEAD>
<BODY>
Your info is: <BR>' . 
"Name: " . $db_info->{'name'} . "<BR>Locale: " . $db_info->{'locale'} . "<BR>Address: " . $db_info->{'address'} . "<BR>Birthday: " . $db_info->{'birthday'} . "<BR>ID: " . $db_info->{'fuid'} . "<BR>Gender: " . $db_info->{'gender'} . "<BR>Username: " . $db_info->{'username'} . '</BODY>
</HTML>
';
}


