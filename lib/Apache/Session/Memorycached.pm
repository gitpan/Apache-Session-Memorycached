#############################################################################
#
# Apache::Session::Memorycached
# Apache persistent user sessions on the network with memcached
# Copyright(c) eric german <germanlinux@yahoo.fr>
# Distribute under the Artistic License
#
############################################################################

package Apache::Session::Memorycached;

use strict;
use vars qw(@ISA $VERSION);

$VERSION = '1.1';
@ISA = qw(Apache::Session);

use Apache::Session;
use Apache::Session::Generate::MD5;
use Apache::Session::Lock::Memorycached;
use Apache::Session::Store::Memorycached;

sub populate {
    my $self = shift;

    $self->{object_store} = new Apache::Session::Store::Memorycached $self;
    $self->{lock_manager} = new Apache::Session::Lock::Memorycached $self;
    $self->{generate}     = \&Apache::Session::Generate::MD5::generate;
    $self->{validate}     = \&Apache::Session::Generate::MD5::validate;
    $self->{serialize}    = \&Apache::Session::Memorycached::none;
    $self->{unserialize}  = \&Apache::Session::Memorycached::none;

    return $self;
}

sub none {
    my $self    = shift;
    my $session = shift;
return;
 }
 sub DESTROY {
    my $self = shift;
    
    $self->save;
    $self->{object_store}->close;
    $self->release_all_locks;
}

1;


=pod

=head1 NAME

Apache::Session::Memorycached - An implementation of Apache::Session

=head1 SYNOPSIS

 use Apache::Session::Memorycached;
 
    tie %session, 'Apache::Session::Memorycached', $cookie, {
          'servers' => ["10.75.1.19:11211"], #all write operations
          'local'  =>  ["localhost:11211"],  #read-only operations
          'timeout' => '300'
     };

=head1 DESCRIPTION

This module is an implementation of Apache::Session.  It uses the memcached system backing
store .  You may specify servers (principal)  and locals caches for locking in arguments to the constructor. See the example, and the documentation for Apache::Session::Store::Memorycached  and Cache::Memcached .

The lemonldap project (SSO under GPL)  uses this module 

=head1 AUTHOR

This module was written by eric german <germanlinux@yahoo.fr>.

=head1 SEE ALSO

L<Apache::Session::DB_File>, L<Apache::Session::Flex>,
L<Apache::Session::MySQL>, L<Apache::Session::Postgres>, L<Apache::Session>
