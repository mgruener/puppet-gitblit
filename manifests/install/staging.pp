class gitblit::install::staging (
  $version    = '1.6.1',
  $installdestdir = '/opt',
  $download_url   = undef
) {

  # crude hack because puppet does not allow (reliably) a class
  # parameter to be used as default value for another class parameter
  # see https://tickets.puppetlabs.com/browse/PUP-1080
  $download_url_real = pick($download_url,"http://dl.bintray.com/gitblit/releases/gitblit-${version}.tar.gz")
  $filename          = basename($download_url_real)

  $basedir = "${installdestdir}/gitblit-${version}"
  if versioncmp('1.7',$version) > 0 {
    $targetdir = $basedir

    file { $targetdir:
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      before => Staging::Deploy[$filename],
    }
  } else {
    $targetdir = $installdestdir
  }

  staging::deploy { $filename:
    source  => $download_url_real,
    target  => $targetdir,
    creates => "${basedir}/gitblit.jar",
  }

  file { $gitblit::installdir:
    ensure => link,
    target => $basedir,
  }

  exec { 'initial-datadir-provisioning':
    command     => "cp -r ${basedir}/data/* ${gitblit::datadir}/",
    path        => '/bin:/usr/bin',
    creates     => "${gitblit::datadir}/certs",
    require     => Staging::Deploy[$filename],
    subscribe   => File[$gitblit::datadir],
  }

  exec { 'initial-datadir-provisioning-accessrights':
    command     => "chown -R ${gitblit::user}:${gitblit::group} ${gitblit::datadir}",
    path        => '/bin:/usr/bin',
    refreshonly => true,
    subscribe   => Exec['initial-datadir-provisioning'],
    notify      => Service[$gitblit::service_name],
    before      => [Concat['users.conf'],Concat['projects.conf']],
  }
}
