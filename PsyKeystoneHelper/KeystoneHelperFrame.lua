local _, ns = ...

local PsyKeystoneHelper = ns.PsyKeystoneHelper

function KeystoneHelperFrame_OnLoad()
	PsyKeystoneHelper.frame = KeystoneHelperFrame
	KeystoneHelperFrame:Hide()

	--Assign child frames
	KeystoneHelperFrame.title = title
	KeystoneHelperFrame.status = status

	--Setup Player Frame lookup
	KeystoneHelperFrame.playerFrames = {}
	KeystoneHelperFrame.playerFrames[1] = createPlayerFrame(1)
	KeystoneHelperFrame.playerFrames[2] = createPlayerFrame(2)
	KeystoneHelperFrame.playerFrames[3] = createPlayerFrame(3)
	KeystoneHelperFrame.playerFrames[4] = createPlayerFrame(4)
	KeystoneHelperFrame.playerFrames[5] = createPlayerFrame(5)

	--Setup Top Keystone lookup
	KeystoneHelperFrame.topKeystones = {}
	--Set defaults
	KeystoneHelperFrame_OnShow()
end

function KeystoneHelperFrame_OnShow()
	--Update title text
	title:SetText("Keystone Helper |cffffff33" .. PsyKeystoneHelper.v .. "|r")
	status:SetText("Status: " .. PsyKeystoneHelper:getSessionStatusString())

	ns:displayPartyData()
end

function Button_ToggleSession_OnClick()
	_G.PsyKeystoneHelper:toggleSessionStatus()
end

function Button_RequestData_OnClick()
	_G.PsyKeystoneHelper:requestInformation()
end

function ns:displayPartyData()
	PsyKeystoneHelper:DebugPrint("Displaying party data...")

	--Default frames
	defaultFrame()

	--Now populate with actual data
	if PsyKeystoneHelper.db ~= nil then
		local index = 1
		for _, playerData in pairs(PsyKeystoneHelper.db.profile.keystoneCache) do
			populatePlayerFrame(KeystoneHelperFrame.playerFrames[index], playerData)
			index = index + 1
		end
	end
end

function createString(parent, template, size, defaultText)
	local string  = parent:CreateFontString(nil, "OVERLAY", template)
	string:SetFont("Fonts\2002B.ttf", size, "OUTLINE")
	string:SetTextHeight(size)
	string:SetTextColor(1,1,1)
	string:SetText(defaultText)
	return string
end

function updateColourForKeyLevel(fontString, level)
	local levelColour = C_ChallengeMode.GetKeystoneLevelRarityColor(level)
	fontString:SetTextColor(levelColour.r, levelColour.g, levelColour.b)
end

function updateColourForOverallScore(fontString, overallScore)
	local scoreColour = C_ChallengeMode.GetDungeonScoreRarityColor(overallScore)
	fontString:SetTextColor(scoreColour.r, scoreColour.g, scoreColour.b)
end

function updateColourForDungeonScore(fontString, dungeonScore)
	local scoreColour = C_ChallengeMode.GetDungeonScoreRarityColor(dungeonScore * 10)
	fontString:SetTextColor(scoreColour.r, scoreColour.g, scoreColour.b)
end

function createDungeonNameFrame() 
	local dungeonNameFrame = CreateFrame("frame", nil, KeystoneHelperFrame, "")
	dungeonNameFrame:SetPoint("TOPLEFT", KeystoneHelperFrame, "TOPLEFT", 10, -75)
	dungeonNameFrame:SetSize(515, 20)

	-- Key
	local keyName = createString(dungeonNameFrame, "GameFontHighlight", 12, "KEY")
	keyName:SetPoint("LEFT", dungeonNameFrame, "LEFT", 90, 0)

	-- Dungeon Names
	local challengeModeIDs = C_ChallengeMode.GetMapTable()
	for index = 1, #challengeModeIDs do 
		local dungeonText = createString(dungeonNameFrame, "GameFontHighlight", 12, "")
		dungeonText:SetJustifyH("CENTER")
		dungeonText:SetPoint("LEFT", dungeonNameFrame, "LEFT", 145 + ((index - 1) * 45), 0)

		local mapName, mapID, _, texture, backgroundTexture = C_ChallengeMode.GetMapUIInfo(challengeModeIDs[index])
		dungeonText:SetText(ns.dungeonAbbreviations[mapName] or "")
	end
end

function createPlayerFrame(index)
	--Frame
	local playerFrame = CreateFrame("frame", "player_frame" .. index, KeystoneHelperFrame, "")
	playerFrame:SetPoint("TOPLEFT", KeystoneHelperFrame, "TOPLEFT", 10, -95  - (50 * (index - 1)))
	playerFrame:SetSize(515, 50)

	--Name
	playerFrame.name = createString(playerFrame, "GameFontHighlight", 12, "Player " .. index)
	playerFrame.name:SetPoint("LEFT", playerFrame, "LEFT", 10, 5)

	--Score
	playerFrame.score = createString(playerFrame, "GameFontHighlight", 12, "Score: 0000")
	playerFrame.score:SetPoint("LEFT", playerFrame, "LEFT", 10, -5)

	--Current Key
	playerFrame.keystone = createKeystoneFrame(playerFrame)
	playerFrame.keystone:SetPoint("LEFT", playerFrame, "LEFT", 90, 0)
	if index == 1 then
		local keystoneColumnTitle = createString(playerFrame.keystone, "GameFontHighlight", 12, "KEY")
		keystoneColumnTitle:SetJustifyH("CENTER")
		keystoneColumnTitle:SetPoint("TOP", playerFrame.keystone, "TOP", 0, 20)
	end

	--Dungeon Bests
	local challengeModeIDs = C_ChallengeMode.GetMapTable()
	playerFrame.dungeonScores = {}
	for i = 1, #challengeModeIDs do 
		local dungeonFrame = createKeystoneFrame(playerFrame)
		dungeonFrame:SetPoint("LEFT", playerFrame, "LEFT", 145 + ((i - 1) * 45), 0)
		playerFrame.dungeonScores[i] = dungeonFrame

		local mapName, mapID, _, texture, backgroundTexture = C_ChallengeMode.GetMapUIInfo(challengeModeIDs[i])
		dungeonFrame.texture:SetTexture(texture)
		dungeonFrame.challengeModeID = challengeModeIDs[i]

		if index == 1 then
			local abbrev = ns.dungeonAbbreviations[mapName] or ""
			local mapColumnTitle = createString(dungeonFrame, "GameFontHighlight", 12, abbrev)
			mapColumnTitle:SetJustifyH("CENTER")
			mapColumnTitle:SetPoint("TOP", dungeonFrame, "TOP", 0, 20)
		end
	end

	return playerFrame
end

function createKeystoneFrame(parent)
	local keystoneFrame = CreateFrame("frame", nil, parent, "")
	keystoneFrame:SetSize(40,40)

	keystoneFrame.texture = keystoneFrame:CreateTexture()
	keystoneFrame.texture:SetTexture([[Interface\ICONS\INV_Misc_QuestionMark]])
	keystoneFrame.texture:SetAllPoints(keystoneFrame)

	keystoneFrame.topText = createString(keystoneFrame, "GameFontNormalMed2Outline", 12, "")
	keystoneFrame.topText:SetPoint("TOP", keystoneFrame, "TOP", 0, 0)

	keystoneFrame.bottomText = createString(keystoneFrame, "GameFontNormalMed2Outline", 12, "")
	keystoneFrame.bottomText:SetPoint("BOTTOM", keystoneFrame, "BOTTOM", 1, 0)

	return keystoneFrame
end

function defaultFrame() 
	defaultTopKeystones()
	defaultPlayerFrames()
end

function defaultTopKeystones() 
	--for _, topKeystone in pairs(KeystoneHelperFrame.topKeystones) do
	--	topKeystone.topText:SetText("")
	--	topKeystone.bottomText:SetText("NONE")
	--	topKeystone.texture:SetTexture([[Interface\ICONS\INV_Misc_QuestionMark]])
	--end
end

function defaultPlayerFrames()
	local index = 1
	for _, playerFrame in pairs(KeystoneHelperFrame.playerFrames) do
		if PsyKeystoneHelper.db ~= nil and PsyKeystoneHelper.db.profile.debugMode then
			playerFrame.name:SetText("Player" .. index)
			playerFrame.name:SetTextColor(1,1,1)
			playerFrame.score:SetText("Score: 0000")
			updateColourForOverallScore(playerFrame.score, 0)
			playerFrame.keystone.texture:SetTexture([[Interface\ICONS\INV_Misc_QuestionMark]])
			playerFrame.keystone.texture:Show()
			playerFrame.keystone.topText:SetText("+0")
			updateColourForKeyLevel(playerFrame.keystone.topText, 0)
			playerFrame.keystone.bottomText:SetText("NONE")

			for _, dungeonFrame in pairs(playerFrame.dungeonScores) do
				dungeonFrame.texture:Show()
				dungeonFrame.texture:SetDesaturated(true)
				dungeonFrame.topText:SetText("+0")
				updateColourForKeyLevel(dungeonFrame.topText, 0)
				dungeonFrame.bottomText:SetText("0")
				updateColourForDungeonScore(dungeonFrame.bottomText, 0)
			end
		else
			playerFrame.name:SetText("")
			playerFrame.name:SetTextColor(1,1,1)
			playerFrame.score:SetText("")
			updateColourForOverallScore(playerFrame.score, 0)
			playerFrame.keystone.texture:Hide()
			playerFrame.keystone.topText:SetText("")
			updateColourForKeyLevel(playerFrame.keystone.topText, 0)
			playerFrame.keystone.bottomText:SetText("")

			for _, dungeonFrame in pairs(playerFrame.dungeonScores) do
				dungeonFrame.texture:Hide()
				dungeonFrame.texture:SetDesaturated(true)
				dungeonFrame.topText:SetText("")
				updateColourForKeyLevel(dungeonFrame.topText, 0)
				dungeonFrame.bottomText:SetText("")
				updateColourForDungeonScore(dungeonFrame.bottomText, 0)
			end
		end
		index = index + 1
	end
end

function populatePlayerFrame(playerFrame, playerData)
	-- Player Name
	playerFrame.name:SetText(playerData.name)
	if playerData.classFilename ~= nil then
		local classColour = C_ClassColor.GetClassColor(playerData.classFilename)
		playerFrame.name:SetTextColor(classColour.r,classColour.g,classColour.b)
	end

	-- Player Score
	playerFrame.score:SetText("Score: " .. playerData.overallScore)
	updateColourForOverallScore(playerFrame.score, playerData.overallScore)

	-- Player Keystone
	if playerData.keystone == nil then
		playerFrame.keystone.texture:SetTexture([[Interface\ICONS\INV_Misc_QuestionMark]])
		playerFrame.keystone.topText:SetText("")
		playerFrame.keystone.bottomText:SetText("")
	else
		playerFrame.keystone.texture:SetTexture(playerData.keystone.texture)
		playerFrame.keystone.topText:SetText("+" ..playerData.keystone.level)
		updateColourForKeyLevel(playerFrame.keystone.topText, playerData.keystone.level)
		playerFrame.keystone.bottomText:SetText(playerData.keystone.mapAbbreviation)
	end
	playerFrame.keystone.texture:Show()

	-- Player Dungeon Score
	for _, dungeonFrame in pairs(playerFrame.dungeonScores) do
		dungeonFrame.texture:Show()

		local dungeonScore = nil
		for _, scoreInfo in pairs(playerData.scoreInfo) do
			if scoreInfo.mapChallengeModeID == dungeonFrame.challengeModeID then
				dungeonScore = scoreInfo
				break
			end
		end

		if dungeonScore == nil then
			dungeonFrame.topText:SetText("")
			dungeonFrame.topText:SetTextColor(1,1,1)
			dungeonFrame.bottomText:SetText("")
			dungeonFrame.texture:SetDesaturated(true)
		else
			dungeonFrame.topText:SetText("+" .. dungeonScore.level)
			updateColourForKeyLevel(dungeonFrame.topText, dungeonScore.level)
			dungeonFrame.bottomText:SetText(dungeonScore.dungeonScore)
			updateColourForDungeonScore(dungeonFrame.bottomText, dungeonScore.dungeonScore)
			dungeonFrame.texture:SetDesaturated(dungeonScore.dungeonScore == 0) 
		end
	end

end