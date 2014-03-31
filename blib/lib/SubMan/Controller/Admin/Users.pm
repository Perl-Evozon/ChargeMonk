package SubMan::Controller::Admin::Users;

use Config::General;
use DateTime;
use Moose;
use namespace::autoclean;
use String::Random qw(random_regex);
use Try::Tiny;

use SubMan::Helpers::Admin::UserDetails qw(send_set_user_psw_email);

BEGIN { extends 'SubMan::Controller::Authenticated'; }


# Backend validation rules

__PACKAGE__->validation_rules(
    create_user => {
        firstname => ['NotEmpty' => 'Firstname can not be empty'],
        lastname  => ['NotEmpty' => 'Lastname can not be empty'],
        email     => [
            'NotEmpty'   => 'Email can not be empty',
            'Email'      => 'Not a valid email',
            'UniqueUser' => 'Email already registered',
        ],
        admin_user => ['ValidAdmin' => 'User can not be made admin'],
    },
    save_user => {
        firstname  => ['NotEmpty'   => 'Firstname can not be empty'],
        lastname   => ['NotEmpty'   => 'Lastname can not be empty'],
        admin_user => ['ValidAdmin' => 'User can not be made admin'],
    },
);


=head1 NAME

SubMan::Controller::Admin::Users - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 auto

Forward the current subscription actions to the subscription actions controller.

=cut

sub auto : Private {
    my ( $self, $c ) = @_;

    my $subscription_actions_dispatcher = {cancel_subscription => '/common/subscriptionactions/cancel_subscription',};
    foreach ( keys %$subscription_actions_dispatcher ) {
        $c->forward( $subscription_actions_dispatcher->{$_} ) if ( defined $c->req->param($_) );
    }

    return 1;
}


=head2 users

Controller for admin 'Users' search page

=cut

sub users : Path : Args(0) {
    my ( $self, $c ) = @_;

    my @users        = ();
    my $where_clause = {};
    my $params       = $c->req->params;
    my $total_users  = $c->model('SubMan::User')->count();

    # assembling search criteria and where_clause
    # adding search_email_name_phone filter conditions

    my @cols = ( 'search_email_name_phone', 'user_status', 'country',
        'user_type', 'signup_period', 'start_date', 'end_date', );

    my %search_criteria = map { $_ => $params->{$_} } grep { defined $params->{$_} and $params->{$_} } @cols;
    my $conditions = {
        -or => ( $params->{search_email_name_phone} )
        ? [ {email     => {like => "%$params->{search_email_name_phone}%"}},
            {phone     => {like => "%$params->{search_email_name_phone}%"}},
            {firstname => {like => "%$params->{search_email_name_phone}%"}},
            {lastname  => {like => "%$params->{search_email_name_phone}%"}},
            ]
        : '',
        country   => $params->{country},
        user_type => ( ref $params->{user_type} eq 'ARRAY' ) ? [map { uc $_ } @{$params->{user_type}}]
        : uc( $params->{user_type} || '' ),
    };
    $conditions->{signup_date}->{'>='} = $params->{start_date}    if ( $params->{start_date} );
    $conditions->{signup_date}->{'>='} = $params->{signup_period} if ( $params->{signup_period} );
    $conditions->{signup_date}->{'<='} = $params->{end_date}      if ( $params->{end_date} );

    map { $where_clause->{$_} = $conditions->{$_} if ( $conditions->{$_} ) } keys %{$conditions};

    if (%search_criteria) {
        @users = $c->model('SubMan::User')->search_rs($where_clause)->all();
    }
    else {
        @users = $c->model('SubMan::User')->all();
    }

    $c->stash( {users => \@users, search_criteria => \%search_criteria, users_count => $total_users} );
}


=head2 user_details

Controller for admin 'User Details' page

=cut

sub user_details : Local : Args(1) {
    my ( $self, $c ) = @_;

    my $user;
    try {
        $user = $c->model('SubMan::User')->find( $c->req->args->[0] );
    }
    catch {
        my $msg = 'Could not retrieve details for user. Please check logger for more details.';
        $c->alert( {'error' => $msg}, " |user: " . $c->req->args->[0] . " error: " . $_ );
    };

    if ( !$user ) {
        $c->alert( {'error' => 'Could not retrieve information for user.'} );
        $c->go('/admin/users');
        $c->detach();
    }

    if ( defined $c->req->param('resend_set_usr_psw') ) {

        # send email to user to set his password
        SubMan::Helpers::Admin::UserDetails::send_set_user_psw_email( $c, $user->id, $user->email,
            'http://' . $c->req->env->{'HTTP_HOST'} );
    }

    my $current_subscription = $c->model('SubMan::LinkUserSubscription')
        ->search_rs( {user_id => $user->id, active => '1'}, {prefetch => 'subscription'} )->first;

    my $active_subscriptions = $c->model('SubMan::LinkUserSubscription')->search_rs(
        {   user_id => $user->id,
            -or     => [active => '1', cancelled => '0']
        }
    )->count;

    my @billing_history = $c->model('SubMan::LinkUserSubscription')->search_rs(
        {"me.user_id" => $user->id,},
        {   prefetch => ['invoices', 'subscription'],
            order_by => {-desc => 'me.id'}
        }
    )->all;

    my ( $upgrades_to, $downgrades_to, $renew );

    if ($current_subscription) {

        if ( $active_subscriptions < 2 ) {
            $upgrades_to = $c->model('SubMan::SubscriptionUpgradeTo')
                ->search_rs( {'subscription_id' => $current_subscription->subscription->id} )->all;
            $downgrades_to = $c->model('SubMan::SubscriptionDowngradeTo')
                ->search_rs( {'subscription_id' => $current_subscription->subscription->id} )->all;
        }

    }
    elsif ( scalar(@billing_history) ) {
        $renew = 1;
    }

    $c->stash(
        {   user                      => $user,
            current_subscription      => $current_subscription,
            upgrades_to               => $upgrades_to,
            downgrades_to             => $downgrades_to,
            renew                     => $renew,
            billing_history           => \@billing_history,
            period_users_subscription => $user->has_period_users_subscription
            ? $user->has_period_users_subscription
            : 0,
            ip_range_subscription => $user->has_ip_range_subscription ? $user->has_ip_range_subscription : 0,
        }
    );
}


=head2 add_user

Add user controller route

=cut

sub add_user : Local : Args(0) {

}


=head2 create_user

    Create user controller route

=cut

sub create_user : Local : Args(0) : OnError(add_user) {
    my ( $self, $c ) = @_;

    my @cols = qw(
        firstname lastname email address address2 country state zip_code phone gender
        birthday user_type company_name company_address company_country
        company_state company_zip_code company_phone signup_date
    );
    my $user_hash;
    map { $user_hash->{$_} = $c->req->param($_) || undef } @cols;
    $user_hash->{user_type}   = $c->req->param('admin_user') ? 'ADMIN' : 'LEAD';
    $user_hash->{signup_date} = DateTime->today->date;
    $user_hash->{password}    = random_regex('.{18}');

    try {
        my $user = $c->model('SubMan::User')->create($user_hash);
        $c->logger->error("aaaaaaici2");
        # save photo on disk
        $c->forward( '/common/user/_save_photo', [$user] ) if ( $c->req->param('photo_input') );

        $c->alert( {'success' => 'The user was successfuly created'}, "email: " . $c->req->param('email') );

        # send email to user to set his password
        SubMan::Helpers::Admin::UserDetails::send_set_user_psw_email( $c, $user->id, $user->email,
            'http://' . $c->req->env->{'HTTP_HOST'} );

    }
    catch {
        $c->alert( {'error' => 'Unable to create the user. Please check the error log for more details.'},
            "email:" . $c->req->param('email') . " | error: $_" );
    };

    $c->go('add_user');
    $c->detach();
}


=head2 edit_user

Controller for admin 'Edit User' page

=cut

sub edit_user : Local('user_details') : Args(1) {
    my ( $self, $c ) = @_;

    my $user = $c->model('SubMan::User')->find( $c->req->args->[0] );

    if ( !$user ) {
        $c->alert( {'error' => 'Could not retrieve information for user.'} );
        $c->go('/admin/users');
        $c->detach();
    }

    $c->stash( {user => $user} );
}

=head2 save_user

Save route for edit user

=cut

sub save_user : Local('user_details') : Args(1) : OnError(edit_user) {
    my ( $self, $c ) = @_;

    my $user = $c->model('SubMan::User')->find( $c->req->args->[0] );

    if ( !$user ) {
        $c->alert( {'error' => 'Could not retrieve information for user.'} );
        $c->go('/admin/users');
        $c->detach();
    }

    my $link_user_subscription = $c->model('SubMan::LinkUserSubscription')->search( {user_id => $user->id} )->first();

    # establish the user user_type ('ADMIN', 'LEAD' or 'CUSTOMER)
    my $user_type = ( $c->req->param('admin_user') ? 'ADMIN' : 'LEAD' );
    $link_user_subscription =
        $c->model('SubMan::LinkUserSubscription')->find( {user_id => $user->id, active => 1} );
    $user_type = 'CUSTOMER' if $link_user_subscription;    # the user has an active subscription...so it's a 'CUSTOMER'

    my @cols = qw(
        firstname lastname address address2 country state zip_code phone gender
        birthday user_type company_name company_address company_country
        company_state company_zip_code company_phone
    );
    my $user_hash;
    map { $user_hash->{$_} = $c->req->param($_) || undef } @cols;
    $user_hash->{user_type} = $user_type;

    try {
        $user->update($user_hash);
    }
    catch {
        my $error = "Unable to edit user info. Please check the error log for more details.";
        $c->alert( {'error' => $error}, $_ );
        $c->go( 'edit_user/' . $user->id() );
        $c->detach();
    };

    $c->alert( {'success' => 'The user was successfuly edited.'}, " | user_id: " . $user->id() );

    # update, create or remove photo
    # the photo was previously set
    if ( $c->req->param('photo_input') ) {
        $c->forward( '/common/user/_save_photo', [$user] );
    }
    else {
        # photo is removed
        if ( $user->profile_picture ) {
            unlink $c->path_to('root') . '/' . $user->profile_picture;
        }

        $user->update( {profile_picture => undef} );
    }

    #refresh from storage
    $user->discard_changes;

    $c->stash( {user => $user} );

    $c->go( 'edit_user/' . $user->id() );
    $c->detach();
}


=head1 AUTHOR

MeSe

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
