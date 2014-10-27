define gitblit::config (
  $ensure     = present,
  $configfile = "${gitblit::datadir}/gitblit.properties",
  $value      = undef,
) {

  case $ensure {
    present: {
      if $value == undef {
        fail("You have to provide a value for ${title}")
      }
      $action = 'set'
    }
    absent: {
      $action = 'rm'
    }
    default: { fail('Ensure can only be present or absent') }
  }

  if is_array($value) {
    $flatvalue = join($value,',')
  }
  else {
    $flatvalue = $value
  }

  augeas { "gitblit-property-${title}":
    context => "/files${configfile}",
    incl    => $configfile,
    lens    => 'Properties.lns',
    changes => "${action} ${title} '${flatvalue}'",
  }
}
