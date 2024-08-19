class cegeka_apache::webdav::ssl {
  include cegeka_apache::ssl

  case $facts['os']['name'] {
    'Debian','Ubuntu':  { include cegeka_apache::webdav::ssl::debian}
    default: { fail("Unsupported operatingsystem ${facts['os']['name']}") }
  }
}
