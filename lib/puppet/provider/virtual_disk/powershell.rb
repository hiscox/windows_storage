require 'json'
Puppet::Type.type(:virtual_disk).provide(:powershell) do
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
      disk = JSON.parse(line.strip, symbolize_names: true)
      disk[:ensure] = :present
      new(disk)
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

  def self.instances_command
    <<-COMMAND
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'
$disks = @(Get-StorageNode | where Name -Match $env:COMPUTERNAME | Get-VirtualDisk)
foreach ($disk in $disks) {
  $hash = [ordered]@{
    name = $disk.FriendlyName
  }
  $hash | ConvertTo-Json -Depth 99 -Compress
}
    COMMAND
  end

  def create_command
    <<-COMMAND
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'
$params = @{
  FriendlyName = '#{@resource[:name]}'
  StoragePoolFriendlyName = '#{@resource[:storage_pool_friendly_name]}'
  ResiliencySettingName = '#{@resource[:resiliency_setting_name]}'
  UseMaximumSize = $#{@resource[:use_maximum_size]}
  Interleave = #{@resource[:interleave]}
  NumberOfColumns = #{@resource[:number_of_columns]}
}
New-VirtualDisk @params
    COMMAND
  end

  def destroy_command
    <<-COMMAND
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'
Get-StorageNode | where Name -Match $env:COMPUTERNAME |
  Get-VirtualDisk -FriendlyName '#{@resource[:name]}' | Remove-VirtualDisk -Confirm:$false
    COMMAND
  end
end
