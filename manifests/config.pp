# == Class keepup::config
#
# creates config files
#
class keepup::config {

  $key              = $keepup::key
  $pkg_path         = $keepup::pkg_path
  $os_path          = $keepup::os_path
  $server           = $keepup::server
  $cron             = $keepup::cron
  $config_manage    = $keepup::config_manage
  $use_defaults     = $keepup::use_defaults
  $info_defaults    = $keepup::info_defaults
  $info             = $keepup::info
  $package_defaults = $keepup::package_defaults

  if $config_manage {

    if $use_defaults {
      $data = deep_merge($info_defaults, $package_defaults, $info)
    } else {
      $data = $info
    }

    if $data['data_center'] == '' {
      fail('info::data_center is a mandatory hash member')
    }

    file { '/opt/keepup':
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0750',
    }->

    file { '/opt/keepup/data.json':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => epp("${module_name}/opt/keepup/data.json.epp", {
        data => $data,
        }),
      replace => true,
    }

    file { '/opt/keepup/pkg.json':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => epp("${module_name}/opt/keepup/pkg.json.epp", {
        data => $data,
        }),
      replace => true,
    }

    file { '/opt/keepup/run.sh':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0750',
      content => epp("${module_name}/opt/keepup/run.sh.epp", {
        pkg_path => $pkg_path,
        os_path  => $os_path,
        server   => $server,
        key      => $key,
        }),
    }

    file { '/etc/cron.d/keepup':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => epp("${module_name}/etc/cron.d/keepup.epp", {
        cron => $cron,
        }),
    }

  } else {

    $files = [
      '/opt/keepup/data.json',
      '/opt/keepup/pkg.json',
      '/opt/keepup/run.sh',
      '/etc/cron.d/keepup',
    ]
    file { $files:
      ensure => 'absent',
    }

  }
}
