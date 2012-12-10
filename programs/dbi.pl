#!/usr/bin/perl
use strict;
use DBI;
use DBD::Pg;

# connect
my $dbh = DBI->connect("DBI:Pg:dbname=perl;host=localhost", "kosyo", "123456", {'RaiseError' => 1});

# execute INSERT query
my $rows = $dbh->do("INSERT INTO test (id, name) VALUES (1, 'first')");
print "$rows row(s) affected\n";

# execute SELECT query
my $sth = $dbh->prepare("SELECT name FROM test");
$sth->execute();

# iterate through resultset
# print values
while(my $ref = $sth->fetchrow_hashref()) {
    print "$ref->{'name'}\n";
}

# clean up
$dbh->disconnect();
