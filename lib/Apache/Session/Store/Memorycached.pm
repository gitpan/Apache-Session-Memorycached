#############################################################################
#
# Apache::Session::Store::Memorycached
# Implements session object storage via memcached 
# Copyright(c) eric german <germanlinux@yahoo.fr>     
# Distribute under the Artistic License
#
############################################################################

package Apache::Session::Store::Memorycached;

use strict;
use Symbol;
use Cache::Memcached;
use vars qw($VERSION);

$VERSION = '1.1';


sub new {
    my $class = shift;
    my $self;
    $self->{opened} = 0;
    
    return bless $self, $class;
}


sub insert {
    my $self    = shift;
    my $session = shift;
 
 my $ryserver = $session->{args}->{servers};
 my $ryserverlocal = $session->{args}->{local};
 my $rytimeout = $session->{args}->{timeout}||'0';
 my $memd= new Cache::Memcached  { 'servers' => $ryserver };
 my $ident = $session->{data}->{_session_id}; 
 my $rhash = $session->{data};
 $memd->set($ident,$rhash,$rytimeout);
 $memd->disconnect_all();
  if ($ryserverlocal)
     {
 my $memdlocal= new Cache::Memcached  { 'servers' => $ryserverlocal };
 my $identlocal = $session->{data}->{_session_id}; 
 my $rhashlocal = $session->{data};
 $memdlocal->set($identlocal,$rhashlocal,$rytimeout);
 $memdlocal->disconnect_all();
     }
$self->{opened} = 1;
 
 }

sub update {
    my $self    = shift;
    my $session = shift;
 
 my $ryserver = $session->{args}->{servers};
 my $ryserverlocal = $session->{args}->{local};
 my $rytimeout = $session->{args}->{timeout}||'0';
 my $memd= new Cache::Memcached  { 'servers' => $ryserver };
 my $ident = $session->{data}->{_session_id} ;
 my $rhash = $session->{data};
 $memd->set($ident,$rhash,$rytimeout);
 $memd->disconnect_all();
  if ($ryserverlocal)
     {
 my $memdlocal= new Cache::Memcached  { 'servers' => $ryserverlocal };
 my $identlocal = $session->{data}->{_session_id}; 
 my $rhashlocal = $session->{data};
 $memdlocal->set($identlocal,$rhashlocal,$rytimeout);
 $memdlocal->disconnect_all();
     }
 $self->{opened} = 1;
}

sub materialize {
    my $self    = shift;
    my $session = shift;
my $ryserver = $session->{args}->{servers};
my $rhash; 
my $ryserverlocal = $session->{args}->{local};
my $rytimeout = $session->{args}->{timeout}||'0';
  if ($ryserverlocal)
     {
 my $memdlocal= new Cache::Memcached  { 'servers' => $ryserverlocal };
 my $identlocal = $session->{data}->{_session_id}; 
 $rhash = $memdlocal->get($identlocal);
 $memdlocal->disconnect_all();
    }
 unless ($rhash)
          {
           my $memd= new Cache::Memcached  { 'servers' => $ryserver };
           my $ident = $session->{data}->{_session_id}; 
           $rhash = $memd->get($ident);
           $memd->disconnect_all();
 ## the data is in the  principal cache notin the local cache 
 ##  we must put data in it.
            if ($ryserverlocal)
                  {
                     my $memdlocal= new Cache::Memcached  { 'servers' => $ryserverlocal };
                     my $identlocal = $session->{data}->{_session_id}; 
                     my $rhashlocal = $session->{data};
                     $memdlocal->set($identlocal,$rhashlocal,$rytimeout);
                     $memdlocal->disconnect_all();
                   }

         }
 $self->{opened} = 1;
 $session->{data} =$rhash;
    
}    

sub remove {
    my $self    = shift;
    my $session = shift;
    my $ryserver = $session->{args}->{servers};
    my $memd= new Cache::Memcached  { 'servers' => $ryserver };
    my $ryserverlocal = $session->{args}->{local};
    my $ident = $session->{data}->{_session_id} ;
        $memd->delete($ident);  
        $memd->disconnect_all();
     if ($ryserverlocal)
          {
            my $memdlocal= new Cache::Memcached  { 'servers' => $ryserverlocal };
            my $identlocal = $session->{data}->{_session_id}; 
            $memdlocal->delete($identlocal);
            $memdlocal->disconnect_all();
          }
 
   $self->{opened} = 0;
    
    }

sub close {
    my $self = shift;
    
    if ($self->{opened}) {
        $self->{opened} = 0;
    }
}

sub DESTROY {
    my $self = shift;
    
    if ($self->{opened}) {    
    }
}

1;

=pod

=head1 NAME

Apache::Session::Store::Memorycached - Store persistent data on the network with  memcached

=head1 SYNOPSIS


 use Apache::Session::Store::Memorycached;
 
 my $store = new Apache::Session::Store::Memorycached;
 
 $store->insert($ref);
 $store->update($ref);
 $store->materialize($ref);
 $store->remove($ref);

=head1 DESCRIPTION

This module fulfills the storage interface of Apache::Session.  The serialized
objects are stored in files on your network in unused memory 

=head1 OPTIONS

This module requires one argument in the usual Apache::Session style.  The
name of the option is servers, and the value is the  same of memcached .
 Example

 tie %s, 'Apache::Session::Memorycached', undef,
    {servers  => ['mymemcachedserver:port'],
     'timeout' => '300' };

In order to optimize the network ,you can use a local memcached server.
All read-only opération are sending fisrt at local server .If you need write ou rewrite data , the data is sending at the principal memcached sever and local cache too  for synchronisation.

=head1 NOTES


=head1 AUTHOR

This module was written by eric german <germanlinux@yahoo.fr> 

=head1 SEE ALSO

L<Apache::Session>
