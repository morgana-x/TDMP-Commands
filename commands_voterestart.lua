#include "tdmp/hooks.lua"
#include "tdmp/player.lua"
#include "tdmp/networking.lua"
#include "tdmp/utilities.lua"
#include "tdmp/chat.lua"
#include "tdmp/json.lua"

Hook_AddListener("TDMP_ChatAdminInit", "TDMP_ChatAdminInitCommand_VoteRestart", function()
        local votedPlayers = {}
        local votesForRestart = 0
    
        Hook_AddListener("PlayerDisconnected", "tdmp_commands_votedc_restart", function(steam)
            if votedPlayers[steam] then
                votesForRestart = votesForRestart - 1
                votedPlayers[steam] = nil
            end
        end)
        TDMP_AddCommand("voterestart", "user", function(pl, args)
            if votedPlayers[pl.steamId] then TDMP_SendChatMessageToPlayer(pl.steamId, {1,0,0}, "|", {1,1,1}, " You have already voted!") return end
            votedPlayers[pl.steamId] = true
            votesForRestart = votesForRestart + 1
            TDMP_BroadcastChatMessage({1,0.5,0.2}, TDMP_SimplifyPlayer(pl), {1,1,1}, "  has voted for to restart the game.", {1,0.5,0.2}, "(" .. tostring(votesForRestart) .. "/" .. tostring(#TDMP_GetPlayers()) .. ")" )
            if votesForRestart >= #TDMP_GetPlayers() / 2 then
                TDMP_BroadcastChatMessage({1,0.5,0.2}, "Restart vote succesful, restart commencing soon." )
                TDMP_ServerStartEvent("Restart", {
                    Receiver = TDMP.Enums.Receiver.All,
                    Reliable = true,
                    DontPack = true,
                    Data = ""
                })
                Restart()
            end
        end)
end)