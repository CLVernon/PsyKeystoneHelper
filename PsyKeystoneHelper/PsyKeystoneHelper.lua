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
AceDB = LibStub("AceDB-3.0")
AceEvent = LibStub("AceEvent-3.0")

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