--- @module lib/Types
local Types = require(script.Parent:FindFirstChild("Types"));

export type Group = Types.Group;

local Group = {} :: Types.Schema_Group;
--[=[
    @class Group

    This class was designed for creating groups and storing permissions within those groups.
]=]
Group.__index = Group;

--[=[
    @within Group
    @param permissions {string}? -- The permission nodes that the group will contain
    @param inheritant Group? -- The group that will be inherited
    @return Group

    This function creates a new [Group] object.
]=]
function Group.new(name: string,permissions: {string}?,inheritant: Group?) : Group
    local self = {} :: Types.Object_Group;
    --[=[
        @prop Name string
        @within Group
        @tag object-prop

        This is a property stores the name of the [Group].
    ]=]
    self.Name = name;

    --[=[
        @prop _Prefix string
        @within Group
        @private
        @tag object-prop

        This is a internal property that stores the prefix of this [Group].
    ]=]
    self._Prefix = "";

    --[=[
        @prop _Inheritant Group?
        @within Group
        @private
        @tag object-prop

        This is a internal property that stores the inherited group if there is one.
    ]=]
    if inheritant then self._Inheritant = inheritant::Group; end

    --[=[
        @prop _Permissions {string}
        @within Group
        @private
        @tag object-prop

        This is a internal property that stores the permission nodes of this [Group].
    ]=]
    self._Permissions = {};
    if permissions then
        for index: number,permission: string in ipairs(permissions) do
            if permission:match("%-?%w+%.%w+%.?%w*") then
                self._Permissions[index] = permission;
            end
        end
    end

    --[=[
        @prop _Precedence number
        @within Group
        @private
        @tag object-prop

        This is a internal property that stores the order of precedence of this [Group].

        :::note

        >The [Group._Precendence] can be -1 which will ignore it from being queried in [Permissions.FindHighestGroupPrecedence]

        :::
    ]=]
    self._Precedence = -1;
    return setmetatable(self,Group) :: Group;
end

--[=[
    @method SetInheritant
    @within Group
    @param inheritant Group -- The group that will be inherited
    @return Group -- The group object is returned for chaining
    @tag chainable

    This method will set this [Group._Inheritant] to the target [Group] and will inherit that groups permissions.
]=]
function Group.SetInheritant(self: Group,inheritant: Group) : Group
    self._Inheritant = inheritant;
    return self;
end

--[=[
    @method SetPrecedence
    @within Group
    @param precedence number
    @return Group -- The group object is returned for chaining
    @tag chainable

    This method will set the [Group._Precedence] property.
]=]
function Group.SetPrecedence(self: Group,precedence: number) : Group
    self._Precedence = precedence;
    return self;
end

--[=[
    @method SetPrefix
    @within Group
    @param prefix string
    @return Group -- The group object is returned for chaining
    @tag chainable

    This method will set the [Group._Prefix] property.
]=]
function Group.SetPrefix(self: Group,prefix: string) : Group
    self._Prefix = prefix;
    return self;
end

local function isNodeNegated(node: string) : boolean
    return (node:match("%s*%-.+") and true) or false;
end

--[=[
    @method GrantPermission
    @within Group
    @param permission string

    This method grants a permission node to the [Group].
]=]
function Group.GrantPermission(self: Group,permission: string)
    -- Checks if the permission is a permission node
    permission = permission:match("%-?%w+%.%w+%.?%w*");
    if not permission then return; end
    -- Revoke negated permission nodes if you are trying to grant that permission
    if not isNodeNegated(permission) then Group.RevokePermission(self,"-"..permission); end
    if table.find(self._Permissions,permission) then return; end
    table.insert(self._Permissions,permission);
end

--[=[
    @method RevokePermission
    @within Group
    @param permission string

    This method revokes a permission node from the [Group].
]=]
function Group.RevokePermission(self: Group,permission: string)
    local foundIndex: number? = table.find(self._Permissions,permission);
    if foundIndex then table.remove(self._Permissions,foundIndex); end
end

--[=[
    @method HasPermission
    @within Group
    @param permission string -- The permission node that will be queried
    @return boolean

    This method checks if this [Group] has a specific permission node.
    Negated permission nodes take priority, and when present in
    the Group's permissions, this function will return false.
]=]
function Group.HasPermission(self: Group,permission: string) : boolean
    -- Check if the queried permission is negated
    local isQueryNegated: boolean = isNodeNegated(permission);
    if not isQueryNegated then
        -- Group has no permission if a negated permission is found
        if table.find(self._Permissions,"-"..permission) then return false; end
    end
    local permIndex: number? = table.find(self._Permissions,permission);
    if not permIndex then
        -- If group has an asterisk then the group contains all permissions
        if table.find(self._Permissions,"*") then return true; end
        -- Check in the inheritant group
        if self._Inheritant then return self._Inheritant:HasPermission(permission); end
    end
    return permIndex and true or false;
end

return Group;