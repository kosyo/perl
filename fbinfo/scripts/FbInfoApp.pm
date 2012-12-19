package FbInfoApp;

use DBI;
use DBD::Pg;
use CGI;
use strict;
use Net::Facebook::Oauth2;
use HTML::Template;
my $q = CGI->new;

sub FbGetInfo {
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
																										
sub DbConnect {
        DBI->connect("DBI:Pg:dbname=perl;host=localhost", "kosyo", "123456", {'RaiseError' => 1});
}

sub InsertFbInfoInDb {
	(my $dbh, my $fb_info) = @_;

	$dbh->prepare("INSERT 
		       INTO fuids (fuid) 
		       VALUES (?)")->execute($$fb_info{id});
	my $db_id = $dbh->prepare("SELECT id 
				FROM fuids F 
				WHERE F.fuid = ?");
        $db_id->execute($$fb_info{id});	
	$db_id = $db_id->fetchrow_hashref()->{id};
	$dbh->prepare("INSERT 
		       INTO names (name, uid) 
		       VALUES (?, ?)")->execute($$fb_info{name}, $db_id);
	$dbh->prepare("INSERT 
		       INTO genders (gender, uid) 
                       VALUES (?, ?)")->execute($$fb_info{gender}, $db_id);
	$dbh->prepare("INSERT 
		       INTO locales (locale, uid) 
		       VALUES (?, ?)")->execute($$fb_info{locale}, $db_id);
	$dbh->prepare("INSERT 
		       INTO usernames (username, uid) 
		       VALUES (?, ?)")->execute($$fb_info{username}, $db_id);
	$db_id;
}

sub LoadHtml {
	(my $dbh, my $db_id, my $is_saved_user) = @_;
	my $db_info = $dbh->prepare("SELECT * FROM fuids F, names N, birthdays B, locales L, addresses A, genders G, usernames U 
			     WHERE F.id = N.uid 
			     AND F.id = B.uid 
			     AND F.id = L.uid 
			     AND F.id = A.uid 
                             AND F.id = G.uid 
			     AND F.id = U.uid 
			     AND F.id = ?");
	$db_info->execute($db_id); 
	$db_info = $db_info->fetchrow_hashref();

	my $saved_user = HTML::Template->new(filename => '../html/saved_user.html');
	my $unsaved_user = HTML::Template->new(filename => '../html/unsaved_user.html');
	if (!$is_saved_user) {
		$unsaved_user->param('$db_id' => $db_id);
		print $unsaved_user->output;
	} else {
		$saved_user->param('$$db_info{name}' => $$db_info{name});
		$saved_user->param('$$db_info{locale}' => $$db_info{locale});
		$saved_user->param('$$db_info{address}' => $$db_info{address});
		$saved_user->param('$$db_info{birthday}' => $$db_info{birthday});
		$saved_user->param('$$db_info{fuid}' => $$db_info{fuid});
		$saved_user->param('$$db_info{gender}' => $$db_info{gender});
		$saved_user->param('$$db_info{username}' => $$db_info{username});
		print $saved_user->output;
	}
}

sub GetDbId {
	(my $dbh, my $fuid) = @_;
	my $db_id = $dbh->prepare("SELECT id 
				FROM fuids F 
				WHERE F.fuid = ?");
	$db_id->execute($fuid);
	$db_id = $db_id->fetchrow_hashref()->{id};
	$db_id;
}

sub IsSavedUser {
	(my $dbh, my $fuid) = @_;
	my $db_fuid = $dbh->prepare("SELECT fuid 
				     FROM fuids F 
				     WHERE F.fuid = ?");
	$db_fuid->execute($fuid);
	$db_fuid->fetch();
}

sub GetFormData {
	print $q->header();

	my $params = $q->Vars;
	my $uid = $params->{uid};
	my $dbh = DbConnect();
	$dbh->prepare("INSERT 
		       INTO addresses (address, uid) 
		       VALUES (?, ?)")->execute($$params{address}, $uid);
	$dbh->prepare("INSERT 
		       INTO birthdays (birthday, uid) 
		       VALUES (?, ?)")->execute($$params{birthday}, $uid);

	$dbh->disconnect();

	print "Your info has been saved!";
}

sub FacebookAuth {
	my $app_secret = '4b8b3ced7f75401c4f4d7274546fcc2e';
	my $app_id = '304631152969790';
	my $call_back = 'http://77.85.27.24/perl/fbinfo/scripts/fbinfo_callback.pl';

	my $fb = Net::Facebook::Oauth2->new(
		application_id => $app_id, 
		application_secret => $app_secret,
		callback => $call_back
	);
	    
	my $url = $fb->get_authorization_url(
		scope => ['offline_access','publish_stream'],
		display => 'page'
	);

	print $q->redirect($url);
}
sub Start {
	print $q->header();

	my $dbh = DbConnect();
	my $fb_info = FbGetInfo();
	my $fuid =  $$fb_info{id};
	my $is_saved_user=IsSavedUser($dbh,$fuid);
	my $db_id;

	if (!$is_saved_user) {
		$db_id = InsertFbInfoInDb($dbh, $fb_info);
	} else {
		$db_id = GetDbId($dbh, $fuid);
	}

	LoadHtml($dbh, $db_id, $is_saved_user);
	$dbh->disconnect();
}

1;
