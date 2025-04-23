local _, ns = ...
local PsyKeystoneHelper = ns.PsyKeystoneHelper

function PsyKeystoneHelper:DebugPrint(msg)
    if PsyKeystoneHelper.db == nil or PsyKeystoneHelper.db.profile == nil then
        return
    end
    if PsyKeystoneHelper.db.profile.debugMode then
        PsyKeystoneHelper:Print(msg)
    end
end