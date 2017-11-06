require 'json'
Puppet::Type.type(:storage_pool).provide(:powershell) do
  confine :operatingsystem => :windows
  commands :powershell =>
              if File.exists?("#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe")
                "#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe"
              elsif File.exists?("#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe")
                "#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe"
              else
                'powershell.exe'
              end

  mk_resource_methods

  def self.invoke_ps_command(command)
    result = powershell(
      ['-noprofile', '-noninteractive', '-executionpolicy',
       'bypass', '-encodedcommand', encoded_command(command)]
    )
    result.lines
  end

  def self.encoded_command(command)
    Base64.strict_encode64(command.encode('utf-16le'))
  end

  def self.instances
    result = invoke_ps_command instances_command
    result.each.collect do |line|
      pool = JSON.parse(line.strip, symbolize_names: true)
      pool[:ensure] = :present
      new(pool)
    end
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    self.class.invoke_ps_command create_command
    @property_hash[:ensure] = :present
  end

  def destroy
    self.class.invoke_ps_command destroy_command
    @property_hash.clear
  end

  def physical_disks=(value)
    raise 'This property cannot be changed once a resource has been created'
  end

  def self.instances_command
    <<-COMMAND
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'
$pools = @(Get-StoragePool)
foreach ($pool in $pools) {
  $disks = @($pool | Get-PhysicalDisk)
  $hash = [ordered]@{
    name = $pool.FriendlyName
    physical_disks = @($disks.DeviceId)
  }
  $hash | ConvertTo-Json -Depth 99 -Compress
}
    COMMAND
  end

  def create_command
    physical_disks_string = @resource[:physical_disks].join(',')
    <<-COMMAND
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'
$physicalDisks = Get-PhysicalDisk | where DeviceId -in #{physical_disks_string}
$params = @{
  FriendlyName = '#{@resource[:name]}'
  StorageSubSystemFriendlyName = '#{@resource[:storage_subsystem_name]}'
  PhysicalDisks = $physicalDisks
}
New-StoragePool @params
    COMMAND
  end

  def destroy_command
    <<-COMMAND
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'
Remove-StoragePool -FriendlyName '#{@resource[:name]}' -Confirm:$false
    COMMAND
  end
end
