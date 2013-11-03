# == Class: backup::rsync_dest
#
# Configure destination host for rsync backups.  This host initiates
# an rsync-over-ssh connection to the rsync source system to back up
# files.
#
# === Parameters
#
# [*backup_group*]
#   System group of user that runs backup job.  Default: backup-rsync
#
# [*backup_home*]
#   Home directory of $backup_user.  Default: /home/backup-rsync.
#
# [*backup_user*]
#   User that runs backup job.  Default: backup-rsync
#
# [*cron_job*]
#   Boolean specifying if backup job should be scheduled in cron.
#   Default: true
#
# [*cron_hour*]
#   Hour for backup cron job.  Default: 0
#
# [*cron_minute*]
#   Minute for backup cron job.  Default: 1
#
# [*cron_month*]
#   Month for backup cron job.  Default: absent (do not restrict
#   month)
#
# [*cron_monthday*]
#   Day of month for backup cron job.  Default: absent (do not
#   restrict day of month)
#
# [*cron_weekday*]
#   Day of week for backup cron job.  Default: absent (do not restrict
#   day of week)
#
# [*ssh_private_key*]
#   SSH private key with permissions to log into source systems.
#
# [*targets*]
#   Hash of rsync source systems (keys) and arrays of directories on
#   each to back up (values).
#
# === Examples
#
# class { 'backup::rsync_dest':
#   ssh_private_key => '-----BEGIN RSA PRIVATE KEY-----[...]',
#   targets => {
#     'foo.example.com' => [ '/home', '/etc' ],
#     'bar.example.com' => [ '/u1/oracle' ]
#   }
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
class backup::rsync_dest (
  $ssh_private_key,
  $targets,
  $backup_group = 'backup-rsync',
  $backup_home = '/home/backup-rsync',
  $backup_user = 'backup-rsync',
  $cron_job = true,
  $cron_hour = 0,
  $cron_minute = 1,
  $cron_month = absent,
  $cron_monthday = absent,
  $cron_weekday = absent,
  ){

  validate_re($backup_group, '^[a-zA-Z0-9\.\-_]+$')
  validate_absolute_path($backup_home)
  validate_re($backup_user, '^[a-zA-Z0-9\.\-_]+$')
  validate_bool($cron_job)
  validate_re($ssh_private_key, '^-----BEGIN')
  validate_hash($targets)

  ensure_packages(['rsync'])

  group { $backup_group:
    ensure => present,
  }

  user { $backup_user:
    ensure     => present,
    comment    => 'Rsync backup user',
    gid        => $backup_group,
    home       => $backup_home,
    managehome => false, # Want to be explicit about perms, etc.
    shell      => '/bin/bash',
    require    => Group[$backup_group],
  }

  file { $backup_home:
    ensure  => directory,
    owner   => $backup_user,
    group   => $backup_group,
    mode    => '0700',
    require => [ Group[$backup_group], User[$backup_user] ],
  }

  $ssh_dir = "${backup_home}/.ssh"

  file { $ssh_dir:
    ensure  => directory,
    owner   => $backup_user,
    group   => $backup_group,
    mode    => '0700',
    require => File[$backup_home],
  }

  file { "${ssh_dir}/backup-rsync.pem":
    ensure  => present,
    owner   => $backup_user,
    group   => $backup_group,
    mode    => '0400',
    content => $ssh_private_key,
    require => File[$ssh_dir],
  }

  file { "${backup_home}/rsync-backup.sh":
    ensure  => present,
    owner   => $backup_user,
    group   => $backup_group,
    mode    => '0700',
    content => template('backup/rsync-backup.sh.erb'),
    require => File[$backup_home],
  }

  if $cron_job {
    cron { 'rsync-backup':
      ensure   => present,
      command  => "${backup_home}/rsync-backup.sh",
      hour     => $cron_hour,
      minute   => $cron_minute,
      month    => $cron_month,
      monthday => $cron_monthday,
      user     => $backup_user,
      weekday  => $cron_weekday,
      require  => User[$backup_user],
    }
  }
}
