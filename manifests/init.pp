# == Class: keepup
#
# This module installs and configures keepup
#
# === Parameters

class keepup (
  String               $key              = $keepup::params::key,
  String               $os_path          = $keepup::params::os_path,
  String               $pkg_path         = $keepup::params::pkg_path,
  String               $server           = $keepup::params::server,
  String               $cron             = $keepup::params::cron,
  Boolean              $manage_package   = $keepup::params::manage_package,
  Array[String]        $package_name     = $keepup::params::package_name,
  Boolean              $config_manage    = $keepup::params::config_manage,
  Boolean              $use_defaults     = $keepup::params::use_defaults,
  Hash                 $info_defaults    = $keepup::params::info_defaults,
  Hash                 $package_defaults = $keepup::params::package_defaults,
  Hash                 $info             = $keepup::params::info,

  ) inherits keepup::params {

    contain keepup::install
    contain keepup::config

    Class['keepup::install'] ->
    Class['keepup::config']
}
