--[=[
    @class Config
    This ModuleScript is where you can preset the groups used by permissions and preset users to have specific permissions and groups assigned to them. The ModuleScript must return a table with any of the properties displayed on this page.
]=]

--[=[
    @prop Groups {Group}
    @within Config
    Place Group objects in this table to allow group assigning to users.
]=]

--[=[
    @interface UserPresetData
    @within Config
    .Permissions {string} -- A array of permission nodes
    .Groups {string} -- An array of group names to be assigned to the user
    The UserPresetData which will contain permission nodes and groups to be assigned to the user.
]=]

--[=[
    @prop Users Dictionary<UserPresetData>
    @within Config
    A dictionary that contains Player.UserId in string format as the key and UserPresetData as it's value.
]=]

--[=[
    @prop DefaultGroup Group
    @within Config
    The default group that will be assigned automatically to joining users.
]=]

--- @module lib/Types
local Types = require(script:FindFirstChild("Types"));
export type Dictionary<T> = Types.Dictionary<T>;
export type Group = Types.Group;
export type Permissions = Types.Permissions;

--- @module lib/Group
local Group: Types.Schema_Group = require(script:FindFirstChild("Group"));

--[=[
    @class Permissions
    This class was designed to track permissions for a user or a group for granting access to certain commands and features inside your game.
]=]
local Permissions = {} :: Permissions;

--[=[
    @prop Group Schema_Group
    @within Permissions
    This property contains the Group class
]=]
Permissions.Group = Group;

-- Map<Player,Group>
--[=[
    @prop _UserPermissions Map<Player,Group>
    @within Permissions
    @private
    This internal property contains the individual user permissions.
]=]
Permissions._UserPermissions = {};

-- Map<Player,Group>
--[=[
    @prop _UserGroups Map<Player,Group>
    @within Permissions
    @private
    This internal property contains the individual user groups.
]=]
Permissions._UserGroups = {};

-- Dictionary<Group>
--[=[
    @prop _Groups Dictionary<Group>
    @within Permissions
    @private
    This internal property contains the Permissions reference to the groups
]=]
Permissions._Groups = {};

local PermissionsConfig;
local function initUser(plr: Player)
    if not Permissions._UserPermissions[plr] then
        Permissions._UserPermissions[plr] = {};
    end
    if not Permissions._UserGroups[plr] then
        Permissions._UserGroups[plr] = {};

        -- TODO: Add player to default group
        local defaultGroup = PermissionsConfig.DefaultGroup;
        if defaultGroup then
            Permissions.SetUserGroup(plr,defaultGroup);
        end
        -- Iterate through preset user data
        if PermissionsConfig and PermissionsConfig.Users then
            local presetUserData = PermissionsConfig.Users[tostring(plr.UserId)];
            if typeof(presetUserData) == "table" then

                -- Add preset user permissions
                local presetPermissions = presetUserData.Permissions;
                if presetPermissions then
                    for _,permission: string in ipairs(presetPermissions) do
                        Permissions.GrantPermission(plr,permission);
                    end
                end
                -- Add preset groups to user
                local presetGroupNames: {string} = presetUserData.Groups;
                if presetGroupNames then
                    for _,groupName: string in ipairs(presetGroupNames) do
                        local group: Group = Permissions.FindGroup(groupName);
                        if group then Permissions.SetUserGroup(plr,group); end
                    end
                end
            end
        end
    end
end

local isInitialized: boolean = false;
--[=[
    @within Permissions
    @param permissionsConfig ModuleScript? -- The config used for setting up and storing the preset permissions & groups
    This method **Must** be called before using any other functions inside Permissions.
]=]
function Permissions.Init(permissionsConfig: Dictionary<any>?) : Permissions
    if isInitialized then return Permissions; end
    if permissionsConfig then PermissionsConfig = require(permissionsConfig); end

    if PermissionsConfig then
        -- Add the created groups from the config
        local presetGroups = PermissionsConfig.Groups;
        if presetGroups then
            for _,group in ipairs(presetGroups) do
                Permissions._Groups[group.Name] = group;
            end
        end
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
    @return Group -- The group that was found or nil if no group was found.
]=]
function Permissions.FindGroup(name: string) : Group
    return Permissions._Groups[name];
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
    This function is used to set a group to a user(player)
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
    This function is used to remove a group from a user(player).
]=]
function Permissions.RemoveUserGroup(plr: Player,group: Group)
    local userGroups: {Group} = Permissions._UserGroups[plr];
    -- Remove group from user if it exists
    local groupIndex: number? = table.find(userGroups,group);
    if groupIndex then table.remove(userGroups,groupIndex); end
end

--[=[
    @within Permissions
    @param plr Player
    @param permission string
    This functions grants a user a permission.
]=]
function Permissions.GrantPermission(plr: Player,permission: string)
    local userPermissions: {string} = Permissions._UserPermissions[plr];
    if not table.find(userPermissions,permission) then table.insert(userPermissions,permission); end
end

--[=[
    @within Permissions
    @param plr Player
    @param permission string
    This functions revokes a user from a permission.
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
    This function checks if a user has a specific permission node
]=]
function Permissions.HasPermission(plr: Player,permission: string) : boolean
    local userPermissions = Permissions._UserPermissions[plr];
    -- Check if user has the permission
    local userPermIndex: number? = table.find(userPermissions,permission);
    if not userPermIndex then
        -- If user has an asterisk then user contains all permissions
        if table.find(userPermissions,"*") then return true; end
        -- Check if the users groups has the permission
        for _,group: any in ipairs(Permissions._UserGroups[plr]) do
            if group:HasPermission(permission) then return true; end
        end
        return false;
    end
    return true;
end

return Permissions;