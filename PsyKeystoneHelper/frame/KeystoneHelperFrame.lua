local _, ns = ...

local PsyKeystoneHelper = ns.PsyKeystoneHelper
local KeystoneHelper = {}
local firstLoad = true

function PKH_KeystoneHelperFrame_OnLoad()
    PsyKeystoneHelper.KeystoneHelperFrame = PKH_KeystoneHelperFrame
    PKH_KeystoneHelperFrame:Hide()

    --Assign child frames
    PKH_KeystoneHelperFrame.title = title
    PKH_KeystoneHelperFrame.status = status
end

function PKH_KeystoneHelperFrame_OnShow()
    --Update title text
    title:SetText("Keystone Helper |cffffff33" .. PsyKeystoneHelper.v .. "|r")
    status:SetText("Status: " .. PsyKeystoneHelper:getSessionStatusString())

    if firstLoad then
        KeystoneHelper:createFrameComponents()
        firstLoad = false
    end

    ns:renderKeystoneHelperFrame()
end

function PKH_Button_ToggleSession_OnClick()
    PsyKeystoneHelper:toggleSessionStatus()
end

function PKH_Button_RequestData_OnClick()
    PsyKeystoneHelper:requestInformation()
end

function KeystoneHelper:createFrameComponents()
    --Setup Player Frame lookup
    PKH_KeystoneHelperFrame.playerFrames = {}
    PKH_KeystoneHelperFrame.playerFrames[1] = KeystoneHelper:createPlayerFrame(1)
    PKH_KeystoneHelperFrame.playerFrames[2] = KeystoneHelper:createPlayerFrame(2)
    PKH_KeystoneHelperFrame.playerFrames[3] = KeystoneHelper:createPlayerFrame(3)
    PKH_KeystoneHelperFrame.playerFrames[4] = KeystoneHelper:createPlayerFrame(4)
    PKH_KeystoneHelperFrame.playerFrames[5] = KeystoneHelper:createPlayerFrame(5)

    --Setup Top Keystone lookup
    PKH_KeystoneHelperFrame.topKeystones = {}
    KeystoneHelper:createTopKeysFrame()

    --Setup version check string
    KeystoneHelper.versionCheckText = PsyKeystoneHelper:createString(PKH_KeystoneHelperFrame, "GameFontHighlight", 10, "")
    KeystoneHelper.versionCheckText:SetPoint("BOTTOM", PKH_KeystoneHelperFrame, "BOTTOM", 0, -20)
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
        for _, columnTitle in pairs(PKH_KeystoneHelperFrame.headers) do
            columnTitle:SetText(columnTitle.txt)
        end

        -- Show player data
        local index = 1
        for _, playerData in pairs(PsyKeystoneHelper.db.profile.keystoneCache) do
            KeystoneHelper:populatePlayerFrame(PKH_KeystoneHelperFrame.playerFrames[index], playerData)
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
            KeystoneHelper.versionCheckText:SetText("Out of date version detected. Please download the latest update on Curseforge or Wago.")
        end
    else
        KeystoneHelper.versionCheckText:SetText("")
    end

end

function KeystoneHelper:createTopKeysFrame()
    local topKeysFrame = CreateFrame("frame", "TopKeysFrame", PKH_KeystoneHelperFrame, "")
    topKeysFrame:SetPoint("TOPLEFT", PKH_KeystoneHelperFrame, "TOPLEFT", 10, -30)
    topKeysFrame:SetSize(515, 70)

    local topKey1 = PsyKeystoneHelper:createKeystoneFrame(topKeysFrame, 60, 16)
    PKH_KeystoneHelperFrame.topKeystones[1] = topKey1
    topKey1:SetPoint("CENTER", topKeysFrame, "CENTER", -70, 0)

    local topKey2 = PsyKeystoneHelper:createKeystoneFrame(topKeysFrame, 60, 16)
    PKH_KeystoneHelperFrame.topKeystones[2] = topKey2
    topKey2:SetPoint("CENTER", topKeysFrame, "CENTER", 0, 0)

    local topKey3 = PsyKeystoneHelper:createKeystoneFrame(topKeysFrame, 60, 16)
    PKH_KeystoneHelperFrame.topKeystones[3] = topKey3
    topKey3:SetPoint("CENTER", topKeysFrame, "CENTER", 70, 0)
end

function KeystoneHelper:createPlayerFrame(index)
    --Frame
    local playerFrame = CreateFrame("frame", "player_frame" .. index, PKH_KeystoneHelperFrame, "")
    playerFrame:SetPoint("TOPLEFT", PKH_KeystoneHelperFrame, "TOPLEFT", 10, -125 - (50 * (index - 1)))
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

        PKH_KeystoneHelperFrame.headers = {}
        PKH_KeystoneHelperFrame.headers["KEY"] = keystoneColumnTitle
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

            PKH_KeystoneHelperFrame.headers[abbrev] = mapColumnTitle
        end
    end

    return playerFrame
end

function KeystoneHelper:defaultTopKeystones(hasData, debugMode)
    for _, topKeystone in pairs(PKH_KeystoneHelperFrame.topKeystones) do
        if hasData or debugMode then
            topKeystone.setTopKeystone(nil)
            topKeystone.texture:Show()
        else
            topKeystone.setTopKeystone(nil)
            topKeystone.bottomText:SetText("")
            topKeystone.texture:Hide()
        end
    end
end

function KeystoneHelper:defaultPlayerFrames(hasData, debugMode)
    local index = 1

    --Display column titles
    if hasData or debugMode then
        for _, columnTitle in pairs(PKH_KeystoneHelperFrame.headers) do
            columnTitle:SetText(columnTitle.txt)
        end
    else
        for _, columnTitle in pairs(PKH_KeystoneHelperFrame.headers) do
            columnTitle:SetText("")
        end
    end

    --Display player frames
    for _, playerFrame in pairs(PKH_KeystoneHelperFrame.playerFrames) do
        if PsyKeystoneHelper.db ~= nil and PsyKeystoneHelper.db.profile.debugMode then
            playerFrame.name:SetText("Player_____" .. index)
            playerFrame.name:SetTextColor(1, 1, 1)
            playerFrame.score:SetText("Score: 0000")
            PsyKeystoneHelper:updateColourForOverallScore(playerFrame.score, 0)
            playerFrame.keystone.texture:Show()
            playerFrame.keystone.setKeystone({
                texture = 525134,
                level = 0,
                mapAbbreviation = "NONE",
            })

            for _, dungeonFrame in pairs(playerFrame.dungeonScores) do
                dungeonFrame.texture:Show()
                dungeonFrame.setDungeonBest({
                    dungeonScore = 0,
                    level = 0
                })
            end
        else
            playerFrame.name:SetText("")
            playerFrame.name:SetTextColor(1, 1, 1)
            playerFrame.score:SetText("")
            PsyKeystoneHelper:updateColourForOverallScore(playerFrame.score, 0)
            playerFrame.keystone.setKeystone(nil)
            playerFrame.keystone.texture:Hide()

            for _, dungeonFrame in pairs(playerFrame.dungeonScores) do
                dungeonFrame.texture:Hide()
                dungeonFrame.setDungeonBest(nil)
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
    playerFrame.keystone.setKeystone(playerData.keystone)
    playerFrame.keystone.texture:Show()
    KeystoneHelper:addKeystoneTooltip(playerFrame.keystone, playerData.keystone)
    KeystoneHelper:addCalloutActionToKeystoneFrame(playerFrame.keystone, playerData.keystone)

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

        dungeonFrame.setDungeonBest(dungeonScore)
        KeystoneHelper:addDungeonBestTooltip(dungeonFrame, dungeonScore)
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
                keystone.keystoneFrame.markReroll()
            else
                keystone.keystoneFrame.markDead()
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
        local topKeyFrame = PKH_KeystoneHelperFrame.topKeystones[index]

        if keystone ~= nil and keystone.gainedScore ~= nil and keystone.gainedScore > 0 then
            topKeyFrame.setTopKeystone(keystone)
            topKeyFrame.texture:Show()

            KeystoneHelper:addTopKeystoneTooltip(topKeyFrame, keystone)
            KeystoneHelper:addCalloutActionToKeystoneFrame(topKeyFrame, keystone)
        else
            topKeyFrame.setTopKeystone(nil)
            topKeyFrame.texture:Show()
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
    if scoreInfo == nil then
        return
    end
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