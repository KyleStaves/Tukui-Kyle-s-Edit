if select(2, UnitClass("player")) ~= "PALADIN" then return end
local GetSpellInfo = DrDamage.SafeGetSpellInfo
local GetTrackingTexture = GetTrackingTexture
local GetSpellBonusDamage = GetSpellBonusDamage
local math_floor = math.floor
local math_min = math.min
local string_match = string.match
local string_find = string.find
local string_lower = string.lower
local tonumber = tonumber
local select = select
local pairs = pairs
local UnitBuff = UnitBuff
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitCreatureType = UnitCreatureType
local UnitIsUnit = UnitIsUnit
local IsSpellKnown = IsSpellKnown

function DrDamage:PlayerData()
	--Events
	local lastPower = UnitPower("player",9)
	self.Calculation["UNIT_POWER"] = function()
		local power = UnitPower("player",9)
		if power ~= lastPower then
			lastPower = power
			--TODO: Add which spells to update
			self:UpdateAB()
		end
	end
	--Lay on Hands (4.0)
	self.ClassSpecials[GetSpellInfo(633)] = function()
		return UnitHealthMax("player"), true
	end
	--Divine Plea (4.0)
	self.ClassSpecials[GetSpellInfo(54428)] = function()
		--Glyph of Divine Plea 4.0
		return (0.12 + (self:HasGlyph(63223) and 0.06 or 0)) * UnitPowerMax("player",0), false, true
	end
	--Seal of Insight Heal (4.0)
	self.ClassSpecials[GetSpellInfo(20165)] = function()
		local AP = 0.15 * self:GetAP()
		local SP = 0.15 * GetSpellBonusDamage(2)
		return AP + SP, true
	end
--GENERAL
	local hol_icon = "|T" .. select(3,GetSpellInfo(76672)) .. ":16:16:1:-1|t"
	self.Calculation["Stats"] = function( calculation, ActiveAuras, Talents, spell, baseSpell )
		local mastery = calculation.mastery
		local masteryLast = calculation.masteryLast
		local spec = calculation.spec
		if spec == 1 then
			-- Updated for 4.1 -- Illuminated Healing bonus increased from 1.25% to 1.5% per mastery
			if mastery > 0 and mastery ~= masteryLast then
				if calculation.healingSpell and calculation.spellName ~= "Holy Radiance" and calculation.spellName ~= "Light of Dawn" then
					--Mastery: Illuminated Healing
					calculation.extraAvg = mastery * 0.01 * 1.5
					calculation.masteryLast = mastery
				end
			end
		elseif spec == 2 then
			if calculation.str ~= 0 then
				---Increases your spell power by an amount equal to 60% of your Strength.
				calculation.SP_mod = calculation.SP_mod + 0.6 * calculation.str
			end
		elseif spec == 3 then
			if mastery > 0 and mastery ~= masteryLast then
				if baseSpell.HandOfLight then
					--local masteryBonus = calculation.masteryBonus
					--if masteryBonus then
					--	calculation.dmgM = calculation.dmgM / masteryBonus
					--end
					--Mastery: Hand of Light
					--BUG?: Seems to be around 14% at 8 mastery
					local bonus = mastery * 0.01 * 1.75--2.1
					calculation.extraAvg = bonus * calculation.dmgM_Magic * (ActiveAuras["Inquisition"] and 1.3 or 1)
					calculation.extraAvgM = true
					calculation.masteryLast = mastery
					calculation.masteryBonus = bonus
					calculation.extraDamage = 0
					calculation.extraName = hol_icon			
				end
			end		
		end
		if calculation.spi ~= 0 then
			if Talents["Enlightened Judgements"] then
				--Grants hit rating equal to 50%/100% of any Spirit gained from items or effects
				local rating = calculation.spi * Talents["Enlightened Judgements"]
				local hit = calculation.melee and (baseSpell.SpellHit and "Hit" or "MeleeHit") or calculation.caster and (baseSpell.MeleeHit and "MeleeHit" or "Hit")
				calculation.hitPerc = calculation.hitPerc + self:GetRating(hit, rating, true)
			end
		end
	end
	self.Calculation["Stats2"] = function( calculation, ActiveAuras, Talents, spell, baseSpell )
		if calculation.spec == 3 and calculation.AP_mod ~= 0 then
			--Increases your spell power by an amount equal to 30% of your attack power
			calculation.SP_mod = calculation.SP_mod + 0.3 * calculation.AP_mod * calculation.SPM
		end
	end
	local illuminated_healing_icon = "|T" .. select(3,GetSpellInfo(76669)) .. ":16:16:1:-1|t"
	self.Calculation["PALADIN"] = function( calculation, ActiveAuras, Talents, spell, baseSpell )
		--Specialization
		local spec = calculation.spec
		if spec == 1 then
			--TODO: Check specialization is active
			if IsSpellKnown(86525) then
				calculation.intM = calculation.intM * 1.05
			end
			if calculation.healingSpell then
				--Passive: Walk in the Light
				calculation.dmgM = calculation.dmgM * 1.1
				if calculation.spellName == "Word of Glory" then
					calculation.cooldown = 0
				end
			end
			if calculation.mastery > 0 then
				if calculation.healingSpell and calculation.spellName ~= "Holy Radiance" and calculation.spellName ~= "Light of Dawn" then
					calculation.extraName = illuminated_healing_icon
				end
			end
		elseif spec == 2 then
			calculation.APtoSP = true
		elseif spec == 3 then
			calculation.APtoSP = true
			--TODO: Check specialization is active
			if IsSpellKnown(86525) then
				calculation.strM = calculation.strM * 1.05
			end
			--"Attack", "Crusader Strike", "Divine Storm", "Hammer of the Righteous", "Templar's Verdict", "Judgement"
			--NOTE: Seal of Truth dot or Seal of Justice base part don't get any bonus
			if self:GetNormM() == 3.3 then
				if (calculation.WeaponDamage or calculation.group == "Judgement") then
					calculation.wDmgM = calculation.wDmgM * 1.2
					calculation.dmgM = calculation.dmgM * 1.2
				elseif calculation.spellName == "Seal of Justice" then
					calculation.wDmgM = calculation.wDmgM * 1.2
					calculation.dmgM_Extra = calculation.dmgM_Extra * 1.2
				elseif calculation.spellName == "Seal of Righteousness" then
					calculation.wDmgM = calculation.wDmgM * 1.2
					calculation.dmgM_Extra = calculation.dmgM_Extra * 1.2
					--BUG?: Doesn't seem to apply full bonus
					calculation.dmgM_dd = calculation.dmgM_dd * 1.0935
				elseif calculation.spellName == "Seal of Truth" then
					calculation.wDmgM = calculation.wDmgM * 1.2
					calculation.dmgM_dd = calculation.dmgM_dd * 1.2
				end
			end
		end
		if not baseSpell.Melee then
			if calculation.healingSpell then
				if self:GetSetAmount( "T10 Holy" ) >= 2 and ActiveAuras["Divine Favor"] then
					--Multiplicative - 3.3.2
					calculation.dmgM = calculation.dmgM * 1.35
				end
				if self:GetSetAmount( "T8 Holy" ) >= 4 then
					calculation.dmgM_Add = calculation.dmgM_Add + 0.05
				end
			end
		else
			if calculation.group == "Judgement" then
				--Glyph of Judgement 4.0
				if self:HasGlyph(54922) then
					--Additive - 3.3.3
					calculation.dmgM_Add = calculation.dmgM_Add + 0.1
				end
				if self:GetSetAmount( "T7 Retribution" ) >= 4 then
					calculation.cooldown = calculation.cooldown - 1
				end
				if self:GetSetAmount( "PvP Retribution" ) >= 4 then
					calculation.cooldown = calculation.cooldown - 1
				end
				if self:GetSetAmount( "T9 Retribution" ) >= 4 then
					calculation.critPerc = calculation.critPerc + 5
				end
				if self:GetSetAmount( "T10 Retribution" ) >= 4 then
					calculation.dmgM_Add = calculation.dmgM_Add + 0.1
				end
			end
			if calculation.group == "Seal" then
				if self:GetSetAmount( "T10 Retribution" ) >= 4 then
					--TODO: Verify
					--if calculation.spellName == "Seal of Truth" then
					--	calculation.dmgM_dd_Add = calculation.dmgM_dd_Add + 0.1
					--else
						calculation.dmgM_Add = calculation.dmgM_Add + 0.1
					--end
				end
			end
		end
	end
--TALENTS
	self.Calculation["Divinity"] = function( calculation, value )
		--Multiplicative - 3.3.3
		calculation.dmgM = calculation.dmgM * (1 + value)
		if UnitIsUnit(calculation.target,"player") then
			calculation.dmgM = calculation.dmgM * (1 + value)
		end
	end
--ABILITIES
	self.Calculation["Flash of Light"] = function( calculation, ActiveAuras, Talents )
		--PvP Healer Glove Flash of Light Bonus
		if self:GetSetAmount( "PvP Healing Gloves" ) >= 1 then
			calculation.critPerc = calculation.critPerc + 2
		end
		if self:GetSetAmount( "T9 Holy" ) >= 4 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.10
		end
	end
	self.Calculation["Shield of the Righteous"] = function( calculation, ActiveAuras, Talents )
		local hp = ActiveAuras["Divine Purpose"] and 3 or math_min(3,UnitPower("player",9))
		if hp > 0 then
			local bonus = select(hp,1,3,6)
			calculation.minDam = calculation.minDam * bonus - bonus
			calculation.maxDam = calculation.maxDam * bonus - bonus
			calculation.APBonus = calculation.APBonus * bonus
		else
			calculation.minDam = 0
			calculation.maxDam = 0
			calculation.APBonus = 0
		end
		--Glyph of Shield of the Righteous 4.0
		if self:HasGlyph(6322) then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
	end
	self.Calculation["Word of Glory"] = function( calculation, ActiveAuras, Talents )
		local hp = ActiveAuras["Divine Purpose"] and 3 or math_min(3,UnitPower("player",9))
		if hp > 0 then
			calculation.minDam = calculation.minDam * hp
			calculation.maxDam = calculation.maxDam * hp
			calculation.SPBonus = calculation.SPBonus * hp
			calculation.APBonus = calculation.APBonus * hp
		else
			calculation.minDam = 0
			calculation.maxDam = 0
			calculation.SPBonus = 0
			calculation.APBonus = 0
		end
		if Talents["Last Word"] and (UnitHealth(calculation.target) ~= 0) and (UnitHealth(calculation.target) / UnitHealthMax(calculation.target) <= 0.35) then
			calculation.critPerc = calculation.critPerc + Talents["Last Word"]
		end
		if Talents["Guarded by the Light"] and UnitIsUnit(calculation.target,"player") then
			calculation.dmgM_Add = calculation.dmgM_Add + Talents["Guarded by the Light"]
		end
		if Talents["Selfless Healer"] and not UnitIsUnit(calculation.target,"player") then
			calculation.dmgM_Add = calculation.dmgM_Add + Talents["Selfless Healer"]
		end
		--Glyph of the Long Word 4.0
		if self:HasGlyph(93466) then
			calculation.hybridDotDmg = 0.5 * (calculation.minDam + calculation.maxDam) / 2
			calculation.SPBonus_dot = calculation.SPBonus * 0.5
			calculation.minDam = calculation.minDam * 0.5
			calculation.maxDam = calculation.maxDam * 0.5
			calculation.SPBonus = calculation.SPBonus * 0.5
			calculation.eDuration = 6
			calculation.sTicks = 2
		end
		--Glyph of Word of Glory 4.0
		if self:HasGlyph(54936)	then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
	end
	self.Calculation["Light of Dawn"] = function( calculation, ActiveAuras, Talents )
		local hp = ActiveAuras["Divine Purpose"] and 3 or math_min(3,UnitPower("player",9))
		if hp > 0 then
			calculation.minDam = calculation.minDam * hp
			calculation.maxDam = calculation.maxDam * hp
			calculation.SPBonus = calculation.SPBonus * hp
		else
			calculation.minDam = 0
			calculation.maxDam = 0
			calculation.SPBonus = 0
		end
		--Glyph of Light of Dawn 4.0
		if self:HasGlyph(54940) then
			calculation.aoe = calculation.aoe + 1
		end
	end
	self.Calculation["Templar's Verdict"] = function( calculation, ActiveAuras, Talents )
		local hp = ActiveAuras["Divine Purpose"] and 3 or math_min(3,UnitPower("player",9))
		if hp > 0 then
			local wp = select(hp,0.3,0.9,2.35)
			calculation.WeaponDamage = wp
		end
		if self:GetSetAmount( "T11 Retribution" ) >= 2 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.10
		end
		--Glyph of Templar's Verdict 4.0
		if self:HasGlyph(63220) then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.15
		end
	end
	self.Calculation["Avenger's Shield"] = function( calculation, _, _, baseSpell )
		--Glyph of Focused Shield 4.0
		if self:HasGlyph(54930) then
			calculation.dmgM = calculation.dmgM * 1.3
			calculation.aoe = nil
		end
	end
	--Detect Undead, Detect Demon
	local exorcism = string_lower(GetSpellInfo(11389) .. GetSpellInfo(11407))
	local glyph_icon = "|TInterface\\Icons\\INV_Glyph_PrimePaladin:16:16:1:-1|t"
	self.Calculation["Exorcism"] = function( calculation )
		local target = UnitCreatureType("target")
		if target and string_find(exorcism, string_lower(target)) then
			calculation.critPerc = 100
		end
		if (calculation.AP + calculation.AP_mod) > (calculation.SP + calculation.SP_mod) then
			calculation.SPBonus = 0
		else
			calculation.APBonus = 0
		end		
		--Glyph of Exorcism 4.0
		if self:HasGlyph(54934) then
			--NOTE: Additional base coeff 0.179, AP/SP coeff 0.0688
			--NOTE: Duration 6, ticks every 2 secs
			calculation.extra = self:ScaleData(0.179) * 3
			calculation.extraBonus = true
			calculation.extraTicks = 3
			calculation.extraName = glyph_icon
			calculation.extraCanCrit = true
			calculation.extraDamage = 0.2 * calculation.SPBonus
			calculation.extraDamageAP = 0.2 * calculation.APBonus
		end
		if self:GetSetAmount( "T8 Retribution" ) >= 2 then
			--Additive - 3.3.0
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
	end
	self.Calculation["Hammer of the Righteous"] = function( calculation, ActiveAuras )
		--TODO: Make sure all holy damage effects are multiplied into the extra portion
		calculation.dmgM_Extra = calculation.dmgM_Extra * calculation.dmgM_Magic
		if ActiveAuras["Inquisition"] then
			calculation.dmgM_Extra = calculation.dmgM_Extra * 1.3
		end
		--Glyph of Hammer of the Righteous 4.0
		if self:HasGlyph(63219) then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
		if self:GetSetAmount( "T7 Protection" ) >= 2 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
		if self:GetSetAmount( "T9 Protection" ) >= 2 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.05
		end
		if self:GetSetAmount( "T10 Protection" ) >= 2 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.2
		end
	end
	self.Calculation["Consecration"] = function( calculation )
		--Glyph of Consecration - 4.0
		if self:HasGlyph(54928) then
			calculation.eDuration = calculation.eDuration + 2
			calculation.cooldown = calculation.cooldown + 6
		end
	end
	self.Calculation["Holy Shock"] = function( calculation )
		--Glyph of Holy Shock 4.0
		if self:HasGlyph(63224) then
			calculation.critPerc = calculation.critPerc + 5
		end
		if calculation.healingSpell then
			if self:GetSetAmount( "PvP Healing" ) >= 4 then
				--Additive - 3.3.3
				calculation.dmgM_Add = calculation.dmgM_Add + 0.1
			end
			if self:GetSetAmount( "T8 Holy" ) >= 2 then
				calculation.extraCrit = (calculation.extraCrit or 0) + 0.15
				calculation.extraChanceCrit = true
				if calculation.extraTicks then
					calculation.extraTicks = nil
				else
					calculation.extraTicks = 3
				end
				calculation.extraName = calculation.extraName and (calculation.extraName .. "+2T8") or "2T8"
			end
		end
		if self:GetSetAmount( "T7 Holy" ) >= 2 then
			calculation.critPerc = calculation.critPerc + 10
		end
	end
	--self.Calculation["Holy Wrath"] = function( calculation, _ , Talents )
	--end
	self.Calculation["Holy Light"] = function( calculation )
		if self:GetSetAmount( "T11 Holy" ) >= 2 then
			calculation.critPerc = calculation.critPerc + 5
		end
	end
	self.Calculation["Crusader Strike"] = function( calculation, _, Talents )
		if Talents["Sanctity of Battle"] then
			calculation.cooldown = calculation.cooldown / calculation.haste
		end
		if self:GetSetAmount( "PvP Retribution Gloves" ) >= 1 then
			--Additive - 3.3.3
			calculation.dmgM_Add = calculation.dmgM_Add + 0.05
		end
		if self:GetSetAmount( "T8 Retribution" ) >= 4 then
			calculation.critPerc = calculation.critPerc + 10
		end
		if self:GetSetAmount( "T11 Protection" ) >= 2 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.10
		end
		--Glyph of Crusader Strike - 4.0
		if self:HasGlyph(54927) then
			calculation.critPerc = calculation.critPerc + 5
		end
	end
	self.Calculation["Divine Storm"] = function( calculation, _, Talents )
		if Talents["Sanctity of Battle"] then
			calculation.cooldown = calculation.cooldown / calculation.haste
		end
		if self:GetSetAmount( "T7 Retribution" ) >= 2 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
		if self:GetSetAmount( "T8 Retribution" ) >= 4 then
			calculation.critPerc = calculation.critPerc + 10
		end
	end
	self.Calculation["Hammer of Wrath"] = function( calculation )
		if self:GetSetAmount( "T8 Retribution" ) >= 2 then
			--Additive - 3.3.0
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
	end
--SEALS AND JUDGEMENTS
	local soc_icon = "|T" .. select(3,GetSpellInfo(85126)) .. ":16:16:1:-1|t"
	self.Calculation["Seal of Righteousness"] = function( calculation, _, Talents )
		if self:GetSetAmount( "T8 Protection" ) >= 2 then
			calculation.dmgM = calculation.dmgM_Add + 0.1
		end
		local spd = self:GetWeaponType() and self:GetWeaponSpeed() or 2
		calculation.APBonus = calculation.APBonus * spd
		calculation.SPBonus = calculation.SPBonus * spd
		if Talents["Seals of Command"] then
			calculation.extraDamage = 0
			calculation.extraWeaponDamage = 0.07
			calculation.extra_canCrit = true
			calculation.extraName = soc_icon
			calculation.aoe = 3
		end
	end
	self.Calculation["Seal of Justice"] = function( calculation, _, Talents )
		local spd = self:GetWeaponType() and self:GetWeaponSpeed() or 2
		calculation.APBonus = calculation.APBonus * spd
		calculation.SPBonus = calculation.SPBonus * spd
		if Talents["Seals of Command"] then
			calculation.extraDamage = 0
			calculation.extraWeaponDamage = 0.07
			calculation.extra_canCrit = true
			calculation.extraName = soc_icon		
		end
	end
	local censure_icon = "|T" .. select(3,GetSpellInfo(31803)) .. ":16:16:1:-1|t"
	self.Calculation["Seal of Truth"] = function( calculation, ActiveAuras, Talents )
		if Talents["Seals of Command"] then
			calculation.WeaponDamage = 0.07
			calculation.WeaponDPS = true
		end
		local number = ActiveAuras["Censure"] or 1
		calculation.extraDamage = calculation.extraDamage * number
		calculation.extraDamageSP = calculation.extraDamageSP * number
		calculation.extraName = number .. "x" .. censure_icon
		if ActiveAuras["Censure"] then
			calculation.WeaponDamage = (calculation.WeaponDamage or 0) + number * 0.03
			calculation.WeaponDPS = true
		end
		if self:GetSetAmount( "T8 Protection" ) >= 2 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
	end
	self.Calculation["Judgement of Truth"] = function( calculation, ActiveAuras )
		if ActiveAuras["Censure"] then
			calculation.dmgM = calculation.dmgM * (1 + 0.1 * ActiveAuras["Censure"])
		end
	end
--SETS
	self.SetBonuses["PvP Healing Gloves"] = {
		--Savage, Hateful, Deadly, Furious, Relentless, Wrathful, Bloodthirsty, Vicious
		40918, 40925, 40926, 40927, 40928, 51459, 64803, 60602,
	}
	self.SetBonuses["PvP Retribution Gloves"] = {
		--Savage, Hateful, Deadly, Furious, Relentless, Wrathful, Bloodthirsty, Vicious
		40798, 40802, 40805, 40808, 40812, 51475, 64844, 60414,
	}	
	self.SetBonuses["PvP Healing"] = {
		--Savage Gladiators'
		40898, 40918, 40930, 40936, 40960,
		--Hateful Gladiator's
		40904, 40925, 40931, 40937, 40961,
		--Deadly Gladiator's
		40905, 40926, 40932, 40938, 40962,
		--Furious Gladiator's
		40907, 40927, 40933, 40939, 40963,
		--Relentess Gladiator's
		40910, 40928, 40934, 40940, 40964,
		--Wrathful Gladiator's
		51468, 51469, 51470, 51471, 51473,
		--Gladiator's Redemption
		64948, 64949, 64950, 64951, 64952,
		--Bloodthirsty Gladiator's
		64802, 64803, 64804, 64805, 64806,
		--Vicious Gladiator's
		60601, 60602, 60603, 60604, 60605,
	}
	self.SetBonuses["PvP Retribution"] = {
		--Savage Gladiators'
		40780, 40798, 40818, 40838, 40858,
		--Hateful Gladiator's
		40782, 40802, 40821, 40842, 40861,
		--Deadly Gladiator's
		40785, 40805, 40825, 40846, 40864,
		--Furious Gladiator's
		40788, 40808, 40828, 40849, 40869,
		--Relentess Gladiator's
		40792, 40812, 40831, 40852, 40872,
		--Wrathful Gladiator's
		51474, 51475, 51476, 51477, 51479,
		--Gladiator's Redemption
		64933, 64934, 64935, 64936, 64937,
		--Bloodthirsty Gladiator's
		64843, 64844, 64845, 64846, 64847,
		--Vicious Gladiator's
		60413, 60414, 60415, 60416, 60417,		
	}
	--T7
	self.SetBonuses["T7 Holy"] = { 39628, 39629, 39630, 39631, 39632, 40569, 40570, 40571, 40572, 40573 }
	self.SetBonuses["T7 Protection"] = { 39638, 39639, 39640, 39641, 39642, 40579, 40580, 40581, 40583, 40584 }
	self.SetBonuses["T7 Retribution"] = { 39633, 39634, 39635, 39636, 39637, 40574, 40575, 40576, 40577, 40578 }
	--T8
	self.SetBonuses["T8 Holy"] = { 45370, 45371, 45372, 45373, 45374, 46178, 46179, 46180, 46181, 46182 }
	self.SetBonuses["T8 Protection"] = { 45381, 45382, 45383, 45384, 45385, 46173, 46174, 46175, 46176, 46177 }
	self.SetBonuses["T8 Retribution"] = { 45375, 45376, 45377, 45379, 45380, 46152, 46153, 46154, 46155, 46156 }
	--T9
	self.SetBonuses["T9 Holy"] = { 48595, 48596, 48597, 48598, 48599, 48564, 48566, 48568, 48572, 48574, 48593, 48591, 48592, 48590, 48594, 48588, 48586, 48587, 48585, 48589, 48576, 48578, 48577, 48579, 48575, 48583, 48581, 48582, 48580, 48584 }
	self.SetBonuses["T9 Protection"] = { 48652, 48653, 48654, 48655, 48656, 48632, 48633, 48634, 48635, 48636, 48641, 48639, 48640, 48638, 48637, 48642, 48644, 48643, 48645, 48646, 48657, 48659, 48658, 48660, 48661, 48651, 48649, 48650, 48648, 48647 }
	self.SetBonuses["T9 Retribution"] = { 48627, 48628, 48629, 48630, 48631, 48602, 48603, 48604, 48605, 48606, 48626, 48625, 48624, 48623, 48622, 48617, 48618, 48619, 48620, 48621, 48607, 48608, 48609, 48610, 48611, 48616, 48615, 48614, 48613, 48612 }
	--T10
	self.SetBonuses["T10 Holy"] = { 50868, 50866, 50867, 50865, 50869, 51270, 51169, 51271, 51168, 51272, 51167, 51273, 51166, 51274, 51165 }
	self.SetBonuses["T10 Protection"] = { 50864, 50862, 50863, 50861, 50860, 51265, 51174, 51266, 51173, 51267, 51172, 51268, 51171, 51269, 51170 }
	self.SetBonuses["T10 Retribution"] = { 50328, 50327, 50326, 50325, 50324, 51275, 51164, 51276, 51163, 51277, 51162, 51278, 51161, 51279, 51160 }
	--T11
	self.SetBonuses["T11 Holy"] = { 60359, 60360, 60361, 60362, 60363, 65219, 65220, 65221, 65222, 65223 }
	self.SetBonuses["T11 Protection"] = { 60354, 60355, 60356, 60357, 60358, 65224, 65225, 65226, 65227, 65228, }
	self.SetBonuses["T11 Retribution"] = { 60344, 60345, 60346, 60347, 60348, 65214, 65215, 65216, 65217, 65218 }
--AURA
--Player
	--Seal of Righteousness 4.0
	--Seal of Truth 4.0
	--Seal of Justice 4.0
	self.PlayerAura[GetSpellInfo(20154)] = { Update = true }
	self.PlayerAura[GetSpellInfo(31801)] = self.PlayerAura[GetSpellInfo(20154)]
	self.PlayerAura[GetSpellInfo(20165)] = self.PlayerAura[GetSpellInfo(20154)]
	self.PlayerAura[GetSpellInfo(20164)] = self.PlayerAura[GetSpellInfo(20154)]
	--Judgements of the Pure 4.0
	self.PlayerAura[GetSpellInfo(53655)] = self.PlayerAura[GetSpellInfo(20154)]
	--Infusion of Light 4.0 (Holy Talent)
	self.PlayerAura[GetSpellInfo(53672)] = { Update = true, Spells = { "Holy Light", "Divine Light" } }
	--The Art of War 4.0 (Retribution Talent)
	self.PlayerAura[GetSpellInfo(59578)] = { Spells = "Exorcism", Value = 1, ID = 59578  }
	--Divine Favor 4.0 (Holy Talent)
	self.PlayerAura[GetSpellInfo(31842)] = { ActiveAura = "Divine Favor", ID = 31842 }
	--Avenging Wrath 4.0
	self.PlayerAura[GetSpellInfo(31884)] = { School = "Healing", Value = 0.2, NoManual = true }
	--Divine Plea 4.0
	self.PlayerAura[GetSpellInfo(54428)] = { School = "Healing", Value = -0.5, ID = 54428, NoManual = true }
	--Holiness 4.0 (4p T10 healer proc, -0.3s cast on Holy Light)
	self.PlayerAura[GetSpellInfo(70757)] = { Update = true, Spells = "Holy Light" }
	--Seal of Insight 4.0
	self.PlayerAura[GetSpellInfo(20165)] = { Caster = true, School = "Healing", ID = 20165, Not = "Gift of the Naaru", ModType =
		function( calculation )
			--Glyph of Seal of Light 4.0 (additive - 3.3.3)
			if self:HasGlyph( 54943 ) then
				calculation.dmgM_Add = calculation.dmgM_Add + 0.05
			end
		end
	}
	--Inquisition 4.0
	self.PlayerAura[GetSpellInfo(84963)] = { School = "Holy", ActiveAura = "Inquisition", Value = 0.3, ID = 84963 }
	--Divine Purpose 4.0.6
	self.PlayerAura[GetSpellInfo(90174)] = { School = "All", ActiveAura = "Divine Purpose", ID = 90174 }
	--Conviction 4.0
	self.PlayerAura[GetSpellInfo(20049)] = { School = "Healing", Ranks = 3, Apps = 3, Value = 0.01, ID = 20049, NoManual = true }
	--Sacred Duty 4.0
	self.PlayerAura[GetSpellInfo(85433)] = { Spells = "Shield of the Righteous", Value = 100, ModType = "critPerc", ID = 85433, NoManual = true }
	--Crusader 4.0
	self.PlayerAura[GetSpellInfo(94686)] = { Spells = "Holy Light", ID = 94686, NoManual = true, ModType =
		function( calculation, _, Talents )
			if Talents["Crusade"] then
				calculation.dmgM = calculation.dmgM * (1 + Talents["Crusade"])
			end
		end
	}
--Target
	--Censure (4.0)
	self.TargetAura[GetSpellInfo(31803)] = { Spells = { "Seal of Truth", ["Judgement of Truth"] = true }, ActiveAura = "Censure", SelfCast = true, Apps = 5, ID = 31803 }

	self.spellInfo = {
		[GetSpellInfo(31935)] = {
					--200% crit, Melee hit
					["Name"] = "Avenger's Shield",
					["ID"] = 31935,
					["Data"] = { 3.024, 0.2, 0.21, ["c_scale"] = 0.33 },
					[0] = { School = { "Holy", "Melee" }, APBonus = 0.419, MeleeCrit = true, MeleeHit = true, AoE = 3, Cooldown = 15 },
					[1] = { 0, 0, },
		},
		[GetSpellInfo(24275)] = {
					--200% crit (verify), Melee Hit
					["Name"] = "Hammer of Wrath",
					["ID"] = 24275,
					["Data"] = { 3.9, 0.1, 0.117, },
					[0] = { School = { "Holy", "Melee" }, APBonus = 0.39, MeleeCrit = true, MeleeHit = true, Cooldown = 6, },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(879)] = {
					--150% crit, Spell hit
					["Name"] = "Exorcism",
					["ID"] = 879,
					["Data"] = { 2.663, 0.101 },
					[0] = { School = "Holy", APBonus = 0.344, SPBonus = 0.344, },
					[1] = { 0, 0, },
		},
		[GetSpellInfo(2812)] = {
					--150% crit, Spell hit
					["Name"] = "Holy Wrath",
					["ID"] = 2812,
					["Data"] = { 2.333 },
					[0] = { School = "Holy", SPBonus = 0.61, Cooldown = 15 },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(20473)] = {
					["Name"] = "Holy Shock",
					["Text1"] = GetSpellInfo(20473),
					["Text2"] = GetSpellInfo(37455),
					["ID"] = 20473,
					["Data"] = { 2.66, 0.08, 0.269, },
					[0] = { School = { "Holy", "Healing", "Holy Shock Heal" }, Cooldown = 6, },
					[1] = { 0, 0 },
			["Secondary"] = {
					["Name"] = "Holy Shock",
					["Text1"] = GetSpellInfo(20473),
					["Text2"] = GetSpellInfo(48360),
					["ID"] = 20473,
					["Data"] = { 1.416, 0.08, 0.429 },
					[0] = { School = { "Holy", "Holy Shock Damage" }, Cooldown = 6 },
					[1] = { 0, 0 },
			},
		},
		[GetSpellInfo(26573)] = {
					--Spell crit, Spell hit
					["Name"] = "Consecration",
					["ID"] = 26573,
					["Data"] = { 0.079, 0, 0.027 },
					[0] = { School = "Holy", APBonus = 0.027, Hits = 10, eDot = true, eDuration = 10, sTicks = 1, Cooldown = 30,  AoE = true, NoDotHaste = true },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(635)] = {
					["Name"] = "Holy Light",
					["ID"] = 635,
					["Data"] = { 4.274, 0.108, 0.432, ["ct_min"] = 1500, ["ct_max"] = 3000 },
					[0] = { School = { "Holy", "Healing" }, },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(19750)] = {
					["Name"] = "Flash of Light",
					["ID"] = 19750,
					["Data"] = { 7.119, 0.115, 0.863, },
					[0] = { School = { "Holy", "Healing" }, },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(85673)] = {
					["Name"] = "Word of Glory",
					["ID"] = 85673,
					["Data"] = { 2.072, 0.108, 0.209, ["c_scale"] = 0.25 },
					[0] = { School = { "Holy", "Healing" }, APBonus = 0.198, Cooldown = 20 },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(82326)] = {
					["Name"] = "Divine Light",
					["ID"] = 82326,
					["Data"] = { 11.397, 0.108, 1.153 },
					[0] = { School = { "Holy", "Healing" }, },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(82327)] = {
					["Name"] = "Holy Radiance",
					["ID"] = 82327,
					["Data"] = { 0.664, 0, 0.067 },
					[0] = { School = { "Holy", "Healing" }, Cooldown = 60, eDot = true, Hits = 10, eDuration = 10, sTicks = 1, AoE = 6, RoundTicks = true },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(85222)] = {
					["Name"] = "Light of Dawn",
					["ID"] = 85222,
					["Data"] = { 0.622, 0.108, 0.132 },
					[0] = { School = { "Holy", "Healing" }, AoE = 5 },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(7294)] = {
					["Name"] = "Retribution Aura",
					["ID"] = 7294,
					["Data"] = { 0.118, 0, 0.033 },
					[0] = { School = "Holy", NoDPM = true, NoDPS = true, NoCasts = true, NoHaste = true, NoMPS = true, NoNextDPS = true, Unresistable = true },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(35395)] = {
					["Name"] = "Crusader Strike",
					["ID"] = 35395,
					[0] = { Melee = true, WeaponDamage = 1.35, Cooldown = 4.5, HandOfLight = true },
					[1] = { 0, 0, },
		},
		[GetSpellInfo(53385)] = {
					["Name"] = "Divine Storm",
					["ID"] = 53385,
					[0] = { Melee = true, WeaponDamage = 1, Cooldown = 4.5, NoNormalization = true, AoE = true, HandOfLight = true },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(53595)] = {
					["Name"] = "Hammer of the Righteous",
					["ID"] = 53595,
					["Data"] = { 0, ["extra"] = 0.708 },
					[0] = { Melee = true, WeaponDamage = 0.3, APBonus_extra = 0.18, Cooldown = 4.5, E_AoE = true, },
					[1] = { 0, 0, },
		},
		[GetSpellInfo(53600)] = {
					["Name"] = "Shield of the Righteous",
					["ID"] = 53600,
					["Data"] = { 0.593 },
					[0] = { School = "Holy", Melee = true, APBonus = 0.1, },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(85256)] = {
					["Name"] = "Templar's Verdict",
					["ID"] = 85256,
					[0] = { Melee = true, WeaponDamage = 0, HandOfLight = true },
					[1] = { 0, 0 },
		},
		--Seals
		--Seal of Insight only heals
		[GetSpellInfo(20154)] = {
					--No crits
					["Name"] = "Seal of Righteousness",
					["ID"] = 20154,
					[0] = { School = { "Holy" , "Seal" }, Melee = true, APBonus = 0.011, SPBonus = 0.022, NoCrits = true, WeaponDPS = true, NoDPM = true, Unavoidable = true },
					[1] = { 0 },
		},
		[GetSpellInfo(20164)] = {
					--Crits for 150%
					["Name"] = "Seal of Justice",
					["ID"] = 20164,
					[0] = { School = { "Holy" , "Seal" }, Melee = true, SpellCrit = "Holy", APBonus = 0.005, SPBonus = 0.01, WeaponDPS = true, NoDPM = true, Unavoidable = true },
					[1] = { 0 },
		},
		[GetSpellInfo(31801)] = {
					--Crits for 200%
					["Name"] = "Seal of Truth",
					["ID"] = 31801,
					[0] = { School = { "Holy", "Seal" }, Melee = true, APBonus_extra = 0.0193, SPBonus_extra = 0.01, Hits_extra = 5, E_eDuration = 15, E_Ticks = 3, E_canCrit = true, NoDPM = true, Unavoidable = true, NoNormalization = true },
					[1] = { 0, 0 },
		},
		["Judgements"] = { 	[GetSpellInfo(20154)] = "Judgement of Righteousness",
							[GetSpellInfo(20164)] = "Judgement of Justice",
							[GetSpellInfo(20165)] = "Judgement of Insight",
							[GetSpellInfo(31801)] = "Judgement of Truth",
		},
		--Judgement
		[GetSpellInfo(20271)] = {
					[0] = function()
						for k, v in pairs(self.spellInfo["Judgements"]) do
							if UnitBuff("player", k) then
								return self.spellInfo[v][0], self.spellInfo[v]
							end
						end
					end
		},
		["Judgement of Righteousness"] = {
					["Name"] = "Judgement of Righteousness",
					["Text1"] = GetSpellInfo(20271),
					["Text2"] = GetSpellInfo(20154),
					[0] = { School = { "Holy", "Judgement" }, Melee = true, APBonus = 0.2, SPBonus = 0.32, Cooldown = 8, Unavoidable = true },
					[1] = { 1, 1 },
		},
		["Judgement of Justice"] = {
					["Name"] = "Judgement of Justice",
					["Text1"] = GetSpellInfo(20271),
					["Text2"] = GetSpellInfo(20164),
					[0] = { School = { "Holy", "Judgement" }, Melee = true, APBonus = 0.16, SPBonus = 0.25, Cooldown = 8, Unavoidable = true },
					[1] = { 1, 1 },
		},
		["Judgement of Insight"] = {
					["Name"] = "Judgement of Insight",
					["Text1"] = GetSpellInfo(20271),
					["Text2"] = GetSpellInfo(20165),
					[0] = { School = { "Holy", "Judgement" }, Melee = true, APBonus = 0.16, SPBonus = 0.25, Cooldown = 8, Unavoidable = true },
					[1] = { 1, 1 },
		},
		["Judgement of Truth"] = {
					["Name"] = "Judgement of Truth",
					["Text1"] = GetSpellInfo(10321),
					["Text2"] = GetSpellInfo(31801),
					[0] = { School = { "Holy", "Judgement" }, Melee = true, SPBonus = 0.223, APBonus = 0.142, Cooldown = 8, Unavoidable = true },
					[1] = { 1, 1 },
		},
	}
	self.talentInfo = {
	--HOLY:
		--Arbiter of the Light
		[GetSpellInfo(20359)] = {	[1] = { Effect = 6, Spells = { "Judgement", "Templar's Verdict" }, ModType = "critPerc" }, },
		--TODO?: Protector of the Innocent -- Casting a targeted heal on any target, except yourself, also heals you for xxxx to xxxx.
		--Last Word
		[GetSpellInfo(20234)] = {	[1] = { Effect = 30, Spells = "Word of Glory", ModType = "Last Word" }, },
		--Blazing Light (additive?)
		[GetSpellInfo(20235)] = {	[1] = { Effect = 0.1, Spells = { "Holy Shock Damage", "Exorcism" }, }, },
		--Infusion of Light
		[GetSpellInfo(53569)] = {	[1] = { Effect = 5, Spells = "Holy Shock", ModType = "critPerc" }, },
		--Enlightened Judgements
		[GetSpellInfo(53556)] = {	[1] = { Effect = 0.5, Spells = "All", Not = "Healing", ModType = "Enlightened Judgements" }, },
		--Speed of Light
		[GetSpellInfo(85495)] = {	[1] = { Effect = -10, Spells = "Holy Radiance" , ModType = "cooldown" }, },
	--PROTECTION:
		--Divinity (multiplicative - 3.3.3)
		[GetSpellInfo(63646)] = { 	[1] = { Effect = 0.02, Caster = true, Spells = { "Healing", "Gift of the Naaru" }, ModType = "Divinity" }, },
		--Seals of the Pure (additive?)
		--TODO: Does this affect judgements?
		[GetSpellInfo(20224)] = {	[1] = { Effect = 0.06, Spells = "Seal" }, },
		--Hallowed Ground (additive?)
		[GetSpellInfo(84631)] = {	[1] = { Effect = 0.2, Spells = "Consecration" }, },
		--Wrath of the Lightbringer
		[GetSpellInfo(84635)] = {	[1] = { Effect = 0.5, Spells = { "Crusader Strike", "Judgement" } },
									[2] = { Effect = 15, Spells = { "Holy Wrath", "Hammer of Wrath" }, ModType = "critPerc" }, },
		--Guarded by the Light
		[GetSpellInfo(85639)] = {	[1] = { Effect = 0.05, Spells = "Word of Glory", ModType = "Guarded by the Light" }, },

	--RETRIBUTION:
		--Crusade (additive?)
		[GetSpellInfo(31866)] = { 	[1] = { Effect = 0.1, Spells = { "Crusader Strike", "Hammer of the Righteous", "Templar's Verdict", "Holy Shock" }, },
									[2] = { Effect = 1, Spells = "Holy Light", ModType = "Crusade" }, },
		--Rule of Law
		[GetSpellInfo(85457)] = {	[1] = { Effect = 5, Spells = { "Crusader Strike", "Hammer of the Righteous", "Word of Glory" }, ModType = "critPerc" }, },
		--Sanctity of Battle
		[GetSpellInfo(25956)] = {	[1] = { Effect = 1, Spells = { "Crusader Strike", "Divine Storm" }, ModType = "Sanctity of Battle" }, },
		--Seals of Command
		[GetSpellInfo(85126)] = {	[1] = { Effect = 1, Spells = "Seal", ModType = "Seals of Command" }, },
		--Sactified Wrath
		[GetSpellInfo(53375)] = {	[1] = { Effect = 20, Caster = true, Spells = "Hammer of Wrath", ModType = "critPerc" }, },
		--Selfless Healer (additive?)
		[GetSpellInfo(85803)] = {	[1] = { Effect = 0.25, Spells = "Word of Glory", ModType = "Selfless Healer" }, },
		--Inquiry of Faith (additive?)
		[GetSpellInfo(53380)] = {	[1] = { Effect = 0.1, Spells = "Seal of Truth", ModType = "dmgM_Extra_Add" }, },
	}
end