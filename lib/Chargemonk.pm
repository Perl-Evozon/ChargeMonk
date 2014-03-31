package Chargemonk;

use Moose;
use namespace::autoclean;

use Catalyst::Runtime;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    ConfigLoader
    Static::Simple
    Session
    Session::State::Cookie
    Session::Store::File
    Log::Handler
    Authentication
    +Chargemonk::Plugin::Logger
    +Chargemonk::Plugin::Alert
    /;

extends 'Catalyst';

our $VERSION = '0.04';

BEGIN {
    #$ENV{DBIC_TRACE}         = 1;
    #$ENV{DBIC_TRACE_PROFILE} = 'console';
}

# Configure the application.
#
# Note that settings in chargemonk.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'Chargemonk',

    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header                      => 1,    # Send X-Catalyst header
);

__PACKAGE__->config({
    'View::JSON' => {
        allow_callback  => 1,    # defaults to 0
        callback_param  => 'cb', # defaults to 'callback'
    },
});

# Default view will be HTML
__PACKAGE__->config( default_view => 'HTML' );


__PACKAGE__->config(
    'Plugin::Static::Simple' => {
        ignore_extensions => [qw/tmpl tt tt2 xhtml/],
        dirs              => ['static', qr/^(img|css|html|js)/]
    }
);

__PACKAGE__->config(
    'Plugin::Authentication' => {
        default => {
            credential => {
                password_field => 'password',
                password_type  => 'self_check'
            },
            store => {
                class       => 'DBIx::Class',
                user_model  => 'Chargemonk::User',
                role_column => 'user_type',
            }
        }

    }
);

__PACKAGE__->config(
    'Log::Handler' => {
        filename        => 'logs/chargemonk_error.log',
        fileopen        => 1,
        mode            => 'append',
        utf8            => 1,
        timeformat      => "%Y/%m/%d %H:%M:%S",
        message_layout  => "%T [%L] %S: %m",
        permissions     => "0660"
    },
);

__PACKAGE__->config( 'Plugin::ConfigLoader' => {file => 'conf/chargemonk.conf'} );

# Start the application
__PACKAGE__->setup();


=head1 NAME

Chargemonk - Catalyst based application

=head1 SYNOPSIS

    script/chargemonk_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<Chargemonk::Controller::Root>, L<Catalyst>

=head1 AUTHOR

natasha

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
