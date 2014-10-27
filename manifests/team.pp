define gitblit::team (
  $ensure   = present,
  $teamname = $title,
  $accounttype = 'LOCAL',
  $mailinglist = undef,
  $roles = undef,
  $repositories = undef,
) {
  concat::fragment { "team-${title}":
    ensure  => $ensure,
    target  => 'users.conf',
    content => template("${module_name}/team.snippet.erb"),
  }
}
