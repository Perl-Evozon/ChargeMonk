#!/usr/bin/perl

use LWP::UserAgent;

my $ua = LWP::UserAgent->new;

my $url = 'https://secure.payu.ro/order/lu.php';

my $form_params = {
    MERCHANT => "PAYDEMO",
    ORDER_REF => "112457",
    ORDER_PNAME => "MACBOOK AIR",
    ORDER_PRICE => "400",
    ORDER_QTY => 1,
    PRICE_CURRENCY => "RON",
    PAY_METHOD => "CCVISAMC",
    TESTORDER => "TRUE",
    LANGUAGE => "RO"
};

my $response = $ua->post( $url, $form_params );

use Data::Dumper;
warn Dumper $response;