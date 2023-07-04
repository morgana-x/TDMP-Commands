#include "tdmp/hooks.lua"
#include "tdmp/player.lua"
#include "tdmp/networking.lua"
#include "tdmp/utilities.lua"
#include "tdmp/chat.lua"
#include "tdmp/json.lua"


local bannedPlayers = {}
local mutedPlayers = {}
Hook_AddListener("TDMP_ChatAdminInit", "TDMP_ChatAdminInitCommand_Moderation", function()

    
    TDMP_AddCommand("kick", "moderator", function(pl, args)
        if not TDMP_KickPlayer then TDMP_SendChatMessageToPlayer(pl.steamId, {1,0,0}, "No kick function yet, wait for new TDMP update!") return end
        local target = TDMP_GetTarget(pl, args[1])
        if not target then return end

        local reason = table.concat(args, ' ', 2)
        if reason == "" then reason = "No reason" end

      

        TDMP_KickPlayer(target.steamId)

        TDMP_BroadcastChatMessage(TDMP_GetPlayerColorSafe(target), TDMP_SimplifyPlayer(target), {1,1,1}, "  was kicked by ", TDMP_GetPlayerColorSafe(pl), TDMP_SimplifyPlayer(pl), {1,1,1}, ". Reason: ", {1,0.2,0}, reason) 
    end)

    TDMP_AddCommand("ban", "admin",function(pl, args)
        if not TDMP_KickPlayer then TDMP_SendChatMessageToPlayer(pl.steamId, {1,0,0}, "No kick function yet, wait for new TDMP update!") return end
        local target = TDMP_GetTarget(pl, args[1])
        if not target then return end

        local reason = table.concat(args, ' ', 2)
        if reason == "" then reason = "No reason" end

        bannedPlayers[target.steamId] = true
        TDMP_KickPlayer(target.steamId)

        TDMP_BroadcastChatMessage(TDMP_GetPlayerColorSafe(target),  TDMP_SimplifyPlayer(target), {1,1,1}, "  was banned by ", TDMP_GetPlayerColorSafe(pl),  TDMP_SimplifyPlayer(pl), {1,1,1}, ". Reason: ", {1,0.2,0}, reason) 
    end)

    TDMP_AddCommand("mute", "moderator", function(pl, args)
        
        local target = TDMP_GetTarget(pl, args[1])
        if not target then return end

        mutedPlayers[target.steamId] = not mutedPlayers[target.steamId]
        TDMP_BroadcastChatMessage(TDMP_GetPlayerColorSafe(target), TDMP_SimplifyPlayer(target), {1,1,1}, "  was " .. ((mutedPlayers[target.steamId] and "muted") or "unmuted") .. " by ", TDMP_GetPlayerColorSafe(pl),  TDMP_SimplifyPlayer(pl), {1,1,1}, ".") -- Reason: ", {1,0.2,0}, reason) 
    end)

      
    Hook_AddListener("PlayerConnected", "TDMP_Commands_BanNono", function(steamId)
        if bannedPlayers[steamId] then TDMP_KickPlayer(steamId) end
    end)
    Hook_AddListener("TDMP_ChatSuppressMessage", "TDMP_Chat_muted", function(msgData)
        msgData = json.decode(msgData)
        if mutedPlayers[msgData[2]] then return "" end
    end)
end)