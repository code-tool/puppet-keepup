# == Class keepup::params
#
# default parameters definition
#
class keepup::params {

  $key            = 'secret'
  $os_path        = '/os-release'
  $pkg_path       = '/package-version'
  $server_name    = 'keepup.exampel.com'
  $cron           = '0 */3 * * *'
  $package_ensure = 'installed'
  $config_manage  = true
  $manage_package = false
  $package_name   = [ 'curl' ]
  $use_defaults   = true
  # https://puppet.com/docs/puppet/7/core_facts.html#os
  $info_defaults = {
    'os_id'            => $facts['os']['distro']['id'],
    'version_codename' => $facts['os']['distro']['codename'],
    'version'          => $facts['os']['distro']['release']['full'],
    'version_id'       => $facts['os']['distro']['release']['major'],
    'host_ip'          => $facts['networking']['hostname'],
    'data_center'      => 'unknown',
  }

  $package_defaults = {
    'package_versions' => $facts['package_versions'],
    'mongodb'          => $facts['package_versions']['mongodb']['version'],
    'redis'            => $facts['package_versions']['redis']['version'],
    'mysql'            => $facts['package_versions']['mysql']['version'],
    'rabbitmq'         => $facts['package_versions']['rabbitmq']['version'],
    'memcached'        => $facts['package_versions']['memcached']['version'],
    'envoy'            => $facts['package_versions']['envoy']['version'],
    'postgresql'       => $facts['package_versions']['postgresql']['version'],
    'elasticsearch'    => $facts['package_versions']['elasticsearch']['version'],

  }

  $info = {}

}
