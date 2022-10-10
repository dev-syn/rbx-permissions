"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[264],{65658:e=>{e.exports=JSON.parse('{"functions":[{"name":"Init","desc":"This method **Must** be called before using any other functions inside Permissions.","params":[{"name":"permissionsConfig","desc":"The config used for setting up and storing the preset permissions & groups","lua_type":"Dictionary<any>?"}],"returns":[{"desc":"","lua_type":"Permissions\\r\\n"}],"function_type":"static","source":{"line":129,"path":"lib/init.lua"}},{"name":"FindGroup","desc":"","params":[{"name":"name","desc":"The name of the group to query.","lua_type":"string"}],"returns":[{"desc":"The group that was found or nil if no group was found.","lua_type":"Group"}],"function_type":"static","source":{"line":161,"path":"lib/init.lua"}},{"name":"IsUserInGroup","desc":"This method is for checking if a user is in a specific group returning true if they are otherwise false","params":[{"name":"plr","desc":"","lua_type":"Player"},{"name":"group","desc":"","lua_type":"Group"}],"returns":[{"desc":"","lua_type":"boolean\\r\\n"}],"function_type":"static","source":{"line":169,"path":"lib/init.lua"}},{"name":"SetUserGroup","desc":"This function is used to set a group to a user(player)","params":[{"name":"plr","desc":"","lua_type":"Player"},{"name":"group","desc":"","lua_type":"Group"}],"returns":[],"function_type":"static","source":{"line":179,"path":"lib/init.lua"}},{"name":"RemoveUserGroup","desc":"This function is used to remove a group from a user(player).","params":[{"name":"plr","desc":"","lua_type":"Player"},{"name":"group","desc":"","lua_type":"Group"}],"returns":[],"function_type":"static","source":{"line":194,"path":"lib/init.lua"}},{"name":"GrantPermission","desc":"This functions grants a user a permission node and will revoke the negated permission node if it exists.","params":[{"name":"plr","desc":"","lua_type":"Player"},{"name":"permission","desc":"","lua_type":"string"}],"returns":[],"function_type":"static","source":{"line":211,"path":"lib/init.lua"}},{"name":"RevokePermission","desc":"This functions revokes a user from a permission node.","params":[{"name":"plr","desc":"","lua_type":"Player"},{"name":"permission","desc":"","lua_type":"string"}],"returns":[],"function_type":"static","source":{"line":224,"path":"lib/init.lua"}},{"name":"HasPermission","desc":"This function checks if a user has a specific permission node, negated permission nodes take priority and when present in the users permissions it will return false.","params":[{"name":"plr","desc":"","lua_type":"Player"},{"name":"permission","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"boolean"}],"function_type":"static","source":{"line":239,"path":"lib/init.lua"}}],"properties":[{"name":"Group","desc":"This property contains the Group class","lua_type":"Schema_Group","source":{"line":56,"path":"lib/init.lua"}},{"name":"_UserPermissions","desc":"This internal property contains the individual user permissions.","lua_type":"Map<Player,{string}>","private":true,"source":{"line":65,"path":"lib/init.lua"}},{"name":"_UserGroups","desc":"This internal property contains the individual user groups.","lua_type":"Map<Player,Group>","private":true,"source":{"line":74,"path":"lib/init.lua"}},{"name":"_Groups","desc":"This internal property contains the Permissions reference to the groups","lua_type":"Dictionary<Group>","private":true,"source":{"line":83,"path":"lib/init.lua"}}],"types":[],"name":"Permissions","desc":"This class was designed to track permissions for a user or a group for granting access to certain commands and features inside your game.\\n# Definitions\\n- \\"&lt;example&gt;\\": Any text within &lt; &gt; is a mandatory placeholder\\n- \\"&lt; ?: example &gt;\\": Any text within &lt; ?: &gt; is a optional placeholder and is not required to be used\\n- \\"permission node\\": This is a string which contains a &lt;category&gt;.&lt;permission&gt;.&lt; ?: subperm&gt; format","source":{"line":49,"path":"lib/init.lua"}}')}}]);