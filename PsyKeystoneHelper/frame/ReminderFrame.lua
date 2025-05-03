local _, ns = ...
local PsyKeystoneHelper = ns.PsyKeystoneHelper
local ReminderPopup = { }
ns.ReminderPopup = ReminderPopup

local firstLoad = true

function PKH_ReminderFrame_OnLoad()
    PKH_ReminderFrame:Hide()
end

function PKH_Reminder_CloseButton_OnClick()
    ReminderPopup:hide()
end

function ReminderPopup:maybeInit()
    -- If this is first load, initialise components
    if firstLoad then
        firstLoad = false
        ReminderPopup:createFrameComponents()
    end
end

function ReminderPopup:hide()
    if PKH_ReminderFrame ~= nil and PKH_ReminderFrame:IsShown() then
        PKH_ReminderFrame:Hide()
        ReminderPopup:blankOut()
    end
end

function ReminderPopup:maybeShowRerollKeystone()
    PsyKeystoneHelper:DebugPrint("maybeShowRerollKeystone()")
    local keystone = PsyKeystoneHelper:getPlayerKeystoneFromCache()
    if keystone == nil then
        PsyKeystoneHelper:DebugPrint("No keystone found")
        return
    end
    if keystone.rerollingGood == nil then
        PsyKeystoneHelper:DebugPrint("No rerollingGood found")
        return
    end
    PsyKeystoneHelper:DebugPrint("rerollingGood=" .. tostring(keystone.rerollingGood))

    if keystone.rerollingGood then
        PsyKeystoneHelper:DebugPrint("Showing ReminderFrame ... showRerollKeystone")
        ReminderPopup:maybeInit()

        PKH_ReminderFrame.keystone.setKeystone(keystone)
        PKH_ReminderFrame.keystone.markReroll()
        PKH_ReminderFrame.keystone.texture:Show()
        PKH_ReminderFrame.text:SetText("Reroll keystone?")

        PKH_ReminderFrame:Show()
    end
end

function ReminderPopup:showYourKeystone()
    PsyKeystoneHelper:DebugPrint("Showing ReminderFrame ... showYourKeystone")
    ReminderPopup:maybeInit()

    local keystone = PsyKeystoneHelper:getPlayerKeystone()
    PKH_ReminderFrame.keystone.setKeystone(keystone)
    PKH_ReminderFrame.keystone.texture:Show()
    PKH_ReminderFrame.text:SetText("Your keystone?")

    PKH_ReminderFrame:Show()
end

function ReminderPopup:createFrameComponents()
    PKH_ReminderFrame.text = PsyKeystoneHelper:createString(PKH_ReminderFrame, "GameFontHighlight", 14, "")
    PKH_ReminderFrame.text:SetPoint("TOP", PKH_ReminderFrame, "TOP", 0, -20)

    PKH_ReminderFrame.keystone = PsyKeystoneHelper:createKeystoneFrame(PKH_ReminderFrame, 60, 18)
    PKH_ReminderFrame.keystone:SetPoint("CENTER", PKH_ReminderFrame, "CENTER", 0, 5)
end

function ReminderPopup:blankOut()
    PKH_ReminderFrame.text:SetText("")
    PKH_ReminderFrame.text:SetTextColor(1, 1, 1)
    PKH_ReminderFrame.keystone.texture:SetTexture([[Interface\ICONS\INV_Misc_QuestionMark]])
    PKH_ReminderFrame.keystone.texture:Hide()
end
