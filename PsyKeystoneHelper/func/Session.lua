local _, ns = ...
local PsyKeystoneHelper = ns.PsyKeystoneHelper

function PsyKeystoneHelper:toggleSessionStatus()
    if PsyKeystoneHelper:getSessionStatus() then
        PsyKeystoneHelper.db.global.session = false
        PsyKeystoneHelper.db.global.keystoneCache = {}
        ns:renderKeystoneHelperFrame()
    else
        if not UnitInParty("player") then
            PsyKeystoneHelper:Print("Cannot start a session when not in a party")
            return
        end
        if UnitInRaid("player") then
            PsyKeystoneHelper:Print("Cannot start a session when in a raid group")
            return
        end
        PsyKeystoneHelper.db.global.session = true
        PsyKeystoneHelper:requestInformation()
    end

    PsyKeystoneHelper:Print("Session is now " .. PsyKeystoneHelper:getSessionStatusString())
    PsyKeystoneHelper.KeystoneHelperFrame.status:SetText("Status: " .. PsyKeystoneHelper:getSessionStatusString())
    LibDBIcon:Hide("PsyKeystoneHelperDBI")
    LibDBIcon:Show("PsyKeystoneHelperDBI")
end

function PsyKeystoneHelper:getSessionStatusString()
    if PsyKeystoneHelper:getSessionStatus() then
        return "\124cFF00FF00Running"
    else
        return "\124cFFFF0000Stopped"
    end
end
