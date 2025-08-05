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
end

function PsyKeystoneHelper:createDefaultSettings()
    return {
        global = {
            session = false,
            debugMode = false,
            keystoneCache = {},
            minimap = {
                hide = false,
            }
        }
    }
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