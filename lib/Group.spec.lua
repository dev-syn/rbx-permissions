return function()
    local PermissionsModule: ModuleScript = script.Parent;
    --- @module lib/Types
    local Types = require(PermissionsModule:FindFirstChild("Types"));
    type Group = Types.Group;
    local Permissions: Types.Permissions = require(PermissionsModule);
    local Group: Types.Schema_Group = Permissions.Group;

    local testGroup: Group;

    it("Should be able to create a group with example permission",function(context)
        local newGroup: Group = Group.new("TestGroup",{"permissions.example"});
        expect(newGroup).to.be.ok();
        testGroup = newGroup;
    end);
    it("Should be able to grant and confirm test permission",function(context)
        if testGroup then
            testGroup:GrantPermission("permissions.test");
            expect(testGroup:HasPermission("permissions.test")).to.be.equal(true);
        end
    end);
    it("Should be able to set TestGroup to user",function(context)
        if testGroup then
            Permissions.SetUserGroup(context.Player,testGroup);
            expect(Permissions.IsUserInGroup(context.Player,testGroup)).to.be.equal(true);
        end
    end);
    it("Should be able to inherit another groups permissions",function(context)
        if testGroup then
            local inheritedGroup: Group = Group.new("InheritedGroup",{"permissions.inherited"});
            testGroup:SetInheritant(inheritedGroup);
            expect(Permissions.HasPermission(context.Player,"permissions.inherited")).to.be.equal(true);
        end
    end);
end