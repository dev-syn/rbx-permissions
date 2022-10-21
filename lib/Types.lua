export type Map<K,V> = {[K]: V};
export type Dictionary<T> = Map<string,T>;

export type PresetUserData = {
    Permissions: {string},
    Groups: {string}
};

export type Config = {
    Groups: {Group},
    Users: Dictionary<PresetUserData>,
    DefaultGroup: Group?
};

export type Schema_Group = {
    __index: any,

    new: (name: string,permissions: {string}?,inheritant: Group?) -> Group,
    SetInheritant: (self: Group,inheritant: Group) -> Group,
    SetPrecedence: (self: Group,precedence: number) -> Group,
    SetPrefix: (self: Group,prefix: string) -> Group,
    GrantPermission: (self: Group,permission: string) -> (),
    RevokePermission: (self: Group,permission: string) -> (),
    HasPermission: (self: Group,permission: string) -> boolean
};
export type Object_Group = {
    Name: string,
    _Inheritant: Group,
    _Permissions: {string},
    _Prefix: string,
    _Precedence: number
};

export type Group = Object_Group & Schema_Group;

export type Permissions = {
    Group: Schema_Group,

    _UserPermissions: Map<Player,{string}>,
    _UserGroups: Map<Player,{Group}>,
    _Groups: Dictionary<Group>,

    LoadConfig: (config: Config) -> (),
    Init: (permissionsConfig: Config?) -> Permissions,
    FindGroup: (name: string) -> Group?,
    FindHighestGroupPrecedence: (plr: Player) -> Group?,
    IsUserInGroup: (plr: Player,group: Group) -> boolean,
    SetUserGroup: (plr: Player,group: Group) -> (),
    RemoveUserGroup: (plr: Player,group: Group) -> (),
    GrantPermission: (plr: Player,permission: string) -> (),
    RevokePermission: (plr: Player,permission: string) -> (),
    HasPermission: (plr: Player,permission: string) -> boolean
};

return true;