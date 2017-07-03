# File-Sync Repository
#
# This defined type manages a file-sync repository
#
# @summary Manages file-sync repos
#
# @example something
#
# @param staging_dir The path to the repository's staging directory. This is the directory where changes to the repository's contents should be made.
# @param live_dir The path to the live directory that the repository's contents should be synced to by the File Sync Client.
# @param auto_commit A boolean indicating whether or not to trigger a commit automatically when files in the staging dir change (are created, modified, or deleted). This should only appear when running the storage service (when staging-dir is set). Defaults to false.
# @param client_active A boolean indicating whether or not the File Sync Client should be actively syncing the repo. When false, commits can be still be triggered for the repo. Should only appear when live-dir is not set for the repo. Defaults to true.
# @param honor_gitignore A boolean indicating whether or not .gitignore files in the staging-dir should be used to filter files from being committed. Should only appear when staging-dir is set. Defaults to false.
# @param submodules_dir The relative path within the repository's working tree where submodules will be added. This key is only necessary if submodules are desired for a particular repo, and should only appear when running the storage service.
# @param confdir Location of the file-sync config file
define file_sync::repo (
  Stdlib::Absolutepath           $staging_dir,
  Stdlib::Absolutepath           $live_dir,
  String                         $staging_dir_owner = 'pe-puppet',
  String                         $staging_dir_group = 'pe-puppet',
  String                         $staging_dir_mode  = '0755',
  String                         $live_dir_owner    = 'pe-puppet',
  String                         $live_dir_group    = 'pe-puppet',
  String                         $live_dir_mode     = '0755',
  Optional[Boolean]              $auto_commit       = false,
  Optional[Boolean]              $client_active     = true,
  Optional[Boolean]              $honor_gitignore   = false,
  Optional[String]               $submodules_dir    = undef,
  Optional[Stdlib::Absolutepath] $confdir           = undef,
) inherits ::puppet_enterprise::master::file_sync {

  $_confdir = $confdir ? {
    undef   => $::puppet_enterprise::master::file_sync::confdir,
    default => $confdir,
  }

  file { $staging_dir:
    ensure => directory,
    owner  => $staging_dir_owner,
    group  => $staging_dir_group,
    mode   => $staging_dir_mode,
  }

  file { $live_dir:
    ensure => directory,
    owner  => $live_dir_owner,
    group  => $live_dir_group,
    mode   => $live_dir_mode,
  }

  if ($staging_dir and !(pe_compile_master())) {
    pe_hocon_setting { "file-sync.repos.${title}.auto-commit":
      path   => "${_confdir}/conf.d/file-sync.conf",
      value  => $staging_dir,
      notify => Serice['pe-puppetserver'],
    }
  }

  if ($auto_commit and !(pe_compile_master())) {
    pe_hocon_setting { "file-sync.repos.${title}.auto-commit":
      path   => "${_confdir}/conf.d/file-sync.conf",
      value  => $auto_commit,
      notify => Serice['pe-puppetserver'],
    }
  }

  if ($client_active and !(pe_compile_master())) {
    pe_hocon_setting { "file-sync.repos.${title}.client-active":
      path   => "${_confdir}/conf.d/file-sync.conf",
      value  => $client_active,
      notify => Serice['pe-puppetserver'],
    }
  }

  if ($honor_gitignore and !(pe_compile_master())) {
    pe_hocon_setting { "file-sync.repos.${title}.honor-gitignore":
      path   => "${_confdir}/conf.d/file-sync.conf",
      value  => $honor_gitignore,
      notify => Serice['pe-puppetserver'],
    }
  }

  if ($submodules_dir and !(pe_compile_master())) {
    pe_hocon_setting { "file-sync.repos.${title}.submodules-dir":
      path   => "${_confdir}/conf.d/file-sync.conf",
      value  => $submodules_dir,
      notify => Serice['pe-puppetserver'],
    }
  }

  if $live_dir {
    pe_hocon_setting { "file-sync.repos.${title}.live-dir":
      path   => "${_confdir}/conf.d/file-sync.conf",
      value  => $live_dir,
      notify => Serice['pe-puppetserver'],
    }
  }
}
