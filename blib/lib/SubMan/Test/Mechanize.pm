package SubMan::Test::Mechanize;

=head1 NAME

Test::SubMan

=cut

=head1 SYNOPSIS

Extension of the Test::WWW::Mechanize::Catalyst module

Add initial testing data and cleanup at the end

=cut

use base qw(Test::WWW::Mechanize::Catalyst);

use Data::Dumper;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Moose;
use Try::Tiny;

use SubMan;
use SubMan::Schema;


has '_app' => (
    is      => 'rw',
    isa     => 'SubMan',
    default => sub { SubMan->new() },
);

=head2 new()

Constructor

=cut

sub new {
    my $class = shift;

    my $self = $class->SUPER::new(@_);

    $self->_init();

    return $self;
}

=head2 new()

Initialize testing data

Admin and standard users

=cut

sub _init {
    my $self = shift;

=head Run the tests on different db
    try {
        $self->_app->model('SubMan::User')->result_source->schema->storage->dbh_do(
            sub {
                my ( $storage, $dbh, @args ) = @_;
                $dbh->do("DROP DATABASE IF EXISTS subman_test")
                    ;    # drop and create cannon be run within a single sql command, in psql
                $dbh->do("CREATE DATABASE subman_test");
            },
        );
    }
    catch {
        warn "Error creating test database: $_";
    };

    try {
        #my $test_schema = SubMan::Schema->connect(
        #    'dbi:Pg:dbname=subman_test;host=' . SubMan->config->{db_host},
        #    SubMan->config->{db_user},
        #    SubMan->config->{db_password},
        #    {PGOPTIONS => "-c search_path=public", quote_names => 1, show_warnings => 0},
        #);
        my $test_schema = SubMan::Schema->connect(
            'DBI:mysql:database=subman;host=' . SubMan->config->{db_host},
            SubMan->config->{db_user},
            SubMan->config->{db_password},
        );

        $test_schema->deploy();
        
        #switch to the new schema
        $self->_app->model('SubMan')->schema($test_schema);
    }
    catch {
        warn "Error connecting to the test database: $_";
    };

    try {
        $self->_app->model('SubMan::User')->result_source->schema->storage->dbh_do(
            sub {
                my ( $storage, $dbh, @args ) = @_;
        
                # run the db init sql script
                open( SQL, "$FindBin::Bin/../db/init_data.sql" );
                local $/ = ';';
                while ( my $sql_statement = <SQL> ) {
                    eval { $dbh->do($sql_statement); };
                    #warn "$sql_statement: " . $@ if ($@);
                }
            },
        );
    } catch {
        warn "Error running the init db: $_";
    };

    warn "==============================cols:" . Dumper( $self->_app->model('SubMan::User')->count() );
=cut
    
    $self->_app->model('SubMan::User')->find_or_create(
        {   email     => '___test_admin',
            password  => '___test_admin',
            firstname => 'Test',
            lastname  => 'Admin',
            user_type => 'ADMIN',
        }
    );

    $self->_app->model('SubMan::User')->find_or_create(
        {   email     => '___test_user',
            password  => '___test_user',
            firstname => 'Test',
            lastname  => 'Customer',
            user_type => 'CUSTOMER',
        }
    );

    $self->_app->model('SubMan::SubscriptionGroup')->find_or_create( {name => '__test'} );
}


sub _cleanup {
    #return;
    
    my $app = SubMan->new();

    foreach my $obj ( $app->model('SubMan::User')->search( {email => {'LIKE', '___test_%'}} )->all() ) {
        $obj->delete();
    }

    # Delete the features
    my $test_features = $app->model('SubMan::Feature')->search( {name => {'LIKE', '__test%'}} );
    while ( my $feature = $test_features->next() ) {
        $feature->delete();
    }

    # Delete the test subscriptions
    my $test_subscriptions =
        $app->model('SubMan::Subscription')->search( {name => {'LIKE', '___test_subscription%'}} );
    while ( my $subscription = $test_subscriptions->next() ) {
        $subscription->delete();
    }

    my $test_groups =
        $app->model('SubMan::SubscriptionGroup')->search( {name => {'LIKE', '__test%'}} );
    while ( my $group = $test_groups->next() ) {
        $group->delete();
    }

    # Delete the test users
    my $test_users =
        $app->model('SubMan::User')->search( {email => {'LIKE', '___test_email%'}} );
    while ( my $user = $test_users->next() ) {
        $user->delete();
    }

    # Delete the test campaigns and discount codes
    my $test_campaigns =
        $app->model('SubMan::Campaign')->search( {name => {'LIKE', '___test%'}} );
    while ( my $camp = $test_campaigns->next() ) {
        $camp->delete();
    }
}


=head2 END

    doing the cleanup here

=cut

END {
    _cleanup();
}

1;
