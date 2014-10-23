use Test::Roo;
use DBI;
use Path::Tiny;

has tempdir => (
    is      => 'ro',
    clearer => 1,
    default => sub { Path::Tiny->tempdir },
);

has dbfile => (
    is      => 'lazy',
    default => sub { shift->tempdir->child('test.sqlite3') },
);

has dbh => ( is => 'lazy', );

sub _build_dbh {
    my $self = shift;
    DBI->connect(
        "dbi:SQLite:dbname=" . $self->dbfile, { RaiseError => 1 }
    );
}

before 'setup' => sub {
    my $self = shift;
    ok( ! -f $self->dbfile, "test database file not created" );
    ok( $self->dbh->do("CREATE TABLE f (f1, f2, f3)"), "created table");
    ok( -f $self->dbfile, "test database file exists" );
};

after 'teardown' => sub {
    my $self = shift;
    my $dir = $self->tempdir;
    $self->clear_tempdir;
    ok( ! -f $dir, "tempdir cleaned up");
};

test 'first' => sub {
    my $self = shift;
    my $dbh  = $self->dbh;
    my $sth  = $dbh->prepare("INSERT INTO f(f1,f2,f3) VALUES (?,?,?)");
    ok( $sth->execute( "one", "two", "three" ), "inserted data" );

    my $got = $dbh->selectrow_arrayref("SELECT * FROM f");
    is_deeply( $got, [qw/one two three/], "read data" );
};

run_me;
done_testing;
