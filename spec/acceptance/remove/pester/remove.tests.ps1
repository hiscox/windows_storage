Describe "windows_storage" {
  Context "storage_pool" {
    It "removes a storage pool" {
      $pool = Get-StoragePool -FriendlyName "test" -ErrorAction SilentlyContinue
      $pool | Should -BeNullOrEmpty
    }
  }
  Context "volume" {
    It "removes a volume" {
      $volume = Get-Volume -FileSystemLabel "test" -ErrorAction SilentlyContinue
      $volume | Should -BeNullOrEmpty
    }
  }
}