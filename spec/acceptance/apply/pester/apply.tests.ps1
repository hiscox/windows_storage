Describe "windows_storage" {
  Context "storage_pool" {
    It "creates a storage pool" {
      $pool = Get-StoragePool -FriendlyName "test" -ErrorAction SilentlyContinue
      $pool | Should -Not -BeNullOrEmpty
    }
  }
  Context "volume" {
    It "creates a volume" {
      $volume = Get-Volume -FileSystemLabel "test" -ErrorAction SilentlyContinue
      $volume | Should -Not -BeNullOrEmpty
    }
    It "assigns a drive letter" {
      $volume = Get-Volume -DriveLetter "q" -ErrorAction SilentlyContinue
      $volume | Should -Not -BeNullOrEmpty
    }
  }
}