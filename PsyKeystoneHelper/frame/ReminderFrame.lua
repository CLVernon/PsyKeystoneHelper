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

function ReminderPopup:showRerollKeystone()
    ReminderPopup:maybeInit()

    --TODO

    --Show
    PKH_ReminderFrame:Show()
end

function ReminderPopup:showYourKeystone()
    ReminderPopup:maybeInit()

    --TODO

    --Show
    PKH_ReminderFrame:Show()

    --Auto close
    C_Timer.After(10, function()
        ReminderPopup:hide()
    end)
end

function ReminderPopup:createFrameComponents()
    PKH_ReminderFrame.text = PsyKeystoneHelper:createString(ReminderFrame, "GameFontHighlight", 14, "")
    PKH_ReminderFrame.text:SetPoint("TOP", ReminderFrame, "TOP", 0, -20)

    PKH_ReminderFrame.keystone = PsyKeystoneHelper:createKeystoneButton(ReminderFrame, 60, 18)
    PKH_ReminderFrame.keystone:SetPoint("CENTER", ReminderFrame, "CENTER", 0, 5)
end

function ReminderPopup:blankOut()
    -- TODO
end
