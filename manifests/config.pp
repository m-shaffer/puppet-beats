# @api private
# This class handles the configuration files for beats. Avoid modifying private classes.
class beats::config {
  $beats::managed_beats.each |String $beat| {
    # Generate beat config name
    if ( $beat == 'heartbeat-elastic' ) {
      $ef_beat = 'heartbeat'
    }
    else { $ef_beat = $beat }


    $beat_config = "${beats::config_root}/${ef_beat}/${ef_beat}.yml"

    # Get beat settings
    $settings = lookup("beats::${beat}::settings", Data, 'deep', undef)

    if $settings {
      # Notify service or not?
      case $beats::service_manage {
        false: {
          $_notify = undef
        }
        default: {
          $_notify = Service[$beat]
        }
      }

      # # Set File defaults
      # File {
      #   ensure => file,
      #   path   => $beat_config,
      #   owner  => 0,
      #   group  => 0,
      #   mode   => '0600',
      #   notify => $_notify,
      # }

      case type($settings) {
        String: {
          file { "${beat}_config":
            ensure => 'file',
            path   => $beat_config,
            owner  => 0,
            group  => 0,
            mode   => '0600',
            notify => $_notify,
            source => $settings,
          }
        }
        default: {
          file { "${beat}_config":
            ensure  => 'file',
            path    => $beat_config,
            owner   => 0,
            group   => 0,
            mode    => '0600',
            notify  => $_notify,
            content => epp('beats/beat.yml.epp', { beat => $beat, settings => $settings }),
          }
        }
      }
    }

    if $beat == 'metricbeat' and lookup('beats::metricbeat::modules', Data, 'deep', undef) {
      require beats::metricbeat::config
    }
  }
}
