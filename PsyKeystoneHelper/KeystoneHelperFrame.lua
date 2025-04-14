local _, ns = ...

function KeystoneHelperFrame_OnLoad()
	_G.PsyKeystoneHelper.frame = KeystoneHelperFrame
	KeystoneHelperFrame:Hide()

	--Setup Player Frame lookup
	KeystoneHelperFrame.playerFrames = {}
	KeystoneHelperFrame.playerFrames[1] = PsyKeystoneHelperFrame_Party1
	KeystoneHelperFrame.playerFrames[2] = PsyKeystoneHelperFrame_Party2
	KeystoneHelperFrame.playerFrames[3] = PsyKeystoneHelperFrame_Party3
	KeystoneHelperFrame.playerFrames[4] = PsyKeystoneHelperFrame_Party4
	KeystoneHelperFrame.playerFrames[5] = PsyKeystoneHelperFrame_Party5
end


function Button_ToggleSession_OnClick()
	_G.PsyKeystoneHelper:toggleSessionStatus()
end

function Button_RequestData_OnClick()
	_G.PsyKeystoneHelper:requestInformation()
end
