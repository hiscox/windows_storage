Puppet::Type.newtype(:storage_pool) do
  ensurable

  newparam(:name) do
  end

  newparam(:storage_subsystem_name) do
  end

  newparam(:physical_disks) do
  end
end
