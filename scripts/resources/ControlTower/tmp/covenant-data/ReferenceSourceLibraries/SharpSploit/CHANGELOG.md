# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased
### Added
- Added Evasion namespace, Amsi class, PatchAmsiScanBuffer function (credit @rasta-mouse)
- Added Is64Bit Utility property (credit @rasta-mouse)
- Added Is64BitProcess Host function (credit @TheWover)
- Added GetProcessorArchitecture, GetParentProcess, GetProcessOwner, IsWow64, and supporting P/Invoke signatures (credit @rasta-mouse)
- Added Keylogger class (credit @checkymander)
- Added SCM class, PowerShellRemoting class, Host.GetDacl function (credit @rasta-mouse)
- Added NetShareEnum functionality for Share Enumeration (credit @checkymander)
- Added in-memory export parsing (credit @b33f)

### Changed
- Improved DynamicInvoke library (credit @TheWover)
- Removed GetProcessListing use of WMI to obtain ppid (credit @rasta-mouse)
- Improved GetProcessListing to include ppid, architecture, owner, and sort by PID (credit @rasta-mouse)
- Improved SharpSploitResultList ToString() display
- Updated powerkatz dlls, fixed LsaSecrets/LsaCache/SamDump mimikatz shortcuts

## [v1.4]
### Added
- Added GetDirectoryListing of a specific path
- Added stderr to output of ShellExecute functions
- Added ShellCmdExecute function
- Added registry class with improved read/write functions
- Added remote registry functions
- Added GPO enumeration functions (credit @panagioto)
- Added Autorun, Startup, WMI persistence functions (credit @rasta-mouse)
- Added DynamicInvoke namespace (credit @TheWover)
### Changed
- Updated mimikatz binaries
- Changed mimikatz function to load in new thread, free input/output pointers
- Updated registry tests

### Fixed
- Fixed XML warning, removed angle brackets in comment

## [v1.3] - 2019-03-03
### Fixed
- Fixed SharpSploit.Enumeration.Host.ChangeCurrentDirectory() to accept absolute paths
- Fixed SharpSploit.Enumeration.Host.GetProcessList() retrieves valid ppid values

## [v1.2] - 2019-02-12
### Added
- Added CHANGELOG.md
- Added Assembly EntryPoint execution

## [v1.1] - 2018-11-03
### Added
- Added DCOM lateral movement
- Added nuget package

### Changed
- Updated README

### Fixed
- Fixed Domain warnings
- Fixed XML path
- Fixed Mimikatz quoting

## v1.0 - 2018-09-20
- Initial release

[v1.1]: https://github.com/cobbr/SharpSploit/compare/v1.0...v1.1
[v1.2]: https://github.com/cobbr/SharpSploit/compare/v1.1...v1.2
[v1.3]: https://github.com/cobbr/SharpSploit/compare/v1.2...v1.3
