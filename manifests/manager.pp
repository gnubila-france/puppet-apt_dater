# = Class: apt_dater::manager
#
class apt_dater::manager {
  include ::apt_dater

  if !defined(Package[$apt_dater::package]) {
    package { $apt_dater::package:
      ensure => $apt_dater::version,
    }
  }

  if !$apt_dater::bool_reuse_ssh {
    if !defined(File[$apt_dater::manager_ssh_dir]) {
      file { $apt_dater::manager_ssh_dir:
        ensure => 'directory',
        mode   => '0700',
        owner  => $apt_dater::manager_user,
      }
    }

    file { $apt_dater::manager_ssh_private_file:
      ensure  => 'file',
      content => $apt_dater::manager_ssh_key,
      mode    => '0600',
      owner   => $apt_dater::manager_user,
    }

  }

  # manage the ~/.config directory
  file { $apt_dater::manager_home_conf_dir:
    ensure => 'directory',
    owner  => $apt_dater::manager_user,
  }

  file {
    $apt_dater::manager_conf_dir:
      ensure  => 'directory',
      mode    => '0700',
      owner   => $apt_dater::manager_user;

    $apt_dater::manager_ad_conf_dir:
      ensure  => 'directory',
      mode    => '0700',
      owner   => $apt_dater::manager_user,
      require => File[$apt_dater::manager_conf_dir];

    "${apt_dater::manager_ad_conf_dir}/apt-dater.conf":
      ensure  => 'file',
      content => template('apt_dater/apt-dater.conf.erb'),
      mode    => '0600',
      owner   => $apt_dater::manager_user,
      require => File[$apt_dater::manager_ad_conf_dir];

    "${apt_dater::manager_ad_conf_dir}/hosts.conf":
      ensure => 'file',
      source => "${apt_dater::manager_ad_conf_dir}/hosts.conf.generated",
      mode   => '0600',
      owner  => $apt_dater::manager_user,
      require => File[$apt_dater::manager_ad_conf_dir];

    "${apt_dater::manager_ad_conf_dir}/screenrc":
      ensure  => 'file',
      content => template('apt_dater/apt-dater-screenrc.erb'),
      mode    => '0600',
      owner   => $apt_dater::manager_user,
      require => File[$apt_dater::manager_ad_conf_dir];

    '/usr/local/bin/update-apt-dater-hosts':
      ensure  => 'file',
      content => template('apt_dater/update-apt-dater-hosts.erb'),
      mode    => '0755',
      owner   => root,
      group   => root,
      notify  => Exec['update-hosts.conf'];

    $apt_dater::manager_fragments_dir:
      ensure  => 'directory',
      source  => 'puppet:///modules/apt_dater/empty',
      mode    => '0700',
      owner   => $apt_dater::manager_user,
      recurse => true,
      ignore  => ['.gitkeep'],
      purge   => true,
      force   => true;
  }

  exec { 'update-hosts.conf':
    command => "/usr/local/bin/update-apt-dater-hosts > ${apt_dater::manager_ad_conf_dir}/hosts.conf.generated",
    unless  => "bash -c 'cmp ${apt_dater::manager_ad_conf_dir}/hosts.conf.generated <(/usr/local/bin/update-apt-dater-hosts)'",
    path    => '/bin:/usr/bin:/sbin:/usr/sbin',
    require => File[$apt_dater::manager_ad_conf_dir],
  }

  # explicitly define the update order, uses a generated file to get proper diff support from File
  Apt_dater::Host_fragment <<| |>> ~>
  Exec['update-hosts.conf'] ->
  File["${apt_dater::manager_ad_conf_dir}/hosts.conf"]
}
