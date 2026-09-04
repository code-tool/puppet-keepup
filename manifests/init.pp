# == Class: keepup
#
# This module installs and configures keepup
#
# === Parameters
# @param key
# @param pkg_path
# @param server
# @param crontimetpl
# @param manage_package
# @param package_name
# @param config_manage
# @param use_defaults
# @param systemd_timer
# @param info_defaults
# @param package_defaults
# @param info

class keepup (
  String               $key              = $keepup::params::key,
  String               $pkg_path         = $keepup::params::pkg_path,
  String               $server           = $keepup::params::server,
  String               $crontimetpl      = $keepup::params::crontimetpl,
  Boolean              $manage_package   = $keepup::params::manage_package,
  Array[String]        $package_name     = $keepup::params::package_name,
  Boolean              $config_manage    = $keepup::params::config_manage,
  Boolean              $use_defaults     = $keepup::params::use_defaults,
  Boolean              $systemd_timer    = $keepup::params::systemd_timer,
  Hash                 $info_defaults    = $keepup::params::info_defaults,
  Hash                 $package_defaults = $keepup::params::package_defaults,
  Hash                 $info             = $keepup::params::info,
) inherits keepup::params {
  contain keepup::install
  contain keepup::config

  Class['keepup::install']
  -> Class['keepup::config']
}
