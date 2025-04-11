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
			PsyKeystoneHelper:requestScoreInformation()
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
		tt:AddLine("Right Click: Request score information from party")
	end
})

--Create vars
LibDBIcon = LibStub("LibDBIcon-1.0")
LibAceSerializer = LibStub("AceSerializer-3.0")
AceDB = LibStub("AceDB-3.0")
AceComm = LibStub("AceComm-3.0")
keystoneCache = {}

function PsyKeystoneHelper:OnInitialize()
	--Init db
	self.db = AceDB:New("PsyKeystoneHelper_Session",{
		profile = {
			session = false,
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
	self:Print("Session is " .. PsyKeystoneHelper:getSessionStatusString())
end

function PsyKeystoneHelper:OnEnable()
end

function PsyKeystoneHelper:OnDisable()
end

function PsyKeystoneHelper:handleChatCommand(input)
	PsyKeystoneHelper:toggleSessionStatus()
end

function PsyKeystoneHelper:toggleSessionStatus()
	if self.db.global.session then self.db.global.session = false else self.db.global.session = true end
	self:Print("Session is now " .. PsyKeystoneHelper:getSessionStatusString())
	LibDBIcon:Hide("PsyKeystoneHelperDBI")
	LibDBIcon:Show("PsyKeystoneHelperDBI")
	if not PsyKeystoneHelper:getSessionStatus() then 
		keystoneCache = {}
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
	--DevTools_Dump(playerData)
	PsyKeystoneHelper:Print("Received data from " .. playerData.name .. "-" .. playerData.realm)
	keystoneCache[playerData.name .. "-" .. playerData.realm] = playerData
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
		realm = GetRealmName("player")
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