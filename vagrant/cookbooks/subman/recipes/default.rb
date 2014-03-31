perlbrew_perl '5.16.3' do
    version 'perl-5.16.3'
    action :install
end

perlbrew_cpanm 'Perl modules for Chargemonk' do
    perlbrew '5.16.3'
    modules [
        'Catalyst::Runtime',
        'Catalyst::Plugin::ConfigLoader',
        'Catalyst::Plugin::Static::Simple',
        'Catalyst::Action::RenderView',
        'Catalyst::Plugin::Session::Store::File',
        'Catalyst::Plugin::Session::State::Cookie',
        'Catalyst::Plugin::Authentication',
        'Catalyst::Authentication::Store::DBIx::Class',
        'Catalyst::View::TT',
        'Log::Log4perl',
        'Catalyst::Devel',
        'DBIx::Class',
        'Template',
        'Template::Plugin::Number::Format',
        'Moose',
        'namespace::autoclean',
        'Config::General',
        'MooseX::MarkAsMethods',
        'MooseX::NonMoose',
        'DBD::Pg',
        'DateTime',
        'DateTime::Format::Pg',
        'Mail::Sendmail',
        'String::Random',
        'MooseX::MarkAsMethods',
        'MooseX::NonMoose',
        'Net::IP',
        'Imager',
        'DBIx::Class::PassphraseColumn',
        'Term::ReadKey',
        'Test::More'
    ]
end

cookbook_file "/root/.bashrc" do
    source "root/.bashrc"
    mode "0644"
    owner "root"
    group "root"
    not_if "test -f /root/.bashrc"
end

bash "chargemonk-db-setup" do
    user "postgres"
    code <<-EOF
        createdb chargemonk
    EOF
    not_if "psql -U postgres -l | egrep '^ chargemonk' | wc -l", :user => "postgres"
    action :run
end

bash "chargemonk-db-user-setup" do
    user "postgres"
    code <<-EOF
        createuser -S -D -R chargemonk
        psql -c "ALTER USER chargemonk WITH PASSWORD 'chargemonk'"
    EOF
    not_if "psql -Upostgres -tAc \"SELECT 1 FROM pg_roles WHERE rolname='chargemonk'\"", :user => "postgres"
    action :run
end

file "/root/.pgpass" do
    content "localhost:5432:chargemonk:chargemonk:chargemonk\n"
    mode "0600"
    action :create
end

service "iptables" do
    action [:disable, :stop]
end
