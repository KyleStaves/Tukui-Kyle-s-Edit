if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then return end
local GetSpellInfo = DrDamage.SafeGetSpellInfo
local GetInventoryItemLink = GetInventoryItemLink
local GetShapeshiftForm = GetShapeshiftForm
local UnitPower = UnitPower
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsUnit = UnitIsUnit
local UnitCreatureType = UnitCreatureType
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff
local string_lower = string.lower
local string_find = string.find
local string_split = string.split
local math_floor = math.floor
local tonumber = tonumber
local select = select
local math_max = math.max
local math_min = math.min
local IsSpellKnown = IsSpellKnown

--Spell hit abilities: Icy Touch, Blood Boil, Death Coil, Death and Decay, Howling Blast. (Unholy Blight, Corpse Explosion?)

function DrDamage:PlayerData()
	--Health updates
	self.TargetHealth = { [1] = 0.351 }
	--Class specials
	--Death Pact 4.0
	self.ClassSpecials[GetSpellInfo(48743)] = function()
		return 0.25 * UnitHealthMax("player"), true
	end
--TALENTS
	self.Calculation["Threat of Thassarian"] = function( calculation, value )
		calculation.DualAttack = 0.5
		calculation.OffhandChance = value
	end
	self.Calculation["Might of the Frozen Wastes"] = function( calculation, value )
		if self:GetNormM() == 3.3 then
			--"Death Coil", "Blood Boil", "Death and Decay", "Plague Strike", "Howling Blast", "Icy Touch", "Chains of Ice"
			if calculation.spellName == "Plague Strike" then
				calculation.dmgM_Extra = calculation.dmgM_Extra / (1 + value)
			elseif not calculation.healingSpell then
				calculation.dmgM = calculation.dmgM / (1 + value)
			end
		end
	end
--GENERAL
	self.Calculation["Stats"] = function( calculation, ActiveAuras, Talents, spell, baseSpell )
		local mastery = calculation.mastery
		local masteryLast = calculation.masteryLast
		local spec = calculation.spec
		if spec == 2 then
			if mastery > 0 and mastery ~= masteryLast then
				if calculation.school == "Frost" then
					local masteryBonus = calculation.masteryBonus
					if masteryBonus then
						calculation.dmgM = calculation.dmgM / masteryBonus
					end
					local bonus = (1 + mastery * 0.01 * 2)
					calculation.dmgM = calculation.dmgM * bonus
					calculation.masteryLast = mastery
					calculation.masteryBonus = bonus
				end
			end
		elseif spec == 3 then
			if mastery > 0 and mastery ~= masteryLast then
				if calculation.school == "Shadow" and not calculation.healingSpell then
					local masteryBonus = calculation.masteryBonus
					if masteryBonus then
						calculation.dmgM = calculation.dmgM / masteryBonus
					end
					--Mastery: Dreadblade
					local bonus = 1 + mastery * 0.01 * 2.5
					calculation.dmgM = calculation.dmgM * bonus
					calculation.masteryLast = mastery
					calculation.masteryBonus = bonus
				--Custom Dreadblade implementation for Scourge Strike
				elseif calculation.shadowBonus then
					local masteryBonus = calculation.masteryBonus
					if masteryBonus then
						calculation.dmgM = calculation.dmgM / masteryBonus
					else
						calculation.dmgM = calculation.dmgM / (1 + calculation.shadowBonus)
					end
					--Mastery: Dreadblade
					local bonus = calculation.shadowBonus * (1 + mastery * 0.01 * 2.5)
					calculation.dmgM = calculation.dmgM * (1 + bonus)
					calculation.masteryLast = mastery
					calculation.masteryBonus = (1 + bonus)
				end
			end
		end
	end
	local undead = string_lower(GetSpellInfo(5502))
	local ri = "|T" .. select(3,GetSpellInfo(53343)) .. ":16:16:1:-1|t"
	local lb = "|T" .. select(3,GetSpellInfo(53331)) .. ":16:16:1:-1|t"
	local diseaseCount = 0
	self.Calculation["DEATHKNIGHT"] = function( calculation, ActiveAuras, Talents, spell, baseSpell )
		--Module variables
		local spec = calculation.spec
		diseaseCount = 0
		if ActiveAuras["Frost Fever"] then diseaseCount = 1 end
		if ActiveAuras["Blood Plague"] then diseaseCount = diseaseCount + 1 end
		if ActiveAuras["Ebon Plague"] then diseaseCount = diseaseCount + 1 end
		--Specialization
		if spec == 2 then
			--TODO: Check specialization is active
			if IsSpellKnown(86524) then
				calculation.strM = calculation.strM * 1.05
			end
			if calculation.mastery > 0 then
				Talents["Frozen Heart"] = calculation.mastery * 0.01 * 2
			end
		elseif spec == 3 then
			--TODO: Check specialization is active
			if IsSpellKnown(86524) then
				calculation.strM = calculation.strM * 1.05
			end
			--Passive: Unholy Might
			calculation.strM = calculation.strM * 1.05
		end
		if baseSpell.Melee then
			if baseSpell.SpellCrit then
				calculation.critM = calculation.critM + 0.5
			end
		else
			calculation.SPBonus = 0
			calculation.SPBonus_dot = 0
			calculation.critM = calculation.critM + 0.5
			if calculation.instant and GetShapeshiftForm() == 3 then
				calculation.castTime = 1
			end
		end
		if not calculation.healingSpell then
			if Talents["Merciless Combat"] and UnitHealth("target") ~= 0 and (UnitHealth("target") / UnitHealthMax("target")) <= 0.35 then
				--Multiplicative - 3.3.3
				calculation.dmgM_dd = calculation.dmgM_dd + (1 * Talents["Merciless Combat"])
			end
			if calculation.WeaponDamage and calculation.group ~= "Disease" then
				local lichbane, lichbane_O, razorice, razorice_O
				local mh = GetInventoryItemLink("player",16)
				if mh then
					local _, _, rune = string_split(":",mh)
					lichbane = (rune == "3366")
					razorice = (rune == "3370")
				end
				if (baseSpell.AutoAttack or calculation.DualAttack) and calculation.offHand then
					local _, _, rune = string_split(":",GetInventoryItemLink("player",17))
					lichbane_O = (rune == "3366")
					razorice_O = (rune == "3370")
				end
				--Rune of Razorice (3370) 2% extra weapon damage as Frost damage
				if razorice or razorice_O then
					local min, max = self:GetMainhandBase()
					--Cinderglacier applies. Seems like Frost Vulnerability doesn't.
					local bonus = math_max(1, 0.02 * (1/2) * (min+max) * calculation.dmgM_Magic * (1 + (Talents["Frozen Heart"] or 0)) * (ActiveAuras["Cinderglacier"] or 1)) --* (ActiveAuras["Frost Vulnerability"] or 1)
					calculation.extraDamage = 0
					if razorice then
						calculation.extraDamBonus = bonus
						calculation.extraName = ri
					end
					if razorice_O then
						calculation.extraDamBonus_O = bonus
						calculation.extraName = calculation.extraName and (calculation.extraName .. "+" .. ri) or ri
					end
				end
				--Rune of Lichbane (3366) 2% extra weapon damage as Fire damage or 4% versus Undead targets.
				if lichbane or lichbane_O then
					local min, max = self:GetMainhandBase()
					local target = UnitCreatureType("target")
					local bonus = math_max(1, 0.02 * (1/2) * (min+max) * calculation.dmgM_Magic)
					if target and string_find(undead,string_lower(target)) then
						bonus = 2 * bonus
					end
					calculation.extraDamage = 0
					if lichbane then
						calculation.extraDamBonus = bonus
						calculation.extraName = calculation.extraName and (calculation.extraName .. "+" .. lb) or lb
					end
					if lichbane_O then
						calculation.extraDamBonus_O = bonus
						calculation.extraName = calculation.extraName and (calculation.extraName .. "+" .. lb) or lb
					end
				end
			end
		end
	end
--ABILITIES
	local bcb = "|T" .. select(3,GetSpellInfo(49219)) .. ":16:16:1:-1|t"
	self.Calculation["Attack"] = function( calculation, ActiveAuras, Talents )
		if Talents["Blood-Caked Blade"] then
			local mh = not calculation.unarmed
			local oh = calculation.offHand
			if mh or oh then
				calculation.extraDamage = 0
				calculation.extraName = calculation.extraName and (calculation.extraName .. "+" .. bcb) or bcb
				calculation.extraWeaponDamageChance = Talents["Blood-Caked Blade"]
				calculation.extraWeaponDamageM = true
			end
			if mh then
				calculation.extraWeaponDamage = 0.25 + diseaseCount * 0.125
			end
			if oh then
				calculation.extraWeaponDamage_O = 0.25 + diseaseCount * 0.125
			end
		end
	end
	self.Calculation["Blood Strike"] = function( calculation, ActiveAuras )
		--Multiplicative - 3.3.3
		calculation.dmgM = calculation.dmgM * (1 + diseaseCount * 0.125 * ((self:GetSetAmount( "T8 - Damage" ) >= 4) and 1.2 or 1))
		if self:GetSetAmount( "T9 - Defense" ) >= 2 then
			--Additive - 3.3.3
			calculation.dmgM_Add = calculation.dmgM_Add + 0.05
		end
	end
	self.Calculation["Heart Strike"] = function( calculation )
		--Multiplicative - 3.3.3
		calculation.dmgM = calculation.dmgM * (1 + diseaseCount * 0.15 * ((self:GetSetAmount( "T8 - Damage" ) >= 4) and 1.2 or 1))
		if self:GetSetAmount( "T9 - Defense" ) >= 2 then
			--Additive - 3.3.3
			calculation.dmgM_Add = calculation.dmgM_Add + 0.05
		end
		if self:GetSetAmount( "T10 - Damage" ) >= 2 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.07
		end
		--Glyph of Heart Strike 4.0
		if self:HasGlyph(58616) then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.3
		end
	end
	self.Calculation["Obliterate"] = function( calculation )
		if diseaseCount > 0 then
			--Additive - 3.3.3
			calculation.dmgM_Add = calculation.dmgM_Add + diseaseCount * 0.125 * ((self:GetSetAmount( "T8 - Damage" ) >= 4) and 1.2 or 1)
		end
		--Glyph of Obliterate 4.0
		if self:HasGlyph(58671) then
			--Additive - 3.3.3
			calculation.dmgM_Add = calculation.dmgM_Add + 0.2
		end
		if self:GetSetAmount( "T7 - Damage" ) >= 2 then
			calculation.critPerc = calculation.critPerc + 5
		end
		if self:GetSetAmount( "T10 - Damage" ) >= 2 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
	end
	local ff = GetSpellInfo(59921)
	self.Calculation["Icy Touch"] = function( calculation, _, Talents )
		calculation.extra = 0.32 * calculation.playerLevel * 1.15
		calculation.extraName = ff
		--Glyph of Icy Touch 4.0
		if self:HasGlyph(58631) then
			calculation.dmgM_Extra_Add = calculation.dmgM_Extra_Add + 0.2
		end
	end
	self.Calculation["Chains of Ice"] = function( calculation, _, Talents )
		calculation.extra = 0.32 * calculation.playerLevel * 1.15
		calculation.extraName = ff
		--Glyph of Icy Touch 4.0
		if self:HasGlyph(58631) then
			calculation.dmgM_Extra_Add = calculation.dmgM_Extra_Add + 0.2
		end
		--Glyph of Chains of Ice 4.0
		if self:HasGlyph(58620) then
			calculation.minDam = 144
			calculation.maxDam = 156
			--TODO: Verify AP bonus
			calculation.APBonus = 0.08
		end
	end
	self.Calculation["Howling Blast"] = function( calculation, _, Talents, spell )
		calculation.aoeM = 0.5
		--Glyph of Howling Blast 4.0
		if self:HasGlyph(63335) then
			calculation.extra = 0.32 * calculation.playerLevel * 1.15
			calculation.extraName = ff
			calculation.extraDamage = 0.055 * 1.15
			--Glyph of Icy Touch 4.0
			if self:HasGlyph(58631) then
				calculation.dmgM_Extra_Add = calculation.dmgM_Extra_Add + 0.2
			end
		end
	end
	local bp = GetSpellInfo(59879)
	self.Calculation["Plague Strike"] = function( calculation, ActiveAuras, Talents )
		calculation.extra = 0.394 * calculation.playerLevel * 1.15
		calculation.extraName = bp
		calculation.dmgM_Extra = calculation.dmgM_Extra * calculation.dmgM_Magic
		if self:GetSetAmount( "T7 - Defense" ) >= 2 then
			calculation.critPerc = calculation.critPerc + 10
		end
		if self:GetSetAmount( "T9 - Damage" ) >= 4 then
			calculation.dmgM_Extra_Add = calculation.dmgM_Extra_Add + 0.1
		end
	end
	self.Calculation["Scourge Strike"] = function( calculation, ActiveAuras, Talents )
		if diseaseCount > 0 then
			--Multiplicative - 3.3.3
			local shadow = calculation.dmgM_Magic * (ActiveAuras["Cinderglacier"] or 1)
			calculation.shadowBonus = diseaseCount * 0.18 * shadow * ((self:GetSetAmount( "T8 - Damage" ) >= 4) and 1.2 or 1) * (self:HasGlyph(58642) and 1.3 or 1)
			--Glyph of Scourge Strike 4.0
			calculation.dmgM = calculation.dmgM * (1 + calculation.shadowBonus)
			--Is this a better way of displaying it?
			--calculation.extraDamage = 0
			--calculation.extraAvg = diseaseCount * 0.12 * ((self:GetSetAmount( "T8 - Damage" ) >= 4) and 1.2 or 1) * (self:HasGlyph(58642) and 1.3 or 1))
			--calculation.dmgM_Extra = calculation.dmgM_Extra * shadow
		end
		if self:GetSetAmount( "T7 - Damage" ) >= 2 then
			calculation.critPerc = calculation.critPerc + 5
		end
		if self:GetSetAmount( "T10 - Damage" ) >= 2 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
	end
	self.Calculation["Blood Boil"] = function( calculation, ActiveAuras )
		if ActiveAuras["Blood Plague"] or ActiveAuras["Frost Fever"] then
			local bonus = self:ScaleData(0.159) --TODO: Verify
			calculation.minDam = calculation.minDam + bonus
			calculation.maxDam = calculation.maxDam + bonus
			calculation.APBonus = calculation.APBonus + 0.0476 --TODO: Verify
		end
	end
	self.Calculation["Frost Strike"] = function( calculation, _, Talents )
		if self:GetSetAmount( "T8 - Damage" ) >= 2 then
			calculation.critPerc = calculation.critPerc + 8
		end
		if self:GetSetAmount( "T11 - Damage" ) >= 2 then
			calculation.critPerc = calculation.critPerc + 5
		end
	end
	local ub = "|T" .. select(3,GetSpellInfo(49194)) .. ":16:16:1:-1|t"
	self.Calculation["Death Coil"] = function( calculation, _, Talents )
		if calculation.healingSpell then
			--Glyph of Death's Embrace 4.0
			if self:HasGlyph(58677) then
				calculation.manaCost = calculation.manaCost - 20
			end
		else
			if Talents["Unholy Blight"] then
				calculation.extraName = ub
				calculation.extraTicks = 10
				calculation.extraAvg = 0.1
			end
		end
		--Glyph of Dark Death 4.0
		if self:HasGlyph(63333) then
			--Additive - 3.3.3
			calculation.dmgM_Add = calculation.dmgM_Add + 0.15
		end
		if self:GetSetAmount( "T8 - Damage" ) >= 2 then
			calculation.critPerc = calculation.critPerc + 8
		end
		if self:GetSetAmount( "T11 - Damage" ) >= 2 then
			calculation.critPerc = calculation.critPerc + 5
		end
	end
	self.Calculation["Death and Decay"] = function( calculation )
		--Glyph of Death and Decay 4.0
		if self:HasGlyph(58629) then
			calculation.eDuration = calculation.eDuration + 5
		end
		if self:GetSetAmount( "T10 - Defense" ) >= 2 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.2
		end
	end
	self.Calculation["Death Strike"] = function( calculation )
		--Glyph of Death Strike 4.0
		--Increase damage by 2% for every 5 RP with a maximum of 40%
		if self:HasGlyph(59336) then
			local power = math_floor(UnitPower("player", 6) / 5)
			--Multiplicative - 3.3.3
			calculation.dmgM = calculation.dmgM * math_min(1.4,1 + 0.02 * power)
		end
		if self:GetSetAmount( "T7 - Damage" ) >= 2 then
			calculation.critPerc = calculation.critPerc + 5
		end
		if self:GetSetAmount( "T11 - Defense" ) >= 2 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.05
		end
	end
	self.Calculation["Rune Strike"] = function( calculation )
		--Glyph of Rune Strike 4.0
		if self:HasGlyph(58669) then
			calculation.critPerc = calculation.critPerc + 10
		end
		if self:GetSetAmount( "T8 - Defense" ) >= 2 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
	end
	self.Calculation["Rune Tap"] = function( calculation, _, Talents )
		calculation.minDam = UnitHealthMax("player")
		calculation.maxDam = calculation.minDam
		calculation.dmgM = 0.1 * (1 + (Talents["Improved Rune Tap"] or 0))
	end
--[[
	self.Calculation["Summon Gargoyle"] = function( calculation )
		--Assume one second is wasted
		calculation.hits = math_floor((30 - 1) / (2 / calculation.haste))
		calculation.APBonus = calculation.APBonus * calculation.hits
		calculation.haste = 1
		calculation.canCrit = true
		calculation.critM = 0.5
		calculation.critPerc = 5
		calculation.critM_custom = true
	end
--]]
--SETS
	self.SetBonuses["T7 - Damage"] =
		{ 39617, 39618, 39619 , 39620 , 39621, --T7
		40550, 40552, 40554, 40556, 40557 } --T7.5
	self.SetBonuses["T7 - Defense"] =
		{ 39623, 39624, 39625, 39626, 39627, --T7
		40559, 40563, 40565, 40567, 40568 } --T7.5
	self.SetBonuses["T8 - Damage"] =
		{ 45340, 45341, 45342, 45343, 45344, --T8
		46111, 46113, 46115, 46116, 46117 } --T8.5
	self.SetBonuses["T8 - Defense"] =
		{ 45335, 45336, 45337, 45338, 45339, --T8
		46118, 46119, 46120, 46121, 46122 } --T8.5
	self.SetBonuses["T9 - Damage"] =
		{ 48501, 48502, 48503, 48504, 48505,
		48472, 48474, 48476, 48478, 48480,
		48481, 48482, 48483, 48484, 48485,
		48490, 48489, 48488, 48487, 48486,
		48500, 48499, 48498, 48497, 48496,
		48491, 48492, 48493, 48494, 48495 }
	self.SetBonuses["T9 - Defense"] =
		{ 48558, 48559, 48560, 48561, 48562,
		48529, 48531, 48533, 48535, 48537,
		48557, 48555, 48556, 48554, 48553,
		48548, 48550, 48549, 48551, 48552,
		48538, 48540, 48539, 48541, 48542,
		48547, 48545, 48546, 48544, 48543 }
	self.SetBonuses["T10 - Damage"] =
		{ 50098, 50097, 50096, 50095, 50094,
		51125, 51314, 51126, 51313, 51127,
		51312, 51128, 51311, 51129, 51310 }
	self.SetBonuses["T10 - Defense"] =
		{ 50853, 50854, 50855, 50856, 50857,
		51130, 51309, 51131, 51308, 51132,
		51307, 51133, 51306, 51134, 51305 }
	self.SetBonuses["T11 - Damage"] = { 60339, 60340, 60341, 60342, 60343, 65179, 65180, 65181, 65182, 65183 }
	self.SetBonuses["T11 - Defense"] = { 60349, 60350, 60351, 60352, 60353, 65184, 65185, 65186, 65187, 65188 }
--AURA
--Player
	--Killing Machine 4.0
	self.PlayerAura[GetSpellInfo(51124)] = { Spells = { "Obliterate", "Frost Strike" }, Value = 100, ModType = "critPerc", ID = 51124 }
	--Cinderglacier 4.0
	self.PlayerAura[GetSpellInfo(53386)] = { ID = 53386, ModType =
		function( calculation, ActiveAuras )
			if calculation.school == "Frost" or calculation.school == "Shadow" then
				calculation.dmgM = calculation.dmgM * 1.2
			elseif calculation.group == "Disease" then
				calculation.dmgM_Extra = calculation.dmgM_Extra * 1.2
			else
				ActiveAuras["Cinderglacier"] = 1.2
			end
		end
	}
	--Vampiric Blood 4.0
	self.PlayerAura[GetSpellInfo(55233)] = { School = "Healing", NoManual = true, ModType =
		function( calculation )
			--Glyph of Vampiric Blood 4.0
			calculation.dmgM = calculation.dmgM * (1.25 + (self:HasGlyph(58676) and 0.15 or 0))
		end
	}
	--Pillar of Frost 4.0
	self.PlayerAura[GetSpellInfo(51271)] = { ID = 51271, ModType = "strM", Multiply = true, Value = 0.2, NoManual = true }
	--Unholy Strength 4.0
	self.PlayerAura[GetSpellInfo(53365)] = { ID = 53365, ModType = "strM", Multiply = true, Value = 0.15, NoManual = true }
--Target
	--Frost Fever 4.0
	self.TargetAura[GetSpellInfo(55095)] = { ActiveAura = "Frost Fever", SelfCast = true, ID = 55095 }
	--Blood Plague 4.0
	self.TargetAura[GetSpellInfo(55078)] = { ActiveAura = "Blood Plague", SelfCast = true, ID = 55078 }
	--Frost Vulnerability 4.0 (Rune of Razorice)
	self.TargetAura[GetSpellInfo(51714)] = { Apps = 5, SelfCast = true, ID = 51714, ModType =
		function( calculation, ActiveAuras, _, _, apps )
			if calculation.school == "Frost" then
				calculation.dmgM = calculation.dmgM * (1 + 0.02 * apps)
			elseif calculation.spellName == "Attack" then
				ActiveAuras["Frost Vulnerability"] = 1 + 0.02 * apps
			end
		end
	}
	--Ebon Plague 4.0
	self.TargetAura[GetSpellInfo(65142)] = { Category = "+8% dmg", SkipCategory = true, ID = 65142, ModType =
		function( calculation, ActiveAuras, _, index, _, _, rank )
			if not ActiveAuras["+8% dmg"] then
				calculation.dmgM_Magic = calculation.dmgM_Magic * 1.08
				ActiveAuras["+8% dmg"] = true
			end
			if calculation.group == "Disease" then
				calculation.dmgM_Extra = calculation.dmgM_Extra * 1.3
			end
			if index then
				local unit = select(8,UnitDebuff("target",index))
				if unit and UnitIsUnit("player",unit) then
					ActiveAuras["Ebon Plague"] = true
				end
			else
				ActiveAuras["Ebon Plague"] = true
			end
		end
	}
	self.spellInfo = {
		--BLOOD
		[GetSpellInfo(45902)] = {
				["Name"] = "Blood Strike",
				["ID"] = 45902,
				["Data"] = { 0.756 * 0.8 },
				[0] = { Melee = true, WeaponDamage = 0.8 },
				[1] = { 0 },
		},
		[GetSpellInfo(55050)] = {
				["Name"] = "Heart Strike",
				["ID"] = 55050,
				["Data"] = { 0.728 },
				[0] = { Melee = true, WeaponDamage = 1.75, ChainFactor = 0.75, AoE = 3 },
				[1] = { 0 },
		},
		[GetSpellInfo(48721)] = {
				["Name"] = "Blood Boil",
				["ID"] = 48721,
				["Data"] = { 0.317 },
				[0] = { School = "Shadow", APBonus = 0.08 * 1.2, AoE = true },
				[1] = { 0, 0 },
		},
		[GetSpellInfo(48982)] = {
				["Name"] = "Rune Tap",
				["ID"] = 48982,
				[0] = { School = { "Shadow", "Healing" }, Cooldown = 30 },
				[1] = { 0, 0 }
		},
		--TODO: Figure out how tooltip works in conjunction with Imp. Death Strike
		[GetSpellInfo(49998)] = {
				["Name"] = "Death Strike",
				["ID"] = 49998,
				["Data"] = { 0.294 * 1.5 },
				[0] = { Melee = true, WeaponDamage = 1.5 },
				[1] = { 0 },
		},
		--FROST
		--HOTFIX 4.1: Obliterate has been reduced from 160% to 150% base weapon damage.
		[GetSpellInfo(49020)] = {
				["Name"] = "Obliterate",
				["ID"] = 49020,
				["Data"] = { 0.578 * 1.5 },
				[0] = { Melee = true, WeaponDamage = 1.5 },
				[1] = { 0 },
		},
		[GetSpellInfo(49143)] = {
				["Name"] = "Frost Strike",
				["ID"] = 49143,
				["Data"] = { 0.247 * 1.3 },
				[0] = { School = "Frost", Melee = true, WeaponDamage = 1.3 },
				[1] = { 0 },
		},
		[GetSpellInfo(56815)] = {
				["Name"] = "Rune Strike",
				["ID"] = 56815,
				[0] = { Melee = true, WeaponDamage = 1.8, APBonus = 0.15, NoNormalization = true, Unavoidable = true },
				[1] = { 0 },
		},
		[GetSpellInfo(45477)] = {
				["Name"] = "Icy Touch",
				["ID"] = 45477,
				["Data"] = { 0.468, 0.083 },
				[0] = { School = { "Frost", "Disease", "Spell" }, Melee = true, APBonus = 0.2, APBonus_extra = 0.055 * 1.15, Hits_extra = 7, E_eDuration = 21, E_canCrit = true, E_Ticks = 3, SpellHit = true, SpellCrit = "Frost", },
				[1] = { 0, 0, },
		},
		[GetSpellInfo(45524)] = {
				["Name"] = "Chains of Ice",
				["ID"] = 45524,
				--["Data"] = { 0, 0 },
				[0] = { School = { "Frost", "Disease", "Spell" }, Melee = true, APBonus_extra = 0.055 * 1.15, Hits_extra = 7, E_eDuration = 21, E_Ticks = 3, E_canCrit = true, SpellHit = true, SpellCrit = "Frost", },
				[1] = { 0, 0 },
		},
		--HOTFIX 4.1: Howling Blast has been reduced by approxomately 8-9%.
		[GetSpellInfo(49184)] = {
				["Name"] = "Howling Blast",
				["ID"] = 49184,
				["Data"] = { 1.281 * 0.915, 0.0996 },
				--NOTE: Marked as Disease and E_eDuration for Glyph
				[0] = { School = { "Frost", "Disease", "Spell" }, Melee = true, APBonus = 0.48 * 0.915, Hits_extra = 7, E_eDuration = 21, E_Ticks = 3, E_canCrit = true, SpellHit = true, SpellCrit = "Frost", AoE = true, E_AoE = true, MixedAoE = true },
				[1] = { 0, 0 },
		},
		[GetSpellInfo(85948)] = {
				["Name"] = "Festering Strike",
				["ID"] = 85948,
				["Data"] = { 0.498 --[[* 1.5--]] },
				[0] = { Melee = true, WeaponDamage = 1.5 },
				[1] = { 0 },
		},
		--UNHOLY
		[GetSpellInfo(45462)] = {
				["Name"] = "Plague Strike",
				["ID"] = 45462,
				["Data"] = { 0.374 * 1 },
				[0] = { School = { "Physical", "Disease" }, Melee = true, WeaponDamage = 1, APBonus_extra = 0.055 * 1.15, Hits_extra = 7, E_eDuration = 21, E_Ticks = 3, E_canCrit = true },
				[1] = { 0 },
		},
		[GetSpellInfo(55090)] = {
				["Name"] = "Scourge Strike",
				["ID"] = 55090,
				["Data"] = { 0.555 * 1 },
				[0] = { Melee = true, WeaponDamage = 1 },
				[1] = { 0 },
		},
		--HOTFIX: Death Coil damage has been reduced by 15%.
		[GetSpellInfo(47541)] = {
				["Name"] = "Death Coil",
				["Text1"] = GetSpellInfo(47541),
				["Text2"] = GetSpellInfo(48360),
				["ID"] = 47541,
				["Data"] = { 0.876 * 0.85 },
				[0] = { School = "Shadow", APBonus = 0.27 * 0.85 },
				[1] = { 0, 0 },
			["Secondary"] = {
				["Name"] = "Death Coil",
				["Text1"] = GetSpellInfo(47541),
				["Text2"] = GetSpellInfo(37455),
				["ID"] = 47541,
				["Data"] = { 0.876 * 3.5 },
				[0] = { School = { "Shadow", "Healing" }, APBonus = 0.27 * 3.5 },
				[1] = { 0, 0 },
			},
		},
		[GetSpellInfo(43265)] = {
				["Name"] = "Death and Decay",
				["ID"] = 43265,
				["Data"] = { 0.041 },
				[0] = { School = "Shadow", APBonus = 0.064, eDot = true, eDuration = 10, Hits = 10, Cooldown = 30, AoE = true, NoPeriod = true },
				[1] = { 0, 0, },
		},
		[GetSpellInfo(73975)] = {
				["Name"] = "Necrotic Strike",
				["ID"] = 73975,
				[0] = { Melee = true, WeaponDamage = 1 },
				[1] = { 0 },
		},
		--[GetSpellInfo(49206)] = {
		--		["Name"] = "Summon Gargoyle",
		--		[0] = { School = "Nature", eDot = true, eDuration = 30, SPBonus = 0, APBonus = 0.35, BaseIncrease = true, MeleeHit = true, MeleeHaste = true, CustomHaste = true, NoNext = true, NoPeriod = true },
		--		[1] = { 51, 69, 57, 77, spellLevel = 60 }
		--},
	}
	self.talentInfo = {
	--BLOOD
		--Blood-Caked Blade 4.0
		[GetSpellInfo(49219)] = {	[1] = { Effect = 0.1, Spells = "Attack", ModType = "Blood-Caked Blade" }, },
		--Abomination's Might 4.0
		[GetSpellInfo(53137)] = {	[1] = { Effect = 0.01, Spells = "All", Multiply = true, ModType = "strM" }, NoManual = true },
		--Improved Death Strike 4.0 - additive?
		[GetSpellInfo(62905)] = {	[1] = { Effect = 0.3, Spells = "Death Strike" },
									[2] = { Effect = 3, Spells = "Death Strike", ModType = "critPerc" }, },
		--Crimson Scourge 4.0
		[GetSpellInfo(81135)] = { 	[1] = { Effect = 0.2, Spells = "Blood Boil" }, },
	--FROST
		--Nerves of Cold Steel 4.0
		[GetSpellInfo(49226)] = {	[1] = { Effect = { 0.08, 0.16, 0.25 }, Melee = true, Spells = { "Attack", "Death Strike", "Obliterate", "Plague Strike", "Blood Strike", "Frost Strike" }, ModType = "offHdmgM", Multiply = true },
									[2] = { Effect = { 0.08, 0.16, 0.25 }, Melee = true, Spells = { "Death Strike", "Obliterate", "Plague Strike", "Blood Strike", "Frost Strike" }, ModType = "bDmgM_O", Multiply = true }, NoManual = true },
		--Annihilation 4.0
		[GetSpellInfo(51468)] = {	[1] = { Effect = 0.15, Melee = true, Spells = "Obliterate" }, },
		--Merciless Combat 4.0 (multiplicative - 3.3.3)
		[GetSpellInfo(49024)] = {	[1] = { Effect = 0.06, Spells = { "Icy Touch", "Howling Blast", "Obliterate", "Frost Strike" }, ModType = "Merciless Combat" }, },
		--Brittle Bones 4.0
		[GetSpellInfo(81327)] = {	[1] = { Effect = 0.02, Spells = "All", Multiply = true, ModType = "strM" }, NoManual = true },
		--Threat of Thassarian 4.0
		[GetSpellInfo(65661)] = {	[1] = { Effect = { 0.3, 0.6, 1 }, Spells = { "Death Strike", "Obliterate", "Plague Strike", "Blood Strike", "Frost Strike", "Rune Strike" }, ModType = "Threat of Thassarian" }, },
		--Might of the Frozen Wastes
		[GetSpellInfo(81135)] = { 	[1] = { Effect = 0.04, Spells = { "Death Coil", "Blood Boil", "Death and Decay", "Plague Strike", "Howling Blast", "Icy Touch", "Chains of Ice", "Festering Strike" }, ModType = "Might of the Frozen Wastes" }, NoManual = true },
	--UNHOLY
		--Virulence 4.0.6
		[GetSpellInfo(48962)] = {	[1] = { Effect = 0.1, Spells = { "Icy Touch", "Chains of Ice", "Howling Blast", "Plague Strike" }, ModType = "dmgM_Extra_Add" }, },
		--Epidemic 4.0
		[GetSpellInfo(49036)] = {	[1] = { Effect = 4, Spells = { "Icy Touch", "Chains of Ice", "Howling Blast", "Plague Strike" }, ModType = "E_eDuration" }, },
		--Morbidity 4.0 (additive - 3.3.3)
		[GetSpellInfo(48963)] = {	[1] = { Effect = 0.05, Spells = "Death Coil" },
									[2] = { Effect = 0.1, Spells = "Death and Decay" }, },
		--Rage of Rivendare 4.0
		[GetSpellInfo(51745)] = {	[1] = { Effect = 0.15, Spells = { "Plague Strike", "Scourge Strike", "Festering Strike" }, }, },
		--Unholy Blight 4.0
		[GetSpellInfo(49194)] = {	[1] = { Effect = 1, Caster = true, Spells = "Death Coil", ModType = "Unholy Blight" }, },
	}
end