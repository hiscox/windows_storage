require 'puppet/parameter/boolean'
Puppet::Type.newtype(:virtual_disk) do

  ensurable

  newparam(:name) do
  end

  newparam(:storage_pool_name) do
  end

  newparam(:use_maximum_size, parent: Puppet::Parameter::Boolean) do
  end

  newproperty(:resiliency_setting_name) do
    newvalues('simple', 'mirror', 'parity')
  end
end
