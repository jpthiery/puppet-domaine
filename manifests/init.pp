define domaine (
  $mail          = false,
  $bindConfig    = "/etc/bind/db.$name",
  $dnsserial     = undef,
  $nssecondaire  = undef,
  $allowtransfer = undef,
  $subdomaines   = undef,
  $customentry   = undef) {
  if $dnsserial == undef {
    fail('dnsserial must be define.')
  }

  package { 'bind9': ensure => latest }

  file { $bindConfig:
    ensure  => file,
    mode    => 0544,
    content => template("domaine/zone.erb"),
    owner   => 'root',
    group   => 'bind'
  }

  file { '/tmp/notcontain.sh':
    ensure => 'file',
    source => 'puppet:///modules/domaine/notcontain.sh',
    group  => '0',
    mode   => '770',
    owner  => '0',
  }
  
  file {'/etc/bind/named.conf.options':
    ensure => 'file',
    mode    => 0544,
    owner   => 'root',
    group   => 'bind'
  }

  exec { 'append-zone':
    command   => template('domaine/named-zone.erb'),
    onlyif    => "/tmp/./notcontain.sh $name",
    require   => File['/tmp/notcontain.sh'],
    path      => "/usr/bin/:/bin/",
    logoutput => on_failure,
  }

  service { 'bind9':
    ensure    => running,
    enable    => true,
    subscribe => [File[$bindConfig],File['/etc/bind/named.conf.options']]
  }

}
