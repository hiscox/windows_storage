storage_pool { 'test':
  ensure                 => present,
  storage_subsystem_name => 'Windows Storage*',
  physical_disks         => ['2','3','4','5'],
}
virtual_disk { 'test':
  ensure                     => present,
  storage_pool_friendly_name => 'test',
  use_maximum_size           => true,
  resiliency_setting_name    => 'simple',
  interleave                 => 65536,
  number_of_columns          => 4,
  require                    => Storage_pool['test'],
}
volume { 'test':
  ensure               => present,
  disk_friendly_name   => 'test',
  allocation_unit_size => 65536,
  file_system          => 'NTFS',
  drive_letter         => 'q',
  require              => Virtual_disk['test']
}
