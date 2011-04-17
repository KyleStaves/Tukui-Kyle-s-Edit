local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales
if not C["actionbar"].enable == true then return end

---------------------------------------------------------------------------
-- setup MultiBarLeft as bar #3 
---------------------------------------------------------------------------

local bar = TukuiBar3
MultiBarBottomRight:SetParent(bar)

for i= 1, 12 do
	local b = _G["MultiBarBottomRightButton"..i]
	local b2 = _G["MultiBarBottomRightButton"..i-1]
	b:SetSize(T.buttonsize, T.buttonsize)
	b:ClearAllPoints()
	b:SetFrameStrata("BACKGROUND")
	b:SetFrameLevel(15)
	
	--[[
	if i == 1 then
		b:SetPoint("BOTTOMLEFT", bar, T.buttonspacing, T.buttonspacing)
	elseif i == 7 then
		b:SetPoint("TOPLEFT", bar, T.buttonspacing, -T.buttonspacing)
	else
		b:SetPoint("LEFT", b2, "RIGHT", T.buttonspacing, 0)
	end
	]]--
	
	if i == 1 then
		b:SetPoint("TOPRIGHT", bar, -T.buttonspacing, -T.buttonspacing)
	else
		b:SetPoint("TOP", b2, "BOTTOM", 0, -T.buttonspacing)
	end
end

for i=7, 12 do
	local b = _G["MultiBarBottomRightButton"..i]
	local b2 = _G["MultiBarBottomRightButton1"]
	b:SetFrameLevel(b2:GetFrameLevel() - 2)
end