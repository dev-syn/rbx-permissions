export type Map<K,V> = {[K]: V};
export type Dictionary<T> = Map<string,T>;

export type Schema_Group = {
    __index: any,

    new: (name: string,permissions: {string}?,inheritant: Group?) -> Group,
    HasPermission: (self: Group,permission: string) -> boolean,
    GrantPermission: (self: Group,permission: string) -> (),
    RevokePermission: (self: Group,permission: string) -> ()
};
export type Object_Group = {
    Name: string,
    _Inheritant: Group,
    _Permissions: {string},
    _Prefix: string
};

export type Group = Object_Group & Schema_Group;

export type Permissions = {
    Group: Schema_Group,

    _UserPermissions: Map<Player,{string}>,
    _UserGroups: Map<Player,{Group}>,
    _Groups: Dictionary<Group>,

    Init: (permissionsConfig: Dictionary<any>?) -> Permissions,
    FindGroup: (name: string) -> Group,
    IsUserInGroup: (plr: Player,group: Group) -> boolean,
    SetUserGroup: (plr: Player,group: Group) -> (),
    RemoveUserGroup: (plr: Player,group: Group) -> (),
    GrantPermission: (plr: Player,permission: string) -> (),
    RevokePermission: (plr: Player,permission: string) -> (),
    HasPermission: (plr: Player,permission: string) -> boolean
};

return true;