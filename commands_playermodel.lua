#include "tdmp/hooks.lua"
#include "tdmp/player.lua"
#include "tdmp/networking.lua"
#include "tdmp/utilities.lua"
#include "tdmp/chat.lua"
#include "tdmp/json.lua"

--#include "tdmp/TDMP/main.lua"
PlayerModels = {
	Selected = {},
	Paths = {
		{author = "SnakeyWakey", name = "Human", xml = "builtin-tdmp:vox/player/human.xml", xmlRag = "builtin-tdmp:vox/player/human_ragdoll.xml", img = "tdmp/TDMP/vox/player/images/human.png"},
		{author = "SnakeyWakey", name = "Bussinessman", xml = "builtin-tdmp:vox/player/bussiness.xml", xmlRag = "builtin-tdmp:vox/player/bussiness_ragdoll.xml", img = "tdmp/TDMP/vox/player/images/bussiness.png"},
		{author = "SnakeyWakey", name = "Scientist", xml = "builtin-tdmp:vox/player/scientist.xml", xmlRag = "builtin-tdmp:vox/player/scientist_ragdoll.xml", img = "tdmp/TDMP/vox/player/images/scientist.png"},
		{author = "SnakeyWakey", name = "Chaos", xml = "builtin-tdmp:vox/player/chaos.xml", xmlRag = "builtin-tdmp:vox/player/chaos_ragdoll.xml", img = "tdmp/TDMP/vox/player/images/chaos.png"},

		{author = "squareblock", name = "Astronaut", xml = "builtin-tdmp:vox/player/astronaut.xml", xmlRag = "builtin-tdmp:vox/player/astronaut_ragdoll.xml", img = "tdmp/TDMP/vox/player/images/Astronaut.png"},
		{author = "squareblock", name = "Blue shirt guy", xml = "builtin-tdmp:vox/player/bluewhiteshirt.xml", xmlRag = "builtin-tdmp:vox/player/bluewhiteshirt_ragdoll.xml", img = "tdmp/TDMP/vox/player/images/Blue shirt guy.png"},
		{author = "squareblock", name = "Fancy guy", xml = "builtin-tdmp:vox/player/fancy.xml", xmlRag = "builtin-tdmp:vox/player/fancy_ragdoll.xml", img = "tdmp/TDMP/vox/player/images/Fancy guy.png"},
		{author = "squareblock", name = "Human revamped", xml = "builtin-tdmp:vox/player/revamped.xml", xmlRag = "builtin-tdmp:vox/player/revamped_ragdoll.xml", img = "tdmp/TDMP/vox/player/images/Human revamped.png"},
		{author = "squareblock", name = "James", xml = "builtin-tdmp:vox/player/james.xml", xmlRag = "builtin-tdmp:vox/player/james_ragdoll.xml", img = "tdmp/TDMP/vox/player/images/James.png"},
		{author = "squareblock", name = "Jeremy", xml = "builtin-tdmp:vox/player/jeremy.xml", xmlRag = "builtin-tdmp:vox/player/jeremy_ragdoll.xml", img = "tdmp/TDMP/vox/player/images/Jeremy.png"},
		{author = "squareblock", name = "Richard", xml = "builtin-tdmp:vox/player/richard.xml", xmlRag = "builtin-tdmp:vox/player/richard_ragdoll.xml", img = "tdmp/TDMP/vox/player/images/Richard.png"},
		{author = "squareblock", name = "Mclockelles employee", xml = "builtin-tdmp:vox/player/mclockellesemployee.xml", xmlRag = "builtin-tdmp:vox/player/mclockellesemployee_ragdoll.xml", img = "tdmp/TDMP/vox/player/images/Mclockelles employee.png"},
		{author = "squareblock", name = "Office worker 1", xml = "builtin-tdmp:vox/player/whiteshirt_tie.xml", xmlRag = "builtin-tdmp:vox/player/whiteshirt_tie_ragdoll.xml", img = "tdmp/TDMP/vox/player/images/Office worker 1.png"},
		{author = "squareblock", name = "Office worker 2", xml = "builtin-tdmp:vox/player/whiteshirt_tie2.xml", xmlRag = "builtin-tdmp:vox/player/whiteshirt_tie2_ragdoll.xml", img = "tdmp/TDMP/vox/player/images/Office worker 2.png"},
		{author = "squareblock", name = "Swedish police", xml = "builtin-tdmp:vox/player/swedish_police2.xml", xmlRag = "builtin-tdmp:vox/player/swedish_police2_ragdoll.xml", img = "tdmp/TDMP/vox/player/images/Swedish police.png"},

		{author = "Nikkill", name = "Omori", xml = "builtin-tdmp:vox/player/omori.xml", xmlRag = "builtin-tdmp:vox/player/omori_ragdoll.xml", img = "tdmp/TDMP/vox/player/images/omori.png"},
		{author = "Nikkill", name = "Sunny", xml = "builtin-tdmp:vox/player/sunny.xml", xmlRag = "builtin-tdmp:vox/player/sunny_ragdoll.xml", img = "tdmp/TDMP/vox/player/images/sunny.png"},
		{author = "Nikkill", name = "Kel", xml = "builtin-tdmp:vox/player/kel.xml", xmlRag = "builtin-tdmp:vox/player/kel_ragdoll.xml", img = "tdmp/TDMP/vox/player/images/kel.png"},
		{author = "Nikkill", name = "Mari", xml = "builtin-tdmp:vox/player/mari.xml", xmlRag = "builtin-tdmp:vox/player/mari_ragdoll.xml", img = "tdmp/TDMP/vox/player/images/mari.png"},
		{author = "Nikkill", name = "Hero", xml = "builtin-tdmp:vox/player/hero.xml", xmlRag = "builtin-tdmp:vox/player/hero_ragdoll.xml", img = "tdmp/TDMP/vox/player/images/hero.png"},
		{author = "Nikkill", name = "Aubrey", xml = "builtin-tdmp:vox/player/aubrey.xml", xmlRag = "builtin-tdmp:vox/player/aubrey_ragdoll.xml", img = "tdmp/TDMP/vox/player/images/aubrey.png"},
		{author = "Nikkill", name = "Basil", xml = "builtin-tdmp:vox/player/basil.xml", xmlRag = "builtin-tdmp:vox/player/basil_ragdoll.xml", img = "tdmp/TDMP/vox/player/images/basil.png"},
	},

	Default = "builtin-tdmp:vox/player/human.xml"
}

do
    math.randomseed(TDMP_FixedTime()^2)
    -- Auto-adding player models to models list
    for i, mod in ipairs(ListKeys("spawn")) do
        for i, spawnable in ipairs(ListKeys("spawn." .. mod)) do
            local p = "spawn." .. mod .. "." .. spawnable
            local catPath = GetString(p)

            if catPath:find("TDMP Models") then
                for i, xml in ipairs(ListKeys(p)) do
                    local path = GetString(p .. ".path")
                    if not path:find("_ragdoll") and path:sub(1,13) ~= "builtin-tdmp:" then
                        local n = GetString(p)

                        local t = "Other"
                        local s = string.find(n, "/", 1, true)
                        if s and s > 1 then
                            t = string.sub(n, 1, s-1)
                            n = string.sub(n, s+1, string.len(n))
                        end

                        if n == "" then 
                            n = "Unnamed"
                        end

                        local rnd = math.random()
                        local r, g, b = hsv2rgb(rnd, 1, 1)
                        local ins = {
                            name = n,
                            xml = path,
                            xmlRag = path:sub(1, #path-4) .. "_ragdoll.xml",
                            img = "vox/player/custom.png",
                            colR = r,
                            colG = g,
                            colB = b,
                        }
                        PlayerModels.Paths[#PlayerModels.Paths + 1] = ins

                        TDMP_Print("Found and added player model:", ins.xml .. " (ragdoll: " .. ins.xmlRag .. ")")
                    end
                end
            end
        end
    end
end

function TDMP_SetPlayerModel(new_model, steamid)

		PlayerModels.Selected[steamid] = PlayerModels.Paths[new_model] and new_model or 1

		if steamid == TDMP_LocalSteamID then
			SetInt("savegame.mod.tdmp.playermodel", new_model)
		end

		Hook_Run("PlayerModelChanged", {steamid, PlayerModels.Selected[steamid]})
		if not TDMP_IsServer() then return end

		if not PlayerModels.Paths[new_model] then
			new_model = 1
		end


	    TDMP_ServerStartEvent("FetchAllModels", {
				Receiver = steamid,
				Reliable = true,

				Data = PlayerModels.Selected
		})
		TDMP_ServerStartEvent("SelectPlayerModel", {
			Receiver = 2,-- TDMP.Enums.Receiver.ClientsOnly, -- We've received that event already so we need to broadcast it only to clients, not again to ourself
			Reliable = true,

			Data = {new_model, steamid}
		})
end

Hook_AddListener("TDMP_ChatAdminInit", "TDMP_ChatAdminInitCommand_PlayerModel", function()
    TDMP_AddCommand({"setplayermodel", "setpm"}, "admin", function(pl, args)
        local target = TDMP_GetTarget(pl, args[1])
        if not target then return end

        if not args[2] then TDMP_SendChatMessageToPlayer(pl.steamId, {0,1,0}, "Missing model number!" )  return end
        local pm_id = tonumber(args[2])
        if not pm_id then TDMP_SendChatMessageToPlayer(pl.steamId, {0,1,0}, "Invalid number!" )  return end
        if not PlayerModels.Paths[pm_id] then TDMP_SendChatMessageToPlayer(pl.steamId, {0,1,0}, "Invalid model") return end

        local data = {pm_id, target.steamId }
        TDMP_BroadcastChatMessage(TDMP_GetPlayerColorSafe(pl), TDMP_SimplifyPlayer(pl), {1,1,1}, "  set ", TDMP_GetPlayerColorSafe(target), TDMP_SimplifyPlayer(target), {1,1,1}, "'s model to " , {1,0.8,0.4}, PlayerModels.Paths[pm_id].name, {1,1,1}, ".") 
        
        --[[if target.steamId == TDMP_LocalSteamID then 
        TDMP_ClientStartEvent("SelectPlayerModel", {
            Reliable = true,
            DontPack = false,
            Data = data
        })
        return
        end]]
        --[[
    	TDMP_ServerStartEvent("SelectPlayerModel", {
                Receiver = TDMP.Enums.Receiver.All,
                Reliable = true,
                DontPack = false,
                Data = data
		})]]

        TDMP_SetPlayerModel(pm_id, target.steamId)

      
        
    end)

    TDMP_AddCommand("playermodels", "user", function(pl, args)
        local message = {pl.steamId, {1,1,1}, "Here is a list of playermodels!"}
        TDMP_SendChatMessageToPlayer(unpack(message))
        for _, model in ipairs(PlayerModels.Paths) do
            TDMP_SendChatMessageToPlayer(pl.steamId, {0.5,1,0.5}, tostring(_), {1,0.8,0.5}, " " .. model.name)
        end
    end)
    --[[TDMP_RegisterEvent("SelectPlayerModel", function(data, steamid)
        DebugPrint( "SelectPlayerModel: " .. data)
        DebugPrint( "SelectPlayerModel SteamId: " .. steamid .. " : Type: " .. type(steamid))
		data = json.decode(data)
    end)]]
    --[[Hook_AddListener("PlayerModelChanged", "ateafga", function(data)
        DebugPrint("PlayerModelChangedHook: " .. data)
    end)]]
end)