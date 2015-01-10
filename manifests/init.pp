class gitblit (
  $datadir                 = '/var/lib/gitblit',
  $installdir              = '/opt/gitblit',
  $http_port               = '0',
  $https_port              = '8443',
  $user                    = 'gitblit',
  $group                   = 'gitblit',
  $manageuser              = true,
  $manage_gitblit_users    = true,
  $manage_gitblit_projects = true,
  $service_name            = $gitblit::params::service_name,
  $service_provider        = $gitblit::params::service_provider,
  $service_template        = $gitblit::params::service_template,
  $service_path            = $gitblit::params::service_path,
  $service_config          = $gitblit::params::service_config,
  $service_ensure          = running,
  $service_enable          = true,
  $adminpassword           = 'admin',
  $adminpasswordtype       = 'combined-md5',
  $mainprojectdoc          = undef,
  $config                  = {},
  $users                   = {},
  $teams                   = {},
  $projects                = {},
  $hiera_merge             = false,
) inherits gitblit::params {
  # only one installation method at the moment
  include gitblit::install::staging

  if $hiera_merge {
    $config_real   = hiera_hash('gitblit::config')
    $users_real    = hiera_hash('gitblit::users')
    $teams_real    = hiera_hash('gitblit::teams')
    $projects_real = hiera_hash('gitblit::projects')
  } else {
    $config_real   = $config
    $users_real    = $users
    $teams_real    = $teams
    $projects_real = $projects
  }

  file { $datadir:
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0755',
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
    content => template("${module_name}/service/gitblit.defaults.erb")
  }

  service { $service_name:
    ensure   => $service_ensure,
    enable   => $service_enable,
    provider => $service_provider,
    require  => [File[$service_path],File[$service_config]],
  }

  concat { 'users.conf':
    ensure  => present,
    path    => "${datadir}/users.conf",
    owner   => $user,
    group   => $group,
    mode    => '0640',
    warn    => true,
    force   => true,
    replace => $manage_gitblit_users,
    require => File[$datadir],
  }

  if $manage_gitblit_users {
    gitblit::user { 'admin':
      ensure       => present,
      passwordtype => $adminpasswordtype,
      password     => $adminpassword,
      roles        => [ '#admin', '#notfederated' ],
      accounttype  => 'LOCAL',
    }

    create_resources('gitblit::user',$users_real)
    create_resources('gitblit::team',$teams_real)
  }

  concat { 'projects.conf':
    ensure  => present,
    path    => "${datadir}/projects.conf",
    owner   => $user,
    group   => $group,
    mode    => '0644',
    warn    => true,
    force   => true,
    replace => $manage_gitblit_projects,
    require => File[$datadir],
  }

  if $manage_gitblit_projects {
    gitblit::project { 'main':
      ensure      => present,
      name        => 'Main Repositories',
      description => 'main group of repositories',
      doc         => $mainprojectdoc
    }

    create_resources('gitblit::project',$projects_real)
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
      home       => $datadir,
      before     => File[$datadir]
    }
  }

  create_resources('gitblit::config',$config_real)
}
