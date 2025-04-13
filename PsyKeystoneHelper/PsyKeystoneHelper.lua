local _, PsyKeystoneHelper = ...

PsyKeystoneHelper = LibStub("AceAddon-3.0"):NewAddon("PsyKeystoneHelper", "AceConsole-3.0", "AceEvent-3.0" );
PsyKeystoneHelper.v = "v0.0.1-alpha"

--Create Minimap Button
PsyKeystoneHelperDBI = LibStub("LibDataBroker-1.1"):NewDataObject("PsyKeystoneHelperDBI", {
	type = "data source",
	text = "PsyKeystoneHelper",
	label = "PsyKeystoneHelper",
	icon = "Interface\\AddOns\\PsyKeystoneHelper\\logo",
	OnClick = function(_, buttonPressed)	
		if buttonPressed == "RightButton" then
			PsyKeystoneHelper.mainFrame:Show()
		elseif buttonPressed =="MiddleButton" then
			PsyKeystoneHelper:handleChatCommand("")
		elseif buttonPressed =="LeftButton" then
			PsyKeystoneHelper:toggleSessionStatus()
		end
	end,
	OnTooltipShow = function (tt)
		tt:AddLine("Keystone Helper " .. "|cFFFFFFFF" .. "v0.0.1-alpha" .. "|r")
		tt:AddLine(" ")
		tt:AddLine("Session Status: " .. PsyKeystoneHelper:getSessionStatusString())
		tt:AddLine(" ")
		tt:AddLine("Left Click: |cFFFFFFFFToggle the status of the session|r")
		tt:AddLine("Middle Click: |cFFFFFFFFShow commands|r")
		tt:AddLine("Right Click: |cFFFFFFFFShow Key Helper window|r")
	end
})

--Get Libs
LibDBIcon = LibStub("LibDBIcon-1.0")
LibAceSerializer = LibStub("AceSerializer-3.0")
LibOpenRaid = LibStub("LibOpenRaid-1.0")
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
			debugPrints = false,
			keystoneCache = {},
			minimap = {
				hide = false,
			}
		}
	})

	--Register slash command
	PsyKeystoneHelper:RegisterChatCommand("keyhelper", "handleChatCommand")

	--Register events
	PsyKeystoneHelper:RegisterEvent("GROUP_LEFT", "handleGroupLeft")
	PsyKeystoneHelper:RegisterEvent("GROUP_ROSTER_UPDATE", "handleGroupChange")
	--CHALLENGE_MODE_COMPLETED

	--Show minimap icon
	LibDBIcon:Register("PsyKeystoneHelperDBI", PsyKeystoneHelperDBI, PsyKeystoneHelper.db.profile.minimap)
	LibDBIcon:Show("PsyKeystoneHelperDBI")
	LibDBIcon:AddButtonToCompartment("PsyKeystoneHelperDBI")

	--Remind user of session state
	PsyKeystoneHelper:Print("Session is " .. PsyKeystoneHelper:getSessionStatusString())
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
			PsyKeystoneHelper.mainFrame:Show()
			return
		elseif arg == "request" then
			PsyKeystoneHelper:requestScoreInformation()
			return
		elseif arg == "send" then
			PsyKeystoneHelper:sendScoreInformation()
			return
		elseif arg == "cache" then
			DevTools_Dump(PsyKeystoneHelper.db.profile.keystoneCache)
			return
		elseif arg == "debug" then
			if PsyKeystoneHelper.db.profile.debugPrints then 
				PsyKeystoneHelper.db.profile.debugPrints = false
				PsyKeystoneHelper:Print("Debug Prints are: |cffffff33Disabled|r")
			else
				PsyKeystoneHelper.db.profile.debugPrints = true
				PsyKeystoneHelper:Print("Debug Prints are: |cffffff33Enabled|r")
			end
			return
		elseif arg == "" then
		else
			PsyKeystoneHelper:Print("Unknown command")
			return
		end
	end

	PsyKeystoneHelper:Print("Chat Commands:")
	PsyKeystoneHelper:Print("|cffffaeae/keyhelper|r " .. "|cffffff33session|r ".. "- Toggle the state of the session")
	PsyKeystoneHelper:Print("|cffffaeae/keyhelper|r " .. "|cffffff33show|r ".. "- Show the Keystone Helper window")
	PsyKeystoneHelper:Print("|cffffaeae/keyhelper|r " .. "|cffffff33request|r ".. "- Request data from the party")
	PsyKeystoneHelper:Print("|cffffaeae/keyhelper|r " .. "|cffffff33send|r ".. "- Send data to the party")
	PsyKeystoneHelper:Print("|cffffaeae/keyhelper|r " .. "|cffffff33cache|r ".. "- Print the cache data")
	PsyKeystoneHelper:Print("|cffffaeae/keyhelper|r " .. "|cffffff33debug|r ".. "- Toggle debug messages")
end

function PsyKeystoneHelper:DebugPrint(msg)
	if PsyKeystoneHelper.db == nil then return end
	if PsyKeystoneHelper.db.profile.debugPrints then PsyKeystoneHelper:Print(msg) end
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
		PsyKeystoneHelper.db.profile.session = true 
		PsyKeystoneHelper:requestScoreInformation()
	end

	PsyKeystoneHelper:Print("Session is now " .. PsyKeystoneHelper:getSessionStatusString())
	PsyKeystoneHelper.statusFrame.title:SetText("Status: " .. PsyKeystoneHelper:getSessionStatusString())
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
	if PsyKeystoneHelper:getSessionStatus() then
		PsyKeystoneHelper:toggleSessionStatus()
	end
end

function PsyKeystoneHelper:handleGroupChange() 
	if PsyKeystoneHelper:getSessionStatus() then
		PsyKeystoneHelper:requestScoreInformation()
	end
end

--------------------------------------------------------------------------------------------------------------------------------------------
-- Communications
--------------------------------------------------------------------------------------------------------------------------------------------

function PsyKeystoneHelper:requestScoreInformation()
	PsyKeystoneHelper:DebugPrint("Requesting data from party...")
	AceComm:SendCommMessage("PsyKeyStone", LibAceSerializer:Serialize({
		type="REQUEST",
		obj={}
	}), "PARTY", UnitName("player"))
end

function PsyKeystoneHelper:receiveScoreInformation(playerData)
	PsyKeystoneHelper:DebugPrint("Received data from " .. playerData.fullName)
	if not PsyKeystoneHelper:getSessionStatus() then return end

	--Get the party's keystones
	PsyKeystoneHelper:assignHeldKeystones()

	--Update the cache
	--DevTools_Dump(playerData)
	PsyKeystoneHelper.db.profile.keystoneCache[playerData.fullName] = playerData
	--PsyKeystoneHelper:createPlayerFrame(playerData.fullName)
end

function PsyKeystoneHelper:sendScoreInformation()
	local scoreInfo = C_ChallengeMode.GetMapScoreInfo()

	for _, dungeon in pairs(scoreInfo) do
		local mapName = C_ChallengeMode.GetMapUIInfo(dungeon.mapChallengeModeID) or ""
		local mapAbbreviation = dungeonAbbreviations[mapName] or ""

		dungeon.mapName = mapName
		dungeon.mapAbbreviation = mapAbbreviation
	end

	local playerData = {
		scoreInfo = scoreInfo,
		overallScore = C_ChallengeMode.GetOverallDungeonScore(),
		name = GetUnitName("player"),
		realm = GetRealmName("player"),
		fullName = GetUnitName("player") .. "-" .. GetRealmName("player")
	}

	PsyKeystoneHelper:DebugPrint("Sending data to party...")
	AceComm:SendCommMessage("PsyKeyStone", LibAceSerializer:Serialize({
		type="SEND",
		obj=playerData
	}), "PARTY", UnitName("player"))
end

local function HandleComm(prefix, message, distribution, sender)
	if prefix == "LRS" then
		if PsyKeystoneHelper:getSessionStatus() then
			PsyKeystoneHelper:assignHeldKeystones()
		end
	else
		local success ,messageObj = LibAceSerializer:Deserialize(message)
		if not success then return end
		if messageObj.type == "SEND" then
			PsyKeystoneHelper:receiveScoreInformation(messageObj.obj)
		elseif messageObj.type =="REQUEST" then
			PsyKeystoneHelper:sendScoreInformation()
		end
	end
end

--------------------------------------------------------------------------------------------------------------------------------------------
-- Frame
--------------------------------------------------------------------------------------------------------------------------------------------
PsyKeystoneHelper.mainFrame = CreateFrame("frame", "PsyKeystoneHelperFrame", UIParent, "BasicFrameTemplateWithInset")
table.insert(UISpecialFrames, "PsyKeystoneHelperFrame")
PsyKeystoneHelper.mainFrame:SetSize(500,350)
PsyKeystoneHelper.mainFrame:SetPoint("RIGHT", UIParent, "RIGHT", 0, 0)
PsyKeystoneHelper.mainFrame:SetFrameStrata("LOW")
PsyKeystoneHelper.mainFrame:EnableMouse(true)
PsyKeystoneHelper.mainFrame:SetMovable(true)
PsyKeystoneHelper.mainFrame:SetClampedToScreen(true)
PsyKeystoneHelper.mainFrame:RegisterForDrag("LeftButton")

PsyKeystoneHelper.mainFrame.TitleBg:SetHeight(30)
PsyKeystoneHelper.mainFrame.title = PsyKeystoneHelper.mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
PsyKeystoneHelper.mainFrame.title:SetPoint("TOPLEFT", PsyKeystoneHelper.mainFrame.TitleBg, "TOPLEFT", 5, -3)
PsyKeystoneHelper.mainFrame.title:SetText("Keystone Helper |cffffff33" .. "v0.0.1-alpha" .. "|r")

PsyKeystoneHelper.statusFrame = CreateFrame("Frame", "PsyKeystoneHelperFrame_Status", PsyKeystoneHelper.mainFrame)
PsyKeystoneHelper.statusFrame.title = PsyKeystoneHelper.statusFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
PsyKeystoneHelper.statusFrame.title:SetPoint("TOPRIGHT", PsyKeystoneHelper.mainFrame.TitleBg, "TOPRIGHT", -5, -3)
PsyKeystoneHelper.statusFrame.title:SetText("Status: " .. PsyKeystoneHelper:getSessionStatusString())

PsyKeystoneHelper.mainFrame:Hide()

PsyKeystoneHelper.mainFrame:SetScript("OnDragStart", function(self)
	self:StartMoving()
end)
PsyKeystoneHelper.mainFrame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
end)
PsyKeystoneHelper.mainFrame:SetScript("OnShow", function()
	PlaySound(808)
end)
PsyKeystoneHelper.mainFrame:SetScript("OnHide", function()
	PlaySound(808)
end)

function PsyKeystoneHelper:createPlayerFrame (fullPlayerName, index)
	local playerData = PsyKeystoneHelper.db.profile.keystoneCache or nil
	if playerData == nil then return end
	
	local playerFrame = CreateFrame("frame", fullPlayerName, PsyKeystoneHelper.mainFrame, "ChallengeModeBannerPartyMemberTemplate")
	playerFrame:SetFrameLevel(PsyKeystoneHelper.mainFrame:GetFrameLevel() + 2)
	
	local playerNameFontString = playerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	--playerNameFontString:SetTextColor -- todo get class colour
	playerNameFontString:SetText(playerData.name)
	playerNameFontString:SetPoint("BOTTOM", playerFrame, "BOTTOM", 0, 0)
end

--------------------------------------------------------------------------------------------------------------------------------------------
-- Dungeon Stuff
--------------------------------------------------------------------------------------------------------------------------------------------

dungeonAbbreviations = {
    ["Cinderbrew Meadery"] = "BREW",
    ["Darkflame Cleft"] = "DFC",
    ["Operation: Floodgate"] = "FLOOD",
    ["The MOTHERLODE!!"] = "ML",
    ["Priory of the Sacred Flame"] = "PSF",
    ["The Rookery"] = "ROOK",
    ["Theater of Pain"] = "TOP",
    ["Operation: Mechagon - Workshop"] = "WORK",
}

function PsyKeystoneHelper:assignHeldKeystones()
	local keystones = LibOpenRaid.GetAllKeystonesInfo()

	for _, player in pairs(PsyKeystoneHelper.db.profile.keystoneCache) do
		for unitName, keystone in pairs(keystones) do
			if UnitInParty(unitName) and  ({strsplit("-", unitName)})[1] == player.name and keystone.level > 0 then
				local mapName = C_ChallengeMode.GetMapUIInfo(keystone.challengeMapID) or ""
				local mapAbbreviation = dungeonAbbreviations[mapName] or ""
				keystone.mapName = mapName
				keystone.mapAbbreviation = mapAbbreviation
				player.keystone = keystone
				break
			end
		end
	end
end

--------------------------------------------------------------------------------------------------------------------------------------------
-- Other Init
--------------------------------------------------------------------------------------------------------------------------------------------
AceComm:RegisterComm("PsyKeyStone", HandleComm)
AceComm:RegisterComm("LRS", HandleComm)