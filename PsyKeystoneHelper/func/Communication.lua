local _, ns = ...
local PsyKeystoneHelper = ns.PsyKeystoneHelper

AceComm = LibStub("AceComm-3.0")
LibAceSerializer = LibStub("AceSerializer-3.0")

local function HandleComm(prefix, message, distribution, sender)
    local success, messageObj = LibAceSerializer:Deserialize(message)
    if not success then
        return
    end
    if messageObj.type == "SEND" then
        PsyKeystoneHelper:receiveInformation(messageObj.obj)
    elseif messageObj.type == "REQUEST" then
        PsyKeystoneHelper:sendInformation()
    elseif messageObj.type == "KEY_CALL" then
        PsyKeystoneHelper:receiveCalloutKey(messageObj.obj)
    end
end
AceComm:RegisterComm("PsyKeyStone", HandleComm)

------------------------------------------------------------------------------------------------------------------------
--- Communication for passing around party data
------------------------------------------------------------------------------------------------------------------------

function PsyKeystoneHelper:requestInformation()
    PsyKeystoneHelper:DebugPrint("Requesting data from party...")
    AceComm:SendCommMessage("PsyKeyStone", LibAceSerializer:Serialize({
        type = "REQUEST",
        obj = {}
    }), "PARTY", UnitName("player"))
end

function PsyKeystoneHelper:receiveInformation(playerData)
    PsyKeystoneHelper:DebugPrint("Received data from " .. playerData.fullName)
    if not PsyKeystoneHelper:getSessionStatus() then
        return
    end

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
    ns:renderKeystoneHelperFrame()
end

function PsyKeystoneHelper:sendInformation()
    -- Get M+ score information and add dungeon name and abbreviation
    local scoreInfo = C_ChallengeMode.GetMapScoreInfo()
    for _, dungeon in pairs(scoreInfo) do
        local mapName = C_ChallengeMode.GetMapUIInfo(dungeon.mapChallengeModeID) or ""
        local mapAbbreviation = PsyKeystoneHelper.dungeonAbbreviations[mapName] or ""

        dungeon.mapName = mapName
        dungeon.mapAbbreviation = mapAbbreviation
    end

    -- Get keystone information
    local keystone = PsyKeystoneHelper:getPlayerKeystone()

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
        type = "SEND",
        obj = playerData
    }), "PARTY", UnitName("player"))
end

function PsyKeystoneHelper:sortInformation()
    table.sort(PsyKeystoneHelper.db.profile.keystoneCache, function(t1, t2)
        if t1.overallScore ~= t2.overallScore then
            return t1.overallScore > t2.overallScore
        end
        return t1.name < t2.name
    end)

    local fullNamesToRemove = {}
    for _, playerData in pairs(PsyKeystoneHelper.db.profile.keystoneCache) do
        local keepPlayer = false
        if GetUnitName("Party1") == playerData.name and UnitIsConnected("Party1") then
            keepPlayer = true
        end
        if GetUnitName("Party2") == playerData.name and UnitIsConnected("Party2") then
            keepPlayer = true
        end
        if GetUnitName("Party3") == playerData.name and UnitIsConnected("Party3") then
            keepPlayer = true
        end
        if GetUnitName("Party4") == playerData.name and UnitIsConnected("Party4") and UnitIsConnected("Party1") then
            keepPlayer = true
        end
        if GetUnitName("player") == playerData.name then
            keepPlayer = true
        end

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

------------------------------------------------------------------------------------------------------------------------
--- Keystone Callout Communication
------------------------------------------------------------------------------------------------------------------------

function PsyKeystoneHelper:calloutKey(keystone)
    PsyKeystoneHelper:DebugPrint("Calling out selected keystone...")

    -- Get class properties
    local _, classFilename, _ = UnitClass("player")

    local keystoneCallout = {
        keystone = {
            texture = keystone.texture,
            mapName = keystone.mapName,
            mapAbbreviation = keystone.mapAbbreviation,
            level = keystone.level,
            owner = keystone.ownedChallengeMapId,
            ownerClassColour = keystone.ownerClassColour
        },
        caller = UnitName("player"),
        callerClassFilename = classFilename
    }

    AceComm:SendCommMessage("PsyKeyStone", LibAceSerializer:Serialize({
        type = "KEY_CALL",
        obj = keystoneCallout
    }), "PARTY", UnitName("player"))
end

function PsyKeystoneHelper:receiveCalloutKey(keystoneCallout)
    PsyKeystoneHelper:DebugPrint("Received keystone callout from " .. keystoneCallout.caller)
    ns.KeystoneCallout:show(keystoneCallout)
end