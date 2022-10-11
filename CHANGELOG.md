# Changelog

## [Unreleased]
### Added
- Permissions.IsUserInGroup() to see if a user is in a group
- TestEZ for testing
- Functionality for using negated permission nodes in Permissions & Group classes
- Group.SetPrecedence() used to assign a group precedence over others
- Group.SetInheritant() used to "inherit" another groups permissions
- Internal function isNodeNegated() to check for negated permission nodes
### Changed
- Permissions.Init() to take a table as a config rather then ModuleScript
- Moonwave documentation improvements/typos
### Removed
- Outdated test config
- Changelog unnecessary tags
- Require on the config in Permissions.Init()
## [0.1.0]
### Added
- The initial required files to the repository
### Changed
### Removed