define gitblit::project (
  $ensure       = present,
  $description  = $name,
  $doc          = undef,
) {

  if $title == 'main' {
    $projectpath = "${gitblit::datadir}/git"
  } else {
    $projectpath = "${gitblit::datadir}/git/${title}"
  }

  file { $projectpath:
    ensure => $ensure ? {
                present => directory,
                absent  => absent
              },
    owner  => $gitblit::user,
    group  => $gitblit::group,
    mode   => '0755',
  }

  if $doc {
    file { "${projectpath}/project.mkd":
      ensure => $ensure ? {
                  present => file,
                  absent  => absent
                },
      owner  => $gitblit::user,
      group  => $gitblit::group,
      mode   => '0755',
    }
  }

  concat::fragment { "project-${title}":
    ensure  => $ensure,
    target  => 'projects.conf',
    content => template("${module_name}/project.snippet.erb"),
  }
}
