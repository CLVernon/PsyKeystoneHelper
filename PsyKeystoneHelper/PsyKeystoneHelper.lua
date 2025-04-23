local _, ns = ...

ns.PsyKeystoneHelper = LibStub("AceAddon-3.0"):NewAddon("PsyKeystoneHelper", "AceConsole-3.0", "AceEvent-3.0");
PsyKeystoneHelper = ns.PsyKeystoneHelper
PsyKeystoneHelper.v = C_AddOns.GetAddOnMetadata("PsyKeystoneHelper", "Version")

--Create Minimap Button
PsyKeystoneHelperDBI = LibStub("LibDataBroker-1.1"):NewDataObject("PsyKeystoneHelperDBI", {
    type = "data source",
    text = "PsyKeystoneHelper",
    label = "PsyKeystoneHelper",
    icon = "Interface\\AddOns\\PsyKeystoneHelper\\img\\logo",
    OnClick = function(_, buttonPressed)
        if buttonPressed == "RightButton" then
            PsyKeystoneHelper:toggleSessionStatus()
        elseif buttonPressed == "MiddleButton" then
            PsyKeystoneHelper:printChatCommands()
        elseif buttonPressed == "LeftButton" then
            if PsyKeystoneHelper.KeystoneHelperFrame:IsShown() then
                PsyKeystoneHelper.KeystoneHelperFrame:Hide()
            else
                PsyKeystoneHelper.KeystoneHelperFrame:Show()
            end
        end
    end,
    OnTooltipShow = function(tt)
        tt:AddLine("Keystone Helper " .. "|cFFFFFFFF" .. PsyKeystoneHelper.v .. "|r")
        tt:AddLine("Session Status: " .. PsyKeystoneHelper:getSessionStatusString())
        tt:AddLine(PsyKeystoneHelper:getMouseIconTooltipMarkup("left") .. " |cFFFFFFFFShow Window|r")
        tt:AddLine(PsyKeystoneHelper:getMouseIconTooltipMarkup("middle") .. " |cFFFFFFFFShow Commands|r")
        tt:AddLine(PsyKeystoneHelper:getMouseIconTooltipMarkup("right") .. " |cFFFFFFFFToggle Session State|r")
    end
})

--Get Libs
LibDBIcon = LibStub("LibDBIcon-1.0")
LibAceSerializer = LibStub("AceSerializer-3.0")
AceDB = LibStub("AceDB-3.0")
AceEvent = LibStub("AceEvent-3.0")

--------------------------------------------------------------------------------------------------------------------------------------------
-- Tooltip Mouse buttons
--------------------------------------------------------------------------------------------------------------------------------------------
mouseButtons = {
    left = { left = 0, right = 64, top = 0, bottom = 64 },
    right = { left = 64, right = 128, top = 0, bottom = 64 },
    middle = { left = 128, right = 192, top = 0, bottom = 64 },
    scroll = { left = 192, right = 256, top = 0, bottom = 64 },
}

function PsyKeystoneHelper:getMouseIconTooltipMarkup(button)
    local texture = "|TInterface\\AddOns\\PsyKeystoneHelper\\img\\mouse.tga:%s:%s:0:0:%s:%s:%s:%s:%s:%s|t";

    if mouseButtons[button] then
        local v = mouseButtons[button];
        return string.format(texture, 20, 20, 256, 64, v.left, v.right, v.top, v.bottom);
    else
        return ""
    end
end
--------------------------------------------------------------------------------------------------------------------------------------------
-- ADDON EVENTS
--------------------------------------------------------------------------------------------------------------------------------------------

function PsyKeystoneHelper:OnInitialize()
    --Init db
    PsyKeystoneHelper.db = AceDB:New("PsyKeystoneHelper_Session", {
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
    PsyKeystoneHelper:RegisterEvent("CHALLENGE_MODE_START", "handleChallengeModeStart")
    PsyKeystoneHelper:RegisterEvent("ITEM_COUNT_CHANGED", "handleItemCountChanged")
    PsyKeystoneHelper:RegisterEvent("ITEM_CHANGED", "handleItemChanged")

    --Show minimap icon
    LibDBIcon:Register("PsyKeystoneHelperDBI", PsyKeystoneHelperDBI, PsyKeystoneHelper.db.profile.minimap)
    LibDBIcon:Show("PsyKeystoneHelperDBI")
    LibDBIcon:AddButtonToCompartment("PsyKeystoneHelperDBI")

    --Disable state on load if player is not in group or is in raid
    if (not UnitInParty("player") or UnitInRaid("player")) and PsyKeystoneHelper:getSessionStatus() then
        PsyKeystoneHelper:toggleSessionStatus()
    end

    --Remind user of session state
    PsyKeystoneHelper:Print("Session is " .. PsyKeystoneHelper:getSessionStatusString())

    --Load frame if session is running
    if PsyKeystoneHelper:getSessionStatus() then
        PsyKeystoneHelper.KeystoneHelperFrame:Show()
    end
end

function PsyKeystoneHelper:OnEnable()
end

function PsyKeystoneHelper:OnDisable()
end

--------------------------------------------------------------------------------------------------------------------------------------------
-- Session Status
--------------------------------------------------------------------------------------------------------------------------------------------

function PsyKeystoneHelper:toggleSessionStatus()
    if PsyKeystoneHelper:getSessionStatus() then
        PsyKeystoneHelper.db.profile.session = false
        PsyKeystoneHelper.db.profile.keystoneCache = {}
        PsyKeystoneHelper.KeystoneHelperFrame:renderData()
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
    PsyKeystoneHelper.KeystoneHelperFrame.status:SetText("Status: " .. PsyKeystoneHelper:getSessionStatusString())
    LibDBIcon:Hide("PsyKeystoneHelperDBI")
    LibDBIcon:Show("PsyKeystoneHelperDBI")
end

function PsyKeystoneHelper:getSessionStatus()
    if PsyKeystoneHelper.db == nil then
        return false
    end
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
    [2] = 155,
    [3] = 170,
    [4] = 200,
    [5] = 215,
    [6] = 230,
    [7] = 260,
    [8] = 275,
    [9] = 290,
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
