--- @module lib/Types
local Types = require(script.Parent:FindFirstChild("Types"));

export type Group = Types.Group;

local Group = {} :: Types.Schema_Group;
--[=[
    @class Group
    This class is for creating groups and storing permissions within those groups.
]=]
Group.__index = Group;

--[=[
    @within Group
    @param name string -- The name that will be for this group
    @param permissions {string}? -- A table of permission nodes or nil
    @param inheritant Group? -- The group that will be inherited with it's permission nodes
    @return Group
    Creates a new Group object.
]=]
function Group.new(name: string,permissions: {string}?,inheritant: Group?) : Group
    local self = {} :: Types.Object_Group;
    --[=[
        @prop Name string
        @within Group
        The name of the group.
    ]=]
    self.Name = name;
    --[=[
        @prop _Prefix string
        @within Group
        @private
        The internal prefix of this group.
    ]=]
    self._Prefix = "";
    --[=[
        @prop _Inheritant Group?
        @within Group
        @private
        The internal property of the inherited group if there is one.
    ]=]
    if inheritant then self._Inheritant = inheritant::Group; end
    --[=[
        @prop _Permissions {string}
        @within Group
        @private
        The internal property of the permission node container.
    ]=]
    self._Permissions = {};
    if permissions then
        for index: number,permission: string in ipairs(permissions) do
            self._Permissions[index] = permission;
        end
    end
    --[=[
        @prop _Precedence number
        @within Group
        @private
        The internal property that tracks the groups order of precedence
    ]=]
    self._Precedence = -1;
    return setmetatable(self,Group) :: Group;
end

--[=[
    @within Group
    @param inheritant Group -- The groups permissions that would be inherited
    This method will set the inheritant that will have it's permissions inherited
]=]
function Group.SetInheritant(self: Group,inheritant: Group) : Group
    self._Inheritant = inheritant;
    return self;
end

--[=[
    @within Group
    This method will set this groups precedence
]=]
function Group.SetPrecedence(self: Group,precedence: number) : Group
    self._Precedence = precedence;
    return self;
end

local function isNodeNegated(node: string) : boolean
    return (node:match("%s*%-.+") and true) or false;
end

--[=[
    @within Group
    @param permission string -- The permission node that will be granted to this group
    This method grants a permission node to the group
]=]
function Group.GrantPermission(self: Group,permission: string)
    local groupPerms: {string} = self._Permissions;
    -- Revoke negated permission nodes if you are trying to grant that permission
    if not isNodeNegated(permission) then Group.RevokePermission(self,"-"..permission); end
    if table.find(self._Permissions,permission) then return; end
    table.insert(self._Permissions,permission);
end

--[=[
    @within Group
    @param permission string -- The permission node that will be granted to this group
    This method revokes a permission node from the group
]=]
function Group.RevokePermission(self: Group,permission: string)
    local foundIndex: number? = table.find(self._Permissions,permission);
    if foundIndex then table.remove(self._Permissions,foundIndex); end
end

--[=[
    @within Group
    @param permission -- The permission node that will be queried
    @return boolean
    This method queries if a permission node is in this group, negated permission nodes take priority and when present in the groups permissions it will return false.
]=]
function Group.HasPermission(self: Group,permission: string) : boolean
    local groupPerms: {string} = self._Permissions;
    -- Check if the queried permission is negated
    local isQueryNegated: boolean = isNodeNegated(permission);
    if not isQueryNegated then
        -- Group has no permission if a negated permission is found
        if table.find(groupPerms,"-"..permission) then return false; end
    end
    local permIndex: number? = table.find(groupPerms,permission);
    if not permIndex then
        -- If group has an asterisk then the group contains all permissions
        if table.find(groupPerms,"*") then return true; end
        -- Check in the inheritant group
        if self._Inheritant then return self._Inheritant:HasPermission(permission); end
    end
    return permIndex and true or false;
end

return Group;