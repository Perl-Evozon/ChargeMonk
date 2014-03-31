package SubMan::Helpers::Stats::Subscribers;

use Moose::Role;
use Storable qw( dclone );
use DateTime;

use SubMan::Helpers::Common::DateTime;

=head1 NAME

SubMan::Helpers::Stats::Subscribers

Calculate the subscribers stats

PS:
The reason to use timestamp_daystart is to be able to cache records by days, weeks...

We need to exclude the intervals that include today from caching

=head1 METHODS


=head2 subscribers_stats

Get the subscribers for the interval
    - new subscribers
    - lost subscribers
        - unconfirmed
        - those that had an subscription
    - all
=cut

sub subscribers_stats {
    my ( $c, $from, $to, $unit, $frequency, $frequency_unit ) = @_;

    my $stats = {};

    my $local_cache = {};

    while ( $from le $to ) {
        push @{$stats->{labels}}, $from->strftime( $c->config->{stats}->{format}->{$frequency_unit} );

        my $to_interm = dclone($from);
        $to_interm->add( $frequency_unit => $frequency );

        my @new_subscribers = $c->model('SubMan::User')->search(
            {signup_date => {-between => [timestamp_daystart($from), timestamp_daystart($to_interm),]}},
            {   join         => 'user_registration_token',
                prefetch     => 'user_registration_token',
                result_class => 'DBIx::Class::ResultClass::HashRefInflator',
            }
        );
        push @{$stats->{new_subscribers}}, scalar(@new_subscribers);

        my $unconfirmed = scalar( grep { defined $_->{user_registration_token} } @new_subscribers );

        #users that started the subscription wizard but didn't confirm
        push @{$stats->{unconfirmed}}, $unconfirmed;

        # lost subscribers also mean the users that had a subscription but do not have anymore
        # get the total active subscription for the current and previous period
        my $active_subs_for_prev =
              $local_cache->{"$from"}
            ? $local_cache->{"$from"}
            : $c->model('SubMan::LinkUserSubscription')->search(
            {active_to_date => {'>=', timestamp_daystart($from)},},
            {result_class   => 'DBIx::Class::ResultClass::HashRefInflator',}
            )->count();

        my $active_subs_for_curr =
              $local_cache->{"$to_interm"}
            ? $local_cache->{"$to_interm"}
            : $c->model('SubMan::LinkUserSubscription')->search(
            {active_to_date => {'>=', timestamp_daystart($to_interm)},},
            {result_class   => 'DBIx::Class::ResultClass::HashRefInflator',}
            )->count();

        my $lost = $active_subs_for_curr < $active_subs_for_prev ? $active_subs_for_prev - $active_subs_for_curr : 0;
        push @{$stats->{lost}}, ( $unconfirmed + $lost );

        $from = $to_interm;
    }

    return $stats;
}

sub revenue_stats {
    my ( $c, $from, $to, $unit, $frequency, $frequency_unit ) = @_;

    my $stats = {};

    while ( $from le $to ) {
        push @{$stats->{labels}}, $from->strftime( $c->config->{stats}->{format}->{$frequency_unit} );

        my $to_interm = dclone($from);
        $to_interm->add( $frequency_unit => $frequency );

        my @revenue_rs = $c->model('SubMan::LinkUserSubscription')->search(
            {   active_from_date => {'>=' => timestamp_daystart($from)},
                active_from_date => {'<=' => timestamp_daystart($to_interm)}
            },
            {   join         => 'subscription',
                prefech      => 'subscription',
                select       => [{sum => 'subscription.price'}],
                as           => ['revenue'],
                result_class => 'DBIx::Class::ResultClass::HashRefInflator',
            }
        );

        my $revenue_result = $revenue_rs[0]->{revenue} || 0;
        push @{$stats->{revenue}}, ( $revenue_result + 0 );

        $from = $to_interm;
    }

    return $stats;
}

sub subscription_stats {
    my $c = shift;

    my $stats = {};

    my @subscriptions = $c->model("SubMan::LinkUserSubscription")->search(
        {},
        {   join    => 'subscription',
            prefech => 'subscription',
            select  => ['subscription.name', {count => 'me.id'}],
            as           => ['name', 'number_of_subscribers'],
            group_by     => ['name'],
            result_class => 'DBIx::Class::ResultClass::HashRefInflator',
        }
    );

    $_->{number_of_subscribers} = ( $_->{number_of_subscribers} + 0 ) foreach (@subscriptions);

    return [@subscriptions];
}

sub revenue_prospect_stats {
    my $c = shift;

    my $stats = {};

    my @months_to_add = ( 1, 2, 3 );

    foreach my $month_to_add (@months_to_add) {
        my $current_date   = DateTime->now();
        my $next_month_start = DateTime->new(
            year  => $current_date->year(),
            month => $current_date->add( months => $month_to_add )->month(),
            day   => 1,
        );
        
        my $next_month_start_clone = dclone($next_month_start);
        my $next_month_end = $next_month_start_clone->add( months => 1 )->subtract( days => 1 );
        
        my @subscription_prospect = $c->model('SubMan::LinkUserSubscription')->search({
            -and => [
                { active_to_date                => {'>=' => timestamp_daystart($next_month_start)} },
                { active_to_date                => {'<=' => timestamp_daystart($next_month_end)} },
                {'subscription.has_auto_renew' => 1 }
            ]},
            {   join         => 'subscription',
                prefech      => 'subscription',
                select       => [{sum => 'subscription.price'}],
                as           => ['revenue_prospect'],
                result_class => 'DBIx::Class::ResultClass::HashRefInflator',
            }
        );
               
        push @{$stats->{revenue_prospect}},
            {
            amount => $subscription_prospect[0]->{revenue_prospect} // 0,
            month  => $next_month_start->month_name()
            };


    }

    return $stats;
}

1;
