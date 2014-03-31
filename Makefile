# This Makefile is for the SubMan extension to perl.
#
# It was generated automatically by MakeMaker version
# 6.84 (Revision: 68400) from the contents of
# Makefile.PL. Don't edit this file, edit Makefile.PL instead.
#
#       ANY CHANGES MADE HERE WILL BE LOST!
#
#   MakeMaker ARGV: ()
#

#   MakeMaker Parameters:

#     ABSTRACT => q[Catalyst based application]
#     AUTHOR => [q[natasha]]
#     BUILD_REQUIRES => { Test::More=>q[0.88], ExtUtils::MakeMaker=>q[6.36] }
#     CONFIGURE_REQUIRES => {  }
#     DISTNAME => q[SubMan]
#     EXE_FILES => [q[script/apply_migrations.pl], q[script/cron_subscriptions.pl], q[script/subman_cgi.pl], q[script/subman_create.pl], q[script/subman_create_admin.pl], q[script/subman_fastcgi.pl], q[script/subman_server.pl], q[script/subman_test.pl]]
#     LICENSE => q[perl]
#     NAME => q[SubMan]
#     NO_META => q[1]
#     PREREQ_PM => { DateTime=>q[0], DateTime::Format::MySQL=>q[0], Catalyst::Devel=>q[0], Catalyst::Plugin::ConfigLoader=>q[0], Net::IP=>q[0], JSON::XS=>q[0], Catalyst::View::JSON=>q[0], Catalyst::Plugin::Session::State::Cookie=>q[0], Config::General=>q[0], Business::AuthorizeNet::CIM=>q[0], Test::WWW::Mechanize::Catalyst=>q[0], Business::Stripe=>q[0], Catalyst::Authentication::Store::DBIx::Class=>q[0], Term::ReadKey=>q[0], MooseX::MarkAsMethods=>q[0], Catalyst::View::TT=>q[0], Try::Tiny=>q[0], ExtUtils::MakeMaker=>q[6.36], DBIx::Class::PassphraseColumn=>q[0], DBD::Pg=>q[0], Net::Braintree=>q[0], Catalyst::Plugin::Session::Store::File=>q[0], Test::More=>q[0.88], Catalyst::Controller::REST=>q[0], Date::Calc=>q[0], Mail::Sendmail=>q[0], Catalyst::Restarter=>q[0], String::Random=>q[0], Log::Log4perl=>q[0], MooseX::NonMoose=>q[0], Catalyst::ScriptRunner=>q[0], LWP::Protocol::https=>q[0], DBIx::Class=>q[0], Catalyst::Plugin::Log::Handler=>q[0], Moose=>q[0], namespace::autoclean=>q[0], SQL::Translator=>q[0], Catalyst::Plugin::Static::Simple=>q[0], YAML::Tiny=>q[0], Imager=>q[0], Template=>q[0], Catalyst::Action::RenderView=>q[0], Test::HTML::Form=>q[0], MIME::Base64=>q[0], Catalyst::Plugin::Authentication=>q[0], JSON=>q[0], Catalyst::Runtime=>q[5.90019], Template::Plugin::Number::Format=>q[0], DateTime::Format::Pg=>q[0] }
#     TEST_REQUIRES => {  }
#     VERSION => q[0.04]
#     VERSION_FROM => q[lib/SubMan.pm]
#     dist => { PREOP=>q[$(PERL) -I. "-MModule::Install::Admin" -e "dist_preop(q($(DISTVNAME)))"] }
#     realclean => { FILES=>q[MYMETA.yml] }
#     test => { TESTS=>q[t/01app.t t/02pod.t t/03podcoverage.t t/Auth.t t/controller_Admin-Dashboard.t t/controller_Admin-DiscountCodes.t t/controller_Admin-Features.t t/controller_Admin-Manage_ips.t t/controller_Admin-Payment_gateways.t t/controller_Admin-Profile.t t/controller_Admin-Registration.t t/controller_Admin-Subscription.t t/controller_Admin-SubscriptionGroup.t t/controller_Admin-Themes.t t/controller_Admin-UpgradeDowngrade.t t/controller_Admin-Users.t t/controller_Dashboard.t t/controller_Home.t t/controller_User-Profile.t t/helper_Cron_Subscriptions.t t/model_SubMan.t t/Public-Links.t t/Registration.t t/view_HTML.t] }

# --- MakeMaker post_initialize section:


# --- MakeMaker const_config section:

# These definitions are from config.sh (via /usr/lib/perl/5.14/Config.pm).
# They may have been overridden via Makefile.PL or on the command line.
AR = ar
CC = cc
CCCDLFLAGS = -fPIC
CCDLFLAGS = -Wl,-E
DLEXT = so
DLSRC = dl_dlopen.xs
EXE_EXT = 
FULL_AR = /usr/bin/ar
LD = cc
LDDLFLAGS = -shared -L/usr/local/lib -fstack-protector
LDFLAGS =  -fstack-protector -L/usr/local/lib
LIBC = 
LIB_EXT = .a
OBJ_EXT = .o
OSNAME = linux
OSVERS = 3.2.0-4-686-pae
RANLIB = :
SITELIBEXP = /usr/local/share/perl/5.14.2
SITEARCHEXP = /usr/local/lib/perl/5.14.2
SO = so
VENDORARCHEXP = /usr/lib/perl5
VENDORLIBEXP = /usr/share/perl5


# --- MakeMaker constants section:
AR_STATIC_ARGS = cr
DIRFILESEP = /
DFSEP = $(DIRFILESEP)
NAME = SubMan
NAME_SYM = SubMan
VERSION = 0.04
VERSION_MACRO = VERSION
VERSION_SYM = 0_04
DEFINE_VERSION = -D$(VERSION_MACRO)=\"$(VERSION)\"
XS_VERSION = 0.04
XS_VERSION_MACRO = XS_VERSION
XS_DEFINE_VERSION = -D$(XS_VERSION_MACRO)=\"$(XS_VERSION)\"
INST_ARCHLIB = blib/arch
INST_SCRIPT = blib/script
INST_BIN = blib/bin
INST_LIB = blib/lib
INST_MAN1DIR = blib/man1
INST_MAN3DIR = blib/man3
MAN1EXT = 1p
MAN3EXT = 3pm
INSTALLDIRS = site
DESTDIR = 
PREFIX = $(SITEPREFIX)
PERLPREFIX = /usr
SITEPREFIX = /usr/local
VENDORPREFIX = /usr
INSTALLPRIVLIB = /usr/share/perl/5.14
DESTINSTALLPRIVLIB = $(DESTDIR)$(INSTALLPRIVLIB)
INSTALLSITELIB = /usr/local/share/perl/5.14.2
DESTINSTALLSITELIB = $(DESTDIR)$(INSTALLSITELIB)
INSTALLVENDORLIB = /usr/share/perl5
DESTINSTALLVENDORLIB = $(DESTDIR)$(INSTALLVENDORLIB)
INSTALLARCHLIB = /usr/lib/perl/5.14
DESTINSTALLARCHLIB = $(DESTDIR)$(INSTALLARCHLIB)
INSTALLSITEARCH = /usr/local/lib/perl/5.14.2
DESTINSTALLSITEARCH = $(DESTDIR)$(INSTALLSITEARCH)
INSTALLVENDORARCH = /usr/lib/perl5
DESTINSTALLVENDORARCH = $(DESTDIR)$(INSTALLVENDORARCH)
INSTALLBIN = /usr/bin
DESTINSTALLBIN = $(DESTDIR)$(INSTALLBIN)
INSTALLSITEBIN = /usr/local/bin
DESTINSTALLSITEBIN = $(DESTDIR)$(INSTALLSITEBIN)
INSTALLVENDORBIN = /usr/bin
DESTINSTALLVENDORBIN = $(DESTDIR)$(INSTALLVENDORBIN)
INSTALLSCRIPT = /usr/bin
DESTINSTALLSCRIPT = $(DESTDIR)$(INSTALLSCRIPT)
INSTALLSITESCRIPT = /usr/local/bin
DESTINSTALLSITESCRIPT = $(DESTDIR)$(INSTALLSITESCRIPT)
INSTALLVENDORSCRIPT = /usr/bin
DESTINSTALLVENDORSCRIPT = $(DESTDIR)$(INSTALLVENDORSCRIPT)
INSTALLMAN1DIR = /usr/share/man/man1
DESTINSTALLMAN1DIR = $(DESTDIR)$(INSTALLMAN1DIR)
INSTALLSITEMAN1DIR = /usr/local/man/man1
DESTINSTALLSITEMAN1DIR = $(DESTDIR)$(INSTALLSITEMAN1DIR)
INSTALLVENDORMAN1DIR = /usr/share/man/man1
DESTINSTALLVENDORMAN1DIR = $(DESTDIR)$(INSTALLVENDORMAN1DIR)
INSTALLMAN3DIR = /usr/share/man/man3
DESTINSTALLMAN3DIR = $(DESTDIR)$(INSTALLMAN3DIR)
INSTALLSITEMAN3DIR = /usr/local/man/man3
DESTINSTALLSITEMAN3DIR = $(DESTDIR)$(INSTALLSITEMAN3DIR)
INSTALLVENDORMAN3DIR = /usr/share/man/man3
DESTINSTALLVENDORMAN3DIR = $(DESTDIR)$(INSTALLVENDORMAN3DIR)
PERL_LIB =
PERL_ARCHLIB = /usr/lib/perl/5.14
LIBPERL_A = libperl.a
FIRST_MAKEFILE = Makefile
MAKEFILE_OLD = Makefile.old
MAKE_APERL_FILE = Makefile.aperl
PERLMAINCC = $(CC)
PERL_INC = /usr/lib/perl/5.14/CORE
PERL = /usr/bin/perl "-Iinc"
FULLPERL = /usr/bin/perl "-Iinc"
ABSPERL = $(PERL)
PERLRUN = $(PERL)
FULLPERLRUN = $(FULLPERL)
ABSPERLRUN = $(ABSPERL)
PERLRUNINST = $(PERLRUN) "-I$(INST_ARCHLIB)" "-Iinc" "-I$(INST_LIB)"
FULLPERLRUNINST = $(FULLPERLRUN) "-I$(INST_ARCHLIB)" "-Iinc" "-I$(INST_LIB)"
ABSPERLRUNINST = $(ABSPERLRUN) "-I$(INST_ARCHLIB)" "-Iinc" "-I$(INST_LIB)"
PERL_CORE = 0
PERM_DIR = 755
PERM_RW = 644
PERM_RWX = 755

MAKEMAKER   = /usr/local/share/perl/5.14.2/ExtUtils/MakeMaker.pm
MM_VERSION  = 6.84
MM_REVISION = 68400

# FULLEXT = Pathname for extension directory (eg Foo/Bar/Oracle).
# BASEEXT = Basename part of FULLEXT. May be just equal FULLEXT. (eg Oracle)
# PARENT_NAME = NAME without BASEEXT and no trailing :: (eg Foo::Bar)
# DLBASE  = Basename part of dynamic library. May be just equal BASEEXT.
MAKE = make
FULLEXT = SubMan
BASEEXT = SubMan
PARENT_NAME = 
DLBASE = $(BASEEXT)
VERSION_FROM = lib/SubMan.pm
OBJECT = 
LDFROM = $(OBJECT)
LINKTYPE = dynamic
BOOTDEP = 

# Handy lists of source code files:
XS_FILES = 
C_FILES  = 
O_FILES  = 
H_FILES  = 
MAN1PODS = script/apply_migrations.pl \
	script/cron_subscriptions.pl \
	script/subman_cgi.pl \
	script/subman_create.pl \
	script/subman_create_admin.pl \
	script/subman_fastcgi.pl \
	script/subman_server.pl \
	script/subman_test.pl
MAN3PODS = lib/SubMan.pm \
	lib/SubMan/Common/Logger.pm \
	lib/SubMan/Controller/API/Base.pm \
	lib/SubMan/Controller/API/Payment.pm \
	lib/SubMan/Controller/API/Pricing.pm \
	lib/SubMan/Controller/API/Register.pm \
	lib/SubMan/Controller/API/Subscriptions.pm \
	lib/SubMan/Controller/Admin/Dashboard.pm \
	lib/SubMan/Controller/Admin/Features.pm \
	lib/SubMan/Controller/Admin/Gateway.pm \
	lib/SubMan/Controller/Admin/Manage_ips.pm \
	lib/SubMan/Controller/Admin/Manage_users.pm \
	lib/SubMan/Controller/Admin/Payment_gateways.pm \
	lib/SubMan/Controller/Admin/Profile.pm \
	lib/SubMan/Controller/Admin/Registration.pm \
	lib/SubMan/Controller/Admin/Stats.pm \
	lib/SubMan/Controller/Admin/SubscriptionGroups.pm \
	lib/SubMan/Controller/Admin/Subscriptions.pm \
	lib/SubMan/Controller/Admin/Subscriptions/Tabs.pm \
	lib/SubMan/Controller/Admin/Subscriptions/add_subscription.pm \
	lib/SubMan/Controller/Admin/Subscriptions/edit_subscription.pm \
	lib/SubMan/Controller/Admin/Themes.pm \
	lib/SubMan/Controller/Admin/Users.pm \
	lib/SubMan/Controller/Authenticated.pm \
	lib/SubMan/Controller/Common/SubscriptionActions.pm \
	lib/SubMan/Controller/Common/User.pm \
	lib/SubMan/Controller/Register.pm \
	lib/SubMan/Controller/Register/Corporate.pm \
	lib/SubMan/Controller/Register/Individual.pm \
	lib/SubMan/Controller/Register/Wizard.pm \
	lib/SubMan/Controller/Root.pm \
	lib/SubMan/Controller/User/Home.pm \
	lib/SubMan/Controller/User/Manage_ips.pm \
	lib/SubMan/Controller/User/Manage_users.pm \
	lib/SubMan/Controller/User/Profile.pm \
	lib/SubMan/Controller/Visitor.pm \
	lib/SubMan/Helpers/Admin/UserDetails.pm \
	lib/SubMan/Helpers/Common/DateTime.pm \
	lib/SubMan/Helpers/Cron/Notifier.pm \
	lib/SubMan/Helpers/Cron/Subscriptions.pm \
	lib/SubMan/Helpers/Gateways/Authorize.pm \
	lib/SubMan/Helpers/Gateways/Braintree.pm \
	lib/SubMan/Helpers/Gateways/Details.pm \
	lib/SubMan/Helpers/Gateways/Stripe.pm \
	lib/SubMan/Helpers/Stats/Subscribers.pm \
	lib/SubMan/Helpers/Visitor/Registration.pm \
	lib/SubMan/Model/SubMan.pm \
	lib/SubMan/Plugin/Alert.pm \
	lib/SubMan/Schema/Result/AuthorizeUser.pm \
	lib/SubMan/Schema/Result/BraintreeUser.pm \
	lib/SubMan/Schema/Result/Invoice.pm \
	lib/SubMan/Schema/Result/StripeUser.pm \
	lib/SubMan/Schema/Result/Transaction.pm \
	lib/SubMan/Test/Mechanize.pm \
	lib/SubMan/Test/Register.pm \
	lib/SubMan/ValidationRule/Base.pm \
	lib/SubMan/ValidationRule/Email.pm \
	lib/SubMan/ValidationRule/NotEmpty.pm \
	lib/SubMan/ValidationRule/NotEmptyIfExists.pm \
	lib/SubMan/ValidationRule/Subscription/CheckAccessType.pm \
	lib/SubMan/ValidationRule/Subscription/CheckTrial.pm \
	lib/SubMan/ValidationRule/Subscription/DiscountCodeExists.pm \
	lib/SubMan/ValidationRule/Subscription/DiscountCodeNotUsed.pm \
	lib/SubMan/ValidationRule/UniqueUser.pm \
	lib/SubMan/ValidationRule/ValidAdmin.pm \
	lib/SubMan/View/HTML.pm

# Where is the Config information that we are using/depend on
CONFIGDEP = $(PERL_ARCHLIB)$(DFSEP)Config.pm $(PERL_INC)$(DFSEP)config.h

# Where to build things
INST_LIBDIR      = $(INST_LIB)
INST_ARCHLIBDIR  = $(INST_ARCHLIB)

INST_AUTODIR     = $(INST_LIB)/auto/$(FULLEXT)
INST_ARCHAUTODIR = $(INST_ARCHLIB)/auto/$(FULLEXT)

INST_STATIC      = 
INST_DYNAMIC     = 
INST_BOOT        = 

# Extra linker info
EXPORT_LIST        = 
PERL_ARCHIVE       = 
PERL_ARCHIVE_AFTER = 


TO_INST_PM = lib/SubMan.pm \
	lib/SubMan/Common/Logger.pm \
	lib/SubMan/Controller/API/Base.pm \
	lib/SubMan/Controller/API/Payment.pm \
	lib/SubMan/Controller/API/Pricing.pm \
	lib/SubMan/Controller/API/Register.pm \
	lib/SubMan/Controller/API/Subscriptions.pm \
	lib/SubMan/Controller/Admin/Dashboard.pm \
	lib/SubMan/Controller/Admin/Features.pm \
	lib/SubMan/Controller/Admin/Gateway.pm \
	lib/SubMan/Controller/Admin/Manage_ips.pm \
	lib/SubMan/Controller/Admin/Manage_users.pm \
	lib/SubMan/Controller/Admin/Payment_gateways.pm \
	lib/SubMan/Controller/Admin/Profile.pm \
	lib/SubMan/Controller/Admin/Registration.pm \
	lib/SubMan/Controller/Admin/Stats.pm \
	lib/SubMan/Controller/Admin/SubscriptionGroups.pm \
	lib/SubMan/Controller/Admin/Subscriptions.pm \
	lib/SubMan/Controller/Admin/Subscriptions/Tabs.pm \
	lib/SubMan/Controller/Admin/Subscriptions/add_subscription.pm \
	lib/SubMan/Controller/Admin/Subscriptions/edit_subscription.pm \
	lib/SubMan/Controller/Admin/Themes.pm \
	lib/SubMan/Controller/Admin/Users.pm \
	lib/SubMan/Controller/Authenticated.pm \
	lib/SubMan/Controller/Common/SubscriptionActions.pm \
	lib/SubMan/Controller/Common/User.pm \
	lib/SubMan/Controller/Register.pm \
	lib/SubMan/Controller/Register/Corporate.pm \
	lib/SubMan/Controller/Register/Individual.pm \
	lib/SubMan/Controller/Register/Wizard.pm \
	lib/SubMan/Controller/Root.pm \
	lib/SubMan/Controller/User/Home.pm \
	lib/SubMan/Controller/User/Manage_ips.pm \
	lib/SubMan/Controller/User/Manage_users.pm \
	lib/SubMan/Controller/User/Profile.pm \
	lib/SubMan/Controller/Visitor.pm \
	lib/SubMan/Helpers/Admin/UserDetails.pm \
	lib/SubMan/Helpers/Common/DateTime.pm \
	lib/SubMan/Helpers/Cron/Notifier.pm \
	lib/SubMan/Helpers/Cron/Subscriptions.pm \
	lib/SubMan/Helpers/Gateways/Authorize.pm \
	lib/SubMan/Helpers/Gateways/Braintree.pm \
	lib/SubMan/Helpers/Gateways/Details.pm \
	lib/SubMan/Helpers/Gateways/Stripe.pm \
	lib/SubMan/Helpers/Stats/Subscribers.pm \
	lib/SubMan/Helpers/Visitor/Registration.pm \
	lib/SubMan/Model/SubMan.pm \
	lib/SubMan/Model/SubMan.pm.new \
	lib/SubMan/Plugin/Alert.pm \
	lib/SubMan/Plugin/Logger.pm \
	lib/SubMan/Schema.pm \
	lib/SubMan/Schema/Result/AuthorizeUser.pm \
	lib/SubMan/Schema/Result/BraintreeUser.pm \
	lib/SubMan/Schema/Result/Campaign.pm \
	lib/SubMan/Schema/Result/Code.pm \
	lib/SubMan/Schema/Result/Config.pm \
	lib/SubMan/Schema/Result/Feature.pm \
	lib/SubMan/Schema/Result/Invoice.pm \
	lib/SubMan/Schema/Result/IpRange.pm \
	lib/SubMan/Schema/Result/LinkCampaignsSubscription.pm \
	lib/SubMan/Schema/Result/LinkSubscriptionFeature.pm \
	lib/SubMan/Schema/Result/LinkUserSubscription.pm \
	lib/SubMan/Schema/Result/PeriodUser.pm \
	lib/SubMan/Schema/Result/Registration.pm \
	lib/SubMan/Schema/Result/StripeUser.pm \
	lib/SubMan/Schema/Result/Subscription.pm \
	lib/SubMan/Schema/Result/SubscriptionDowngradeTo.pm \
	lib/SubMan/Schema/Result/SubscriptionGroup.pm \
	lib/SubMan/Schema/Result/SubscriptionUpgradeTo.pm \
	lib/SubMan/Schema/Result/Theme.pm \
	lib/SubMan/Schema/Result/Transaction.pm \
	lib/SubMan/Schema/Result/User.pm \
	lib/SubMan/Schema/Result/UserPswSetToken.pm \
	lib/SubMan/Schema/Result/UserRegistrationToken.pm \
	lib/SubMan/Schema/Result/UserType.pm \
	lib/SubMan/Test/Mechanize.pm \
	lib/SubMan/Test/Register.pm \
	lib/SubMan/ValidationRule/Base.pm \
	lib/SubMan/ValidationRule/Email.pm \
	lib/SubMan/ValidationRule/NotEmpty.pm \
	lib/SubMan/ValidationRule/NotEmptyIfExists.pm \
	lib/SubMan/ValidationRule/Subscription/CheckAccessType.pm \
	lib/SubMan/ValidationRule/Subscription/CheckTrial.pm \
	lib/SubMan/ValidationRule/Subscription/DiscountCodeExists.pm \
	lib/SubMan/ValidationRule/Subscription/DiscountCodeNotUsed.pm \
	lib/SubMan/ValidationRule/UniqueUser.pm \
	lib/SubMan/ValidationRule/ValidAdmin.pm \
	lib/SubMan/View/HTML.pm \
	lib/SubMan/View/JSON.pm

PM_TO_BLIB = lib/SubMan.pm \
	blib/lib/SubMan.pm \
	lib/SubMan/Common/Logger.pm \
	blib/lib/SubMan/Common/Logger.pm \
	lib/SubMan/Controller/API/Base.pm \
	blib/lib/SubMan/Controller/API/Base.pm \
	lib/SubMan/Controller/API/Payment.pm \
	blib/lib/SubMan/Controller/API/Payment.pm \
	lib/SubMan/Controller/API/Pricing.pm \
	blib/lib/SubMan/Controller/API/Pricing.pm \
	lib/SubMan/Controller/API/Register.pm \
	blib/lib/SubMan/Controller/API/Register.pm \
	lib/SubMan/Controller/API/Subscriptions.pm \
	blib/lib/SubMan/Controller/API/Subscriptions.pm \
	lib/SubMan/Controller/Admin/Dashboard.pm \
	blib/lib/SubMan/Controller/Admin/Dashboard.pm \
	lib/SubMan/Controller/Admin/Features.pm \
	blib/lib/SubMan/Controller/Admin/Features.pm \
	lib/SubMan/Controller/Admin/Gateway.pm \
	blib/lib/SubMan/Controller/Admin/Gateway.pm \
	lib/SubMan/Controller/Admin/Manage_ips.pm \
	blib/lib/SubMan/Controller/Admin/Manage_ips.pm \
	lib/SubMan/Controller/Admin/Manage_users.pm \
	blib/lib/SubMan/Controller/Admin/Manage_users.pm \
	lib/SubMan/Controller/Admin/Payment_gateways.pm \
	blib/lib/SubMan/Controller/Admin/Payment_gateways.pm \
	lib/SubMan/Controller/Admin/Profile.pm \
	blib/lib/SubMan/Controller/Admin/Profile.pm \
	lib/SubMan/Controller/Admin/Registration.pm \
	blib/lib/SubMan/Controller/Admin/Registration.pm \
	lib/SubMan/Controller/Admin/Stats.pm \
	blib/lib/SubMan/Controller/Admin/Stats.pm \
	lib/SubMan/Controller/Admin/SubscriptionGroups.pm \
	blib/lib/SubMan/Controller/Admin/SubscriptionGroups.pm \
	lib/SubMan/Controller/Admin/Subscriptions.pm \
	blib/lib/SubMan/Controller/Admin/Subscriptions.pm \
	lib/SubMan/Controller/Admin/Subscriptions/Tabs.pm \
	blib/lib/SubMan/Controller/Admin/Subscriptions/Tabs.pm \
	lib/SubMan/Controller/Admin/Subscriptions/add_subscription.pm \
	blib/lib/SubMan/Controller/Admin/Subscriptions/add_subscription.pm \
	lib/SubMan/Controller/Admin/Subscriptions/edit_subscription.pm \
	blib/lib/SubMan/Controller/Admin/Subscriptions/edit_subscription.pm \
	lib/SubMan/Controller/Admin/Themes.pm \
	blib/lib/SubMan/Controller/Admin/Themes.pm \
	lib/SubMan/Controller/Admin/Users.pm \
	blib/lib/SubMan/Controller/Admin/Users.pm \
	lib/SubMan/Controller/Authenticated.pm \
	blib/lib/SubMan/Controller/Authenticated.pm \
	lib/SubMan/Controller/Common/SubscriptionActions.pm \
	blib/lib/SubMan/Controller/Common/SubscriptionActions.pm \
	lib/SubMan/Controller/Common/User.pm \
	blib/lib/SubMan/Controller/Common/User.pm \
	lib/SubMan/Controller/Register.pm \
	blib/lib/SubMan/Controller/Register.pm \
	lib/SubMan/Controller/Register/Corporate.pm \
	blib/lib/SubMan/Controller/Register/Corporate.pm \
	lib/SubMan/Controller/Register/Individual.pm \
	blib/lib/SubMan/Controller/Register/Individual.pm \
	lib/SubMan/Controller/Register/Wizard.pm \
	blib/lib/SubMan/Controller/Register/Wizard.pm \
	lib/SubMan/Controller/Root.pm \
	blib/lib/SubMan/Controller/Root.pm \
	lib/SubMan/Controller/User/Home.pm \
	blib/lib/SubMan/Controller/User/Home.pm \
	lib/SubMan/Controller/User/Manage_ips.pm \
	blib/lib/SubMan/Controller/User/Manage_ips.pm \
	lib/SubMan/Controller/User/Manage_users.pm \
	blib/lib/SubMan/Controller/User/Manage_users.pm \
	lib/SubMan/Controller/User/Profile.pm \
	blib/lib/SubMan/Controller/User/Profile.pm \
	lib/SubMan/Controller/Visitor.pm \
	blib/lib/SubMan/Controller/Visitor.pm \
	lib/SubMan/Helpers/Admin/UserDetails.pm \
	blib/lib/SubMan/Helpers/Admin/UserDetails.pm \
	lib/SubMan/Helpers/Common/DateTime.pm \
	blib/lib/SubMan/Helpers/Common/DateTime.pm \
	lib/SubMan/Helpers/Cron/Notifier.pm \
	blib/lib/SubMan/Helpers/Cron/Notifier.pm \
	lib/SubMan/Helpers/Cron/Subscriptions.pm \
	blib/lib/SubMan/Helpers/Cron/Subscriptions.pm \
	lib/SubMan/Helpers/Gateways/Authorize.pm \
	blib/lib/SubMan/Helpers/Gateways/Authorize.pm \
	lib/SubMan/Helpers/Gateways/Braintree.pm \
	blib/lib/SubMan/Helpers/Gateways/Braintree.pm \
	lib/SubMan/Helpers/Gateways/Details.pm \
	blib/lib/SubMan/Helpers/Gateways/Details.pm \
	lib/SubMan/Helpers/Gateways/Stripe.pm \
	blib/lib/SubMan/Helpers/Gateways/Stripe.pm \
	lib/SubMan/Helpers/Stats/Subscribers.pm \
	blib/lib/SubMan/Helpers/Stats/Subscribers.pm \
	lib/SubMan/Helpers/Visitor/Registration.pm \
	blib/lib/SubMan/Helpers/Visitor/Registration.pm \
	lib/SubMan/Model/SubMan.pm \
	blib/lib/SubMan/Model/SubMan.pm \
	lib/SubMan/Model/SubMan.pm.new \
	blib/lib/SubMan/Model/SubMan.pm.new \
	lib/SubMan/Plugin/Alert.pm \
	blib/lib/SubMan/Plugin/Alert.pm \
	lib/SubMan/Plugin/Logger.pm \
	blib/lib/SubMan/Plugin/Logger.pm \
	lib/SubMan/Schema.pm \
	blib/lib/SubMan/Schema.pm \
	lib/SubMan/Schema/Result/AuthorizeUser.pm \
	blib/lib/SubMan/Schema/Result/AuthorizeUser.pm \
	lib/SubMan/Schema/Result/BraintreeUser.pm \
	blib/lib/SubMan/Schema/Result/BraintreeUser.pm \
	lib/SubMan/Schema/Result/Campaign.pm \
	blib/lib/SubMan/Schema/Result/Campaign.pm \
	lib/SubMan/Schema/Result/Code.pm \
	blib/lib/SubMan/Schema/Result/Code.pm \
	lib/SubMan/Schema/Result/Config.pm \
	blib/lib/SubMan/Schema/Result/Config.pm \
	lib/SubMan/Schema/Result/Feature.pm \
	blib/lib/SubMan/Schema/Result/Feature.pm \
	lib/SubMan/Schema/Result/Invoice.pm \
	blib/lib/SubMan/Schema/Result/Invoice.pm \
	lib/SubMan/Schema/Result/IpRange.pm \
	blib/lib/SubMan/Schema/Result/IpRange.pm \
	lib/SubMan/Schema/Result/LinkCampaignsSubscription.pm \
	blib/lib/SubMan/Schema/Result/LinkCampaignsSubscription.pm \
	lib/SubMan/Schema/Result/LinkSubscriptionFeature.pm \
	blib/lib/SubMan/Schema/Result/LinkSubscriptionFeature.pm \
	lib/SubMan/Schema/Result/LinkUserSubscription.pm \
	blib/lib/SubMan/Schema/Result/LinkUserSubscription.pm \
	lib/SubMan/Schema/Result/PeriodUser.pm \
	blib/lib/SubMan/Schema/Result/PeriodUser.pm \
	lib/SubMan/Schema/Result/Registration.pm \
	blib/lib/SubMan/Schema/Result/Registration.pm \
	lib/SubMan/Schema/Result/StripeUser.pm \
	blib/lib/SubMan/Schema/Result/StripeUser.pm \
	lib/SubMan/Schema/Result/Subscription.pm \
	blib/lib/SubMan/Schema/Result/Subscription.pm \
	lib/SubMan/Schema/Result/SubscriptionDowngradeTo.pm \
	blib/lib/SubMan/Schema/Result/SubscriptionDowngradeTo.pm \
	lib/SubMan/Schema/Result/SubscriptionGroup.pm \
	blib/lib/SubMan/Schema/Result/SubscriptionGroup.pm \
	lib/SubMan/Schema/Result/SubscriptionUpgradeTo.pm \
	blib/lib/SubMan/Schema/Result/SubscriptionUpgradeTo.pm \
	lib/SubMan/Schema/Result/Theme.pm \
	blib/lib/SubMan/Schema/Result/Theme.pm \
	lib/SubMan/Schema/Result/Transaction.pm \
	blib/lib/SubMan/Schema/Result/Transaction.pm \
	lib/SubMan/Schema/Result/User.pm \
	blib/lib/SubMan/Schema/Result/User.pm \
	lib/SubMan/Schema/Result/UserPswSetToken.pm \
	blib/lib/SubMan/Schema/Result/UserPswSetToken.pm \
	lib/SubMan/Schema/Result/UserRegistrationToken.pm \
	blib/lib/SubMan/Schema/Result/UserRegistrationToken.pm \
	lib/SubMan/Schema/Result/UserType.pm \
	blib/lib/SubMan/Schema/Result/UserType.pm \
	lib/SubMan/Test/Mechanize.pm \
	blib/lib/SubMan/Test/Mechanize.pm \
	lib/SubMan/Test/Register.pm \
	blib/lib/SubMan/Test/Register.pm \
	lib/SubMan/ValidationRule/Base.pm \
	blib/lib/SubMan/ValidationRule/Base.pm \
	lib/SubMan/ValidationRule/Email.pm \
	blib/lib/SubMan/ValidationRule/Email.pm \
	lib/SubMan/ValidationRule/NotEmpty.pm \
	blib/lib/SubMan/ValidationRule/NotEmpty.pm \
	lib/SubMan/ValidationRule/NotEmptyIfExists.pm \
	blib/lib/SubMan/ValidationRule/NotEmptyIfExists.pm \
	lib/SubMan/ValidationRule/Subscription/CheckAccessType.pm \
	blib/lib/SubMan/ValidationRule/Subscription/CheckAccessType.pm \
	lib/SubMan/ValidationRule/Subscription/CheckTrial.pm \
	blib/lib/SubMan/ValidationRule/Subscription/CheckTrial.pm \
	lib/SubMan/ValidationRule/Subscription/DiscountCodeExists.pm \
	blib/lib/SubMan/ValidationRule/Subscription/DiscountCodeExists.pm \
	lib/SubMan/ValidationRule/Subscription/DiscountCodeNotUsed.pm \
	blib/lib/SubMan/ValidationRule/Subscription/DiscountCodeNotUsed.pm \
	lib/SubMan/ValidationRule/UniqueUser.pm \
	blib/lib/SubMan/ValidationRule/UniqueUser.pm \
	lib/SubMan/ValidationRule/ValidAdmin.pm \
	blib/lib/SubMan/ValidationRule/ValidAdmin.pm \
	lib/SubMan/View/HTML.pm \
	blib/lib/SubMan/View/HTML.pm \
	lib/SubMan/View/JSON.pm \
	blib/lib/SubMan/View/JSON.pm


# --- MakeMaker platform_constants section:
MM_Unix_VERSION = 6.84
PERL_MALLOC_DEF = -DPERL_EXTMALLOC_DEF -Dmalloc=Perl_malloc -Dfree=Perl_mfree -Drealloc=Perl_realloc -Dcalloc=Perl_calloc


# --- MakeMaker tool_autosplit section:
# Usage: $(AUTOSPLITFILE) FileToSplit AutoDirToSplitInto
AUTOSPLITFILE = $(ABSPERLRUN)  -e 'use AutoSplit;  autosplit($$$$ARGV[0], $$$$ARGV[1], 0, 1, 1)' --



# --- MakeMaker tool_xsubpp section:


# --- MakeMaker tools_other section:
SHELL = /bin/sh
CHMOD = chmod
CP = cp
MV = mv
NOOP = $(TRUE)
NOECHO = @
RM_F = rm -f
RM_RF = rm -rf
TEST_F = test -f
TOUCH = touch
UMASK_NULL = umask 0
DEV_NULL = > /dev/null 2>&1
MKPATH = $(ABSPERLRUN) -MExtUtils::Command -e 'mkpath' --
EQUALIZE_TIMESTAMP = $(ABSPERLRUN) -MExtUtils::Command -e 'eqtime' --
FALSE = false
TRUE = true
ECHO = echo
ECHO_N = echo -n
UNINST = 0
VERBINST = 0
MOD_INSTALL = $(ABSPERLRUN) -MExtUtils::Install -e 'install([ from_to => {@ARGV}, verbose => '\''$(VERBINST)'\'', uninstall_shadows => '\''$(UNINST)'\'', dir_mode => '\''$(PERM_DIR)'\'' ]);' --
DOC_INSTALL = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'perllocal_install' --
UNINSTALL = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'uninstall' --
WARN_IF_OLD_PACKLIST = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'warn_if_old_packlist' --
MACROSTART = 
MACROEND = 
USEMAKEFILE = -f
FIXIN = $(ABSPERLRUN) -MExtUtils::MY -e 'MY->fixin(shift)' --
CP_NONEMPTY = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'cp_nonempty' --


# --- MakeMaker makemakerdflt section:
makemakerdflt : all
	$(NOECHO) $(NOOP)


# --- MakeMaker dist section:
TAR = tar
TARFLAGS = cvf
ZIP = zip
ZIPFLAGS = -r
COMPRESS = gzip --best
SUFFIX = .gz
SHAR = shar
PREOP = $(PERL) -I. "-MModule::Install::Admin" -e "dist_preop(q($(DISTVNAME)))"
POSTOP = $(NOECHO) $(NOOP)
TO_UNIX = $(NOECHO) $(NOOP)
CI = ci -u
RCS_LABEL = rcs -Nv$(VERSION_SYM): -q
DIST_CP = best
DIST_DEFAULT = tardist
DISTNAME = SubMan
DISTVNAME = SubMan-0.04


# --- MakeMaker macro section:


# --- MakeMaker depend section:


# --- MakeMaker cflags section:


# --- MakeMaker const_loadlibs section:


# --- MakeMaker const_cccmd section:


# --- MakeMaker post_constants section:


# --- MakeMaker pasthru section:

PASTHRU = LIBPERL_A="$(LIBPERL_A)"\
	LINKTYPE="$(LINKTYPE)"\
	PREFIX="$(PREFIX)"


# --- MakeMaker special_targets section:
.SUFFIXES : .xs .c .C .cpp .i .s .cxx .cc $(OBJ_EXT)

.PHONY: all config static dynamic test linkext manifest blibdirs clean realclean disttest distdir



# --- MakeMaker c_o section:


# --- MakeMaker xs_c section:


# --- MakeMaker xs_o section:


# --- MakeMaker top_targets section:
all :: pure_all manifypods
	$(NOECHO) $(NOOP)


pure_all :: config pm_to_blib subdirs linkext
	$(NOECHO) $(NOOP)

subdirs :: $(MYEXTLIB)
	$(NOECHO) $(NOOP)

config :: $(FIRST_MAKEFILE) blibdirs
	$(NOECHO) $(NOOP)

help :
	perldoc ExtUtils::MakeMaker


# --- MakeMaker blibdirs section:
blibdirs : $(INST_LIBDIR)$(DFSEP).exists $(INST_ARCHLIB)$(DFSEP).exists $(INST_AUTODIR)$(DFSEP).exists $(INST_ARCHAUTODIR)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists $(INST_SCRIPT)$(DFSEP).exists $(INST_MAN1DIR)$(DFSEP).exists $(INST_MAN3DIR)$(DFSEP).exists
	$(NOECHO) $(NOOP)

# Backwards compat with 6.18 through 6.25
blibdirs.ts : blibdirs
	$(NOECHO) $(NOOP)

$(INST_LIBDIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_LIBDIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_LIBDIR)
	$(NOECHO) $(TOUCH) $(INST_LIBDIR)$(DFSEP).exists

$(INST_ARCHLIB)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_ARCHLIB)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_ARCHLIB)
	$(NOECHO) $(TOUCH) $(INST_ARCHLIB)$(DFSEP).exists

$(INST_AUTODIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_AUTODIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_AUTODIR)
	$(NOECHO) $(TOUCH) $(INST_AUTODIR)$(DFSEP).exists

$(INST_ARCHAUTODIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_ARCHAUTODIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_ARCHAUTODIR)
	$(NOECHO) $(TOUCH) $(INST_ARCHAUTODIR)$(DFSEP).exists

$(INST_BIN)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_BIN)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_BIN)
	$(NOECHO) $(TOUCH) $(INST_BIN)$(DFSEP).exists

$(INST_SCRIPT)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_SCRIPT)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_SCRIPT)
	$(NOECHO) $(TOUCH) $(INST_SCRIPT)$(DFSEP).exists

$(INST_MAN1DIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_MAN1DIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_MAN1DIR)
	$(NOECHO) $(TOUCH) $(INST_MAN1DIR)$(DFSEP).exists

$(INST_MAN3DIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_MAN3DIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_MAN3DIR)
	$(NOECHO) $(TOUCH) $(INST_MAN3DIR)$(DFSEP).exists



# --- MakeMaker linkext section:

linkext :: $(LINKTYPE)
	$(NOECHO) $(NOOP)


# --- MakeMaker dlsyms section:


# --- MakeMaker dynamic_bs section:

BOOTSTRAP =


# --- MakeMaker dynamic section:

dynamic :: $(FIRST_MAKEFILE) $(BOOTSTRAP) $(INST_DYNAMIC)
	$(NOECHO) $(NOOP)


# --- MakeMaker dynamic_lib section:


# --- MakeMaker static section:

## $(INST_PM) has been moved to the all: target.
## It remains here for awhile to allow for old usage: "make static"
static :: $(FIRST_MAKEFILE) $(INST_STATIC)
	$(NOECHO) $(NOOP)


# --- MakeMaker static_lib section:


# --- MakeMaker manifypods section:

POD2MAN_EXE = $(PERLRUN) "-MExtUtils::Command::MM" -e pod2man "--"
POD2MAN = $(POD2MAN_EXE)


manifypods : pure_all  \
	lib/SubMan.pm \
	lib/SubMan/Common/Logger.pm \
	lib/SubMan/Controller/API/Base.pm \
	lib/SubMan/Controller/API/Payment.pm \
	lib/SubMan/Controller/API/Pricing.pm \
	lib/SubMan/Controller/API/Register.pm \
	lib/SubMan/Controller/API/Subscriptions.pm \
	lib/SubMan/Controller/Admin/Dashboard.pm \
	lib/SubMan/Controller/Admin/Features.pm \
	lib/SubMan/Controller/Admin/Gateway.pm \
	lib/SubMan/Controller/Admin/Manage_ips.pm \
	lib/SubMan/Controller/Admin/Manage_users.pm \
	lib/SubMan/Controller/Admin/Payment_gateways.pm \
	lib/SubMan/Controller/Admin/Profile.pm \
	lib/SubMan/Controller/Admin/Registration.pm \
	lib/SubMan/Controller/Admin/Stats.pm \
	lib/SubMan/Controller/Admin/SubscriptionGroups.pm \
	lib/SubMan/Controller/Admin/Subscriptions.pm \
	lib/SubMan/Controller/Admin/Subscriptions/Tabs.pm \
	lib/SubMan/Controller/Admin/Subscriptions/add_subscription.pm \
	lib/SubMan/Controller/Admin/Subscriptions/edit_subscription.pm \
	lib/SubMan/Controller/Admin/Themes.pm \
	lib/SubMan/Controller/Admin/Users.pm \
	lib/SubMan/Controller/Authenticated.pm \
	lib/SubMan/Controller/Common/SubscriptionActions.pm \
	lib/SubMan/Controller/Common/User.pm \
	lib/SubMan/Controller/Register.pm \
	lib/SubMan/Controller/Register/Corporate.pm \
	lib/SubMan/Controller/Register/Individual.pm \
	lib/SubMan/Controller/Register/Wizard.pm \
	lib/SubMan/Controller/Root.pm \
	lib/SubMan/Controller/User/Home.pm \
	lib/SubMan/Controller/User/Manage_ips.pm \
	lib/SubMan/Controller/User/Manage_users.pm \
	lib/SubMan/Controller/User/Profile.pm \
	lib/SubMan/Controller/Visitor.pm \
	lib/SubMan/Helpers/Admin/UserDetails.pm \
	lib/SubMan/Helpers/Common/DateTime.pm \
	lib/SubMan/Helpers/Cron/Notifier.pm \
	lib/SubMan/Helpers/Cron/Subscriptions.pm \
	lib/SubMan/Helpers/Gateways/Authorize.pm \
	lib/SubMan/Helpers/Gateways/Braintree.pm \
	lib/SubMan/Helpers/Gateways/Details.pm \
	lib/SubMan/Helpers/Gateways/Stripe.pm \
	lib/SubMan/Helpers/Stats/Subscribers.pm \
	lib/SubMan/Helpers/Visitor/Registration.pm \
	lib/SubMan/Model/SubMan.pm \
	lib/SubMan/Plugin/Alert.pm \
	lib/SubMan/Schema/Result/AuthorizeUser.pm \
	lib/SubMan/Schema/Result/BraintreeUser.pm \
	lib/SubMan/Schema/Result/Invoice.pm \
	lib/SubMan/Schema/Result/StripeUser.pm \
	lib/SubMan/Schema/Result/Transaction.pm \
	lib/SubMan/Test/Mechanize.pm \
	lib/SubMan/Test/Register.pm \
	lib/SubMan/ValidationRule/Base.pm \
	lib/SubMan/ValidationRule/Email.pm \
	lib/SubMan/ValidationRule/NotEmpty.pm \
	lib/SubMan/ValidationRule/NotEmptyIfExists.pm \
	lib/SubMan/ValidationRule/Subscription/CheckAccessType.pm \
	lib/SubMan/ValidationRule/Subscription/CheckTrial.pm \
	lib/SubMan/ValidationRule/Subscription/DiscountCodeExists.pm \
	lib/SubMan/ValidationRule/Subscription/DiscountCodeNotUsed.pm \
	lib/SubMan/ValidationRule/UniqueUser.pm \
	lib/SubMan/ValidationRule/ValidAdmin.pm \
	lib/SubMan/View/HTML.pm \
	script/apply_migrations.pl \
	script/cron_subscriptions.pl \
	script/subman_cgi.pl \
	script/subman_create.pl \
	script/subman_create_admin.pl \
	script/subman_fastcgi.pl \
	script/subman_server.pl \
	script/subman_test.pl
	$(NOECHO) $(POD2MAN) --section=1 --perm_rw=$(PERM_RW) \
	  script/apply_migrations.pl $(INST_MAN1DIR)/apply_migrations.pl.$(MAN1EXT) \
	  script/cron_subscriptions.pl $(INST_MAN1DIR)/cron_subscriptions.pl.$(MAN1EXT) \
	  script/subman_cgi.pl $(INST_MAN1DIR)/subman_cgi.pl.$(MAN1EXT) \
	  script/subman_create.pl $(INST_MAN1DIR)/subman_create.pl.$(MAN1EXT) \
	  script/subman_create_admin.pl $(INST_MAN1DIR)/subman_create_admin.pl.$(MAN1EXT) \
	  script/subman_fastcgi.pl $(INST_MAN1DIR)/subman_fastcgi.pl.$(MAN1EXT) \
	  script/subman_server.pl $(INST_MAN1DIR)/subman_server.pl.$(MAN1EXT) \
	  script/subman_test.pl $(INST_MAN1DIR)/subman_test.pl.$(MAN1EXT) 
	$(NOECHO) $(POD2MAN) --section=3 --perm_rw=$(PERM_RW) \
	  lib/SubMan.pm $(INST_MAN3DIR)/SubMan.$(MAN3EXT) \
	  lib/SubMan/Common/Logger.pm $(INST_MAN3DIR)/SubMan::Common::Logger.$(MAN3EXT) \
	  lib/SubMan/Controller/API/Base.pm $(INST_MAN3DIR)/SubMan::Controller::API::Base.$(MAN3EXT) \
	  lib/SubMan/Controller/API/Payment.pm $(INST_MAN3DIR)/SubMan::Controller::API::Payment.$(MAN3EXT) \
	  lib/SubMan/Controller/API/Pricing.pm $(INST_MAN3DIR)/SubMan::Controller::API::Pricing.$(MAN3EXT) \
	  lib/SubMan/Controller/API/Register.pm $(INST_MAN3DIR)/SubMan::Controller::API::Register.$(MAN3EXT) \
	  lib/SubMan/Controller/API/Subscriptions.pm $(INST_MAN3DIR)/SubMan::Controller::API::Subscriptions.$(MAN3EXT) \
	  lib/SubMan/Controller/Admin/Dashboard.pm $(INST_MAN3DIR)/SubMan::Controller::Admin::Dashboard.$(MAN3EXT) \
	  lib/SubMan/Controller/Admin/Features.pm $(INST_MAN3DIR)/SubMan::Controller::Admin::Features.$(MAN3EXT) \
	  lib/SubMan/Controller/Admin/Gateway.pm $(INST_MAN3DIR)/SubMan::Controller::Admin::Gateway.$(MAN3EXT) \
	  lib/SubMan/Controller/Admin/Manage_ips.pm $(INST_MAN3DIR)/SubMan::Controller::Admin::Manage_ips.$(MAN3EXT) \
	  lib/SubMan/Controller/Admin/Manage_users.pm $(INST_MAN3DIR)/SubMan::Controller::Admin::Manage_users.$(MAN3EXT) \
	  lib/SubMan/Controller/Admin/Payment_gateways.pm $(INST_MAN3DIR)/SubMan::Controller::Admin::Payment_gateways.$(MAN3EXT) \
	  lib/SubMan/Controller/Admin/Profile.pm $(INST_MAN3DIR)/SubMan::Controller::Admin::Profile.$(MAN3EXT) \
	  lib/SubMan/Controller/Admin/Registration.pm $(INST_MAN3DIR)/SubMan::Controller::Admin::Registration.$(MAN3EXT) \
	  lib/SubMan/Controller/Admin/Stats.pm $(INST_MAN3DIR)/SubMan::Controller::Admin::Stats.$(MAN3EXT) \
	  lib/SubMan/Controller/Admin/SubscriptionGroups.pm $(INST_MAN3DIR)/SubMan::Controller::Admin::SubscriptionGroups.$(MAN3EXT) \
	  lib/SubMan/Controller/Admin/Subscriptions.pm $(INST_MAN3DIR)/SubMan::Controller::Admin::Subscriptions.$(MAN3EXT) \
	  lib/SubMan/Controller/Admin/Subscriptions/Tabs.pm $(INST_MAN3DIR)/SubMan::Controller::Admin::Subscriptions::Tabs.$(MAN3EXT) \
	  lib/SubMan/Controller/Admin/Subscriptions/add_subscription.pm $(INST_MAN3DIR)/SubMan::Controller::Admin::Subscriptions::add_subscription.$(MAN3EXT) \
	  lib/SubMan/Controller/Admin/Subscriptions/edit_subscription.pm $(INST_MAN3DIR)/SubMan::Controller::Admin::Subscriptions::edit_subscription.$(MAN3EXT) \
	  lib/SubMan/Controller/Admin/Themes.pm $(INST_MAN3DIR)/SubMan::Controller::Admin::Themes.$(MAN3EXT) \
	  lib/SubMan/Controller/Admin/Users.pm $(INST_MAN3DIR)/SubMan::Controller::Admin::Users.$(MAN3EXT) \
	  lib/SubMan/Controller/Authenticated.pm $(INST_MAN3DIR)/SubMan::Controller::Authenticated.$(MAN3EXT) \
	  lib/SubMan/Controller/Common/SubscriptionActions.pm $(INST_MAN3DIR)/SubMan::Controller::Common::SubscriptionActions.$(MAN3EXT) 
	$(NOECHO) $(POD2MAN) --section=3 --perm_rw=$(PERM_RW) \
	  lib/SubMan/Controller/Common/User.pm $(INST_MAN3DIR)/SubMan::Controller::Common::User.$(MAN3EXT) \
	  lib/SubMan/Controller/Register.pm $(INST_MAN3DIR)/SubMan::Controller::Register.$(MAN3EXT) \
	  lib/SubMan/Controller/Register/Corporate.pm $(INST_MAN3DIR)/SubMan::Controller::Register::Corporate.$(MAN3EXT) \
	  lib/SubMan/Controller/Register/Individual.pm $(INST_MAN3DIR)/SubMan::Controller::Register::Individual.$(MAN3EXT) \
	  lib/SubMan/Controller/Register/Wizard.pm $(INST_MAN3DIR)/SubMan::Controller::Register::Wizard.$(MAN3EXT) \
	  lib/SubMan/Controller/Root.pm $(INST_MAN3DIR)/SubMan::Controller::Root.$(MAN3EXT) \
	  lib/SubMan/Controller/User/Home.pm $(INST_MAN3DIR)/SubMan::Controller::User::Home.$(MAN3EXT) \
	  lib/SubMan/Controller/User/Manage_ips.pm $(INST_MAN3DIR)/SubMan::Controller::User::Manage_ips.$(MAN3EXT) \
	  lib/SubMan/Controller/User/Manage_users.pm $(INST_MAN3DIR)/SubMan::Controller::User::Manage_users.$(MAN3EXT) \
	  lib/SubMan/Controller/User/Profile.pm $(INST_MAN3DIR)/SubMan::Controller::User::Profile.$(MAN3EXT) \
	  lib/SubMan/Controller/Visitor.pm $(INST_MAN3DIR)/SubMan::Controller::Visitor.$(MAN3EXT) \
	  lib/SubMan/Helpers/Admin/UserDetails.pm $(INST_MAN3DIR)/SubMan::Helpers::Admin::UserDetails.$(MAN3EXT) \
	  lib/SubMan/Helpers/Common/DateTime.pm $(INST_MAN3DIR)/SubMan::Helpers::Common::DateTime.$(MAN3EXT) \
	  lib/SubMan/Helpers/Cron/Notifier.pm $(INST_MAN3DIR)/SubMan::Helpers::Cron::Notifier.$(MAN3EXT) \
	  lib/SubMan/Helpers/Cron/Subscriptions.pm $(INST_MAN3DIR)/SubMan::Helpers::Cron::Subscriptions.$(MAN3EXT) \
	  lib/SubMan/Helpers/Gateways/Authorize.pm $(INST_MAN3DIR)/SubMan::Helpers::Gateways::Authorize.$(MAN3EXT) \
	  lib/SubMan/Helpers/Gateways/Braintree.pm $(INST_MAN3DIR)/SubMan::Helpers::Gateways::Braintree.$(MAN3EXT) \
	  lib/SubMan/Helpers/Gateways/Details.pm $(INST_MAN3DIR)/SubMan::Helpers::Gateways::Details.$(MAN3EXT) \
	  lib/SubMan/Helpers/Gateways/Stripe.pm $(INST_MAN3DIR)/SubMan::Helpers::Gateways::Stripe.$(MAN3EXT) \
	  lib/SubMan/Helpers/Stats/Subscribers.pm $(INST_MAN3DIR)/SubMan::Helpers::Stats::Subscribers.$(MAN3EXT) \
	  lib/SubMan/Helpers/Visitor/Registration.pm $(INST_MAN3DIR)/SubMan::Helpers::Visitor::Registration.$(MAN3EXT) \
	  lib/SubMan/Model/SubMan.pm $(INST_MAN3DIR)/SubMan::Model::SubMan.$(MAN3EXT) \
	  lib/SubMan/Plugin/Alert.pm $(INST_MAN3DIR)/SubMan::Plugin::Alert.$(MAN3EXT) \
	  lib/SubMan/Schema/Result/AuthorizeUser.pm $(INST_MAN3DIR)/SubMan::Schema::Result::AuthorizeUser.$(MAN3EXT) \
	  lib/SubMan/Schema/Result/BraintreeUser.pm $(INST_MAN3DIR)/SubMan::Schema::Result::BraintreeUser.$(MAN3EXT) \
	  lib/SubMan/Schema/Result/Invoice.pm $(INST_MAN3DIR)/SubMan::Schema::Result::Invoice.$(MAN3EXT) \
	  lib/SubMan/Schema/Result/StripeUser.pm $(INST_MAN3DIR)/SubMan::Schema::Result::StripeUser.$(MAN3EXT) 
	$(NOECHO) $(POD2MAN) --section=3 --perm_rw=$(PERM_RW) \
	  lib/SubMan/Schema/Result/Transaction.pm $(INST_MAN3DIR)/SubMan::Schema::Result::Transaction.$(MAN3EXT) \
	  lib/SubMan/Test/Mechanize.pm $(INST_MAN3DIR)/SubMan::Test::Mechanize.$(MAN3EXT) \
	  lib/SubMan/Test/Register.pm $(INST_MAN3DIR)/SubMan::Test::Register.$(MAN3EXT) \
	  lib/SubMan/ValidationRule/Base.pm $(INST_MAN3DIR)/SubMan::ValidationRule::Base.$(MAN3EXT) \
	  lib/SubMan/ValidationRule/Email.pm $(INST_MAN3DIR)/SubMan::ValidationRule::Email.$(MAN3EXT) \
	  lib/SubMan/ValidationRule/NotEmpty.pm $(INST_MAN3DIR)/SubMan::ValidationRule::NotEmpty.$(MAN3EXT) \
	  lib/SubMan/ValidationRule/NotEmptyIfExists.pm $(INST_MAN3DIR)/SubMan::ValidationRule::NotEmptyIfExists.$(MAN3EXT) \
	  lib/SubMan/ValidationRule/Subscription/CheckAccessType.pm $(INST_MAN3DIR)/SubMan::ValidationRule::Subscription::CheckAccessType.$(MAN3EXT) \
	  lib/SubMan/ValidationRule/Subscription/CheckTrial.pm $(INST_MAN3DIR)/SubMan::ValidationRule::Subscription::CheckTrial.$(MAN3EXT) \
	  lib/SubMan/ValidationRule/Subscription/DiscountCodeExists.pm $(INST_MAN3DIR)/SubMan::ValidationRule::Subscription::DiscountCodeExists.$(MAN3EXT) \
	  lib/SubMan/ValidationRule/Subscription/DiscountCodeNotUsed.pm $(INST_MAN3DIR)/SubMan::ValidationRule::Subscription::DiscountCodeNotUsed.$(MAN3EXT) \
	  lib/SubMan/ValidationRule/UniqueUser.pm $(INST_MAN3DIR)/SubMan::ValidationRule::UniqueUser.$(MAN3EXT) \
	  lib/SubMan/ValidationRule/ValidAdmin.pm $(INST_MAN3DIR)/SubMan::ValidationRule::ValidAdmin.$(MAN3EXT) \
	  lib/SubMan/View/HTML.pm $(INST_MAN3DIR)/SubMan::View::HTML.$(MAN3EXT) 




# --- MakeMaker processPL section:


# --- MakeMaker installbin section:

EXE_FILES = script/apply_migrations.pl script/cron_subscriptions.pl script/subman_cgi.pl script/subman_create.pl script/subman_create_admin.pl script/subman_fastcgi.pl script/subman_server.pl script/subman_test.pl

pure_all :: $(INST_SCRIPT)/subman_create_admin.pl $(INST_SCRIPT)/apply_migrations.pl $(INST_SCRIPT)/subman_create.pl $(INST_SCRIPT)/subman_fastcgi.pl $(INST_SCRIPT)/cron_subscriptions.pl $(INST_SCRIPT)/subman_server.pl $(INST_SCRIPT)/subman_cgi.pl $(INST_SCRIPT)/subman_test.pl
	$(NOECHO) $(NOOP)

realclean ::
	$(RM_F) \
	  $(INST_SCRIPT)/subman_create_admin.pl $(INST_SCRIPT)/apply_migrations.pl \
	  $(INST_SCRIPT)/subman_create.pl $(INST_SCRIPT)/subman_fastcgi.pl \
	  $(INST_SCRIPT)/cron_subscriptions.pl $(INST_SCRIPT)/subman_server.pl \
	  $(INST_SCRIPT)/subman_cgi.pl $(INST_SCRIPT)/subman_test.pl 

$(INST_SCRIPT)/subman_create_admin.pl : script/subman_create_admin.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/subman_create_admin.pl
	$(CP) script/subman_create_admin.pl $(INST_SCRIPT)/subman_create_admin.pl
	$(FIXIN) $(INST_SCRIPT)/subman_create_admin.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/subman_create_admin.pl

$(INST_SCRIPT)/apply_migrations.pl : script/apply_migrations.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/apply_migrations.pl
	$(CP) script/apply_migrations.pl $(INST_SCRIPT)/apply_migrations.pl
	$(FIXIN) $(INST_SCRIPT)/apply_migrations.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/apply_migrations.pl

$(INST_SCRIPT)/subman_create.pl : script/subman_create.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/subman_create.pl
	$(CP) script/subman_create.pl $(INST_SCRIPT)/subman_create.pl
	$(FIXIN) $(INST_SCRIPT)/subman_create.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/subman_create.pl

$(INST_SCRIPT)/subman_fastcgi.pl : script/subman_fastcgi.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/subman_fastcgi.pl
	$(CP) script/subman_fastcgi.pl $(INST_SCRIPT)/subman_fastcgi.pl
	$(FIXIN) $(INST_SCRIPT)/subman_fastcgi.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/subman_fastcgi.pl

$(INST_SCRIPT)/cron_subscriptions.pl : script/cron_subscriptions.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/cron_subscriptions.pl
	$(CP) script/cron_subscriptions.pl $(INST_SCRIPT)/cron_subscriptions.pl
	$(FIXIN) $(INST_SCRIPT)/cron_subscriptions.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/cron_subscriptions.pl

$(INST_SCRIPT)/subman_server.pl : script/subman_server.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/subman_server.pl
	$(CP) script/subman_server.pl $(INST_SCRIPT)/subman_server.pl
	$(FIXIN) $(INST_SCRIPT)/subman_server.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/subman_server.pl

$(INST_SCRIPT)/subman_cgi.pl : script/subman_cgi.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/subman_cgi.pl
	$(CP) script/subman_cgi.pl $(INST_SCRIPT)/subman_cgi.pl
	$(FIXIN) $(INST_SCRIPT)/subman_cgi.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/subman_cgi.pl

$(INST_SCRIPT)/subman_test.pl : script/subman_test.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/subman_test.pl
	$(CP) script/subman_test.pl $(INST_SCRIPT)/subman_test.pl
	$(FIXIN) $(INST_SCRIPT)/subman_test.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/subman_test.pl



# --- MakeMaker subdirs section:

# none

# --- MakeMaker clean_subdirs section:
clean_subdirs :
	$(NOECHO) $(NOOP)


# --- MakeMaker clean section:

# Delete temporary files but do not touch installed files. We don't delete
# the Makefile here so a later make realclean still has a makefile to use.

clean :: clean_subdirs
	- $(RM_F) \
	  $(BASEEXT).bso $(BASEEXT).def \
	  $(BASEEXT).exp $(BASEEXT).x \
	  $(BOOTSTRAP) $(INST_ARCHAUTODIR)/extralibs.all \
	  $(INST_ARCHAUTODIR)/extralibs.ld $(MAKE_APERL_FILE) \
	  *$(LIB_EXT) *$(OBJ_EXT) \
	  *perl.core MYMETA.json \
	  MYMETA.yml blibdirs.ts \
	  core core.*perl.*.? \
	  core.[0-9] core.[0-9][0-9] \
	  core.[0-9][0-9][0-9] core.[0-9][0-9][0-9][0-9] \
	  core.[0-9][0-9][0-9][0-9][0-9] lib$(BASEEXT).def \
	  mon.out perl \
	  perl$(EXE_EXT) perl.exe \
	  perlmain.c pm_to_blib \
	  pm_to_blib.ts so_locations \
	  tmon.out 
	- $(RM_RF) \
	  blib 
	  $(NOECHO) $(RM_F) $(MAKEFILE_OLD)
	- $(MV) $(FIRST_MAKEFILE) $(MAKEFILE_OLD) $(DEV_NULL)


# --- MakeMaker realclean_subdirs section:
realclean_subdirs :
	$(NOECHO) $(NOOP)


# --- MakeMaker realclean section:
# Delete temporary files (via clean) and also delete dist files
realclean purge ::  clean realclean_subdirs
	- $(RM_F) \
	  $(MAKEFILE_OLD) $(FIRST_MAKEFILE) 
	- $(RM_RF) \
	  MYMETA.yml $(DISTVNAME) 


# --- MakeMaker metafile section:
metafile :
	$(NOECHO) $(NOOP)


# --- MakeMaker signature section:
signature :
	cpansign -s


# --- MakeMaker dist_basics section:
distclean :: realclean distcheck
	$(NOECHO) $(NOOP)

distcheck :
	$(PERLRUN) "-MExtUtils::Manifest=fullcheck" -e fullcheck

skipcheck :
	$(PERLRUN) "-MExtUtils::Manifest=skipcheck" -e skipcheck

manifest :
	$(PERLRUN) "-MExtUtils::Manifest=mkmanifest" -e mkmanifest

veryclean : realclean
	$(RM_F) *~ */*~ *.orig */*.orig *.bak */*.bak *.old */*.old



# --- MakeMaker dist_core section:

dist : $(DIST_DEFAULT) $(FIRST_MAKEFILE)
	$(NOECHO) $(ABSPERLRUN) -l -e 'print '\''Warning: Makefile possibly out of date with $(VERSION_FROM)'\''' \
	  -e '    if -e '\''$(VERSION_FROM)'\'' and -M '\''$(VERSION_FROM)'\'' < -M '\''$(FIRST_MAKEFILE)'\'';' --

tardist : $(DISTVNAME).tar$(SUFFIX)
	$(NOECHO) $(NOOP)

uutardist : $(DISTVNAME).tar$(SUFFIX)
	uuencode $(DISTVNAME).tar$(SUFFIX) $(DISTVNAME).tar$(SUFFIX) > $(DISTVNAME).tar$(SUFFIX)_uu
	$(NOECHO) $(ECHO) 'Created $(DISTVNAME).tar$(SUFFIX)_uu'

$(DISTVNAME).tar$(SUFFIX) : distdir
	$(PREOP)
	$(TO_UNIX)
	$(TAR) $(TARFLAGS) $(DISTVNAME).tar $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(COMPRESS) $(DISTVNAME).tar
	$(NOECHO) $(ECHO) 'Created $(DISTVNAME).tar$(SUFFIX)'
	$(POSTOP)

zipdist : $(DISTVNAME).zip
	$(NOECHO) $(NOOP)

$(DISTVNAME).zip : distdir
	$(PREOP)
	$(ZIP) $(ZIPFLAGS) $(DISTVNAME).zip $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(NOECHO) $(ECHO) 'Created $(DISTVNAME).zip'
	$(POSTOP)

shdist : distdir
	$(PREOP)
	$(SHAR) $(DISTVNAME) > $(DISTVNAME).shar
	$(RM_RF) $(DISTVNAME)
	$(NOECHO) $(ECHO) 'Created $(DISTVNAME).shar'
	$(POSTOP)


# --- MakeMaker distdir section:
create_distdir :
	$(RM_RF) $(DISTVNAME)
	$(PERLRUN) "-MExtUtils::Manifest=manicopy,maniread" \
		-e "manicopy(maniread(),'$(DISTVNAME)', '$(DIST_CP)');"

distdir : create_distdir  
	$(NOECHO) $(NOOP)



# --- MakeMaker dist_test section:
disttest : distdir
	cd $(DISTVNAME) && $(ABSPERLRUN) Makefile.PL 
	cd $(DISTVNAME) && $(MAKE) $(PASTHRU)
	cd $(DISTVNAME) && $(MAKE) test $(PASTHRU)



# --- MakeMaker dist_ci section:

ci :
	$(PERLRUN) "-MExtUtils::Manifest=maniread" \
	  -e "@all = keys %{ maniread() };" \
	  -e "print(qq{Executing $(CI) @all\n}); system(qq{$(CI) @all});" \
	  -e "print(qq{Executing $(RCS_LABEL) ...\n}); system(qq{$(RCS_LABEL) @all});"


# --- MakeMaker distmeta section:
distmeta : create_distdir metafile
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'exit unless -e q{META.yml};' \
	  -e 'eval { maniadd({q{META.yml} => q{Module YAML meta-data (added by MakeMaker)}}) }' \
	  -e '    or print "Could not add META.yml to MANIFEST: $$$${'\''@'\''}\n"' --
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'exit unless -f q{META.json};' \
	  -e 'eval { maniadd({q{META.json} => q{Module JSON meta-data (added by MakeMaker)}}) }' \
	  -e '    or print "Could not add META.json to MANIFEST: $$$${'\''@'\''}\n"' --



# --- MakeMaker distsignature section:
distsignature : create_distdir
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'eval { maniadd({q{SIGNATURE} => q{Public-key signature (added by MakeMaker)}}) }' \
	  -e '    or print "Could not add SIGNATURE to MANIFEST: $$$${'\''@'\''}\n"' --
	$(NOECHO) cd $(DISTVNAME) && $(TOUCH) SIGNATURE
	cd $(DISTVNAME) && cpansign -s



# --- MakeMaker install section:

install :: pure_install doc_install
	$(NOECHO) $(NOOP)

install_perl :: pure_perl_install doc_perl_install
	$(NOECHO) $(NOOP)

install_site :: pure_site_install doc_site_install
	$(NOECHO) $(NOOP)

install_vendor :: pure_vendor_install doc_vendor_install
	$(NOECHO) $(NOOP)

pure_install :: pure_$(INSTALLDIRS)_install
	$(NOECHO) $(NOOP)

doc_install :: doc_$(INSTALLDIRS)_install
	$(NOECHO) $(NOOP)

pure__install : pure_site_install
	$(NOECHO) $(ECHO) INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

doc__install : doc_site_install
	$(NOECHO) $(ECHO) INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

pure_perl_install :: all
	$(NOECHO) $(MOD_INSTALL) \
		read $(PERL_ARCHLIB)/auto/$(FULLEXT)/.packlist \
		write $(DESTINSTALLARCHLIB)/auto/$(FULLEXT)/.packlist \
		$(INST_LIB) $(DESTINSTALLPRIVLIB) \
		$(INST_ARCHLIB) $(DESTINSTALLARCHLIB) \
		$(INST_BIN) $(DESTINSTALLBIN) \
		$(INST_SCRIPT) $(DESTINSTALLSCRIPT) \
		$(INST_MAN1DIR) $(DESTINSTALLMAN1DIR) \
		$(INST_MAN3DIR) $(DESTINSTALLMAN3DIR)
	$(NOECHO) $(WARN_IF_OLD_PACKLIST) \
		$(SITEARCHEXP)/auto/$(FULLEXT)


pure_site_install :: all
	$(NOECHO) $(MOD_INSTALL) \
		read $(SITEARCHEXP)/auto/$(FULLEXT)/.packlist \
		write $(DESTINSTALLSITEARCH)/auto/$(FULLEXT)/.packlist \
		$(INST_LIB) $(DESTINSTALLSITELIB) \
		$(INST_ARCHLIB) $(DESTINSTALLSITEARCH) \
		$(INST_BIN) $(DESTINSTALLSITEBIN) \
		$(INST_SCRIPT) $(DESTINSTALLSITESCRIPT) \
		$(INST_MAN1DIR) $(DESTINSTALLSITEMAN1DIR) \
		$(INST_MAN3DIR) $(DESTINSTALLSITEMAN3DIR)
	$(NOECHO) $(WARN_IF_OLD_PACKLIST) \
		$(PERL_ARCHLIB)/auto/$(FULLEXT)

pure_vendor_install :: all
	$(NOECHO) $(MOD_INSTALL) \
		read $(VENDORARCHEXP)/auto/$(FULLEXT)/.packlist \
		write $(DESTINSTALLVENDORARCH)/auto/$(FULLEXT)/.packlist \
		$(INST_LIB) $(DESTINSTALLVENDORLIB) \
		$(INST_ARCHLIB) $(DESTINSTALLVENDORARCH) \
		$(INST_BIN) $(DESTINSTALLVENDORBIN) \
		$(INST_SCRIPT) $(DESTINSTALLVENDORSCRIPT) \
		$(INST_MAN1DIR) $(DESTINSTALLVENDORMAN1DIR) \
		$(INST_MAN3DIR) $(DESTINSTALLVENDORMAN3DIR)


doc_perl_install :: all
	$(NOECHO) $(ECHO) Appending installation info to $(DESTINSTALLARCHLIB)/perllocal.pod
	-$(NOECHO) $(MKPATH) $(DESTINSTALLARCHLIB)
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLPRIVLIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(DESTINSTALLARCHLIB)/perllocal.pod

doc_site_install :: all
	$(NOECHO) $(ECHO) Appending installation info to $(DESTINSTALLARCHLIB)/perllocal.pod
	-$(NOECHO) $(MKPATH) $(DESTINSTALLARCHLIB)
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLSITELIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(DESTINSTALLARCHLIB)/perllocal.pod

doc_vendor_install :: all
	$(NOECHO) $(ECHO) Appending installation info to $(DESTINSTALLARCHLIB)/perllocal.pod
	-$(NOECHO) $(MKPATH) $(DESTINSTALLARCHLIB)
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLVENDORLIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(DESTINSTALLARCHLIB)/perllocal.pod


uninstall :: uninstall_from_$(INSTALLDIRS)dirs
	$(NOECHO) $(NOOP)

uninstall_from_perldirs ::
	$(NOECHO) $(UNINSTALL) $(PERL_ARCHLIB)/auto/$(FULLEXT)/.packlist

uninstall_from_sitedirs ::
	$(NOECHO) $(UNINSTALL) $(SITEARCHEXP)/auto/$(FULLEXT)/.packlist

uninstall_from_vendordirs ::
	$(NOECHO) $(UNINSTALL) $(VENDORARCHEXP)/auto/$(FULLEXT)/.packlist


# --- MakeMaker force section:
# Phony target to force checking subdirectories.
FORCE :
	$(NOECHO) $(NOOP)


# --- MakeMaker perldepend section:


# --- MakeMaker makefile section:
# We take a very conservative approach here, but it's worth it.
# We move Makefile to Makefile.old here to avoid gnu make looping.
$(FIRST_MAKEFILE) : Makefile.PL $(CONFIGDEP)
	$(NOECHO) $(ECHO) "Makefile out-of-date with respect to $?"
	$(NOECHO) $(ECHO) "Cleaning current config before rebuilding Makefile..."
	-$(NOECHO) $(RM_F) $(MAKEFILE_OLD)
	-$(NOECHO) $(MV)   $(FIRST_MAKEFILE) $(MAKEFILE_OLD)
	- $(MAKE) $(USEMAKEFILE) $(MAKEFILE_OLD) clean $(DEV_NULL)
	$(PERLRUN) Makefile.PL 
	$(NOECHO) $(ECHO) "==> Your Makefile has been rebuilt. <=="
	$(NOECHO) $(ECHO) "==> Please rerun the $(MAKE) command.  <=="
	$(FALSE)



# --- MakeMaker staticmake section:

# --- MakeMaker makeaperl section ---
MAP_TARGET    = perl
FULLPERL      = /usr/bin/perl

$(MAP_TARGET) :: static $(MAKE_APERL_FILE)
	$(MAKE) $(USEMAKEFILE) $(MAKE_APERL_FILE) $@

$(MAKE_APERL_FILE) : $(FIRST_MAKEFILE) pm_to_blib
	$(NOECHO) $(ECHO) Writing \"$(MAKE_APERL_FILE)\" for this $(MAP_TARGET)
	$(NOECHO) $(PERLRUNINST) \
		Makefile.PL DIR= \
		MAKEFILE=$(MAKE_APERL_FILE) LINKTYPE=static \
		MAKEAPERL=1 NORECURS=1 CCCDLFLAGS=


# --- MakeMaker test section:

TEST_VERBOSE=0
TEST_TYPE=test_$(LINKTYPE)
TEST_FILE = test.pl
TEST_FILES = t/01app.t t/02pod.t t/03podcoverage.t t/Auth.t t/controller_Admin-Dashboard.t t/controller_Admin-DiscountCodes.t t/controller_Admin-Features.t t/controller_Admin-Manage_ips.t t/controller_Admin-Payment_gateways.t t/controller_Admin-Profile.t t/controller_Admin-Registration.t t/controller_Admin-Subscription.t t/controller_Admin-SubscriptionGroup.t t/controller_Admin-Themes.t t/controller_Admin-UpgradeDowngrade.t t/controller_Admin-Users.t t/controller_Dashboard.t t/controller_Home.t t/controller_User-Profile.t t/helper_Cron_Subscriptions.t t/model_SubMan.t t/Public-Links.t t/Registration.t t/view_HTML.t
TESTDB_SW = -d

testdb :: testdb_$(LINKTYPE)

test :: $(TEST_TYPE) subdirs-test

subdirs-test ::
	$(NOECHO) $(NOOP)


test_dynamic :: pure_all
	PERL_DL_NONLAZY=1 $(FULLPERLRUN) "-MExtUtils::Command::MM" "-MTest::Harness" "-e" "undef *Test::Harness::Switches; test_harness($(TEST_VERBOSE), 'inc', '$(INST_LIB)', '$(INST_ARCHLIB)')" $(TEST_FILES)

testdb_dynamic :: pure_all
	PERL_DL_NONLAZY=1 $(FULLPERLRUN) $(TESTDB_SW) "-Iinc" "-I$(INST_LIB)" "-I$(INST_ARCHLIB)" $(TEST_FILE)

test_ : test_dynamic

test_static :: test_dynamic
testdb_static :: testdb_dynamic


# --- MakeMaker ppd section:
# Creates a PPD (Perl Package Description) for a binary distribution.
ppd :
	$(NOECHO) $(ECHO) '<SOFTPKG NAME="$(DISTNAME)" VERSION="$(VERSION)">' > $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <ABSTRACT>Catalyst based application</ABSTRACT>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <AUTHOR>natasha</AUTHOR>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <IMPLEMENTATION>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Business::AuthorizeNet::CIM" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Business::Stripe" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Action::RenderView" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Authentication::Store::DBIx::Class" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Controller::REST" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Devel" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Plugin::Authentication" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Plugin::ConfigLoader" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Plugin::Log::Handler" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Plugin::Session::State::Cookie" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Plugin::Session::Store::File" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Plugin::Static::Simple" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Restarter" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::Runtime" VERSION="5.90019" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::ScriptRunner" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::View::JSON" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Catalyst::View::TT" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Config::General" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="DBD::Pg" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="DBIx::Class" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="DBIx::Class::PassphraseColumn" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Date::Calc" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="DateTime::" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="DateTime::Format::MySQL" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="DateTime::Format::Pg" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Imager::" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="JSON::" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="JSON::XS" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="LWP::Protocol::https" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Log::Log4perl" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="MIME::Base64" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Mail::Sendmail" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Moose::" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="MooseX::MarkAsMethods" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="MooseX::NonMoose" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Net::Braintree" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Net::IP" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="SQL::Translator" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="String::Random" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Template::" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Template::Plugin::Number::Format" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Term::ReadKey" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Test::HTML::Form" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Test::WWW::Mechanize::Catalyst" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="Try::Tiny" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="YAML::Tiny" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <REQUIRE NAME="namespace::autoclean" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <ARCHITECTURE NAME="i486-linux-gnu-thread-multi-64int-5.14" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <CODEBASE HREF="" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    </IMPLEMENTATION>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '</SOFTPKG>' >> $(DISTNAME).ppd


# --- MakeMaker pm_to_blib section:

pm_to_blib : $(FIRST_MAKEFILE) $(TO_INST_PM)
	$(NOECHO) $(ABSPERLRUN) -MExtUtils::Install -e 'pm_to_blib({@ARGV}, '\''$(INST_LIB)/auto'\'', q[$(PM_FILTER)], '\''$(PERM_DIR)'\'')' -- \
	  lib/SubMan.pm blib/lib/SubMan.pm \
	  lib/SubMan/Common/Logger.pm blib/lib/SubMan/Common/Logger.pm \
	  lib/SubMan/Controller/API/Base.pm blib/lib/SubMan/Controller/API/Base.pm \
	  lib/SubMan/Controller/API/Payment.pm blib/lib/SubMan/Controller/API/Payment.pm \
	  lib/SubMan/Controller/API/Pricing.pm blib/lib/SubMan/Controller/API/Pricing.pm \
	  lib/SubMan/Controller/API/Register.pm blib/lib/SubMan/Controller/API/Register.pm \
	  lib/SubMan/Controller/API/Subscriptions.pm blib/lib/SubMan/Controller/API/Subscriptions.pm \
	  lib/SubMan/Controller/Admin/Dashboard.pm blib/lib/SubMan/Controller/Admin/Dashboard.pm \
	  lib/SubMan/Controller/Admin/Features.pm blib/lib/SubMan/Controller/Admin/Features.pm \
	  lib/SubMan/Controller/Admin/Gateway.pm blib/lib/SubMan/Controller/Admin/Gateway.pm \
	  lib/SubMan/Controller/Admin/Manage_ips.pm blib/lib/SubMan/Controller/Admin/Manage_ips.pm \
	  lib/SubMan/Controller/Admin/Manage_users.pm blib/lib/SubMan/Controller/Admin/Manage_users.pm \
	  lib/SubMan/Controller/Admin/Payment_gateways.pm blib/lib/SubMan/Controller/Admin/Payment_gateways.pm \
	  lib/SubMan/Controller/Admin/Profile.pm blib/lib/SubMan/Controller/Admin/Profile.pm \
	  lib/SubMan/Controller/Admin/Registration.pm blib/lib/SubMan/Controller/Admin/Registration.pm \
	  lib/SubMan/Controller/Admin/Stats.pm blib/lib/SubMan/Controller/Admin/Stats.pm \
	  lib/SubMan/Controller/Admin/SubscriptionGroups.pm blib/lib/SubMan/Controller/Admin/SubscriptionGroups.pm \
	  lib/SubMan/Controller/Admin/Subscriptions.pm blib/lib/SubMan/Controller/Admin/Subscriptions.pm \
	  lib/SubMan/Controller/Admin/Subscriptions/Tabs.pm blib/lib/SubMan/Controller/Admin/Subscriptions/Tabs.pm \
	  lib/SubMan/Controller/Admin/Subscriptions/add_subscription.pm blib/lib/SubMan/Controller/Admin/Subscriptions/add_subscription.pm \
	  lib/SubMan/Controller/Admin/Subscriptions/edit_subscription.pm blib/lib/SubMan/Controller/Admin/Subscriptions/edit_subscription.pm \
	  lib/SubMan/Controller/Admin/Themes.pm blib/lib/SubMan/Controller/Admin/Themes.pm \
	  lib/SubMan/Controller/Admin/Users.pm blib/lib/SubMan/Controller/Admin/Users.pm \
	  lib/SubMan/Controller/Authenticated.pm blib/lib/SubMan/Controller/Authenticated.pm \
	  lib/SubMan/Controller/Common/SubscriptionActions.pm blib/lib/SubMan/Controller/Common/SubscriptionActions.pm \
	  lib/SubMan/Controller/Common/User.pm blib/lib/SubMan/Controller/Common/User.pm \
	  lib/SubMan/Controller/Register.pm blib/lib/SubMan/Controller/Register.pm \
	  lib/SubMan/Controller/Register/Corporate.pm blib/lib/SubMan/Controller/Register/Corporate.pm \
	  lib/SubMan/Controller/Register/Individual.pm blib/lib/SubMan/Controller/Register/Individual.pm 
	$(NOECHO) $(ABSPERLRUN) -MExtUtils::Install -e 'pm_to_blib({@ARGV}, '\''$(INST_LIB)/auto'\'', q[$(PM_FILTER)], '\''$(PERM_DIR)'\'')' -- \
	  lib/SubMan/Controller/Register/Wizard.pm blib/lib/SubMan/Controller/Register/Wizard.pm \
	  lib/SubMan/Controller/Root.pm blib/lib/SubMan/Controller/Root.pm \
	  lib/SubMan/Controller/User/Home.pm blib/lib/SubMan/Controller/User/Home.pm \
	  lib/SubMan/Controller/User/Manage_ips.pm blib/lib/SubMan/Controller/User/Manage_ips.pm \
	  lib/SubMan/Controller/User/Manage_users.pm blib/lib/SubMan/Controller/User/Manage_users.pm \
	  lib/SubMan/Controller/User/Profile.pm blib/lib/SubMan/Controller/User/Profile.pm \
	  lib/SubMan/Controller/Visitor.pm blib/lib/SubMan/Controller/Visitor.pm \
	  lib/SubMan/Helpers/Admin/UserDetails.pm blib/lib/SubMan/Helpers/Admin/UserDetails.pm \
	  lib/SubMan/Helpers/Common/DateTime.pm blib/lib/SubMan/Helpers/Common/DateTime.pm \
	  lib/SubMan/Helpers/Cron/Notifier.pm blib/lib/SubMan/Helpers/Cron/Notifier.pm \
	  lib/SubMan/Helpers/Cron/Subscriptions.pm blib/lib/SubMan/Helpers/Cron/Subscriptions.pm \
	  lib/SubMan/Helpers/Gateways/Authorize.pm blib/lib/SubMan/Helpers/Gateways/Authorize.pm \
	  lib/SubMan/Helpers/Gateways/Braintree.pm blib/lib/SubMan/Helpers/Gateways/Braintree.pm \
	  lib/SubMan/Helpers/Gateways/Details.pm blib/lib/SubMan/Helpers/Gateways/Details.pm \
	  lib/SubMan/Helpers/Gateways/Stripe.pm blib/lib/SubMan/Helpers/Gateways/Stripe.pm \
	  lib/SubMan/Helpers/Stats/Subscribers.pm blib/lib/SubMan/Helpers/Stats/Subscribers.pm \
	  lib/SubMan/Helpers/Visitor/Registration.pm blib/lib/SubMan/Helpers/Visitor/Registration.pm \
	  lib/SubMan/Model/SubMan.pm blib/lib/SubMan/Model/SubMan.pm \
	  lib/SubMan/Model/SubMan.pm.new blib/lib/SubMan/Model/SubMan.pm.new \
	  lib/SubMan/Plugin/Alert.pm blib/lib/SubMan/Plugin/Alert.pm \
	  lib/SubMan/Plugin/Logger.pm blib/lib/SubMan/Plugin/Logger.pm \
	  lib/SubMan/Schema.pm blib/lib/SubMan/Schema.pm \
	  lib/SubMan/Schema/Result/AuthorizeUser.pm blib/lib/SubMan/Schema/Result/AuthorizeUser.pm \
	  lib/SubMan/Schema/Result/BraintreeUser.pm blib/lib/SubMan/Schema/Result/BraintreeUser.pm \
	  lib/SubMan/Schema/Result/Campaign.pm blib/lib/SubMan/Schema/Result/Campaign.pm \
	  lib/SubMan/Schema/Result/Code.pm blib/lib/SubMan/Schema/Result/Code.pm \
	  lib/SubMan/Schema/Result/Config.pm blib/lib/SubMan/Schema/Result/Config.pm \
	  lib/SubMan/Schema/Result/Feature.pm blib/lib/SubMan/Schema/Result/Feature.pm \
	  lib/SubMan/Schema/Result/Invoice.pm blib/lib/SubMan/Schema/Result/Invoice.pm \
	  lib/SubMan/Schema/Result/IpRange.pm blib/lib/SubMan/Schema/Result/IpRange.pm \
	  lib/SubMan/Schema/Result/LinkCampaignsSubscription.pm blib/lib/SubMan/Schema/Result/LinkCampaignsSubscription.pm \
	  lib/SubMan/Schema/Result/LinkSubscriptionFeature.pm blib/lib/SubMan/Schema/Result/LinkSubscriptionFeature.pm 
	$(NOECHO) $(ABSPERLRUN) -MExtUtils::Install -e 'pm_to_blib({@ARGV}, '\''$(INST_LIB)/auto'\'', q[$(PM_FILTER)], '\''$(PERM_DIR)'\'')' -- \
	  lib/SubMan/Schema/Result/LinkUserSubscription.pm blib/lib/SubMan/Schema/Result/LinkUserSubscription.pm \
	  lib/SubMan/Schema/Result/PeriodUser.pm blib/lib/SubMan/Schema/Result/PeriodUser.pm \
	  lib/SubMan/Schema/Result/Registration.pm blib/lib/SubMan/Schema/Result/Registration.pm \
	  lib/SubMan/Schema/Result/StripeUser.pm blib/lib/SubMan/Schema/Result/StripeUser.pm \
	  lib/SubMan/Schema/Result/Subscription.pm blib/lib/SubMan/Schema/Result/Subscription.pm \
	  lib/SubMan/Schema/Result/SubscriptionDowngradeTo.pm blib/lib/SubMan/Schema/Result/SubscriptionDowngradeTo.pm \
	  lib/SubMan/Schema/Result/SubscriptionGroup.pm blib/lib/SubMan/Schema/Result/SubscriptionGroup.pm \
	  lib/SubMan/Schema/Result/SubscriptionUpgradeTo.pm blib/lib/SubMan/Schema/Result/SubscriptionUpgradeTo.pm \
	  lib/SubMan/Schema/Result/Theme.pm blib/lib/SubMan/Schema/Result/Theme.pm \
	  lib/SubMan/Schema/Result/Transaction.pm blib/lib/SubMan/Schema/Result/Transaction.pm \
	  lib/SubMan/Schema/Result/User.pm blib/lib/SubMan/Schema/Result/User.pm \
	  lib/SubMan/Schema/Result/UserPswSetToken.pm blib/lib/SubMan/Schema/Result/UserPswSetToken.pm \
	  lib/SubMan/Schema/Result/UserRegistrationToken.pm blib/lib/SubMan/Schema/Result/UserRegistrationToken.pm \
	  lib/SubMan/Schema/Result/UserType.pm blib/lib/SubMan/Schema/Result/UserType.pm \
	  lib/SubMan/Test/Mechanize.pm blib/lib/SubMan/Test/Mechanize.pm \
	  lib/SubMan/Test/Register.pm blib/lib/SubMan/Test/Register.pm \
	  lib/SubMan/ValidationRule/Base.pm blib/lib/SubMan/ValidationRule/Base.pm \
	  lib/SubMan/ValidationRule/Email.pm blib/lib/SubMan/ValidationRule/Email.pm \
	  lib/SubMan/ValidationRule/NotEmpty.pm blib/lib/SubMan/ValidationRule/NotEmpty.pm \
	  lib/SubMan/ValidationRule/NotEmptyIfExists.pm blib/lib/SubMan/ValidationRule/NotEmptyIfExists.pm \
	  lib/SubMan/ValidationRule/Subscription/CheckAccessType.pm blib/lib/SubMan/ValidationRule/Subscription/CheckAccessType.pm \
	  lib/SubMan/ValidationRule/Subscription/CheckTrial.pm blib/lib/SubMan/ValidationRule/Subscription/CheckTrial.pm \
	  lib/SubMan/ValidationRule/Subscription/DiscountCodeExists.pm blib/lib/SubMan/ValidationRule/Subscription/DiscountCodeExists.pm \
	  lib/SubMan/ValidationRule/Subscription/DiscountCodeNotUsed.pm blib/lib/SubMan/ValidationRule/Subscription/DiscountCodeNotUsed.pm \
	  lib/SubMan/ValidationRule/UniqueUser.pm blib/lib/SubMan/ValidationRule/UniqueUser.pm \
	  lib/SubMan/ValidationRule/ValidAdmin.pm blib/lib/SubMan/ValidationRule/ValidAdmin.pm \
	  lib/SubMan/View/HTML.pm blib/lib/SubMan/View/HTML.pm \
	  lib/SubMan/View/JSON.pm blib/lib/SubMan/View/JSON.pm 
	$(NOECHO) $(TOUCH) pm_to_blib


# --- MakeMaker selfdocument section:


# --- MakeMaker postamble section:


# End.
# Postamble by Module::Install 1.06
# --- Module::Install::Admin::Makefile section:

realclean purge ::
	$(RM_F) $(DISTVNAME).tar$(SUFFIX)
	$(RM_F) MANIFEST.bak _build
	$(PERL) "-Ilib" "-MModule::Install::Admin" -e "remove_meta()"
	$(RM_RF) inc

reset :: purge

upload :: test dist
	cpan-upload -verbose $(DISTVNAME).tar$(SUFFIX)

grok ::
	perldoc Module::Install

distsign ::
	cpansign -s

# --- Module::Install::AutoInstall section:

config :: installdeps
	$(NOECHO) $(NOOP)

checkdeps ::
	$(PERL) Makefile.PL --checkdeps

installdeps ::
	$(PERL) Makefile.PL --config= --installdeps=DateTime::Format::MySQL,0

installdeps_notest ::
	$(PERL) Makefile.PL --config=notest,1 --installdeps=DateTime::Format::MySQL,0

upgradedeps ::
	$(PERL) Makefile.PL --config= --upgradedeps=DateTime::Format::MySQL,0,Test::More,0.88,Business::AuthorizeNet::CIM,0,Business::Stripe,0,Date::Calc,0,DateTime,0,DateTime::Format::Pg,0,DBD::Pg,0,DBIx::Class,0,DBIx::Class::PassphraseColumn,0,Catalyst::Action::RenderView,0,Catalyst::Authentication::Store::DBIx::Class,0,Catalyst::Controller::REST,0,Catalyst::Devel,0,Catalyst::Plugin::Authentication,0,Catalyst::Plugin::ConfigLoader,0,Catalyst::Plugin::Session::Store::File,0,Catalyst::Plugin::Session::State::Cookie,0,Catalyst::Plugin::Static::Simple,0,Catalyst::Restarter,0,Catalyst::Runtime,5.90019,Catalyst::ScriptRunner,0,Catalyst::View::TT,0,Catalyst::Plugin::Log::Handler,0,Config::General,0,Imager,0,JSON,0,JSON::XS,0,Log::Log4perl,0,LWP::Protocol::https,0,Mail::Sendmail,0,MIME::Base64,0,Moose,0,MooseX::MarkAsMethods,0,MooseX::NonMoose,0,namespace::autoclean,0,Net::Braintree,0,Net::IP,0,SQL::Translator,0,String::Random,0,Template,0,Template::Plugin::Number::Format,0,Term::ReadKey,0,Test::HTML::Form,0,Test::WWW::Mechanize::Catalyst,0,Try::Tiny,0,YAML::Tiny,0,Catalyst::View::JSON,0

upgradedeps_notest ::
	$(PERL) Makefile.PL --config=notest,1 --upgradedeps=DateTime::Format::MySQL,0,Test::More,0.88,Business::AuthorizeNet::CIM,0,Business::Stripe,0,Date::Calc,0,DateTime,0,DateTime::Format::Pg,0,DBD::Pg,0,DBIx::Class,0,DBIx::Class::PassphraseColumn,0,Catalyst::Action::RenderView,0,Catalyst::Authentication::Store::DBIx::Class,0,Catalyst::Controller::REST,0,Catalyst::Devel,0,Catalyst::Plugin::Authentication,0,Catalyst::Plugin::ConfigLoader,0,Catalyst::Plugin::Session::Store::File,0,Catalyst::Plugin::Session::State::Cookie,0,Catalyst::Plugin::Static::Simple,0,Catalyst::Restarter,0,Catalyst::Runtime,5.90019,Catalyst::ScriptRunner,0,Catalyst::View::TT,0,Catalyst::Plugin::Log::Handler,0,Config::General,0,Imager,0,JSON,0,JSON::XS,0,Log::Log4perl,0,LWP::Protocol::https,0,Mail::Sendmail,0,MIME::Base64,0,Moose,0,MooseX::MarkAsMethods,0,MooseX::NonMoose,0,namespace::autoclean,0,Net::Braintree,0,Net::IP,0,SQL::Translator,0,String::Random,0,Template,0,Template::Plugin::Number::Format,0,Term::ReadKey,0,Test::HTML::Form,0,Test::WWW::Mechanize::Catalyst,0,Try::Tiny,0,YAML::Tiny,0,Catalyst::View::JSON,0

listdeps ::
	@$(PERL) -le "print for @ARGV" DateTime::Format::MySQL

listalldeps ::
	@$(PERL) -le "print for @ARGV" DateTime::Format::MySQL Test::More Business::AuthorizeNet::CIM Business::Stripe Date::Calc DateTime DateTime::Format::Pg DBD::Pg DBIx::Class DBIx::Class::PassphraseColumn Catalyst::Action::RenderView Catalyst::Authentication::Store::DBIx::Class Catalyst::Controller::REST Catalyst::Devel Catalyst::Plugin::Authentication Catalyst::Plugin::ConfigLoader Catalyst::Plugin::Session::Store::File Catalyst::Plugin::Session::State::Cookie Catalyst::Plugin::Static::Simple Catalyst::Restarter Catalyst::Runtime Catalyst::ScriptRunner Catalyst::View::TT Catalyst::Plugin::Log::Handler Config::General Imager JSON JSON::XS Log::Log4perl LWP::Protocol::https Mail::Sendmail MIME::Base64 Moose MooseX::MarkAsMethods MooseX::NonMoose namespace::autoclean Net::Braintree Net::IP SQL::Translator String::Random Template Template::Plugin::Number::Format Term::ReadKey Test::HTML::Form Test::WWW::Mechanize::Catalyst Try::Tiny YAML::Tiny Catalyst::View::JSON

