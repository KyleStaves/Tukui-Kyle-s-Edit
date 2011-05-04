local UnitCastingInfo = UnitCastingInfo;
local UnitChannelInfo = UnitChannelInfo;
local GetItemInfo = GetItemInfo;
local GetSpellInfo = GetSpellInfo;
local GetSpellCooldown = GetSpellCooldown;
local UnitAura = UnitAura;
local GetItemCooldown = GetItemCooldown;
local GetRuneCooldown = GetRuneCooldown;
local GetRuneType = GetRuneType;
local GetTotemInfo = GetTotemInfo;
local UnitExists = UnitExists;
local UnitPower = UnitPower;
local UnitPowerMax = UnitPowerMax;
local UnitHealth = UnitHealth;
local UnitHealthMax = UnitHealthMax;
local UnitAlternatePowerInfo = UnitAlternatePowerInfo;
local UnitAlternatePowerTextureInfo = UnitAlternatePowerTextureInfo;
local select = select;
local pairs = pairs;
local ipairs = ipairs;
local tonumber = tonumber;
local string_match = string.match;
local string_gmatch = string.gmatch;
local string_trim = string.trim;
local string_gsub = string.gsub;
local string_len = string.len;
local string_lower = string.lower;
local table_insert = table.insert;

function Gnosis:Timers_Spell( bar, timer, ti )
	-- cast
	local spell, _, _, icon, s, d = UnitCastingInfo( timer.unit );
	if( d and d > 0 ) then
		if( timer.spell == "all" or timer.spell == spell ) then
			ti.bChannel = false;
			ti.dur = (d - s);
			ti.fin = d;
			ti.cname = spell;
			ti.icon = icon;
			ti.unit = timer.unit;
			ti.ok = true;
		end
	else
		spell, _, _, icon, s, d = UnitChannelInfo( timer.unit );
		if( d and d > 0 ) then
			if( timer.spell == "all" or timer.spell == spell ) then
				ti.bChannel = true;
				ti.dur = (d - s);
				ti.fin = d;
				ti.cname = spell;
				ti.icon = icon;
				ti.unit = timer.unit;
				ti.ok = true;
			end
		end
	end
end

function Gnosis:Timers_SpellCD( bar, timer, ti )
	-- cooldown, player only
	ti.unit = "player";
	local s, d = GetSpellCooldown( timer.spell );
	if( d and d > 1.5 ) then	-- duration greater than global cd
		if( not timer.bNot ) then
			ti.bChannel = true;
			ti.dur = d * 1000;
			ti.fin = (s + d) * 1000;
			ti.cname = timer.spell;
			ti.stacks = nil;
			ti.ok = true;
			ti.icon = select( 3, GetSpellInfo(timer.spell) );
		end
	elseif( timer.bNot ) then
		ti.bChannel = true;
		ti.cname = timer.spell;
		ti.stacks = nil;
		ti.icon = select( 3, GetSpellInfo(timer.spell) );
		ti.dur = 1;
		ti.fin = 1;
		ti.ok = true;
		ti.bSpecial = true;
	end
end

function Gnosis:Timers_Aura( bar, timer, ti )
	-- aura == buff or debuff (== hot or dot)
	ti.unit = timer.unit;
	local _, _, ic, sta, _, d, s = UnitAura( timer.unit, timer.spell, nil, timer.filter );
	if( s and d ) then
		if( not timer.bNot ) then
			if( not timer.nodur and s > 0 ) then
				-- dynamic aura
				ti.dur = d * 1000;
				ti.fin = s * 1000;
				ti.ok = true;
			elseif( timer.nodur and s == 0 and d == 0 ) then
				-- static aura
				ti.dur = 1;
				ti.fin = 1;
				ti.bSpecial = true;
				ti.ok = true;
			end
			ti.bChannel = true;
			ti.cname = timer.spell;
			ti.stacks = (sta and sta > 0) and sta or nil;
			ti.icon = ic;
		end
	elseif( timer.bNot ) then
		ti.bChannel = true;
		ti.cname = timer.spell;
		ti.stacks = nil;
		ti.icon = timer.icon or select( 3, GetSpellInfo(timer.spell) );
		ti.dur = 1;
		ti.fin = 1;
		ti.ok = true;
		ti.bSpecial = true;
	end
end

function Gnosis:Timers_ItemCD( bar, timer, ti )
	-- itemcd, player only
	ti.unit = "player";
	if( not timer.iid ) then
		local _, link, _, _, _, _, _, _, _, itex = GetItemInfo( timer.spell );
		if( link and itex ) then
			local iid = string_match( link, "|Hitem:(%d+):" );
			timer.iid = iid;
			timer.itex = itex;
		end
	end

	if( timer.iid ) then
		local s, d = GetItemCooldown( timer.iid );
		if( d and d > 1.5 ) then	-- duration greater than global cd
			if( not timer.bNot ) then
				ti.bChannel = true;
				ti.dur = d * 1000;
				ti.fin = (s + d) * 1000;
				ti.cname = timer.spell;
				ti.icon = timer.itex;
				ti.ok = true;
				ti.stacks = nil;
			end
		elseif( timer.bNot ) then
			ti.bChannel = true;
			ti.dur = 1;
			ti.fin = 1;
			ti.cname = timer.spell;
			ti.icon = timer.itex;
			ti.stacks = nil;
			ti.ok = true;
			ti.bSpecial = true;
		end
	end
end

function Gnosis:Timers_RuneCD( bar, timer, ti )
	-- rune cooldown, player only
	ti.unit = "player";
	local s, d, rdy = GetRuneCooldown( timer.spell );
	if( s and s > 0 ) then
		if( not timer.bNot ) then
			ti.bChannel = true;
			ti.dur = d * 1000;
			ti.fin = (s + d) * 1000;
			local rune = GetRuneType( timer.spell );
			if( rune ) then
				ti.cname = Gnosis.tRuneName[rune];
				ti.icon = Gnosis.tRuneTexture[rune];
			else
				ti.cname = "";
				ti.icon = nil;
			end
			ti.stacks = nil;
			ti.ok = true;
		end
	elseif( timer.bNot and rdy ) then
		ti.bChannel = true;
		ti.dur = 1;
		ti.fin = 1;
		local rune = GetRuneType( timer.spell );
		if( rune ) then
			ti.cname = Gnosis.tRuneName[rune];
			ti.icon = Gnosis.tRuneTexture[rune];
		else
			ti.cname = "";
			ti.icon = nil;
		end
		ti.stacks = nil;
		ti.ok = true;
		ti.bSpecial = true;
	end
end

function Gnosis:Timers_TotemDuration( bar, timer, ti )
	-- totem duration
	local bExist, name, s, d, icon = GetTotemInfo( timer.spell );
	if( bExist and name and s and s > 0 ) then
		if( not timer.bNot ) then
			ti.unit = "player";
			ti.bChannel = true;
			ti.dur = d * 1000;
			ti.fin = (s + d) * 1000;
			ti.cname = name;
			ti.icon = icon;
			ti.stacks = nil;
			ti.ok = true;
		end
	elseif( timer.bNot ) then
		ti.bChannel = true;
		ti.dur = 1;
		ti.fin = 1;
		ti.cname = "";
		ti.icon = nil;
		ti.stacks = nil;
		ti.ok = true;
		ti.bSpecial = true;
	end
end

function Gnosis:Timers_Power( bar, timer, ti )
	local s, d = UnitPower( timer.unit ), UnitPowerMax( timer.unit );
	if( d and d > 0 ) then
		local pts = select( 2, UnitPowerType( timer.unit ) );
		ti.cname = pts and _G[pts] or "";
		ti.bChannel = true;
		ti.bSpecial = true;
		ti.fin = s;
		ti.dur = d;
		ti.unit = timer.unit;
		ti.icon = nil;
		ti.ok = true;
	end
end

function Gnosis:Timers_Health( bar, timer, ti )
	local s, d = UnitHealth( timer.unit ), UnitHealthMax( timer.unit );
	if( d and d > 0 ) then
		ti.cname = _G["HEALTH"];
		ti.bChannel = true;
		ti.bSpecial = true;
		ti.fin = s;
		ti.dur = d;
		ti.unit = timer.unit;
		ti.icon = nil;
		ti.ok = true;
	end
end

function Gnosis:Timers_PowerAlternate( bar, timer, ti )
	local s, d = UnitPower( timer.unit, ALTERNATE_POWER_INDEX ), UnitPowerMax( timer.unit, ALTERNATE_POWER_INDEX );
	if( d and d > 0 ) then
		ti.cname = select( 10, UnitAlternatePowerInfo( timer.unit ) )
		ti.bChannel = true;
		ti.bSpecial = true;
		ti.fin = s;
		ti.dur = d;
		ti.unit = timer.unit;
		ti.icon = UnitAlternatePowerTextureInfo( timer.unit, 2 );
		ti.ok = true;
	end
end

local TimerInfo = {
};

local SelectedTimerInfo = {
};

function Gnosis:CreateSingleTimerTable()
	self:cleartable( self.ti_fl );

	for key, value in pairs( self.castbars ) do
		local conf = Gnosis.s.cbconf[key];

		if( conf.bEn and (conf.spec == 0 or conf.spec == self.iCurSpec) and conf.bartype == "ti" ) then
			value.timers = {};
			value.iTimerSort = nil;

			for k, v in ipairs(conf.bnwlist) do
				-- copy of timer command string
				local str = v;
				-- unit, recast, staticdur, zoom, spec
				local unit = string_match( str, "unit=(%w+)" );
				local recast = string_match( str, "recast=([+-]?[0-9]*%.?[0-9]*)" );	-- floating point regex
				local staticdur = string_match( str, "staticdur=([+-]?[0-9]*%.?[0-9]*)" );
				local zoom = string_match( str, "zoom=([+-]?[0-9]*%.?[0-9]*)" );
				local spec = string_match( str, "spec=(%d+)" );
				recast, staticdur, zoom =
					recast and (tonumber( recast ) * 1000),
					staticdur and (tonumber( staticdur ) * 1000),
					zoom and (tonumber( zoom ) * 1000);
				spec = spec and tonumber( spec );
				-- name format string
				local nfs = string_match( str, "nfs=\"(.-)\"" );
				if( not nfs ) then
					nfs = string_match( str, "nfs=(.-)[,:]" );
				else
					str = string_gsub( str, "nfs=\"(.-)\"", "" );
				end
				-- time format string
				local tfs = string_match( str, "tfs=\"(.-)\"" );
				if( not tfs ) then
					tfs = string_match( str, "tfs=(.-)[,:]" );
				else
					str = string_gsub( str, "tfs=\"(.-)\"", "" );
				end
				-- status bar color
				local colstr = string_match( str, "sbcol=\"(.-)\"" );
				local tsbcol;
				if( colstr ) then
					str = string_gsub( str, "sbcol=\"(.-)\"", "" );
					local r,g,b,a = self:GetColorsFromString( colstr );
					if( r ) then
						tsbcol = { r, g, b, a };
					end
				end
				-- command and spellname
				local cmd, spell = string_match( str, "(.-):(.+)" );
				local tiType, bSelf, bHarm, bHelp, bShowLag, bShowCasttime, iSort, bNoDur, bNot, cfinit;
				cmd, spell = cmd and string_trim( cmd ), spell and string_trim( spell );
				if( cmd and string_len( cmd ) > 0 and spell and string_len( spell ) > 0 ) then
					for w in string_gmatch( cmd, "%w+" ) do
						w = string_lower( w );

						if( w == "cast" ) then
							tiType = 0;
							cfinit = Gnosis.Timers_Spell;
						elseif( w == "cd" ) then
							tiType = 1;
							cfinit = Gnosis.Timers_SpellCD;
						elseif( w == "dot" or w == "debuff" ) then
							bHarm = true;
							tiType = 2;
							cfinit = Gnosis.Timers_Aura;
						elseif( w == "hot" or w == "buff" ) then
							bHelp = true;
							tiType = 2;
							cfinit = Gnosis.Timers_Aura;
						elseif( w == "aura" ) then
							tiType = 2;
							cfinit = Gnosis.Timers_Aura;
						elseif( w == "itemcd" ) then
							tiType = 3;
							cfinit = Gnosis.Timers_ItemCD;
						elseif( w == "runecd" ) then
							if( tonumber(spell) and tonumber(spell) > 0 and tonumber(spell) <= 6 ) then
								tiType = 4;
								cfinit = Gnosis.Timers_RuneCD;
							end
						elseif( w == "totemdur" ) then
							if( tonumber(spell) and tonumber(spell) > 0 and tonumber(spell) <= MAX_TOTEMS) then
								tiType = 5;
								cfinit = Gnosis.Timers_TotemDuration;
							end
						elseif( w == "resource" ) then
							if( spell == "power" ) then
								tiType = 11;
								cfinit = Gnosis.Timers_Power;
							elseif( spell == "health" ) then
								tiType = 12;
								cfinit = Gnosis.Timers_Health;
							elseif( spell == "altpower" ) then
								tiType = 13;
								cfinit = Gnosis.Timers_PowerAlternate;
							end
						elseif( w == "mine" ) then
							bSelf = true;
						elseif( w == "helpful" ) then
							bHelp = true;
						elseif( w == "harmful" ) then
							bHarm = true;
						elseif( w == "lag" ) then
							bShowLag = true;
						elseif( w == "casttime" ) then
							bShowCasttime = true;
						elseif( w == "nodur" ) then
							bNoDur = true;
						elseif( w == "not" ) then
							bNot = true;
						elseif( w == "sort" ) then
							if( spell == "minrem" ) then
								iSort = 1;
							elseif( spell == "maxrem" ) then
								iSort = 2;
							elseif( spell == "mindur" ) then
								iSort = 3;
							elseif( spell == "maxdur" ) then
								iSort = 4;
							elseif( spell == "first" ) then
								iSort = 5;
							end
						end
					end
				end

				local strFilter = "";
				strFilter = strFilter .. (bSelf and "PLAYER" or "");
				strFilter = strFilter .. (bHarm and (string_len( strFilter ) > 0 and "|HARMFUL" or "HARMFUL") or "");
				strFilter = strFilter .. (bHelp and (string_len( strFilter ) > 0 and "|HELPFUL" or "HELPFUL") or "");

				if( not spec or spec == self.iCurSpec ) then
					if( tiType ) then
						local tTimer = {
							type = tiType,
							filter = strFilter,
							spell = spell,
							showlag = bShowLag,
							showcasttime = bShowCasttime,
							nfs = nfs,
							tfs = tfs,
							recast = recast,
							staticdur = staticdur,
							zoom = zoom,
							nodur = bNoDur,
							bNot = bNot,
							cfinit = cfinit,
							sbcolor = tsbcol,
						};
						-- targeted unit
						tTimer.unit = unit and unit or conf.unit;

						-- get icon if aura and passed as id
						if( tiType == 2 and tonumber(spell) ) then
							local name_, _, icon_ = GetSpellInfo(tonumber(spell));
							if( name_ and icon_ ) then
								tTimer.spell = name_;
								tTimer.icon = icon_;
							end
						end

						-- if itemcd try to get item id and texture
						if( tiType == 3 ) then
							local _, link, _, _, _, _, _, _, _, itex = GetItemInfo( spell );
							if( link and itex ) then
								local iid = string.match( link, "|Hitem:(%d+):" );
								tTimer.iid = iid;
								tTimer.itex = itex;
							end
						end
						-- insert entry
						table_insert( value.timers, tTimer );
					elseif( iSort ) then
						-- sorting criterion
						value.iTimerSort = iSort;
					end
				end
			end

			if( #value.timers > 0 ) then
				table_insert( self.ti_fl, value );
			end
		end
	end
end

function Gnosis:ScanTimerbar( bar, fCurTime )
	local bUpdateText = false;
	local bDelayedShow = false;

	-- hide bar in/out of combat
	if( bar.conf.incombatsel == 1 or bar.conf.incombatsel == self.curincombattype or bar.conf.bUnlocked ) then
		if( bar.bBarHidden ) then
			bDelayedShow = true;
		end
	else
		if( not bar.bBarHidden ) then
			bar:Hide();
			bar.bBarHidden = true;
		end
		return;
	end

		-- valid group layout?
	if( not self:CheckGroupLayout( bar.conf ) ) then
		if( not bar.bBarHidden ) then
			bar:Hide();
			bar.bBarHidden = true;
		end
		return;
	end

	SelectedTimerInfo.duration = nil;
	for k, v in ipairs(bar.timers) do
		TimerInfo.ok = false;
		TimerInfo.bSpecial = false;

		-- selected unit exists?
		if( UnitExists(v.unit) ) then
			-- call related timer function (Timers.lua)
			v:cfinit( bar, v, TimerInfo );

			if( TimerInfo.ok and self:UnitRelationSelect( bar.conf.relationsel, TimerInfo.unit ) ) then
				-- check if cooldown is gcd
				local bTakeover = false;
				if( TimerInfo.bSpecial ) then
					bTakeover = true;
					SelectedTimerInfo.bSpecial = TimerInfo.bSpecial;
				else
					-- sorting
					SelectedTimerInfo.bSpecial = false;
					if( not bar.iTimerSort or not SelectedTimerInfo.duration ) then
						bTakeover = true;
					elseif( bar.iTimerSort == 1 and SelectedTimerInfo.endTime > TimerInfo.fin ) then	-- min remaining
						bTakeover = true;
					elseif( bar.iTimerSort == 2 and SelectedTimerInfo.endTime < TimerInfo.fin ) then	-- max remaining
						bTakeover = true;
					elseif( bar.iTimerSort == 3 and SelectedTimerInfo.duration > TimerInfo.dur ) then	-- min duration
						bTakeover = true;
					elseif( bar.iTimerSort == 4 and SelectedTimerInfo.duration < TimerInfo.dur ) then	-- max duration
						bTakeover = true;
					end
				end

				if( bTakeover ) then
					SelectedTimerInfo.castname = TimerInfo.cname;
					SelectedTimerInfo.endTime = TimerInfo.fin;
					SelectedTimerInfo.duration = TimerInfo.dur;
					SelectedTimerInfo.icon = TimerInfo.icon;
					SelectedTimerInfo.stacks = TimerInfo.stacks;
					SelectedTimerInfo.tiunit = TimerInfo.unit;
					SelectedTimerInfo.bChannel = TimerInfo.bChannel;
					SelectedTimerInfo.curtimer = v;
				end

				if( SelectedTimerInfo.bSpecial or not bar.iTimerSort ) then
					-- break if no sorting criterion given or if bar was durationless,
					-- i.e. it couldn't be sorted anyway
					break;
				end
			end
		end
	end

	if( SelectedTimerInfo.duration ) then
		if( bDelayedShow ) then
			bar.bBarHidden = nil;
			bar:Show();
		end

		-- only minor changes to bar necessary?
		if( bar.bActive and bar.castname == SelectedTimerInfo.castname and bar.tiUnit == SelectedTimerInfo.tiunit and
				bar.tiType == SelectedTimerInfo.curtimer.type and bar.bSpecial == SelectedTimerInfo.bSpecial ) then

			local dur = bar.dur and bar.dur or bar.duration;
			local bRecalcTick = (dur ~= SelectedTimerInfo.duration);

			if( SelectedTimerInfo.curtimer.nodur or SelectedTimerInfo.curtimer.bNot ) then
				return;
			elseif( SelectedTimerInfo.bSpecial ) then
				-- power
				self:SetPowerbarValue( bar, SelectedTimerInfo.endTime, SelectedTimerInfo.duration );
				return;
			end

			-- zoom?
			local bZoom = SelectedTimerInfo.curtimer.zoom and (SelectedTimerInfo.curtimer.zoom >= (SelectedTimerInfo.endTime - fCurTime));
			-- staticdur?
			local bStatic = SelectedTimerInfo.curtimer.staticdur and true;

			bar.dur = (bStatic or bZoom) and SelectedTimerInfo.duration or nil;
			bar.duration = bZoom and SelectedTimerInfo.curtimer.zoom or (bStatic and SelectedTimerInfo.curtimer.staticdur or SelectedTimerInfo.duration);
			bar.endTime = SelectedTimerInfo.endTime;

			if( bar.cbs_check ) then
				local bShowCBS = bar.duration >= (bar.endTime - fCurTime);
				if( bShowCBS ) then
					if( bar.cbs_hidden ) then
						bar.cbs:Show();
						bar.cbs_hidden = false;
					end
				else
					if( not bar.cbs_hidden ) then
						bar.cbs:Hide();
						bar.cbs_hidden = true;
					end
				end
			end

			-- stacks text
			if( bar.stacks ~= SelectedTimerInfo.stacks ) then
				bar.stacks = SelectedTimerInfo.stacks;
				bar.ctext:SetText( self:CreateCastname( bar, bar.conf, SelectedTimerInfo.castname, "" ) );
			end

			self:SetupTimerLagBox( bar, SelectedTimerInfo.curtimer.showlag,
				SelectedTimerInfo.curtimer.showcasttime, SelectedTimerInfo.castname,
				SelectedTimerInfo.curtimer.recast, bRecalcTick );
		else
			bar.nfs = SelectedTimerInfo.curtimer.nfs and SelectedTimerInfo.curtimer.nfs or bar.conf.strNameFormat;
			bar.tfs = SelectedTimerInfo.curtimer.tfs and SelectedTimerInfo.curtimer.tfs or bar.conf.strTimeFormat;

			if( SelectedTimerInfo.bSpecial or SelectedTimerInfo.curtimer.nodur ) then
				bar.bSpecial = true;
				self:SetupPowerbar( bar, SelectedTimerInfo );
			else
				bar.bSpecial = false;
				self:SetupTimerbar( bar, fCurTime, SelectedTimerInfo );
			end
		end
	elseif( self.activebars[bar.name] or bar.forcecleanup ) then
		local conf = bar.conf;
		-- bar active, fadeout or cleanup
		if( conf.bUnlocked or conf.bShowWNC or bDelayedShow ) then
			self:CleanupCastbar( bar );
			bar.forcecleanup = false;
		else
			self:PrepareCastbarForFadeout( bar, fCurTime, bar.forcecleanup );
			bar.forcecleanup = false;
		end
	end
end
