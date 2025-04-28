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

    keystoneFrame.setKeystone = function(keystone)
        if keystone == nil then
            keystoneFrame.texture:SetTexture([[Interface\ICONS\INV_Misc_QuestionMark]])
            keystoneFrame.texture:SetDesaturated(false)

            keystoneFrame.topText:SetText("")
            keystoneFrame.topText:SetTextColor(1, 1, 1)

            keystoneFrame.bottomText:SetText("")
            keystoneFrame.bottomText:SetTextColor(1, 1, 1)

            PsyKeystoneHelper:clearTooltip(keystoneFrame)
            PsyKeystoneHelper:clearClickListener(keystoneFrame)
        else
            keystoneFrame.texture:SetTexture(keystone.texture)

            keystoneFrame.topText:SetText("+" .. keystone.level)
            PsyKeystoneHelper:updateColourForKeyLevel(keystoneFrame.topText, keystone.level)

            keystoneFrame.bottomText:SetText(keystone.mapAbbreviation)
        end
    end

    keystoneFrame.setDungeonBest = function(dungeonScore)
        if dungeonScore == nil then
            keystoneFrame.texture:SetDesaturated(true)

            keystoneFrame.topText:SetText("")
            keystoneFrame.topText:SetTextColor(1, 1, 1)

            keystoneFrame.bottomText:SetText("")
            keystoneFrame.bottomText:SetTextColor(1, 1, 1)

            PsyKeystoneHelper:clearTooltip(keystoneFrame)
            PsyKeystoneHelper:clearClickListener(keystoneFrame)
        else
            keystoneFrame.texture:SetDesaturated(dungeonScore.dungeonScore == 0)

            keystoneFrame.topText:SetText("+" .. dungeonScore.level)
            PsyKeystoneHelper:updateColourForKeyLevel(keystoneFrame.topText, dungeonScore.level)

            keystoneFrame.bottomText:SetText(dungeonScore.dungeonScore)
            PsyKeystoneHelper:updateColourForDungeonScore(keystoneFrame.bottomText, dungeonScore.dungeonScore)
        end
    end

    keystoneFrame.setTopKeystone = function(keystone)
        if keystone == nil then
            keystoneFrame.texture:SetTexture(237555)
            keystoneFrame.texture:SetDesaturated(false)

            keystoneFrame.topText:SetText("")
            keystoneFrame.topText:SetTextColor(1, 1, 1)

            keystoneFrame.bottomText:SetText("NONE")
            keystoneFrame.bottomText:SetTextColor(1, 1, 1)

            PsyKeystoneHelper:clearTooltip(keystoneFrame)
            PsyKeystoneHelper:clearClickListener(keystoneFrame)
        else
            keystoneFrame.texture:SetTexture(keystone.texture)

            keystoneFrame.topText:SetText("+" .. keystone.level)
            PsyKeystoneHelper:updateColourForKeyLevel(keystoneFrame.topText, keystone.level)

            keystoneFrame.bottomText:SetText(keystone.gainedScore)
            PsyKeystoneHelper:updateColourForDungeonScore(keystoneFrame.bottomText, keystone.gainedScore)
        end
    end

    keystoneFrame.markDead = function()
        keystoneFrame.texture:SetDesaturated(true)

        keystoneFrame.topText:SetText("DEAD")
        keystoneFrame.topText:SetTextColor(1, 1, 1)
    end

    keystoneFrame.markReroll = function()
        keystoneFrame.texture:SetTexture([[Interface\AddOns\PsyKeystoneHelper\img\reroll_keystone]])
    end

    return keystoneFrame
end

function PsyKeystoneHelper:createKeystoneButton(parent, size, fontSize)
    local keystoneFrame = CreateFrame("button", nil, parent, "SecureActionButtonTemplate")
    keystoneFrame:SetSize(size, size)

    keystoneFrame.texture = keystoneFrame:CreateTexture()
    keystoneFrame.texture:SetTexture([[Interface\ICONS\INV_Misc_QuestionMark]])
    keystoneFrame.texture:SetAllPoints(keystoneFrame)

    keystoneFrame.topText = PsyKeystoneHelper:createString(keystoneFrame, "GameFontNormalMed2Outline", fontSize, "")
    keystoneFrame.topText:SetPoint("TOP", keystoneFrame, "TOP", 0, 0)

    keystoneFrame.bottomText = PsyKeystoneHelper:createString(keystoneFrame, "GameFontNormalMed2Outline", fontSize, "")
    keystoneFrame.bottomText:SetPoint("BOTTOM", keystoneFrame, "BOTTOM", 1, 0)

    keystoneFrame:RegisterForClicks("AnyDown", "AnyUp")
    keystoneFrame:SetAttribute("type", "spell")
    keystoneFrame:SetAttribute("spell", 0)

    keystoneFrame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
        GameTooltip:ClearLines()

        local spellId = keystoneFrame:GetAttribute("spell")
        if spellId == 0 then
            GameTooltip:Hide()
        else
            GameTooltip:AddLine(PsyKeystoneHelper:getMouseIconTooltipMarkup("left") .. " Teleport to dungeon")

            if IsSpellKnown(spellId) then
                local spellCooldownInfo = C_Spell.GetSpellCooldown(spellId)
                if spellCooldownInfo then
                    local startTime = spellCooldownInfo.startTime
                    local duration = spellCooldownInfo.duration
                    local isEnabled = spellCooldownInfo.isEnabled
                    local remaining = max(0, (startTime + duration) - GetTime())
                    if isEnabled and remaining > 5 then
                        GameTooltip:AddLine("")
                        GameTooltip:AddLine("|cFFFF0000Dungeon teleport is on cooldown!|r")
                    end
                end
            else
                GameTooltip:AddLine("")
                GameTooltip:AddLine("|cFFFF0000Dungeon teleport not known :(|r")
            end

            GameTooltip:Show()
        end

    end)

    keystoneFrame:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

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