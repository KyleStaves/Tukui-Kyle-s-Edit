if select(2, UnitClass("player")) ~= "SHAMAN" then return end
local GetSpellInfo = DrDamage.SafeGetSpellInfo
local GetSpellCritChance = GetSpellCritChance
local GetSpellBonusDamage = GetSpellBonusDamage
local UnitPowerMax = UnitPowerMax
local UnitAttackSpeed = UnitAttackSpeed
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitDamage = UnitDamage
local UnitIsUnit = UnitIsUnit
local string_find = string.find
local string_match = string.match
local string_gsub = string.gsub
local math_min = math.min
local math_max = math.max
local math_floor = math.floor
local select = select
local tonumber = tonumber
local IsSpellKnown = IsSpellKnown

--TODO-MINOR: Glyph of Healing Wave (20% self-heal)
--Glyph of Flametongue Weapon is handled by API
--Dual Wield hit is handled by API

function DrDamage:PlayerData()
	--Health updates
	self.TargetHealth = { [1] = 0.351 }
	--Mana Spring Totem
	local MST = GetSpellInfo(5675)
	local TF = GetSpellInfo(16173)
	self.ClassSpecials[MST] = function()
		local cost = select(4, GetSpellInfo(MST))
		local duration = 0.2 * 5 * 60 * (1 + select(self.talents[TF] or 3,0.2,0.4,0))
		local value = duration * self:ScaleData(0.736, nil, nil, nil, true) - (tonumber(cost) or 0)
		return value, nil, true
	end
--GENERAL
	self.Calculation["Stats"] = function( calculation, ActiveAuras, Talents, spell, baseSpell )
		local mastery = calculation.mastery
		local masteryLast = calculation.masteryLast
		local spec = calculation.spec
		if spec == 1 then
			if mastery > 0 and mastery ~= masteryLast then
				if calculation.spellName == "Lightning Bolt" or calculation.spellName == "Chain Lightning" or calculation.spellName == "Lava Burst" then
					local masteryBonus = calculation.masteryBonus
					if masteryBonus then
						calculation.finalMod_M = calculation.finalMod_M - masteryBonus
					end
					--TODO-MINOR: Improve this?
					local bonus = (mastery * 0.01 * 2) * 0.75
					calculation.finalMod_M = calculation.finalMod_M + bonus
					calculation.masteryLast = mastery
					calculation.masteryBonus = bonus
				end
			end
		elseif spec == 2 then
			if mastery > 0 and mastery ~= masteryLast then
				if not calculation.healingSpell then
					if (calculation.school == "Fire" or calculation.school == "Frost" or calculation.school == "Nature") then
						local masteryBonus = calculation.masteryBonus
						if masteryBonus then
							calculation.dmgM = calculation.dmgM / masteryBonus
						end
						local bonus = 1 + mastery * 0.01 * 2.5
						calculation.dmgM = calculation.dmgM * bonus
						calculation.masteryLast = mastery
						calculation.masteryBonus = bonus
					elseif calculation.spellName == "Attack" and calculation.E_dmgM then
						local masteryBonus = calculation.masteryBonus
						if masteryBonus then
							calculation.E_dmgM = calculation.E_dmgM / masteryBonus
						end
						local bonus = 1 + mastery * 0.01 * 2.5
						calculation.E_dmgM = calculation.E_dmgM * bonus
						calculation.masteryLast = mastery
						calculation.masteryBonus = bonus
					end
				end
			end
		elseif spec == 3 then
			if mastery > 0 and mastery ~= masteryLast then
				if calculation.healingSpell and baseSpell.DirectHeal then
					local masteryBonus = calculation.masteryBonus
					if masteryBonus then
						calculation.dmgM = calculation.dmgM / masteryBonus
					end
					--TODO: Does this work with riptide?
					--1% of bonus at 100% health, 100% of bonus at 1% health
					--Mastery: Deep Healing
					local mult = 1 - UnitHealth(calculation.target) / UnitHealthMax(calculation.target)
					local bonus = 1 + mult * (mastery * 0.01 * 3)
					calculation.dmgM = calculation.dmgM * bonus
					calculation.masteryLast = mastery
					calculation.masteryBonus = bonus
				end
			end
		end
		if calculation.spi ~= 0 then
			if calculation.caster and not calculation.healingSpell and Talents["Elemental Precision"] then
				--Grants you spell hit rating equal to 33/66/100% of any Spirit gained from items or effects.
				local bonus = select(Talents["Elemental Precision"],0.33,0.66,1)
				local rating = calculation.spi * bonus
				calculation.hitPerc = calculation.hitPerc + self:GetRating("Hit", rating, true)
				--TODO: Add bonus to weapon enhancements
			end
		end
	end
	self.Calculation["Stats2"] = function( calculation, ActiveAuras, Talents, spell, baseSpell )
		if calculation.AP_mod ~= 0 then
			if calculation.spec == 2 then
				--Mental Quickness --Increases your spell power by an amount equal to 50% of your attack power
				calculation.SP_mod = calculation.SP_mod + 0.5 * calculation.AP_mod * calculation.SPM
			end
		end
	end

	--Rockbiter weapon
	local rb = GetSpellInfo(36494)
	--Lightning Shield
	local lightning_shield = GetSpellInfo(324)
	--Earthliving weapon
	local elw = GetSpellInfo(51730)
	local elwicon = "|T" .. select(3,GetSpellInfo(51730)) .. ":16:16:1:-1|t"
	--Windfury weapon
	local wf = GetSpellInfo(8232)
	local wficon = "|T" .. select(3,GetSpellInfo(8232)) .. ":16:16:1:-1|t"
	--Flametongue weapon
	local ft = GetSpellInfo(8024)
	local fticon = "|T" .. select(3,GetSpellInfo(8024)) .. ":16:16:1:-1|t"
	--Frostbrand weapon
	local fb = GetSpellInfo(8033)
	local fbicon = "|T" .. select(3,GetSpellInfo(8033)) .. ":16:16:1:-1|t"
	--Static Shock
	local ssicon = "|T" .. select(3,GetSpellInfo(51525)) .. ":16:16:1:-1|t"
	self.Calculation["SHAMAN"] = function( calculation, ActiveAuras, Talents, spell, baseSpell )
		--Specialization
		local spec = calculation.spec
		if spec == 1 then
			--TODO: Check specialization is active
			if IsSpellKnown(86529) then
				calculation.intM = calculation.intM * 1.05
			end
			if calculation.spellName == "Lightning Bolt" or calculation.spellName == "Chain Lightning" or calculation.spellName == "Lava Burst" then
				calculation.SPBonus_Add = calculation.SPBonus_Add + 0.2
			end
			if (calculation.school == "Fire" or calculation.school == "Frost" or calculation.school == "Nature") and not calculation.healingSpell and (calculation.critM < 1) then
				calculation.critM = calculation.critM + 0.5
			elseif calculation.spellName == "Attack" then
				Talents["Elemental Fury"] = 0.5
			end
		elseif spec == 2 then
			calculation.APtoSP = true
			--TODO: Check specialization is active
			if IsSpellKnown(86529) then
				calculation.agiM = calculation.agiM * 1.05
			end
		elseif spec == 3 then
			--TODO: Check specialization is active
			if IsSpellKnown(86529) then
				calculation.intM = calculation.intM * 1.05
			end
			if calculation.healingSpell then
				--Passive: Purification
				calculation.dmgM = calculation.dmgM * 1.25
				Talents["Purification"] = 0.25
			end
		end
		if calculation.healingSpell then
			if calculation.spellName ~= "Healing Stream Totem" then
				local name = self:GetWeaponBuff()
				local nameO = self:GetWeaponBuff(true)
				local mh = name and string_find(elw,name)
				local oh = nameO and string_find(elw,nameO)
				if mh or oh then
					local chance = 0.2 + (UnitHealth("target") ~= 0 and ((UnitHealth("target") / UnitHealthMax("target")) <= 0.35) and Talents["Blessing of the Eternals"] or 0)
					--chance = math_min(1, chance * (calculation.spellName == "Chain Heal" and calculation.aoe or 1))
					calculation.extra = 4 * self:ScaleData(0.574)
					calculation.extraDamage = 4 * 0.057
					calculation.extraBonus = true
					--Glyph of Earthliving Weapon (4.0)
					calculation.extraDmgM = (1 + (Talents["Purification"] or 0)) * (1 + (self:HasGlyph(55439) and 0.2 or 0))
					calculation.extraTicks = 4
					calculation.extraChance = math_min(1, (mh and chance or 0) + (oh and chance or 0))
					calculation.extraName = (mh and elwicon or "") .. (mh and oh and "+" or "") .. (oh and elwicon or "")
					calculation.extraCanCrit = true
				end
			end
			if Talents["Spark of Life"] and UnitIsUnit(calculation.target,"player") then
				calculation.dmgM = calculation.dmgM * (1 + Talents["Spark of Life"])
			end
			if Talents["Nature's Blessing"] and ActiveAuras["Earth Shield"] and baseSpell.DirectHeal then
				calculation.dmgM = calculation.dmgM * (1 + Talents["Nature's Blessing"])
			end
		else
			if Talents["Elemental Oath"] and ActiveAuras["Clearcasting"] then
				--Multiplicative 3.3.3
				calculation.dmgM = calculation.dmgM * (1 + Talents["Elemental Oath"])
			end
			if Talents["Frozen Power"] and ActiveAuras["Frostbrand Attack"] then
				--CHECK
				calculation.dmgM = calculation.dmgM * (1 + Talents["Frozen Power"])
			end
			if Talents["Static Shock"] and ActiveAuras["Lightning Shield"] then
				--When you use your Primal Strike, Stormstrike, or Lava Lash abilities while having Lightning Shield active, you have a 15%/30%/45% chance to deal damage equal to a Lightning Shield orb without consuming a charge.
				calculation.extra = self.spellInfo[lightning_shield][1][1]
				calculation.extraDamage = 0
				calculation.extraDamageSP = self.spellInfo[lightning_shield][0].SPBonus
				calculation.extraChance = Talents["Static Shock"]
				calculation.extraName = ssicon
				calculation.E_dmgM = select(7,UnitDamage("player")) * calculation.dmgM_Magic * (1 + (Talents["Improved Shields"] or 0) + 0.01 * (Talents["Elemental Precision"] or 0)) / calculation.dmgM_Physical
			end
		end
	end
--ABILITIES
	self.Calculation["Attack"] = function( calculation, _, Talents, spell, baseSpell )
		local spellHit = 0.01 * math_max(0,math_min(100,self:GetSpellHit(calculation.playerLevel, calculation.targetLevel) + calculation.spellHit))
		local dmgM = select(7,UnitDamage("player")) * calculation.dmgM_Magic * (1 + 0.01 * (Talents["Elemental Precision"] or 0)) / calculation.dmgM_Physical
		local critM = (0.5 + (Talents["Elemental Fury"] or 0)) * (1 + 3 * self.Damage_critMBonus)
		local name, rank = self:GetWeaponBuff()
		local pcm, pco
		if name then
			if string_find(wf, name) then
				local spd = UnitAttackSpeed("player")
				--Glyph of Windfury Weapon (4.0)
				pcm = self:HasGlyph(55445) and (select(math_floor(spd/1.5) + 1, 0.132, 0.153, 0.18) or 0.22) or (select(math_floor(spd/1.5) + 1, 0.125, 0.143, 0.167) or 0.2)
				calculation.WindfuryBonus = self:ScaleData(10, nil, nil, nil, true)
				calculation.extraName = wficon
			elseif string_find(ft, name) then
				local spd = self:GetWeaponSpeed()
				local bonus = spd * 0.01 * self:ScaleData(7.61)
				local coeff = (spd <= 2.6) and (spd / 2.6) * 0.1 or (0.1 + (spd - 2.6)/ 1.4 * 0.05)
				--Modifiers to core:
				if calculation.spec == 2 then
					calculation.extraDamage = 0.8 * coeff
				else
					calculation.extraDamage = 0
					calculation.extraDamageSP = 0.8 * coeff
				end
				calculation.extraName = fticon
				calculation.extra = calculation.extra + bonus
				calculation.extraChance = spellHit
				calculation.E_canCrit = true
				calculation.E_critM = critM
				calculation.E_dmgM = dmgM
				--calculation.SP = calculation.SP - GetSpellBonusDamage(2) + GetSpellBonusDamage(3)
				calculation.E_critPerc = GetSpellCritChance(3) + calculation.spellCrit
			elseif string_find(fb, name) then
				local spd = self:GetWeaponSpeed()
				local bonus = self:ScaleData(0.609)
				local level = calculation.playerLevel
				--Modifiers to core:
				calculation.extraDamage = 0
				calculation.extraName = fbicon
				calculation.extra = calculation.extra + bonus
				calculation.extraDamageSP = 0.1
				calculation.extraChance = (spd * 9)/60 * spellHit
				calculation.E_canCrit = true
				calculation.E_critM = critM
				calculation.E_dmgM = dmgM
				--calculation.SP = calculation.SP - GetSpellBonusDamage(2) + GetSpellBonusDamage(5)
				calculation.E_critPerc = GetSpellCritChance(5) + calculation.spellCrit
			end
		end
		if calculation.offHand then
			local name, rank = self:GetWeaponBuff(true)
			if name then
				if string_find(wf, name) then
					local _, ospd = UnitAttackSpeed("player")
					if ospd then
						--Glyph of Windfury Weapon (4.0)
						pco = self:HasGlyph(55445) and (select(math_floor(ospd/1.5) + 1, 0.132, 0.153, 0.18) or 0.22) or (select(math_floor(ospd/1.5) + 1, 0.125, 0.143, 0.167) or 0.2)
						calculation.WindfuryBonus_O = self:ScaleData(10, nil, nil, nil, true)
						calculation.extraName = calculation.extraName and (calculation.extraName .. "+" .. wficon) or wficon
					end
				elseif string_find(ft, name) then
					local _, spd = self:GetWeaponSpeed()
					local bonus = spd * 0.01 * self:ScaleData(7.61)
					local coeff = (spd <= 2.6) and (spd / 2.6) * 0.1 or (0.1 + (spd - 2.6)/ 1.4 * 0.05)
					--Modifiers to core:
					calculation.extraDamage = 0
					if calculation.spec == 2 then
						calculation.extraDamage_O = 0.8 * coeff
					else
						calculation.extraDamageSP_O = 0.8 * coeff
					end
					calculation.extraName = calculation.extraName and (calculation.extraName .. "+" .. fticon) or fticon
					calculation.extra_O = (calculation.extra_O or 0) + bonus
					calculation.extraChance_O = spellHit
					calculation.E_canCrit = true
					calculation.E_critM = critM
					calculation.E_dmgM = dmgM
					--calculation.SP_O = GetSpellBonusDamage(3)
					calculation.E_critPerc_O = GetSpellCritChance(3) + calculation.spellCrit
				elseif string_find(fb, name) then
					local _, spd = self:GetWeaponSpeed()
					local bonus = self:ScaleData(0.609)
					--Modifiers to core:
					calculation.extraDamage = 0
					calculation.extraName = calculation.extraName and (calculation.extraName .. "+" .. fbicon) or fbicon
					calculation.extra_O = (calculation.extra_O or 0) + bonus
					calculation.extraDamageSP_O = 0.1
					calculation.extraChance_O = (spd * 9)/60 * spellHit
					calculation.E_canCrit = true
					calculation.E_critM = critM
					calculation.E_dmgM = dmgM
					--calculation.SP_O = GetSpellBonusDamage(5)
					calculation.E_critPerc_O = GetSpellCritChance(5) + calculation.spellCrit
				end
			end
		end
		if Talents["Elemental Weapons"] then
			calculation.WindfuryDmgM = 1 + 0.2 * Talents["Elemental Weapons"]
		end
		--Model windfury cooldown effects
		if pcm and pco then
			local spd, ospd = UnitAttackSpeed("player")
			if spd <= 1.5 and ospd <= 1.5 then
				--From total 1.7s to 2.9s combined (simulation from 0.8 - 1.4, 0.9 - 1.5)
				if self:HasGlyph(55445) then
					--Max error deviation 1.39%, avg 0.346%
					pcm = 10.9 + math_min(1,math_max(0,(spd+ospd-1.7)/1.2)) * 4.1
				else
					--Max error deviation 0.8%, avg: 0.314%
					pcm = 10.7 + math_min(1,math_max(0,(spd+ospd-1.7)/1.2)) * 3.8
				end
			elseif spd <= 1.5 or ospd <= 1.5 then
				--From total 2.4s to 4.2s combined (simulation from 0.8 - 1.5, 1.6 - 2.7)
				if self:HasGlyph(55445) then
					--Max error deviation 1.73%, avg 0.725%
					pcm = 13.8 + math_min(1,math_max(0,(spd+ospd-2.4)/1.8)) * 4
				else
					--Max error deviation 1.7%, avg 0.678%
					pcm = 13.3 + math_min(1,math_max(0,(spd+ospd-2.4)/1.8)) * 3.9
				end
			elseif spd > 1.5 and ospd > 1.5 then
				--From total 3.3s to 5.3s combined (simulation from 1.6 - 2.6, 1.7 - 2.7)
				if self:HasGlyph(55445) then
					--Max error deviation 1.67%, avg 0.198%
					pcm = 18.5 + math_min(1,math_max(0,(spd+ospd-3.3)/2)) * 2.6
				else
					--Max error deviation 1.58%, avg 0.165%
					pcm = 17.8 + math_min(1,math_max(0,(spd+ospd-3.3)/2)) * 2.4
				end
			end
			calculation.WindfuryChance = pcm / 100
		else
			calculation.WindfuryChance = pcm or pco
		end
	end
	self.Calculation["Earth Shield"] = function( calculation, _, Talents )
		--Glyph of Earth Shield (4.0, multiplicative - 3.3.3)
		if self:HasGlyph(63279) then
			calculation.dmgM = calculation.dmgM * 1.2
		end
		if Talents["Purification"] and calculation.target ~= "player" then
			--CHECK: - [BUG] Earth Shield is only affected by the Purification specialization when cast upon yourself. So you lose out on 10% effectiveness.
			calculation.dmgM = calculation.dmgM / (1 + Talents["Purification"])
		end
	end
	self.Calculation["Lava Burst"] = function( calculation, ActiveAuras )
		--Glyph of Lava Burst (4.0)
		if self:HasGlyph(55454) then
			--CHECK
			calculation.dmgM = calculation.dmgM * 1.1
		end
		if ActiveAuras["Flame Shock"] then
			calculation.critPerc = 100
		end
		if self:GetSetAmount( "T7 Elemental" ) >= 4 then
			calculation.critM = calculation.critM + 0.05
		end
		if self:GetSetAmount( "T9 Elemental" ) >= 4 then
			calculation.extraAvg = 0.1
			calculation.extraTicks = 3
			calculation.extraName = "4T9"
		end
	end
	self.Calculation["Chain Heal"] = function( calculation )
		--Glyph of Chain Heal (4.0)
		if self:HasGlyph(55437) then
			calculation.dmgM = calculation.dmgM * 0.9
			--TODO: CHECK
			calculation.chainFactor = (calculation.chainFactor + 0.15)
			calculation.chainBonus = 1/0.9
		end
		if self:GetSetAmount( "T7 Healer" ) >= 4 then
			calculation.dmgM = calculation.dmgM * 1.05
		end
		if self:GetSetAmount( "T9 Healer" ) >= 4 then
			calculation.critPerc = calculation.critPerc + 5
		end
		if self:GetSetAmount( "T10 Healer" ) >= 4 then
			--TODO-MINOR: Make work in conjunction with ELW?
			if calculation.extra then
				calculation.extra = nil
				calculation.extraDamage = nil
				calculation.extraChance = nil
				calculation.extraBonus = nil
			end
			-- 25% of amount healed becomes a HoT over 9s on critical heal
			calculation.extraCrit = 0.25
			calculation.extraChanceCrit = true
			calculation.extraTicks = 3
			calculation.extraName = "4T10"
		end
	end
	self.Calculation["Chain Lightning"] = function( calculation, ActiveAuras, Talents )
		--Glyph of Chain Lightning (4.0)
		if self:HasGlyph(55449) then
			calculation.aoe = 5
			calculation.dmgM = calculation.dmgM * 0.9
			calculation.chainBonus = 1/0.9
		end
		if Talents["Rolling Thunder"] and ActiveAuras["Lightning Shield"] then
			calculation.manaCost = calculation.manaCost - 0.02 * UnitPowerMax("player",0) * Talents["Rolling Thunder"]
		end
	end
	self.Calculation["Flame Shock"] = function( calculation )
		--Glyph of Flame Shock (4.0)
		if self:HasGlyph(55447) then
			calculation.eDuration = calculation.eDuration + 9
		end
		--Glyph of Shocking (4.0)
		if self:HasGlyph(55442) then
			calculation.castTime = 1
		end
		if self:GetSetAmount( "T8 Elemental" ) >= 2 then
			calculation.dmgM_dot_Add = calculation.dmgM_dot_Add + 0.2
		end
		if self:GetSetAmount( "T9 Elemental" ) >= 2 then
			calculation.eDuration = calculation.eDuration + 9
		end
		--Confirmed additive - 3.3.3
		if self:GetSetAmount( "T9 Melee" ) >= 4 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.25
		end
		if self:GetSetAmount( "T11 Elemental" ) >= 2 then
			calculation.critPerc = calculation.critPerc + 10
		end
	end
	self.Calculation["Frost Shock"] = function( calculation )
		--Glyph of Shocking (4.0)
		if self:HasGlyph(55442) then
			calculation.castTime = 1
		end
		if self:GetSetAmount( "T9 Melee" ) >= 4 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.25
		end
	end
	local fulmination_icon = "|T" .. select(3,GetSpellInfo(88766)) .. ":16:16:1:-1|t"
	self.Calculation["Earth Shock"] = function( calculation, ActiveAuras, Talents )
		--Glyph of Shocking (4.0)
		if self:HasGlyph(55442) then
			calculation.castTime = 1
		end
		if self:GetSetAmount( "T9 Melee" ) >= 4 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.25
		end
		if Talents["Fulmination"] and ActiveAuras["Lightning Shield"] then
			local apps = ActiveAuras["Lightning Shield"] - 3
			if apps > 0 then
				--When you have more than 3 Lightning Shield charges active, your Earth Shock spell will consume any surplus charges, instantly dealing their total damage to the enemy target.
				local ls = self.spellInfo[lightning_shield]
				calculation.extra = apps * ls[1][1]
				calculation.extraDamage = apps * ls[0].SPBonus
				calculation.extraDmgM = select(7,UnitDamage("player")) * calculation.dmgM_Magic * (1 + (Talents["Improved Shields"] or 0) + 0.01 * (Talents["Elemental Precision"] or 0))
				calculation.extraName = fulmination_icon
				calculation.extraCanCrit = true
			end
		end
	end
	self.Calculation["Lightning Bolt"] = function( calculation, ActiveAuras, Talents )
		--Glyph of Lightning Bolt (4.0, additive - 3.3.2)
		if self:HasGlyph(55453) then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.04
		end
		if self:GetSetAmount( "T8 Elemental" ) >= 4 then
			calculation.extraCrit = 0.08
			calculation.extraCritChance = true
			calculation.extraTicks = 2
		end
		if self:GetSetAmount( "T11 Melee" ) >= 4 then
			calculation.critPerc = calculation.critPerc + 10
		end
		if Talents["Rolling Thunder"] and ActiveAuras["Lightning Shield"] then
			calculation.manaCost = calculation.manaCost - 0.02 * UnitPowerMax("player",0) * Talents["Rolling Thunder"]
		end
	end
	self.Calculation["Lightning Shield"] = function( calculation )
		if self:GetSetAmount( "T7 Melee" ) >= 2 then --(Additive/Multiplicative)
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
	end
	self.Calculation["Riptide"] = function( calculation )
		--Glyph of Riptide (4.0)
		if self:HasGlyph(63273) then
			calculation.eDuration = calculation.eDuration + 6
		end
		if self:GetSetAmount( "T8 Healer" ) >= 2 then
			calculation.cooldown = calculation.cooldown - 1
		end
		if self:GetSetAmount( "T9 Healer" ) >= 2 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.2
		end
	end
	local mana_restore = GetSpellInfo(33511)
	self.Calculation["Thunderstorm"] = function( calculation )
		--Glyph of Thunder (4.0)
		if self:HasGlyph(63270) then
			calculation.cooldown = calculation.cooldown - 10
		end
		--Glyph of Thunderstorm (4.0)
		calculation.customText = mana_restore or "Mana Restore"
		calculation.customTextValue = (0.08 + (self:HasGlyph(62132) and 0.02 or 0)) * UnitPowerMax("player",0)
	end
	self.Calculation["Healing Wave"] = function( calculation )
		if self:GetSetAmount( "T7 Healer" ) >= 4 then
			calculation.dmgM = calculation.dmgM * 1.05
		end
		if self:GetSetAmount( "T11 Healer" ) >= 2 then
			calculation.critPerc = calculation.critPerc + 5
		end
	end
	self.Calculation["Cleanse Spirit"] = function( calculation, _, Talents )
		calculation.minDam = calculation.minDam * (Talents["Cleansing Waters"] or 0)
		calculation.maxDam = calculation.maxDam * (Talents["Cleansing Waters"] or 0)
		calculation.SPBonus = calculation.SPBonus * (Talents["Cleansing Waters"] or 0)
	end
	self.Calculation["Searing Totem"] = function( calculation, _, Talents )
		--if Talents["Searing Flames"] then
		--TODO: Searing Flames: Causes the Searing Bolts from your Searing Totem to have a 100% chance to set their targets aflame, dealing damage equal to the Searing Bolt's impact damage over 15 sec. Stacks up to 5 times.
		--end
	end
	self.Calculation["Stormstrike"] = function( calculation )
		if self:GetSetAmount( "T8 Melee" ) >= 2 then
			calculation.dmgM = calculation.dmgM * 1.2
		end
		if self:GetSetAmount( "T11 Melee" ) >= 2 then
			--CHECK: Verify
			calculation.dmgM = calculation.dmgM * 1.2
		end
	end
	self.Calculation["Lava Lash"] = function( calculation, ActiveAuras, Talents )
		--Glyph of Lava Lash (4.0)
		if self:HasGlyph(55444) then
			--CHECK
			calculation.dmgM = calculation.dmgM * 1.2
		end
		if Talents["Improved Lava Lash"] and ActiveAuras["Searing Flames"] then
			--CHECK
			calculation.dmgM_Add = calculation.dmgM_Add + ActiveAuras["Searing Flames"] * Talents["Improved Lava Lash"]
		end
		if calculation.offHand then
			local name = self:GetWeaponBuff(true)
			if name and string_find(ft, name) then
				calculation.dmgM = calculation.dmgM * 1.4
			end
		end
		--Additive/multiplicative?
		if self:GetSetAmount( "T8 Melee" ) >= 2 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.2
		end
		if self:GetSetAmount( "T11 Melee" ) >= 2 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.2
		end
	end
--SETS
	self.SetBonuses["T7 Melee"] = { 40520, 40521, 40522, 40523, 40524, 39597, 39601, 39602, 39603, 39604 }
	self.SetBonuses["T7 Elemental"] = { 39592, 39593, 39594, 39595, 39596, 40514, 40515, 40516, 40517, 40518 }
	self.SetBonuses["T7 Healer"] = { 40508, 40509, 40510, 40512, 40513, 39583, 39588, 39589, 39590, 39591 }
	self.SetBonuses["T8 Melee"] = { 46200, 46203, 46205, 46208, 46212, 45412, 45413, 45414, 45415, 45416 }
	self.SetBonuses["T8 Elemental"] = { 46206, 46207, 46209, 46210, 46211, 45406, 45408, 45409, 45410, 45411 }
	self.SetBonuses["T8 Healer"] = { 46198, 46199, 46201, 46202, 46204, 45401, 45402, 45403, 45404, 45405 }
	self.SetBonuses["T9 Melee"] = { 48341, 48342, 48343, 48344, 48345, 48366, 48367, 48368, 48369, 48370, 48346, 48348, 48347, 48350, 48349, 48355, 48353, 48354, 48351, 48352, 48365, 48363, 48364, 48361, 48362, 48356, 48358, 48357, 48360, 48359 }
	self.SetBonuses["T9 Elemental"] = { 48310, 48312, 48313, 48314, 48315, 48336, 48337, 48338, 48339, 48340, 48334, 48335, 48333, 48332, 48331, 48327, 48326, 48328, 48329, 48330, 48317, 48316, 48318, 48319, 48320, 48324, 48325, 48323, 48322, 48321 }
	self.SetBonuses["T9 Healer"] = { 48280, 48281, 48282, 48283, 48284, 48295, 48296, 48297, 48298, 48299, 48301, 48302, 48303, 48304, 48300, 48306, 48307, 48308, 48309, 48305, 48286, 48287, 48288, 48289, 48285, 48293, 48292, 48291, 48290, 48294 }
	--self.SetBonuses["T10 Elemental"] = { 50842, 50841, 50843, 50844, 50845, 51238, 51201, 51239, 51200, 51237, 51202, 51236, 51203, 51235, 51204 }
	self.SetBonuses["T10 Healer"] = { 50836, 50837, 50838, 50839, 50835, 51248, 51191, 51247, 51192, 51246, 51193, 51245, 51194, 51249, 51190 }
	self.SetBonuses["T11 Melee"] = { 60318, 60319, 60320, 60321, 60322, 65249, 65250, 65251, 65252, 65253 }
	self.SetBonuses["T11 Elemental"] = { 60313, 60314, 60315, 60316, 30317, 65254, 65255, 65256, 65257, 65258 }
	self.SetBonuses["T11 Healer"] = { 60308, 60309, 60310, 60311, 60312, 65244, 65245, 65246, 65247, 65248 }

	--AURA
--Player
	--Maelstrom Weapon (4.0)
	self.PlayerAura[GetSpellInfo(53817)] = { Update = true }
	--Lava Flows (4.0)
	self.PlayerAura[GetSpellInfo(65264)] = self.PlayerAura[GetSpellInfo(53817)]
	--Elemental Mastery (4.0 - Fire, Frost, Nature)
	self.PlayerAura[GetSpellInfo(16166)] = { School = "Damage Spells", Value = 0.15, ID = 16166, Mods = { ["haste"] = 1.2 } }
	--Clearcasting (4.0)
	self.PlayerAura[GetSpellInfo(16246)] = { School = "Spells", ActiveAura = "Clearcasting", ID = 16246, Mods = { ["manaCost"] = function(v) return v * 0.6 end } }
	--Lightning Shield (4.0)
	self.PlayerAura[GetSpellInfo(324)] = { ActiveAura = "Lightning Shield", Apps = 3, Spells = { "Chain Lightning", "Lightning Bolt", "Stormstrike", "Lava Lash", "Primal Strike", "Earth Shock" }, ID = 324 }
	--Focused Insight (4.0)
	self.PlayerAura[GetSpellInfo(77800)] = { School = "Healing", ID = 77800, ModType =
		function( calculation, _, Talents )
			if Talents["Focused Insight"] then
				calculation.dmgM = calculation.dmgM * (1 + Talents["Focused Insight"])
			end
		end
	}
	--Tidal Waves (4.0)
	self.PlayerAura[GetSpellInfo(53390)] = { Spells = { "Healing Wave", "Greater Healing Wave", "Healing Surge" }, NoManual = true, ModType =
		function( calculation, _, Talents )
			if Talents["Tidal Waves"] then
				calculation.critPerc = calculation.critPerc + Talents["Tidal Waves"]
			end
		end
	}
	--Unleash Flame (4.0)
	self.PlayerAura[GetSpellInfo(73683)] = { Spells = { "Flame Shock", "Lava Burst", "Fire Nova" }, ID = 73683, ModType =
		function( calculation, _, Talents )
			calculation.dmgM = calculation.dmgM * (1 + 0.2 * (1 + 0.25 * (Talents["Elemental Weapons"] or 0)))
		end
	}
	--Unleash Life (4.0)
	--TODO: Does this work with chain heal or riptide dh-part?
	self.PlayerAura[GetSpellInfo(73685)] = { Spells = { "Healing Surge", "Healing Wave", "Greater Healing Wave", "Chain Heal", "Riptide" }, ID = 73685, ModType =
		function( calculation, _, Talents )
			calculation.dmgM = calculation.dmgM * (1 + 0.2 * (1 + 0.25 * (Talents["Elemental Weapons"] or 0)))
		end
	}	

--Target
	--Riptide (4.0)
	self.TargetAura[GetSpellInfo(61295)] = { Spells = "Chain Heal", Value = 0.25, ID = 61295 }
	--Flame Shock (4.0)
	self.TargetAura[GetSpellInfo(8050)] = { ActiveAura = "Flame Shock", Spells = "Lava Burst", ID = 8050 }
	--Frostbrand Attack (4.0)
	self.TargetAura[GetSpellInfo(8034)] = { ActiveAura = "Frostbrand Attack", ID = 8034 }
	--Earth Shield (4.0)
	self.TargetAura[GetSpellInfo(974)] = { School = "Healing", ActiveAura = "Earth Shield", SelfCastBuff = true, ID = 974 }
	--Searing Flames (4.0)
	self.TargetAura[GetSpellInfo(77661)] = { ActiveAura = "Searing Flames", Apps = 5, ID = 7766 }
	--Stormstrike (4.0)
	self.TargetAura[GetSpellInfo(17364)] = { Spells = { "Lightning Bolt", "Chain Lightning", "Lightning Shield", "Earth Shock", }, SelfCast = true, ID = 17364, ModType =
		function( calculation )
			--Glyph of Stormstrike (4.0)
			calculation.critPerc = calculation.critPerc + (self:HasGlyph(55446) and 35 or 25)
		end
	}

	self.spellInfo = {
		[GetSpellInfo(324)] = {
			["Name"] = "Lightning Shield",
			["ID"] = 324,
			["Data"] = { 0.389, 0, 0.267, ["c_scale"] = 0.35 },
			[0] = { School = "Nature", Hits = 3, NoDPS = true, NoDoom = true, NoPeriod = true, },
			[1] = { 0, 0 },
		},
		[GetSpellInfo(403)] = {
			["Name"] = "Lightning Bolt",
			["ID"] = 403,
			["Data"] = { 0.767, 0.133, 0.714, ["ct_min"] = 1500, ["ct_max"] = 2500 },
			[0] = { School = "Nature" },
			[1] = { 0, 0 },
		},
		[GetSpellInfo(421)] = {
			["Name"] = "Chain Lightning",
			["ID"] = 421,
			["Data"] = { 1.088, 0.133, 0.571, },
			[0] = { School = "Nature", Cooldown = 3, chainFactor = 0.7, AoE = 3, },
			[1] = { 0, 0 },
		},
		[GetSpellInfo(8042)] = {
			["Name"] = "Earth Shock",
			["ID"] = 8042,
			["Data"] = { 0.927, 0.053, 0.386, },
			[0] = { School = { "Nature", "Shock" }, Cooldown = 6, },
			[1] = { 0, 0 },
		},
		[GetSpellInfo(8050)] = {
			["Name"] = "Flame Shock",
			["ID"] = 8050,
			["Data"] = { 0.529, 0, 0.214, 0.142, 0, 0.1 },
			[0] = { School = { "Fire", "Shock" }, Cooldown = 6, Hits_dot = 6, eDuration = 18, sTicks = 3, },
			[1] = { 0, 0, hybridDotDmg = 0 },
		},
		[GetSpellInfo(8056)] = {
			["Name"] = "Frost Shock",
			["ID"] = 8056,
			["Data"] = { 0.869, 0.056, 0.386, },
			[0] = { School = { "Frost", "Shock" }, Cooldown = 6, },
			[1] = { 0, 0 },
		},
		[GetSpellInfo(3599)] = {
			["Name"] = "Searing Totem",
			["ID"] = 3599,
			["Data"] = { 0.096, 0.3, 0.167, },
			[0] = { School = "Fire", NoDotHaste = true, Hits = 24, eDot = true, eDuration = 60, sTicks = 2.5 },
			[1] = { 0, 0 },
		},
		[GetSpellInfo(1535)] = {
			["Name"] = "Fire Nova",
			["ID"] = 1535,
			["Data"] = { 0.683, 0.112, 0.143, },
			[0] = { School = "Fire", Cooldown = 10, AoE = true, },
			[1] = { 0, 0 },
		},
		[GetSpellInfo(8190)] = {
			["Name"] = "Magma Totem",
			["ID"] = 8190,
			["Data"] = { 0.267, 0, 0.067, },
			[0] = { School = "Fire", NoDotHaste = true, Hits = 10, eDot = true, eDuration = 20, sTicks = 2, AoE = true },
			[1] = { 0, 0 },
		},
		[GetSpellInfo(51490)] = {
			["Name"] = "Thunderstorm",
			["ID"] = 51490,
			["Data"] = { 1.63, 0.133, 0.571, },
			[0] = { School = "Nature", Cooldown = 45, AoE = true, },
			[1] = { 0, 0 },
		},
		[GetSpellInfo(51505)] = {
			["Name"] = "Lava Burst",
			["ID"] = 51505,
			["Data"] = { 1.579, 0.242, 0.628, },
			[0] = { School = "Fire", Cooldown = 8, },
			[1] = { 0, 0 },
		},
		[GetSpellInfo(8004)] = {
			["Name"] = "Healing Surge",
			["ID"] = 8004,
			["Data"] = { 5.978, 0.133, 0.604, },
			[0] = { School = { "Nature", "Healing", }, DirectHeal = true },
			[1] = { 0, 0 },
		},
		[GetSpellInfo(331)] = {
			["Name"] = "Healing Wave",
			["ID"] = 331,
			["Data"] = { 2.989, 0.133, 0.302, ["ct_min"] = 1500, ["ct_max"] = 3000 },
			[0] = { School = { "Nature", "Healing", }, DirectHeal = true },
			[1] = { 0, 0 },
		},
		[GetSpellInfo(77472)] = {
			["Name"] = "Greater Healing Wave",
			["ID"] = 77472,
			["Data"] = { 9.564, 0.133, 0.967, },
			[0] = { School = { "Nature", "Healing", }, DirectHeal = true },
			[1] = { 0, 0 },
		},
		[GetSpellInfo(1064)] = {
			["Name"] = "Chain Heal",
			["ID"] = 1064,
			["Data"] = { 3.5, 0.133, 0.35, },
			[0] = { School = { "Nature", "Healing", }, DirectHeal = true, chainFactor = 0.7, AoE = 3 },
			[1] = { 0, 0 },
		},
		--TODO: Fix base value, seems increased by 20%
		[GetSpellInfo(5394)] = {
			["Name"] = "Healing Stream Totem",
			["ID"] = 5394,
			["Data"] = { 0.028 * 1.2, 0, 0.0827, },
			[0] = { School = { "Nature", "Healing", }, NoDotHaste = true, NoCrits = true, Hits = 150, eDot = true, eDuration = 300, sTicks = 2, AoE = 5, },
			[1] = { 0, 0 },
		},
		[GetSpellInfo(974)] = {
			["Name"] = "Earth Shield",
			["ID"] = 974,
			["Data"] = { 1.7622, 0, 1, },
			[0] = { School = { "Nature", "Healing", }, Hits = 9, NoDPS = true, NoDoom = true, NoPeriod = true, },
			[1] = { 0, 0 },
		},
		[GetSpellInfo(61295)] = {
			["Name"] = "Riptide",
			["ID"] = 61295,
			["Data"] = { 2.353, 0, 0.238, 0.742, 0, 0.075 },
			[0] = { School = { "Nature", "Healing", }, DirectHeal = true, Hits_dot = 5, eDuration = 15, sTicks = 3, Cooldown = 6, },
			[1] = { 0, 0, hybridDotDmg = 0, },
		},
		[GetSpellInfo(73920)] = {
			["Name"] = "Healing Rain",
			["ID"] = 73920,
			["Data"] = { 0.752, 0.173, 0.076, },
			[0] = { School = { "Nature", "Healing", }, Hits = 5, eDot = true, eDuration = 10, sTicks = 2, Cooldown = 10, AoE = 6, },
			[1] = { 0, 0 },
		},
		[GetSpellInfo(17364)] = {
			["Name"] = "Stormstrike",
			["ID"] = 17364,
			--["Data"] = { },
			[0] = { Melee = true, WeaponDamage = 1.25, Cooldown = 8, DualAttack = true, NoNormalization = true, SP = 4 },
			[1] = { 0 },
		},
		[GetSpellInfo(73899)] = {
			--TODO: Is this normalized?
			["Name"] = "Primal Strike",
			["ID"] = 73899,
			["Data"] = { 0.178 },
			[0] = { Melee = true, WeaponDamage = 1, Cooldown = 8, SP = 4, --[[NoNormalization = true--]] },
			[1] = { 0 },
		},
		[GetSpellInfo(60103)] = {
			["Name"] = "Lava Lash",
			["ID"] = 60103,
			--["Data"] = { },
			[0] = { School = "Fire", Melee = true, WeaponDamage = 2, Cooldown = 10, OffhandAttack = true, NoNormalization = true, SP = 4 },
			[1] = { 0 },
		},
		[GetSpellInfo(61882)] = {
			["Name"] = "Earthquake",
			["ID"] = 61882,
			["Data"] = { 0.54 },
			--TOOLTIP BUG: Blizzard states coefficient to be 0.21
			[0] = { Melee = true, SPBonus = 0.1908, Hits = 8, Channeled = 8, Unavoidable = true, NoArmor = true },
			[1] = { 0 },
		},
		[GetSpellInfo(51886)] = {
			["Name"] = "Cleanse Spirit",
			["ID"] = 51886,
			["Data"] = { 1.395, 0.12, 0.141, },
			[0] = { School = { "Nature", "Healing", }, DirectHeal = true },
			[1] = { 0, 0 },
		},
		[GetSpellInfo(73680)] = {
			[0] = function()
				local name = self:GetWeaponBuff()
				if name then
					if string_find(wf,name) then
						return self.spellInfo[wf][0], self.spellInfo[wf]
					elseif string_find(ft,name) then
						return self.spellInfo[ft][0], self.spellInfo[ft]
					elseif string_find(fb,name) then
						return self.spellInfo[fb][0], self.spellInfo[fb]
					elseif string_find(elw,name) then
						return self.spellInfo[elw][0], self.spellInfo[elw]
					end
				end
			end,
			--[[
			["Secondary"] = {
				[0] = function()
					local name = self:GetWeaponBuff(true)
					if name then
						if string_find(wf,name) then
							return self.spellInfo[wf][0], self.spellInfo[wf]
						elseif string_find(ft,name) then
							return self.spellInfo[ft][0], self.spellInfo[ft]
						elseif string_find(fb,name) then
							return self.spellInfo[fb][0], self.spellInfo[fb]
						elseif string_find(elw,name) then
							return self.spellInfo[elw][0], self.spellInfo[elw]
						end
					end
				end,
			},
			--]]
		},
		[GetSpellInfo(8232)] = {
			["Name"] = "Unleash Wind",
			["Text1"] = GetSpellInfo(73680),
			["Text2"] = GetSpellInfo(73681),
			["ID"] = 8232,
			[0] = { Melee = true, WeaponDamage = 1.25, Cooldown = 15, SpellCost = 73680 },
			[1] = { 0, 0 },
		},
		[GetSpellInfo(8024)] = {
			["Name"] = "Unleash Flame",
			["Text1"] = GetSpellInfo(73680),
			["Text2"] = GetSpellInfo(73683),
			["ID"] = 8024,
			["Data"] = { 1.113, 0.17, 0.429 },
			[0] = { School = "Fire", Cooldown = 15, SpellCost = 73680 },
			[1] = { 0, 0 },
		},
		[GetSpellInfo(8033)] = {
			["Name"] = "Unleash Frost",
			["Text1"] = GetSpellInfo(73680),
			["Text2"] = GetSpellInfo(73682),
			["ID"] = 8033,
			["Data"] = { 0.869, 0.15, 0.386 },
			[0] = { School = "Frost", Cooldown = 15, SpellCost = 73680 },
			[1] = { 0, 0 },
		},
		[GetSpellInfo(51730)] = {
			["Name"] = "Unleash Life",
			["Text1"] = GetSpellInfo(73680),
			["Text2"] = GetSpellInfo(73685),
			["ID"] = 51730,
			["Data"] = { 1.987, 0.08, 0.201  },
			[0] = { School = { "Nature", "Healing" }, Cooldown = 15, SpellCost = 73680, DirectHeal = true },
			[1] = { 0, 0 },
		},
	}
	self.talentInfo = {
	--ELEMENTAL:
		--Concussion (additive - 3.3.3)
		[GetSpellInfo(16035)] = { 	[1] = { Effect = 0.02, Caster = true, Spells = { "Lightning Bolt", "Chain Lightning", "Thunderstorm", "Lava Burst", "Shock" }, }, },
		--Call of Flame (additive with Improved Fire Nova and Concussion - 3.3.3)
		[GetSpellInfo(16038)] = { 	[1] = { Effect = 0.10, Caster = true, Spells = { "Searing Totem", "Magma Totem", "Fire Nova" } },
									[2] = { Effect = 0.05, Caster = true, Spells = "Lava Burst" }, },
		--Reverberation
		[GetSpellInfo(16040)] = { 	[1] = { Effect = -0.5, Caster = true, Spells = "Shock", ModType = "cooldown" }, },
		--Elemental Precision (additive?)
		[GetSpellInfo(30672)] = { 	[1] = { Effect = 0.01, Spells = { "Fire", "Frost", "Nature" }, Not = "Healing" },
									[2] = { Effect = 1, Spells = "All", ModType = "Elemental Precision" }, },
		--Rolling Thunder
		[GetSpellInfo(88756)] = { 	[1] = { Effect = 0.3, Caster = true, Spells = { "Lightning Bolt", "Chain Lightning" }, ModType = "Rolling Thunder" }, },
		--Elemental Oath (multiplicative?)
		[GetSpellInfo(51466)] = { 	[1] = { Effect = 0.05, Caster = true, Spells = "All", ModType = "Elemental Oath" }, 
									[2] = { Effect = 0.05, Melee = true, Spells = "Earthquake", ModType = "Elemental Oath" }, },
		--Lava Flows (additive?)
		[GetSpellInfo(51480)] = { 	[1] = { Effect = { 0.03, 0.06, 0.12 }, Caster = true, Spells = "Lava Burst", ModType = "critM", },
									[2] = { Effect = 0.2, Caster = true, Spells = "Flame Shock", ModType = "dmgM_dot_Add" }, },
		--Fulmination
		[GetSpellInfo(88766)] = { 	[1] = { Effect = 1, Caster = true, Spells = "Earth Shock", ModType = "Fulmination" }, },

	--ENHANCEMENT:
		--Elemental Weapons
		[GetSpellInfo(16266)] = {	[1] = { Effect = 1, Spells = "All", ModType = "Elemental Weapons" }, },
		--Focused Strikes (additive?)
		[GetSpellInfo(77536)] = {	[1] = { Effect = 0.15, Melee = true, Spells = { "Stormstrike", "Primal Strike" } }, },
		--Improved Shields (additive - 3.3.3)
		[GetSpellInfo(16261)] = { 	[1] = { Effect = 0.05, Caster = true, Spells = { "Lightning Shield", "Earth Shield" }, },
									[2] = { Effect = 0.05, Melee = true, Spells = { "Lava Lash", "Stormstrike", "Primal Strike" }, ModType = "Improved Shields" }, },
		--Static Shock
		[GetSpellInfo(51525)] = { 	[1] = { Effect = 0.15, Melee = true, Spells = { "Stormstrike", "Primal Strike", "Lava Lash" }, ModType = "Static Shock" }, },
		--Frozen Power (multiplicative - 3.3.3)
		[GetSpellInfo(63373)] = {	[1] = { Effect = 0.05, Spells = { "Chain Lightning", "Lightning Bolt", "Shock", "Lava Lash" }, ModType = "Frozen Power" }, },
		--Improved Fire Nova (additive - 3.3.3)
		[GetSpellInfo(16086)] = {	[1] = { Effect = 0.1, Caster = true, Spells = "Fire Nova", },
									[2] = { Effect = -2, Caster = true, Spells = "Fire Nova", ModType = "cooldown" }, },
		--Searing Flames
		[GetSpellInfo(77655)] = { 	[1] = { Effect = { 0.33, 0.66, 1 }, Caster = true, Spells = "Searing Totem", ModType = "Searing Flames" }, },
		--Improved Lava Lash (additive?)
		[GetSpellInfo(77700)] = { 	[1] = { Effect = 0.15, Spells = "Lava Lash", },
									[2] = { Effect = 0.1, Spells = "Lava Lash", ModType = "Improved Lava Lash" }, },

	--RESTORATION:
		--Spark of Life (additive? - self-healing is multiplicative)
		[GetSpellInfo(84846)] = { 	[1] = { Effect = 0.02, Caster = true, Spells = "Healing", },
									[2] = { Effect = 0.05, Caster = true, Spells = "Healing", ModType = "Spark of Life" }, },
		--TODO-MINOR: Improved Water Shield?
		--Focused Insight (buff after Shock cast - multiplicative?)
		[GetSpellInfo(77794)] = { 	[1] = { Effect = 0.1, Caster = true, Spells = "Healing", ModType = "Focused Insight" }, },
		--Nature's Blessing (buff on Earth Shielded targets - multiplicative?)
		[GetSpellInfo(30867)] = { 	[1] = { Effect = 0.05, Caster = true, Spells = "Healing", ModType = "Nature's Blessing" }, },
		--Soothing Rains (4.0: Healing Stream Totem part is multiplicative with Spark of Life -- which one is multiplicative?)
		[GetSpellInfo(16187)] = { 	[1] = { Effect = 0.25, Caster = true, Multiply = true, Spells = "Healing Stream Totem", },
									[2] = { Effect = 0.15, Caster = true, Multiply = true, Spells = "Healing Rain" }, },
		[GetSpellInfo(86959)] = { 	[1] = { Effect = 1, Caster = true, Spells = "Cleanse Spirit", ModType = "Cleansing Waters" }, },
		--TODO-MINOR: Telluric currents?
		--Your attunement to natural energies causes your Lightning Bolt spell to restore mana equal to 20%/40% of damage dealt.
		--Tidal Waves
		[GetSpellInfo(51562)] = {	[1] = { Effect = 10, Caster = true, Spells = "Healing Surge", ModType = "Tidal Waves" }, },
		--Blessing of the Eternals
		[GetSpellInfo(51554)] = { 	[1] = { Effect = 0.4, Caster = true, Spells = "Healing", ModType = "Blessing of the Eternals" }, },
	}
end