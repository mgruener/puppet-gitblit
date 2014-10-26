class gitblit::params {
  case $::operatingsystem {
    'Fedora': {
      if $::operatingsystemmajrelease < 19 {
        fail('The gitblit module requires Fedora 19 or newer')
      }
      $service_provider = 'systemd'
      $service_name     = 'gitblit.service'
      $service_template = 'gitblit.service.systemd.erb'
      $service_path     = "/usr/lib/systemd/system/${service_name}"
      $service_config   = '/etc/sysconfig/gitblit'
    }
    'Ubuntu', 'Debian': {
      $service_provider = undef
      $service_name     = 'gitblit'
      $service_template = 'gitblit.service.lsbinit.erb'
      $service_path     = "/etc/init.d/${service_name}"
      $service_config   = '/etc/default/gitblit'
    }
    'CentOS','RedHat': {
      case $::operatingsystemmajrelease {
        6: {
          $service_provider = undef
          $service_name     = 'gitblit'
          $service_template = 'gitblit.service.chkconfig.erb'
          $service_path     = "/etc/init.d/${service_name}"
          $service_config   = '/etc/sysconfig/gitblit'
        }
        7: {
          $service_provider = 'systemd'
          $service_name     = 'gitblit.service'
          $service_template = 'gitblit.service.systemd.erb'
          $service_path     = "/usr/lib/systemd/system/${service_name}"
          $service_config   = '/etc/sysconfig/gitblit'
        }
        default: { fail('The gitblit module requires CentOS/RHEL 6 or newer') }
      }
    }
    default: { fail("The gitblit module is not supported on ${::operatingsystem}.") }
  }
}
