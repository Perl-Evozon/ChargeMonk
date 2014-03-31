package Chargemonk::Test::Mechanize;

=head1 NAME

Test::Chargemonk

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

use Chargemonk;
use Chargemonk::Schema;


has '_app' => (
    is      => 'rw',
    isa     => 'Chargemonk',
    default => sub { Chargemonk->new() },
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

    try {
        my $conn_info = $self->_app->model('Chargemonk')->schema->storage->_connect_info->[0];
        $conn_info->{dsn} =~ s/database=(.*);/"database=".Chargemonk->config->{tests_db}.";"/ge;
        
        my $test_schema = Chargemonk::Schema->connect($conn_info);
        $test_schema->deploy({ add_drop_table => 1 });
        $self->_app->model('Chargemonk')->schema($test_schema);

        $self->_app->model('Chargemonk')->schema->storage->dbh_do(
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
    }
    catch {
        warn "Error deploying the test db: $_";
    };

    
    $self->_app->model('Chargemonk::User')->find_or_create(
        {   email     => '___test_admin',
            password  => '___test_admin',
            firstname => 'Test',
            lastname  => 'Admin',
            user_type => 'ADMIN',
        }
    );

    $self->_app->model('Chargemonk::User')->find_or_create(
        {   email     => '___test_user',
            password  => '___test_user',
            firstname => 'Test',
            lastname  => 'Customer',
            user_type => 'CUSTOMER',
        }
    );

    $self->_app->model('Chargemonk::SubscriptionGroup')->find_or_create( {name => '__test'} );
}


sub _cleanup {
    
    my $app = Chargemonk->new();

    foreach my $obj ( $app->model('Chargemonk::User')->search( {email => {'LIKE', '___test_%'}} )->all() ) {
        $obj->delete();
    }

    # Delete the features
    my $test_features = $app->model('Chargemonk::Feature')->search( {name => {'LIKE', '__test%'}} );
    while ( my $feature = $test_features->next() ) {
        $feature->delete();
    }

    # Delete the test subscriptions
    my $test_subscriptions =
        $app->model('Chargemonk::Subscription')->search( {name => {'LIKE', '___test_subscription%'}} );
    while ( my $subscription = $test_subscriptions->next() ) {
        $subscription->delete();
    }

    my $test_groups =
        $app->model('Chargemonk::SubscriptionGroup')->search( {name => {'LIKE', '__test%'}} );
    while ( my $group = $test_groups->next() ) {
        $group->delete();
    }

    # Delete the test users
    my $test_users =
        $app->model('Chargemonk::User')->search( {email => {'LIKE', '___test_email%'}} );
    while ( my $user = $test_users->next() ) {
        $user->delete();
    }

    # Delete the test campaigns and discount codes
    my $test_campaigns =
        $app->model('Chargemonk::Campaign')->search( {name => {'LIKE', '___test%'}} );
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
