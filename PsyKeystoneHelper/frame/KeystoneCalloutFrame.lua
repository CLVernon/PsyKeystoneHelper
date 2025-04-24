local _, ns = ...
local PsyKeystoneHelper = ns.PsyKeystoneHelper
local KeystoneCallout = { }
ns.KeystoneCallout = KeystoneCallout

local timestamp = 0
local firstLoad = true

function KeystoneCalloutFrame_OnLoad()
    KeystoneCalloutFrame:Hide()
end

function CloseButton_OnClick()
    KeystoneCalloutFrame:Hide()
end

-- keystoneCallout={
--  caller="Dave",
--  keystone={
--    mapName="Operation: Floodgate",
--    mapAbbreviation="FLOOD",
--    level=13,
--    ownerClassColour="ffffffff",
--    owner="Psyala",
--    texture=6422372
--  }
-- }
function KeystoneCallout:show(keystoneCallout)
    -- Assign timestamp of frame opening
    timestamp = GetTime()

    -- If this is first load, initialise components
    if firstLoad then
        firstLoad = false
        KeystoneCallout:createFrameComponents()
    end

    -- Populate frame with data
    KeystoneCallout:populateCalloutFrames(keystoneCallout)

    -- Show the frame and auto hide after X seconds
    -- Only if the timestamp has not changed
    KeystoneCalloutFrame:Show()
    local timestampToClose = timestamp
    C_Timer.After(10, function()
        if timestampToClose == timestamp then
            KeystoneCalloutFrame:Hide()
            KeystoneCallout:populateCalloutFrames(nil)
        end
    end)
end

function KeystoneCallout:createFrameComponents()
    KeystoneCalloutFrame.text = PsyKeystoneHelper:createString(KeystoneCalloutFrame, "GameFontHighlight", 14, "")
    KeystoneCalloutFrame.text:SetPoint("TOP", KeystoneCalloutFrame, "TOP", 0, -20)

    KeystoneCalloutFrame.keystone = PsyKeystoneHelper:createKeystoneFrame(KeystoneCalloutFrame, 60, 18)
    KeystoneCalloutFrame.keystone:SetPoint("CENTER", KeystoneCalloutFrame, "CENTER", 0, 5)
end

function KeystoneCallout:populateCalloutFrames(keystoneCallout)
    if keystoneCallout == nil then
        KeystoneCalloutFrame.text:SetText("")
        KeystoneCalloutFrame.keystone.texture:SetTexture([[Interface\ICONS\INV_Misc_QuestionMark]])
        KeystoneCalloutFrame.keystone.topText:SetText("")
        PsyKeystoneHelper:updateColourForKeyLevel(KeystoneCalloutFrame.keystone.topText, 0)
        KeystoneCalloutFrame.keystone.bottomText:SetText("")
    else
        local callerClassColour = C_ClassColor.GetClassColor(keystoneCallout.callerClassFilename):GenerateHexColor()
        KeystoneCalloutFrame.text:SetText("|c" .. callerClassColour .. keystoneCallout.caller .. "|r has called a dungeon:")
        KeystoneCalloutFrame.keystone.texture:SetTexture(keystoneCallout.keystone.texture)
        KeystoneCalloutFrame.keystone.topText:SetText("+" .. keystoneCallout.keystone.level)
        PsyKeystoneHelper:updateColourForKeyLevel(KeystoneCalloutFrame.keystone.topText, keystoneCallout.keystone.level)
        KeystoneCalloutFrame.keystone.bottomText:SetText(keystoneCallout.keystone.mapAbbreviation)
    end
end

