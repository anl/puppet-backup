# == Class: backup::mysql
#
# MySQL backup configuration.
#
# === Parameters
#
# Document parameters here.
#
# [*backup_dir*]
#   Directory backups will be written to.
#
# [*base_url*]
#   Base of download URL for backup script; e.g. raw project URL on GitHub.
#
# [*checksum*]
#   SHA256 checksum of script.
#
# [*cron_hour*]
#   Hour of day for cron job to be scheduled.
#
# [*cron_min*]
#   Minute for cron job to be scheduled.
#
# [*version*]
#   Version of backup script to download.
#
# === Examples
#
# class { backup::mysql:
#   cron_hour => 20,
#   cron_min  => 11,
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
class backup::mysql(
  $cron_hour = 20,
  $cron_min = 36,
  $backup_dir = '/srv/backups',
  $base_url = 'https://raw.github.com/anl/mysql-backup',
  $checksum = '54a96ba9b3020269a6195f1f52c60ded04843bbd3c71b86855ae7b9aed932eae',
  $version = '0.2.0'
  ) {

  include remotefile

  validate_absolute_path($backup_dir)

  file { $backup_dir:
    ensure  => directory,
    mode    => '0700',
  }

  remotefile::download { 'mysql-backup-all.sh':
    checksum    => $checksum,
    file_name   => 'mysql-backup-all.sh',
    install_dir => '/root',
    mode        => '0555',
    url         => "${base_url}/${version}/mysql-backup-all.sh",
  }

  cron { 'mysql-backup-all.sh':
    command => "timeout 3600 /root/mysql-backup-all.sh -d ${backup_dir}",
    user    => 'root',
    hour    => $cron_hour,
    minute  => $cron_min,
  }
}
