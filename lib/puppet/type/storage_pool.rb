Puppet::Type.newtype(:storage_pool) do

  ensurable

  newparam(:name) do
  end

  newparam(:storage_subsystem_name) do
  end

  newproperty(:physical_disks, array_matching: :all) do
    def insync?(is)
      is.sort == should.sort
    end
  end

end
