local _, ns = ...
local PsyKeystoneHelper = ns.PsyKeystoneHelper

------------------------------------------------------------------------------------------------------------------------
--- Mouse Buttons
------------------------------------------------------------------------------------------------------------------------
mouseButtons = {
    left = { left = 0, right = 64, top = 0, bottom = 64 },
    right = { left = 64, right = 128, top = 0, bottom = 64 },
    middle = { left = 128, right = 192, top = 0, bottom = 64 },
    scroll = { left = 192, right = 256, top = 0, bottom = 64 },
}

function PsyKeystoneHelper:getMouseIconTooltipMarkup(button)
    local texture = "|TInterface\\AddOns\\PsyKeystoneHelper\\img\\mouse.tga:%s:%s:0:0:%s:%s:%s:%s:%s:%s|t";

    if mouseButtons[button] then
        local v = mouseButtons[button];
        return string.format(texture, 20, 20, 256, 64, v.left, v.right, v.top, v.bottom);
    else
        return ""
    end
end

------------------------------------------------------------------------------------------------------------------------
--- UI Creators
------------------------------------------------------------------------------------------------------------------------

function PsyKeystoneHelper:createString(parent, template, size, defaultText)
    local string = parent:CreateFontString(nil, "OVERLAY", template)
    string:SetFont("Fonts/2002B.ttf", size, "OUTLINE")
    string:SetTextHeight(size)
    string:SetTextColor(1, 1, 1)
    string:SetText(defaultText)
    return string
end

function PsyKeystoneHelper:createKeystoneFrame(parent, size, fontSize)
    local keystoneFrame = CreateFrame("frame", nil, parent, "")
    keystoneFrame:SetSize(size, size)

    keystoneFrame.texture = keystoneFrame:CreateTexture()
    keystoneFrame.texture:SetTexture([[Interface\ICONS\INV_Misc_QuestionMark]])
    keystoneFrame.texture:SetAllPoints(keystoneFrame)

    keystoneFrame.topText = PsyKeystoneHelper:createString(keystoneFrame, "GameFontNormalMed2Outline", fontSize, "")
    keystoneFrame.topText:SetPoint("TOP", keystoneFrame, "TOP", 0, 0)

    keystoneFrame.bottomText = PsyKeystoneHelper:createString(keystoneFrame, "GameFontNormalMed2Outline", fontSize, "")
    keystoneFrame.bottomText:SetPoint("BOTTOM", keystoneFrame, "BOTTOM", 1, 0)

    return keystoneFrame
end

------------------------------------------------------------------------------------------------------------------------
--- UI Alters
------------------------------------------------------------------------------------------------------------------------

function PsyKeystoneHelper:updateColourForKeyLevel(fontString, level)
    local levelColour = C_ChallengeMode.GetKeystoneLevelRarityColor(level) or { r = 1, g = 1, b = 1 }
    fontString:SetTextColor(levelColour.r, levelColour.g, levelColour.b)
end

function PsyKeystoneHelper:updateColourForOverallScore(fontString, overallScore)
    local scoreColour = C_ChallengeMode.GetDungeonScoreRarityColor(overallScore) or { r = 1, g = 1, b = 1 }
    fontString:SetTextColor(scoreColour.r, scoreColour.g, scoreColour.b)
end

function PsyKeystoneHelper:updateColourForDungeonScore(fontString, dungeonScore)
    local scoreColour = C_ChallengeMode.GetSpecificDungeonScoreRarityColor(dungeonScore) or { r = 1, g = 1, b = 1 }
    fontString:SetTextColor(scoreColour.r, scoreColour.g, scoreColour.b)
end

------------------------------------------------------------------------------------------------------------------------
--- Tooltip Generators
------------------------------------------------------------------------------------------------------------------------

function PsyKeystoneHelper:clearTooltip(frame)
    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
        GameTooltip:ClearLines()
        GameTooltip:Hide()
    end)
    frame:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
end

------------------------------------------------------------------------------------------------------------------------
--- Click Events
------------------------------------------------------------------------------------------------------------------------

function PsyKeystoneHelper:clearClickListener(frame)
    frame:SetScript("OnMouseDown", function(self, button)
    end)
end