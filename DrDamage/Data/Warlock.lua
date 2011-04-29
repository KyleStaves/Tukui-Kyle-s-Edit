if select(2, UnitClass("player")) ~= "WARLOCK" then return end
local GetSpellInfo = DrDamage.SafeGetSpellInfo
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff
local UnitExists = UnitExists
local UnitIsFriend = UnitIsFriend
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitIsUnit = UnitIsUnit
local math_min = math.min
local math_max = math.max
local math_ceil = math.ceil
local select = select
local GetPetSpellBonusDamage = GetPetSpellBonusDamage
local GetSpellCritChanceFromIntellect = GetSpellCritChanceFromIntellect
local Orc = (select(2,UnitRace("player")) == "Orc")
local IsSpellKnown = IsSpellKnown

local spells = { [GetSpellInfo(7814) or "Lash of Pain"] = true, [GetSpellInfo(54049) or "Shadow Bite"] = true, [GetSpellInfo(3110) or "Firebolt"] = true, }
function DrDamage:UpdatePetSpells()
	self:UpdateAB(spells)
end

function DrDamage:PlayerData()
	--Health updates
	self.PlayerHealth = { [1] = 0.251, [0.251] = GetSpellInfo(689) }
	self.TargetHealth = { [1] = 0.251, }
--GENERAL
	self.Calculation["Stats"] = function( calculation, ActiveAuras, Talents, spell, baseSpell )
		local mastery = calculation.mastery
		local masteryLast = calculation.masteryLast
		local spec = calculation.spec
		if spec == 1 then
			if mastery > 0 and mastery ~= masteryLast then
				if (calculation.school == "Shadow" --[[or calculation.school == "Shadowflame"--]]) and (baseSpell.eDot or baseSpell.Drain) --[[and calculation.group ~= "Pet"--]] then
					local masteryBonus = calculation.masteryBonus
					if masteryBonus then
						if baseSpell.Drain then
							calculation.dmgM_Add = calculation.dmgM_Add - masteryBonus
						else
							calculation.dmgM_dot_Add = calculation.dmgM_dot_Add - masteryBonus
						end
					end
					local bonus = mastery * 0.01 * 1.63
					if baseSpell.Drain then
						calculation.dmgM_Add = calculation.dmgM_Add + bonus
					else
						--Mastery is additive with Improved Corruption - 4.0.3
						calculation.dmgM_dot_Add = calculation.dmgM_dot_Add + bonus
					end
					calculation.masteryLast = mastery
					calculation.masteryBonus = bonus
				end
			end
		elseif spec == 2 then
			if mastery > 0 and mastery ~= masteryLast then
				if calculation.group == "Pet" or (ActiveAuras["Metamorphosis"] == 0) then
					local masteryBonus = calculation.masteryBonus
					if masteryBonus then
						calculation.dmgM = calculation.dmgM / masteryBonus
					end
					--NOTE: For Pet tooltips only base damage is affected
					--Mastery: Master Demonologist
					local bonus = 1 + mastery * 0.01 * 2
					calculation.dmgM = calculation.dmgM * bonus
					calculation.masteryLast = mastery
					calculation.masteryBonus = bonus
				end
			end
		elseif spec == 3 then
			if mastery > 0 and mastery ~= masteryLast then
				if (calculation.school == "Fire" or calculation.school == "Shadowflame") and calculation.group ~= "Pet" then
					local masteryBonus = calculation.masteryBonus
					if masteryBonus then
						calculation.dmgM = calculation.dmgM / masteryBonus
					end
					--Mastery: Fiery Apocalpyse
					local bonus = 1 + mastery * 0.01 * 1.35
					calculation.dmgM = calculation.dmgM * bonus
					calculation.masteryLast = mastery
					calculation.masteryBonus = bonus
				end
			end
		end
	end
	self.Calculation["WARLOCK"] = function( calculation, ActiveAuras, Talents, spell, baseSpell )
		--General stats
		if IsSpellKnown(86091) then
			calculation.intM = calculation.intM * 1.05
		end
		--Set crits to 199.5%
		calculation.critM = calculation.critM + 0.495
		calculation.casterCrit = true
		--General bonuses
		if calculation.group == "Pet" then
			if Orc then
				calculation.dmgM = calculation.dmgM * 1.05
			end
		else
			--TODO: Verify
			if Talents["Death's Embrace"] then
				if UnitHealth("target") ~=0 and (UnitHealth("target") / UnitHealthMax("target")) <= 0.25 then
					calculation.dmgM = calculation.dmgM * ( 1 + 0.04 * Talents["Death's Embrace"] )
				end
			end
			if ActiveAuras["Metamorphosis"] == 0 then
				calculation.dmgM = calculation.dmgM * 1.2
			end
		end
		if not baseSpell.NoSchoolTalents then
			local spec = calculation.spec
			if spec == 1 then
				-- Checked in 4.1 - Shadow Mastery bonus went from 25% to 30%
				if calculation.school == "Shadow" or calculation.school == "Shadowflame" then
					--NOTE: Pets don't gain, but tooltips show base damage gain
					if calculation.group ~= "Pet" then
						if calculation.spellName == "Haunt" then
							--BUG: Haunt only gains base damage?
							calculation.bDmgM = calculation.bDmgM * 1.3
						else
							calculation.dmgM = calculation.dmgM * 1.3
						end
					end
				end
			elseif spec == 2 then
				if calculation.school == "Shadow" or calculation.school == "Fire" or calculation.school == "Shadowflame" then
					if calculation.group ~= "Pet" then
						--Multiplicative 4.0
						calculation.dmgM = calculation.dmgM * 1.15
					end
				end
			elseif spec == 3 then
				if calculation.school == "Fire" or calculation.school == "Shadowflame" then
					if calculation.group ~= "Pet" then
						calculation.dmgM = calculation.dmgM * 1.25
					end
				end
			end
		end
	end
--ABILITIES
	local damage_text = GetSpellInfo(48360)
	self.Calculation["Life Tap"] = function( calculation, _, Talents )
		--Additive - 4.0
		local amount = UnitHealthMax("player") * 0.15 * (1.20 + (Talents["Improved Life Tap"] or 0))
		calculation.minDam = amount
		calculation.maxDam = amount
		calculation.customText = damage_text
		calculation.customTextValue = 0.15 * UnitHealthMax("player")
	end
	local heal = GetSpellInfo(2050)
	self.Calculation["Drain Life"] = function( calculation, ActiveAuras, Talents )
		--Multiplicative - 4.0
		if ActiveAuras["Soul Siphon"] and Talents["Soul Siphon"] then
			calculation.dmgM = calculation.dmgM * (1 + math_min(4, ActiveAuras["Soul Siphon"]) * Talents["Soul Siphon"] * 0.03)
		end
		if ActiveAuras["Soulburn"] then
			calculation.castTime = 1.5
		end
		if Talents["Death's Embrace"] and (UnitHealth("player") / UnitHealthMax("player")) <= 0.25 then
			calculation.customTextValue = (0.06 + 0.01 * Talents["Death's Embrace"]) * UnitHealthMax("player") * (ActiveAuras["Demon Armor"] or 1)
		else
			calculation.customTextValue = 0.06 * UnitHealthMax("player") * (ActiveAuras["Demon Armor"] or 1)
		end
		calculation.customText = heal
	end
	self.Calculation["Drain Soul"] = function ( calculation, ActiveAuras, Talents, spell )
		--Multiplicative - 4.0
		if ActiveAuras["Soul Siphon"] and Talents["Soul Siphon"] then
			calculation.dmgM = calculation.dmgM * (1 + math_min(4, ActiveAuras["Soul Siphon"]) * Talents["Soul Siphon"] * 0.03)
		end
		if UnitHealth("target") ~= 0 and (UnitHealth("target") / UnitHealthMax("target")) <= 0.25 then
			calculation.minDam = calculation.minDam * 2
			calculation.maxDam = calculation.maxDam * 2
		end
	end
	self.Calculation["Incinerate"] = function( calculation, ActiveAuras, Talents, spell )
		--Glyph of Incinerate (Additive - 4.0)
		if self:HasGlyph(56242) then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.05
		end
		if ActiveAuras["Immolate"] then
			calculation.minDam = 1.167 * calculation.minDam
			calculation.maxDam = 1.167 * calculation.maxDam
			calculation.SPBonus = 1.167 * calculation.SPBonus
			--TODO: Doesn't seem to apply...
			--calculation.dmgM = calculation.dmgM * (1 + (Talents["Fire and Brimstone"] or 0))
		end
		if ActiveAuras["Molten Core"] and Talents["Molten Core"] then
			--Additive 4.0
			calculation.dmgM_Add = calculation.dmgM_Add + 0.06 * Talents["Molten Core"]
		end
		if self:GetSetAmount( "T8" ) >= 4 then
			calculation.critPerc = calculation.critPerc + 5
		end
		if self:GetSetAmount( "T10" ) >= 2 then
			calculation.critPerc = calculation.critPerc + 5
		end
	end
	self.Calculation["Soul Fire"] = function( calculation, ActiveAuras, Talents, spell )
		if self:GetSetAmount( "T10" ) >= 2 then
			calculation.critPerc = calculation.critPerc + 5
		end
		--[[
		if Talents["Burning Embers"] then
			calculation.hybridCanCrit = false
			calculation.hybridDotDmg = self:ScaleData(0.174, nil, calculation.playerLevel) --self:ScaleData(0.148, nil, calculation.playerLevel)
			calculation.hybridDotRoll = true
			calculation.SPBonus_dot = Talents["Burning Embers"] * 0.425
			calculation.dmgM_dot_global = 1
			calculation.eDuration = 7
			calculation.sTicks = 1
		end
		--]]
	end
	self.Calculation["Chaos Bolt"] = function( calculation, ActiveAuras, Talents )
		if ActiveAuras["Immolate"] and Talents["Fire and Brimstone"] then
			calculation.dmgM = calculation.dmgM * (1 + Talents["Fire and Brimstone"])
		end
		--Glyph of Chaos Bolt (4.0)
		if self:HasGlyph(63304) then
			calculation.cooldown = calculation.cooldown - 2
		end
	end
	self.Calculation["Immolate"] = function( calculation )
		--Glyph of Immolate (4.0)
		if self:HasGlyph(56228) then
			calculation.dmgM_dot_Add = calculation.dmgM_dot_Add + 0.1
		end
		if self:GetSetAmount( "T8" ) >= 2 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
		if self:GetSetAmount( "T9" ) >= 4 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
	end
	self.Calculation["Bane of Agony"] = function( calculation )
		--Glyph of Bane of Agony (4.0)
		if self:HasGlyph(56241) then
			calculation.eDuration = calculation.eDuration + 4
			--Total damage goes from 100% -> 133.2%. 28/24 increase is handled in the core, but the glyph gives high-end ticks so it gain more base damage.
			calculation.bDmgM = calculation.bDmgM * (133.2/(100*(28/24)))
		end
	end
	self.Calculation["Searing Pain"] = function( calculation, ActiveAuras, Talents )
		if Talents["Improved Searing Pain"] and UnitHealth("target") ~=0 and (UnitHealth("target") / UnitHealthMax("target")) <= 0.25 then
				calculation.critPerc = calculation.critPerc + Talents["Improved Searing Pain"]
		end
		if ActiveAuras["Soulburn"] then
			calculation.critPerc = 100
		end
	end
	self.Calculation["Corruption"] = function( calculation )
		if self:GetSetAmount( "T9" ) >= 4 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
		if self:GetSetAmount( "T10" ) >= 2 then
			calculation.critPerc = calculation.critPerc + 5
		end
	end
	local immolate = GetSpellInfo(348)
	self.Calculation["Conflagrate"] = function( calculation, ActiveAuras, Talents )
		if self:GetSetAmount( "T8" ) >= 2 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
		if self:GetSetAmount( "T9" ) >= 4 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
		--Glyph of Conflagrate (4.0)
		if self:HasGlyph(63304) then
			calculation.cooldown = calculation.cooldown - 2
		end
		--Glyph of Immolate (4.0)
		if self:HasGlyph(56228) then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
		local spell = self.spellInfo[immolate][1]
		local baseSpell = self.spellInfo[immolate][0]
		calculation.SPBonus = 0.6 * baseSpell.Hits_dot * baseSpell.SPBonus_dot
		calculation.minDam = 0.6 * baseSpell.Hits_dot * math_ceil( spell.hybridDotDmg )
		calculation.maxDam = calculation.minDam
	end
	self.Calculation["Unstable Affliction"] = function( calculation )
		if self:GetSetAmount( "T8" ) >= 2 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.2
		end
		if self:GetSetAmount( "T9" ) >= 4 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
	end
	self.Calculation["Shadow Bolt"] = function( calculation )
		if self:GetSetAmount( "T8" ) >= 4 then
			calculation.critPerc = calculation.critPerc + 5
		end
		if self:GetSetAmount( "T10" ) >= 2 then
			calculation.critPerc = calculation.critPerc + 5
		end
	end
	self.Calculation["Immolation Aura"] = function( calculation, ActiveAuras )
		if not ActiveAuras["Metamorphosis"] then
			calculation.dmgM = calculation.dmgM * 1.2
		end
	end
	self.Calculation["Demon Leap"] = function( calculation, ActiveAuras )
		if not ActiveAuras["Metamorphosis"] then
			calculation.dmgM = calculation.dmgM * 1.2
		end
	end
	self.Calculation["Firebolt"] = function( calculation, ActiveAuras, Talents, spell )
		--calculation.critPerc = GetSpellCritChanceFromIntellect("pet") + calculation.spellCrit
		--Glyph of Imp (4.0)
		calculation.dmgM = calculation.dmgM * (1 + (self:HasGlyph(56248) and 0.2 or 0))
		if self:GetSetAmount( "T9" ) >= 2 then
			calculation.critPerc = calculation.critPerc + 10
		end
		if Talents["Burning Embers"] then
			calculation.hybridCanCrit = false
			calculation.hybridDotDmg = self:ScaleData(0.174, nil, calculation.playerLevel) --self:ScaleData(0.148, nil, calculation.playerLevel)
			calculation.dmgM_dot = calculation.dmgM_dot / calculation.dmgM
			calculation.SPBonus_dot = Talents["Burning Embers"] * 0.425
			--calculation.SP_dot = 0.5 * calculation.SP
			calculation.eDuration = 7
			calculation.sTicks = 1
			calculation.constantDPS = true
		end
		--calculation.SP = 0.5 * calculation.SP-- GetPetSpellBonusDamage()
		--calculation.SP_mod = 0.5 * calculation.SP_mod
		calculation.SPBonus = 0.5 * calculation.SPBonus
	end
	local shadowbite = {
		--Immolate, Corruption, Bane of Agony
		[GetSpellInfo(348)] = true, [GetSpellInfo(172)] = true, [GetSpellInfo(980)] = true,
		--Unstable Affliction, Bane of Doom, Drain Soul
		[GetSpellInfo(30108)] = true, [GetSpellInfo(603)] = true, [GetSpellInfo(1120)] = true,
		--Drain Life, Seed of Corruption,
		[GetSpellInfo(689)] = true, [GetSpellInfo(27243)] = true,
		--Also benefits from: Shadowflame
		--Doesn't benefit from: Hellfire, Rain of Fire
	}
	self.Calculation["Shadow Bite"] = function( calculation, ActiveAuras, Talents, spell )
		calculation.SPBonus = 0.5 * calculation.SPBonus
		--calculation.SP = GetPetSpellBonusDamage()
		--calculation.critPerc = GetSpellCritChanceFromIntellect("pet") + calculation.spellCrit
		if self:GetSetAmount( "T9" ) >= 2 then
			calculation.critPerc = calculation.critPerc + 10
		end
		if UnitExists("pettarget") then
			local dots = 0
			for i = 1, 40 do
				local name, _, _, _, _, _, _, caster = UnitDebuff("pettarget",i)
				if name then
					if shadowbite[name] and caster and UnitIsUnit("player", caster) then
						dots = dots + 1
					end
				else break end
			end
			-- 4.1 - Bonus per DoT went from 15% to 30%
			calculation.dmgM = calculation.dmgM * (1 + dots * 0.3)
		end
	end
	self.Calculation["Lash of Pain"] = function( calculation, ActiveAuras, Talents, spell )
		calculation.SPBonus = 0.5 * calculation.SPBonus
		--calculation.SP = GetPetSpellBonusDamage()
		--calculation.critPerc = GetSpellCritChanceFromIntellect("pet") + calculation.spellCrit
		--Glyph of Lash of Pain (4.0)
		calculation.dmgM = calculation.dmgM * (1 + (self:HasGlyph(70947) and 0.25 or 0))
		if self:GetSetAmount( "T9" ) >= 2 then
			calculation.critPerc = calculation.critPerc + 10
		end
	end
--SETS
	self.SetBonuses["T8"] = { 46135, 46136, 46137, 46139, 46140, 45417, 45419, 45420, 45421, 45422 }
	self.SetBonuses["T9"] = { 47798, 47799, 47800, 47801, 47802, 47783, 47784, 47785, 47786, 47787, 47782, 47778, 47780, 47779, 47781, 47788, 47789, 47790, 47791, 47792, 47803, 47804, 47805, 47806, 47807, 47797, 47796, 47795, 47794, 47793 }
	self.SetBonuses["T10"] = { 50240, 50241, 50242, 50243, 50244, 51230, 51231, 51232, 51233, 51234, 51205, 51206, 51207, 51208, 51209, }
--AURA
--Player
	--Demonic Soul (T7 proc)
	self.PlayerAura[GetSpellInfo(61595)] = { Spells = { "Shadow Bolt", "Incinerate" }, ModType = "critPerc", Value = 10, NoManual = true }
	--Fel Spark (T11 4p proc)
	self.PlayerAura[GetSpellInfo(89937)] = { Spells = "Fel Flame", Value = 3, NoManual = true }
	--Devious Minds (T10 4p 10% damage)
	self.PlayerAura[GetSpellInfo(70840)] = { School = "Pet", Value = 0.1, NoManual = true }
	--Eradication (Affliction proc)
	self.PlayerAura[GetSpellInfo(47195)] = { Update = true }
	--Decimation (Demonology proc)
	self.PlayerAura[GetSpellInfo(63156)] = { Update = true, Spells = "Soul Fire" }
	--Backlash (Destruction proc)
	self.PlayerAura[GetSpellInfo(34935)] = { Update = true, Spells = { "Incinerate", "Shadow Bolt" } }
	--Empowered Imp (Destruction proc)
	self.PlayerAura[GetSpellInfo(47283)] = { Update = true, Spells = "Soul Fire" }
	--Molten Core (Demonology proc)
	self.PlayerAura[GetSpellInfo(47383)] = { Spells = "Incinerate", ActiveAura = "Molten Core", ID = 47383 }
	--Metamorphosis
	self.PlayerAura[GetSpellInfo(59672)] = { ActiveAura = "Metamorphosis", Index = true, ID = 59672 }
	--Soulburn
	self.PlayerAura[GetSpellInfo(74434)] = { ActiveAura = "Soulburn", Spells = { "Searing Pain", "Soul Fire", "Drain Life" }, ID = 74434 }
	--Soulburn: Searing Pain
	self.PlayerAura[GetSpellInfo(79440)] = { Spells = "Searing Pain", ModType = "critPerc", Value = 50, ID = 79440 }
	--Demon Soul: Imp - Critical strike chance of your cast time Destruction spells increased by 30%.
	--TODO: Hellfire? Rain of Fire?
	self.PlayerAura[GetSpellInfo(79459)] = { Spells = { "Searing Pain", "Soul Fire", "Incinerate", "Shadow Bolt", "Chaos Bolt" }, ModType = "critPerc", Value = 30, ID = 79459 }
	--Demon Soul: Succubus
	self.PlayerAura[GetSpellInfo(79463)] = { Spells = "Shadow Bolt", Value = 0.1, ID = 79463 }
	--Demon Soul: Felhunter
	self.PlayerAura[GetSpellInfo(79460)] = { School = "Shadow", ID = 79460, Not = "Pet", ModType =
		function( calculation )
			if calculation.spellName == "Drain Life" or calculation.spellName == "Drain Soul" then
				calculation.dmgM = calculation.dmgM * 1.2
			else
				calculation.dmgM_dot = calculation.dmgM_dot * 1.2
			end
		end
	}
	--TODO: Demon Soul: Felguard. Does API handle it?
	--Improved Soul Fire (Destruction proc)
	self.PlayerAura[GetSpellInfo(85383)] = { School = { "Fire", "Shadow" }, Ranks = 2, Value = 0.04 }

--Target
	--Immolate
	self.TargetAura[GetSpellInfo(348)] = { ActiveAura = "Immolate", Ranks = 11, Spells = { "Incinerate", "Conflagrate", "Chaos Bolt" }, SelfCast = true, ID = 348 }
	--Curse of Gul'dan
	self.TargetAura[GetSpellInfo(86000)] = { School = "Pet", ID = 86000, ModType = "spellCrit", Value = 10 }
	--Soul Siphon
		--Corruption
		self.TargetAura[GetSpellInfo(172)] = 	{ ActiveAura = "Soul Siphon", Spells = { "Drain Life", "Drain Soul" }, SelfCast = true, NoManual = true }
		--Bane of Agony
		self.TargetAura[GetSpellInfo(980)] = 	self.TargetAura[GetSpellInfo(172)]
		--Bane of Doom
		self.TargetAura[GetSpellInfo(603)] = 	self.TargetAura[GetSpellInfo(172)]
		--Curse of Weakness
		self.TargetAura[GetSpellInfo(702)] = 	self.TargetAura[GetSpellInfo(172)]
		--Curse of Tongues
		self.TargetAura[GetSpellInfo(1714)] = 	self.TargetAura[GetSpellInfo(172)]
		--Curse of Exhaustion
		self.TargetAura[GetSpellInfo(18223)] = 	self.TargetAura[GetSpellInfo(172)]
		--Unstable Affliction
		self.TargetAura[GetSpellInfo(30108)] = 	self.TargetAura[GetSpellInfo(172)]
		--Seed of Corruption
		self.TargetAura[GetSpellInfo(27243)] = 	self.TargetAura[GetSpellInfo(172)]
		--Fear
		self.TargetAura[GetSpellInfo(5782)] = 	self.TargetAura[GetSpellInfo(172)]
		--Howl of Terror
		self.TargetAura[GetSpellInfo(5484)] = 	self.TargetAura[GetSpellInfo(172)]
--Custom
	--Curse of the Elements (debuff added in Aura.lua)
	self.TargetAura[GetSpellInfo(1490)].ActiveAura = "Soul Siphon"
	--Demon Armor
	self.PlayerAura[GetSpellInfo(687)] = { Spells = { "Death Coil", "Drain Life" }, ID = 687, ModType =
		function( calculation, ActiveAuras, Talents )
			calculation.leechBonus = (calculation.leechBonus or 0) * (1.2 + (Talents["Demonic Aegis"] or 0))
			ActiveAuras["Demon Armor"] = 1.2 + (Talents["Demonic Aegis"] or 0)
		end
	}
	--Backdraft
	self.PlayerAura[GetSpellInfo(47258)] = { NoManual = true, ModType =
		function( calculation, _, Talents )
			if Talents["Backdraft"] then
				calculation.haste = calculation.haste * (1 + Talents["Backdraft"])
			end
		end
	}
	--Haunt
	self.TargetAura[GetSpellInfo(48181)] = { School = "Shadow", SelfCast = true, ID = 48181, Not = { "Pet", "Bane of Doom" }, ModType =
		function( calculation, ActiveAuras, Talents )
			--Glyph of Haunt (4.0)
			if calculation.spellName == "Drain Life" or calculation.spellName == "Drain Soul" then
				--Multiplicative - 4.0
				calculation.dmgM = calculation.dmgM * (1.2 + (self:HasGlyph(63302) and 0.03 or 0))
			else
				--Multiplicative - 4.0
				calculation.dmgM_dot = calculation.dmgM_dot * (1.2 + (self:HasGlyph(63302) and 0.03 or 0))
			end
			if Talents["Soul Siphon"] then
				--Verified - 4.0
				ActiveAuras["Soul Siphon"] = (ActiveAuras["Soul Siphon"] or 0) + 1
			end
		end
	}
	--Shadow Embrace
	self.TargetAura[GetSpellInfo(32386)] = { School = "Shadow", SelfCast = true, ID = 32386, Apps = 3, Not = { "Pet", "Bane of Doom" }, ModType =
		function( calculation, ActiveAuras, Talents, _, apps )
			if Talents["Shadow Embrace"] then
				if calculation.spellName == "Drain Life" or calculation.spellName == "Drain Soul" then
					--Multiplicative 4.0
					calculation.dmgM = calculation.dmgM * (1 + Talents["Shadow Embrace"] * apps)
				else
					--Multiplicative 4.0
					calculation.dmgM_dot = calculation.dmgM_dot * (1 + Talents["Shadow Embrace"] * apps)
				end
			end
			if Talents["Soul Siphon"] then
				--Verified 4.0
				ActiveAuras["Soul Siphon"] = (ActiveAuras["Soul Siphon"] or 0) + 1
			end
		end
	}
	self.spellInfo = {
		[GetSpellInfo(172)] = {
					["Name"] = "Corruption",
					["ID"] = 172,
					["Data"] = { 0.153, 0, 0.176 },
					[0] = { School = { "Shadow", "Affliction", }, Hits = 6, eDot = true, eDuration = 18, sTicks = 3 },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(686)] = {
					["Name"] = "Shadow Bolt",
					["ID"] = 686,
					["Data"] = { 0.62, 0.11, 0.754, ["range"] = 5, ["ct_min"] = 1700, ["ct_max"] = 3000  },
					[0] = { School = { "Shadow", "Destruction" } },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(1454)] = {
					["Name"] = "Life Tap",
					["ID"] = 1454,
					[0] = { School = { "Shadow", "Utility", }, NoCrits = true, NoGlobalMod = true, NoTargetAura = true, NoSchoolTalents = true, NoDPS = true, NoNext = true, NoDPM = true, NoDoom = true, Unresistable = true },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(6229)] = {
					["Name"] = "Shadow Ward",
					["ID"] = 6229,
					["Data"] = { 3.69, 0 },
					[0] = { School = { "Shadow", "Absorb" }, SPBonus = 0.807, NoCrits = true, NoGlobalMod = true, NoTargetAura = true, NoSchoolTalents = true, NoDPS = true, NoNext = true, NoDPM = true, NoDoom = true, Unresistable = true, },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(980)] = {
					["Name"] = "Bane of Agony",
					["ID"] = 980,
					["Data"] = { 0.133, 0, 0.088 },
					[0] = { School = { "Shadow", "Affliction", }, Hits = 12, eDot = true, eDuration = 24, sTicks = 2, },
					[1] = { 0, 0, },
		},
		[GetSpellInfo(603)] = {
					["Name"] = "Bane of Doom",
					["ID"] = 603,
					["Data"] = { 2.024, 0, 0.88  },
					[0] = { School = { "Shadow", "Affliction", }, Hits = 4, eDot = true, eDuration = 60, sTicks = 15 },
					[1] = { 0, 0, },
		},
		[GetSpellInfo(6789)] = {
					["Name"] = "Death Coil",
					["ID"] = 6789,
					["Data"] = { 0.784, 0, 0.188 },
					[0] = { School = { "Shadow", "Affliction", "Leech" }, Cooldown = 120, Leech = 3, NoDoom = true, },
					[1] = { 0, 0, },
		},
		[GetSpellInfo(689)] = {
					["Name"] = "Drain Life",
					["ID"] = 689,
					["Data"] = { 0.114, 0, 0.172  },
					[0] = { School = { "Shadow", "Affliction" }, Hits = 3, sTicks = 1, Channeled = 3, Drain = true },
					[1] = { 0, 0, },
		},
		[GetSpellInfo(1120)] = {
					["Name"] = "Drain Soul",
					["ID"] = 1120,
					["Data"] = { 0.08, 0, 0.378  },
					[0] = { School = { "Shadow", "Affliction", }, Hits = 5, sTicks = 3, Channeled = 15, Drain = true },
					[1] = { 0, 0, },
		},
		[GetSpellInfo(5676)] = {
					["Name"] = "Searing Pain",
					["ID"] = 5676,
					["Data"] = { 0.322, 0.17, 0.378 },
					[0] = { School = { "Fire", "Destruction" }, },
					[1] = { 0, 0, },
		},
		[GetSpellInfo(6353)] = {
					["Name"] = "Soul Fire",
					["ID"] = 6353,
					["Data"] = { 2.543, 0.225, 0.628 },
					[0] = { School = { "Fire", "Destruction" }, },
					[1] = { 0, 0, },
		},
		[GetSpellInfo(17877)] = {
					["Name"] = "Shadowburn",
					["ID"] = 17877,
					["Data"] = { 0.714, 0.11, 1.056, ["PPL"] = 1.2 },
					[0] = { School = { "Shadow", "Destruction" }, Cooldown = 15, },
					[1] = { 0, 0, },
		},
		[GetSpellInfo(348)] = {
					["Name"] = "Immolate",
					["ID"] = 348,
					["Data"] = { 0.692, 0, 0.22, 0.439, 0, 0.176, ["c_scale"] = 0.55  },
					[0] = { School = { "Fire", "Destruction" }, Hits_dot = 5, eDuration = 15, sTicks = 3, },
					[1] = { 0, 0, hybridDotDmg = 0, },
		},
		[GetSpellInfo(1949)] = {
					["Name"] = "Hellfire",
					["ID"] = 1949,
					["Data"] = { 0.332, 0, 0.095, ["PPL"] = 0.4 },
					[0] = { School = { "Fire", "Destruction" }, Hits = 15, Channeled = 15, sTicks = 1, AoE = true },
					[1] = { 0, 0, },
		},
		[GetSpellInfo(5740)] = {
			-- Checked in 4.1
					["Name"] = "Rain of Fire",
					["ID"] = 5740,
					["Data"] = { 0.797, 0, 0.238, ["PPL"] = 0.3 },
					[0] = { School = { "Fire", "Destruction" }, Hits = 4, Channeled = 8, sTicks = 2, AoE = true },
					[1] = { 0, 0, },
		},
		[GetSpellInfo(30108)] = {
					["Name"] = "Unstable Affliction",
					["ID"] = 30108,
					["Data"] = { 0.232, 0, 0.2 },
					[0] = { School = { "Shadow", "Affliction", }, Hits = 5, eDot = true, eDuration = 15, sTicks = 3, },
					[1] = { 0, 0, },
		},
		[GetSpellInfo(17962)] = {
					["Name"] = "Conflagrate",
					["ID"] = 17962,
					[0] = { School = { "Fire", "Destruction" }, Cooldown = 10, },
					[1] = { 0, 0, },
		},
		[GetSpellInfo(27243)] = {
			-- Checked in 4.1
					["Name"] = "Seed of Corruption",
					["ID"] = 27243,
					["Data"] = { 0.766, 0.15, 0.229, 0.302, 0, 0.3  },
					["Data2"] = function(baseSpell, spell, playerLevel)
						baseSpell.Cap = 1.761 * self.Scaling[playerLevel]
						baseSpell.Cap_SPBonus = 0.143
					end,
					[0] = { School = { "Shadow", "Affliction", }, Hits_dot = 6, eDuration = 18, sTicks = 3, NoDotAverage = true, AoE = true },
					[1] = { 0, 0, hybridDotDmg = 0 },
		},
		[GetSpellInfo(30283)] = {
					["Name"] = "Shadowfury",
					["ID"] = 30283,
					["Data"] = { 0.783, 0.175, 0.214, ["PPL"] = 1.6, ["range"] = 65 },
					[0] = { School = { "Shadow", "Destruction" }, Cooldown = 20, AoE = true },
					[1] = { 0, 0, },
		},
		[GetSpellInfo(29722)] = {
					["Name"] = "Incinerate",
					["ID"] = 29722,
					["Data"] = { 0.573, 0.15, 0.539 },
					[0] = { School = { "Fire", "Destruction" }, },
					[1] = { 0, 0, 0, 0 },
		},
		[GetSpellInfo(47897)] = {
					["Name"] = "Shadowflame",
					["ID"] = 47987,
					["Data"] = { 0.727, 0.09, 0.102, ["PPL"] = 2 },
					[0] = { School = { "Shadow", "Destruction" }, Cooldown = 12, },
					[1] = { 0, 0, },
			["Secondary"] = {
					["Name"] = "Shadowflame",
					["ID"] = 47897,
					["Data"] = { 0, 0, 0, 0.169, 0, 0.2  },
					[0] = { School = { "Fire", "Destruction" }, Hits_dot = 3, eDuration = 6, sTicks = 2, Cooldown = 12 },
					[1] = { 0, 0, hybridDotDmg = 0 },
			},
		},
		[GetSpellInfo(48181)] = {
					["Name"] = "Haunt",
					["ID"] = 48181,
					["Data"] = { 0.958, 0, nil },
					[0] = { School = { "Shadow", "Affliction" }, SPBonus = 0.53625, Cooldown = 8 },
					[1] = { 0, 0, },
		},
		[GetSpellInfo(50796)] = {
					["Name"] = "Chaos Bolt",
					["ID"] = 50796,
					["Data"] = { 1.547, 0.238, 0.628, ["range"] = 225 },
					[0] = { School = { "Fire", "Destruction" }, Unresistable = true, Cooldown = 12, },
					[1] = { 0, 0, },
		},
		[GetSpellInfo(50589)] = {
					["Name"] = "Immolation Aura",
					["ID"] = 50589,
					["Data"] = { 0.589, 0, 0.1 },
					[0] = { School = "Fire", Channeled = 15, Hits = 15, sTicks = 1, Cooldown = 30, AoE = true, },
					[1] = { 0, 0, },
		},
		[GetSpellInfo(54785)] = {
					["Name"] = "Demon Leap",
					["ID"] = 54785,
					["Data"] = { 2.514, 0.17, 0.214, },
					[0] = { School = "Shadow", AoE = true, },
					[1] = { 0, 0, },
		},
		[GetSpellInfo(3110)] = {
					["Name"] = "Firebolt",
					["ID"] = 3110,
					["Data"] = { 0.123, 0.11, 0.657, ["ct_min"] = 2000, ["ct_max"] = 2500 },
					[0] = { School = { "Fire", "Pet" }, SPBonus = 0.657, NoGlobalMod = true, NoManaCalc = true, NoNext = true, NoMPS = true, NoDPM = true, NoDPSC = true },
					[1] = { 0, 0, },
		},
		[GetSpellInfo(54049)] = {
			-- Checked in 4.1
					["Name"] = "Shadow Bite",
					["ID"] = 54049,
					--Tooltip displays wrong base values, range is halved
					-- ["Data"] = { 0.163, 0.35 / 2 }, (4.0.3 values)
					["Data"] = { 0.326, 0.35 / 2 },
					[0] = { School = { "Shadow", "Pet" }, SPBonus = 0.614, Cooldown = 6, NoGlobalMod = true, NoManaCalc = true, NoNext = true, NoMPS = true, NoDPM = true, },
					[1] = { 0, 0, },
		},
		[GetSpellInfo(7814)] = {
			-- Checked in 4.1
					["Name"] = "Lash of Pain",
					["ID"] = 7814,
					--Tooltip displays wrong base values, multiplier of 1.5 seems to give correct values
					["Data"] = { 0.201 * 1.5, 0.16 / 1.5, ["c_scale"] = 1/3 },
					[0] = { School = { "Shadow", "Pet" }, SPBonus = 0.612, NoGlobalMod = true, NoManaCalc = true, NoNext = true, NoMPS = true, NoDPM = true, },
					[1] = { 0, 0, },
		},
		[GetSpellInfo(86121)] = {
					["Name"] = "Soul Swap",
					["ID"] = 86121,
					["Data"] = { 0.174, 0, 0.2 },
					[0] = { School = { "Shadow", "Affliction" }, },
					[1] = { 0, 0, },
		},
		[GetSpellInfo(71521)] = {
					["Name"] = "Hand of Gul'Dan",
					["ID"] = 71521,
					["Data"] = { 1.593, 0.166, 0.968 },
					[0] = { School = "Shadow", Cooldown = 12, AoE = true },
					[1] = { 0, 0, },
		},
		[GetSpellInfo(77799)] = {
					["Name"] = "Fel Flame",
					["ID"] = 77799,
					["Data"] = { 0.248, 0.15, 0.302 },
					[0] = { School = "Shadowflame", Double = { "Shadow", "Fire" }, },
					[1] = { 0, 0, },
		},
	}
	self.talentInfo = {
	--AFFLICTION
		--Doom and Gloom
		[GetSpellInfo(18827)] = { 	[1] = { Effect = 4, Spells = { "Bane of Agony", "Bane of Doom" }, ModType = "critPerc" }, },
		--Improved Life Tap
		[GetSpellInfo(18182)] = { 	[1] = { Effect = 0.1, Spells = "Life Tap", ModType = "Improved Life Tap" }, },
		--Improved Corruption (additive - 4.0)
		[GetSpellInfo(17810)] = {	[1] = { Effect = 0.04, Spells = "Corruption", ModType = "dmgM_dot_Add" }, },
		--Soul Siphon
		[GetSpellInfo(17804)] = { 	[1] = { Effect = 1, Spells = { "Drain Soul", "Drain Life" }, ModType = "Soul Siphon" }, },
		--Shadow Embrace (multiplicative - 4.0)
		[GetSpellInfo(32385)] = {	[1] = { Effect = { 0.03, 0.04, 0.05 }, Spells = "Shadow", Not = "Pet", ModType = "Shadow Embrace" }, },
		--Death's Embrace (multiplicative - 4.0)
		[GetSpellInfo(47198)] = {	[1] = { Effect = 1, Spells = { "Shadow", "Shadowflame" }, Not = "Pet", ModType = "Death's Embrace", }, },
		--Everlasting Affliction
		[GetSpellInfo(47201)] = {	[1] = { Effect = 5, Spells = { "Corruption", "Seed of Corruption", "Unstable Affliction" }, ModType = "critPerc" }, },
		--Pandemic
		[GetSpellInfo(85099)] = {	[1] = { Effect = -0.25, Spells = { "Bane of Agony", "Bane of Doom" }, ModType = "castTime" }, },
	--DEMONOLOGY
		--Dark Arts (additive? - doesn't matter)
		[GetSpellInfo(85284)] = {	[1] = { Effect = 0.05, Spells = "Shadow Bite", }, },
		--Demonic Aegis
		[GetSpellInfo(30143)] = { 	[1] = { Effect = 0.05, Spells = { "Death Coil" , "Drain Life" }, ModType = "Demonic Aegis" }, },
		--Molten Core (additive - 4.0)
		[GetSpellInfo(47245)] = {	[1] = { Effect = 1, Spells = "Incinerate", ModType = "Molten Core", }, },
		--Inferno (4.0.6)
		[GetSpellInfo(85105)] = {	[1] = { Effect = 6, Spells = "Immolate", ModType = "eDuration" }, },
		--Cremation (additive - 4.0)
		[GetSpellInfo(85104)] = { 	[1] = { Effect = 0.15, Spells = "Hellfire", }, },
		--Demonic Pact (multiplicative - 4.0)
		[GetSpellInfo(47236)] = {	[1] = { Effect = 0.02, Spells = "All", Not = "Pet", Multiply = true }, },
	--DESTRUCTION:
		--Shadow and Flame (additive - 4.0 - ?)
		[GetSpellInfo(17793)] = {	[1] = { Effect = 0.04, Spells = { "Shadow Bolt", "Incinerate" } }, },
		--Improved Immolate (additive?)
		[GetSpellInfo(17815)] = { 	[1] = { Effect = 0.1, Spells = { "Immolate", "Conflagrate" }, }, },
		--Improved Searing Pain
		[GetSpellInfo(17927)] = { 	[1] = { Effect = 20, Spells = "Searing Pain", ModType = "Improved Searing Pain", }, },
		--Backdraft
		[GetSpellInfo(47258)] = { 	[1] = { Effect = 0.1, Spells = { "Shadow Bolt", "Chaos Bolt", "Incinerate" }, ModType = "Backdraft", }, },
		--Burning Embers
		[GetSpellInfo(91986)] = { 	[1] = { Effect = 1, Spells = { "Firebolt", "Soul Fire" }, ModType = "Burning Embers", }, },
		--Fire and Brimstone (multiplicative?)
		[GetSpellInfo(47266)] = {	[1] = { Effect = 5, Spells = "Conflagrate", ModType = "critPerc", },
									[2] = { Effect = 0.02, Spells = { "Incinerate", "Chaos Bolt" }, ModType = "Fire and Brimstone" }, },
	}
end