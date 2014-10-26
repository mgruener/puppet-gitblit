class gitblit::install::staging (
  $version    = '1.6.1',
  $installdestdir = "/opt/gitblit-${version}",
) {
  $filename     = "gitblit-${version}.tar.gz"
  $download_url = "http://dl.bintray.com/gitblit/releases/${filename}"

  staging::deploy { $filename:
    source => $download_url,
    target => $installdestdir,
  }

  file { $gitblit::installdir:
    ensure => link,
    target => $installdestdir,
  }

  exec { "cp -r ${installdestdir}/data/* ${gitblit::datadir}/":
    path        => '/bin:/usr/bin',
    creates     => "${gitblit::datadir}/gitblit.properties",
    refreshonly => true,
    require     => Staging::Deploy[$filename],
    subscribe   => File[$gitblit::datadir],
  }
}
