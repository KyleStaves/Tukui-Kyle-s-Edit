local DrDamage = DrDamage
local GetSpellInfo = GetSpellInfo
local UnitStat = UnitStat
DrDamage.PlayerAura = {}
DrDamage.TargetAura = {}
DrDamage.Consumables = {}
DrDamage.Calculation = {}

function DrDamage.SafeGetSpellInfo(...)
	local name, rank, icon, cost, isFunnel, powerType, castTime = GetSpellInfo(...)
	--[===[@debug@
	if not name then
		local id = ...
		DrDamage:Print("SpellID removed: " .. id)
	end
	--@end-debug@]===]
	return name or "", rank, icon or "", cost or 0, isFunnel, powerType, castTime
end

local function DrD_LoadAuras()
	local L = LibStub("AceLocale-3.0"):GetLocale("DrDamage", true)
	local playerClass = select(2,UnitClass("player"))
	local DK = (playerClass == "DEATHKNIGHT")
	local Hunter = (playerClass == "HUNTER")
	local Rogue = (playerClass == "ROGUE")
	local Mage = (playerClass == "MAGE")
	local Paladin = (playerClass == "PALADIN")
	local Warrior = (playerClass == "WARRIOR")
	local Priest = (playerClass == "PRIEST")
	local Warlock = (playerClass == "WARLOCK")
	local Druid = (playerClass == "DRUID")
	local Shaman = (playerClass == "SHAMAN")
	local playerHealer = Priest or Shaman or Paladin or Druid
	local playerCaster = Mage or Priest or Warlock
	local playerMelee = Rogue or Warrior or Hunter
	local playerHybrid = DK or Druid or Paladin or Shaman

	local Aura = DrDamage.PlayerAura
	local GetSpellInfo = DrDamage.SafeGetSpellInfo
	local horde = (UnitFactionGroup("player") == "Horde")
	local UnitBuff = UnitBuff
	local select = select

	--[[ NOTES:
	 	School = "Spells" means it applies to both heals and spells
	 	School = "Damage Spells" means it applies to all damaging spells
		School = "Healing" applies only to heals
		School = "Physical" applies only to abilities dealing physical damage, which is the default in melee module unless otherwise specified
		School = "All" applies to everything
		No school or spell applies to everything but healing
		Caster = true or Melee = true limits it to respective modules
	--]]

	if horde then
		--Bloodlust
		Aura[GetSpellInfo(2825)] = { School = "All", Category = "30% haste", ID = 2825, CustomHaste = true, Multiply = true, Mods = { ["haste"] = 0.3 } }
	else
		--Heroism
		Aura[GetSpellInfo(32182)] = { School = "All", Category = "30% haste", ID = 32182, CustomHaste = true, Multiply = true, Mods = { ["haste"] = 0.3 } }
	end
	--Ancient Hysteria
	Aura[GetSpellInfo(90355)] = { School = "All", Category = "30% haste", ID = 90355, CustomHaste = true, Multiply = true, Mods = { ["haste"] = 0.3 }, NoManual = not Hunter }
	--Time Warp
	Aura[GetSpellInfo(80353)] = { School = "All", Category = "30% haste", ID = 80353, CustomHaste = true, Multiply = true, Mods = { ["haste"] = 0.3 }, NoManual = not Mage }
	--Ferocious Inspiration
	Aura[GetSpellInfo(34460)] = { Category = "+3% damage", Not = { "Absorb", "Utility", "Pet" }, Manual = GetSpellInfo(34460), ID = 34460, Multiply = true, Mods = { ["dmgM"] = 0.03 } }
	--Arcane Tactics
	Aura[GetSpellInfo(82930)] = Aura[GetSpellInfo(34460)]
	--Communion
		--Concentration
		Aura[GetSpellInfo(19746)] = { Category = "+3% damage", Not = { "Absorb", "Utility", "Pet" }, Manual = GetSpellInfo(31876), ID = 31876, Multiply = true, Mods = { ["dmgM"] = 0.03 }, NoManual = not Paladin }
		--Retribution
		Aura[GetSpellInfo(7294)] = Aura[GetSpellInfo(19746)]
		--Devotion
		Aura[GetSpellInfo(465)] = Aura[GetSpellInfo(19746)]
		--Crusader
		--Aura[GetSpellInfo(32223)] = Aura[GetSpellInfo(19746)]
		--Resistance
		--Aura[GetSpellInfo(19891)] = Aura[GetSpellInfo(19746)]
	--+5% crit
		--Elemental Oath
		Aura[GetSpellInfo(51466)] = { School = "All", Category = "+5% crit", ID = 51466, Mods = { ["spellCrit"] = 5, ["meleeCrit"] = 5 } }
		--Leader of the Pack
		Aura[GetSpellInfo(17007)] = { School = "All", Category = "+5% crit", ID = 17007, Mods = { ["spellCrit"] = 5, ["meleeCrit"] = 5 } }
		--Rampage
		Aura[GetSpellInfo(29801)] = { School = "All", Category = "+5% crit", ID = 29801, Mods = { ["spellCrit"] = 5, ["meleeCrit"] = 5 }, NoManual = not Warrior }
		--Terrifying Roar
		Aura[GetSpellInfo(90309)] = { School = "All", Category = "+5% crit", ID = 90309, Mods = { ["spellCrit"] = 5, ["meleeCrit"] = 5 }, NoManual = not Hunter }
		--Furious Howl
		Aura[GetSpellInfo(24604)] = { School = "All", Category = "+5% crit", ID = 24604, Mods = { ["spellCrit"] = 5, ["meleeCrit"] = 5 }, NoManual = not Hunter}
		--Honor Among Thieves
		Aura[GetSpellInfo(51701)] = { School = "All", Category = "+5% crit", ID = 51701, Mods = { ["spellCrit"] = 5, ["meleeCrit"] = 5 }, NoManual = not Rogue }

	--5% All Stats
		--Blessing of Kings (Paladin)
		Aura[GetSpellInfo(20217)] = { School = "All", Category = "+5% All Stats", ID = 20217,
			ModType = function(calculation)
				calculation.strM = calculation.strM * 1.05
				calculation.agiM = calculation.agiM * 1.05
				calculation.intM = calculation.intM * 1.05
				calculation.spiM = calculation.spiM * 1.05
			end,
			Mods = {
				[1] = function(calculation)
					if not calculation.customStats then
						calculation.str_mod = (calculation.str_mod or 0) + 0.05 * UnitStat("player",1)
						calculation.agi_mod = (calculation.agi_mod or 0) + 0.05 * UnitStat("player",2)
						calculation.int_mod = (calculation.int_mod or 0) + 0.05 * UnitStat("player",4)
						calculation.spi_mod = (calculation.spi_mod or 0) + 0.05 * UnitStat("player",5)
					end
				end
			},
		}
		--Mark of the Wild (Druid)
		Aura[GetSpellInfo(1126)] = { School = "All", Category = "+5% All Stats", ID = 1126, NoManual = not Druid,
			ModType = function(calculation)
				calculation.strM = calculation.strM * 1.05
				calculation.agiM = calculation.agiM * 1.05
				calculation.intM = calculation.intM * 1.05
				calculation.spiM = calculation.spiM * 1.05
			end,
			Mods = {
				[1] = function(calculation)
					if not calculation.customStats then
						calculation.str_mod = (calculation.str_mod or 0) + 0.05 * UnitStat("player",1)
						calculation.agi_mod = (calculation.agi_mod or 0) + 0.05 * UnitStat("player",2)
						calculation.int_mod = (calculation.int_mod or 0) + 0.05 * UnitStat("player",4)
						calculation.spi_mod = (calculation.spi_mod or 0) + 0.05 * UnitStat("player",5)
					end
				end
			},
		}
		--Embrace of the Shale Spider (Hunter)
		Aura[GetSpellInfo(90363)] = { School = "All", Category = "+5% All Stats", ID = 90363, NoManual = not Hunter,
			ModType = function(calculation)
				calculation.strM = calculation.strM * 1.05
				calculation.agiM = calculation.agiM * 1.05
				calculation.intM = calculation.intM * 1.05
				calculation.spiM = calculation.spiM * 1.05
			end,
			Mods = {
				[1] = function(calculation)
					if not calculation.customStats then
						calculation.str_mod = (calculation.str_mod or 0) + 0.05 * UnitStat("player",1)
						calculation.agi_mod = (calculation.agi_mod or 0) + 0.05 * UnitStat("player",2)
						calculation.int_mod = (calculation.int_mod or 0) + 0.05 * UnitStat("player",4)
						calculation.spi_mod = (calculation.spi_mod or 0) + 0.05 * UnitStat("player",5)
					end
				end
			},
		}
		--Blessing of Forgotten Kings (Leatherworking)
		Aura[GetSpellInfo(69378)] = { School = "All", ID = 69378, NoManual = true,
			ModType = function(calculation, ActiveAuras)
				if not ActiveAuras["+5% All Stats"] then
					calculation.strM = calculation.strM * 1.04
					calculation.agiM = calculation.agiM * 1.04
					calculation.intM = calculation.intM * 1.04
					calculation.spiM = calculation.spiM * 1.04
				end
			end
		}
	--+10% AP / +MP5
		--Blessing of Might
		Aura[GetSpellInfo(19740)] = { School = "All", ModType = "APM", Value = 0.1, Category = "+10% AP", SkipCategoryMod = true, ID = 19740, Mods = { [1] =
			function(calculation, ActiveAuras)
				if not ActiveAuras["+10% AP"] then
					calculation.AP_bonus = (calculation.AP_bonus or 0) + 0.1 * calculation.AP
					ActiveAuras["+10% AP"] = true
				end
				if not ActiveAuras["+MP5"] and calculation.caster then
					calculation.manaRegen = calculation.manaRegen + DrDamage:ScaleData(0.736 / 5, nil, nil, nil, true)
					ActiveAuras["+MP5"] = true
				end
			end },
		}
	if playerCaster or playerHybrid then
		--Bloodgem Infusion
		--Aura[GetSpellInfo(34379)] = { School = "Damage Spells", Value = 0.05, NoManual = true }
		--Vibrant Blood
		--Aura[GetSpellInfo(35329)] = { School = "Damage Spells", Value = 0.1, NoManual = true }
		--Dark Intent
		Aura[GetSpellInfo(94324)] = { School = "Spells", Caster = true, NoManual = true, ModType =
			function(calculation, _, _, index)
				if index then
					local _, _, _, apps = UnitBuff("player",index)
					--NOTE: Need to check for apps here as there are two buffs with the same name and texture
					if apps then
						calculation.dmgM_dot = calculation.dmgM_dot * (1 + tonumber(apps) * 0.03)
					end
				end
			end
		}
		if not DK then
			--+6% Spell Power
				--Arcane Brilliance
				Aura[GetSpellInfo(1459)] = { School = "All", ModType = "SPM", Value = 0.06, Category = "+6% SP", Mods = { [1] = function(calculation) calculation.SP_bonus = (calculation.SP_bonus or 0) + 0.06 * calculation.SP end }, ID = 1459, }
				--Dalaran Brilliance
				Aura[GetSpellInfo(61316)] = { School = "All", ModType = "SPM", Value = 0.06, Category = "+6% SP", Mods = { [1] = function(calculation) calculation.SP_bonus = (calculation.SP_bonus or 0) + 0.06 * calculation.SP end }, ID = 61316, }
				--Flametongue Totem
				Aura[GetSpellInfo(8227)] = { School = "All", ModType = "SPM", Value = 0.06, Category = "+6% SP", Mods = { [1] = function(calculation) calculation.SP_bonus = (calculation.SP_bonus or 0) + 0.06 * calculation.SP end }, ID = 8227, }
			--+10% Spell Power
				--Totemic Wrath
				Aura[GetSpellInfo(77746)] = { School = "All", ModType = "SPM", Value = 0.1, Category = "+10% SP", Mods = { [1] = function(calculation) calculation.SP_bonus = (calculation.SP_bonus or 0) + 0.1 * calculation.SP end }, ID = 77746, }
				--Demonic Pact
				Aura[GetSpellInfo(47236)] = { School = "All", ModType = "SPM", Value = 0.1, Category = "+10% SP", Mods = { [1] = function(calculation) calculation.SP_bonus = (calculation.SP_bonus or 0) + 0.1 * calculation.SP end }, ID = 47236 }
			--+5% spell haste
				--Wrath of Air
				Aura[GetSpellInfo(3738)] = { School = "Spells", Category = "+5% haste", Caster = true, CustomHaste = true, Mods = { ["haste"] = function(v, baseSpell) return baseSpell.MeleeHaste and v or v * 1.05 end }, ID = 3738 }
				--Moonkin Aura
				Aura[GetSpellInfo(24907)] = { School = "Spells", Category = "+5% haste", Caster = true, CustomHaste = true, Mods = { ["haste"] = function(v, baseSpell) return baseSpell.MeleeHaste and v or v * 1.05 end }, ID = 24907 }
				--Mind Quickening
				Aura[GetSpellInfo(49868)] = { School = "Spells", Category = "+5% haste", Caster = true, CustomHaste = true, Mods = { ["haste"] = function(v, baseSpell) return baseSpell.MeleeHaste and v or v * 1.05 end }, ID = 49868, NoManual = not Priest }
			--Power Infusion
			Aura[GetSpellInfo(10060)] = { School = "Spells", Caster = true, Multiply = true, Mods = { ["haste"] = 0.2, ["manaCost"] = -0.2 }, ID = 10060 }
			--Mana Spring Totem
			Aura[GetSpellInfo(5677)] = { School = "Spells", Caster = true, Category = "+MP5", Mods = { ["manaRegen"] = function(regen) return regen + DrDamage:ScaleData(0.736 / 5, nil, nil, nil, true) end }, ID = 5677 }
			--Fel Intelligence
			Aura[GetSpellInfo(54424)] = { School = "Spells", Caster = true, Category = "+MP5", Mods = { ["manaRegen"] = function(regen) return regen + DrDamage:ScaleData(0.736 / 5, nil, nil, nil, true) end }, ID = 54424, NoManual = not Warlock }
		end
	end
	if playerHybrid or playerMelee then
		--Agi/Str
			--Strength of Earth (Shaman)
			Aura[GetSpellInfo(8076)] = { ID = 8076, Category = "+Agi/Str", Mods = { [1] =
				function(calculation)
					local bonus = DrDamage:ScaleData( 1.24, nil, nil, nil, true )
					calculation.agi = calculation.agi + bonus
					calculation.str = calculation.str + bonus
				end },
			}
			--Battle Shout (Warrior)
			Aura[GetSpellInfo(6673)] = { ID = 6673, Category = "+Agi/Str", Mods = { [1] =
				function(calculation)
					local bonus = DrDamage:ScaleData( 1.24, nil, nil, nil, true )
					calculation.agi = calculation.agi + bonus
					calculation.str = calculation.str + bonus
				end },
			}
			--Horn of Winter (Death Knight)
			Aura[GetSpellInfo(57330)] = { ID = 57330, Category = "+Agi/Str", NoManual = not DK, Mods = { [1] =
				function(calculation)
					local bonus = DrDamage:ScaleData( 1.24, nil, nil, nil, true )
					calculation.agi = calculation.agi + bonus
					calculation.str = calculation.str + bonus
				end },
			}
			--Roar of Courage (Hunter Cat)
			Aura[GetSpellInfo(93435)] = { ID = 93435, Category = "+Agi/Str", NoManual = not Hunter, Mods = { [1] =
				function(calculation)
					local bonus = DrDamage:ScaleData( 1.24, nil, nil, nil, true )
					calculation.agi = calculation.agi + bonus
					calculation.str = calculation.str + bonus
				end },
			}
		--+10% AP
			--Trueshot Aura
			Aura[GetSpellInfo(19506)] = { ModType = "APM", Value = 0.1, Mods = { [1] = function(calculation) calculation.AP_bonus = (calculation.AP_bonus or 0) + 0.1 * calculation.AP end }, ID = 19506, Category = "+10% AP" }
			--Unleashed Rage
			Aura[GetSpellInfo(30808)] = { ModType = "APM", Value = 0.1, Mods = { [1] = function(calculation) calculation.AP_bonus = (calculation.AP_bonus or 0) + 0.1 * calculation.AP end }, ID = 30808, Category = "+10% AP" }
			--Abomination's Might
			Aura[GetSpellInfo(53138)] = { ModType = "APM", Value = 0.1, Mods = { [1] = function(calculation) calculation.AP_bonus = (calculation.AP_bonus or 0) + 0.1 * calculation.AP end }, ID = 53138, Category = "+10% AP" }
		--+10% melee haste
			--Windfury Totem
			Aura[GetSpellInfo(8512)] = { CustomHaste = true, Mods = { ["haste"] = function(v, baseSpell) return (baseSpell.WeaponDPS or baseSpell.NextMelee or baseSpell.MeleeHaste) and 1.1 * v or v end }, ID = 8512, Category = "+Meleehaste" }
			--Improved Icy Talons
			Aura[GetSpellInfo(55610)] = { CustomHaste = true, Mods = { ["haste"] = function(v, baseSpell) return (baseSpell.WeaponDPS or baseSpell.NextMelee or baseSpell.MeleeHaste) and 1.1 * v or v end }, ID = 55610, Category = "+Meleehaste", NoManual = not DK }
			--Hunting Party
			Aura[GetSpellInfo(53290)] = { CustomHaste = true, Mods = { ["haste"] = function(v, baseSpell) return (baseSpell.WeaponDPS or baseSpell.NextMelee or baseSpell.MeleeHaste) and 1.1 * v or v end }, ID = 53290, Category = "+Meleehaste", NoManual = not Hunter }
	end
	if playerHealer then
	--Buffs
		--Nether Portal - Serenity (Karazhan)
		--Aura[GetSpellInfo(30422)] = { School = "Healing", Caster = true, Value = 0.05, Apps = 99, NoManual = true }
		--Luck of the Draw (Random LFG Bonus)
		Aura[GetSpellInfo(72221)] = { School = "Healing", Caster = true, Value = 0.05, NoManual = true }
		--Strength of Wrynn
		Aura[GetSpellInfo(73762)] = { School = { "Healing", "Pet" }, Caster = true, NoManual = true, ModType =
			function( calculation )
				calculation.dmgM = calculation.dmgM * 1.3
				calculation.dmgM_absorb = (calculation.dmgM_absorb or 1) * 1.3
			end
		}
		--Hellscream's Warsong
		Aura[GetSpellInfo(73816)] = { School = { "Healing", "Pet" }, Caster = true, NoManual = true, ModType =
			function( calculation, _, _, index )
				calculation.dmgM = calculation.dmgM * 1.3
				calculation.dmgM_absorb = (calculation.dmgM_absorb or 1) * 1.3
			end
		}
	--Debuffs
		--Stolen Soul (Exarch Maladaar)
		--Aura[GetSpellInfo(32346)] = { School = "Healing", Caster = true, Value = -0.5, NoManual = true }
		--Wretching Bile (Stratholme)
		Aura[GetSpellInfo(52527)] = { School = "Healing", Caster = true, Value = -0.35, NoManual = true }
		--Necrotic Strike (Icecrown)
		--Aura[GetSpellInfo(60626)] = { School = "Healing", Caster = true, Value = -0.1, Apps = 1, NoManual = true }
		--Emerald Vigor (Valithria Dreamwalker)
		--Aura[GetSpellInfo(70873)] = { School = "Healing", Caster = true, Value = 0.10, Apps = 1, NoManual = true }
		--Hopelessness
		--Aura[GetSpellInfo(72390)] = { School = "Healing", Caster = true, NoManual = true, ModType =
		--	function( calculation, _, _, index )
		--		local id
		--		if index then id = select(11,UnitBuff("player",index)) end
		--		local penalty = (id == 72397) and 0.6 or (id == 72396) and 0.4 or (id == 72395) and 0.2 or (id == 72393) and 0.75 or (id == 72391) and 0.5 or 0.25 --72390
		--		calculation.dmgM = calculation.dmgM * (1 - penalty)
		--	end
		--}
	end
	if playerHealer or playerCaster or playerHybrid then
		--Shadow Crash ((Valithria Dreamwalker)
		Aura[GetSpellInfo(63277)] = { School = "Spells", Not = { "Absorb", "Utility", "Pet" }, ModType = function(calculation) calculation.dmgM = calculation.dmgM * (calculation.healingSpell and 0.25 or 2) end, NoManual = true, }
		--Debilitating Strike (Melee damage done reduced by 75%)
		Aura[GetSpellInfo(37578)] = { School = "Damage Spells", Value = 1/(1-0.75) - 1, NoManual = true }
		--Bonegrinder (Melee damage done reduced by 75%)
		Aura[GetSpellInfo(43952)] = Aura[GetSpellInfo(37578)]
		--Hammer Drop (Physical damage done reduced by 5%)
		Aura[GetSpellInfo(57759)] = { School = "Damage Spells", Apps = 1, NoManual = true, ModType =
			function(calculation, _, _, _, apps)
				calculation.dmgM = calculation.dmgM * 1/(1-0.05 * apps)
			end
		}
		--Demoralizing roar (-10% physical damage)
		Aura[GetSpellInfo(99)] = { School = "Damage Spells", ModType = "dmgM_Physical", Value = 1/1.1, Multiply = true, NoManual = true }
		--Demoralizing screech
		Aura[GetSpellInfo(24423)] = Aura[GetSpellInfo(99)]
		--Demoralizing shout
		Aura[GetSpellInfo(1160)] = Aura[GetSpellInfo(99)]
		--Vindication
		Aura[GetSpellInfo(26017)] = Aura[GetSpellInfo(99)]
		--Scarlet Fever (Death Knight)
		Aura[GetSpellInfo(81130)] = Aura[GetSpellInfo(99)]
		--Curse of Weakness
		Aura[GetSpellInfo(702)] = Aura[GetSpellInfo(99)]
		--Alluring Aura (Karazhan - Physical Damage done is reduced by 50%)
		--Aura[GetSpellInfo(29485)] = { School = "Damage Spells", Value = 1/(1-0.5) - 1, NoManual = true }
		--Shatter Armor (SSC - Melee damage done reduced by 35%)
		--Aura[GetSpellInfo(38591)] = { School = "Damage Spells", Value = 1/(1-0.35) - 1, NoManual = true }
	end

--Target
	Aura = DrDamage.TargetAura

--Buffs
	--Damage increase
		--Death Wish(Warrior)
		Aura[GetSpellInfo(12292)] = { Value = 0.05, NoManual = true }
		--Recklessness (Warrior)
		Aura[GetSpellInfo(1719)] = { Value = 0.20, NoManual = true }
	--Damage decrease
		--Icebound Fortitude (Death Knight) NOTE: Does not take into account the talent Sanguine Fortitude
		Aura[GetSpellInfo(48792)] = { Value = -0.2, NoManual = true }
		--Bone Shield (Death Knight)
		Aura[GetSpellInfo(49222)] = { Value = -0.2, NoManual = true }
		--Blade Barrier (Death Knight)
		Aura[GetSpellInfo(49182)] = { Value = -0.02, Ranks = 3, NoManual = true }
		--Will of the Necropolis (Death Knight)
		Aura[GetSpellInfo(81162)] = { Value = { -0.08, -0.16, -0.25 }, Ranks = 3, NoManual = true }
		--Blood Presence (Death Knight)
		Aura[GetSpellInfo(48263)] = { Value = -0.08, NoManual = true }
		--Dispersion (Priest)
		Aura[GetSpellInfo(47585)] = { Value = -0.9, NoManual = true }
		--Shadowform (Priest)
		Aura[GetSpellInfo(15473)] = { Value = -0.15, NoManual = true }
		--Pain Suppression (Priest)
		Aura[GetSpellInfo(33206)] = { Value = -0.4, NoManual = true }
		--Focused Will (Priest)
		Aura[GetSpellInfo(45234)] = { Apps = 2, Ranks = 2, NoManual = true, ModType =
			function( calculation, _, _, _, apps, _, rank )
				if UnitExists("target") and not UnitIsFriend("target","player") then
					calculation.dmgM = calculation.dmgM * (1 - (rank * 0.05) * apps)
				end
			end
		}
		--Divine Guardian (Paladin)
		Aura[GetSpellInfo(70940)] = { Value = -0.2, NoManual = true }
		--Ardent Defender (Paladin)
		Aura[GetSpellInfo(31850)] = { Value = -0.2, NoManual = true }
		--Safeguard (Warrior)
		Aura[GetSpellInfo(46945)] = { Value = -0.15, Ranks = 2, NoManual = true }
		--Shield Wall (Warrior)
		Aura[GetSpellInfo(871)] = { Value = -0.4, NoManual = true }
		--TODO: Defensive stance? Battle Stance?
		--Survival Instincts (Druid)
		Aura[GetSpellInfo(61336)] = { Value = -0.5, NoManual = true }
		--Barkskin (Druid)
		Aura[GetSpellInfo(22812)] = { Value = -0.2, NoManual = true }
		--Cheating Death (Rogue)
		Aura[GetSpellInfo(45182)] = { Value = -0.9, NoManual = true }
		--Shamanistic Rage (Shaman)
		Aura[GetSpellInfo(30823)] = { Value = -0.3, NoManual = true }
		--Soul Link (Warlock)
		Aura[GetSpellInfo(19028)] = { Value = -0.2, NoManual = true }
		--Stoneform (Dwarf Racial)
		Aura[GetSpellInfo(65116)] = { Value = -0.1, NoManual = true }
--Debuffs
	--+8% Magic Damage
		--Curse of the Elements (Warlock)
		Aura[GetSpellInfo(1490)] = { Value = 0.08, Category = "+8% dmg", ID = 1490, ModType = "dmgM_Magic" }
		--Earth and Moon (Druid)
		Aura[GetSpellInfo(48506)] = { Value = 0.08, Category = "+8% dmg", ID = 48506, ModType = "dmgM_Magic" }
		--Ebon Plague (Death Knight)
		Aura[GetSpellInfo(51160)] = { Value = 0.08, Category = "+8% dmg", ID = 51160, ModType = "dmgM_Magic" }
		--Fire Breath (Hunter pet)
		Aura[GetSpellInfo(34889)] = { Value = 0.08, Category = "+8% dmg", ID = 34889, ModType = "dmgM_Magic", NoManual = not Hunter }
		--Lightning Breath (Hunter pet)
		Aura[GetSpellInfo(24844)] = { Value = 0.08, Category = "+8% dmg", ID = 24844, ModType = "dmgM_Magic", NoManual = not Hunter }
		--Master Poisoner (Rogue)
		Aura[GetSpellInfo(93068)] = { Value = 0.08, Category = "+8% dmg", ID = 93068, ModType = "dmgM_Magic", NoManual = not Rogue }
	--+5% crit
		--Shadow and Flame
		Aura[GetSpellInfo(17800)] = { School = "Damage Spells", Value = 5, Category = "+5% crit", ID = 17800, ModType = "spellCrit" }
		--Critical Mass
		Aura[GetSpellInfo(22959)] = { School = "Damage Spells", Value = 5, Category = "+5% crit", ID = 22959, ModType = "spellCrit" }
	if playerCaster or playerHybrid then
		--Anti-Magic Shell
		Aura[GetSpellInfo(48707)] = { School = "Damage Spells", Value = -0.75, NoManual = true }
		--Anti-Magic Zone
		Aura[GetSpellInfo(50461)] = { School = "Damage Spells", Value = -0.75, NoManual = true }
	end
	--Buffs
	if playerHealer then
		--Demon Armor
		Aura[GetSpellInfo(687)] = { School = "Healing", Caster = true, Value = 0.2, ID = 687 }
		--Sacred Shield
		Aura[GetSpellInfo(96263)] = { School = "Healing", Caster = true, Value = 0.2, NoManual = true }
		--Vampiric Blood
		Aura[GetSpellInfo(55233)] = { School = "Healing", Caster = true, Value = 0.25, NoManual = true }
		--Divine Hymn
		Aura[GetSpellInfo(64843)] = { School = "Healing", Caster = true, Value = 0.1, NoManual = true }
		--Guardian Spirit
		Aura[GetSpellInfo(47788)] = { School = "Healing", Caster = true, Value = 0.4, NoManual = true }
		--Blessed Resilience
		Aura[GetSpellInfo(33142)] = { School = "Healing", Caster = true, Ranks = 2, Value = 0.15, NoManual = true }
	--Debuffs
	--Player
		--10% healing
			--Mortal Strike
			Aura[GetSpellInfo(12294)] = { School = "Healing", Caster = true, Value = -0.1, Category = "Mortal Strike", Manual = GetSpellInfo(12294), ID = 12294 }
			--Legion Strike (Felguard)
			Aura[GetSpellInfo(30213)] = Aura[GetSpellInfo(12294)]
			--Widow Venom (Hunter)
			Aura[GetSpellInfo(82654)] = Aura[GetSpellInfo(12294)]
			--Wound Poison (Rogue)
			Aura[GetSpellInfo(43461)] = Aura[GetSpellInfo(12294)]
			--Furious Attacks (Fury Warrior talent)
			Aura[GetSpellInfo(46910)] = Aura[GetSpellInfo(12294)]
			--Mind Trauma (Improved Mind Blast)
			Aura[GetSpellInfo(48301)] = Aura[GetSpellInfo(12294)]
			--Permafrost (Mage talent)
			Aura[GetSpellInfo(68391)] = { School = "Healing", Caster = true, Ranks = 3, Value = { -0.03, -0.07, -0.1 }, Category = "Mortal Strike", Manual = GetSpellInfo(12294), ID = 12294 }
			--Monstrous bite (Hunter pet)
			Aura[GetSpellInfo(54680)] = Aura[GetSpellInfo(12294)]
	--NPC
	--25% reduction
		--Fetid Rot (King Ymiron)
		--Aura[GetSpellInfo(48291)] = { School = "Healing", Caster = true, Value = -0.25, Category = "Mortal Strike", NoManual = true }
		--Wounding Strike (Chrono-Lord Epoch - Stratholme)
		--Aura[GetSpellInfo(52771)] = Aura[GetSpellInfo(48291)]
		--Dark Volley (Ulduar - Guardian of Yogg-Saron)
		--Aura[GetSpellInfo(63038)] = Aura[GetSpellInfo(48291)]
	--50% reduction (Mortal Strike)
		--Mortal Cleave (random mobs)
		Aura[GetSpellInfo(22859)] = { School = "Healing", Caster = true, Value = -0.5, Category = "Mortal Strike", NoManual = true }
		--Mutated Infection (Rotface)
		--Aura[GetSpellInfo(69674)] = Aura[GetSpellInfo(22859)]
		--Soul Strike (Halls of Lightning, Mana-Tombs)
		--Aura[GetSpellInfo(32315)] = Aura[GetSpellInfo(22859)]
		--Curse of the Deadwood (Felwood)
		--Aura[GetSpellInfo(13583)] = Aura[GetSpellInfo(22859)]
		--Arcing Smash (Gurtogg)
		--Aura[GetSpellInfo(40599)] = Aura[GetSpellInfo(22859)]
	--75% reduction
		--Veil of Shadow (Multiple places)
		Aura[GetSpellInfo(17820)] = { School = "Healing", Caster = true, Value = -0.75, Category = "Mortal Strike", NoManual = true }
		--Veil of Shadow Alternate (Different Localized name)
		Aura[GetSpellInfo(69633)] = Aura[GetSpellInfo(17820)]
		--Gehennas' Curse
		Aura[GetSpellInfo(19716)] = Aura[GetSpellInfo(17820)]
	--100% reduction
		--Necrotic Aura (Loatheb)
		--Aura[GetSpellInfo(55593)] = { School = "Healing", Caster = true, Value = -1, Category = "Mortal Strike", NoManual = true }
		--Embrace of the Vampyr (Prince Taldaram)
		--Aura[GetSpellInfo(59513)] = { School = "Healing", Caster = true, Value = -1, Category = "Mortal Strike", DebuffID = 59513, NoManual = true }
		--Enfeeble (Prince Malchezaar)
		--Aura[GetSpellInfo(30843)] = Aura[GetSpellInfo(55593)]
	--Others
		--Nether Portal - Dominance (Kharazan)
		--Aura[GetSpellInfo(30423)] = { School = "Healing", Caster = true, Value = -0.01, Apps = 10, Category = "Mortal Strike", NoManual = true }
		--Dark Touched (Eredar Twins)
		--Aura[GetSpellInfo(45347)] = { School = "Healing", Caster = true, Value = -0.05, Apps = 1, Category = "Mortal Strike", NoManual = true }
		--Mortal Wound (Naxxramas etc)
		--Aura[GetSpellInfo(28467)] = { School = "Healing", Caster = true, Value = -0.1, Apps = 1, Category = "Mortal Strike", NoManual = true }
		--Chop (random 70-80 mobs)
		Aura[GetSpellInfo(43410)] = { School = "Healing", Caster = true, Value = -0.1, Category = "Mortal Strike", NoManual = true }
		--Suppression (Valithria Dreamwalker)
		--Aura[GetSpellInfo(70588)] = { School = "Healing", Caster = true, Value = -0.1, Category = "Mortal Strike", NoManual = true }
		--Shroud of Darkness (Zuramat the Obliterator)
		---Aura[GetSpellInfo(54525)] = { School = "Healing", Caster = true, Value = -0.2, Apps = 1, Category = "Mortal Strike", NoManual = true }
	end
	if playerMelee or playerHybrid then
	--Buffs
		--Inspiration
		Aura[GetSpellInfo(14893)] = { School = "Physical", Melee = true, Value = -0.05, Ranks = 2, Category = "-10% Physical", ID = 14893, NoManual = true }
		--Ancestral Fortitude
		Aura[GetSpellInfo(16177)] = { School = "Physical", Melee = true, Value = -0.05, Ranks = 2, Category = "-10% Physical", ID = 16177, NoManual = true }
	--Debuffs
	--Player
		--+4% physical damage
			--Savage Combat
			Aura[GetSpellInfo(58683)] = { School = "Physical", Melee = true, Value = 0.02, Ranks = 2, Category = "+4% Physical", ID = 58683 }
			--Blood Frenzy
			Aura[GetSpellInfo(29836)] = { School = "Physical", Melee = true, Value = 0.02, Ranks = 2, Category = "+4% Physical", Category2 = "+30% bleed", ID = 29836, ModType =
				function(calculation, _, _, _, _, _, rank)
					calculation.dmgM = calculation.dmgM * (1 + rank * 0.02)
					calculation.bleedBonus = calculation.bleedBonus * (1 + rank * 0.15)
				end
			}
			--Acid Spit (Hunter Pet)
			Aura[GetSpellInfo(55749)] = { School = "Physical", Melee = true, Value = 0.04, Category = "+4% Physical", ID = 55749, NoManual = not Hunter }
			--Brittle Bones (Death Knight)
			Aura[GetSpellInfo(81328)] = { School = "Physical", Melee = true, Value = 0.02, Ranks = 2, Category = "+4% Physical", ID = 81328, NoManual = not DK }
		--+30% bleed damage
			--Mangle (Bear)
			Aura[GetSpellInfo(33878)] = { School = "Physical", Melee = true, Value = 0.3, ModType = "bleedBonus", Category = "+30% bleed", Manual = GetSpellInfo(33917), ID = 33917 }
			--Mangle (Cat)
			Aura[GetSpellInfo(33876)] = Aura[GetSpellInfo(33878)]
			--Hemorrhage
			Aura[GetSpellInfo(16511)] = { School = "Physical", Melee = true, Value = 0.3, ModType = "bleedBonus", Category = "+30% bleed", ID = 16511 }
			--Stampede
			Aura[GetSpellInfo(57386)] = { School = "Physical", Melee = true, Value = 0.3, ModType = "bleedBonus", Category = "+30% bleed", ID = 57386, NoManual = not Hunter }
			--Gore (Hunter Pet)
			Aura[GetSpellInfo(35290)] = Aura[GetSpellInfo(57386)]
			--Tendon Rip (Hunter Pet)
			Aura[GetSpellInfo(50271)] = Aura[GetSpellInfo(57386)]
		---20% Armor
			--Shattering Throw
			Aura[GetSpellInfo(64382)] = { School = "Physical", Melee = true, Value = 0.2, ModType = "armorM", Category = "-20% Armor", Manual = GetSpellInfo(7386), ID = 7386, NoManual = not Warrior }
		---12% Armor
			--Expose Armor
			Aura[GetSpellInfo(8647)] = { School = "Physical", Melee = true, Value = 0.12, ModType = "armorM", Category = "-12% Armor", ID = 8647, NoManual = not Rogue }
			--Sunder Armor
			Aura[GetSpellInfo(7386)] = { School = "Physical", Melee = true, Apps = 3, Value = 0.04, ModType = "armorM", Category = "-12% Armor", Manual = GetSpellInfo(7386), ID = 7386 }
			--Faerie Fire
			Aura[GetSpellInfo(770)] = Aura[GetSpellInfo(7386)]
			--Faerie Fire (Feral)
			Aura[GetSpellInfo(16857)] = Aura[GetSpellInfo(7386)]
			--Tear Armor (Hunter Pet)
			Aura[GetSpellInfo(50498)] = Aura[GetSpellInfo(7386)]
			--Corrosive Spit (Hunter Pet)
			Aura[GetSpellInfo(35387)] = Aura[GetSpellInfo(7386)]
	end

	local Consumables = DrDamage.Consumables
	--Mastery Rating food
	Consumables[string.format(L["+%d Mastery Rating Food"],90)] = { School = "All", Mods = { ["mastery"] = function(v) return v + DrDamage:GetRating("Mastery", 90, true) end }, Category = "Food", Alt = GetSpellInfo(87549) }
	--Elixir of the Master
	Consumables[GetSpellInfo(79635)] = { School = "All", Mods = { ["mastery"] = function(v) return v + DrDamage:GetRating("Mastery", 225, true) end }, Category = "Battle Elixir", ID = 79635 }
	if (playerCaster or playerHybrid or playerHealer) and not DK then
		--Spell Power Food
		Consumables[string.format(L["+%d Spell Power Food"],46)] = { School = "All", Mods = { ["SP_mod"] = 46, }, Category = "Food", Alt = GetSpellInfo(57327) }
		--Intellect Food
		Consumables[string.format(L["+%d Intellect Food"],90)] = { School = "All", Mods = { ["int"] = 90, }, Category = "Food", Alt = GetSpellInfo(57327) }
		--Spirit Food
		Consumables[string.format(L["+%d Spirit Food"],90)] = { School = "All", Mods = { ["spi"] = 90, }, Category = "Food", Alt = GetSpellInfo(57327) }
		--Flask of the Draconic Mind
		Consumables[GetSpellInfo(79470)] = { School = "All", Mods = { ["int"] = 300 }, Category = "Battle Elixir", Category2 = "Guardian Elixir", ID = 79470 }
		--Ghost Elixir
		Consumables[GetSpellInfo(79468)] = { School = "All", Caster = true, Mods = { ["spi"] = 225 }, Category = "Battle Elixir", ID = 79468 }
		--Flask of Flowing Water
		Consumables[GetSpellInfo(94160)] = { School = "All", Caster = true, Mods = { ["spi"] = 300 }, Category = "Battle Elixir", Category2 = "Guardian Elixir", ID = 94160 }
	end
	if playerMelee or playerHybrid then
		--AP Food
		Consumables[string.format(L["+%d AP Food"],80)] = { Mods = { ["AP_mod"] = 80 }, Category = "Food", Alt = GetSpellInfo(57079) }
		--Agility Food
		Consumables[string.format(L["+%d Agility Food"],90)] = { School = "All", Mods = { ["agi"] = 90, }, Category = "Food", Alt = GetSpellInfo(57327) }
		--Strength Food
		Consumables[string.format(L["+%d Strength Food"],90)] = { School = "All", Mods = { ["str"] = 90, }, Category = "Food", Alt = GetSpellInfo(57327) }
		--Flask of the Winds
		Consumables[GetSpellInfo(79471)] = { Mods = { ["agi"] = 300 }, Category = "Battle Elixir", Category2 = "Guardian Elixir", ID = 79471 }
		--Flask of Titanic Strength
		Consumables[GetSpellInfo(79472)] = { Mods = { ["str"] = 300 }, Category = "Battle Elixir", Category2 = "Guardian Elixir", ID = 79472 }
		--Elixir of the Naga
		Consumables[GetSpellInfo(79474)] = 	{ Melee = true, Mods = { ["expertise"] = function(v) return v + DrDamage:GetRating("Expertise", 225, true) end }, Category = "Battle Elixir", ID = 60344 }
		--Expertise Rating Food
		Consumables[string.format(L["+%d Expertise Rating Food"],90)] = { Melee = true, Mods = { ["expertise"] = function(v) return v + DrDamage:GetRating("Expertise", 90, true) end }, Alt = GetSpellInfo(33263), Category = "Food" }
	end
--CUSTOM
	--Elixir of the Cobra
	Consumables[GetSpellInfo(79477)] = 	{ School = "All", Category = "Battle Elixir", ID = 79477,
		Mods = {
			function(calculation, baseSpell)
				if not baseSpell.NoManualRatings then
					local value = DrDamage:GetRating("Crit", 225, true)
					calculation.spellCrit = calculation.spellCrit + value
					calculation.meleeCrit = calculation.meleeCrit + value
				end
			end
		}
	}
	--Critical Strike Rating Food
	Consumables[string.format(L["+%d Critical Strike Rating Food"],90)] = { School = "All", Alt = GetSpellInfo(33263), Category = "Food",
		Mods = {
			function(calculation, baseSpell)
				if not baseSpell.NoManualRatings then
					local value = DrDamage:GetRating("Crit", 90, true)
					calculation.spellCrit = calculation.spellCrit + value
					calculation.meleeCrit = calculation.meleeCrit + value
				end
			end
		}
	}
	--Elixir of Impossible Accuracy
	Consumables[GetSpellInfo(80491)] = { Alt = GetSpellInfo(79481), Category = "Battle Elixir", ID = 79481,
		Mods = {
			function(calculation, baseSpell)
				if not baseSpell.NoManualRatings then
					calculation.spellHit = calculation.spellHit + DrDamage:GetRating("Hit", 225, true)
					calculation.meleeHit = calculation.meleeHit + DrDamage:GetRating("MeleeHit", 225, true)
				end
			end
		},
	}
	--Hit Rating Food
	Consumables[string.format(L["+%d Hit Rating Food"],90)] = { Alt = GetSpellInfo(33263), Category = "Food",
		Mods = {
			function(calculation, baseSpell)
				if not baseSpell.NoManualRatings then
					calculation.spellHit = calculation.spellHit + DrDamage:GetRating("Hit", 90, true)
					calculation.meleeHit = calculation.meleeHit + DrDamage:GetRating("MeleeHit", 90, true)
				end
			end
		},
	}
	--Elixir of Mighty Speed
	Consumables[GetSpellInfo(80493)] = { School = "All", Alt = GetSpellInfo(79632), Category = "Battle Elixir", ID = 79632,
		Mods = {
			function(calculation, baseSpell)
				if not baseSpell.NoManualRatings then
					local rating = (baseSpell.Melee or baseSpell.MeleeHaste) and "MeleeHaste" or "Haste"
					local base = DrDamage:GetRating(rating, calculation.hasteRating, true)/100
					calculation.haste = (calculation.haste / (1 + base)) * (1 + base + DrDamage:GetRating(rating, 225, true)/100)
				end
			end
		},
	}
	--Haste Rating Food
	Consumables[string.format(L["+%d Haste Rating Food"],90)] = { School = "All", Alt = GetSpellInfo(33263), Category = "Food",
		Mods = {
			function(calculation, baseSpell)
				if not baseSpell.NoManualRatings then
					local rating = (baseSpell.Melee or baseSpell.MeleeHaste) and "MeleeHaste" or "Haste"
					local base = DrDamage:GetRating(rating, calculation.hasteRating, true)/100
					calculation.haste = (calculation.haste / (1 + base)) * (1 + base + DrDamage:GetRating(rating, 90, true)/100)
				end
			end
		},

	}
end

DrD_LoadAuras()
DrD_LoadAuras = nil