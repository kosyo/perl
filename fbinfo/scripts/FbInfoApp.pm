package FbInfoApp;
use strict;

use DBI;
use DBD::Pg;
use CGI;
use Net::Facebook::Oauth2;
use HTML::Template;

sub FbGetInfo {
	my ($q) = @_;
	my $app_secret = '4b8b3ced7f75401c4f4d7274546fcc2e';
	my $app_id = '304631152969790';
	my $call_back = 'http://77.85.27.24/perl/fbinfo/scripts/fbinfo.pl';

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
	my ($dbname, $host, $user, $pass) = @_;
        DBI->connect("DBI:Pg:dbname=$dbname;host=$host", $user, $pass, {'RaiseError' => 1});
}

sub InsertFbInfoInDb {
	my ($dbh, $fb_info) = @_;

	my $user = $dbh->prepare("INSERT 
		       INTO fb_users (fbuid, name, username, gender, locale) 
		       VALUES (?, ?, ?, ?, ?)");
	$user->execute($$fb_info{id}, $$fb_info{name}, $$fb_info{username}, $$fb_info{gender}, $$fb_info{locale});
	my $db_id = $dbh->prepare("SELECT id 
				FROM fb_users F 
				WHERE F.fbuid = ?");
        $db_id->execute($$fb_info{id});	
	$db_id = $db_id->fetchrow_hashref()->{id};
	$db_id;
}

sub LoadHtml {
	my ($dbh, $db_id, $is_saved_user) = @_;
	my $db_info = $dbh->prepare("SELECT * FROM fb_users F
			     WHERE F.id = ?"); 
	$db_info->execute($db_id); 
	$db_info = $db_info->fetchrow_hashref();

	my $saved_user = HTML::Template->new(filename => '../html/saved_user.html');
	my $unsaved_user = HTML::Template->new(filename => '../html/unsaved_user.html');
	if (!$is_saved_user) {
		$unsaved_user->param('id' => $db_id);
		print $unsaved_user->output;
	} else {
		$saved_user->param('name' => $$db_info{name});
		$saved_user->param('locale' => $$db_info{locale});
		$saved_user->param('address' => $$db_info{address});
		$saved_user->param('birthday' => $$db_info{birthday});
		$saved_user->param('fbuid' => $$db_info{fbuid});
		$saved_user->param('gender' => $$db_info{gender});
		$saved_user->param('username' => $$db_info{username});
		print $saved_user->output;
	}
}

sub GetDbId {
	my ($dbh, $fbuid) = @_;
	my $db_id = $dbh->prepare("SELECT id 
				FROM fb_users F 
				WHERE F.fbuid = ?");
	$db_id->execute($fbuid);
	$db_id = $db_id->fetchrow_hashref()->{id};
	$db_id;
}

sub IsSavedUser {
	my ($dbh, $fbuid) = @_;
	my $db_fbuid = $dbh->prepare("SELECT fbuid 
				     FROM fb_users F 
				     WHERE F.fbuid = ?");
	$db_fbuid->execute($fbuid);
	$db_fbuid->fetch();
}

sub GetFormData {
	my ($q) = @_;
	print $q->header();

	my $params = $q->Vars;
	my $id = $params->{id};
	my $dbh = DbConnect("perl", "localhost", "kosyo", "123456");
	my $address = $dbh->prepare("UPDATE fb_users F SET 
		       address = ? WHERE F.id = ?");
	$address->execute($$params{address}, $id);
	my $birthday = $dbh->prepare("UPDATE fb_users F SET
		       birthday = ? WHERE F.id = ?");
	$birthday->execute($$params{birthday}, $id);

	$dbh->disconnect();

	print "Your info has been saved!";
}

sub FacebookAuth {
	my ($q) = @_;
	my $app_secret = '4b8b3ced7f75401c4f4d7274546fcc2e';
	my $app_id = '304631152969790';
	my $call_back = 'http://77.85.27.24/perl/fbinfo/scripts/fbinfo.pl';

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
	my $q = CGI->new;
	if ($q->param('code')) {
		print $q->header();

		my $dbh = DbConnect("perl", "localhost", "kosyo", "123456");
		my $fb_info = FbGetInfo($q);
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
	} elsif ($q->param('address')) {
		GetFormData($q);
	} else {
		FacebookAuth($q);
	}
}

1;
