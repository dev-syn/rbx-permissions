local Config = script:FindFirstChild("PermissionsConfig");

local PermissionsModule: ModuleScript? = game.ServerScriptService:FindFirstChild("Permissions") :: ModuleScript?;
if PermissionsModule then
    local Dependencies: Folder = PermissionsModule:FindFirstChild("Dependencies") :: Folder;
    if Dependencies then
        local TestEZ = require(Dependencies:FindFirstChild("TestEZ"));
        TestEZ.TestBootstrap:run({PermissionsModule});
    end
end
