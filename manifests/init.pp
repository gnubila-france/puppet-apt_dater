# = Class: apt_dater
#
# This is the main apt_dater class to configure a node for being managed by apt-dater.
#
#
# == Parameters
#
# Standard class parameters
# Define the general class behaviour and customizations
#
# [*my_class*]
#   Name of a custom class to autoload to manage module's customizations
#   If defined, apt_dater class will automatically "include $my_class"
#   Can be defined also by the (top scope) variable $apt_dater_myclass
#
# [*version*]
#   The package version, used in the ensure parameter of package type.
#   Default: present. Can be 'latest' or a specific version number.
#   Note that if the argument absent (see below) is set to true, the
#   package is removed, whatever the value of version parameter.
#
# [*absent*]
#   Set to 'true' to remove package(s) installed by module
#   Can be defined also by the (top scope) variable $apt_dater_absent
#
# [*noops*]
#   Set noop metaparameter to true for all the resources managed by the module.
#   Basically you can run a dryrun for this specific module if you set
#   this to true. Default: undef
#
# [*debug*]
#   Set to 'true' to enable modules debugging
#   Can be defined also by the (top scope) variables $apt_dater_debug and $debug
#
# Default class params - As defined in apt_dater::params.
# Note that these variables are mostly defined and used in the module itself,
# overriding the default values might not affected all the involved components.
# Set and override them only if you know what you're doing.
# Note also that you can't override/set them via top scope variables.
#
# [*role*]
#   One of 'host', 'manager' or 'all'.
#
# [*customer*]
#   A grouping to be displayed in the apt-dater interface. Should be a simple alphanumeric string.
#
# [*package*]
#   The name of apt-dater package
#
# [*host_package*]
#   The name of apt-dater-host package
#
# [*user*]
#   Which user to use when connecting to the hosts. By default the user is called
#   "apt-dater" and created for you.
#
# [*home_dir*]
#   Where to put the config and ssh keys for the apt_dater::user.
#
# [*reuse_user*]
#   If your user is managed elsewhere, set this to true. Then this class doesn't touch
#   the user.
#
# [*reuse_ssh*]
#   If your ssh connection is managed elsewhere, set this to true. Then this class
#   doesn't touch the ssh keys.
#
# [*ssh_key_options*]
#   The options for the ssh key, as required by ssh_authorized_key.
#
# [*ssh_key_type*]
#   The type for the ssh key, as required by ssh_authorized_key.
#
# [*ssh_key*]
#   The ssh key, as required by ssh_authorized_key.
#
# [*manager_user*]
#   The user managing apt-dater. Only used on hosts with the 'manager' role.
#
# [*manager_ssh_dir*]
#   Where to put the secret apt-dater identity. Only used on hosts with the 'manager' role.
#
# [*manager_ssh_key*]
#   The secret apt-dater identity. Only used on hosts with the 'manager' role.
#
# == Examples
#
# You can use this class in 2 ways:
# - Set variables (at top scope level on in a ENC) and "include apt_dater"
# - Call apt_dater as a parametrized class
#
# See README for details.
#
class apt_dater (
  $version          = $apt_dater::params::version,
  $role             = $apt_dater::params::role,
  $customer         = $apt_dater::params::customer,
  $package          = $apt_dater::params::package,
  $host_package     = $apt_dater::params::host_package,
  $host_update_cmd  = $apt_dater::params::host_update_cmd,
  $host_user        = $apt_dater::params::host_user,
  $host_home_dir    = $apt_dater::params::host_home_dir,
  $reuse_host_user  = $apt_dater::params::reuse_host_user,
  $reuse_ssh        = $apt_dater::params::reuse_ssh,
  $ssh_key_options  = $apt_dater::params::ssh_key_options,
  $ssh_key_type     = $apt_dater::params::ssh_key_type,
  $ssh_key          = $apt_dater::params::ssh_key,
  $ssh_port         = $apt_dater::params::ssh_port,
  $manager_user     = $apt_dater::params::manager_user,
  $manager_home_dir = $apt_dater::params::manager_home_dir,
  $manager_ssh_key  = $apt_dater::params::manager_ssh_key
  ) inherits apt_dater::params {
  $bool_reuse_host_user = any2bool($apt_dater::reuse_host_user)
  $bool_reuse_ssh = any2bool($apt_dater::reuse_ssh)

  $manager_ssh_dir = "${apt_dater::manager_home_dir}/.ssh"
  $manager_ssh_private_file = "${apt_dater::manager_ssh_dir}/id_apt_dater"
  $manager_conf_dir = "${apt_dater::manager_home_dir}/.config"
  $manager_ad_conf_dir = "${apt_dater::manager_conf_dir}/apt-dater"
  $manager_ad_hosts_file = "${apt_dater::manager_ad_conf_dir}/hosts.conf"
  $manager_fragments_dir = "${::puppet_vardir}/apt-dater-fragments"

  # Managed resources
  if $apt_dater::role == 'host' or $apt_dater::role == 'all' {
    include apt_dater::host
  }

  if $apt_dater::role == 'manager' or $apt_dater::role == 'all' {
    include apt_dater::manager
  }
}
