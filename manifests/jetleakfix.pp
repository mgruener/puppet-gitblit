# Quickfix for
# https://github.com/eclipse/jetty.project/blob/master/advisories/2015-02-24-httpparser-error-buffer-bleed.md
class gitblit::jetleakfix (
  $version = '9.2.9.v20150224',
  $baseurl = 'http://repo1.maven.org/maven2/org/eclipse/jetty/aggregate/jetty-all',
  $absoluteurl = '',
) {
  $file = "jetty-all-${version}.jar"
  if $absoluteurl {
    $url = $absoluteurl
  } else {
    $url = "${baseurl}/${version}/${file}"
  }

  staging::file { $file:
    source => $url,
    target => "${::gitblit::installdir}/ext/${file}",
    notify => Service[$::gitblit::service_name],
  }

  file { "${::gitblit::installdir}/ext/jetty-all-9.2.3.v20140905.jar":
    ensure => absent,
    notify => Service[$::gitblit::service_name],
  }
}
