#include "tdmp/hooks.lua"
#include "tdmp/player.lua"
#include "tdmp/networking.lua"
#include "tdmp/utilities.lua"
#include "tdmp/chat.lua"
#include "tdmp/json.lua"

Hook_AddListener("TDMP_ChatAdminInit", "TDMP_ChatAdminInitCommand_VoteMap", function()
        local votedPlayers = {}
        local votedMaps = {}
        local gSandbox = {		
            { mod_level = false, id="lee_sandbox", level="lee", name="Lee Chemicals", image="menu/level/lee.png", file="lee.xml", layers="sandbox"},
            { mod_level = false, id="marina_sandbox", level="marina", name="Marina", image="menu/level/marina.png", file="marina.xml", layers="sandbox"},
            { mod_level = false, id="mansion_sandbox", level="mansion", name="Villa Gordon", image="menu/level/mansion.png", file="mansion.xml", layers="sandbox"},
            { mod_level = false, id="caveisland_sandbox", level="caveisland", name="Hollowrock", image="menu/level/caveisland.png", file="caveisland.xml", layers="sandbox"},
            { mod_level = false, id="mall_sandbox", level="mall", name="Evertides", image="menu/level/mall.png", file="mall.xml", layers="sandbox"},
            { mod_level = false, id="frustrum_sandbox", level="frustrum", name="Frustrum", image="menu/level/frustrum.png", file="frustrum.xml", layers="sandbox"},
            { mod_level = false, id="hub_carib_sandbox", level="hub_carib", name="Muratori Beach", image="menu/level/hub_carib.png", file="hub_carib.xml", layers="sandbox"},
            { mod_level = false, id="carib_sandbox", level="carib", name="Isla Estocastica", image="menu/level/carib.png", file="carib.xml", layers="sandbox"},
            { mod_level = false, id="factory_sandbox", level="factory", name="Quilez Security", image="menu/level/factory.png", file="factory.xml", layers="sandbox"},
            { mod_level = false, id="cullington_sandbox", level="cullington", name="Cullington", image="menu/level/cullington.png", file="cullington.xml", layers="sandbox"},
        }
        local mods = ListKeys("mods.available")
        for _, modThing in ipairs(mods) do
            --DebugPrint(modKey)
            modKey = "mods.available." .. modThing
            if GetBool(modKey..".playable") and string.find(modKey, "steam") then
                local modKeyId = modKey --"mods.available.".. _
                local mod_name = GetString(modKey..".name")
                table.insert(gSandbox, {mod_level = true,name = mod_name, id=modKeyId })
            end
        end
        Hook_AddListener("PlayerDisconnected", "tdmp_commands_votedc", function(steam)
            if votedPlayers[steam] and votedPlayers[steam] > 0 then
                votedMaps[steam] = votedMaps[steam] - 1
                votedPlayers[steam] = nil
            end
        end)
        TDMP_AddCommand("votemap", "user", function(pl, args)
            local map_id = args[1]
            if not map_id then TDMP_SendChatMessageToPlayer(pl.steamId, {0,1,0}, "Missing model number!" )  return end
            map_id = tonumber(map_id)
            if not map_id then TDMP_SendChatMessageToPlayer(pl.steamId, {0,1,0}, "Invalid number!" )  return end
            if map_id <= 0 then TDMP_SendChatMessageToPlayer(pl.steamId, {0,1,0}, "Number has to be above 0!" )  return end
            if not gSandbox[map_id] then TDMP_SendChatMessageToPlayer(pl.steamId, {0,1,0}, "Invalid map!" ) return end 
            if not votedPlayers[pl.steamId] then votedPlayers[pl.steamId] = -1 end
            if votedPlayers[pl.steamId] == map_id then TDMP_SendChatMessageToPlayer(pl.steamId, {0,1,0}, "You have already voted for this map!" ) return end
            
            if votedMaps[votedPlayers[pl.steamId]] then votedMaps[votedPlayers[pl.steamId]] = votedMaps[votedPlayers[pl.steamId]] - 1 end
            votedMaps[map_id] = (votedMaps[map_id] or 0) + 1
            votedPlayers[pl.steamId] = map_id

            TDMP_BroadcastChatMessage({1,0.5,0.2}, TDMP_SimplifyPlayer(pl), {1,1,1}, "  has voted for ", {1,0.5,0.2}, gSandbox[map_id].name, {1,1,1}, ". (" .. tostring(votedMaps[map_id]) .. "/" .. tostring(#TDMP_GetPlayers()) .. ")" )
            if votedMaps[map_id] >= #TDMP_GetPlayers() / 1.8 then
                TDMP_BroadcastChatMessage({1,1,1}, "The map ", {1,0.5,0.2}, gSandbox[map_id].name, {1,1,1}, " has won the vote! Game will change level soon...." )
                if TDMP_StartLevel then TDMP_BroadcastChatMessage( {1,0.5,0.2}, "TDMP_StartLevel exists but probably won't work outside of lobby") end
                if TDMP_StartLevel then TDMP_BroadcastChatMessage( {1,0.5,0.2}, "Aka map change probably won't work!") end
                if gSandbox[map_id].mod_level then
                    --DebugPrint("Starting mod level....")
                    --DebugPrint(gSandbox[map_id].id)
                    TDMP_StartLevel( true, gSandbox[map_id].id)
                else
                    --DebugPrint("Starting sandbox level....")
                    --  TDMP_StartLevel( false, gSandbox[map_id].id, gSandbox[map_id].file, gSandbox[map_id].layers)
                    --DebugPrint(gSandbox[map_id].id)
                    --DebugPrint(gSandbox[map_id].file)
                    --DebugPrint(gSandbox[map_id].layers)
                    TDMP_StartLevel( false, gSandbox[map_id].id, gSandbox[map_id].file, gSandbox[map_id].layers)
                    --StartLevel(gSandbox[map_id].id, gSandbox[map_id].file, gSandbox[map_id].layers)
                end
                --TDMP_StartLevel(false, gSandbox[i].id, gSandbox[i].file, gSandbox[i].layers)
            end
        end)

        TDMP_AddCommand("maps", "user", function(pl, args)
            local message = {pl.steamId, {1,1,1}, "Here is a list of maps!"}
            TDMP_SendChatMessageToPlayer(unpack(message))
            for _, map in ipairs(gSandbox) do
                TDMP_SendChatMessageToPlayer(pl.steamId, {0.5,1,0.5}, tostring(_), {1,0.8,0.5}, " " .. map.name)
            end
            local message2 = {pl.steamId, {1,1,1}, "Type " , {0,1,0}, "!votemap ", {1,1,0}, "id of map ", {1,1,1}, " to vote for it!"}
            TDMP_SendChatMessageToPlayer(unpack(message2))
            
        end)


end)