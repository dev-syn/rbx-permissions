# Changelog

## [Unreleased]

## [0.3.0]
### Added
- Permissions.LoadConfig used to load configuration files into Permissions

## [0.2.3]
### Removed
- Dependencies folder inside Permissions (mb)
## [0.2.2]
### Added
- Export Schema_Group type in Permissions

## [0.2.1]
### Removed
- Permissions.HasPermission removed redundant variable

## [0.2.0]
### Added
- Permissions.IsUserInGroup() to see if a user is in a group
- TestEZ for testing
- Functionality for using negated permission nodes in Permissions & Group classes
- Group.SetPrecedence() used to assign a group precedence over others
- Group.SetInheritant() used to "inherit" another groups permissions
- Permissions.FindHighestGroupPrecedence() used to return the highest group precedence
- Internal function isNodeNegated() to check for negated permission nodes
- TextStyling for styling group prefixes
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