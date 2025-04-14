local _, ns = ...

local PsyKeystoneHelper = ns.PsyKeystoneHelper

function KeystoneHelperFrame_OnLoad()
	PsyKeystoneHelper.frame = KeystoneHelperFrame
	KeystoneHelperFrame:Hide()

	--Assign child frames
	KeystoneHelperFrame.title = title
	KeystoneHelperFrame.status = status

	--Setup Player Frame lookup
	KeystoneHelperFrame.playerFrames = {}
	KeystoneHelperFrame.playerFrames[1] = createPlayerFrame(1)
	KeystoneHelperFrame.playerFrames[2] = createPlayerFrame(2)
	KeystoneHelperFrame.playerFrames[3] = createPlayerFrame(3)
	KeystoneHelperFrame.playerFrames[4] = createPlayerFrame(4)
	KeystoneHelperFrame.playerFrames[5] = createPlayerFrame(5)

	--Setup Top Keystone lookup
	KeystoneHelperFrame.topKeystones = {}
	KeystoneHelperFrame.topKeystones[1] = {
		topText = TopKeys_1_Top,
		bottomText = TopKeys_1_Bottom,
		texture = TopKeys_1
	}
	KeystoneHelperFrame.topKeystones[2] = {
		topText = TopKeys_2_Top,
		bottomText = TopKeys_2_Bottom,
		texture = TopKeys_2
	}
	KeystoneHelperFrame.topKeystones[3] = {
		topText = TopKeys_3_Top,
		bottomText = TopKeys_3_Bottom,
		texture = TopKeys_3
	}

	--Set defaults
	KeystoneHelperFrame_OnShow()
end

function KeystoneHelperFrame_OnShow()
	--Update title text
	title:SetText("Keystone Helper |cffffff33" .. PsyKeystoneHelper.v .. "|r")
	status:SetText("Status: " .. PsyKeystoneHelper:getSessionStatusString())

	ns:displayPartyData()
end

function Button_ToggleSession_OnClick()
	_G.PsyKeystoneHelper:toggleSessionStatus()
end

function Button_RequestData_OnClick()
	_G.PsyKeystoneHelper:requestInformation()
end

function ns:displayPartyData()
	--Default frames
	defaultFrame()

	--Now populate with actual data
	if PsyKeystoneHelper.db ~= nil then
		local index = 1
		for _, playerData in pairs(PsyKeystoneHelper.db.profile.keystoneCache) do
			populatePlayerFrame(KeystoneHelperFrame.playerFrames[index], playerData)
			index = index + 1
		end
	end
end

function createPlayerFrame(index)
	local playerFrame = CreateFrame("frame", "player_frame" .. index, KeystoneHelperFrame, "")
	playerFrame:SetPoint("TOPLEFT", KeystoneHelperFrame, "TOPLEFT", 10, -95  - (85 * (index - 1)))
	playerFrame:SetSize(400, 80)

	playerFrame.name = playerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	playerFrame.name:SetFont("Fonts\2002B.ttf", 12, "OUTLINE")
	playerFrame.name:SetTextHeight(12)
	playerFrame.name:SetTextColor(1,1,1)
	playerFrame.name:SetText("Player " .. index)
	playerFrame.name:SetPoint("LEFT", playerFrame, "LEFT", 10, 5)

	playerFrame.score = playerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	playerFrame.score:SetFont("Fonts\2002B.ttf", 12, "OUTLINE")
	playerFrame.score:SetTextHeight(12)
	playerFrame.score:SetTextColor(1,1,1)
	playerFrame.score:SetText("Score: 0000")
	playerFrame.score:SetPoint("LEFT", playerFrame, "LEFT", 9, -5)

	playerFrame.keystone = createKeystoneFrame(playerFrame)
	playerFrame.keystone:SetPoint("LEFT", playerFrame, "LEFT", 90, 0)

	return playerFrame
end

function createKeystoneFrame(parent)
	local keystoneFrame = CreateFrame("frame", nil, parent, "")
	keystoneFrame:SetSize(40,40)

	keystoneFrame.texture = keystoneFrame:CreateTexture()
	keystoneFrame.texture:SetTexture([[Interface\ICONS\INV_Misc_QuestionMark]])
	keystoneFrame.texture:SetAllPoints(keystoneFrame)

	keystoneFrame.topText = keystoneFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2Outline")
	keystoneFrame.topText:SetFont("Fonts\2002B.ttf", 14, "OUTLINE")
	keystoneFrame.topText:SetTextHeight(14)
	keystoneFrame.topText:SetTextColor(1,1,1)
	keystoneFrame.topText:SetPoint("TOP", keystoneFrame, "TOP", 0, 7)
	keystoneFrame.topText:SetText("")

	keystoneFrame.bottomText = keystoneFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2Outline")
	keystoneFrame.bottomText:SetFont("Fonts\2002B.ttf", 10, "OUTLINE")
	keystoneFrame.bottomText:SetTextHeight(10)
	keystoneFrame.bottomText:SetTextColor(1,1,1)
	keystoneFrame.bottomText:SetPoint("BOTTOM", keystoneFrame, "BOTTOM", 1, -7)
	keystoneFrame.bottomText:SetText("")

	return keystoneFrame
end

function defaultFrame() 
	defaultTopKeystones()
	defaultPlayerFrames()
end

function defaultTopKeystones() 
	for _, topKeystone in pairs(KeystoneHelperFrame.topKeystones) do
		topKeystone.topText:SetText("")
		topKeystone.bottomText:SetText("NONE")
		topKeystone.texture:SetTexture([[Interface\ICONS\INV_Misc_QuestionMark]])
	end
end

function defaultPlayerFrames()
	for _, playerFrame in pairs(KeystoneHelperFrame.playerFrames) do
		playerFrame.name:SetText("")
		playerFrame.score:SetText("")
		playerFrame.keystone.texture:Hide()
		playerFrame.keystone.topText:SetText("")
		playerFrame.keystone.bottomText:SetText("")
	end
end

function populatePlayerFrame(playerFrame, playerData)
	playerFrame.name:SetText(playerData.name)
	playerFrame.score:SetText("Score: " .. playerData.overallScore)

	if playerData.keystone == nil then
		playerFrame.keystone.texture:SetTexture([[Interface\ICONS\INV_Misc_QuestionMark]])
		playerFrame.keystone.topText:SetText("")
		playerFrame.keystone.bottomText:SetText("")
	else
		playerFrame.keystone.texture:SetTexture(playerData.keystone.texture)
		playerFrame.keystone.topText:SetText("+" ..playerData.keystone.level)
		playerFrame.keystone.bottomText:SetText(playerData.keystone.mapAbbreviation)
	end
	playerFrame.keystone.texture:Show()
end