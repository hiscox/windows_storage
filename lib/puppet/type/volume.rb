Puppet::Type.newtype(:volume) do
  ensurable

  newparam(:name) do
  end

  newparam(:disk_friendly_name) do
    validate do |value|
      raise('disk_friendly_name must be specified') if value.nil?
    end
  end

  newparam(:allocation_unit_size) do
  end

  newparam(:file_system) do
    newvalues('NTFS', 'ReFS', 'CSVFS_NTFS', 'CSVFS_ReFS')
  end

  newparam(:drive_letter) do
  end
end
