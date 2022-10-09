-- This is an example config

local Permissions = require(game.ServerScriptService:FindFirstChild("Permissions"));
local Group = Permissions.Group;

local RegularGroup = Group.new("Regular",{
    "example.permission",
    "example2.permission",
    "example3.permission"
});

return {
    Groups = {
        RegularGroup,
        Group.new("Owner",{
            "Permissions.Test"
        })
    },
    Users = {
        ["31381261"] = {
            Permissions = {},
            Groups = {
                "Owner"
            }
        }
    },
    DefaultGroup = RegularGroup
};