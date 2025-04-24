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

function PsyKeystoneHelper:isOldVersion(versionToCheck)
    return PsyKeystoneHelper:intifyVersion(versionToCheck) < PsyKeystoneHelper:intifyVersion(PsyKeystoneHelper.v)
end

function PsyKeystoneHelper:intifyVersion(versionString)
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