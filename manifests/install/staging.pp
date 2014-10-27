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
    source => $download_url,
    target => $installdestdir_real,
  }

  file { $gitblit::installdir:
    ensure => link,
    target => $installdestdir_real,
  }

  exec { "cp -r ${installdestdir_real}/data/* ${gitblit::datadir}/":
    path        => '/bin:/usr/bin',
    creates     => "${gitblit::datadir}/gitblit.properties",
    refreshonly => true,
    require     => Staging::Deploy[$filename],
    subscribe   => File[$gitblit::datadir],
  }
}
