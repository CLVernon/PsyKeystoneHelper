local _, ns = ...
local PsyKeystoneHelper = ns.PsyKeystoneHelper
local KeystoneCallout = { }
ns.KeystoneCallout = KeystoneCallout

local timestamp = 0
local firstLoad = true

function PKH_KeystoneCalloutFrame_OnLoad()
    PKH_KeystoneCalloutFrame:Hide()
end

function PKH_CloseButton_OnClick()
    PKH_KeystoneCalloutFrame:Hide()
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
    if not PsyKeystoneHelper:showKeystoneCallout() then
        return
    end

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
    PKH_KeystoneCalloutFrame:Show()
    local timestampToClose = timestamp
    C_Timer.After(PsyKeystoneHelper:getKeystoneCalloutTime(), function()
        if timestampToClose == timestamp then
            PKH_KeystoneCalloutFrame:Hide()
            KeystoneCallout:populateCalloutFrames(nil)
        end
    end)
end

function KeystoneCallout:createFrameComponents()
    PKH_KeystoneCalloutFrame.text = PsyKeystoneHelper:createString(PKH_KeystoneCalloutFrame, "GameFontHighlight", 14, "")
    PKH_KeystoneCalloutFrame.text:SetPoint("TOP", PKH_KeystoneCalloutFrame, "TOP", 0, -20)

    PKH_KeystoneCalloutFrame.keystone = PsyKeystoneHelper:createKeystoneButton(PKH_KeystoneCalloutFrame, 60, 18)
    PKH_KeystoneCalloutFrame.keystone:SetPoint("CENTER", PKH_KeystoneCalloutFrame, "CENTER", 0, 5)
end

function KeystoneCallout:populateCalloutFrames(keystoneCallout)
    if keystoneCallout == nil then
        PKH_KeystoneCalloutFrame.text:SetText("")
        PKH_KeystoneCalloutFrame.keystone.texture:SetTexture([[Interface\ICONS\INV_Misc_QuestionMark]])
        PKH_KeystoneCalloutFrame.keystone.topText:SetText("")
        PsyKeystoneHelper:updateColourForKeyLevel(PKH_KeystoneCalloutFrame.keystone.topText, 0)
        PKH_KeystoneCalloutFrame.keystone.bottomText:SetText("")
        PKH_KeystoneCalloutFrame.keystone:SetAttribute("spell", 0)
    else
        local callerClassColour = C_ClassColor.GetClassColor(keystoneCallout.callerClassFilename):GenerateHexColor()
        PKH_KeystoneCalloutFrame.text:SetText("|c" .. callerClassColour .. keystoneCallout.caller .. "|r has called a dungeon:")
        PKH_KeystoneCalloutFrame.keystone.texture:SetTexture(keystoneCallout.keystone.texture)
        PKH_KeystoneCalloutFrame.keystone.topText:SetText("+" .. keystoneCallout.keystone.level)
        PsyKeystoneHelper:updateColourForKeyLevel(PKH_KeystoneCalloutFrame.keystone.topText, keystoneCallout.keystone.level)
        PKH_KeystoneCalloutFrame.keystone.bottomText:SetText(keystoneCallout.keystone.mapAbbreviation)
        PKH_KeystoneCalloutFrame.keystone:SetAttribute("spell", PsyKeystoneHelper.dungeonSpellIds[keystoneCallout.keystone.mapName] or 0)
    end
end

