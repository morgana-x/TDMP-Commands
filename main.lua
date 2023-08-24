#include "tdmp/hooks.lua"
#include "tdmp/player.lua"
#include "tdmp/networking.lua"
#include "tdmp/utilities.lua"
#include "tdmp/chat.lua"
#include "tdmp/json.lua"
#include "cfg.lua"
#include "commands.lua" -- Help, goto, bring
#include "commands_ranks.lua" -- setrank, getrank, ranks
#include "commands_moderation.lua" -- mute, kick, ban
#include "commands_voterestart.lua" -- voterestart

--[[ 
    ///////////// DISABLED MODULES DUE TO TECHNICAL ISSUES MAKING THEM IMPOSSIBLE /////////////
                            (ATLEAST FOR A MOSTLY SERVERSIDE ONLY SETUP)
    #include "commands_playermodel.lua"
    #include "commands_votemap.lua"

    ///////////////////////////////////////////////////////////////////////////////////////////
]]

#include "ranks.lua"



TDMP_Commands = {}
TDMP_Ranks = {}
local debug = false
local function string_startwith(text, prefix)
    return text:find(prefix, 1, true) == 1
end

local function string_split(text)
    local chnks = {}
    for w in text:gmatch("%S+") do table.insert(chnks, w) end
    return chnks
end

function TDMP_SearchPlayer(name)
    local found = nil
    name = string.lower(name)
    for _, pl in ipairs(TDMP_GetPlayers()) do
        local p_nick = string.lower(pl.nick)
        if p_nick == name then found = pl; break end
        if string_startwith(p_nick,name) then found = pl; break end
        if string_startwith(name,p_nick) then found = pl; break end
    end
    return found
end

function TDMP_GetTarget(pl, search) -- does all checks as well
    if not search then TDMP_SendChatMessageToPlayer(pl.steamId, {1,0.2,0.2}, "Missing target!" )  return false end
    local target = TDMP_SearchPlayer(search)
    if not target then TDMP_SendChatMessageToPlayer(pl.steamId, {1,0.2,0.2}, "Couldn't find player \"" .. search .. "\"!" )  return false end
    if not TDMP_CanTarget(pl.steamId, target.steamId) then TDMP_SendChatMessageToPlayer(pl.steamId, {1,0.2,0.2}, "You cannot target this player!" ) return false end
    return target
end

function TDMP_GetTarget_AllowSameRank(pl, search) -- does all checks as well
    if not search then TDMP_SendChatMessageToPlayer(pl.steamId, {1,0.2,0.2}, "Missing target!" )  return false end
    local target = TDMP_SearchPlayer(search)
    if not target then TDMP_SendChatMessageToPlayer(pl.steamId, {1,0.2,0.2}, "Couldn't find player \"" .. search .. "\"!" )  return false end
    if not TDMP_CanTarget_SameRank(pl.steamId, target.steamId) then TDMP_SendChatMessageToPlayer(pl.steamId, {1,0.2,0.2}, "You cannot target this player!" ) return false end
    return target
end

function TDMP_AddCommand(name, rank, cb)
    if type(name) == "string" then
        TDMP_Commands[name] = {rank = rank, cb = cb}
        --return TDMP_Commands[name]
    elseif type(name) == "table" then
        for _, alias in ipairs(name) do
            TDMP_Commands[alias] = {rank = rank, cb = cb}
        end
        --return TDMP_Commands[name[1]]
    else
        DebugPrint("Invalid type for name in addcommand")
    end
end

function TDMP_SimplifyPlayer(pl)
    return {steamId = pl.steamId, id = pl.id}
end

function TDMP_AddRank(name, tbl)
    TDMP_Ranks[name] = tbl
end


function TDMP_GetPlayerColorSafe(pl)
    return (pl.GetColor and pl:GetColor(true)) or {0,1,0}
end

function TDMP_SetRank(steamid, rank)
    SetString("savegame.mod.tdmp_commands_rank_" .. steamid, rank)
end

function TDMP_GetRank(steamid)
    if TDMP_IsLobbyOwner(steamid) then return "superadmin" end
    local rank = GetString("savegame.mod.tdmp_commands_rank_" .. steamid)
    if (not rank) or rank == "" then SetString("savegame.mod.tdmp_commands_rank_" .. steamid, "user"); rank = "user" end
    return rank
end

function TDMP_GetRankTable(steamid)
    return TDMP_Ranks[TDMP_GetRank(steamid)]
end

function TDMP_CanUseCommand(steamid, cmd) -- LESS PRIVILEGE VALUE = MORE VALUE, lowest to highest
   return (TDMP_Ranks[TDMP_GetRank(steamid)].privilege <= TDMP_Ranks[cmd.rank].privilege)
end

function TDMP_CanTarget(steamid, target)
    return (steamid == target) or TDMP_GetRankTable(steamid).privilege < TDMP_GetRankTable(target).privilege
end
function TDMP_CanTarget_SameRank(steamid, target)
    return (steamid == target) or TDMP_GetRankTable(steamid).privilege <= TDMP_GetRankTable(target).privilege
end
function TDMP_SetPlayerPosition(steamid, pos)
    if not TDMP_IsServer() then return end
    if type(steamid) == "string" or  type(steamid) == "number" then steamid = Player(steamid) end
    steamid = steamid.steamId
    local data = json.encode({pos[1], pos[2],pos[3]})
    TDMP_ServerStartEvent("TDMP_SetPlayerPos", {
		Receiver = steamid, -- As a host we don't need to send that event to ourself, otherwise we'd get in loop of restarting map again and again
		Reliable = true,

		DontPack = true, -- We're sending empty string so no need to pack it or do anything with it
		Data = data
	})
end



function processCommand(steamId, msg)
    if not steamId then return end
    if not msg then return end
    if not string_startwith(msg, "!") then return end

    local args = string_split(msg)
    local tcmd = args[1]:sub(2);
    local cmd = TDMP_Commands[tcmd]
    if (not cmd) then 
        if customInvalidCommandSystem then
            TDMP_SendChatMessageToPlayer(steamId, {0,1,0}, "Command \"" .. tcmd .. "\" does not exist!" ) 
            return "" 
        else
            return
        end
    end 
    if not TDMP_CanUseCommand(steamId, cmd) then
        TDMP_SendChatMessageToPlayer(steamId, {1,0,0}, "This command is ", {1,1,0}, cmd.rank, {1,0,0}, "+" ) 
        return ""  
    end
    table.remove(args, 1)
    cmd.cb(Player(steamId), args) 
    return ""
end

local sendStartMessageList = {}
Hook_AddListener("TDMP_ChatSuppressMessage", "TDMP_ChatCommandMaster", function(msgData)
    msgData = json.decode(msgData)
    return processCommand(msgData[2], msgData[1])
end)

function init()
    TDMP_RegisterEvent("TDMP_SetPlayerPos", function(data, sender)
        if sender and ( TDMP_IsServer() and ( (sender ~= TDMP_LocalSteamID) and sender ~= "" ) ) then return end
        local pos = json.decode(data)
        SetPlayerTransform(Transform(Vec(pos[1], pos[2], pos[3])))
    end)
    Hook_Run("TDMP_ChatAdminInit")
    sendStartMessageList[TDMP_LocalSteamID] = GetTime() + startMessageDelay
end

function update()
    for steamid, time in pairs(sendStartMessageList) do
        if (time ~= nil) and (GetTime() > time) then
            for _, msg in ipairs(startMessage) do
                TDMP_SendChatMessageToPlayer(steamid, unpack(msg))
            end
            sendStartMessageList[steamid] = nil
        end
    end
end

Hook_AddListener("PlayerConnected", "TDMP_PlayerConnected", function(steamid)
    if not sendStartMessage then return end
    sendStartMessageList[steamid] = GetTime() + startMessageDelay
end)