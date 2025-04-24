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
        end
    end)
end

function KeystoneCallout:createFrameComponents()

end

function KeystoneCallout:populateCalloutFrames(keystoneCallout)

end

