class gitblit::install::staging (
  $version    = '1.6.1',
  $installdestdir = undef,
) {

  # crude hack because puppet does not allow a class
  # parameter to be used as default value for another
  # class parameter
  $installdestdir_real = pick($installdestdir,"/opt/gitblit-${version}")

  $filename     = "gitblit-${version}.tar.gz"
  $download_url = "http://dl.bintray.com/gitblit/releases/${filename}"

  staging::deploy { $filename:
    source  => $download_url,
    target  => $installdestdir_real,
    creates => "${installdestdir_real}/gitblit.jar",
    require => File[$installdestdir_real],
  }

  file { $installdestdir_real:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { $gitblit::installdir:
    ensure => link,
    target => $installdestdir_real,
  }

  exec { 'initial-datadir-provisioning':
    command     => "cp -r ${installdestdir_real}/data/* ${gitblit::datadir}/",
    path        => '/bin:/usr/bin',
    creates     => "${gitblit::datadir}/gitblit.properties",
    refreshonly => true,
    require     => Staging::Deploy[$filename],
    subscribe   => File[$gitblit::datadir],
  }

  exec { 'initial-datadir-provisioning-accessrights':
    command     => "chown -R ${gitblit::user}:${gitblit::group} ${gitblit::datadir}",
    path        => '/bin:/usr/bin',
    refreshonly => true,
    subscribe   => Exec['initial-datadir-provisioning'],
  }
}
