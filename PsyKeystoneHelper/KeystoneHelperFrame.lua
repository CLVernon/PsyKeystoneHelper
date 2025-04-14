local _, ns = ...

local PsyKeystoneHelper = ns.PsyKeystoneHelper

function KeystoneHelperFrame_OnLoad()
	PsyKeystoneHelper.frame = KeystoneHelperFrame
	KeystoneHelperFrame:Hide()

	--Set default title text
	KeystoneHelperFrame_OnShow()

	--Assign child frames
	KeystoneHelperFrame.title = title
	KeystoneHelperFrame.status = status

	--Setup Player Frame lookup
	KeystoneHelperFrame.playerFrames = {}
	KeystoneHelperFrame.playerFrames[1] = PsyKeystoneHelperFrame_Party1
	KeystoneHelperFrame.playerFrames[2] = PsyKeystoneHelperFrame_Party2
	KeystoneHelperFrame.playerFrames[3] = PsyKeystoneHelperFrame_Party3
	KeystoneHelperFrame.playerFrames[4] = PsyKeystoneHelperFrame_Party4
	KeystoneHelperFrame.playerFrames[5] = PsyKeystoneHelperFrame_Party5

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

	--Assign frame components their default values
	defaultTopKeystones()
end

function KeystoneHelperFrame_OnShow()
	--Update title text
	title:SetText("Keystone Helper |cffffff33" .. PsyKeystoneHelper.v .. "|r")
	status:SetText("Status: " .. PsyKeystoneHelper:getSessionStatusString())
end

function Button_ToggleSession_OnClick()
	_G.PsyKeystoneHelper:toggleSessionStatus()
end

function Button_RequestData_OnClick()
	_G.PsyKeystoneHelper:requestInformation()
end

function ns:displayPartyData()
	PsyKeystoneHelper:Print("displayPartyData() call")

	--Default frames
	do
		defaultTopKeystones()
	end

	--Now populate with actual data
	do

	end
end

function defaultTopKeystones() 
	for _, topKeystone in pairs(KeystoneHelperFrame.topKeystones) do
		topKeystone.topText:SetText("")
		topKeystone.bottomText:SetText("NONE")
		topKeystone.texture:SetTexture([[Interface\ICONS\INV_Misc_QuestionMark]])
	end
end
