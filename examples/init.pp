storage_pool { 'test':
  storage_subsystem_name => 'Windows Storage*',
  physical_disks         => ['2','3','4','5'],
}
virtual_disk { 'test':
  storage_pool_name       => 'test',
  resiliency_setting_name => 'simple',
  use_maximum_size        => true,
  require                 => Storage_pool['test'],
}
