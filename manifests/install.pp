# == Class keepup::install
#
# This class is called from keepup for install.
#
class keepup::install {

  $manage_package = $keepup::manage_package
  $package_ensure = $keepup::package_ensure
  $package_name   = $keepup::package_name

  # only do repo management when on a Debian-like system
  if $manage_package {

    include apt

    package { $package_name:
      ensure => $package_ensure,
    }

  }

}
