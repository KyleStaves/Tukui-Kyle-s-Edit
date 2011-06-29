local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales
if not C["actionbar"].enable == true then return end

---------------------------------------------------------------------------
-- setup MultiBarRight as bar #4
---------------------------------------------------------------------------

local bar = TukuiBar4
bar:SetAlpha(1)
MultiBarLeft:SetParent(bar)

--[[ 
	Bonus bar classes id

	DRUID: Caster: 0, Cat: 1, Tree of Life: 2, Bear: 3, Moonkin: 4
	WARRIOR: Battle Stance: 1, Defensive Stance: 2, Berserker Stance: 3 
	ROGUE: Normal: 0, Stealthed: 1
	PRIEST: Normal: 0, Shadowform: 1
	
	When Possessing a Target: 5
]]--

local Page = {
	["DRUID"] = "[bonusbar:1] 8; [bonusbar:2] 6; [bonusbar:3] 10; [bonusbar:4] 6;",
	["WARRIOR"] = "[bonusbar:1] 6; [bonusbar:2] 8; [bonusbar:3] 10;",
	["ROGUE"] = "[bonusbar:1] 8; [form:3] 8;",
	["PRIEST"] = "[bonusbar:1] 6;",
	["DEFAULT"] = "[bonusbar:0] 6;",
}

--[[local Page = {
	["WARRIOR"] = "[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;",
	["DEFAULT"] = "[bonusbar:5] 11; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;",
}
]]--

local function GetBar()
	local condition = Page["DEFAULT"]
	local class = T.myclass
	local page = Page[class]
	if page then
		condition = condition.." "..page
	end
	condition = condition.." 1"
	return condition
end
bar:RegisterEvent("PLAYER_LOGIN")
bar:RegisterEvent("PLAYER_ENTERING_WORLD")
bar:RegisterEvent("KNOWN_CURRENCY_TYPES_UPDATE")
bar:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
bar:RegisterEvent("BAG_UPDATE")
bar:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
bar:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		local button
		for i = 1, NUM_ACTIONBAR_BUTTONS do
			button = _G["MultiBarLeftButton"..i]
			self:SetFrameRef("MultiBarLeftButton"..i, button)
		end	

		self:Execute([[
			buttons = table.new()
			for i = 1, 12 do
				table.insert(buttons, self:GetFrameRef("MultiBarLeftButton"..i))
			end
		]])

		self:SetAttribute("_onstate-page", [[
			for i, button in ipairs(buttons) do
				button:SetAttribute("actionpage", tonumber(newstate))
			end
		]])

		RegisterStateDriver(self, "page", GetBar())
	elseif event == "PLAYER_ENTERING_WORLD" then
		local button
		for i = 1, 12 do
			local b = _G["MultiBarLeftButton"..i]
			local b2 = _G["MultiBarLeftButton"..i-1]
			b:SetSize(T.buttonsize, T.buttonsize)
			b:ClearAllPoints()
			b:SetFrameStrata("BACKGROUND")
			b:SetFrameLevel(15)

			if i == 1 then
				b:SetPoint("TOPLEFT", bar, T.buttonspacing, -T.buttonspacing)
			else
				b:SetPoint("LEFT", b2, "RIGHT", T.buttonspacing, 0)
			end
		end
	elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
		-- attempt to fix blocked glyph change after switching spec.
		LoadAddOn("Blizzard_GlyphUI")
	else
		MainMenuBar_OnEvent(self, event, ...)
	end
end)