local _, ns = ...

local PsyKeystoneHelper = ns.PsyKeystoneHelper
local firstLoad = true

function KeystoneHelperFrame_OnLoad()
	PsyKeystoneHelper.frame = KeystoneHelperFrame
	KeystoneHelperFrame:Hide()

	--Assign child frames
	KeystoneHelperFrame.title = title
	KeystoneHelperFrame.status = status
end

function KeystoneHelperFrame_OnShow()
	--Update title text
	title:SetText("Keystone Helper |cffffff33" .. PsyKeystoneHelper.v .. "|r")
	status:SetText("Status: " .. PsyKeystoneHelper:getSessionStatusString())

	if firstLoad then
		createFrameComponents()
		firstLoad = false
	end

	ns:renderData()
end

function Button_ToggleSession_OnClick()
	_G.PsyKeystoneHelper:toggleSessionStatus()
end

function Button_RequestData_OnClick()
	_G.PsyKeystoneHelper:requestInformation()
end

function createFrameComponents()
	--Setup Player Frame lookup
	KeystoneHelperFrame.playerFrames = {}
	KeystoneHelperFrame.playerFrames[1] = createPlayerFrame(1)
	KeystoneHelperFrame.playerFrames[2] = createPlayerFrame(2)
	KeystoneHelperFrame.playerFrames[3] = createPlayerFrame(3)
	KeystoneHelperFrame.playerFrames[4] = createPlayerFrame(4)
	KeystoneHelperFrame.playerFrames[5] = createPlayerFrame(5)

	--Setup Top Keystone lookup
	KeystoneHelperFrame.topKeystones = {}
	createTopKeysFrame()
end

function ns:renderData()
	local profileAvailable = PsyKeystoneHelper.db ~= nil and PsyKeystoneHelper.db.profile ~= nil
	local debugMode = profileAvailable and PsyKeystoneHelper.db.profile.debugMode
	local hasData = profileAvailable and PsyKeystoneHelper.db.profile.keystoneCache ~= nil and #PsyKeystoneHelper.db.profile.keystoneCache > 0
	PsyKeystoneHelper:DebugPrint("Displaying party data...")

	--Default frames
	defaultTopKeystones(hasData, debugMode)
	defaultPlayerFrames(hasData, debugMode)

	--Now populate with actual data
	if hasData then
		for _, columnTitle in pairs(KeystoneHelperFrame.headers) do
			columnTitle:SetText(columnTitle.txt)
		end

		local index = 1
		for _, playerData in pairs(PsyKeystoneHelper.db.profile.keystoneCache) do
			populatePlayerFrame(KeystoneHelperFrame.playerFrames[index], playerData)
			index = index + 1
		end

		calculateTopKeyStones() 
	end

end

function createString(parent, template, size, defaultText)
	local string  = parent:CreateFontString(nil, "OVERLAY", template)
	string:SetFont("Fonts/2002B.ttf", size, "OUTLINE")
	string:SetTextHeight(size)
	string:SetTextColor(1,1,1)
	string:SetText(defaultText)
	return string
end

function updateColourForKeyLevel(fontString, level)
	local levelColour = C_ChallengeMode.GetKeystoneLevelRarityColor(level) or {r=1,g=1,b=1}
	fontString:SetTextColor(levelColour.r, levelColour.g, levelColour.b)
end

function updateColourForOverallScore(fontString, overallScore)
	local scoreColour = C_ChallengeMode.GetDungeonScoreRarityColor(overallScore) or {r=1,g=1,b=1}
	fontString:SetTextColor(scoreColour.r, scoreColour.g, scoreColour.b)
end

function updateColourForDungeonScore(fontString, dungeonScore)
	local scoreColour = C_ChallengeMode.GetSpecificDungeonScoreRarityColor(dungeonScore) or {r=1,g=1,b=1}
	fontString:SetTextColor(scoreColour.r, scoreColour.g, scoreColour.b)
end

function createTopKeysFrame()
	local topKeysFrame = CreateFrame("frame", "TopKeysFrame", KeystoneHelperFrame, "")
	topKeysFrame:SetPoint("TOPLEFT", KeystoneHelperFrame, "TOPLEFT", 10, -30)
	topKeysFrame:SetSize(515, 70)

	local topKey1 = createKeystoneFrame(topKeysFrame)
	KeystoneHelperFrame.topKeystones[1] = topKey1
	topKey1:SetSize(50,50)
	topKey1:SetPoint("CENTER", topKeysFrame, "CENTER", -60, 0)

	local topKey2 = createKeystoneFrame(topKeysFrame)
	KeystoneHelperFrame.topKeystones[2] = topKey2
	topKey2:SetSize(50,50)
	topKey2:SetPoint("CENTER", topKeysFrame, "CENTER", 0, 0)

	local topKey3 = createKeystoneFrame(topKeysFrame)
	KeystoneHelperFrame.topKeystones[3] = topKey3
	topKey3:SetSize(50,50)
	topKey3:SetPoint("CENTER", topKeysFrame, "CENTER", 60, 0)
end

function createPlayerFrame(index)
	--Frame
	local playerFrame = CreateFrame("frame", "player_frame" .. index, KeystoneHelperFrame, "")
	playerFrame:SetPoint("TOPLEFT", KeystoneHelperFrame, "TOPLEFT", 10, -125  - (50 * (index - 1)))
	playerFrame:SetSize(515, 50)

	--Version Indicator
	playerFrame.version = createString(playerFrame, "GameFontHighlight", 8, "X")
	playerFrame.version:SetTextColor(1,0,0)
	playerFrame.version:SetPoint("LEFT", playerFrame, "LEFT", 0, 0)

	--Name
	playerFrame.name = createString(playerFrame, "GameFontHighlight", 12, "Player " .. index)
	playerFrame.name:SetPoint("LEFT", playerFrame, "LEFT", 10, 5)

	--Score
	playerFrame.score = createString(playerFrame, "GameFontHighlight", 12, "Score: 0000")
	playerFrame.score:SetPoint("LEFT", playerFrame, "LEFT", 10, -5)

	--Current Key
	playerFrame.keystone = createKeystoneFrame(playerFrame)
	playerFrame.keystone:SetPoint("LEFT", playerFrame, "LEFT", 110, 0)
	if index == 1 then
		local keystoneColumnTitle = createString(playerFrame.keystone, "GameFontHighlight", 12, "KEY")
		keystoneColumnTitle.txt = "KEY"
		keystoneColumnTitle:SetJustifyH("CENTER")
		keystoneColumnTitle:SetPoint("TOP", playerFrame.keystone, "TOP", 0, 20)

		KeystoneHelperFrame.headers = {}
		KeystoneHelperFrame.headers["KEY"] = keystoneColumnTitle
	end

	--Dungeon Bests
	local challengeModeIDs = C_ChallengeMode.GetMapTable()
	table.sort(challengeModeIDs, function(t1, t2) return t1 < t2 end)
	playerFrame.dungeonScores = {}
	for i = 1, #challengeModeIDs do 
		local dungeonFrame = createKeystoneFrame(playerFrame)
		dungeonFrame:SetPoint("LEFT", playerFrame, "LEFT", 165 + ((i - 1) * 45), 0)
		playerFrame.dungeonScores[i] = dungeonFrame

		local mapName, mapID, _, texture, backgroundTexture = C_ChallengeMode.GetMapUIInfo(challengeModeIDs[i])
		dungeonFrame.texture:SetTexture(texture)
		dungeonFrame.challengeModeID = challengeModeIDs[i]

		if index == 1 then
			local abbrev = ns.dungeonAbbreviations[mapName] or ""
			local mapColumnTitle = createString(dungeonFrame, "GameFontHighlight", 12, abbrev)
			mapColumnTitle.txt = abbrev
			mapColumnTitle:SetJustifyH("CENTER")
			mapColumnTitle:SetPoint("TOP", dungeonFrame, "TOP", 0, 20)

			KeystoneHelperFrame.headers[abbrev] = mapColumnTitle
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

function defaultTopKeystones(hasData, debugMode) 
	for _, topKeystone in pairs(KeystoneHelperFrame.topKeystones) do
		if hasData or debugMode then
			topKeystone.topText:SetText("")
			updateColourForDungeonScore(topKeystone.topText, 0)
			topKeystone.bottomText:SetText("NONE")
			updateColourForDungeonScore(topKeystone.bottomText, 0)
			topKeystone.texture:SetTexture(237555)
			topKeystone.texture:Show()
			clearTooltip(topKeystone)
		else
			topKeystone.topText:SetText("")
			updateColourForDungeonScore(topKeystone.topText, 0)
			topKeystone.bottomText:SetText("")
			updateColourForDungeonScore(topKeystone.bottomText, 0)
			topKeystone.texture:SetTexture(237555)
			topKeystone.texture:Hide()
			clearTooltip(topKeystone)
		end
	end
end

function defaultPlayerFrames(hasData, debugMode)
	local index = 1

	--Display column titles
	if hasData or debugMode then
		for _, columnTitle in pairs(KeystoneHelperFrame.headers) do
			columnTitle:SetText(columnTitle.txt)
		end
	else
		for _, columnTitle in pairs(KeystoneHelperFrame.headers) do
			columnTitle:SetText("")
		end
	end

	--Display player frames
	for _, playerFrame in pairs(KeystoneHelperFrame.playerFrames) do
		if PsyKeystoneHelper.db ~= nil and PsyKeystoneHelper.db.profile.debugMode then
			playerFrame.name:SetText("Player_____" .. index)
			playerFrame.name:SetTextColor(1,1,1)
			playerFrame.score:SetText("Score: 0000")
			updateColourForOverallScore(playerFrame.score, 0)
			playerFrame.keystone.texture:SetTexture(525134)
			playerFrame.keystone.texture:Show()
			playerFrame.keystone.texture:SetDesaturated(false)
			playerFrame.keystone.topText:SetText("+0")
			updateColourForKeyLevel(playerFrame.keystone.topText, 0)
			playerFrame.keystone.bottomText:SetText("NONE")
			clearTooltip(playerFrame.keystone)

			for _, dungeonFrame in pairs(playerFrame.dungeonScores) do
				dungeonFrame.texture:Show()
				dungeonFrame.texture:SetDesaturated(true)
				dungeonFrame.topText:SetText("+0")
				updateColourForKeyLevel(dungeonFrame.topText, 0)
				dungeonFrame.bottomText:SetText("0")
				updateColourForDungeonScore(dungeonFrame.bottomText, 0)
				clearTooltip(dungeonFrame)
			end
		else
			playerFrame.name:SetText("")
			playerFrame.name:SetTextColor(1,1,1)
			playerFrame.score:SetText("")
			updateColourForOverallScore(playerFrame.score, 0)
			playerFrame.keystone.texture:Hide()
			playerFrame.keystone.texture:SetDesaturated(false)
			playerFrame.keystone.topText:SetText("")
			updateColourForKeyLevel(playerFrame.keystone.topText, 0)
			playerFrame.keystone.bottomText:SetText("")
			clearTooltip(playerFrame.keystone)

			for _, dungeonFrame in pairs(playerFrame.dungeonScores) do
				dungeonFrame.texture:Hide()
				dungeonFrame.texture:SetDesaturated(true)
				dungeonFrame.topText:SetText("")
				updateColourForKeyLevel(dungeonFrame.topText, 0)
				dungeonFrame.bottomText:SetText("")
				updateColourForDungeonScore(dungeonFrame.bottomText, 0)
				clearTooltip(dungeonFrame)
			end
		end

		playerFrame.version:SetText("")
		playerFrame.version:SetScript("OnEnter", function (self)
			GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
			GameTooltip:ClearLines()
			GameTooltip:Show()
		end)
		playerFrame.version:SetScript("OnLeave", function (self)
			GameTooltip:Hide()
		end)
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

	-- Player version
	checkVersion(playerFrame.version, playerData.version)

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

		playerData.keystone.keystoneFrame = playerFrame.keystone
	end
	addKeystoneTooltip(playerFrame.keystone, playerData.keystone)
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
			clearTooltip(dungeonFrame)
		else
			dungeonFrame.topText:SetText("+" .. dungeonScore.level)
			updateColourForKeyLevel(dungeonFrame.topText, dungeonScore.level)
			dungeonFrame.bottomText:SetText(dungeonScore.dungeonScore)
			updateColourForDungeonScore(dungeonFrame.bottomText, dungeonScore.dungeonScore)
			dungeonFrame.texture:SetDesaturated(dungeonScore.dungeonScore == 0) 
			addDungeonBestTooltip(dungeonFrame, dungeonScore)
		end		
	end

end

function calculateTopKeyStones() 
	--Update data of keystone and add to a simple table
	local keystones = {}
	for _, playerData in pairs(PsyKeystoneHelper.db.profile.keystoneCache) do
		if playerData.keystone ~= nil then
			playerData.keystone.scoreForLevel = ns.minTimeScorePerLevels[playerData.keystone.level]
			playerData.keystone.owner = playerData.name
			playerData.keystone.ownerClassColour = C_ClassColor.GetClassColor(playerData.classFilename):GenerateHexColor()
			table.insert(keystones, playerData.keystone)
		end
	end

	--Apply gained score to each keystone
	for _, keystone in pairs(keystones) do
		local gainedScore = 0
		keystone.playerUpgrades = {}

		for _, playerData in pairs(PsyKeystoneHelper.db.profile.keystoneCache) do
			--Get dungeon score for player
			local dungeonScore = 0
			for _, dungeonInfo in pairs(playerData.scoreInfo) do
				if dungeonInfo.mapChallengeModeID == keystone.mapChallengeModeID then
					dungeonScore = dungeonInfo.dungeonScore
					break
				end
			end

			--Get the score delta
			local deltaScore = keystone.scoreForLevel - dungeonScore
			if deltaScore > 0 then
				gainedScore = gainedScore + deltaScore
				table.insert(keystone.playerUpgrades, {
					name=playerData.name,
					classColour= C_ClassColor.GetClassColor(playerData.classFilename):GenerateHexColor(),
					gainedScore=deltaScore
				})
			end
		end

		keystone.gainedScore = gainedScore
		table.sort(keystone.playerUpgrades, function (t1, t2) 
			if t1.gainedScore ~= t2.gainedScore then return t1.gainedScore > t2.gainedScore  end
			return t1.name < t2.name 
		end)

		--If key has no score gain...
		if gainedScore == 0 then
			local rerollingGood = false
			for _, playerData in pairs(PsyKeystoneHelper.db.profile.keystoneCache) do
				for _, dungeonInfo in pairs(playerData.scoreInfo) do
					if dungeonInfo.dungeonScore < keystone.scoreForLevel then
						rerollingGood = true
						break
					end
				end
				if rerollingGood then break end
			end

			--Mark keystone for reroll in no gained score and rolling to another key of same level would result in score
			if rerollingGood then
				keystone.keystoneFrame.texture:SetTexture([[Interface\AddOns\PsyKeystoneHelper\reroll_keystone]])
			else
				keystone.keystoneFrame.topText:SetText("DEAD")
				keystone.keystoneFrame.topText:SetTextColor(1,1,1)
				keystone.keystoneFrame.texture:SetDesaturated(true)
			end
		end

	end

	--Sort keystone table
	table.sort(keystones, function (t1, t2) return t1.gainedScore > t2.gainedScore end)

	--Display data
	for index = 1, 3 do 
		local keystone = keystones[index] or nil
		local topKeyFrame = KeystoneHelperFrame.topKeystones[index]

		if keystone ~= nil and keystone.gainedScore ~= nil and keystone.gainedScore > 0 then 
			topKeyFrame.topText:SetText("+" .. keystone.level)
			updateColourForKeyLevel(topKeyFrame.topText, keystone.level)
			topKeyFrame.bottomText:SetText(keystone.gainedScore)
			updateColourForDungeonScore(topKeyFrame.bottomText, keystone.gainedScore)
			topKeyFrame.texture:SetTexture(keystone.texture)
			topKeyFrame.texture:Show()

			addTopKeystoneTooltip(topKeyFrame, keystone)
		else
			topKeyFrame.topText:SetText("")
			updateColourForDungeonScore(topKeyFrame.topText, 0)
			topKeyFrame.bottomText:SetText("NONE")
			updateColourForDungeonScore(topKeyFrame.bottomText, 0)
			topKeyFrame.texture:SetTexture(237555)
			topKeyFrame.texture:Show()
			clearTooltip(topKeyFrame)

			addTopKeystoneTooltip(topKeyFrame, nil)
		end
	end
end

function clearTooltip(frame)
	frame:SetScript("OnEnter", function (self)
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
		GameTooltip:ClearLines()
		GameTooltip:Hide()
	end)
	frame:SetScript("OnLeave", function (self)
		GameTooltip:Hide()
	end)
end

function addTopKeystoneTooltip(topKeyFrame, keystone)
	topKeyFrame:SetScript("OnEnter", function (self)
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
		GameTooltip:ClearLines()

		if keystone == nil then
			GameTooltip:AddLine("|cFFFF0000No upgrade found :(|r")
		else
			GameTooltip:AddLine("|cFFFFFFFF" .. keystone.mapName .. "|r")
			GameTooltip:AddLine("Level: |c" .. C_ChallengeMode.GetKeystoneLevelRarityColor(keystone.level):GenerateHexColor() .. keystone.level .. "|r")
			GameTooltip:AddLine("Owner: |c" .. keystone.ownerClassColour .. keystone.owner .. "|r")
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine("Total Rating Gained: |cFFFFFFFF" .. keystone.gainedScore .. "|r")
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine("Player Rating Gained:")
			for _, player in pairs(keystone.playerUpgrades) do
				GameTooltip:AddLine("|c" .. player.classColour .. player.name .. "|r: |cFFFFFFFF" .. player.gainedScore .. "|r")
			end
		end

		GameTooltip:Show()
	end)

	topKeyFrame:SetScript("OnLeave", function (self)
		GameTooltip:Hide()
	end)
end

function addKeystoneTooltip(keystoneFrame, keystone)
	keystoneFrame:SetScript("OnEnter", function (self)
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
		GameTooltip:ClearLines()

		if keystone == nil then
			GameTooltip:AddLine("|cFFFF0000No keystone found|r")
		else
			GameTooltip:AddLine("|cFFFFFFFF" .. keystone.mapName .. "|r")
			GameTooltip:AddLine("Level: |c" .. C_ChallengeMode.GetKeystoneLevelRarityColor(keystone.level):GenerateHexColor() .. keystone.level .. "|r")
			GameTooltip:AddLine("Available Score: |c" ..  C_ChallengeMode.GetSpecificDungeonScoreRarityColor(keystone.scoreForLevel):GenerateHexColor() .. keystone.scoreForLevel .. "|r")
		end

		GameTooltip:Show()
	end)

	keystoneFrame:SetScript("OnLeave", function (self)
		GameTooltip:Hide()
	end)
end

function addDungeonBestTooltip(dungeonBestFrame, scoreInfo)
	dungeonBestFrame:SetScript("OnEnter", function (self)
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
		GameTooltip:ClearLines()

		GameTooltip:AddLine("|cFFFFFFFF" .. scoreInfo.mapName .. "|r")
		GameTooltip:AddLine("Level: |c" .. C_ChallengeMode.GetKeystoneLevelRarityColor(scoreInfo.level):GenerateHexColor() .. scoreInfo.level .. "|r")
		GameTooltip:AddLine("Rating: |c" .. C_ChallengeMode.GetSpecificDungeonScoreRarityColor(scoreInfo.dungeonScore):GenerateHexColor() .. scoreInfo.dungeonScore .. "|r")
		
		GameTooltip:Show()
	end)
	dungeonBestFrame:SetScript("OnLeave", function (self)
		GameTooltip:Hide()
	end)
end

function checkVersion(versionText, playerVersion)
	local oldVersion = intifyVersion(playerVersion) < intifyVersion(PsyKeystoneHelper.v)

	if oldVersion then
		versionText:SetText("X")
		versionText:SetScript("OnEnter", function (self)
			GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
			GameTooltip:ClearLines()
			GameTooltip:AddLine("|cFFFF0000Player has older version:|r")
			GameTooltip:AddLine(playerVersion)
			GameTooltip:Show()
		end)
		versionText:SetScript("OnLeave", function (self)
			GameTooltip:Hide()
		end)
	else
		versionText:SetText("")
		versionText:SetScript("OnEnter", function (self)
			GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
			GameTooltip:ClearLines()
			GameTooltip:Show()
		end)
		versionText:SetScript("OnLeave", function (self)
			GameTooltip:Hide()
		end)
	end
end

function intifyVersion(versionString)
	if versionString == nil or versionString == "" then
		return 0
	end

	local versionInt = string.gsub(versionString, "%.", "")
	if string.find(versionInt, "-beta") then
		versionInt = string.gsub(versionInt, "-beta", "2")
	elseif string.find(versionInt, "-alpha") then
		versionInt = string.gsub(versionInt, "-alpha", "1")
	else
		versionInt = versionInt .. "3"
	end
	return tonumber(versionInt)
end