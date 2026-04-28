# == Class keepup::config
#
# creates config files
#
class keepup::config {
  $key              = $keepup::key
  $pkg_path         = $keepup::pkg_path
  $server           = $keepup::server
  $crontimetpl      = $keepup::crontimetpl
  $config_manage    = $keepup::config_manage
  $use_defaults     = $keepup::use_defaults
  $systemd_timer    = $keepup::systemd_timer
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
    } ->

    # ensure old data file is absent
    file { '/opt/keepup/data.json':
      ensure  => 'absent',
    }

    file { '/opt/keepup/pkg.json':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => epp("${module_name}/opt/keepup/pkg.json.epp", {
          data => $data,
        }
      ),
      replace => true,
    }

    file { '/opt/keepup/run.sh':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0750',
      content => epp("${module_name}/opt/keepup/run.sh.epp", {
          pkg_path => $pkg_path,
          server   => $server,
          key      => $key,
        }
      ),
    }

    $persistent_random_minute = $facts['keepup_random_minute']
    # for example: 'RANDOM */3 * * *' will be replaced to rndomized persistent value
    $crontabtime = regsubst($crontimetpl, 'RANDOM', "${persistent_random_minute}", 'G')
    $systemd_calendar = "*-*-* 00/3:${persistent_random_minute}:00"

    if $systemd_timer {
      file { '/etc/cron.d/keepup':
        ensure => absent,
      }

      exec { 'keepup-systemd-daemon-reload':
        command     => '/bin/systemctl daemon-reload',
        refreshonly => true,
      }

      file { '/etc/systemd/system/keepup.service':
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => epp("${module_name}/etc/systemd/system/keepup.service.epp"),
        notify  => Exec['keepup-systemd-daemon-reload'],
      }

      file { '/etc/systemd/system/keepup.timer':
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => epp("${module_name}/etc/systemd/system/keepup.timer.epp", {
            calendar => $systemd_calendar,
          }
        ),
        notify  => Exec['keepup-systemd-daemon-reload'],
      }

      service { 'keepup.timer':
        ensure    => running,
        enable    => true,
        require   => Exec['keepup-systemd-daemon-reload'],
        subscribe => File['/etc/systemd/system/keepup.timer'],
      }
    } else {
      file { '/etc/cron.d/keepup':
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0640',
        content => epp("${module_name}/etc/cron.d/keepup.epp", {
            crontabtime => $crontabtime,
          }
        ),
      }

      exec { 'keepup-systemd-disable-timer':
        command => '/bin/systemctl disable --now keepup.timer',
        onlyif  => '/bin/systemctl list-unit-files keepup.timer --no-legend | /bin/grep -q "^keepup.timer"',
      }

      exec { 'keepup-systemd-daemon-reload':
        command     => '/bin/systemctl daemon-reload',
        refreshonly => true,
      }

      file { [
          '/etc/systemd/system/keepup.service',
          '/etc/systemd/system/keepup.timer',
        ]:
        ensure  => absent,
        require => Exec['keepup-systemd-disable-timer'],
        notify  => Exec['keepup-systemd-daemon-reload'],
      }
    }
  } else {
    $files = [
      '/opt/keepup/pkg.json',
      '/opt/keepup/run.sh',
      '/etc/cron.d/keepup',
      '/etc/systemd/system/keepup.service',
      '/etc/systemd/system/keepup.timer',
    ]
    file { $files:
      ensure => 'absent',
    }
  }
}
