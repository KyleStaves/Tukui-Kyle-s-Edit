local parent, ns = ...
local oUF = ns.oUF

local Update = function(self, event)
	if(UnitAffectingCombat"player") then
		self.Combat:Show()
	else
		self.Combat:Hide()
	end
end

local Path = function(self, ...)
	return (self.Combat.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate')
end

local Enable = function(self, unit)
	local combat = self.Combat
	if(combat and unit == 'player') then
		combat.__owner = self
		combat.ForceUpdate = ForceUpdate

		self:RegisterEvent("PLAYER_REGEN_DISABLED", Path)
		self:RegisterEvent("PLAYER_REGEN_ENABLED", Path)

		if(combat:IsObjectType"Texture" and not combat:GetTexture()) then
			combat:SetTexture[[Interface\CharacterFrame\UI-StateIcon]]
			combat:SetTexCoord(.5, 1, 0, .49)
		end

		return true
	end
end

local Disable = function(self)
	if(self.Combat) then
		self:UnregisterEvent("PLAYER_REGEN_DISABLED", Path)
		self:UnregisterEvent("PLAYER_REGEN_ENABLED", Path)
	end
end

oUF:AddElement('Combat', Path, Enable, Disable)
