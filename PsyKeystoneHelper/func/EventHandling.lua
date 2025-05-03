local _, ns = ...
local PsyKeystoneHelper = ns.PsyKeystoneHelper

function PsyKeystoneHelper:handleGroupLeft()
    PsyKeystoneHelper:DebugPrint("handleGroupLeft()")
    if PsyKeystoneHelper:getSessionStatus() then
        PsyKeystoneHelper:toggleSessionStatus()
        ns:renderKeystoneHelperFrame()
    end
    ns.ReminderPopup:hide()
end

function PsyKeystoneHelper:handleGroupJoined()
    PsyKeystoneHelper:DebugPrint("handleGroupJoined()")
    if UnitInRaid("player") then
        if PsyKeystoneHelper:getSessionStatus() then
            PsyKeystoneHelper:toggleSessionStatus()
        end
        return
    end
    PsyKeystoneHelper:sendInformation()
end

function PsyKeystoneHelper:handleChallengeModeCompleted()
    PsyKeystoneHelper:DebugPrint("handleChallengeModeCompleted()")
    PsyKeystoneHelper:sendInformation()
    C_Timer.After(3, function()
        PsyKeystoneHelper:sendInformation()
    end)
    C_Timer.After(5, function()
        ns.ReminderPopup:maybeShowRerollKeystone()
    end)
    if PsyKeystoneHelper:getSessionStatus() then
        PsyKeystoneHelper.KeystoneHelperFrame:Show()
    end
end

function PsyKeystoneHelper:handleChallengeModeStart()
    PsyKeystoneHelper:DebugPrint("handleChallengeModeStart()")
    C_Timer.After(3, function()
        PsyKeystoneHelper:sendInformation()
    end)
    ns.ReminderPopup:hide()
end

function PsyKeystoneHelper:handleItemCountChanged(_, itemId)
    if itemId == 180653 or itemId == 138019 then
        PsyKeystoneHelper:DebugPrint("handleItemCountChanged()")
        PsyKeystoneHelper:sendInformation()
        C_Timer.After(2, function()
            PsyKeystoneHelper:sendInformation()
        end)
        return
    end
end

function PsyKeystoneHelper:handleItemChanged(e, itemFrom, itemTo)
    if string.find(itemFrom, "Mythic Keystone") ~= nil then
        PsyKeystoneHelper:DebugPrint("handleItemChanged()")
        PsyKeystoneHelper:sendInformation()
        C_Timer.After(2, function()
            PsyKeystoneHelper:sendInformation()
        end)
    end
end

function PsyKeystoneHelper:handleZoneChanged()
    PsyKeystoneHelper:DebugPrint("handleZoneChanged()")
    PsyKeystoneHelper:checkIfYourKey(false)
end

function PsyKeystoneHelper:handleReadyCheck()
    PsyKeystoneHelper:DebugPrint("handleReadyCheck()")
    PsyKeystoneHelper:checkIfYourKey(false)
end