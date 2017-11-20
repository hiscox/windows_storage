volume { 'test':
  ensure => absent,
}
virtual_disk { 'test':
  ensure  => absent,
  require => Volume['test'],
}
storage_pool { 'test':
  ensure  => absent,
  require => Virtual_disk['test'],
}
