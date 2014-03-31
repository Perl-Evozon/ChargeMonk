#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install 1.02;
use Module::Install::Catalyst;    # Complain loudly if you don't have

# Catalyst::Devel installed or haven't said
# 'make dist' to create a standalone tarball.

name 'Chargemonk';
all_from 'lib/Chargemonk.pm';

requires 'Business::AuthorizeNet::CIM';
requires 'Business::Stripe';
requires 'Date::Calc';
requires 'DateTime';
requires 'DateTime::Format::Pg';
requires 'DateTime::Format::MySQL';
requires 'DBD::Pg';
requires 'DBIx::Class';
requires 'DBIx::Class::PassphraseColumn';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Authentication::Store::DBIx::Class';
requires 'Catalyst::Controller::REST';
requires 'Catalyst::Devel';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Session::Store::File';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Restarter';
requires 'Catalyst::Runtime' => '5.90019';
requires 'Catalyst::ScriptRunner';
requires 'Catalyst::View::TT';
requires 'Catalyst::Plugin::Log::Handler';
requires 'Config::General';    # This should reflect the config file format you've chosen
requires 'Imager';
requires 'JSON';
requires 'JSON::XS';
requires 'Log::Log4perl';
requires 'LWP::Protocol::https';
requires 'Mail::Sendmail';
requires 'MIME::Base64';
requires 'Moose';
requires 'MooseX::MarkAsMethods';
requires 'MooseX::NonMoose';
requires 'namespace::autoclean';
requires 'Net::Braintree';
requires 'Net::IP';
requires 'SQL::Translator';
requires 'String::Random';
requires 'Template';
requires 'Template::Plugin::Number::Format';
requires 'Term::ReadKey';
requires 'Test::HTML::Form';
requires 'Test::WWW::Mechanize::Catalyst';
requires 'Try::Tiny';
requires 'YAML::Tiny';
requires 'Catalyst::View::JSON';

# See Catalyst::Plugin::ConfigLoader for supported formats
test_requires 'Test::More' => '0.88';
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
