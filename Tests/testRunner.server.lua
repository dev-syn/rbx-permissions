local Config = script:FindFirstChild("PermissionsConfig");

local PermissionsModule: ModuleScript? = game.ServerScriptService:FindFirstChild("Permissions") :: ModuleScript?;
if PermissionsModule then
    --- @module lib/Types
    local Types = PermissionsModule:FindFirstChild("Types");
    local Permissions: Types.Permissions = require(PermissionsModule).Init(Config);
    local player = game.Players:GetPlayers()[1] or game.Players.PlayerAdded:Wait();
    task.spawn(function()
        repeat task.wait(0.15); until Permissions._UserPermissions[player] ~= nil;
        print("Has permission: ",Permissions.HasPermission(player,"Permissions.Test"));
        print(Permissions.HasPermission(player,"Permissions.shouldnt"))
    end);
end
