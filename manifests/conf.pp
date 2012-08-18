class etckeeper::conf::params {

  # HIGHLEVEL_PACKAGE_MANAGER config setting.
  $high_pkg_mgr = $operatingsystem ? {
    /(?i-mx:ubuntu|debian)/        => 'apt',
    /(?i-mx:centos|fedora|redhat)/ => 'yum',
    /(?i-mx:suse|opensuse)/        => 'zypper',
  }

  # LOWLEVEL_PACKAGE_MANAGER config setting.
  $low_pkg_mgr = $operatingsystem ? {
    /(?i-mx:ubuntu|debian)/        => 'dpkg',
    /(?i-mx:centos|fedora|redhat)/ => 'rpm',
    /(?i-mx:suse|opensuse)/        => 'rpm',
  }

}

define etckeeper::conf::update($value) {

  $context = "/files/etc/etckeeper/etckeeper.conf"
  $key = $name
  augeas {"etckeeper_conf/$key":
    load_path => "/usr/share/augeas/lenses/dist:/usr/share/augeas/lenses/contrib:${settings::vardir}/augeas/lenses",
    lens    => "Etckeeperconf.lns",
    incl    => "/etc/etckeeper/etckeeper.conf",
    context => $context,
    onlyif  => "get $key != '$value'",
    changes => "set $key '$value'",
  } 
}

class etckeeper::conf(
  $vcs = 'git'
) inherits etckeeper::conf::params {

  file { '/etc/etckeeper':
    ensure => directory,
  }
  
  if $etckeeper_conf_exist {
    include augeas

    augeas::lens {'etckeeperconf':
      lens_source => 'puppet:///modules/etckeeper/augeas/lenses/etckeeperconf.aug',
      test_source => 'puppet:///modules/etckeeper/augeas/lenses/test_etckeeperconf.aug',
    }

    etckeeper::conf::update {'VCS':
      value => $vcs,
    }

  } else {
  
    file { 'etckeeper.conf':
      ensure  => present,
      path    => '/etc/etckeeper/etckeeper.conf',
      owner   => root,
      group   => root,
      mode    => '0644',
      content => template('etckeeper/etckeeper.conf.erb'),
    }

  }

}
