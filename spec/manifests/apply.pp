storage_pool { 'test':
  ensure                 => present,
  storage_subsystem_name => 'Windows Storage*',
  physical_disks         => ['2','3','4','5'],
}
volume { 'test':
  ensure                     => present,
  allocation_unit_size       => 65536,
  file_system                => 'NTFS',
  storage_pool_friendly_name => 'test',
  drive_letter               => 'q',
  resiliency_setting_name    => 'simple',
  use_maximum_size           => true,
  require                    => Storage_pool['test'],
}
