local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales

C["general"] = {
	["autoscale"] = true,                               -- mainly enabled for users that don't want to mess with the config file
	["uiscale"] = 0.71,                                 -- set your value (between 0.64 and 1) of your uiscale if autoscale is off
	["overridelowtohigh"] = false,                      -- EXPERIMENTAL ONLY! override lower version to higher version on a lower reso.
	["multisampleprotect"] = false,                      -- i don't recommend this because of shitty border but, voila!
	["backdropcolor"] = { .1,.1,.1 },                   -- default backdrop color of panels
	["bordercolor"] = { .3,.3,.3 },                     -- default border color of panels
}

C["unitframes"] = {
	-- general options
	["enable"] = true,                                  -- do i really need to explain this?
	["enemyhcolor"] = false,                            -- enemy target (players) color by hostility, very useful for healer.
	["unitcastbar"] = false,                             -- enable tukui castbar
	["cblatency"] = false,                              -- enable castbar latency
	["cbicons"] = false,                                 -- enable icons on castbar
	["auratimer"] = true,                               -- enable timers on buffs/debuffs
	["auratextscale"] = 10,                             -- the font size of buffs/debuffs timers on unitframes
	["playerauras"] = false,                            -- enable auras
	["targetauras"] = true,                             -- enable auras on target unit frame
	["lowThreshold"] = 20,                              -- global low threshold, for low mana warning.
	["targetpowerpvponly"] = true,                      -- enable power text on pvp target only
	["totdebuffs"] = false,                             -- enable tot debuffs (high reso only)
	["showtotalhpmp"] = false,                          -- change the display of info text on player and target with XXXX/Total.
	["showsmooth"] = true,                              -- enable smooth bar
	["charportrait"] = false,                           -- do i really need to explain this?
	["maintank"] = false,                               -- enable maintank
	["mainassist"] = false,                             -- enable mainassist
	["unicolor"] = true,                               -- enable unicolor theme
	["combatfeedback"] = false,                          -- enable combattext on player and target.
	["playeraggro"] = true,                             -- color player border to red if you have aggro on current target.
	["healcomm"] = true,                               -- enable healprediction support.
	["onlyselfdebuffs"] = false,                        -- display only our own debuffs applied on target
	["showfocustarget"] = false,                         -- show focus target
	["bordercolor"] = { .3,.3,.3 },                     -- unit frames panel border color

	-- raid layout (if one of them is enabled)
	["showrange"] = true,                               -- show range opacity on raidframes
	["raidalphaoor"] = 0.3,                             -- alpha of unitframes when unit is out of range
	["gridonly"] = true,                               -- enable grid only mode for all healer mode raid layout.
	["showsymbols"] = true,	                            -- show symbol.
	["aggro"] = true,                                   -- show aggro on all raids layouts
	["raidunitdebuffwatch"] = true,                     -- track important spell to watch in pve for grid mode.
	["gridhealthvertical"] = true,                      -- enable vertical grow on health bar for grid mode.
	["showplayerinparty"] = true,                      -- show my player frame in party
	["gridscale"] = 1,                                  -- set the healing grid scaling
	
	-- boss frames
	["showboss"] = true,                                -- enable boss unit frames for PVELOL encounters.

	-- priest only plugin
	["weakenedsoulbar"] = false,                         -- show weakened soul bar
	
	-- class bar
	["classbar"] = true,                                -- enable tukui classbar over player unit
}

C["arena"] = {
	["unitframes"] = true,                              -- enable tukz arena unitframes (requirement : tukui unitframes enabled)
}

C["auras"] = {
	["player"] = true,                                  -- enable tukui buffs/debuffs
}

C["actionbar"] = {
	["enable"] = true,                                  -- enable tukui action bars
	["hotkey"] = false,                                 -- enable hotkey display because it was a lot requested
	["hideshapeshift"] = true,                         -- hide shapeshift or totembar because it was a lot requested.
	["showgrid"] = true,                                -- show grid on empty button
	["buttonsize"] = 24,                                -- normal buttons size
	["petbuttonsize"] = 22,                             -- pet & stance buttons size
	["buttonspacing"] = 4,                              -- buttons spacing
}

C["bags"] = {
	["enable"] = false,                                  -- enable an all in one bag mod that fit tukui perfectly
}

C["loot"] = {
	["lootframe"] = true,                               -- reskin the loot frame to fit tukui
	["rolllootframe"] = true,                           -- reskin the roll frame to fit tukui
	["autogreed"] = false,                               -- auto-dez or auto-greed item at max level, auto-greed Frozen orb
}

C["cooldown"] = {
	["enable"] = true,                                  -- do i really need to explain this?
	["treshold"] = 8,                                   -- show decimal under X seconds and text turn red
}

C["datatext"] = {
	["fps_ms"] = 0,                                     -- show fps and ms on panels
	["system"] = 0,                                     -- show total memory and others systems infos on panels
	["bags"] = 0,                                       -- show space used in bags on panels
	["gold"] = 0,                                       -- show your current gold on panels
	["wowtime"] = 6,                                    -- show time on panels
	["guild"] = 1,                                      -- show number on guildmate connected on panels
	["dur"] = 3,                                        -- show your equipment durability on panels.
	["friends"] = 2,                                    -- show number of friends connected.
	["dps_text"] = 0,                                   -- show a dps meter on panels
	["hps_text"] = 0,                                   -- show a heal meter on panels
	["power"] = 5,                                      -- show your attackpower/spellpower/healpower/rangedattackpower whatever stat is higher gets displayed
	["haste"] = 0,                                      -- show your haste rating on panels.
	["crit"] = 0,                                       -- show your crit rating on panels.
	["avd"] = 0,                                        -- show your current avoidance against the level of the mob your targeting
	["armor"] = 0,                                      -- show your armor value against the level mob you are currently targeting
	["currency"] = 4,                                   -- show your tracked currency on panels
	["hit"] = 0,
	["mastery"] = 0,
	["micromenu"] = 99,
	["regen"] = 0,                                      -- show mana regeneration
	["battleground"] = true,                            -- enable 3 stats in battleground only that replace stat1,stat2,stat3.
	["time24"] = false,                                  -- set time to 24h format.
	["localtime"] = true,                              -- set time to local time instead of server time.
	["fontsize"] = 10,                                  -- font size for panels.
}

C["chat"] = {
	["enable"] = true,                                  -- blah
	["whispersound"] = true,                            -- play a sound when receiving whisper
	["background"] = true,
}

C["nameplate"] = {
	["enable"] = false,                                  -- enable nice skinned nameplates that fit into tukui
	["showhealth"] = false,				                -- show health text on nameplate
	["enhancethreat"] = false,			                -- threat features based on if your a tank or not
	["combat"] = false,					                -- only show enemy nameplates in-combat.
	["goodcolor"] = {75/255,  175/255, 76/255},	        -- good threat color (tank shows this with threat, everyone else without)
	["badcolor"] = {0.78, 0.25, 0.25},			        -- bad threat color (opposite of above)
	["transitioncolor"] = {218/255, 197/255, 92/255},	-- threat color when gaining threat
}

C["tooltip"] = {
	["enable"] = true,                                  -- true to enable this mod, false to disable
	["hidecombat"] = false,                             -- hide bottom-right tooltip when in combat
	["hidebuttons"] = false,                            -- always hide action bar buttons tooltip.
	["hideuf"] = false,                                 -- hide tooltip on unitframes
	["cursor"] = false,                                 -- tooltip via cursor only
}

C["merchant"] = {
	["sellgrays"] = true,                               -- automaticly sell grays?
	["autorepair"] = true,                              -- automaticly repair?
	["sellmisc"] = false,                                -- sell defined items automatically
}

C["error"] = {
	["enable"] = false,                                  -- true to enable this mod, false to disable
	filter = {                                          -- what messages to not hide
		[INVENTORY_FULL] = true,                        -- inventory is full will not be hidden by default
	},
}

C["invite"] = { 
	["autoaccept"] = true,                              -- auto-accept invite from guildmate and friends.
}

C["buffreminder"] = {
	["enable"] = true,                                  -- this is now the new innerfire warning script for all armor/aspect class.
	["sound"] = true,                                   -- enable warning sound notification for reminder.
}

C["kyle"] = {
	["disableChatTabs"] = true,							-- Should show always-visible chat tabs when chat BG is enabled?
	["chatBGHeight"] = 153,								-- Height of the chat box background
	["unitFrameLayout"] = 1,							-- 1: Kyle, 2: Tuk default
	["jasjeComboPoints"] = true,
	["expanderButton"] = "G",
	["expanderScale"] = 1.8,
	["expanderAlpha"] = 0.8,
	["expanderToggle"] = true,
	["watchframeExpandButton"] = false,
	["chatWidth"] = 410,
	["chatHeight"] = 136,
	grid = {
		width = 55,
		height = 55,
	}
}
