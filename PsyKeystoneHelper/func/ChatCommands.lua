local _, ns = ...
local PsyKeystoneHelper = ns.PsyKeystoneHelper

function PsyKeystoneHelper:printChatCommands()
    PsyKeystoneHelper:Print("Chat Commands:")
    PsyKeystoneHelper:Print("|cffffaeae/pkh|r " .. "|cffffff33session|r " .. "- Toggle the state of the session")
    PsyKeystoneHelper:Print("|cffffaeae/pkh|r " .. "|cffffff33show|r " .. "- Show the Keystone Helper window")
    PsyKeystoneHelper:Print("|cffffaeae/pkh|r " .. "|cffffff33request|r " .. "- Request data from the party")
    PsyKeystoneHelper:Print("|cffffaeae/pkh|r " .. "|cffffff33send|r " .. "- Send data to the party")
    PsyKeystoneHelper:Print("|cffffaeae/pkh|r " .. "|cffffff33version|r " .. "- Show version information")
    PsyKeystoneHelper:Print("|cffffaeae/pkh|r " .. "|cffffff33clear|r " .. "- Clear the cache data")
end

function PsyKeystoneHelper:handleChatCommand(input)
    local args = { strsplit(' ', input) }

    for _, arg in ipairs(args) do
        if arg == "session" then
            PsyKeystoneHelper:toggleSessionStatus()
            return
        elseif arg == "show" or arg == "" then
            if PsyKeystoneHelper.KeystoneHelperFrame:IsShown() then
                PsyKeystoneHelper.KeystoneHelperFrame:Hide()
            else
                PsyKeystoneHelper.KeystoneHelperFrame:Show()
            end
            return
        elseif arg == "request" then
            PsyKeystoneHelper:requestInformation()
            return
        elseif arg == "send" then
            PsyKeystoneHelper:sendInformation()
            return
        elseif arg == "cache" then
            DevTools_Dump(PsyKeystoneHelper.db.profile.keystoneCache)
            return
        elseif arg == "clear" then
            PsyKeystoneHelper.db.profile.keystoneCache = {}
            PsyKeystoneHelper:Print("Cache cleared")
            ns:renderKeystoneHelperFrame()
            return
        elseif arg == "version" then
            PsyKeystoneHelper:Print("Current Version: " .. PsyKeystoneHelper.v)
            if PsyKeystoneHelper:getSessionStatus() then
                PsyKeystoneHelper:Print("Received Player Versions: ")
                for _, playerData in pairs(PsyKeystoneHelper.db.profile.keystoneCache) do
                    PsyKeystoneHelper:Print(playerData.name .. " - " .. (playerData.version or "Unknown"))
                end
            end
            return
        elseif arg == "debug" then
            if PsyKeystoneHelper.db.profile.debugMode then
                PsyKeystoneHelper.db.profile.debugMode = false
                PsyKeystoneHelper:Print("Debug mode is: |cffffff33Disabled|r")
            else
                PsyKeystoneHelper.db.profile.debugMode = true
                PsyKeystoneHelper:Print("Debug mode is: |cffffff33Enabled|r")
            end
            return
        elseif arg == "commands" or arg == "command" or arg == "help" or arg == "?" then
            PsyKeystoneHelper:printChatCommands()
            return
        else
            PsyKeystoneHelper:Print("Unknown command...")
            PsyKeystoneHelper:printChatCommands()
            return
        end
    end
end