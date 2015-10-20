# = Class: apt_dater::host
#
class apt_dater::host {
  include ::apt_dater

  case $::osfamily {
    'Debian': {
      if !defined(Package[$apt_dater::host_package]) {
        package { $apt_dater::host_package:
          ensure => $apt_dater::version,
        }
      }
    }
    'RedHat': {
      file { '/usr/bin/apt-dater-host':
        ensure => 'present',
        owner  => $apt_dater::host_user,
        group  => $apt_dater::host_user,
        mode   => '0750',
        source => 'puppet:///modules/apt_dater/apt-dater-host-yum',
      }
    }
    default: {
      fail('OS family not yet supported.')
    }
  }

  if !$apt_dater::bool_reuse_host_user {
    user { $apt_dater::host_user:
      ensure     => present,
      system     => true,
      home       => $apt_dater::host_home_dir,
      managehome => true;
    }
  }

  if !$apt_dater::bool_reuse_ssh {
    file { "${apt_dater::host_home_dir}/.ssh":
      ensure => directory,
      mode   => '0700',
      owner  => $apt_dater::host_user;
    }

    ssh_authorized_key { 'apt-dater-key':
      ensure  => 'present',
      user    => $apt_dater::host_user,
      options => $apt_dater::ssh_key_options,
      type    => $apt_dater::ssh_key_type,
      key     => $apt_dater::ssh_key,
      require => File["${apt_dater::host_home_dir}/.ssh"];
    }
  }

  sudo::directive { 'apt-dater':
    content => "${apt_dater::host_user} ALL=NOPASSWD: ${apt_dater::host_update_cmd}\n";
  }

  @@apt_dater::host_fragment { $::fqdn:
    customer => $apt_dater::customer,
    ssh_user => $apt_dater::host_user,
    ssh_name => $::fqdn,
    ssh_port => $apt_dater::ssh_port;
  }
}
