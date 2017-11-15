require 'puppet/parameter/boolean'
Puppet::Type.newtype(:volume) do
  ensurable

  newparam(:name) do
  end

  newparam(:storage_pool_friendly_name) do
  end

  newparam(:allocation_unit_size) do
  end

  newparam(:file_system) do
    newvalues('NTFS', 'ReFS', 'CSVFS_NTFS', 'CSVFS_ReFS')
  end

  newparam(:drive_letter) do
  end

  newparam(:resiliency_setting_name) do
    newvalues('simple', 'mirror', 'parity')
  end

  newparam(:use_maximum_size, parent: Puppet::Parameter::Boolean) do
  end
end
