#include "tdmp/hooks.lua"
#include "tdmp/player.lua"
#include "tdmp/networking.lua"
#include "tdmp/utilities.lua"
#include "tdmp/chat.lua"
#include "tdmp/json.lua"


Hook_AddListener("TDMP_ChatAdminInit", "TDMP_ChatAdminInitCommand", function()



 
    TDMP_AddCommand("help", "user", function(pl, args)
        TDMP_SendChatMessageToPlayer(pl.steamId, {0,1,0}, "Here is a list of commands!" )
        for name, cmd in pairs(TDMP_Commands) do
            local col = {0.2,0.5,1} 
            if not TDMP_CanUseCommand(pl.steamId, cmd) then col =  {1,0.2,0.2} end
            TDMP_SendChatMessageToPlayer(pl.steamId, col ,name .."  ", {1,1,0}, "(" .. cmd.rank .. ")" )
        end
    end)

 




    TDMP_AddCommand("goto", "moderator", function(pl,args)
        local target = TDMP_GetTarget_AllowSameRank(pl, args[1]) -- Allow same ranks to target each other version
        if not target then return end
        local pos = TDMP_GetPlayerTransform(target).pos
        TDMP_SetPlayerPosition(pl, pos)
        TDMP_BroadcastChatMessage(TDMP_GetPlayerColorSafe(pl), TDMP_SimplifyPlayer(pl), {1,1,1}, "  went to ", TDMP_GetPlayerColorSafe(target), TDMP_SimplifyPlayer(target), {1,1,1}, ".") 
    end)

    
    TDMP_AddCommand("bring", "moderator", function(pl,args)
        local target = TDMP_GetTarget_AllowSameRank(pl, args[1])-- Allow same ranks to target each other version
        if not target then return end
        local pos = TDMP_GetPlayerTransform(pl).pos
        TDMP_SetPlayerPosition(target, pos)
        TDMP_BroadcastChatMessage(TDMP_GetPlayerColorSafe(pl), TDMP_SimplifyPlayer(pl), {1,1,1}, "  brought ", TDMP_GetPlayerColorSafe(target), TDMP_SimplifyPlayer(target), {1,1,1}, ".") 
    end)



    TDMP_AddCommand("explode", "superadmin", function(pl, args)
        local target = TDMP_GetTarget_AllowSameRank(pl, args[1])-- Allow same ranks to target each other version, wait this one might be a mistake D:
        if not target then return end
        for i=1, 2 do
            local t = TDMP_GetPlayerTransform(target.id)
            TDMP_ClientStartEvent("RocketShot", {
                Reliable = true,
                Data = {t.pos, Vec(0,0,0), 5}
            })
        end
        TDMP_BroadcastChatMessage(TDMP_GetPlayerColorSafe(pl), TDMP_SimplifyPlayer(pl), {1,1,1}, "  exploded ", TDMP_GetPlayerColorSafe(target), TDMP_SimplifyPlayer(target), {1,1,1}, ".") 

    end)
end)

