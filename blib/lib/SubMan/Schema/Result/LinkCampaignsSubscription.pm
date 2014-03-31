package SubMan::Schema::Result::LinkCampaignsSubscription;

use strict;
use warnings;
use utf8;
use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;

extends 'DBIx::Class::Core';

__PACKAGE__->table("link_campaigns_subscriptions");

__PACKAGE__->add_columns(
    subscription_id => { data_type => "integer", is_nullable => 0 },
    campaign_id =>
      { data_type => "integer", is_nullable => 0 },
);

__PACKAGE__->belongs_to(
    "subscription",
    "SubMan::Schema::Result::Subscription",
    { "foreign.id" => "self.subscription_id" },
    {
        is_deferrable => 1,
        join_type     => "LEFT",
        on_delete     => "CASCADE",
        on_update     => "CASCADE",
    },
);

__PACKAGE__->belongs_to(
    "campaign",
    "SubMan::Schema::Result::Campaign",
    { "foreign.id" => "self.campaign_id" },
    {
        is_deferrable => 1,
        join_type     => "LEFT",
        on_delete     => "CASCADE",
        on_update     => "CASCADE",
    },
);

__PACKAGE__->meta->make_immutable;

1;
