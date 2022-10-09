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
        The internal tracker of the inherited group if there is one.
    ]=]
    if inheritant then self._Inheritant = inheritant::Group; end
    --[=[
        @prop _Permissions {string}
        @within Group
        @private
        The internal tracker of the permission node container.
    ]=]
    self._Permissions = {};
    if permissions then
        for index: number,permission: string in ipairs(permissions) do
            self._Permissions[index] = permission;
        end
    end
    return setmetatable(self,Group) :: Group;
end

--[=[
    @within Group
    @param permission -- The permission node that will be queried
    @return boolean
    This method queries if a permission node is in this group.
]=]
function Group.HasPermission(self: Group,permission: string) : boolean
    local permIndex: number? = table.find(self._Permissions,permission);
    if not permIndex then
        -- If group has an asterisk then the group contains all permissions
        if table.find(self._Permissions,"*") then return true; end
        -- Check in the inheritant group
        if self._Inheritant then return self._Inheritant:HasPermission(permission); end
    end
    return permIndex and true or false;
end

--[=[
    @within Group
    @param permission string -- The permission node that will be granted to this group
    This function grants a permission node to the group in which this function is called.
]=]
function Group.GrantPermission(self: Group,permission: string)
    if table.find(self._Permissions,permission) then return; end
    table.insert(self._Permissions,permission);
end

--[=[
    @within Group
    @param permission string -- The permission node that will be granted to this group
    This function revokes a permission node in the group that this function was called.
]=]
function Group.RevokePermission(self: Group,permission: string)
    local foundIndex: number? = table.find(self._Permissions,permission);
    if foundIndex then table.remove(self._Permissions,foundIndex); end
end

return Group;