define gitblit::user (
  $password,
  $ensure                   = present,
  $username                 = $title,
  $passwordtype             = 'CMD5',
  $accounttype              = 'LOCAL',
  $emailmeonmyticketchanges = true,
  $displayname              = $title,
  $emailaddress             = undef,
  $organizationalunit       = undef,
  $organization             = undef,
  $locality                 = undef,
  $stateprovince            = undef,
  $countrycode              = undef,
  $disabled                 = undef,
  $locale                   = undef,
  $preferredtransport       = undef,
  $roles                    = undef,
  $repositories             = undef,
) {
  case downcase($passwordtype) {
    'plain': { $password_real = $password }
    'md5': {
      $passmd5 = md5($password)
      $password_real = "MD5:${passmd5}"
    }
    'combined-md5','cmd5': {
      $lcaseusername = downcase($username)
      $passmd5 = md5("${lcaseusername}${password}")
      $password_real = "CMD5:${passmd5}"
    }
    default: { fail("Unsupported password type ${passwordtype}.") }
  }

  # gitblit uses the raw password hash including the
  # mechanism prefix (MD5 oder CMD5) as input for the
  # cookie hash
  $cookie = sha1("${username}${password_real}")

  concat::fragment { "user-${title}":
    ensure  => $ensure,
    target  => 'users.conf',
    content => template("${module_name}/user.snippet.erb"),
  }
}
