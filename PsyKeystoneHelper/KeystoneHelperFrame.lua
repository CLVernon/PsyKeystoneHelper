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
end
