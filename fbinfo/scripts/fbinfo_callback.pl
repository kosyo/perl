#!/usr/bin/perl -w

use DBI;
use DBD::Pg;
use CGI;
use strict;
use Net::Facebook::Oauth2;

my $cgi = CGI->new;
print $cgi->header();

sub fb_get_info {
	my $app_secret = '4b8b3ced7f75401c4f4d7274546fcc2e';
	my $app_id = '304631152969790';
	my $call_back = 'http://localhost/perl/fbinfo/scripts/fbinfo_callback.pl';

	my $fb = Net::Facebook::Oauth2->new(
        	application_id => $app_id,
   		application_secret => $app_secret,
        	callback => $call_back
	);

	my $access_token = $fb->get_access_token(code => $cgi->param('code'));

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
        open(SQL,"@_");
        while(my $sql_statement = <SQL>) {
                my $sth = db_connect->prepare($sql_statement)
                        or die (qq(Cant prepare $sql_statement));
                $sth->execute()
                        or die qq(Cant execute $sql_statement);
        }
}

exec_sql_file("../sql/create_tables.sql");
exec_sql_file("../sql/inser_fb_info.sql");
