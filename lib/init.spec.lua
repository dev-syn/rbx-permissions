return function()
    local PermissionsModule: ModuleScript = script.Parent;
    --- @module lib/Types
    local Types = require(PermissionsModule:FindFirstChild("Types"));
    local Permissions: Types.Permissions = require(PermissionsModule);

    beforeAll(function(context)
        local Group: Types.Schema_Group = Permissions.Group;
        local defaultGroup: Types.Group = Group.new("Default");
        context.Config = {
            Groups = {
                Group.new("TestGroup",{
                    "permissions.test"
                }),
                defaultGroup;
            },
            Users = {
                ["31381261"] = {
                    Groups = {
                        "TestGroup"
                    }
                }
            },
            DefaultGroup = defaultGroup
        };
        Permissions.Init(context.Config);
        context.Player = game.Players:GetPlayers()[1] or game.Players.PlayerAdded:Wait();
        repeat task.wait(0.15); until Permissions._UserPermissions[context.Player] ~= nil;
    end);

    it("Should have permission for node permissions.test",function(context)
        expect(Permissions.HasPermission(context.Player,"permissions.test")).to.be.equal(true);
    end);
    it("Shouldn't have permission for node permissions.invalid",function(context)
        expect(Permissions.HasPermission(context.Player,"permissions.invalid")).to.be.equal(false);
    end);
    it("Should be able to see default group in user",function(context)
        local DefaultGroup: Types.Group = context.DefaultGroup;
        if DefaultGroup then expect(Permissions.IsUserInGroup(context.Player,DefaultGroup)).to.be.equal(true); end
    end);
    it("Should be able to see TestGroup in user",function(context)
        local TestGroup: Types.Group = Permissions.FindGroup("TestGroup");
        if TestGroup then expect(Permissions.IsUserInGroup(context.Player,TestGroup)).to.be.equal(true); end
    end);
end