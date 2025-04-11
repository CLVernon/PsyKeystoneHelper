PsyKeystoneHelper = LibStub("AceAddon-3.0"):NewAddon("PsyKeystoneHelper", "AceConsole-3.0", "AceEvent-3.0" );

function PsyKeystoneHelper:OnInitialize()
		-- Called when the addon is loaded

		-- Print a message to the chat frame
		self:Print("OnInitialize Event Fired: Hello")
end

function PsyKeystoneHelper:OnEnable()
		-- Called when the addon is enabled

		-- Print a message to the chat frame
		self:Print("OnEnable Event Fired: Hello, again ;)")
end

function PsyKeystoneHelper:OnDisable()
		-- Called when the addon is disabled
end
