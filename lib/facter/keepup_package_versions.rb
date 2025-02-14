#!/usr/bin/env ruby

require 'facter'

packages = {
  'mongodb' => {
    host_package: '/usr/bin/mongod',
    host_version_command: "dpkg-query -W -f='\${Package} \${Version}\n' mongodb-org-server 2>/dev/null || true",
  },
  'redis' => {
    host_package: 'redis-server',
    host_version_command: "dpkg-query -W -f='\${Package} \${Version}\n' redis-server 2>/dev/null || true",
  },
  'mysql' => {
    host_package: 'percona-server-server',
    host_version_command: "dpkg-query -W -f='\${Package} \${Version}\n' percona-server-server 2>/dev/null || true",
  },
  'rabbitmq' => {
    host_package: 'rabbitmq-server',
    host_version_command: "dpkg-query -W -f='\${Package} \${Version}\n' rabbitmq-server 2>/dev/null || true",
  },
  'memcached' => {
    host_package: 'memcached',
    host_version_command: "dpkg-query -W -f='\${Package} \${Version}\n' memcached 2>/dev/null || true",
  },
  'envoy' => {
    host_package: 'envoy',
    host_version_command: "dpkg-query -W -f='\${Package} \${Version}\n' envoy 2>/dev/null || true",
  },
  'postgresql' => {
    host_package: 'postgresql', 
    host_version_command: "psql --version 2>/dev/null | cut -d ' ' -f3 | sed 's/^/postgresql /' || true",
  },
  'elasticsearch' => {
    host_package: 'elasticsearch',
    host_version_command: "dpkg-query -W -f='${Package} ${Version}\n' elasticsearch 2>/dev/null || true",
  },
}

def process_running?(package)
  Facter::Util::Resolution.exec("pgrep -f '#{package}'")
end

def package_version(command)
  output = Facter::Util::Resolution.exec(command)
  return nil unless $?.success? && output

  version = output.strip.split(' ')[1]
  version
end

Facter.add('package_versions') do
  setcode do
    package_versions = {}
    packages.each do |package_name, config|
      process_check = process_running?(config[:host_package] || package_name)

      if process_check
        version = package_version(config[:host_version_command])
        if version
          package_versions[package_name] = { 'version' => version }
        else
          package_versions[package_name] = { 'version' => 'unknown'}
        end
      else
        package_versions[package_name] = { 'version' => 'unknown'}
      end
    end

    package_versions
  end
end
