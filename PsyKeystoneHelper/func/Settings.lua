local _, ns = ...
local PsyKeystoneHelper = ns.PsyKeystoneHelper

--Create Settings Frame
local settingsFrame = CreateFrame("Frame", "PsyKeystoneHelper_Settings", UIParent, "")
local c = Settings.RegisterCanvasLayoutCategory(settingsFrame, "Psy Keystone Helper")
PsyKeystoneHelper.settingsCategory = c
Settings.RegisterAddOnCategory(c)

function PsyKeystoneHelper:buildSettingsPanel()
    do
        local t = settingsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
        t:SetText("Psy Keystone Helper |cffffff33" .. PsyKeystoneHelper.v .. "|r")
        t:SetPoint("TOPLEFT", settingsFrame, 10, -15)
    end

    do
        local b = CreateFrame("Button", nil, settingsFrame, "GameMenuButtonTemplate")
        b:SetWidth(200)
        b:SetHeight(25)
        b:SetPoint("TOPLEFT", 10, -50)
        b:SetText("Open Psy Keystone Helper")
        b:SetScript("OnClick", function()
            PsyKeystoneHelper.KeystoneHelperFrame:Show()
        end)
    end

    do
        local config = PsyKeystoneHelper:minimap()

        local b = CreateFrame("CheckButton", nil, settingsFrame, "UICheckButtonTemplate")
        b:SetPoint("TOPLEFT", settingsFrame, 220, -47)

        b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        b.text:SetPoint("LEFT", b, "RIGHT", 0, 1)
        b.text:SetText("Minimap Icon")
        b:SetChecked(not config.hide)
        b:SetScript("OnClick", function()
            config.hide = not b:GetChecked()

            local icon = LibStub("LibDBIcon-1.0")
            if b:GetChecked() then
                icon:Show("PsyKeystoneHelperDBI")
            else
                icon:Hide("PsyKeystoneHelperDBI")
            end
        end)
    end

    do
        local sectionTitle = settingsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
        sectionTitle:SetText("Pop-ups")
        sectionTitle:SetPoint("TOPLEFT", settingsFrame, 10, -90)

        local sectionDesc = settingsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        sectionDesc:SetText("Configure if various pop-ups are enabled, and any settings relating to them.")
        sectionDesc:SetPoint("TOPLEFT", sectionTitle, 0, -18)

        do
            local b = CreateFrame("CheckButton", nil, settingsFrame, "UICheckButtonTemplate")
            b:SetPoint("TOPLEFT", sectionTitle, 0, -42)

            b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            b.text:SetPoint("LEFT", b, "RIGHT", 0, 1)
            b.text:SetText("Show Keystone Callouts")
            b:SetChecked(PsyKeystoneHelper.db.global.showKeystoneCallout)
            b:SetScript("OnClick", function()
                PsyKeystoneHelper.db.global.showKeystoneCallout = b:GetChecked()
            end)
        end

        do
            local s = CreateFrame("Slider", nil, settingsFrame, "UISliderTemplateWithLabels")
            s:SetPoint("TOPLEFT", sectionTitle, 250, -50)
            s:SetSize(200, 15)
            s:SetMinMaxValues(5, 60)
            s:SetValueStep(5)
            s:SetObeyStepOnDrag(true)
            s:SetValue(PsyKeystoneHelper:getKeystoneCalloutTime())
            s.Text:SetText("Frame Display Time (" .. PsyKeystoneHelper:getKeystoneCalloutTime() .. ")")
            s.Low:SetText(5)
            s.High:SetText(60)
            s:SetScript("OnValueChanged", function(self, value)
                PsyKeystoneHelper.db.global.keystoneCalloutTime = value
                s.Text:SetText("Frame Display Time (" .. value .. ")")
            end)
        end

        do
            local b = CreateFrame("CheckButton", nil, settingsFrame, "UICheckButtonTemplate")
            b:SetPoint("TOPLEFT", sectionTitle, 0, -82)

            b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            b.text:SetPoint("LEFT", b, "RIGHT", 0, 1)
            b.text:SetText("Show Your Keystone Reminder")
            b:SetChecked(PsyKeystoneHelper.db.global.showKeystoneReminder)
            b:SetScript("OnClick", function()
                PsyKeystoneHelper.db.global.showKeystoneReminder = b:GetChecked()
            end)
        end

        --do
        --    local s = CreateFrame("Slider", nil, settingsFrame, "UISliderTemplateWithLabels")
        --    s:SetPoint("TOPLEFT", sectionTitle, 250, -90)
        --    s:SetSize(200, 15)
        --    s:SetMinMaxValues(5, 60)
        --    s:SetValueStep(5)
        --    s:SetObeyStepOnDrag(true)
        --    s:SetValue(PsyKeystoneHelper:getKeystoneReminderTime())
        --    s.Text:SetText("Frame Display Time (" .. PsyKeystoneHelper:getKeystoneReminderTime() .. ")")
        --    s.Low:SetText(5)
        --    s.High:SetText(60)
        --    s:SetScript("OnValueChanged", function(self, value)
        --        PsyKeystoneHelper.db.global.keystoneReminderTime = value
        --        s.Text:SetText("Frame Display Time (" .. value .. ")")
        --    end)
        --end

        do
            local b = CreateFrame("CheckButton", nil, settingsFrame, "UICheckButtonTemplate")
            b:SetPoint("TOPLEFT", sectionTitle, 0, -122)

            b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            b.text:SetPoint("LEFT", b, "RIGHT", 0, 1)
            b.text:SetText("Show Keystone Reroll Reminder")
            b:SetChecked(PsyKeystoneHelper.db.global.showKeystoneReroll)
            b:SetScript("OnClick", function()
                PsyKeystoneHelper.db.global.showKeystoneReroll = b:GetChecked()
            end)
        end

        --do
        --    local s = CreateFrame("Slider", nil, settingsFrame, "UISliderTemplateWithLabels")
        --    s:SetPoint("TOPLEFT", sectionTitle, 250, -130)
        --    s:SetSize(200, 15)
        --    s:SetMinMaxValues(5, 60)
        --    s:SetValueStep(5)
        --    s:SetObeyStepOnDrag(true)
        --    s:SetValue(PsyKeystoneHelper:getKeystoneRerollTime())
        --    s.Text:SetText("Frame Display Time (" .. PsyKeystoneHelper:getKeystoneRerollTime() .. ")")
        --    s.Low:SetText(5)
        --    s.High:SetText(60)
        --    s:SetScript("OnValueChanged", function(self, value)
        --        PsyKeystoneHelper.db.global.keystoneRerollTime = value
        --        s.Text:SetText("Frame Display Time (" .. value .. ")")
        --    end)
        --end


    end

    do
        local sectionTitle = settingsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
        sectionTitle:SetText("Functionality")
        sectionTitle:SetPoint("TOPLEFT", settingsFrame, 10, -300)

        local sectionDesc = settingsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        sectionDesc:SetText("Extra functionality settings that are toggleable.")
        sectionDesc:SetPoint("TOPLEFT", sectionTitle, 0, -15)

        do
            local b = CreateFrame("CheckButton", nil, settingsFrame, "UICheckButtonTemplate")
            b:SetPoint("TOPLEFT", sectionTitle, 0, -42)

            b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            b.text:SetPoint("LEFT", b, "RIGHT", 0, 1)
            b.text:SetText("Auto Start Session")
            b:SetChecked(PsyKeystoneHelper.db.global.autoSession)
            b:SetScript("OnClick", function()
                PsyKeystoneHelper.db.global.autoSession = b:GetChecked()
            end)
        end
    end

end

function PsyKeystoneHelper:createDefaultSettings()
    return {
        global = {
            session = false,
            debugMode = false,
            keystoneCache = {},
            minimap = {
                hide = false,
            },
            showKeystoneReminder = true,
            showKeystoneReroll = true,
            showKeystoneCallout = true,
            keystoneReminderTime = 10,
            keystoneRerollTime = 10,
            keystoneCalloutTime = 30,
            autoSession = true
        }
    }
end

function PsyKeystoneHelper:getKeystoneReminderTime()
    if PsyKeystoneHelper.db == nil then
        return 10
    end
    return PsyKeystoneHelper.db.global.keystoneRerollTime
end

function PsyKeystoneHelper:getKeystoneCalloutTime()
    if PsyKeystoneHelper.db == nil then
        return 30
    end
    return PsyKeystoneHelper.db.global.keystoneCalloutTime
end

function PsyKeystoneHelper:getKeystoneRerollTime()
    if PsyKeystoneHelper.db == nil then
        return 10
    end
    return PsyKeystoneHelper.db.global.keystoneRerollTime
end

function PsyKeystoneHelper:isAutoSession()
    if PsyKeystoneHelper.db == nil then
        return true
    end
    return PsyKeystoneHelper.db.global.autoSession or true
end

function PsyKeystoneHelper:showKeystoneReminder()
    if PsyKeystoneHelper.db == nil then
        return true
    end
    return PsyKeystoneHelper.db.global.showKeystoneReminder or true
end

function PsyKeystoneHelper:showKeystoneCallout()
    if PsyKeystoneHelper.db == nil then
        return true
    end
    return PsyKeystoneHelper.db.global.showKeystoneCallout or true
end

function PsyKeystoneHelper:showKeystoneReroll()
    if PsyKeystoneHelper.db == nil then
        return true
    end
    return PsyKeystoneHelper.db.global.showKeystoneReroll or true
end

function PsyKeystoneHelper:minimap()
    if PsyKeystoneHelper.db == nil then
        return {
            hide = false,
        }
    end
    return PsyKeystoneHelper.db.global.minimap;
end

function PsyKeystoneHelper:getSessionStatus()
    if PsyKeystoneHelper.db == nil then
        return false
    end
    return PsyKeystoneHelper.db.global.session or false
end

function PsyKeystoneHelper:isDebugMode()
    if PsyKeystoneHelper.db == nil then
        return false
    end
    return PsyKeystoneHelper.db.global.debugMode
end

function PsyKeystoneHelper:keystoneCache()
    if PsyKeystoneHelper.db == nil then
        return {}
    end
    return PsyKeystoneHelper.db.global.keystoneCache
end