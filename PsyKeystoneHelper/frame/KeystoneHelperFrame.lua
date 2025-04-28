local _, ns = ...

local PsyKeystoneHelper = ns.PsyKeystoneHelper
local KeystoneHelper = {}
local firstLoad = true

function KeystoneHelperFrame_OnLoad()
    PsyKeystoneHelper.KeystoneHelperFrame = KeystoneHelperFrame
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
        KeystoneHelper:createFrameComponents()
        firstLoad = false
    end

    ns:renderKeystoneHelperFrame()
end

function Button_ToggleSession_OnClick()
    PsyKeystoneHelper:toggleSessionStatus()
end

function Button_RequestData_OnClick()
    PsyKeystoneHelper:requestInformation()
end

function KeystoneHelper:createFrameComponents()
    --Setup Player Frame lookup
    KeystoneHelperFrame.playerFrames = {}
    KeystoneHelperFrame.playerFrames[1] = KeystoneHelper:createPlayerFrame(1)
    KeystoneHelperFrame.playerFrames[2] = KeystoneHelper:createPlayerFrame(2)
    KeystoneHelperFrame.playerFrames[3] = KeystoneHelper:createPlayerFrame(3)
    KeystoneHelperFrame.playerFrames[4] = KeystoneHelper:createPlayerFrame(4)
    KeystoneHelperFrame.playerFrames[5] = KeystoneHelper:createPlayerFrame(5)

    --Setup Top Keystone lookup
    KeystoneHelperFrame.topKeystones = {}
    KeystoneHelper:createTopKeysFrame()

    --Setup version check string
    KeystoneHelper.versionCheckText = PsyKeystoneHelper:createString(KeystoneHelperFrame, "GameFontHighlight", 10, "")
    KeystoneHelper.versionCheckText:SetPoint("BOTTOM", KeystoneHelperFrame, "BOTTOM", 0, 20)
    KeystoneHelper.versionCheckText:SetTextColor(1, 0, 0)
end

function ns:renderKeystoneHelperFrame()
    local profileAvailable = PsyKeystoneHelper.db ~= nil and PsyKeystoneHelper.db.profile ~= nil
    local debugMode = profileAvailable and PsyKeystoneHelper.db.profile.debugMode
    local hasData = profileAvailable and PsyKeystoneHelper.db.profile.keystoneCache ~= nil and #PsyKeystoneHelper.db.profile.keystoneCache > 0
    PsyKeystoneHelper:DebugPrint("Displaying party data...")

    --Default frames
    KeystoneHelper:defaultTopKeystones(hasData, debugMode)
    KeystoneHelper:defaultPlayerFrames(hasData, debugMode)

    --Now populate with actual data
    if hasData then
        -- Set column titles
        for _, columnTitle in pairs(KeystoneHelperFrame.headers) do
            columnTitle:SetText(columnTitle.txt)
        end

        -- Show player data
        local index = 1
        for _, playerData in pairs(PsyKeystoneHelper.db.profile.keystoneCache) do
            KeystoneHelper:populatePlayerFrame(KeystoneHelperFrame.playerFrames[index], playerData)
            index = index + 1
        end

        -- Show top keystone data
        KeystoneHelper:calculateTopKeyStones()

        -- Check received version to see if players version is out of date, if so display warning
        local higherVersionFound = false
        for _, playerData in pairs(PsyKeystoneHelper.db.profile.keystoneCache) do
            if playerData.version ~= nil and PsyKeystoneHelper:intifyVersion(playerData.version) > PsyKeystoneHelper:intifyVersion(PsyKeystoneHelper.v) then
                higherVersionFound = true
                break
            end
        end
        if higherVersionFound then
            KeystoneHelper.versionCheckText:SetText("Addon version out of date. Please download the latest update on Curseforge or Wago.")
        end
    else
        KeystoneHelper.versionCheckText:SetText("")
    end

end

function KeystoneHelper:createTopKeysFrame()
    local topKeysFrame = CreateFrame("frame", "TopKeysFrame", KeystoneHelperFrame, "")
    topKeysFrame:SetPoint("TOPLEFT", KeystoneHelperFrame, "TOPLEFT", 10, -30)
    topKeysFrame:SetSize(515, 70)

    local topKey1 = PsyKeystoneHelper:createKeystoneFrame(topKeysFrame, 60, 16)
    KeystoneHelperFrame.topKeystones[1] = topKey1
    topKey1:SetPoint("CENTER", topKeysFrame, "CENTER", -70, 0)

    local topKey2 = PsyKeystoneHelper:createKeystoneFrame(topKeysFrame, 60, 16)
    KeystoneHelperFrame.topKeystones[2] = topKey2
    topKey2:SetPoint("CENTER", topKeysFrame, "CENTER", 0, 0)

    local topKey3 = PsyKeystoneHelper:createKeystoneFrame(topKeysFrame, 60, 16)
    KeystoneHelperFrame.topKeystones[3] = topKey3
    topKey3:SetPoint("CENTER", topKeysFrame, "CENTER", 70, 0)
end

function KeystoneHelper:createPlayerFrame(index)
    --Frame
    local playerFrame = CreateFrame("frame", "player_frame" .. index, KeystoneHelperFrame, "")
    playerFrame:SetPoint("TOPLEFT", KeystoneHelperFrame, "TOPLEFT", 10, -125 - (50 * (index - 1)))
    playerFrame:SetSize(515, 50)

    --Version Indicator
    playerFrame.version = PsyKeystoneHelper:createString(playerFrame, "GameFontHighlight", 8, "X")
    playerFrame.version:SetTextColor(1, 0, 0)
    playerFrame.version:SetPoint("LEFT", playerFrame, "LEFT", 0, 0)

    --Name
    playerFrame.name = PsyKeystoneHelper:createString(playerFrame, "GameFontHighlight", 12, "Player " .. index)
    playerFrame.name:SetPoint("LEFT", playerFrame, "LEFT", 10, 5)

    --Score
    playerFrame.score = PsyKeystoneHelper:createString(playerFrame, "GameFontHighlight", 12, "Score: 0000")
    playerFrame.score:SetPoint("LEFT", playerFrame, "LEFT", 10, -5)

    --Current Key
    playerFrame.keystone = PsyKeystoneHelper:createKeystoneFrame(playerFrame, 40, 12)
    playerFrame.keystone:SetPoint("LEFT", playerFrame, "LEFT", 110, 0)
    if index == 1 then
        local keystoneColumnTitle = PsyKeystoneHelper:createString(playerFrame.keystone, "GameFontHighlight", 12, "KEY")
        keystoneColumnTitle.txt = "KEY"
        keystoneColumnTitle:SetJustifyH("CENTER")
        keystoneColumnTitle:SetPoint("TOP", playerFrame.keystone, "TOP", 0, 20)

        KeystoneHelperFrame.headers = {}
        KeystoneHelperFrame.headers["KEY"] = keystoneColumnTitle
    end

    --Dungeon Bests
    local challengeModeIDs = C_ChallengeMode.GetMapTable()
    table.sort(challengeModeIDs, function(t1, t2)
        return t1 < t2
    end)
    playerFrame.dungeonScores = {}
    for i = 1, #challengeModeIDs do
        local dungeonFrame = PsyKeystoneHelper:createKeystoneFrame(playerFrame, 40, 12)
        dungeonFrame:SetPoint("LEFT", playerFrame, "LEFT", 165 + ((i - 1) * 45), 0)
        playerFrame.dungeonScores[i] = dungeonFrame

        local mapName, _, _, texture, _ = C_ChallengeMode.GetMapUIInfo(challengeModeIDs[i])
        dungeonFrame.texture:SetTexture(texture)
        dungeonFrame.challengeModeID = challengeModeIDs[i]

        if index == 1 then
            local abbrev = PsyKeystoneHelper.dungeonAbbreviations[mapName] or ""
            local mapColumnTitle = PsyKeystoneHelper:createString(dungeonFrame, "GameFontHighlight", 12, abbrev)
            mapColumnTitle.txt = abbrev
            mapColumnTitle:SetJustifyH("CENTER")
            mapColumnTitle:SetPoint("TOP", dungeonFrame, "TOP", 0, 20)

            KeystoneHelperFrame.headers[abbrev] = mapColumnTitle
        end
    end

    return playerFrame
end

function KeystoneHelper:defaultTopKeystones(hasData, debugMode)
    for _, topKeystone in pairs(KeystoneHelperFrame.topKeystones) do
        if hasData or debugMode then
            topKeystone.topText:SetText("")
            PsyKeystoneHelper:updateColourForDungeonScore(topKeystone.topText, 0)
            topKeystone.bottomText:SetText("NONE")
            PsyKeystoneHelper:updateColourForDungeonScore(topKeystone.bottomText, 0)
            topKeystone.texture:SetTexture(237555)
            topKeystone.texture:Show()
            PsyKeystoneHelper:clearTooltip(topKeystone)
            PsyKeystoneHelper:clearClickListener(topKeystone)
        else
            topKeystone.topText:SetText("")
            PsyKeystoneHelper:updateColourForDungeonScore(topKeystone.topText, 0)
            topKeystone.bottomText:SetText("")
            PsyKeystoneHelper:updateColourForDungeonScore(topKeystone.bottomText, 0)
            topKeystone.texture:SetTexture(237555)
            topKeystone.texture:Hide()
            PsyKeystoneHelper:clearTooltip(topKeystone)
            PsyKeystoneHelper:clearClickListener(topKeystone)
        end
    end
end

function KeystoneHelper:defaultPlayerFrames(hasData, debugMode)
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
            playerFrame.name:SetTextColor(1, 1, 1)
            playerFrame.score:SetText("Score: 0000")
            PsyKeystoneHelper:updateColourForOverallScore(playerFrame.score, 0)
            playerFrame.keystone.texture:SetTexture(525134)
            playerFrame.keystone.texture:Show()
            playerFrame.keystone.texture:SetDesaturated(false)
            playerFrame.keystone.topText:SetText("+0")
            PsyKeystoneHelper:updateColourForKeyLevel(playerFrame.keystone.topText, 0)
            playerFrame.keystone.bottomText:SetText("NONE")
            PsyKeystoneHelper:clearTooltip(playerFrame.keystone)

            for _, dungeonFrame in pairs(playerFrame.dungeonScores) do
                dungeonFrame.texture:Show()
                dungeonFrame.texture:SetDesaturated(true)
                dungeonFrame.topText:SetText("+0")
                PsyKeystoneHelper:updateColourForKeyLevel(dungeonFrame.topText, 0)
                dungeonFrame.bottomText:SetText("0")
                PsyKeystoneHelper:updateColourForDungeonScore(dungeonFrame.bottomText, 0)
                PsyKeystoneHelper:clearTooltip(dungeonFrame)
            end
        else
            playerFrame.name:SetText("")
            playerFrame.name:SetTextColor(1, 1, 1)
            playerFrame.score:SetText("")
            PsyKeystoneHelper:updateColourForOverallScore(playerFrame.score, 0)
            playerFrame.keystone.texture:Hide()
            playerFrame.keystone.texture:SetDesaturated(false)
            playerFrame.keystone.topText:SetText("")
            PsyKeystoneHelper:updateColourForKeyLevel(playerFrame.keystone.topText, 0)
            playerFrame.keystone.bottomText:SetText("")
            PsyKeystoneHelper:clearTooltip(playerFrame.keystone)

            for _, dungeonFrame in pairs(playerFrame.dungeonScores) do
                dungeonFrame.texture:Hide()
                dungeonFrame.texture:SetDesaturated(true)
                dungeonFrame.topText:SetText("")
                PsyKeystoneHelper:updateColourForKeyLevel(dungeonFrame.topText, 0)
                dungeonFrame.bottomText:SetText("")
                PsyKeystoneHelper:updateColourForDungeonScore(dungeonFrame.bottomText, 0)
                PsyKeystoneHelper:clearTooltip(dungeonFrame)
            end
        end

        playerFrame.version:SetText("")
        playerFrame.version:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
            GameTooltip:ClearLines()
            GameTooltip:Show()
        end)
        playerFrame.version:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
        index = index + 1
    end
end

function KeystoneHelper:populatePlayerFrame(playerFrame, playerData)
    -- Player Name
    playerFrame.name:SetText(playerData.name)
    if playerData.classFilename ~= nil then
        local classColour = C_ClassColor.GetClassColor(playerData.classFilename)
        playerFrame.name:SetTextColor(classColour.r, classColour.g, classColour.b)
    end

    -- Player version
    KeystoneHelper:checkVersion(playerFrame.version, playerData.version)

    -- Player Score
    playerFrame.score:SetText("Score: " .. playerData.overallScore)
    PsyKeystoneHelper:updateColourForOverallScore(playerFrame.score, playerData.overallScore)

    -- Player Keystone
    if playerData.keystone == nil then
        playerFrame.keystone.texture:SetTexture([[Interface\ICONS\INV_Misc_QuestionMark]])
        playerFrame.keystone.topText:SetText("")
        playerFrame.keystone.bottomText:SetText("")
    else
        playerFrame.keystone.texture:SetTexture(playerData.keystone.texture)
        playerFrame.keystone.topText:SetText("+" .. playerData.keystone.level)
        PsyKeystoneHelper:updateColourForKeyLevel(playerFrame.keystone.topText, playerData.keystone.level)
        playerFrame.keystone.bottomText:SetText(playerData.keystone.mapAbbreviation)

        playerData.keystone.keystoneFrame = playerFrame.keystone
    end
    KeystoneHelper:addKeystoneTooltip(playerFrame.keystone, playerData.keystone)
    KeystoneHelper:addCalloutActionToKeystoneFrame(playerFrame.keystone, playerData.keystone)
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
            dungeonFrame.topText:SetTextColor(1, 1, 1)
            dungeonFrame.bottomText:SetText("")
            dungeonFrame.texture:SetDesaturated(true)
            PsyKeystoneHelper:clearTooltip(dungeonFrame)
        else
            dungeonFrame.topText:SetText("+" .. dungeonScore.level)
            PsyKeystoneHelper:updateColourForKeyLevel(dungeonFrame.topText, dungeonScore.level)
            dungeonFrame.bottomText:SetText(dungeonScore.dungeonScore)
            PsyKeystoneHelper:updateColourForDungeonScore(dungeonFrame.bottomText, dungeonScore.dungeonScore)
            dungeonFrame.texture:SetDesaturated(dungeonScore.dungeonScore == 0)
            KeystoneHelper:addDungeonBestTooltip(dungeonFrame, dungeonScore)
        end
    end

end

function KeystoneHelper:calculateTopKeyStones()
    --Update data of keystone and add to a simple table
    local keystones = {}
    for _, playerData in pairs(PsyKeystoneHelper.db.profile.keystoneCache) do
        if playerData.keystone ~= nil then
            playerData.keystone.scoreForLevel = PsyKeystoneHelper.minTimeScorePerLevels[playerData.keystone.level]
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
                    name = playerData.name,
                    classColour = C_ClassColor.GetClassColor(playerData.classFilename):GenerateHexColor(),
                    gainedScore = deltaScore
                })
            end
        end

        keystone.gainedScore = gainedScore
        table.sort(keystone.playerUpgrades, function(t1, t2)
            if t1.gainedScore ~= t2.gainedScore then
                return t1.gainedScore > t2.gainedScore
            end
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
                if rerollingGood then
                    break
                end
            end

            --Mark keystone for reroll in no gained score and rolling to another key of same level would result in score
            if rerollingGood then
                keystone.keystoneFrame.texture:SetTexture([[Interface\AddOns\PsyKeystoneHelper\img\reroll_keystone]])
            else
                keystone.keystoneFrame.topText:SetText("DEAD")
                keystone.keystoneFrame.topText:SetTextColor(1, 1, 1)
                keystone.keystoneFrame.texture:SetDesaturated(true)
            end
        end

    end

    --Sort keystone table
    table.sort(keystones, function(t1, t2)
        return t1.gainedScore > t2.gainedScore
    end)

    --Display data
    for index = 1, 3 do
        local keystone = keystones[index] or nil
        local topKeyFrame = KeystoneHelperFrame.topKeystones[index]

        if keystone ~= nil and keystone.gainedScore ~= nil and keystone.gainedScore > 0 then
            topKeyFrame.topText:SetText("+" .. keystone.level)
            PsyKeystoneHelper:updateColourForKeyLevel(topKeyFrame.topText, keystone.level)
            topKeyFrame.bottomText:SetText(keystone.gainedScore)
            PsyKeystoneHelper:updateColourForDungeonScore(topKeyFrame.bottomText, keystone.gainedScore)
            topKeyFrame.texture:SetTexture(keystone.texture)
            topKeyFrame.texture:Show()

            KeystoneHelper:addTopKeystoneTooltip(topKeyFrame, keystone)
            KeystoneHelper:addCalloutActionToKeystoneFrame(topKeyFrame, keystone)
        else
            topKeyFrame.topText:SetText("")
            PsyKeystoneHelper:updateColourForDungeonScore(topKeyFrame.topText, 0)
            topKeyFrame.bottomText:SetText("NONE")
            PsyKeystoneHelper:updateColourForDungeonScore(topKeyFrame.bottomText, 0)
            topKeyFrame.texture:SetTexture(237555)
            topKeyFrame.texture:Show()
            PsyKeystoneHelper:clearTooltip(topKeyFrame)

            KeystoneHelper:addTopKeystoneTooltip(topKeyFrame, nil)
            PsyKeystoneHelper:clearClickListener(topKeyFrame)
        end
    end
end

function KeystoneHelper:addCalloutActionToKeystoneFrame(topKeyFrame, keystone)
    if keystone ~= nil then
        topKeyFrame:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                PsyKeystoneHelper:calloutKey(keystone)
            end
        end)
    end
end

function KeystoneHelper:addTopKeystoneTooltip(topKeyFrame, keystone)
    topKeyFrame:SetScript("OnEnter", function(self)
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
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(PsyKeystoneHelper:getMouseIconTooltipMarkup("left") .. " Callout dungeon to party")
        end

        GameTooltip:Show()
    end)

    topKeyFrame:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
end

function KeystoneHelper:addKeystoneTooltip(keystoneFrame, keystone)
    keystoneFrame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
        GameTooltip:ClearLines()

        if keystone == nil then
            GameTooltip:AddLine("|cFFFF0000No keystone found|r")
        else
            GameTooltip:AddLine("|cFFFFFFFF" .. keystone.mapName .. "|r")
            GameTooltip:AddLine("Level: |c" .. C_ChallengeMode.GetKeystoneLevelRarityColor(keystone.level):GenerateHexColor() .. keystone.level .. "|r")
            GameTooltip:AddLine("Available Score: |c" .. C_ChallengeMode.GetSpecificDungeonScoreRarityColor(keystone.scoreForLevel):GenerateHexColor() .. keystone.scoreForLevel .. "|r")
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(PsyKeystoneHelper:getMouseIconTooltipMarkup("left") .. " Callout dungeon to party")
        end

        GameTooltip:Show()
    end)

    keystoneFrame:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
end

function KeystoneHelper:addDungeonBestTooltip(dungeonBestFrame, scoreInfo)
    dungeonBestFrame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
        GameTooltip:ClearLines()

        GameTooltip:AddLine("|cFFFFFFFF" .. scoreInfo.mapName .. "|r")
        GameTooltip:AddLine("Level: |c" .. C_ChallengeMode.GetKeystoneLevelRarityColor(scoreInfo.level):GenerateHexColor() .. scoreInfo.level .. "|r")
        GameTooltip:AddLine("Rating: |c" .. C_ChallengeMode.GetSpecificDungeonScoreRarityColor(scoreInfo.dungeonScore):GenerateHexColor() .. scoreInfo.dungeonScore .. "|r")

        GameTooltip:Show()
    end)
    dungeonBestFrame:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
end

function KeystoneHelper:checkVersion(versionText, playerVersion)
    local oldVersion = PsyKeystoneHelper:isOldVersion(playerVersion)

    if oldVersion then
        versionText:SetText("X")
        versionText:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
            GameTooltip:ClearLines()
            GameTooltip:AddLine("|cFFFF0000Player has older version:|r")
            GameTooltip:AddLine(playerVersion)
            GameTooltip:Show()
        end)
        versionText:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
    else
        versionText:SetText("")
        versionText:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
            GameTooltip:ClearLines()
            GameTooltip:Show()
        end)
        versionText:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
    end
end