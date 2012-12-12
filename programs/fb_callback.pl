#!/usr/bin/perl -w

use CGI;
use strict;
my $cgi = CGI->new;
print $cgi->header();  
use Net::Facebook::Oauth2;

my $app_secret = '4b8b3ced7f75401c4f4d7274546fcc2e';
my $app_id = '304631152969790';
my $call_back = 'http://77.85.27.24/perl/fb_callback.pl';
    
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
	   
print $info->as_json;
