#include "tdmp/hooks.lua"
#include "tdmp/player.lua"
#include "tdmp/networking.lua"
#include "tdmp/utilities.lua"
#include "tdmp/chat.lua"
#include "tdmp/json.lua"
Hook_AddListener("TDMP_ChatAdminInit", "TDMP_ChatAdminInitCommand_Ranks", function()
    
    TDMP_AddCommand("getrank", "user",function(pl, args)
        if not args[1] then TDMP_SendChatMessageToPlayer(pl.steamId, {0,1,0}, "Missing target!" ) return end 
        local target = TDMP_SearchPlayer(args[1]) -- find a target from the first argument, will handle all the rank permissions etc as well
        if not target then TDMP_SendChatMessageToPlayer(pl.steamId, {0,1,0}, "Couldn't find player \"" .. args[1] .. "\"" )return end

        local rank = TDMP_GetRank(target.steamId)
        if not rank then return end

        TDMP_SendChatMessageToPlayer(pl.steamId, {1,1,1}, TDMP_SimplifyPlayer(target), {1,1,1}, "'s rank is ", {1,0.5,0.2}, rank, {1,1,1}, ".")
    end)
    TDMP_AddCommand("setrank", "superadmin",function(pl, args)
        if not args[1] then TDMP_SendChatMessageToPlayer(pl.steamId, {0,1,0}, "Missing target!" ) return end 
        local target = TDMP_GetTarget(pl, args[1]) -- find a target from the first argument, will handle all the rank permissions etc as well

        if not args[2] then TDMP_SendChatMessageToPlayer(pl.steamId, {0,1,0}, "Missing rank!" )  return end
        args[2] = string.lower(args[2])
        local rank = TDMP_Ranks[args[2]]
        if not rank then TDMP_SendChatMessageToPlayer(pl.steamId, {0,1,0}, "Invalid rank \"" .. args[2] .. "\"!" )  return end


        TDMP_SetRank(target.steamId, args[2])
        TDMP_BroadcastChatMessage(TDMP_GetPlayerColorSafe(pl), TDMP_SimplifyPlayer(pl), {1,1,1}, "  set ", TDMP_GetPlayerColorSafe(target), TDMP_SimplifyPlayer(target), {1,1,1}, "'s rank to " , {1,0,0}, args[2], {1,1,1}, ".") 
    end)

    TDMP_AddCommand("listranks", "user", function(pl, args)
        TDMP_SendChatMessageToPlayer(pl.steamId, {0,1,0}, "List of ranks:" )
        for name, cmd in pairs(TDMP_Ranks) do
            TDMP_SendChatMessageToPlayer(pl.steamId, {1,0.2,0.2},name )
        end
    end)

end)

