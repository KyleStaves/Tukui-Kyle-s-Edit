if select(2, UnitClass("player")) ~= "HUNTER" then return end
local GetSpellInfo = DrDamage.SafeGetSpellInfo
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitCreatureType = UnitCreatureType
local UnitRangedDamage = UnitRangedDamage
local GetTrackingTexture = GetTrackingTexture
local GetInventoryItemLink = GetInventoryItemLink
local IsEquippedItem = IsEquippedItem
local tonumber = tonumber
local string_match = string.match
local string_find = string.find
local string_lower = string.lower
local select = select
local math_min = math.min
local math_max = math.max
local IsSpellKnown = IsSpellKnown

function DrDamage:PlayerData()
--GENERAL
	self.Calculation["Stats"] = function( calculation, ActiveAuras, Talents, spell, baseSpell )
		local mastery = calculation.mastery
		local masteryLast = calculation.masteryLast
		local spec = calculation.spec
		if spec == 2 then
			if mastery > 0 and mastery ~= masteryLast then
				if calculation.group == "Ranged" and calculation.subType ~= "Trap" then
					--Mastery: Wild Quiver
					calculation.extraWeaponDamageChance = mastery * 0.01 * 2.1
					calculation.masteryLast = mastery
				end
			end
		elseif spec == 3 then
			if mastery > 0 and mastery ~= masteryLast then
				if calculation.school ~= "Physical" then
					local masteryBonus = calculation.masteryBonus
					if masteryBonus then
						calculation.dmgM = calculation.dmgM / masteryBonus
					end
					--Mastery: Essence of the Viper - Increases all elemental damage you deal
					local bonus = 1 + mastery * 0.01
					calculation.dmgM = calculation.dmgM * bonus
					calculation.masteryLast = mastery
					calculation.masteryBonus = bonus
				end
			end
		end
	end
	local piercingshots = "|T" .. select(3,GetSpellInfo(53234)) .. ":16:16:1:-1|t"
	local wildquiver = "|T" .. select(3,GetSpellInfo(76659)) .. ":16:16:1:-1|t"
	self.Calculation["HUNTER"] = function( calculation, ActiveAuras, Talents, spell, baseSpell )
		--TODO: Check specialization is active
		if IsSpellKnown(86528) then
			calculation.agiM = calculation.agiM * 1.05
		end
		--Specialization
		local spec = calculation.spec
		if spec == 1 then
			--Animal Handler: Attack Power increased by 25%.
			calculation.APM = calculation.APM * 1.25
		elseif spec == 2 then
			if baseSpell.AutoShot then
				calculation.dmgM = calculation.dmgM * 1.15
			end
			if calculation.mastery > 0 then
				if calculation.group == "Ranged" and calculation.subType ~= "Trap" then
					calculation.extraDamage = 0
					calculation.extraWeaponDamage = 1
					calculation.extra_canCrit = true
					calculation.extraName = wildquiver
				end
			end
		elseif spec == 3 then
			--Into the Wilderness: Increases your total Agility by 10%
			calculation.agiM = calculation.agiM * 1.1
		end
		if Talents["Rapid Killing"] and ActiveAuras["Rapid Killing"] then --Additive - 3.3.3
			calculation.dmgM_Add = calculation.dmgM_Add + Talents["Rapid Killing"]
		end
		if Talents["Careful Aim"] and UnitHealth("target") ~= 0 and ((UnitHealth("target") / UnitHealthMax("target")) > 0.8) then
			calculation.critPerc = calculation.critPerc + Talents["Careful Aim"]
		end
		if ActiveAuras["Serpent Sting"] and Talents["Noxious Stings"] then --Multiplicative - 3.3.3
			calculation.dmgM = calculation.dmgM * (1 + Talents["Noxious Stings"])
		end
		if ActiveAuras["Frozen"] and Talents["Point of No Escape"] then
			calculation.critPerc = calculation.critPerc + Talents["Point of No Escape"]
		end
		if Talents["Piercing Shots"] then
			--TODO: Fix crits in conjunction with wild quiver
			calculation.extraDamage = 0
			calculation.extraCrit = Talents["Piercing Shots"]
			calculation.extraChanceCrit = true
			if calculation.extraName then
				calculation.extraName = calculation.extraName .. "+" .. piercingshots
			else
				calculation.extraTicks = 8
				calculation.extraName = piercingshots
			end
		end
	end
--ABILITIES
	self.Calculation["Steady Shot"] = function( calculation, ActiveAuras )
		--Glyph of Steady Shot - 4.0 - additive?
		if self:HasGlyph(56826) then
			--CHECK
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
	end
	local serpent_sting = GetSpellInfo(1978)
	--local serpent_sting_icon = "|T" .. select(3,GetSpellInfo(1978)) .. ":16:16:1:-1|t"
	--local improved_serpent_sting = GetSpellInfo(82834)
	local improved_serpent_sting_icon = "|T" .. select(3,GetSpellInfo(82834)) .. ":16:16:1:-1|t"
	self.Calculation["Multi-Shot"] = function( calculation, _, Talents )
		--Gladiator's Chain Gauntlets
		--if IsEquippedItem( 28335 ) or IsEquippedItem( 31961 ) or IsEquippedItem( 33665 ) then
		--	calculation.cooldown = calculation.cooldown - 1
		--end
		if Talents["Serpent Spread"] then
			local hits = Talents["Serpent Spread"] / 3
			local iss = (Talents["Improved Serpent Sting"] or 0) * self.spellInfo[serpent_sting][0].Hits
			local bonus = 1 + (self:GetSetAmount("T8") >= 2 and 0.1 or 0) + (self:GetSetAmount("T9") >= 2 and 0.1 or 0)
			calculation.extra = bonus * (hits + iss) * self.spellInfo[serpent_sting][1][2]
			calculation.extraDamage = bonus * (hits + iss) * self.spellInfo[serpent_sting][0].APBonus
			calculation.extraName = serpent_sting
		end
	end
	self.Calculation["Serpent Sting"] = function ( calculation, _, Talents )
		--Glyph of Serpent Sting - 4.0
		if self:HasGlyph(56832) then
			calculation.critPerc = calculation.critPerc + 6
		end
		if self:GetSetAmount("T8") >= 2 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
		if self:GetSetAmount("T9") >= 2 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
		if self:GetSetAmount("T11") >= 2 then
			calculation.critPerc = calculation.critPerc + 5
		end
		if Talents["Improved Serpent Sting"] then
			calculation.extra = Talents["Improved Serpent Sting"] * calculation.hits * calculation.maxDam
			calculation.extraDamage = Talents["Improved Serpent Sting"] * calculation.hits * calculation.APBonus
			calculation.extra_canCrit = true
			if calculation.extraName then
				calculation.extraName = calculation.extraName .. "+" .. improved_serpent_sting_icon
			else
				calculation.extraName = improved_serpent_sting_icon
			end
		end
	end
	self.Calculation["Arcane Shot"] = function ( calculation )
		--Glyph of Arcane Shot - 4.0
		if self:HasGlyph(56841) then
			--CHECK
			calculation.dmgM_Add = calculation.dmgM_Add + 0.12
		end
	end
	self.Calculation["Chimera Shot"] = function ( calculation, ActiveAuras, Talents )
		--Glyph of Chimera Shot - 4.0
		if self:HasGlyph(63065) then
			calculation.cooldown = calculation.cooldown - 1
		end
	end
	self.Calculation["Explosive Shot"] = function ( calculation )
		--Glyph of Explosive Shot - 4.0
		if self:HasGlyph(63066) then
			calculation.critPerc = calculation.critPerc + 6
		end
	end
	self.Calculation["Explosive Trap"] = function ( calculation, ActiveAuras, Talents, spell )
		--NOTE: 3.3.3 - Direct damage part does not benefit from +dmg% (tested Ferocious Inspiration, Aspect of the Viper, Improved Tracking). Benefits from Noxious Stings.
		calculation.dmgM_Extra = calculation.dmgM * select(6,UnitRangedDamage("player"))
	end
	self.Calculation["Immolation Trap"] = function ( calculation, ActiveAuras, Talents )
		--Glyph of Immolation Trap - 4.0
		if self:HasGlyph(56846) then
			--CHECK
			calculation.eDuration = calculation.eDuration - 6
			calculation.hits = 3
			calculation.APBonus = calculation.APBonus * 2
			calculation.minDam = calculation.minDam * 2
			calculation.maxDam = calculation.maxDam * 2
		end
		--NOTE: 3.3.3 - Does not benefit from +dmg% (tested Ferocious Inspiration, Aspect of the Viper, Improved Tracking). Benefits from Noxious Stings.
	end
	self.Calculation["Wyvern Sting"] = function ( calculation )
		--Glyph of Wyvern Sting - 4.0
		if self:HasGlyph(56848) then
			calculation.cooldown = calculation.cooldown - 6
		end
	end
	--self.Calculation["Aimed Shot"] = function( calculation, ActiveAuras, Talents )
	--end
	--self.Calculation["Black Arrow"] = function ( calculation )
	--end
	--self.Calculation["Kill Shot"] = function ( calculation )
	--end
--SETS
	self.SetBonuses["T8"] = { 45360, 45361, 45362, 45363, 45364, 46141, 46142, 46143, 46144, 46145 }
	self.SetBonuses["T9"] = { 48250, 48251, 48252, 48253, 48254, 48275, 48276, 48277, 48278, 48279, 48273, 48272, 48271, 48270, 48274, 48266, 48267, 48268, 48269, 48265, 48256, 48257, 48258, 48259, 48255, 48263, 48262, 48261, 48260, 48264 }
	self.SetBonuses["T11"] = { 60303, 60304, 60305, 60306, 60307, 65204, 65205, 65206, 65207, 65208 }
--AURA
--Player
	--Rapid Killing - 4.0
	self.PlayerAura[GetSpellInfo(35098)] = { ActiveAura = "Rapid Killing", ID = 35098 }
	--Sniper Training - 4.0
	self.PlayerAura[GetSpellInfo(53302)] = { Spells = { "Steady Shot", "Cobra Shot" }, ModType = "dmgM_Add", Value = 0.02, Ranks = 3, ID = 53302 }
--Target
	--Freezing Trap - 4.0
	self.TargetAura[GetSpellInfo(3355)] = { ActiveAura = "Frozen", ID = 3355, Manual = GetSpellInfo(3355) }
	--Ice Trap - 4.0
	self.TargetAura[GetSpellInfo(13810)] = self.TargetAura[GetSpellInfo(3355)]
	--Serpent Sting - 4.0
	self.TargetAura[GetSpellInfo(1978)] = { ActiveAura = "Serpent Sting", ID = 1978 }
--Custom
	--Hunter's Mark - 4.0
	self.TargetAura[GetSpellInfo(1130)] = { School = "Ranged", ID = 1130, ModType =
		function( calculation )
			calculation.AP = calculation.AP + self:ScaleData(4, nil, nil, nil, true)
		end
	}

	self.spellInfo = {
		[GetSpellInfo(75)] = {
			["Name"] = "Auto Shot",
			["ID"] = 75,
			[0] = { School = { "Physical", "Ranged", "Shot" }, WeaponDamage = 1, NoNormalization = true, AutoShot = true, DPSrg = true },
			[1] = { 0 },
		},
		[GetSpellInfo(3044)] = {
			["Name"] = "Arcane Shot",
			["ID"] = 3044,
			["Data"] = { 0.2576, ["weaponDamage"] = 0.61, ["PPL_start"] = 1, ["PPL"] = 0.494 },
			[0] = { School = { "Arcane", "Ranged", "Shot" }, APBonus = 0.0483 },
			[1] = { 0 },
		},
		[GetSpellInfo(19434)] = {
			["Name"] = "Aimed Shot",
			["ID"] = 19434,
			["Data"] = { 0.73, 0.11, ["weaponDamage"] = 1.25, ["PPL_start"] = 10, ["PPL"] = 0.5 },
			[0] = { School = { "Physical", "Ranged", "Shot" }, APBonus = 0.724, BleedExtra = true, },
			[1] = { 0 },
		},
		[GetSpellInfo(82928)] = {
			["Name"] = "Aimed Shot!",
			["ID"] = 82928,
			--HOTFIX: Aimed Shot damage has been decreased to approximately 160% weapon damage (at level 80+), down from 200%.
			["Data"] = { 0.73, 0.11, ["weaponDamage"] = 1.25, ["PPL_start"] = 10, ["PPL"] = 0.5 },
			[0] = { School = { "Physical", "Ranged", "Shot" }, APBonus = 0.724, BleedExtra = true, },
			[1] = { 0 },
		},		
		[GetSpellInfo(2643)] = {
			["Name"] = "Multi-Shot",
			["ID"] = 2643,
			["Data"] = { 0, ["weaponDamage"] = 0.4, ["PPL_start"] = 24, ["PPL"] = 0.268 },
			[0] = { School = { "Physical", "Ranged", "Shot" }, AoE = true },
			[1] = { 0 },
		},
		[GetSpellInfo(19503)] = {
			["Name"] = "Scatter Shot",
			["ID"] = 19503,
			[0] = { School = { "Physical", "Ranged", "Shot" }, WeaponDamage = 0.5, Cooldown = 30, NoNormalization = true },
			[1] = { 0 },
		},
		[GetSpellInfo(56641)] = {
			["Name"] = "Steady Shot",
			["ID"] = 56641,
			["Data"] = { 0.249, ["weaponDamage"] = 0.62, ["PPL_start"] = 3, ["PPL"] = 0.494 },
			[0] = { School = { "Physical", "Ranged", "Shot" }, APBonus = 0.021, BleedExtra = true },
			[1] = { 0 },
		},
		[GetSpellInfo(53351)] = {
			["Name"] = "Kill Shot",
			["ID"] = 53351,
			--TODO 4.0.6: Tooltip says 50% base damage increase, patchnotes say 50% AP scaling increase
			["Data"] = { 0.483, ["weaponDamage"] = 1.16, ["PPL_start"] = 35, ["PPL"] = 0.756 },
			[0] = { School = { "Physical", "Ranged", "Shot" }, APBonus = 0.3, Cooldown = 10 },
			[1] = { 0 },
		},
		--TODO-MINOR: 5% self heal
		[GetSpellInfo(53209)] = {
			["Name"] = "Chimera Shot",
			["ID"] = 53209,
			["Data"] = { 1.44 },
			[0] = { School = { "Nature", "Ranged", "Shot" }, WeaponDamage = 1, APBonus = 0.732, Cooldown = 10, BleedExtra = true },
			[1] = { 0 },
		},
		[GetSpellInfo(13795)] = {
			["Name"] = "Immolation Trap",
			["ID"] = 13795,
			["Data"] = { 0.512 },
			[0] = { School = { "Fire", "Ranged", "Trap" }, Hits = 5, eDot = true, eDuration = 15, Ticks = 3, APBonus = 0.02, Cooldown = 30, SpellCritM = true, NoGlobalMod = true, Unresistable = true, NoWeapon = true },
			[1] = { 0 },
		},
		[GetSpellInfo(13813)] = {
			["Name"] = "Explosive Trap",
			["ID"] = 13813,
			["Data"] = { 0.198, 0.25, ["extra"] = 0.026 },
			--BUG?: Initial explosion doesn't seem to have an AP coefficient
			[0] = { School = { "Fire", "Ranged", "Trap" }, APBonus = 0--[[0.0546--]], Hits_extra = 10, APBonus_extra = 0.0546, E_eDuration = 20, E_Ticks = 2, E_canCrit = true, Cooldown = 30, AoE = true, E_AoE = true, SpellCritM = true, NoGlobalMod = true, Unresistable = true, NoWeapon = true, },
			[1] = { 0, 0, Extra = 0, },
		},
		--TODO: Verify if this crits, also check if this has a AP coefficient
		[GetSpellInfo(19386)] = {
			["Name"] = "Wyvern Sting",
			["ID"] = 19386,
			["Data"] = { 0.811 },
			[0] = { School = { "Nature", "Ranged" }, Hits = 3, eDot = true, eDuration = 6, sTicks = 2, Cooldown = 60 },
			[1] = { 0 },
		},
		[GetSpellInfo(1978)] = {
			["Name"] = "Serpent Sting",
			["ID"] = 1978,
			["Data"] = { 0.409 },
			[0] = { School = { "Nature", "Ranged" }, APBonus = 0.4 / 5, eDot = true, Hits = 5, eDuration = 15, Ticks = 3, SpellCritM = true, },
			[1] = { 0 },
		},
		[GetSpellInfo(2973)] = {
			["Name"] = "Raptor Strike",
			["ID"] = 2973,
			["Data"] = { 0.332 },
			[0] = { WeaponDamage = 1, Cooldown = 6 },
			[1] = { 0 },
		},
		[GetSpellInfo(19306)] = {
			["Name"] = "Counterattack",
			["ID"] = 19306,
			["Data"] = { 0.285 },
			[0] = { Cooldown = 5, APBonus = 0.2, NoWeapon = true, Unavoidable = true },
			[1] = { 0 },
		},
		[GetSpellInfo(3674)] = {
			["Name"] = "Black Arrow",
			["ID"] = 3674,
			["Data"] = { 0.362 },
			[0] = { School = { "Shadow", "Ranged" }, APBonus = 0.095, eDot = true, Hits = 5, eDuration = 15, Ticks = 3, Cooldown = 30, SpellCritM = true, },
			[1] = { 0 },
		},
		[GetSpellInfo(53301)] = {
			["Name"] = "Explosive Shot",
			["ID"] = 53301,
			["Data"] = { 0.314, 0.187 },
			[0] = { School = { "Fire", "Ranged", "Shot" }, APBonus = 0.232, Cooldown = 6, Hits = 3, NoHits = true },
			[1] = { 0 },
		},
		[GetSpellInfo(77767)] = {
			["Name"] = "Cobra Shot",
			["ID"] = 77767,
			["Data"] = { 0.246 },
			[0] = { School = { "Nature", "Ranged", "Shot" }, WeaponDamage = 1, APBonus = 0.017 },
			[1] = { 0 },
		},
	}
	self.talentInfo = {
	--BEAST MASTERY:

	--MARKMANSHIP:
		--Rapid Killing (additive - 3.3.3)
		[GetSpellInfo(34948)] = {	[1] = { Effect = 0.1, Spells = { "Aimed Shot", "Aimed Shot!", "Steady Shot", "Cobra Shot" }, ModType = "Rapid Killing" }, },
		--Careful Aim
		[GetSpellInfo(34482)] = {	[1] = { Effect = 30, Spells = { "Aimed Shot", "Aimed Shot!", "Steady Shot", "Cobra Shot" }, ModType = "Careful Aim" }, },
		--Piercing Shots
		[GetSpellInfo(53234)] = {	[1] = { Effect = 0.1, Spells = { "Aimed Shot", "Aimed Shot!", "Steady Shot", "Chimera Shot" }, ModType = "Piercing Shots" }, },

	--SURVIVAL:
		--Improved Serpent Sting
		[GetSpellInfo(19464)] = {	[1] = { Effect = 0.15, Spells = { "Serpent Sting", "Multi-Shot" }, ModType = "Improved Serpent Sting" },
									[2] = { Effect = 5, Spells = "Serpent Sting", ModType = "critPerc" }, },
		--Trap Mastery (additive - 3.3.3)
		[GetSpellInfo(19376)] = {	[1] = { Effect = 0.1, Spells = { "Immolation Trap", "Black Arrow" }, },
									[2] = { Effect = 0.1, Spells = "Explosive Trap", ModType = "dmgM_Extra_Add" }, },
		--Point of No Escape
		[GetSpellInfo(53298)] = {	[1] = { Effect = 3, Spells = "All", ModType = "Point of No Escape" }, },
		--Thrill of the Hunt
		[GetSpellInfo(34497)] = { 	[1] = { Effect = { 0.05 * 0.4, 0.10 * 0.4, 0.15 * 0.4 }, Spells = { "Arcane Shot", "Explosive Shot", "Black Arrow" }, ModType = "freeCrit" }, },
		--Resourcefulness
		[GetSpellInfo(34491)] = {	[1] = { Effect = -2, Spells = { "Explosive Trap", "Immolation Trap", "Black Arrow" }, ModType = "cooldown" }, },
		--Toxicology
		[GetSpellInfo(82832)] = {	[1] = { Effect = 0.25, Spells = { "Serpent Sting", "Black Arrow" }, ModType = "critM" }, },
		--Noxious Stings (multiplicative - 3.3.3)
		[GetSpellInfo(53295)] = { 	[1] = { Effect = 0.05, Spells = "All", ModType = "Noxious Stings" }, },
		--Hunting Party
		[GetSpellInfo(53290)] = { 	[1] = { Effect = 0.02, Spells = "All", ModType = "Hunting Party", Multiply = true, ModType = "agiM" }, },
		--Sniper Training (Kill Shot bonus only, rest handled elsewhere)
		[GetSpellInfo(53302)] = {	[1] = { Effect = 5, Spells = "Kill Shot", ModType = "critPerc" }, },
		--Serpent Spread
		[GetSpellInfo(87934)] = { 	[1] = { Effect = { 6, 9 }, Spells = "Multi-Shot", ModType = "Serpent Spread" }, },
	}
end
