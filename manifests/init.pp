class gitblit (
  $datadir          = '/var/lib/gitblit',
  $installdir       = '/opt/gitblit',
  $http_port        = '0',
  $https_port       = '8443',
  $user             = 'gitblit',
  $group            = 'gitblit',
  $manageuser       = true,
  $config           = {},
  $service_name     = $gitblit::params::service_name,
  $service_provider = $gitblit::params::service_provider,
  $service_template = $gitblit::params::service_template,
  $service_path     = $gitblit::params::service_path,
  $service_config   = $gitblit::params::service_config,
  $service_ensure   = running,
  $service_enable   = true,
) inherits gitblit::params {
  # only one installation method at the moment
  include gitblit::install::staging

  file { $datadir:
    ensure => directory,
    owner  => $user,
    group  => $group,
  }

  file { $service_path:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0744',
    content => template("${module_name}/${service_template}")
  }

  file { $service_config:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/gitblit.defaults.erb")
  }

  service { $service_name:
    ensure   => $service_ensure,
    enable   => $service_enable,
    provider => $service_provider,
    require  => [File[$service_path],File[$service_config]],
  }

  if $manageuser {
    group { $group:
      ensure => present,
      system => true,
    }

    user { $user:
      ensure     => present,
      gid        => $group,
      system     => true,
      managehome => false,
      before     => File[$datadir]
    }
  }

  create_resources('gitblit::config',$config)
}
