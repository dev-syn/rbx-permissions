--[=[
    @class Config

    This class was designed to implement permissions & groups that get assigned to users used to restrict certain features across your game.

    ## Configuration Example
    ```lua
    local Permissions = require(PermissionsModule);
    type Group = Permissions.Group;

    -- The Group class
    local Group: Permissions.Schema_Group = Permissions.Group;

    -- Any groups we will reuse in the Config we will need to store in a variable
    local defaultGroup: Group = Group.new("Default",{"example.default"});
    local example1: Group = Group.new("Example1","example.permission1");

    return {
        Groups = {
            defaultGroup -- The default group also must still be added

            -- "Example 1" would contain permission nodes example.permission1
            example1,

            -- "Example 2" would inherit example1 permission nodes & example.permission2
            Group.new("Example2","example.permission2",example1),

            -- "Example 3" would have the highest precedence a group could have
            -- "Example 3" would have the inherited example.permission1 permission node
            Group.new("Example3"):SetPrecedence(0):SetInheritant(example1),

            -- This will be used for later
            Group.new("Developer","example.superpermission",defaultGroup),
        },
        Users = {
            ["Player.UserId"] = {
            --[[
                You can place permission nodes inside Permissions to
                automatically assign those permissions to that user.
            --]]
                Permissions = {"example.only_I_have_this_permission"},

            --[[
                You can place group names inside of Groups to have
                the user automatically be assigned to those Groups.

                This user would automatically be in the "Example 2" group
            --]]
                Groups = {"Example2"}
            },
            ["ownerid"] = {
                -- Optionally grant this specific user all permissions
                Permissions = {"*"},

                -- Assign this user to the Developer group we made earlier
                Groups = {"Developer"}
            }
        },
        DefaultGroup = defaultGroup
    }
    ```

    :::note

    >You still have to add the Default Group to the [Config.Groups] table.

    :::
]=]

--[=[
    @prop Groups {Group}
    @within Config

    This is an array of [Group] objects that represent all the groups that [Permissions] should be aware of.
]=]

--[=[
    @interface UserPresetData
    @within Config
    .Permissions {string} -- A array of permission nodes
    .Groups {string} -- An array of group names to be assigned to the user

    The UserPresetData is a table that contains permission nodes and [Group] names that will be assigned to the user.
]=]

--[=[
    @prop Users Dictionary<UserPresetData>
    @within Config

    A dictionary that which contains [Player.UserId] as the keys and [Permissions.UserPresetData] as the values.
]=]

--[=[
    @prop DefaultGroup Group
    @within Config

    The default group is a [Group] that is automatically assigned to joining users.
]=]

--- @module Permissions/lib/Types
local Types = require(script:FindFirstChild("Types"));

type Dictionary<T> = Types.Dictionary<T>;

export type Schema_Group = Types.Schema_Group;
export type Group = Types.Group;
export type Permissions = Types.Permissions;

--[=[
    @class Permissions
    This class was designed to track permissions for a user or a group for granting access to certain commands and features inside your game.

    # Definitions
    - "&lt;example&gt;": Any text within `< >` is a mandatory placeholder.
    - "&lt;?: example &gt;": Any text within `<?: >` is a optional placeholder and is not required to be used.
    - "permission node": This is a string which contains a `<category>.<permission>.<?: subperm>` format.

    :::note

    >The Permissions module is recommended to be placed in [ServerScriptService].

    :::
]=]
local Permissions = {} :: Permissions;

--- @module lib/Group
local Group: Types.Schema_Group = require(script:FindFirstChild("Group"));
--[=[
    @prop Group Schema_Group
    @within Permissions
    @tag reference

    This property stores a reference to the [Group] class.
]=]
Permissions.Group = Group;

--[=[
    @prop _UserPermissions Map<Player,{string}>
    @within Permissions
    @private

    This internal property contains the individual user permissions.
]=]
Permissions._UserPermissions = {};

--[=[
    @prop _UserGroups Map<Player,{Group}>
    @within Permissions
    @private

    This internal property contains the individual user groups.
]=]
Permissions._UserGroups = {};

--[=[
    @prop _Groups Dictionary<Group>
    @within Permissions
    @private

    This internal property stores a Dictionary of [Group] names & objects that [Permissions] is aware of.
]=]
Permissions._Groups = {};

local function loadPresetUserData(presetUsers: Dictionary<Types.PresetUserData>,plr: Player)
    local presetUserData: Types.PresetUserData? = presetUsers[tostring(plr.UserId)];
    if presetUserData then
        -- Load preset player permissions
        local presetPermissions: {string}? = presetUserData.Permissions;
        if presetPermissions then
            for _,permission: string in ipairs(presetPermissions) do
                Permissions.GrantPermission(plr,permission);
            end
        end
        -- Load preset player groups if they exist
        local presetGroupNames: {string}? = presetUserData.Groups;
        if presetGroupNames then
            for _,groupName: string in ipairs(presetGroupNames) do
                local group: Group? = Permissions.FindGroup(groupName);
                if group then Permissions.SetUserGroup(plr,group::Group); end
            end
        end
    end
end

local PermissionsConfig: Types.Config? = nil;
local lastDefaultGroup: Group? = nil;

local function initUser(plr: Player)
    if not Permissions._UserPermissions[plr] then
        Permissions._UserPermissions[plr] = {};
    end
    if not Permissions._UserGroups[plr] then
        Permissions._UserGroups[plr] = {};
    end
    if PermissionsConfig then
        local presetUsers: Dictionary<Types.PresetUserData> = PermissionsConfig.Users;
        if presetUsers then
            loadPresetUserData(presetUsers,plr)
        end
        -- Add player to default group if not already in it
        local defaultGroup = PermissionsConfig.DefaultGroup;
        if lastDefaultGroup then
            if not (lastDefaultGroup == defaultGroup) then
                Permissions.RemoveUserGroup(plr,lastDefaultGroup);
                Permissions.SetUserGroup(plr,defaultGroup::Group);
            end
        else
            Permissions.SetUserGroup(plr,defaultGroup::Group);
        end
    end
end

--[=[
    @within Permissions

    This function loads the passed [config](/api/Config) loading the preset user data (groups,permissions)
    to the preset users and setting the default group to the users.
]=]
function Permissions.LoadConfig(config: Types.Config)
    -- Add the created groups from the config
    local presetGroups = config.Groups;
    if presetGroups then
        for _,group in ipairs(presetGroups) do
            -- If a group with this name doesn't already exist add the group
            if not Permissions._Groups[group.Name] then Permissions._Groups[group.Name] = group; end
        end
    end
    local defaultGroup: Group? = config.DefaultGroup;
    local presetUsers: Dictionary<Types.PresetUserData> = config.Users;
    -- Load player permissions & groups
    if presetUsers then
        for _,plr: Player in ipairs(game.Players:GetPlayers()) do
            loadPresetUserData(presetUsers,plr);
            if defaultGroup then
                -- Set the players default group
                if lastDefaultGroup then
                    if not (lastDefaultGroup == defaultGroup) then
                        Permissions.RemoveUserGroup(plr,lastDefaultGroup);
                        Permissions.SetUserGroup(plr,defaultGroup::Group);
                    end
                else
                    Permissions.SetUserGroup(plr,defaultGroup::Group);
                end
                lastDefaultGroup = defaultGroup;
            end
        end
    else
        -- If no preset users then just set the default groups for the players
        for _,plr: Player in ipairs(game.Players:GetPlayers()) do
            if defaultGroup then
                -- Set the players default group
                if lastDefaultGroup then
                    if not (lastDefaultGroup == defaultGroup) then
                        Permissions.RemoveUserGroup(plr,lastDefaultGroup);
                        Permissions.SetUserGroup(plr,defaultGroup::Group);
                    end
                else
                    Permissions.SetUserGroup(plr,defaultGroup::Group);
                end
                lastDefaultGroup = defaultGroup;
            end
        end
    end
    PermissionsConfig = config;
end

local isInitialized: boolean = false;
--[=[
    @within Permissions
    @param permissionsConfig Config? -- The config used for setting up and storing the preset permissions & groups

    This function initializes [Permissions] and the preset user permissions & groups.

    :::danger

    >Failure to call this function before using other functions will result in [Permissions] being broken.

    :::
]=]
function Permissions.Init(permissionsConfig: Types.Config?) : Permissions
    if isInitialized then return Permissions; end

    if permissionsConfig then
        Permissions.LoadConfig(permissionsConfig);
    end
    game.Players.PlayerRemoving:Connect(function(plr: Player)
        if Permissions._UserPermissions[plr] then Permissions._UserPermissions[plr] = nil; end
        if Permissions._UserGroups[plr] then Permissions._UserGroups[plr] = nil; end
    end);
    game.Players.PlayerAdded:Connect(function(plr: Player)
        initUser(plr);
    end);
    for _,plr: Player in ipairs(game.Players:GetPlayers()) do
        initUser(plr);
    end
    isInitialized = true;
    return Permissions;
end

--[=[
    @within Permissions
    @param name string -- The name of the group to query.
    @return Group? -- The group that was found or nil if no group was found.

    This function is used to find a [Group] object by it's name.
]=]
function Permissions.FindGroup(name: string) : Group?
    return Permissions._Groups[name] or nil;
end

--[=[
    @within Permissions

    This method is for querying the user groups for the highest
    precedence returning that group.
]=]
function Permissions.FindHighestGroupPrecedence(plr: Player) : Group?
    local userGroups: {Group} = Permissions._UserGroups[plr];
    local lowestPrecedence: number?,highestGroup: Group = nil,nil;
    for _,group: Group in ipairs(userGroups) do
        if group._Precedence == -1 then continue; end

        if not lowestPrecedence then
            lowestPrecedence = group._Precedence;
            highestGroup = group;
        elseif group._Precedence < lowestPrecedence then
            lowestPrecedence = group._Precedence;
            highestGroup = group;
        end
    end
    return highestGroup;
end

--[=[
    @within Permissions

    This method is for checking if a user is in a specific group returning true if they are otherwise false
]=]
function Permissions.IsUserInGroup(plr: Player,group: Group) : boolean
    return table.find(Permissions._UserGroups[plr],group) and true or false;
end

--[=[
    @within Permissions
    @param plr Player
    @param group Group

    This function is used to set a group to a user.
]=]
function Permissions.SetUserGroup(plr: Player,group: Group)
    local userGroups: {Group} = Permissions._UserGroups[plr];

    -- Check if player is already has that group
    if table.find(userGroups,group) then return; end

    table.insert(userGroups,group);
end

--[=[
    @within Permissions
    @param plr Player
    @param group Group

    This function is used to remove a group from a user.
]=]
function Permissions.RemoveUserGroup(plr: Player,group: Group)
    local userGroups: {Group} = Permissions._UserGroups[plr];
    -- Remove group from user if it exists
    local groupIndex: number? = table.find(userGroups,group);
    if groupIndex then table.remove(userGroups,groupIndex); end
end

local function isNodeNegated(node: string) : boolean
    return (node:match("%s*%-.+") and true) or false;
end

--[=[
    @within Permissions
    @param plr Player
    @param permission string

    This functions grants a user a permission node.

    :::note

    If you grant a user a permission node and that user had a negated permission node it will revoke the negated permission.

    :::
]=]
function Permissions.GrantPermission(plr: Player,permission: string)
    -- Checks if the permission is a permission node
    permission = permission:match("%-?%w+%.%w+%.?%w*");
    if not permission then return; end
    local userPermissions: {string} = Permissions._UserPermissions[plr];
    -- Revoke negated permission nodes if you are trying to grant that permission
    if not isNodeNegated(permission) then Permissions.RevokePermission(plr,"-"..permission); end
    if not table.find(userPermissions,permission) then table.insert(userPermissions,permission); end
end

--[=[
    @within Permissions
    @param plr Player
    @param permission string

    This functions revokes a user from a permission node.
]=]
function Permissions.RevokePermission(plr: Player,permission: string)
    local userPermissions: {string} = Permissions._UserPermissions[plr];
    if userPermissions then
        local permIndex: number? = table.find(userPermissions,permission);
        if permIndex then table.remove(userPermissions,permIndex); end
    end
end

--[=[
    @within Permissions
    @param plr Player
    @param permission string
    @return boolean

    This function checks if a user has a specific permission node.
    Negated permission nodes take priority, and when present in
    the user's permissions, this function will return false.
]=]
function Permissions.HasPermission(plr: Player,permission: string) : boolean
    local userPermissions = Permissions._UserPermissions[plr];
    -- Check if the queried permission is negated
    local isQueryNegated: boolean = isNodeNegated(permission);
    if not isQueryNegated then
        -- User has no permission if a negated permission is found
        if table.find(userPermissions,"-"..permission) then return false; end
    end
    -- Check if user has the permission
    local userPermIndex: number? = table.find(userPermissions,permission);
    if not userPermIndex then
        -- If user has an asterisk then user contains all permissions (only applies on non-negated permissions)
        if not isQueryNegated and table.find(userPermissions,"*") then return true; end
        -- Check if the users groups has the permission
        for _,group: any in ipairs(Permissions._UserGroups[plr]) do
            if group:HasPermission(permission) then return true; end
        end
        return false;
    end
    return true;
end

return Permissions;