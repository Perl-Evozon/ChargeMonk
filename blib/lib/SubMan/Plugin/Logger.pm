package SubMan::Plugin::Logger;
use Moose;
use MooseX::Types;
use Log::Log4perl qw(get_logger);
use FindBin;

use namespace::autoclean;

has logger => (
    is      => 'ro',
    isa     => "Log::Log4perl::Logger",
    lazy    => 1,
    builder => '_get_logger',
);


sub _get_logger {
    my $self = shift;
    
    my $user_name = ( $self->user && ( $self->user->firstname || $self->user->lastname ) ) ? $self->user->firstname.' '.$self->user->lastname : 'N/A';
    my $user_type = ( $self->user() ) ? 'User [name=' . $user_name . '] [email=' . $self->user->email . '] [session=' . $self->{_sessionid} . ']'
                                      : 'User anonymous'; 
    my $config = qq(
        log4perl.logger.error                  = DEBUG, FileAppndr1
        log4perl.appender.FileAppndr1          = Log::Log4perl::Appender::File
        log4perl.appender.FileAppndr1.filename = logs/subman_error.log 
        log4perl.appender.FileAppndr1.layout   = Log::Log4perl::Layout::PatternLayout
        log4perl.appender.FileAppndr1.layout.ConversionPattern = %d [%p] %F{1}:%L %M - $user_type: %m%n
    );
    
    Log::Log4perl::init(\$config);
    return  Log::Log4perl->get_logger('error');
}

1;
