define cegeka_apache::module ($ensure='present') {

  include cegeka_apache::params

  $a2enmod_deps = $facts['os']['name'] ? {
    /RedHat|CentOS/ => [
      Package['cegeka_apache'],
      File['/etc/httpd/mods-available'],
      File['/etc/httpd/mods-enabled'],
      File['/usr/local/sbin/a2enmod'],
      File['/usr/local/sbin/a2dismod']
    ],
    /Debian|Ubuntu/ => Package['cegeka_apache'],
  }

  if $facts['os']['selinux']['enabled'] == true and $ensure == true {
    cegeka_apache::redhat::selinux {$name: }
  }

  $enablecmd = $facts['os']['name'] ? {
    'RedHat'  => "/usr/local/sbin/a2enmod ${name}",
    'CentOS'  => "/usr/local/sbin/a2enmod ${name}",
    default => "/usr/sbin/a2enmod ${name}"
  }

  $disablecmd = $facts['os']['name'] ? {
    /RedHat|CentOS/ => "/usr/local/sbin/a2dismod ${name}",
    /Debian|Ubuntu/ => "/usr/sbin/a2dismod ${name}",
  }

  case $ensure {
    'present' : {
      exec { "a2enmod ${name}":
        command => $enablecmd,
        unless  => "/bin/sh -c '[ -L ${cegeka_apache::params::conf}/mods-enabled/${name}.load ] \\
          && [ ${cegeka_apache::params::conf}/mods-enabled/${name}.load -ef ${cegeka_apache::params::conf}/mods-available/${name}.load ]'",
        require => $a2enmod_deps,
        notify  => Service['cegeka_apache'],
      }
    }

    'absent': {
      exec { "a2dismod ${name}":
        command => $disablecmd,
        onlyif  => "/bin/sh -c '[ -L ${cegeka_apache::params::conf}/mods-enabled/${name}.load ] \\
          || [ -e ${cegeka_apache::params::conf}/mods-enabled/${name}.load ]'",
        require => $a2enmod_deps,
        notify  => Service['cegeka_apache'],
      }
    }

    default: {
      fail ( "Unknown ensure value: '${ensure}'" )
    }
  }
}
