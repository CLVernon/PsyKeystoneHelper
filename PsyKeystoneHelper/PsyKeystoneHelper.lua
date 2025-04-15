local _, ns = ...

ns.PsyKeystoneHelper = LibStub("AceAddon-3.0"):NewAddon("PsyKeystoneHelper", "AceConsole-3.0", "AceEvent-3.0" );
PsyKeystoneHelper = ns.PsyKeystoneHelper
PsyKeystoneHelper.v = C_AddOns.GetAddOnMetadata("PsyKeystoneHelper", "Version")

--Create Minimap Button
PsyKeystoneHelperDBI = LibStub("LibDataBroker-1.1"):NewDataObject("PsyKeystoneHelperDBI", {
	type = "data source",
	text = "PsyKeystoneHelper",
	label = "PsyKeystoneHelper",
	icon = "Interface\\AddOns\\PsyKeystoneHelper\\logo",
	OnClick = function(_, buttonPressed)	
		if buttonPressed == "RightButton" then
			PsyKeystoneHelper:toggleSessionStatus()
		elseif buttonPressed =="MiddleButton" then
			PsyKeystoneHelper:handleChatCommand("")
		elseif buttonPressed =="LeftButton" then
			if PsyKeystoneHelper.frame:IsShown() then
				PsyKeystoneHelper.frame:Hide()
			else
				PsyKeystoneHelper.frame:Show()
			end
		end
	end,
	OnTooltipShow = function (tt)
		tt:AddLine("Keystone Helper " .. "|cFFFFFFFF" .. PsyKeystoneHelper.v .. "|r")
		tt:AddLine(" ")
		tt:AddLine("Session Status: " .. PsyKeystoneHelper:getSessionStatusString())
		tt:AddLine(" ")
		tt:AddLine("Left Click: |cFFFFFFFFShow Window|r")
		tt:AddLine("Middle Click: |cFFFFFFFFShow Commands|r")
		tt:AddLine("Right Click: |cFFFFFFFFToggle Session State|r")
	end
})

--Get Libs
LibDBIcon = LibStub("LibDBIcon-1.0")
LibAceSerializer = LibStub("AceSerializer-3.0")
AceDB = LibStub("AceDB-3.0")
AceComm = LibStub("AceComm-3.0")
AceEvent = LibStub("AceEvent-3.0")

--------------------------------------------------------------------------------------------------------------------------------------------
-- ADDON EVENTS
--------------------------------------------------------------------------------------------------------------------------------------------

function PsyKeystoneHelper:OnInitialize()
	--Init db
	PsyKeystoneHelper.db = AceDB:New("PsyKeystoneHelper_Session",{
		profile = {
			session = false,
			debugMode = false,
			keystoneCache = {},
			minimap = {
				hide = false,
			}
		}
	})

	--Register slash command
	PsyKeystoneHelper:RegisterChatCommand("pkh", "handleChatCommand")
	PsyKeystoneHelper:RegisterChatCommand("keyhelper", "handleChatCommand")

	--Register events
	PsyKeystoneHelper:RegisterEvent("GROUP_LEFT", "handleGroupLeft")
	PsyKeystoneHelper:RegisterEvent("GROUP_JOINED", "handleGroupJoined")
	PsyKeystoneHelper:RegisterEvent("CHALLENGE_MODE_COMPLETED", "handleChallengeModeCompleted")
	PsyKeystoneHelper:RegisterEvent("ITEM_COUNT_CHANGED", "handleItemCountChanged")
	PsyKeystoneHelper:RegisterEvent("ITEM_CHANGED", "handleItemChanged")

	--Show minimap icon
	LibDBIcon:Register("PsyKeystoneHelperDBI", PsyKeystoneHelperDBI, PsyKeystoneHelper.db.profile.minimap)
	LibDBIcon:Show("PsyKeystoneHelperDBI")
	LibDBIcon:AddButtonToCompartment("PsyKeystoneHelperDBI")

	--Disable state on load if player is not in group or is in raid
	if (not UnitInParty("player") or UnitInRaid("player") and PsyKeystoneHelper:getSessionStatus()) then
		PsyKeystoneHelper:toggleSessionStatus()
	end

	--Remind user of session state
	PsyKeystoneHelper:Print("Session is " .. PsyKeystoneHelper:getSessionStatusString())

	--Load frame if session is running
	if PsyKeystoneHelper:getSessionStatus() then
		PsyKeystoneHelper.frame:Show()
	end
end

function PsyKeystoneHelper:OnEnable()
end

function PsyKeystoneHelper:OnDisable()
end

--------------------------------------------------------------------------------------------------------------------------------------------
-- Chat Commands
--------------------------------------------------------------------------------------------------------------------------------------------

function PsyKeystoneHelper:handleChatCommand(input)
	local args = {strsplit(' ', input)}

	for _, arg in ipairs(args) do
		if arg == "session" then
			PsyKeystoneHelper:toggleSessionStatus()
			return
		elseif arg == "show" then
			if PsyKeystoneHelper.frame:IsShown() then
				PsyKeystoneHelper.frame:Hide()
			else
				PsyKeystoneHelper.frame:Show()
			end
			return
		elseif arg == "request" then
			PsyKeystoneHelper:requestInformation()
			return
		elseif arg == "send" then
			PsyKeystoneHelper:sendInformation()
			return
		elseif arg == "cache" then
			DevTools_Dump(PsyKeystoneHelper.db.profile.keystoneCache)
			return
		elseif arg == "clear" then
			PsyKeystoneHelper.db.profile.keystoneCache = {}
			PsyKeystoneHelper:Print("Cache cleared")
			return
		elseif arg == "debug" then
			if PsyKeystoneHelper.db.profile.debugMode then 
				PsyKeystoneHelper.db.profile.debugMode = false
				PsyKeystoneHelper:Print("Debug mode is: |cffffff33Disabled|r")
			else
				PsyKeystoneHelper.db.profile.debugMode = true
				PsyKeystoneHelper:Print("Debug mode is: |cffffff33Enabled|r")
			end
			ns:displayPartyData()
			return
		elseif arg == "" then
		else
			PsyKeystoneHelper:Print("Unknown command")
		end
	end

	PsyKeystoneHelper:Print("Chat Commands:")
	PsyKeystoneHelper:Print("|cffffaeae/pkh|r " .. "|cffffff33session|r ".. "- Toggle the state of the session")
	PsyKeystoneHelper:Print("|cffffaeae/pkh|r " .. "|cffffff33show|r ".. "- Show the Keystone Helper window")
	PsyKeystoneHelper:Print("|cffffaeae/pkh|r " .. "|cffffff33request|r ".. "- Request data from the party")
	PsyKeystoneHelper:Print("|cffffaeae/pkh|r " .. "|cffffff33send|r ".. "- Send data to the party")
	PsyKeystoneHelper:Print("|cffffaeae/pkh|r " .. "|cffffff33cache|r ".. "- Print the cache data")
	PsyKeystoneHelper:Print("|cffffaeae/pkh|r " .. "|cffffff33clear|r ".. "- Clear the cache data")
	PsyKeystoneHelper:Print("|cffffaeae/pkh|r " .. "|cffffff33debug|r ".. "- Toggle debug mode")
end

function PsyKeystoneHelper:DebugPrint(msg)
	if PsyKeystoneHelper.db == nil then return end
	if PsyKeystoneHelper.db.profile.debugMode then PsyKeystoneHelper:Print(msg) end
end

--------------------------------------------------------------------------------------------------------------------------------------------
-- Session Status
--------------------------------------------------------------------------------------------------------------------------------------------

function PsyKeystoneHelper:toggleSessionStatus()
	if PsyKeystoneHelper.db.profile.session then 
		PsyKeystoneHelper.db.profile.session = false 
		PsyKeystoneHelper.db.profile.keystoneCache = {}
	else 
		if not UnitInParty("player") then
			PsyKeystoneHelper:Print("Cannot start a session when not in a party")
			return
		end
		if UnitInRaid("player") then
			PsyKeystoneHelper:Print("Cannot start a session when in a raid group")
			return
		end
		PsyKeystoneHelper.db.profile.session = true 
		PsyKeystoneHelper:requestInformation()
	end

	PsyKeystoneHelper:Print("Session is now " .. PsyKeystoneHelper:getSessionStatusString())
	PsyKeystoneHelper.frame.status:SetText("Status: " .. PsyKeystoneHelper:getSessionStatusString())
	LibDBIcon:Hide("PsyKeystoneHelperDBI")
	LibDBIcon:Show("PsyKeystoneHelperDBI")
end

function PsyKeystoneHelper:getSessionStatus()
	if PsyKeystoneHelper.db == nil then return false end
	return PsyKeystoneHelper.db.profile.session or false
end

function PsyKeystoneHelper:getSessionStatusString()
	if PsyKeystoneHelper:getSessionStatus() then
		return "\124cFF00FF00Running"
	else 
		return "\124cFFFF0000Stopped"
	end
end

--------------------------------------------------------------------------------------------------------------------------------------------
-- Event Handling
--------------------------------------------------------------------------------------------------------------------------------------------

function PsyKeystoneHelper:handleGroupLeft() 
	PsyKeystoneHelper:DebugPrint("handleGroupLeft()")
	if PsyKeystoneHelper:getSessionStatus() then
		PsyKeystoneHelper:toggleSessionStatus()
		ns:displayPartyData()
	end
end

function PsyKeystoneHelper:handleGroupJoined() 
	PsyKeystoneHelper:DebugPrint("handleGroupJoined()")
	if UnitInRaid("player") then
		if PsyKeystoneHelper:getSessionStatus() then 
			PsyKeystoneHelper:toggleSessionStatus()
		end
		return
	end
	PsyKeystoneHelper:sendInformation()
end

function PsyKeystoneHelper:handleChallengeModeCompleted() 
	PsyKeystoneHelper:DebugPrint("handleChallengeModeCompleted()")
	PsyKeystoneHelper:sendInformation()
	C_Timer.After(3, function () PsyKeystoneHelper:sendInformation() end)
	if PsyKeystoneHelper:getSessionStatus() then
		PsyKeystoneHelper.frame:Show()
	end
end

function PsyKeystoneHelper:handleItemCountChanged(e, itemId) 
	if itemId == 180653 or itemId == 138019 then
		PsyKeystoneHelper:DebugPrint("handleItemCountChanged()")
		PsyKeystoneHelper:sendInformation()
		C_Timer.After(2, function () PsyKeystoneHelper:sendInformation() end)
		return
	end
end

function PsyKeystoneHelper:handleItemChanged(e, itemFrom, itemTo) 
	if string.find(itemFrom, "Mythic Keystone") ~= nil then
		PsyKeystoneHelper:DebugPrint("handleItemChanged()")
		PsyKeystoneHelper:sendInformation()
		C_Timer.After(2, function () PsyKeystoneHelper:sendInformation() end)
	end
end

--------------------------------------------------------------------------------------------------------------------------------------------
-- Communications
--------------------------------------------------------------------------------------------------------------------------------------------

function PsyKeystoneHelper:requestInformation()
	PsyKeystoneHelper:DebugPrint("Requesting data from party...")
	AceComm:SendCommMessage("PsyKeyStone", LibAceSerializer:Serialize({
		type="REQUEST",
		obj={}
	}), "PARTY", UnitName("player"))
end

function PsyKeystoneHelper:receiveInformation(playerData)
	PsyKeystoneHelper:DebugPrint("Received data from " .. playerData.fullName)
	if not PsyKeystoneHelper:getSessionStatus() then return end

	--Check to see if the player already exists in data
	local existingIndex = 0
	for index, cachedPlayer in pairs(PsyKeystoneHelper.db.profile.keystoneCache) do
		if cachedPlayer.fullName == playerData.fullName then
			existingIndex = index
			break
		end
	end

	--Update the cache
	if existingIndex == 0 then
		PsyKeystoneHelper.db.profile.keystoneCache[#PsyKeystoneHelper.db.profile.keystoneCache + 1] = playerData
	else 
		PsyKeystoneHelper.db.profile.keystoneCache[existingIndex] = playerData
	end
	PsyKeystoneHelper:sortInformation() 
	ns:displayPartyData()
end

function PsyKeystoneHelper:sortInformation() 
	table.sort(PsyKeystoneHelper.db.profile.keystoneCache, function (t1, t2) return t1.overallScore > t2.overallScore end)

	local fullNamesToRemove = {}
	for index, playerData in pairs(PsyKeystoneHelper.db.profile.keystoneCache) do
		local keepPlayer = false
		if  GetUnitName("Party1") == playerData.name then keepPlayer = true end
		if  GetUnitName("Party2") == playerData.name then keepPlayer = true end
		if  GetUnitName("Party3") == playerData.name then keepPlayer = true end
		if  GetUnitName("Party4") == playerData.name then keepPlayer = true end
		if  GetUnitName("player") == playerData.name then keepPlayer = true end

		if not keepPlayer then
			table.insert(fullNamesToRemove, playerData.fullName)
		end
	end

	for _, fullName in pairs(fullNamesToRemove) do
		local indexToRemove = 0
		for index, playerData in pairs(PsyKeystoneHelper.db.profile.keystoneCache) do
			if playerData.fullName == fullName then
				indexToRemove = index
				break
			end
		end

		if indexToRemove > 0 then 
			table.remove(PsyKeystoneHelper.db.profile.keystoneCache, indexToRemove)
		end
	end
end

function PsyKeystoneHelper:sendInformation()
	-- Get M+ score information and add dungeon name and abbreviation
	local scoreInfo = C_ChallengeMode.GetMapScoreInfo()
	for _, dungeon in pairs(scoreInfo) do
		local mapName = C_ChallengeMode.GetMapUIInfo(dungeon.mapChallengeModeID) or ""
		local mapAbbreviation = ns.dungeonAbbreviations[mapName] or ""

		dungeon.mapName = mapName
		dungeon.mapAbbreviation = mapAbbreviation
	end

	-- Get keystone information
	local ownedChallengeMapId = C_MythicPlus.GetOwnedKeystoneChallengeMapID() or nil
	local keystone = nil
	if ownedChallengeMapId then
		local mapName, mapID, _, texture, backgroundTexture = C_ChallengeMode.GetMapUIInfo(ownedChallengeMapId)
		keystone = {
			mapChallengeModeID = ownedChallengeMapId,
			mapID = mapID,
			level = C_MythicPlus.GetOwnedKeystoneLevel(),
			texture = texture,
			backgroundTexture = backgroundTexture,
			itemLink = nil, --todo
			mapName = mapName,
			mapAbbreviation = ns.dungeonAbbreviations[mapName] or mapName
		}
	end

	-- Get class properties
	local className, classFilename, classId = UnitClass("player")

	-- Create obj to send
	local playerData = {
		name = GetUnitName("player"),
		realm = GetRealmName("player"),
		fullName = GetUnitName("player") .. "-" .. GetRealmName("player"),
		className = className,
		classFilename = classFilename,
		classId = classId,
		scoreInfo = scoreInfo,
		overallScore = C_ChallengeMode.GetOverallDungeonScore(),
		keystone = keystone,
		sessionState = PsyKeystoneHelper:getSessionStatus(),
		version = PsyKeystoneHelper.v
	}

	PsyKeystoneHelper:DebugPrint("Sending data to party...")
	AceComm:SendCommMessage("PsyKeyStone", LibAceSerializer:Serialize({
		type="SEND",
		obj=playerData
	}), "PARTY", UnitName("player"))
end

local function HandleComm(prefix, message, distribution, sender)
	local success ,messageObj = LibAceSerializer:Deserialize(message)
	if not success then return end
	if messageObj.type == "SEND" then
		PsyKeystoneHelper:receiveInformation(messageObj.obj)
	elseif messageObj.type =="REQUEST" then
		PsyKeystoneHelper:sendInformation()
	end
end

--------------------------------------------------------------------------------------------------------------------------------------------
-- Dungeon Stuff
--------------------------------------------------------------------------------------------------------------------------------------------

-- Map or dungeon name to abbreviation
ns.dungeonAbbreviations = {
    ["Cinderbrew Meadery"] = "BREW",
    ["Darkflame Cleft"] = "DFC",
    ["Operation: Floodgate"] = "FLOOD",
    ["The MOTHERLODE!!"] = "ML",
    ["Priory of the Sacred Flame"] = "PSF",
    ["The Rookery"] = "ROOK",
    ["Theater of Pain"] = "TOP",
    ["Operation: Mechagon - Workshop"] = "WORK",
}

-- Just in-time score of each level
ns.minTimeScorePerLevels = {
  [2] =  155,
  [3] =  170,
  [4] =  200,
  [5] =  215,
  [6] =  230,
  [7] =  260,
  [8] =  275,
  [9] =  290,
  [10] = 320,
  [11] = 335,
  [12] = 365,
  [13] = 380,
  [14] = 395,
  [15] = 410,
  [16] = 425,
  [17] = 440,
  [18] = 455,
  [19] = 470,
  [20] = 485,
  [21] = 500,
  [22] = 515,
  [23] = 530,
  [24] = 545,
  [25] = 560,
  [26] = 575,
  [27] = 590,
  [28] = 605,
  [29] = 620,
  [30] = 635,
  [31] = 650,
  [32] = 665,
  [33] = 680,
  [34] = 695,
  [35] = 710,
  [36] = 725,
  [37] = 740,
  [38] = 755,
  [39] = 770,
}

--------------------------------------------------------------------------------------------------------------------------------------------
-- Other Init
--------------------------------------------------------------------------------------------------------------------------------------------
AceComm:RegisterComm("PsyKeyStone", HandleComm)