define domaine (
  $mail         = false,
  $bindConfig   = "/etc/bind/db.$name",
  $dnsserial    = undef,
  $nssecondaire = undef,
  $rootname     = undef,
  $subdomaines  = [],
  $customentry  = []) {

  if $rootname == undef {
    fail('rootname must be define.')
  }
  
  if $dnsserial == undef {
    fail('dnsserial must be define.')
  }
    
  package { 'bind9': ensure => latest }

  file { $bindConfig:
    ensure  => file,
    mode    => 0544,
    content => template("domaine/zone.erb"),
    owner => 'root',
    group => 'bind'
  }

  service { 'bind9':
    ensure    => running,
    enable    => true,
    subscribe => File[$bindConfig]
  }

  

}
