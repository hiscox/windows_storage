require 'puppet/parameter/boolean'
Puppet::Type.newtype(:virtual_disk) do
  ensurable

  newparam(:name) do
  end

  newparam(:storage_pool_friendly_name) do
  end

  newparam(:use_maximum_size, parent: Puppet::Parameter::Boolean) do
  end

  newparam(:interleave) do
  end

  newparam(:resiliency_setting_name) do
    newvalues('simple', 'mirror', 'parity')
  end

  newparam(:number_of_columns) do
  end
end
