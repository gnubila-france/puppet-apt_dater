# This define is used to export/collect the required connection information from hosts to managers.
define apt_dater::host_fragment (
  $customer,
  $ssh_user,
  $ssh_name,
  $ssh_port,
) {
  validate_string($customer)
  validate_string($ssh_user)
  validate_string($ssh_name)
  validate_string($ssh_port)

  include ::apt_dater

  file { "${apt_dater::manager_fragments_dir}/${customer}:${ssh_user}@${ssh_name}:${ssh_port}":
    ensure  => present,
    content => '',
  }
}
