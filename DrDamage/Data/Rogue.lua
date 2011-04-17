if select(2, UnitClass("player")) ~= "ROGUE" then return end
local GetSpellInfo = DrDamage.SafeGetSpellInfo
local GetSpellCritChance = GetSpellCritChance
local GetCritChance = GetCritChance
local UnitDebuff = UnitDebuff
local UnitCreatureType = UnitCreatureType
local math_min = math.min
local math_max = math.max
local math_floor = math.floor
local math_ceil = math.ceil
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitDamage = UnitDamage
local string_find = string.find
local string_lower = string.lower
local IsEquippedItemType = IsEquippedItemType
local select = select
local IsSpellKnown = IsSpellKnown

--Talent Precision is handled by API

function DrDamage:PlayerData()
	--Health Updates
	self.TargetHealth = { [1] = 0.35, [2] = "player" }
	--Special aura handling
	local TargetIsPoisoned = false
	local Mutilate = GetSpellInfo(1329)
	local poison = GetSpellInfo(38615)
	self.Calculation["TargetAura"] = function()
		local temp = TargetIsPoisoned
		TargetIsPoisoned = false

		for i=1,40 do
			local name, _, _, _, debuffType = UnitDebuff("target",i)
			if name then
				if debuffType == poison then
					TargetIsPoisoned = true
					break
				end
			else break end
		end
		if temp ~= TargetIsPoisoned then
			return true, Mutilate
		end
	end
--GENERAL
	self.Calculation["Stats"] = function( calculation, ActiveAuras, Talents, spell, baseSpell )
		local mastery = calculation.mastery
		local masteryLast = calculation.masteryLast
		local spec = calculation.spec
		if spec == 1 then
			if mastery > 0 and mastery ~= masteryLast then
				if calculation.E_dmgM then
					local masteryBonus = calculation.masteryBonus
					if masteryBonus then
						calculation.E_dmgM = calculation.E_dmgM / masteryBonus
					end
					local bonus = 1 + mastery * 0.01 * 3.5
					calculation.E_dmgM = calculation.E_dmgM * bonus
					calculation.masteryLast = mastery
					calculation.masteryBonus = bonus
				end
			end
		elseif spec == 2 then
			if mastery > 0 and mastery ~= masteryLast then
				if baseSpell.AutoAttack and calculation.offHand then
					--Each point of Mastery increases the chance by an additional 2.00%
					calculation.extraWeaponDamageChance = mastery * 0.01 * 2
					calculation.masteryLast = mastery
				end
			end
		elseif spec == 3 then
			if mastery > 0 and mastery ~= masteryLast then
				if baseSpell.Finisher then
					local masteryBonus = calculation.masteryBonus
					if masteryBonus then
						calculation.dmgM = calculation.dmgM / masteryBonus
					end
					--Mastery: Executioner
					local bonus = 1 + mastery * 0.01 * 2.5
					calculation.dmgM = calculation.dmgM * bonus
					calculation.masteryLast = mastery
					calculation.masteryBonus = bonus
				end
			end
		end
	end
	--TODO: Verify if poison AP coefficients scale or not
	local instant = GetSpellInfo(8679)
	local wound = GetSpellInfo(13219)
	local deadly = GetSpellInfo(2823)
	local ipicon = "|T" .. select(3,GetSpellInfo(8679)) .. ":16:16:1:1|t"
	local wpicon = "|T" .. select(3,GetSpellInfo(13219)) .. ":16:16:1:1|t"
	local dpicon = "|T" .. select(3,GetSpellInfo(2823)) .. ":16:16:1:-1|t"
	local mgicon = "|T" .. select(3,GetSpellInfo(76806)) .. ":16:16:1:1|t"
	local hmicon = "|T" .. select(3,GetSpellInfo(56807)) .. ":16:16:1:1|t"
	local vwicon = "|T" .. select(3,GetSpellInfo(79133)) .. ":16:16:1:1|t"
	self.Calculation["ROGUE"] = function( calculation, ActiveAuras, Talents, spell, baseSpell )
		--TODO: Check specialization is active
		if IsSpellKnown(86531) then
			calculation.agiM = calculation.agiM * 1.05
		end
		--Specialization
		local spec = calculation.spec
		if spec == 1 then
			calculation.impPoison = true
		elseif spec == 2 then
			--Vitality: Increased attack power by 25%
			calculation.APM = calculation.APM * 1.25
			--Increased off-hand damage
			calculation.offHdmgM = calculation.offHdmgM * 1.75
			if calculation.group == "Ranged" then
				calculation.wDmgM = calculation.wDmgM * 1.75
			end
			if calculation.mastery > 0 then
				--Main gauche
				--Your main hand attacks have a 16% chance to grant you an extra off hand attack.
				--TODO: Yellow hit miss chance
				if baseSpell.AutoAttack and calculation.offHand then
					if not calculation.extraDamage then
						calculation.extraDamage = 0
					end
					calculation.extraWeaponDamage = 1
					calculation.extraWeaponDamageM = true
					calculation.extraWeaponDamageNorm = true
					calculation.extraWeaponDamage_dmgM = calculation.dmgM_global
					calculation.extra_canCrit = true
					calculation.extra_critM = 1 + 2 * self.Damage_critMBonus
					calculation.extra_critPerc = GetCritChance() + calculation.meleeCrit
					calculation.extraName = calculation.extraName and (calculation.extraName .. "+" .. mgicon) or mgicon
				end
			end
		elseif spec == 3 then
			--Sinister Calling: Increases agility by 30%
			calculation.agiM = calculation.agiM * 1.3
			if calculation.spellName == "Backstab" or calculation.spellName == "Hemorrhage" then
				--Multiplicative according to tooltip
				calculation.WeaponDamage = calculation.WeaponDamage * 1.40
			end
			--TODO-MINOR: Slice and Dice bonus from Executioner?
		end
		if Talents["Sanguinary Vein"] and ActiveAuras["Bleeding"] then
			calculation.dmgM = calculation.dmgM * (1 + Talents["Sanguinary Vein"])
		end
		if ActiveAuras["Blade Flurry"] then
			if not calculation.aoe then
				calculation.aoe = 2
			else
				calculation.targets = calculation.targets * 2
			end
		end
		local buff = self:GetWeaponBuff()
		local buffO = self:GetWeaponBuff(true)
		local hit
		if buff or buffO then
			calculation.E_dmgM = (1 + (Talents["Vile Poisons"] or 0)) * calculation.dmgM_Magic --* select(7,UnitDamage("player")) / calculation.dmgM_Physical
			calculation.E_canCrit = true
			calculation.E_critPerc = GetSpellCritChance(4) + calculation.spellCrit
			calculation.E_critM = 0.5 + self.Damage_critMBonus * 1.5
			hit = 0.01 * math_max(0,math_min(100, self:GetSpellHit(calculation.playerLevel,calculation.targetLevel) + calculation.spellHit))
		end
		if not baseSpell.OffhandAttack and not baseSpell.NoPoison and buff then
			--Instant Poison
			if buff == instant then
				local spd = self:GetWeaponSpeed()
				calculation.extra = math_ceil(self:ScaleData(0.313,0.28,calculation.playerLevel,0))
				calculation.extraDamage = 0.09
				calculation.extraChance = 0.2/1.4 * spd * (1 + (calculation.impPoison and 0.5 or 0) + (ActiveAuras["Envenom"] and 0.75 or 0)) * hit
				calculation.extraName = calculation.extraName and (calculation.extraName .. "+" .. ipicon) or ipicon
			--Wound Poison
			elseif buff == wound then
				local spd = self:GetWeaponSpeed()
				calculation.extra = math_ceil(self:ScaleData(0.245,0,calculation.playerLevel,0))
				calculation.extraDamage = 0.04
				calculation.extraChance = 0.5/1.4 * spd * hit
				calculation.extraName = calculation.extraName and (calculation.extraName .. "+" .. wpicon) or wpicon
			--Deadly Poison
			elseif baseSpell.AutoAttack and buff == deadly then
				calculation.extra_DPS = 4 * math_ceil(self:ScaleData(0.12, 0,calculation.playerLevel,0))
				calculation.extraDamage_DPS = 4 * 0.035
				calculation.extraDuration_DPS = 12
				calculation.extraStacks_DPS = 5
				calculation.extraName_DPS = "5x" .. dpicon
			end
		end
		if (baseSpell.AutoAttack or baseSpell.DualAttack or baseSpell.OffhandAttack) and buffO then
			--Instant Poison
			if buffO == instant then
				local _, spd = self:GetWeaponSpeed()
				calculation.extra_O = self:ScaleData(0.313,0.28,calculation.playerLevel,0)
				calculation.extraDamage_O = 0.09
				calculation.extraChance_O = 0.2/1.4 * spd * (1 + (calculation.impPoison and 0.5 or 0) + (ActiveAuras["Envenom"] and 0.75 or 0)) * hit
				calculation.extraName = calculation.extraName and (calculation.extraName .. "+" .. ipicon) or ipicon
				if not calculation.extraDamage then
					calculation.extraDamage = 0
				end
			--Wound Poison
			elseif buffO == wound then
				local _, spd = self:GetWeaponSpeed()
				calculation.extra_O = self:ScaleData(0.245,0,calculation.playerLevel,0)
				calculation.extraDamage_O = 0.04
				calculation.extraChance_O = 0.5/1.4 * spd * hit
				calculation.extraName = calculation.extraName and (calculation.extraName .. "+" .. wpicon) or wpicon
				if not calculation.extraDamage then
					calculation.extraDamage = 0
				end
			elseif baseSpell.AutoAttack and deadly[buffO] then
				calculation.extra_DPS = 4 * math_ceil(self:ScaleData(0.12, 0,calculation.playerLevel,0))
				calculation.extraDamage_DPS = 4 * 0.035
				calculation.extraDuration_DPS = 12
				calculation.extraStacks_DPS = 5
				calculation.extraName_DPS = "5x" .. dpicon
			end
		end
	end
--TALENTS
	self.Calculation["Relentless Strikes"] = function( calculation, value )
		calculation.actionCost = calculation.actionCost - value * calculation.Melee_ComboPoints * 25
	end
--ABILITIES
	self.Calculation["Shiv"] = function( calculation, _, Talents )
		calculation.extraChance_O = 0.01 * math_max(0,math_min(100, self:GetSpellHit(calculation.playerLevel,calculation.targetLevel) + calculation.spellHit))
		calculation.E_canCrit = false
		if Talents["Combat Potency"] then
			calculation.actionCost = calculation.actionCost - Talents["Combat Potency"] * 0.2 * (calculation.hitO / 100)
		end
	end
	self.Calculation["Envenom"] = function( calculation, ActiveAuras )
		if ActiveAuras["Deadly Poison"] then
			calculation.Melee_ComboPoints = math_min(ActiveAuras["Deadly Poison"], calculation.Melee_ComboPoints)
		else
			calculation.Melee_ComboPoints = 0
			calculation.zero = true
		end
	end
	self.Calculation["Mutilate"] = function( calculation, ActiveAuras, Talents )
		if TargetIsPoisoned or ActiveAuras["Deadly Poison"] then
			--Multiplicative - 3.3.3
			calculation.dmgM = calculation.dmgM * 1.2
		end
		if self:GetSetAmount("T9") >= 4 then
			calculation.critPerc = calculation.critPerc + 5
		end
		if self:GetSetAmount("T11") >= 2 then
			calculation.critPerc = calculation.critPerc + 5
		end
		if Talents["Combat Potency"] then
			calculation.actionCost = calculation.actionCost - Talents["Combat Potency"] * 0.2 * (calculation.hitO / 100)
		end
	end
	self.Calculation["Killing Spree"] = function( calculation, ActiveAuras )
		if not ActiveAuras["Killing Spree"] then
			--Glyph of Killing Spree (4.0)
			calculation.dmgM = calculation.dmgM * (1.2 + (self:HasGlyph(63252) and 0.1 or 0))
		end
	end
	self.Calculation["Eviscerate"] = function( calculation )
		--Glyph of Eviscerate (4.0)
		if self:HasGlyph(56802) then
			calculation.critPerc = calculation.critPerc + 10
		end
	end
	self.Calculation["Rupture"] = function( calculation, ActiveAuras, Talents )
		--Glyph of Rupture (4.0)
		if self:HasGlyph(56801) then
			calculation.eDuration = calculation.eDuration + 4
		end
		if self:GetSetAmount("T7") >= 2 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
		if self:GetSetAmount("T8") >= 4 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.2
		end
		if Talents["Venomous Wounds"] and (ActiveAuras["Deadly Poison"] or ActiveAuras["Poison"]) then
			if not calculation.extraDamage then
				calculation.extraDamage = 0
			end
			--TODO: Add hits and crits?
			calculation.extraTickDamage = self:ScaleData(0.6, nil, calculation.playerLevel)
			calculation.extraTickDamageBonus = 0.176
			calculation.extraTickDamageChance = Talents["Venomous Wounds"]
			calculation.extraTickDamageCost = 10
			calculation.extraName = calculation.extraName and (calculation.extraName .. "+" .. vwicon) or vwicon
		end
	end
	self.Calculation["Garrote"] = function( calculation, ActiveAuras, Talents )
		if Talents["Venomous Wounds"] and (ActiveAuras["Deadly Poison"] or ActiveAuras["Poison"]) then
			if not calculation.extraDamage then
				calculation.extraDamage = 0
			end
			--TODO: Add hits and crits?
			calculation.extraTickDamage = self:ScaleData(0.6, nil, calculation.playerLevel)
			calculation.extraTickDamageBonus = 0.176
			calculation.extraTickDamageChance = Talents["Venomous Wounds"]
			calculation.extraTickDamageCost = 10
			calculation.extraName = calculation.extraName and (calculation.extraName .. "+" .. vwicon) or vwicon
		end
	end
	self.Calculation["Hemorrhage"] = function( calculation )
		if self:GetSetAmount("T9") >= 4 then
			calculation.critPerc = calculation.critPerc + 5
		end
		if self:GetNormM() == 1.7 then
			calculation.WeaponDamage = calculation.WeaponDamage * 1.45
		end
		--Glyph of Hemorrhage (4.0)
		--Your Hemorrhage ability also causes the target to bleed, dealing 40% of the direct strike's damage over 24 sec.
		if self:HasGlyph(56807) then
			if not calculation.extraDamage then
				calculation.extraDamage = 0
			end
			calculation.extraAvg = 0.4 * calculation.bleedBonus
			calculation.extraAvgM = 1
			calculation.extraAvgChance = 1
			calculation.extraName = calculation.extraName and (calculation.extraName .. "+" .. hmicon) or hmicon
			--Duration 24, ticks every 3 seconds
			calculation.extraTicks = 8
		end
	end
	self.Calculation["Sinister Strike"] = function( calculation )
		if self:GetSetAmount("T9") >= 4 then
			calculation.critPerc = calculation.critPerc + 5
		end
		if self:GetSetAmount("T11") >= 2 then
			calculation.critPerc = calculation.critPerc + 5
		end
	end
	self.Calculation["Backstab"] = function( calculation, _, Talents )
		if self:GetSetAmount("T9") >= 4 then
			calculation.critPerc = calculation.critPerc + 5
		end
		if self:GetSetAmount("T11") >= 2 then
			calculation.critPerc = calculation.critPerc + 5
		end
		--Glyph of Backstab (4.0)
		if self:HasGlyph(56800) then
			calculation.actionCost = calculation.actionCost - 5 * (calculation.critPerc / 100)
		end
		if Talents["Murderous Intent"] and UnitHealth("target") ~= 0 and (UnitHealth("target") / UnitHealthMax("target")) < 0.35 then
			calculation.actionCost = calculation.actionCost - Talents["Murderous Intent"]
		end
	end
	self.Calculation["Ambush"] = function( calculation )
		if self:GetNormM() == 1.7 then
			calculation.WeaponDamage = calculation.WeaponDamage * 2.75/1.9
			calculation.minDam = calculation.minDam * 2.75/1.9
			calculation.maxDam = calculation.maxDam * 2.75/1.9
		end
	end
--SETS
	self.SetBonuses["T7"] = { 40495, 40496, 40499, 40500, 40502, 39558, 39560, 39561, 39564, 39565 }
	self.SetBonuses["T8"] = { 46123, 46124, 46125, 46126, 46127, 45396, 45397, 45398, 45399, 45400 }
	self.SetBonuses["T9"] = { 48243, 48244, 48245, 48246, 48247, 48218, 48219, 48220, 48221, 48222, 48223, 48224, 48225, 48226, 48227, 48232, 48231, 48230, 48229, 48228, 48242, 48241, 48240, 48239, 48238, 48233, 48234, 48235, 48236, 48237 }
	--self.SetBonuses["T10"] = { 50150, 50090, 50089, 50088, 50087, 51185, 51254, 51186, 51253, 51187, 51252, 51188, 51251, 51189, 51250 }
	self.SetBonuses["T11"] = { 60298, 60299, 60300, 60301, 60302, 65239, 65240, 65241, 65242, 65243 }
	--AURA
--Player
	--Killing Spree (TODO: Verify API handles it properly)
	self.PlayerAura[GetSpellInfo(51690)] = { ActiveAura = "Killing Spree", ID = 51690, ModType =
		function( calculation, _, _, index )
			if not index then
				--Glyph of Killing Spree (4.0)
				calculation.dmgM = calculation.dmgM * (1.2 + (self:HasGlyph(63252) and 0.1 or 0))
			end
		end
	}
	--Shadowstep (4.0)
	self.PlayerAura[GetSpellInfo(36554)] = { ActiveAura = "Shadowstep", Value = 0.3, ID = 36554, Spells = { "Ambush", "Garrote" } }
	--Envenom (4.0)
	self.PlayerAura[GetSpellInfo(32645)] = { ActiveAura = "Envenom", ID = 32645 }
	--Blade Flurry (4.0)
	self.PlayerAura[GetSpellInfo(13877)] = { ActiveAura = "Blade Flurry", ID = 13877, }
	--Slice and Dice (4.0)
	self.PlayerAura[GetSpellInfo(5171)] = { ID = 5171, Mods = { ["haste"] = function(v) return v * 1.4 end } }
	--Cold Blood (4.0)
	self.PlayerAura[GetSpellInfo(14177)] = { Value = 100, ModType = "critPerc", ID = 14177, Not = { "Attack", "Rupture", "Garrote", "Gouge", "Shiv" } }
	--Shallow Insight
	self.PlayerAura[GetSpellInfo(84745)] = { SelfCast = true, ID = 84745, Category = "Bandit's Guile", Value = 0.1 }
	--Moderate Insight
	self.PlayerAura[GetSpellInfo(84746)] = { SelfCast = true, ID = 84746, Category = "Bandit's Guile", Value = 0.2 }
	--Deep Insight
	self.PlayerAura[GetSpellInfo(84747)] = { SelfCast = true, ID = 84747, Category = "Bandit's Guile", Value = 0.3 }
	--Deadly Scheme (4p T11 proc)
	self.PlayerAura[GetSpellInfo(90472)] = { Spells = { "Eviscerate", "Envenom" }, Value = 100, ModType = "critPerc", NoManual = true }

--Target
	--Deadly Poison (4.0)
	self.TargetAura[GetSpellInfo(2818)] = { ActiveAura = "Deadly Poison", Spells = { "Envenom", "Mutilate", "Rupture", "Garrote" }, SelfCast = true, Apps = 5, ID = 2818 }
	--Wound Poison (4.0)
	self.TargetAura[GetSpellInfo(43461)] = { ActiveAura = "Poison", Spells = { "Mutilate", "Rupture", "Garrote" }, SelfCast = true, ID = 43461 }
	--Crippling Poison (4.0)
	self.TargetAura[GetSpellInfo(30981)] = { ActiveAura = "Poison", Spells = { "Mutilate", "Rupture", "Garrote" }, SelfCast = true, ID = 30981 }
	--Mind-numbing Poison (4.0)
	self.TargetAura[GetSpellInfo(25810)] = { ActiveAura = "Poison", Spells = { "Mutilate", "Rupture", "Garrote" }, SelfCast = true, ID = 25810 }
	--Vendetta (4.0)
	self.TargetAura[GetSpellInfo(79140)] = { SelfCast = true, ID = 79140, Value = 0.2 }
	--Revealing Strike (4.0, TODO: Verify spells)
	self.TargetAura[GetSpellInfo(84617)] = { SelfCast = true, ID = 84617, Spells = { "Eviscerate", "Rupture", "Deadly Throw", "Envenom" }, ModType =
		function(calculation )
			--Glyph of Revealing Strike (4.0)
			calculation.dmgM = calculation.dmgM * (1.35 + (self:HasGlyph(56814) and 0.1 or 0))
		end
	}
	--Find Weakness (4.0)
	self.TargetAura[GetSpellInfo(91023)] = { Ranks = 2, Value = 0.35, ModType = "armorM", ID = 91023 }
--Bleed effects (TODO: Verify this contains all important ones)
	--Deep Wound - 4.0
	self.TargetAura[GetSpellInfo(43104)] = 	{ ActiveAura = "Bleeding", Manual = "Bleeding", ID = 59881 }
	--Pounce - 4.0
	self.TargetAura[GetSpellInfo(9005)] = 	self.TargetAura[GetSpellInfo(43104)]
	--Rip - 4.0
	self.TargetAura[GetSpellInfo(1079)] = 	self.TargetAura[GetSpellInfo(43104)]
	--Rake - 4.0
	self.TargetAura[GetSpellInfo(59881)] = 	self.TargetAura[GetSpellInfo(43104)]
	--Lacerate - 4.0
	self.TargetAura[GetSpellInfo(33745)] = 	self.TargetAura[GetSpellInfo(43104)]
	--Rend - 4.0
	self.TargetAura[GetSpellInfo(94009)] = 	self.TargetAura[GetSpellInfo(43104)]
	--Garrote - 4.0
	self.TargetAura[GetSpellInfo(703)] = 	self.TargetAura[GetSpellInfo(43104)]
	--Rupture - 4.0
	self.TargetAura[GetSpellInfo(1943)] = 	self.TargetAura[GetSpellInfo(43104)]
	--Piercing Shots - 4.0
	self.TargetAura[GetSpellInfo(53234)] = 	self.TargetAura[GetSpellInfo(43104)]

	self.spellInfo = {
		[GetSpellInfo(1752)] = {
			["Name"] = "Sinister Strike",
			["ID"] = 1752,
			["Data"] = { 0.178, ["weaponDamage"] = 0.42, ["PPL_start"] = 1, ["PPL"] = 0.735 },
			[0] = { },
			[1] = { 0 },
		},
		[GetSpellInfo(53)] = {
			["Name"] = "Backstab",
			["ID"] = 53,
			["Data"] = { 0.307, ["weaponDamage"] = 1.09, ["PPL_start"] = 18, ["PPL"] = 1.468 },
			[0] = { Weapon = GetSpellInfo(1180) }, --Daggers
			[1] = { 0 },
		},
		[GetSpellInfo(2098)] = {
			["Name"] = "Eviscerate",
			["ID"] = 2098,
			["Data"] = { 0.326, 1, ["c_scale"] = 0.414, ["perCombo"] = 0.476 },
			[0] = { ComboPoints = true, APBonus = 0.091, Finisher = true },
			[1] = { 0, 0, PerCombo = 0 },
		},
		[GetSpellInfo(8676)] = {
			["Name"] = "Ambush",
			["ID"] = 8676,
			["Data"] = { 0.327, ["weaponDamage"] = 0.9, ["PPL_start"] = 8, ["PPL"] = 1.39 },
			[0] = { Unavoidable = true },
			[1] = { 0 },
		},
		[GetSpellInfo(1776)] = {
			["Name"] = "Gouge",
			["ID"] = 1776,
			["Data"] = { 0.104 },
			[0] = { APBonus = 0.21, NoPoison = true, Cooldown = 10 },
			[1] = { 0 },
		},
		[GetSpellInfo(703)] = {
			["Name"] = "Garrote",
			["ID"] = 703,
			["Data"] = { 0.118 },
			[0] = { Hits = 6, APBonus = 0.07, eDot = true, eDuration = 18, Ticks = 3, NoWeapon = true, Bleed = true, Unavoidable = true },
			[1] = { 0 },
		},
		[GetSpellInfo(1943)] = {
			["Name"] = "Rupture",
			["ID"] = 1943,
			["Data"] = { 0.126, ["perCombo"] = 0.018 },
			[0] = { ComboPoints = true, APBonus = 0.06, DotHits = 4, eDuration = 8, Ticks = 2, TicksPerCombo = 1, Bleed = true, Finisher = true },
			[1] = { 0, PerCombo = 0, },
		},
		[GetSpellInfo(16511)] = {
			["Name"] = "Hemorrhage",
			["ID"] = 16511,
			["Data"] = { 0, ["weaponDamage"] = 0.69, ["PPL_start"] = 29, ["PPL"] = 0.804 },
			[0] = { },
			[1] = { 0 },
		},
		[GetSpellInfo(5938)] = {
			["Name"] = "Shiv",
			["ID"] = 5938,
			[0] = { WeaponDamage = 1, OffhandAttack = true, NoCrits = true, Unavoidable = true },
			[1] = { 0 },
		},
		[GetSpellInfo(32645)] = {
			["Name"] = "Envenom",
			["ID"] = 32645,
			["Data"] = { 0, ["perCombo"] = 0.214 },
			[0] = { School = "Nature", ComboPoints = true, APBonus = 0.09, Finisher = true },
			[1] = { 0, PerCombo = 0 },
		},
		[GetSpellInfo(26679)] = {
			["Name"] = "Deadly Throw",
			["ID"] = 26679,
			["Data"] = { 0.143, 0.25, ["perCombo"] = 0.222 },
			[0] = { School = { "Physical", "Ranged" }, ComboPoints = true, WeaponDamage = 1, NoPoison = true, NoNormalization = true, Finisher = true },
			[1] = { 0, 0, PerCombo = 0 },
		},
		[GetSpellInfo(1329)] = {
			["Name"] = "Mutilate",
			["ID"] = 1329,
			["Data"] = { 0.179, ["weaponDamage"] = 0.63, ["PPL_start"] = 1, ["PPL"] = 1.102 },
			[0] = { DualAttack = true, Weapon = GetSpellInfo(1180) }, --Daggers
			[1] = { 0 },
		},
		[GetSpellInfo(51723)] = {
			["Name"] = "Fan of Knives",
			["ID"] = 51723,
			[0] = { School = { "Physical", "Ranged" }, WeaponDamage = 0.8, --[[DualAttack = true,--]] AoE = true, NoNormalization = true },
			[1] = { 0 },
		},
		[GetSpellInfo(51690)] = {
			["Name"] = "Killing Spree",
			["ID"] = 51690,
			[0] = { WeaponDamage = 1, DualAttack = true, Hits = 5 },
			[1] = { 0 },
		},
		[GetSpellInfo(84617)] = {
			["Name"] = "Revealing Strike",
			["ID"] = 84617,
			["Data"] = { 0, ["weaponDamage"] = 0.81, ["PPL_start"] = 29, ["PPL"] = 0.863 },
			[0] = { NoNormalization = true, },
			[1] = { 0 },
		},
	}
	self.talentInfo = {
	--ASSASSINATION:
		--Coup de Grace (additive - 3.3.3)
		[GetSpellInfo(14162)] = {	[1] = { Effect = { 0.07, 0.14, 0.20 } , Spells = { "Eviscerate", "Envenom" }, }, },
		--Lethality
		[GetSpellInfo(14128)] = {	[1] = { Effect = 0.1, Spells = { "Sinister Strike", "Backstab", "Mutilate", "Hemorrhage" }, ModType = "critM" }, },
		--Puncturing Wounds
		[GetSpellInfo(13733)] = {	[1] = { Effect = 10, Spells = "Backstab", ModType = "critPerc" },
									[2] = { Effect = 5, Spells = "Mutilate", ModType = "critPerc" }, },
		--Vile Poisons (additive - 3.3.3)
		[GetSpellInfo(16513)] = {	[1] = { Effect = { 0.07, 0.14, 0.20 }, Spells = "All", ModType = "Vile Poisons" },
									[2] = { Effect = { 0.33, 0.66, 1 }, Spells = "Fan of Knives", ModType = "Poison Chance" }, },
		--Murderous Intent
		[GetSpellInfo(14518)] = {	[1] = { Effect = 15, Spells = "Backstab", ModType = "Murderous Intent" }, },
		--Venomous Wounds
		[GetSpellInfo(79133)] = {	[1] = { Effect = 0.3, Spells = { "Rupture", "Garrote" }, ModType = "Venomous Wounds" }, },
	--COMBAT:
		--Improved Sinister Strike (additive?)
		[GetSpellInfo(13732)] = {	[1] = { Effect = 0.1, Spells = "Sinister Strike", }, },
		--Aggression (additive - 3.3.3)
		[GetSpellInfo(18427)] = {	[1] = { Effect = { 0.07, 0.14, 0.20 }, Spells = { "Sinister Strike", "Eviscerate", "Backstab" } }, },
		--Combat Potency
		[GetSpellInfo(35551)] = {	[1] = { Effect = 5, Spells = { "Shiv", "Mutilate", }, ModType = "Combat Potency" }, },
		--Savage Combat
		[GetSpellInfo(51682)] = {	[1] = { Effect = 0.02, Spells = "All", Multiply = true, ModType = "APM" }, NoManual = true },
	--SUBTLETY:
		--Improved Ambush (additive?)
		[GetSpellInfo(14079)] = {	[1] = { Effect = 20, Spells = "Ambush", ModType = "critPerc" },
									[2] = { Effect = 0.05, Spells = "Ambush" }, },
		--Relentless Strikes
		[GetSpellInfo(14179)] = {	[1] = { Effect = { 0.07, 0.14, 0.20 }, Spells = { "Eviscerate", "Deadly Throw", "Envenom", "Rupture" }, ModType = "Relentless Strikes", }, },
		--Opportunity (additive - 3.3.3)
		[GetSpellInfo(14057)] = {	[1] = { Effect = 0.1, Spells = { "Backstab", "Mutilate", "Garrote", "Ambush" } }, },
		--Sanguinary Vein (multiplicative?)
		[GetSpellInfo(79146)] = {	[1] = { Effect = 0.05, Spells = "All", ModType = "Sanguinary Vein" }, },
	}
end