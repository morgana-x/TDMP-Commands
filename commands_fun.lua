#include "tdmp/hooks.lua"
#include "tdmp/player.lua"
#include "tdmp/networking.lua"
#include "tdmp/utilities.lua"
#include "tdmp/chat.lua"
#include "tdmp/json.lua"

Hook_AddListener("TDMP_ChatAdminInit", "TDMP_ChatAdminInitCommand_FunStuff", function()
    
    local function spawn(t, path)
        local data = {t, path} 
        TDMP_ServerStartEvent("Spawn", {
			Receiver = TDMP.Enums.Receiver.All, -- We've received that event already so we need to broadcast it only to clients, not again to ourself
			Reliable = true,

			DontPack = false,
			Data = data
		})
    end
    TDMP_AddCommand("car", "superadmin", function(pl, args)
        local target = TDMP_GetTarget(pl, args[1])
        if not target then return end
        local t = TDMP_GetPlayerCameraTransform(target.id) --GetCameraTransform()
		t.pos = VecAdd(t.pos, TransformToParentVec(t, Vec(0, 0, -5)))
        spawn(t, "builtin-vehiclepack:assets/vehicle/car/taskmaster-4wd.xml")
        
        TDMP_BroadcastChatMessage(TDMP_GetPlayerColorSafe(pl), TDMP_SimplifyPlayer(pl), {1,1,1}, " spawned ", TDMP_GetPlayerColorSafe(target), TDMP_SimplifyPlayer(target),  {1,1,1}, " a really sick car!")
    end)

    TDMP_AddCommand("tank", "superadmin", function(pl, args)
        local target = TDMP_GetTarget(pl, args[1])
        if not target then return end
        local t = TDMP_GetPlayerCameraTransform(target.id) --GetCameraTransform()
		t.pos = VecAdd(t.pos, TransformToParentVec(t, Vec(0, 0, -5)))
        spawn(t, "builtin-vehiclepack:assets/vehicle/military/mil-tank.xml")
        
        TDMP_BroadcastChatMessage(TDMP_GetPlayerColorSafe(pl), TDMP_SimplifyPlayer(pl), {1,1,1}, " spawned ", TDMP_GetPlayerColorSafe(target), TDMP_SimplifyPlayer(target),  {1,1,1}, " a really sick tank!")
    end)
    TDMP_AddCommand("explosives", "superadmin", function(pl, args)
        local target = TDMP_GetTarget(pl, args[1])
        if not target then return end
        local radius = 5;

   
        for angle =0, 360, 10 do
            local x = math.cos(angle) * radius;
            local y = math.sin(angle) * radius;
            for i=1, 5 do
                local t = TDMP_GetPlayerCameraTransform(target.id) 
                t.pos = VecAdd(t.pos, TransformToParentVec(t, Vec(x, 0,y)))
                spawn(t,"builtin-proppack:prop/explosive/propanecanister.xml" )
            end
        end

        TDMP_BroadcastChatMessage(TDMP_GetPlayerColorSafe(pl), TDMP_SimplifyPlayer(pl), {1,1,1}, " spawned ", TDMP_GetPlayerColorSafe(target), TDMP_SimplifyPlayer(target),  {1,1,1}, " a bunch of explosives!")
    end)
end)