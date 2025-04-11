local _, PsyKeystoneHelper = ...

PsyKeystoneHelper = LibStub("AceAddon-3.0"):NewAddon("PsyKeystoneHelper", "AceConsole-3.0", "AceEvent-3.0" );

--Create Minimap Button
PsyKeystoneHelperDBI = LibStub("LibDataBroker-1.1"):NewDataObject("PsyKeystoneHelperDBI", {
	type = "data source",
	text = "PsyKeystoneHelper",
	label = "PsyKeystoneHelper",
	icon = "Interface\\AddOns\\PsyKeystoneHelper\\logo",
	OnClick = function(_, buttonPressed)	
		if buttonPressed == "RightButton" then
			PsyKeystoneHelper:handleChatCommand("")
		elseif buttonPressed =="LeftButton" then
			PsyKeystoneHelper:toggleSessionStatus()
		end
	end,
	OnTooltipShow = function (tt)
		tt:AddLine("Keystone Helper")
		tt:AddLine(" ")
		tt:AddLine("Session Status: " .. PsyKeystoneHelper:getSessionStatusString())
		tt:AddLine(" ")
		tt:AddLine("Left Click: Toggle the status of the session")
		tt:AddLine("Right Click: Show commands")
	end
})

--Create vars
LibDBIcon = LibStub("LibDBIcon-1.0")
LibAceSerializer = LibStub("AceSerializer-3.0")
LibOpenRaid = LibStub("LibOpenRaid-1.0")
AceDB = LibStub("AceDB-3.0")
AceComm = LibStub("AceComm-3.0")

function PsyKeystoneHelper:OnInitialize()
	--Init db
	self.db = AceDB:New("PsyKeystoneHelper_Session",{
		profile = {
			session = false,
			keystoneCache = {},
			minimap = {
				hide = false,
			},
			frame = {
				point = "CENTER",
				relativeFrame = nil,
				relativePoint = "CENTER",
				ofsx = 0,
				ofsy = 0,
				width = 750,
				height = 400,
			}
		}
	})
	--Register slash command
	PsyKeystoneHelper:RegisterChatCommand('keyhelper', 'handleChatCommand')

	--Show minimap icon
	LibDBIcon:Register("PsyKeystoneHelperDBI", PsyKeystoneHelperDBI, self.db.profile.minimap)
	LibDBIcon:Show("PsyKeystoneHelperDBI")
	LibDBIcon:AddButtonToCompartment("PsyKeystoneHelperDBI")

	--Remind user of session state
	PsyKeystoneHelper:Print("Session is " .. PsyKeystoneHelper:getSessionStatusString())
end

function PsyKeystoneHelper:OnEnable()
end

function PsyKeystoneHelper:OnDisable()
end

function PsyKeystoneHelper:handleChatCommand(input)
	local args = {strsplit(' ', input)}

	for _, arg in ipairs(args) do
		if arg == "session" then
			PsyKeystoneHelper:toggleSessionStatus()
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
		elseif arg == "" then
		else
			PsyKeystoneHelper:Print("Unknown command")
			return
		end
	end

	PsyKeystoneHelper:Print("|cffffaeae/keyhelper|r " .. "|cffffff33session|r ".. "- Toggle the state of the session")
	PsyKeystoneHelper:Print("|cffffaeae/keyhelper|r " .. "|cffffff33request|r ".. "- Request data from the party")
	PsyKeystoneHelper:Print("|cffffaeae/keyhelper|r " .. "|cffffff33send|r ".. "- Send data to the party")
	PsyKeystoneHelper:Print("|cffffaeae/keyhelper|r " .. "|cffffff33cache|r ".. "- Print the keystone cache")
end

function PsyKeystoneHelper:toggleSessionStatus()
	if self.db.global.session then self.db.global.session = false else self.db.global.session = true end
	PsyKeystoneHelper:Print("Session is now " .. PsyKeystoneHelper:getSessionStatusString())
	LibDBIcon:Hide("PsyKeystoneHelperDBI")
	LibDBIcon:Show("PsyKeystoneHelperDBI")
	if not PsyKeystoneHelper:getSessionStatus() then 
		self.db.profile.keystoneCache = {}
		return 
	end

	PsyKeystoneHelper:requestScoreInformation()
end

function PsyKeystoneHelper:getSessionStatus()
	return self.db.global.session
end

function PsyKeystoneHelper:getSessionStatusString()
	if PsyKeystoneHelper:getSessionStatus() then
		return "\124cFF00FF00Running"
	else 
		return "\124cFFFF0000Stopped"
	end
end

function PsyKeystoneHelper:requestScoreInformation()
	PsyKeystoneHelper:Print("Requesting data from party...")
	AceComm:SendCommMessage("PsyKeyStone", LibAceSerializer:Serialize({
		type="REQUEST",
		obj={}
	}), "PARTY", UnitName("player"))
end

function PsyKeystoneHelper:receiveScoreInformation(playerData)
	PsyKeystoneHelper:Print("Received data from " .. playerData.fullName)
	if not PsyKeystoneHelper:getSessionStatus() then return end

	--Get the party's keystones and assign the keystone to the incoming player
	local keystones = LibOpenRaid.GetAllKeystonesInfo()
	for unitName, keystone in pairs(keystones) do
		if UnitInParty(unitName) and  ({strsplit("-", unitName)})[1] == playerData.name and keystone.level > 0 then
			local mapName = C_ChallengeMode.GetMapUIInfo(keystone.challengeMapID) or ""
			local mapAbbreviation = dungeonAbbreviations[mapName] or ""
			keystone.mapName = mapName
			keystone.mapAbbreviation = mapAbbreviation
			playerData.keystone = keystone
			break
		end
	end

	--Update the cache
	--DevTools_Dump(playerData)
	self.db.profile.keystoneCache[playerData.fullName] = playerData
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

	PsyKeystoneHelper:Print("Sending data to party...")
	AceComm:SendCommMessage("PsyKeyStone", LibAceSerializer:Serialize({
		type="SEND",
		obj=playerData
	}), "PARTY", UnitName("player"))
end

local function HandleComm(prefix, message, distribution, sender)
	local success ,messageObj = LibAceSerializer:Deserialize(message)
	if not success then return end
	if messageObj.type == "SEND" then
		PsyKeystoneHelper:receiveScoreInformation(messageObj.obj)
	elseif messageObj.type =="REQUEST" then
		PsyKeystoneHelper:sendScoreInformation()
	end
end

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

AceComm:RegisterComm("PsyKeyStone", HandleComm)