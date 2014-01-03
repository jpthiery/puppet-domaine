define domaine (
  $mail          = false,
  $bindConfig    = "/etc/bind/db.$name",
  $dnsserial     = undef,
  $nssecondaire  = undef,
  $allowtransfer = undef,
  $subdomaines   = undef,
  $customentry   = undef,
  $mailnotifier  = undef) {
  if $dnsserial == undef {
    fail('dnsserial must be define.')
  }

  package { 'bind9': ensure => present }

  file { $bindConfig:
    ensure  => file,
    mode    => 0544,
    content => template("domaine/zone.erb"),
    owner   => 'root',
    group   => 'bind',
    require => Package['bind9']
  }

  file { '/tmp/notcontain.sh':
    ensure  => 'file',
    source  => 'puppet:///modules/domaine/notcontain.sh',
    group   => '0',
    mode    => '770',
    owner   => '0',
    require => Package['bind9']
  }

  file { '/etc/bind/named.conf.options':
    ensure  => 'file',
    mode    => 0544,
    owner   => 'root',
    group   => 'bind',
    require => Package['bind9']
  }

  exec { 'append-zone':
    command   => template('domaine/named-zone.erb'),
    onlyif    => "/tmp/./notcontain.sh $name /etc/bind/named.conf.options",
    require   => [
      File['/tmp/notcontain.sh'],
      Package['bind9']],
    path      => "/usr/bin/:/bin/",
    logoutput => 'on_failure'
  }

  service { 'bind9':
    ensure    => running,
    enable    => true,
    subscribe => [
      File[$bindConfig],
      File['/etc/bind/named.conf.options']],
    require   => Package['bind9']
  }

  if $mail and $mailnotifier {
    file { '/home/vpopmail/bin/vadddomaine': ensure => 'file' }

    file { '/home/vpopmail/bin/vdominfo': ensure => 'file' }

    file { '/usr/sbin/createdomainemail':
      ensure  => 'file',
      source  => 'puppet:///modules/domaine/createdomainemail.sh',
      group   => '0',
      mode    => '770',
      owner   => '0',
      require => [
        File['/home/vpopmail/bin/vadddomaine'],
        File['/home/vpopmail/bin/vdominfo']]
    }

    exec { 'add-mail':
      command   => "createdomainemail $name $mailnotifier",
      onlyif    => "test -z vdominfo $name | grep \"^domain: $name\$\" | uniq -c | awk {'print \$1'}",
      path      => '/usr/bin/:/bin/:/usr/sbin/',
      logoutput => 'on_failure',
      require   => File['/usr/sbin/createdomainemail']
    }
  }

}
