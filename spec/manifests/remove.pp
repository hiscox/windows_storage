volume { 'test':
  ensure => absent,
}
storage_pool { 'test':
  ensure  => absent,
  require => Volume['test'],
}
