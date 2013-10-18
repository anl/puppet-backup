# Include this module
include backup
class { 'backup::mysql':
  cron_hour => 20,
  cron_min  => 12,
}
