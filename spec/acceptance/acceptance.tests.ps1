Describe "windows_storage" {
  Context "storage_pool" {
    It "creates a storage pool" {
      $pool = Get-StoragePool -FriendlyName "test" -ErrorAction SilentlyContinue
      $pool | Should -Not -BeNullOrEmpty
    }
  }
  Context "virtual_disk" {
    It "creates a virtual disk" {
      $vdisk = Get-VirtualDisk -FriendlyName "test" -ErrorAction SilentlyContinue
      $vdisk | Should -Not -BeNullOrEmpty
    }
  }
}