# == Class: backup::rsync
#
# Configure rsync backup client.
#
# Ensures rsync package is installed and drops restricted key into root's
# authorized_keys file.
#
# === Parameters
#
# [*ssh_key*]
#   Contents of SSH key for root user.
#
# [*ssh_key_type*]
#   Type of SSH key being added to root's authorized keys.
#
# === Examples
#
# class { 'backup::rsync':
#   ssh_key      => 'AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ==',
#   ssh_key_type => 'ssh-rsa',
# }
#
# === Authors
#
# Andrew Leonard
#
# === Copyright
#
# Copyright 2013 Andrew Leonard
#
class backup::rsync(
  $ssh_key = false,
  $ssh_key_type = false
  ) {

  validate_re($ssh_key_type, [ '^ssh-dss$', '^ssh-rsa$',
    '^ecdsa-sha2-nistp256$', '^ecdsa-sha2-nistp384$',
    '^ecdsa-sha2-nistp521$' ])

  if $ssh_key == false {
    fail('ssh_key must be set')
  }

  ensure_packages(['rsync'])

  ssh_authorized_key { 'root rsync':
    ensure  => present,
    key     => $ssh_key,
    options => [ 'command="rsync --server"', 'no-port-forwarding',
      'no-agent-forwarding', 'no-X11-forwarding', 'no-pty' ],
    type    => $ssh_key_type,
    user    => 'root',
  }
}
