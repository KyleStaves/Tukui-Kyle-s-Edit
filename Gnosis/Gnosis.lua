Gnosis = LibStub( "AceAddon-3.0" ):NewAddon( "Gnosis", "AceConsole-3.0", "AceEvent-3.0" );
Gnosis.gui = LibStub( "AceGUI-3.0" );
Gnosis.lsm = LibStub( "LibSharedMedia-3.0", 1 );
Gnosis.smw = LibStub( "AceGUISharedMediaWidgets-1.0" );

-- local functions
local UnitName = UnitName;
local UnitIsDead = UnitIsDead;
local pairs = pairs;
local type = type;
local tonumber = tonumber;
local table_insert = table.insert;
local string_format = string.format;
local string_gsub = string.gsub;
local string_match = string.match;
local string_trim = string.trim;
local string_len = string.len;

if( Gnosis.lsm ) then
	Gnosis.lsm:Register( "statusbar", "Waterline", "Interface\\Addons\\Gnosis\\Textures\\Waterline" );
	Gnosis.lsm:Register( "font", "Desyrel", "Interface\\Addons\\Gnosis\\Fonts\\DESYREL_.ttf" );
end

function Gnosis:InitialConfig()
	self.optFrame = LibStub( "AceConfigDialog-3.0" ):AddToBlizOptions( "Gnosis", self.L["AddonName"] );
	self.optCBs = LibStub( "AceConfigDialog-3.0" ):AddToBlizOptions( "Gnosis Castbars", Gnosis.L["TabCastbars"], "Gnosis" );
	LibStub( "AceConfigDialog-3.0" ):AddToBlizOptions( "Gnosis Channeled Spells", Gnosis.L["TabChanneledSpells"], "Gnosis" );
	LibStub( "AceConfigDialog-3.0" ):AddToBlizOptions( "Gnosis Combattext/Clip test", Gnosis.L["TabCTClipTest"], "Gnosis" );
	self.optCfgs = LibStub( "AceConfigDialog-3.0" ):AddToBlizOptions( "Gnosis Configurations", Gnosis.L["TabConfig"], "Gnosis" );
end

function Gnosis:Enable( status )
	if( status ) then
		-- enable addon
		self.bGnosisEnabled = true;

		if( self.bOptionsCreated ) then
			LibStub("AceConfig-3.0"):RegisterOptionsTable( "Gnosis", self.opt );
			LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable( "Gnosis Castbars", self.opt_cbs );
			LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable( "Gnosis Channeled Spells", self.opt_css );
			LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable( "Gnosis Combattext/Clip test", self.opt_ctclip );
			LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable( "Gnosis Configurations", self.opt_configs );
		else
			LibStub("AceConfig-3.0"):RegisterOptionsTable( "Gnosis", self.optunloaded_main );
			LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable( "Gnosis Castbars", self.optunloaded );
			LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable( "Gnosis Channeled Spells", self.optunloaded );
			LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable( "Gnosis Combattext/Clip test", self.optunloaded );
			LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable( "Gnosis Configurations", self.optunloaded );
		end

		self:RegisterEvents();
		self:DefaultAllBars();

		-- blizzard castbar
		if( self.s.bHideBlizz ) then
			self:HideBlizzardCastbar( true );
		end
		-- mirror castbar
		if( self.s.bHideMirror ) then
			self:HideBlizzardMirrorCastbar( true );
		end
		-- pet/vehicle castbar
		if( self.s.bHidePetVeh ) then
			self:HideBlizzardPetCastbar( true );
		end

		-- scan table, fast lookup tables
		self:CreateCBTables();
	else
		-- disable addon
		self.bGnosisEnabled = false;

		if( self.bOptionsCreated ) then
			LibStub("AceConfig-3.0"):RegisterOptionsTable( "Gnosis", self.optdisabled );
			LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable( "Gnosis Castbars", self.optempty );
			LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable( "Gnosis Channeled Spells", self.optempty );
			LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable( "Gnosis Combattext/Clip test", self.optempty );
			LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable( "Gnosis Configurations", self.optempty );
		else
			LibStub("AceConfig-3.0"):RegisterOptionsTable( "Gnosis", self.optunloaded_main );
			LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable( "Gnosis Castbars", self.optunloaded );
			LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable( "Gnosis Channeled Spells", self.optunloaded );
			LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable( "Gnosis Combattext/Clip test", self.optunloaded );
			LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable( "Gnosis Configurations", self.optunloaded );
		end

		self:UnregisterEvents();
		self:HideAllBars();

		-- blizzard castbar
		if( self.s.bHideBlizz ) then
			self:HideBlizzardCastbar( false );
		end
		-- mirror castbar
		if( self.s.bHideMirror ) then
			self:HideBlizzardMirrorCastbar( false );
		end
		-- pet/vehicle castbar
		if( self.s.bHidePetVeh ) then
			self:HideBlizzardPetCastbar( false );
		end

		-- scan table, fast lookup castbar and timer tables
		self:ClearCBTables();
	end
end

function Gnosis:HideBlizzardCastbarIfStatusChange( status )
	if( self.s.bHideBlizz ~= status ) then
		self.s.bHideBlizz = status;
		self:HideBlizzardCastbar( self.s.bHideBlizz );
	end
end

function Gnosis:HideBlizzardCastbar( status )
	if( status ) then	-- hide castbar
		for key, value in pairs(self.tCastbarEvents) do
			if( CastingBarFrame:IsEventRegistered( value ) ) then
				table_insert( self.blizzcastbar, value );
			end
			CastingBarFrame:UnregisterEvent( value );
		end
		for key, value in pairs(self.tMiscEvents) do
			if( CastingBarFrame:IsEventRegistered( value ) ) then
				table_insert( self.blizzcastbar, value );
			end
			CastingBarFrame:UnregisterEvent( value );
		end
		if( #self.blizzcastbar > 0 ) then
			if( not self.s.bHideAddonMsgs ) then
				self:Print( Gnosis.L["MsgDisBlizCB"] );
			end
		else
			if( not self.s.bHideAddonMsgs ) then
				self:Print( Gnosis.L["MsgBlizCBIsDis"] );
			end
		end
	else	-- restore castbar events, it might not actually enable the blizzard castbar if another addon hides it
		for key, value in pairs(self.blizzcastbar) do
			CastingBarFrame:RegisterEvent( value );
		end
		if( #self.blizzcastbar > 0 ) then
			if( not self.s.bHideAddonMsgs ) then
				self:Print( Gnosis.L["MsgBlizCBRestored"] );
			end
		end
		self.blizzcastbar = {};
	end
end

function Gnosis:HideBlizzardPetCastbarIfStatusChange( status )
	if( status == nil ) then
		status = false;
	end

	if( self.s.bHidePetVeh ~= status ) then
		self.s.bHidePetVeh = status;
		self:HideBlizzardPetCastbar( self.s.bHidePetVeh );
	end
end

function Gnosis:HideBlizzardMirrorCastbarIfStatusChange( status )
	if( self.s.bHideMirror ~= status ) then
		self.s.bHideMirror = status;
		self:HideBlizzardMirrorCastbar( self.s.bHideMirror );
	end
end

function Gnosis:HideBlizzardPetCastbar( status )
	if( status ) then	-- hide pet castbar
		for key, value in pairs(self.tCastbarEvents) do
			if( PetCastingBarFrame:IsEventRegistered( value ) ) then
				table_insert( self.petcastbar, value );
			end
			PetCastingBarFrame:UnregisterEvent( value );
		end
		for key, value in pairs(self.tMiscEvents) do
			if( PetCastingBarFrame:IsEventRegistered( value ) ) then
				table_insert( self.petcastbar, value );
			end
			PetCastingBarFrame:UnregisterEvent( value );
		end
		if( #self.petcastbar > 0 ) then
			if( not self.s.bHideAddonMsgs ) then
				self:Print( Gnosis.L["MsgDisPetCB"] );
			end
		else
			if( not self.s.bHideAddonMsgs ) then
				self:Print( Gnosis.L["MsgPetCBIsDis"] );
			end
		end
	else	-- restore pet castbar events, it might not actually enable the blizzard castbar if another addon hides it
		for key, value in pairs(self.petcastbar) do
			PetCastingBarFrame:RegisterEvent( value );
		end
		if( #self.petcastbar > 0 ) then
			if( not self.s.bHideAddonMsgs ) then
				self:Print( Gnosis.L["MsgPetCBRestored"] );
			end
		end
		self.petcastbar = {};
	end
end

function Gnosis:HideBlizzardMirrorCastbar( status )
	if( status ) then	-- hide castbar
		for key, value in pairs(self.tMirrorEvents) do
			if( UIParent:IsEventRegistered( value ) ) then
				table_insert( self.blizzmirrorcastbar, value );
			end
			UIParent:UnregisterEvent( value );
		end
		if( #self.blizzmirrorcastbar > 0 ) then
			if( not self.s.bHideAddonMsgs ) then
				self:Print( Gnosis.L["MsgDisMirrCB"] );
			end
		else
			if( not self.s.bHideAddonMsgs ) then
				self:Print( Gnosis.L["MsgMirrCBIsDis"] );
			end
		end
	else	-- restore mirror castbar events, it might not actually enable the blizzard mirror castbar if another addon hides it
		for key, value in pairs(self.blizzmirrorcastbar) do
			UIParent:RegisterEvent( value );
		end
		if( #self.blizzmirrorcastbar > 0 ) then
			if( not self.s.bHideAddonMsgs ) then
				self:Print( Gnosis.L["MsgMirrCBRestored"] );
			end
		end
		self.blizzmirrorcastbar = {};
	end
end

function Gnosis:OnInitialize()
	local unitkey = UnitName( "player" ) .. " - " .. GetRealmName();
	if( GnosisDB and GnosisDB.profiles and GnosisDB.profiles[unitkey] and
		GnosisDB.profileKeys and GnosisDB.profileKeys[unitkey] ) then
		-- copy to new char only based profile (to heavily cut down on mem usage)
		if( not GnosisChar ) then GnosisChar = {}; end
		if( not GnosisChar.profileKeys ) then GnosisChar.profileKeys = {}; end
		if( not GnosisChar.profiles ) then GnosisChar.profiles = {}; end
		GnosisChar.profileKeys[unitkey] = unitkey;
		GnosisChar.profiles[unitkey] = self:deepcopy( GnosisDB.profiles[unitkey] );
		GnosisDB.profileKeys[unitkey] = nil;
		GnosisDB.profiles[unitkey] = nil;

		-- fully remove from db if empty
		if( self:tsize( GnosisDB.profiles ) == 0 ) then
			GnosisDB.profiles = nil;
		end
		if( self:tsize( GnosisDB.profileKeys ) == 0 ) then
			GnosisDB.profileKeys = nil;
		end
	end

	self.db = LibStub("AceDB-3.0"):New( "GnosisChar", defaults );
	self.s = self.db.profile;

	self:RegisterChatCommand( "gnosis", "HandleChatCommand" );
end

function Gnosis:SetupHooks()
	-- tradeskill hooking
	hooksecurefunc( "DoTradeSkill", function( index, num )
			Gnosis.bNewTradeSkill = tonumber(num) and true or nil;
			Gnosis.iLastTradeSkillCnt = tonumber(num);
		end );

	hooksecurefunc( "CloseTradeSkill", function()
			Gnosis.bNewTradeSkill = nil;
			Gnosis.iLastTradeSkillCnt = nil;
			Gnosis:CloseAllTradeskillBars();
		end );

	-- SetCVar hook
	hooksecurefunc( "SetCVar", function( cv, val )
			if( cv == "uiscale" ) then
				Gnosis:UIScaleUpdate();		-- called when changing ui scale in the blizzard menu
			end
		end );
end

function Gnosis:OnEnable()
	-- set init values
	self:StartupVariables();

	-- setup hooks
	self:SetupHooks();

	-- load localization
	if( not self.s.strLocale and self.LSet[GetLocale()] ) then
		self.s.strLocale = GetLocale();
	elseif( not self.s.strLocale ) then
		self.s.strLocale = "default";
	end
	self:SetupLocale();

	-- basic tables
	self:OptCreateBasicTables();

	-- set default saved variables
	if( self.s.bAddonEn == nil ) then
		self.s.optver = self.optver;
	end
	for key, value in pairs( self.tDefaults ) do
		if( self.s[key] == nil ) then
			self.s[key] = value;
		end
	end

	if( not self.s.bHideAddonMsgs ) then
		self:Print( self.title .. " " .. Gnosis.L["MsgLoaded"] .. " " .. (self.s.bAddonEn and Gnosis.L["MsgEn"] or Gnosis.L["MsgDis"]) );
	end

	-- check castbar options
	self:CheckStoredCastbarOptions();

	-- first start?
	local bFirstStart = self:CheckForFirstStart();

	-- create saved castbars
	self:InitialCreateCastbars();

	-- add channeled spells to table
	self:SetupChanneledSpellsTable();

	-- create castbar options table
	if( self.s.bAutoCreateOptions or bFirstStart ) then
		self.bOptionsCreated = true;

		self:CreateCastbarsOpt();
		self:CreateChannelSpellsOpt();
		self:OptCreateCTpage();
		self:OptCreateConfigurations();
	else
		self.bOptionsCreated = false;
	end

	-- enable/disable addon
	self:InitialConfig();
	self:Enable( self.s.bAddonEn );

	-- get player GUID
	self.guid = UnitGUID( "player" );
end

function Gnosis:CreateOptions()
	if( not self.bOptionsCreated ) then
		self.bOptionsCreated = true;
		self:CreateCastbarsOpt();
		self:CreateChannelSpellsOpt();
		self:OptCreateCTpage();
		self:OptCreateConfigurations();
	end

	if( self.bGnosisEnabled ) then
		LibStub("AceConfig-3.0"):RegisterOptionsTable( "Gnosis", self.opt );
		LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable( "Gnosis Castbars", self.opt_cbs );
		LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable( "Gnosis Channeled Spells", self.opt_css );
		LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable( "Gnosis Combattext/Clip test", self.opt_ctclip );
		LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable( "Gnosis Configurations", self.opt_configs );
	else
		LibStub("AceConfig-3.0"):RegisterOptionsTable( "Gnosis", self.optdisabled );
		LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable( "Gnosis Castbars", self.optempty );
		LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable( "Gnosis Channeled Spells", self.optempty );
		LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable( "Gnosis Combattext/Clip test", self.optempty );
		LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable( "Gnosis Configurations", self.optempty );
	end
end

function Gnosis:HandleChatCommand( cmd )
	local subcmd = string_match( cmd, "(%w+)" );
	if( subcmd and subcmd == "reanchor" ) then
		Gnosis:UIScaleUpdate();
	elseif( subcmd and subcmd == "load" ) then
		subcmd = string_match( cmd, "load (.+)" );
		subcmd = subcmd and string_trim( subcmd );
		if( subcmd and string_len( subcmd ) > 0 ) then
			self:LoadConfig( subcmd, false, true, false, false );
		end
	else
		InterfaceOptionsFrame_OpenToCategory( self.optFrame );
	end
end

function Gnosis:RecreateAllBars()
	self:HideAllBars();

	self:cleartable( self.castbars );
	self:CheckStoredCastbarOptions();
	self:InitialCreateCastbars();
end

function Gnosis:DefaultAllBars()
	for key, value in pairs( self.s.cbconf ) do
		self:SetBarParams( key );
	end
end

function Gnosis:HideAllBars()
	self:cleartable( self.activebars );
	self:cleartable( self.fadeoutbars );

	for key, value in pairs( self.castbars ) do
		value:Hide();
	end
end

function Gnosis:RegisterEvents()
	local key, value;

	for key, value in pairs(Gnosis.tCastbarEvents) do
		self:RegisterEvent( value );
	end

	for key, value in pairs(Gnosis.tMiscEvents) do
		self:RegisterEvent( value );
	end

	for key, value in pairs(Gnosis.tMirrorEvents) do
		self:RegisterEvent( value );
	end

	for key, value in pairs(Gnosis.tSwingEvents) do
		self:RegisterEvent( value );
	end
end

function Gnosis:UnregisterEvents()
	local key, value;

	for key, value in pairs(Gnosis.tCastbarEvents) do
		self:UnregisterEvent( value );
	end

	for key, value in pairs(Gnosis.tMiscEvents) do
		self:UnregisterEvent( value );
	end

	for key, value in pairs(Gnosis.tMirrorEvents) do
		self:UnregisterEvent( value );
	end

	for key, value in pairs(Gnosis.tSwingEvents) do
		self:UnregisterEvent( value );
	end
end

function Gnosis:RemoveChanneledSpell( name )
	if( self.s.channeledspells[name] ~= nil ) then
		 self.s.channeledspells[name] = nil;
		 self:CreateChannelSpellsOpt();
	end
end

function Gnosis:AddChanneledSpellByName( name, tickcount, bdoaddticks, bars, binit, baoe, school, bheal, iUpdate, idhs, bcths )
	if( name ) then
		if( bheal ) then
			if( baoe ) then
				tx = "col<0,1,0>(spellname) [tickscrits] +eh <oh> col<pre>dps HPShittext< Hits>crittext< Crits>ticktext< Ticks>";
			else
				tx = "col<0,1,0>(spellname - col<1,1,1>col<class>targetcol<cpre>col<pre>col<0,1,0>) [tickscrits] +eh <oh> col<pre>dps HPShittext< Hits>crittext< Crits>ticktext< Ticks>";
			end
		else
			if( school ) then
				tx = "col<" .. school .. ">dmg col<pre>col<1,1,0>(spellname) [tickscrits]col<pre>clipped dps DPScliptext<(Clipped) >hittext< Hits>crittext< Crits>ticktext< Ticks>";
			else
				tx = "dmg col<1,1,0>(spellname) [tickscrits]col<pre>clipped dps DPScliptext<(Clipped) >hittext< Hits>crittext< Crits>ticktext< Ticks>";
			end
		end

		local bStoredcliptest = false;
		local bStoredcombattext = false;

		-- update existing
		if( iUpdate and self.s.channeledspells[name] and (self.s.channeledspells[name].iupdate == nil or self.s.channeledspells[name].iupdate < iUpdate) ) then
			bStoredcliptest = self.s.channeledspells[name] and self.s.channeledspells[name].bcliptest or false;
			bStoredcombattext = self.s.channeledspells[name] and self.s.channeledspells[name].bcombattext or false;
			self.s.channeledspells[name] = nil;
		end

		-- do not overwrite (possibly user edited) entry
		if( self.s.channeledspells[name] == nil ) then
			self.s.channeledspells[name] = {
				ben = true,
				ticks = tickcount,
				baddticks = bdoaddticks,
				bars = bars,
				binit = binit,
				baoe = baoe,
				bcliptest = bStoredcliptest,
				bcombattext = bStoredcombattext,
				bicon = true,
				bsticky = true,
				fontsizeclip = 0,
				fontsizenclip = 0,
				ctstring = tx,
				bhidenonplayer = bdoaddticks,
				hastespell = idhs,
				basecasttime = bcths,
				iupdate = iUpdate,
			};
		end
	end
end

function Gnosis:AddChanneledSpellById( id, tickcount, bdoaddticks, bars, binit, baoe, school, bheal, iUpdate, idhs, bcths )
	local name = GetSpellInfo( id );

	self:AddChanneledSpellByName( name, tickcount, bdoaddticks, bars, binit, baoe, school, bheal, iUpdate, idhs, bcths );
end

function Gnosis:SetupChanneledSpellsTable()
	-- ( spellid, #ticks, addticks, #shown ticks, first tick instant, multi mob (therefore no clipping detection), spellschool, isheal, upgrade_num, spellid to compute current haste, basecasttime of that spell )

	-- removed drain mana, removed compatability to toc < 40000
	local _, _, _, toc = GetBuildInfo();
	if( toc >= 40000 ) then
		-- priest
		self:AddChanneledSpellById( 15407, 3, false, 3, false, false, "shadow", false, 1, 2061, 1500 );	-- mind flay
		self:AddChanneledSpellById( 32000, 5, false, 5, false, true, "shadow", false, 1, 2061, 1500 ); 	-- mind sear
		self:AddChanneledSpellById( 47540, 3, false, 2, true, false, "holy", true, 1, 2061, 1500 );		-- penance, first tick instant
		self:AddChanneledSpellById( 64843, 4, true, 4, false, true, "holy", true, 2, 2061, 1500 );		-- divine hymn
		self:AddChanneledSpellById( 64901, 4, true, 4, false, true, "holy", false, 1, 2061, 1500 ); 	-- hymn of hope
			-- flash heal (2061), base cast time 1.5s

		-- mage
		self:AddChanneledSpellById( 10, 8, false, 8, false, true, "frost", false, 1, 118, 2000 );		-- blizzard
		self:AddChanneledSpellById( 5143, 5, false, 5, false, false, "arcane", false, 1, 118, 2000 );	-- arcane missiles
		self:AddChanneledSpellById( 12051, 5, false, 4, true, false, "arcane", false, 1, 118, 2000 );	-- evocation
			-- polymorph (118), base cast time 2.0s

		-- warlock
		self:AddChanneledSpellById( 1120, 5, true, 5, false, false, "shadow", false, 1, 6201, 3000 );	-- drain soul
		self:AddChanneledSpellById( 689, 3, false, 3, false, false, "shadow", false, 1, 6201, 3000 );	-- drain life
		self:AddChanneledSpellById( 4629, 4, false, 4, false, true, "fire", false, 1, 6201, 3000 );		-- rain of fire
		self:AddChanneledSpellById( 1949, 15, false, 15, false, true, "fire", false, 1, 6201, 3000 );	-- hellfire
		self:AddChanneledSpellById( 755, 3, false, 3, false, false, "shadow", false, 1, 6201, 3000 );	-- health funnel
		self:AddChanneledSpellById( 79268, 3, true, 3, false, false, "shadow", true, 3, 6201, 3000 );	-- soul harvest
			-- create healthstone (6201), base cast time 3.0s

		-- druid
		self:AddChanneledSpellById( 740, 4, false, 4, false, true, "nature", true, 2, 20484, 2000 );	-- tranquility
		self:AddChanneledSpellById( 16914, 10, false, 10, false, true, "nature", false, 1, 20484, 2000 );-- hurricane
			-- rebirth (20484), base cast time 2.0s
	end
end

function Gnosis:CreateColorString( r, g, b, a )
	if( not (tonumber( r ) and tonumber( g ) and tonumber( b ) and tonumber ( a )) ) then
		return "";
	end

	local str = string_format( "%.2f, %.2f, %.2f, %.2f", r, g, b, a );
	return str;
end

function Gnosis:GetCoordinatesFromString( str )
	str = str .. ",0.0,0.0";	-- append safety net, also default coordinate

	local x, y = string_match( str, ".-([%+%-%.%d]+).-([%+%-%.%d]+)" );

	if( not(x and y and tonumber(x) and tonumber(y)) ) then
		return 0.0, 0.0;
	else
		return tonumber(x), tonumber(y);
	end
end

function Gnosis:ScreenPercentageToString( px, py )
	local uis = UIParent:GetEffectiveScale();
	local xm, ym = GetScreenWidth(), GetScreenHeight();
	return string_format( "%.2f, %.2f", px * xm * uis, py * ym * uis );
end

function Gnosis:StringToScreenPercentage( str )
	str = str .. ",0.0,0.0";	-- append safety net, also default coordinate

	local x, y = string_match( str, ".-([%+%-%.%d]+).-([%+%-%.%d]+)" );

	if( not(x and y and tonumber(x) and tonumber(y)) ) then
		return 0.0, 0.0;
	else
		local uis = UIParent:GetEffectiveScale();
		local xm, ym = GetScreenWidth(), GetScreenHeight();
		return x / (xm*uis), y / (ym*uis);
	end
end

function Gnosis:GetColorsFromString( str, dst )
	str = str .. ",1.0,1.0,1.0,1.0";	-- append safety net (also default if illegal r,g,b values given
	local r, g, b, a = string_match(
		str,
		".-([-+]?[0-9]*%.?[0-9]+).-([-+]?[0-9]*%.?[0-9]+).-([-+]?[0-9]*%.?[0-9]+).-([-+]?[0-9]*%.?[0-9]+)"
	);

	r, g, b, a = tonumber( r ), tonumber( g ), tonumber( b ), tonumber( a );
	if( not a ) then
		r, g, b, a = nil, nil, nil, nil;
	end

	if( dst and r ) then
		dst.r, dst.g, dst.b, dst.a = r, g, b, a;
	end

	return r, g, b, a;
end

local RCS_strClass = "";
local function ReplaceColorsStrings_GSubFunc( sub )
	if( sub == "pre" or sub == "prev" ) then
		return "|r";
	elseif( sub == "cpre" ) then
		return RCS_strClass and "|r" or "";
	elseif( sub == "class" and not RCS_strClass ) then
		return "";
	end

	local colstr = (Gnosis.colSchools[sub] and Gnosis.colSchools[sub] or (
		(sub == "class" and RCS_strClass) and Gnosis.colClasses[RCS_strClass] or sub
		)) .. ",1.0,1.0,1.0,1.0";
	local r, g, b, a = string_match(
		colstr,".-([-+]?[0-9]*%.?[0-9]+).-([-+]?[0-9]*%.?[0-9]+).-([-+]?[0-9]*%.?[0-9]+).-([-+]?[0-9]*%.?[0-9]+)"
	);
	return string_format(
		"|c%02x%02x%02x%02x",
		tonumber( a ) * 255,
		tonumber( r ) * 255,
		tonumber( g ) * 255,
		tonumber( b ) * 255
	);
end

function Gnosis:ReplaceColorStrings( str, strClass )
	-- new line
	str = string_gsub( str, "\\n", "\n" );

	RCS_strClass = strClass;
	return string_gsub(
		str,
		"col<([^>]*)>",
		ReplaceColorsStrings_GSubFunc,
		10
	);
end

function Gnosis:GenerateCombattext( cc, cs, bClip )
	-- substitute strings
	local str = cs.ctstring;
	local sub;
	local clipped, hit, crit, tick;

	-- spell school colors, format is col<r,g,b[,a]> or col<spellschool>
		-- e.g. col<1.0,0.5,0.5,1.0>; col<shadow>
	str = string_gsub( str, "col<prev>", "|r" );
	str = self:ReplaceColorStrings( str, cc.class );

	-- clipped text
	clipped = string_match( str, "cliptext<(.-)>" );
	clipped = clipped and clipped or "";
	str = string_gsub( str, "cliptext<(.-)>", "" );
	hit = string_match( str, "hittext<(.-)>" );
	hit = hit and hit or "";
	str = string_gsub( str, "hittext<(.-)>", "" );
	crit = string_match( str, "crittext<(.-)>" );
	crit = crit and crit or "";
	str = string_gsub( str, "crittext<(.-)>", "" );
	tick = string_match( str, "ticktext<(.-)>" );
	tick = tick and tick or "";
	str = string_gsub( str, "ticktext<(.-)>", "" );

	-- hits, crits, ticks, dmg, dps, clipped
	local dpstime = 1000 / (cc.freqtest and min(cc.freqtest-cc.starttime,cc.duration) or cc.duration);
	local tickscrits = string_format( "%d%s", cc.ticks, tick );
	if( cc.crits > 0 ) then tickscrits = string_format( "%s, %d%s", tickscrits, cc.crits, crit ); end

	str = string_gsub( str, "tickscrits", tickscrits );
	str = string_gsub( str, "spellname", string_format( "%s", cc.spell ) );
	str = string_gsub( str, "hits", string_format( "%d", cc.hits ) .. hit );
	str = string_gsub( str, "crits", string_format( "%d", cc.crits ) .. crit );
	str = string_gsub( str, "ticks", string_format( "%d", cc.ticks ) .. tick );
	str = string_gsub( str, "dmg", string_format( "%d", cc.dmg ) );
	str = string_gsub( str, "dps", string_format( "%d", cc.dmg * dpstime ) );
	str = string_gsub( str, "eh", string_format( "%d", cc.eh ) );
	str = string_gsub( str, "oh", string_format( "%d", cc.oh ) );
	str = string_gsub( str, "target", cc.target or "" );
	if( bClip )	then
		str = string_gsub( str, "clipped", clipped );
	else
		str = string_gsub( str, "clipped", "" );
	end

	-- string ready for combat text output
	local strTex = nil;
	local bSticky = nil;
	if( cs.bicon ) then strTex = cc.texture; end
	if( cs.bsticky and bClip ) then bSticky = true; end

	-- font size
	local fs = nil;
	if( bClip and cs.fontsizeclip > 0 ) then
		fs = cs.fontsizeclip;
	elseif( not bClip and cs.fontsizenclip > 0 ) then
		fs = cs.fontsizenclip;
	end

	if( self.s.ct.addon == "MSBT" and MikSBT and MikSBT.IsModDisabled() == nil ) then
		MikSBT.DisplayMessage( str, MikSBT.DISPLAYTYPE_OUTGOING, bSticky, nil, nil, nil, fs, nil, nil, strTex );
	elseif( self.s.ct.addon == "SCT" and SCT and (cc.type or SCTD) ) then
		SCT:DisplayText( str, nil, bSticky, "damage", cc.type and SCT.FRAME2 or SCT.FRAME3, nil, nil, strTex );
	elseif( self.s.ct.addon == "Parrot" and Parrot ) then
		Parrot:ShowMessage( str, "Outgoing", bSticky, 1, 1, 1, nil, fs, nil, strTex );
	elseif( self.s.ct.addon == "Blizz" and tostring(SHOW_COMBAT_TEXT) ~= "0" ) then
		CombatText_AddMessage( str, CombatText_StandardScroll, 1, 1, 1, bSticky, false );
	end
end

-- clip test
function Gnosis:SetupChannelData( fCurTime, name, startTime, endTime, texture )
	local cc = {};
	local cs = self.s.channeledspells[name];

	if( cs and cs.ben and (cs.bcliptest or cs.bcombattext) ) then
		local fTick = (endTime - startTime) / (cs.binit and (cs.ticks-1) or cs.ticks);

		cc.spell = name;
		cc.ftick = fTick;
		cc.endtime = endTime;
		cc.starttime = startTime;
		cc.duration = endTime - startTime;
		cc.maxticks = cs.ticks;
		cc.testtime = endTime + self.s.wfcl;
		cc.pushback = 0;
		cc.dmg = 0;
		cc.eh = 0;
		cc.oh = 0;
		cc.ticks = 0;
		cc.hits = 0;
		cc.crits = 0;
		cc.bcliptest = cs.bcliptest;
		cc.baeo = cs.baoe;
		cc.texture = texture;
		cc.target = self.strLastTarget;
		cc.class = self.strLastTargetClass;

		if( self.curchannel ) then
			self.nextchannel = cc;
		else
			self.curchannel = cc;
		end
	end
end

function Gnosis:RequestClipTest( fCurTime )
	local cc, nc = self.curchannel, self.nextchannel;
	if( cc ) then
		if( nc and cc.spell == nc.spell ) then
			-- same spell, make sure ticks of spells don't overlap cliptest
			cc.freqtest = cc.freqtest and min(cc.freqtest,fCurTime) or fCurTime;
			cc.fforcedtest = cc.fforcedtest and min(cc.fforcedtest,nc.starttime + min( self.s.wfcl, nc.ftick )) or (nc.starttime + min( self.s.wfcl, nc.ftick ));
		else
			cc.freqtest = cc.freqtest and min(cc.freqtest,fCurTime) or fCurTime;
			cc.fforcedtest = cc.fforcedtest and min(cc.fforcedtest,fCurTime + self.s.wfcl) or (fCurTime + self.s.wfcl);
		end
	end
end

function Gnosis:ClipTest( fCurTime )
	local cc, nc = self.curchannel, self.nextchannel;

	if( cc ) then
		local cs = self.s.channeledspells[cc.spell];
		local bClip, bOutput = false, false;

		if( (not cs.baoe and cc.ticks == cc.maxticks) or fCurTime >= cc.testtime ) then
			-- check spell out, no clipping
			bOutput = true;
		elseif( cs.bcliptest and cc.fforcedtest and fCurTime >= cc.fforcedtest ) then	-- clip test requested
			-- test for clipping
		 	if( (not cs.baoe) and (((cc.ticks+1) * cc.ftick + cc.starttime) - cc.freqtest) <= self.s.ctt ) then
		 		-- probably unintentional clip, test for spell pushback
		 		if( ((cc.ticks+1) * cc.ftick) > (cc.duration - cc.pushback) ) then
		 			-- clipping impossible due to spell pushback
		 		else
		 			-- unintentional clipping detected, do not output as clip if player had no target when clip test was requested
					local tarname = UnitName( "target" );
					if( tarname and not UnitIsDead( "target" ) ) then
						bClip = true;
					end
		 		end
		 	end
		 	bOutput = true;
 		end

		if( bOutput ) then
			-- play clip sound and output to combat text
		  	if( bClip and cs.bcliptest ) then
		  		if( self.s.ct.bsound and self.s.ct.sound ) then
		  			PlaySound( self.s.ct.sound );
		  		end
		  		if( self.s.ct.bmusic and self.s.ct.music ) then
		  			PlaySoundFile( self.lsm:Fetch( "sound", Gnosis.s.ct.music ) );
		  		end
		 	end

		 	if( cs.bcombattext and cc.ticks > 0 ) then
		 		self:GenerateCombattext( cc, cs, bClip );
		 	end

		 	-- done, next channeled spell in queue
		 	self.curchannel = nil;
		 	self.curchannel = self.nextchannel;
		 	self.nextchannel = nil;
		end

	elseif( nc ) then
		self.curchannel = nil;
		self.curchannel = self.nextchannel;
		self.nextchannel = nil;
	end
end

function Gnosis:AddBasicCastbar( name, unit, movefactor_y, movefactor_x )
	local fScale = UIParent:GetScale();
	local cfg;

	if( self.s.cbconf[name] ) then
		self:RemoveCastbar( name );
	end

	self:OptCreateNewCastbar( name, unit );

	cfg = self.s.cbconf[name];
	cfg.anchor.py = cfg.anchor.py + movefactor_y * (self.tCastbarDefaults.height/GetScreenHeight() + 0.01) * fScale;
	cfg.anchor.px = cfg.anchor.px + movefactor_x * (self.tCastbarDefaults.height/GetScreenHeight()*2.5 + self.tCastbarDefaults.width/GetScreenWidth() + 0.01) * fScale;
	self:AnchorBar( name );
end

function Gnosis:CreateBasicCastbarSet()
	self:AddBasicCastbar( self.L["CBSetPlayer"], "player", 2, 0 );
	self:AddBasicCastbar( self.L["CBSetTarget"], "target", 1, 0 );
	self:AddBasicCastbar( self.L["CBSetFocus"], "focus", 0, 0 );
	self:AddBasicCastbar( self.L["CBSetPet"], "pet", -2, 0 );
	self:AddBasicCastbar( self.L["CBSetMirror"], "mirror", 4, 0 );
end

function Gnosis:CreateMadnessSet()
	local i;
	for i = 1, 99 do
		self:AddBasicCastbar( "Player " .. i, "player", 10-i%20, -2+floor(i/20) );
	end
end

function Gnosis:CreateGCDSwingTimers()
	self:AddBasicCastbar( self.L["CBSetGCD"], "gcd", -3, 0 );
	self:AddBasicCastbar( self.L["CBSetSwing"], "smr", -4, 0 );

	local cfg = self.s.cbconf[self.L["CBSetGCD"]];
	cfg.height = 3;
	cfg.border = 0;
	cfg.colBar = { 0.85, 0.85, 0.85, 0.70 };
	cfg.strNameFormat = "";
	cfg.strTimeFormat = "";
	cfg.iconside = "NONE";
	self:SetBarParams( self.L["CBSetGCD"] );

	cfg = self.s.cbconf[self.L["CBSetSwing"]];
	cfg.height = 3;
	cfg.border = 0;
	cfg.colBar = { 0.85, 0.85, 0.85, 0.70 };
	cfg.strNameFormat = "";
	cfg.strTimeFormat = "r<1>";
	cfg.fontsize_timer = 14;
	cfg.coord.casttime.y = -6;
	cfg.iconside = "NONE";
	self:SetBarParams( self.L["CBSetSwing"] );
end

function Gnosis:RedoLocalization()
	self:SetupLocale();
	-- recreate tables
	self:OptCreateBasicTables();
	self:CreateCastbarsOpt();
	self:CreateChannelSpellsOpt();
	self:OptCreateCTpage();
	self:OptCreateConfigurations();

	local hide = self.s.bHideAddonMsgs;
	self.s.bHideAddonMsgs = true;
	-- reload most of the addon for localization
	self:Enable( false );
	self:Enable( true );
	self.s.bHideAddonMsgs = hide;
end

function Gnosis:tsize( t )
	local i = 0;
	if( t and type( t ) == "table" ) then
		for k, v in pairs( t ) do
			i = i + 1;
		end
	end

	return i;
end

function Gnosis:CheckForFirstStart( bForce )
	if( self.s.bAddonEn and (bForce or ((not Gnosis.s) or self:tsize( Gnosis.s.cbconf ) == 0)) ) then
		-- create window
		local f = self.gui:Create( "Window" );

		local _, uc = UnitClass( "player" );
		if( UnitLevel( "player" ) == 1 or (uc == "DEATHKNIGHT" and UnitLevel( "player" ) == 55) ) then
			-- probably newly created char, don't release widget for OnClose callback,
			-- otherwise window will be gone after the intro sequence
			f:SetCallback( "OnClose", function( w ) end );
		else
			f:SetCallback( "OnClose", function( w ) Gnosis.gui:Release( w ); end );
		end

		f:SetTitle( Gnosis.L["AddonName"] );
		f:SetStatusText( Gnosis.L["IfCWAction"] );
		f:SetLayout( "Flow" );
		f:SetWidth( 500 );
		f:SetFullHeight( true );

		local h1 = self.gui:Create( "Heading" );
		if( (not Gnosis.s) or self:tsize( Gnosis.s.cbconf ) == 0 ) then
			h1:SetText( Gnosis.L["IfNoCBs"] );
		end
		h1.width = "fill";
		f:AddChild( h1 );

		local msg = self.gui:Create( "Label" );
		msg:SetText( Gnosis.L["IfCCSString"] );
		msg:SetFullWidth( true );
		f:AddChild( msg );

		local btnLCS = self.gui:Create( "Button" );
		btnLCS:SetWidth( 230 );
		btnLCS:SetText( Gnosis.L["IfCCSetup"] );
		btnLCS:SetCallback( "OnClick", function()
				Gnosis:CreateBasicCastbarSet();
				Gnosis:HideBlizzardCastbarIfStatusChange( true );
				Gnosis:HideBlizzardMirrorCastbarIfStatusChange( true );
				Gnosis:HideBlizzardPetCastbarIfStatusChange( true );
			end
		);
		f:AddChild( btnLCS );

		local btnLCS = self.gui:Create( "Button" );
		btnLCS:SetWidth( 230 );
		btnLCS:SetText( Gnosis.L["IfCCTimers"] );
		btnLCS:SetCallback( "OnClick", function()
				Gnosis:CreateGCDSwingTimers();
			end
		);
		f:AddChild( btnLCS );

		if( self:tsize( GnosisConfigs ) > 0 ) then
			local h2 = self.gui:Create( "Heading" );
			h2:SetText( Gnosis.L["IfConfigs"] );
			h2.width = "fill";
			f:AddChild( h2 );

			local msg2 = self.gui:Create( "Label" );
			msg2:SetText( Gnosis.L["IfLFConigs"] );
			msg2:SetFullWidth( true );
			f:AddChild( msg2 );

			for key, value in pairs(GnosisConfigs) do
				local butCfg = self.gui:Create( "Button" );
				butCfg:SetWidth( 230 );
				butCfg:SetText( key );
				butCfg:SetCallback( "OnClick", function()
						Gnosis:LoadConfig( key, true, true, true, true );
					end
				);
				f:AddChild( butCfg );
			end
		end

		local h3 = self.gui:Create( "Heading" );
		h3:SetText( "" );
		h3.width = "fill";
		f:AddChild( h3 );

		local btnGUI = self.gui:Create( "Button" );
		btnGUI:SetWidth( 230 );
		btnGUI:SetText( Gnosis.L["IfOpenGUI"] );
		btnGUI:SetCallback( "OnClick", function()
				InterfaceOptionsFrame_OpenToCategory( Gnosis.optFrame );
			end
		);
		f:AddChild( btnGUI );

		self.IntroFrame = f;

		return true;
	end

	return false;
end
