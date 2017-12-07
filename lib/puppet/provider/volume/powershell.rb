require 'json'
Puppet::Type.type(:volume).provide(:powershell) do
  confine :operatingsystem => :windows
  commands :powershell =>
              if File.exists?("#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe")
                "#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe"
              elsif File.exists?("#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe")
                "#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe"
              else
                'powershell.exe'
              end

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

  def exists?
    result = self.class.invoke_ps_command exists_command
    result.first.strip.downcase == true.to_s
  end

  def create
    self.class.invoke_ps_command create_command
  end

  def destroy
    self.class.invoke_ps_command destroy_command
  end

  def exists_command
    <<-COMMAND
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'
(Get-StorageNode | where Name -Match $env:COMPUTERNAME |
  Get-Volume | where FileSystemLabel -Eq '#{@resource[:name]}') -ne $null
    COMMAND
  end

  def create_command
    <<-COMMAND
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'
$disk = Get-StorageNode | where Name -Match $env:COMPUTERNAME | Get-Disk | where FriendlyName -Eq '#{@resource[:disk_friendly_name]}'
$params = @{
  FriendlyName = '#{@resource[:name]}'
  Disk = $disk
  AllocationUnitSize = #{@resource[:allocation_unit_size]}
  AccessPath = '#{@resource[:drive_letter]}:'
  FileSystem = '#{@resource[:file_system]}'
}
New-Volume @params
    COMMAND
  end

  def destroy_command
    <<-COMMAND
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'
Get-StorageNode | where Name -Match $env:COMPUTERNAME | Get-Volume | where FileSystemLabel -Eq '#{@resource[:name]}' |
  Get-Partition | Remove-Partition -Confirm:$false
    COMMAND
  end
end
