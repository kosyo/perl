#!/usr/bin/perl -w

use CGI;
use strict;
my $cgi = CGI->new;
use Net::Facebook::Oauth2;

my $app_secret = '4b8b3ced7f75401c4f4d7274546fcc2e';
my $app_id = '304631152969790';
my $call_back = 'http://localhost/perl/fbinfo/scripts/fbinfo_callback.pl';

my $fb = Net::Facebook::Oauth2->new(
	application_id => $app_id, 
        application_secret => $app_secret,
        callback => $call_back
);
    
my $url = $fb->get_authorization_url(
	scope => ['offline_access','publish_stream'],
        display => 'page'
);

print $cgi->redirect($url);
