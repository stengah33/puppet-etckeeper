# == Class: etckeeper
#
# Configure and install etckeeper. Works for debian-like and
# redhat-like systems.
#
# === Variables
#
# [*etckeeper_high_pkg_mgr*]
#   OS dependent config setting, HIGHLEVEL_PACKAGE_MANAGER.
#
# [*etckeeper_low_pkg_mgr*]
#   OS dependent config setting, LOWLEVEL_PACKAGE_MANAGER.
#
# === Examples
#
#   include etckeeper
#
# === Authors
#
# Thomas Van Doren
#
# === Copyright
#
# Copyright 2012, Thomas Van Doren, unless otherwise noted
#
class etckeeper {

  Package {
    ensure => present,
  }

  package { ['git', 'etckeeper']:
    ensure => present,
  }

  include etckeeper::conf

  #package { 'etckeeper':
  #  require => [ Package['git'],
  #               File['etckeeper.conf'],
  #               ],
  #}

  #exec { 'etckeeper-init':
  #  command => '/usr/bin/etckeeper init',
  #  cwd     => '/etc',
  #  creates => '/etc/.git',
  #  require => [ Package['git'], Package['etckeeper'], ],
  #}
}
