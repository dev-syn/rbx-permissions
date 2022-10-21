local PermissionsModule: ModuleScript? = game.ServerScriptService:FindFirstChild("Permissions") :: ModuleScript?;
if PermissionsModule then
    local Dependencies: Folder = game.ReplicatedStorage:FindFirstChild("Dependencies");
    if Dependencies then
        local TestEZ = require(Dependencies:FindFirstChild("TestEZ"));
        TestEZ.TestBootstrap:run({PermissionsModule});
    end
end
