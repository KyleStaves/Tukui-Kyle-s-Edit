--Localization.zhCN.lua , by Onlyfly

if ( GetLocale() == "zhCN" ) then

TomTomLocals = {
	["%s (%.2f, %.2f)"] = "%s (%.2f, %.2f)",
	["%s yards away"] = "%s 码距离",
	["Accept waypoints from guild and party members"] = "接受来自工会或团队的路径点",
	["Allow control-right clicking on map to create new waypoint"] = "允许使用右键点击地图来创建新的路径点",
    ["Alpha"] = "透明度",
	["Are you sure you would like to remove ALL TomTom waypoints?"] = "你确认要删除所有 TomTom 路径点吗?",
	["Arrow colors"] = "箭头颜色",
	["Arrow display"] = "箭头显示",
	["Ask for confirmation on \"Remove All\""] = "\"全部删除\" 时进行确认",
	["Automatically set waypoint arrow"] = "自动设置路径点箭头",
	["Background color"] = "背景色",
	["Bad color"] = "错误颜色",
	["Block height"] = "模块高度",
	["Block width"] = "模块宽度",
	["Border color"] = "边框颜色",
	["Clear waypoint distance"] = "清空路径点距离",
	["Clear waypoint from crazy arrow"] = "清除路径点箭头",
	["Coordinate Block"] = "坐标模块",
	["Coordinate Accuracy"] ="坐标精确度",  --new+++in tomtom_config.lua  line 80
	["Coordinates can be displayed as simple XX, YY coordinate, or as more precise XX.XX, YY.YY.  This setting allows you to control that precision"] = "坐标模块可以显示简单的如 XX，YY 坐标，同样的他也可以显示如 XX.XX, YY.YY 的精确坐标。",
	["Ctrl+Right Click To Add a Waypoint"] = "单击 Ctrl+右键 添加一个路径点",
	["Cursor Coordinates"] = "鼠标坐标",
	["Cursor coordinate accuracy"] = "鼠标精确坐标",
	["Create note modifier"] = "创建快捷组合键",  -- new
	["Display Settings"] = "显示设置",
	["Display waypoints from other zones"] = "从其他地区显示路径点",
	["Enable coordinate block"] = "启用坐标模块",
	["Enable floating waypoint arrow"] = "启用浮动路径箭头",
	["Enable minimap waypoints"] = "启用小地图路径点",
	["Enable mouseover tooltips"] = "启用鼠标提示",
	["Enable showing cursor coordinates"] = "启用显示鼠标坐标",
	["Enable showing player coordinates"] = "启用显示玩家坐标",
	["Enable the right-click contextual menu"] = "启用右键菜单", --？
	["Enable world map waypoints"] = "启用世界地图路径点",
	["Enables a floating block that displays your current position in the current zone"] = "启用浮动的模块以显示你在当前区域的当前位置",
	["Enables a menu when right-clicking on a waypoint allowing you to clear or remove waypoints"] = "当右键点击一个路径点时显示菜单以清除或移动路径点",
	["Enables a menu when right-clicking on the waypoint arrow allowing you to clear or remove waypoints"] = "当右键点击路径点箭头时显示菜单以清除或移动路径点",
	["Font size"] = "字体大小",
	["Found %d possible matches for zone %s.  Please be more specific"] = "Found %d possible matches for zone %s.  Please be more specific",
	["Found multiple matches for zone '%s'.  Did you mean: %s"] = "Found multiple matches for zone '%s'.  Did you mean: %s",
	["General Options"] = "综合选项",
	["Good color"] = "正确颜色",
	["Lock coordinate block"] = "锁定坐标模块",
	["Lock waypoint arrow"] = "锁定路径箭头",
	["Locks the coordinate block so it can't be accidentally dragged to another location"] = "锁定坐标模块以防止意外拖动",
	["Locks the waypoint arrow, so it can't be moved accidentally"] = "锁定路径箭头，防止意外拖动",
	["Middle color"] = "中间颜色",
	["Minimap"] = "小地图",
	["No"] = "否",
	["Options profile"] = "选项配置",
	["Options that alter the coordinate block"] = "坐标模块选项",
	["Player Coordinates"] = "玩家坐标",
	["Player coordinate accuracy"] = "玩家精确坐标",
	["Profile Options"] = "配置选项",
	["Prompt before accepting sent waypoints"] = "发送，接受路径点前进行提示",
	["Remove all waypoints"] = "删除全部路径点",
	["Remove all waypoints from this zone"] = "删除本区域的全部路径点",
	["Remove waypoint"] = "删除路径点",
	["Save new waypoints until I remove them"] = "保存新的路径点直到删除他们",
	["Save profile for TomTom waypoints"] = "保存TomTom路径点配置",
	["Save this waypoint between sessions"] = "保存这个路径点之间的会话",
	["Saved profile for TomTom options"] = "保存TomTom选项的配置",
	["Scale"] = "比例",
	["Send to battleground"] = "发送到战场",
	["Send to guild"] = "发送到工会",
	["Send to party"] = "发送到队伍",
	["Send to raid"] = "发送到团队",
	["Send waypoint to"] = "发送路径点到",
	["Set as waypoint arrow"] = "设定为路径箭头",
	["Show estimated time to arrival"] = "显示估计的到达时间 ",
	["Shows an estimate of how long it will take you to reach the waypoint at your current speed"] = "显示以你当前的速度需要多长时间到达路径点",
	["The color to be displayed when you are halfway between the direction of the active waypoint and the completely wrong direction"] = "当你界于正确与错误的路径点方向之间时显示的颜色",
	["The color to be displayed when you are moving in the direction of the active waypoint"] = "当你朝向路径点方向时显示的颜色",
	["The color to be displayed when you are moving in the opposite direction of the active waypoint"] = "当你反方向路径点是显示的颜色",
	["The display of the coordinate block can be customized by changing the options below."] = "通过改变以下选项可以自定义坐标模块显示.",
	["The floating waypoint arrow can change color depending on whether or nor you are facing your destination.  By default it will display green when you are facing it directly, and red when you are facing away from it.  These colors can be changed in this section.  Setting these options to the same color will cause the arrow to not change color at all"] = "浮动的路径点箭头是否改变颜色取决于你所面对的你的目的地. 默认情况下，你面对它,箭头会显示绿色；当你反方向的话箭头会显示红色。这些颜色可以在这里进行设定。如果设置为相同的颜色， 会导致箭头在所有状态下不改变颜色",
	["There were no waypoints to remove in %s"] = " %s 没有路径点被删除",
	["These options let you customize the size and opacity of the waypoint arrow, making it larger or partially transparent, as well as limiting the size of the title display."] = "这些选项可以使你自定义路径箭头的比例尺寸和透明度,同时可以设置标题显示的极限尺寸.",
	["This option will not remove any waypoints that are currently set to persist, but only effects new waypoints that get set"] = "This option will not remove any waypoints that are currently set to persist, but only effects new waypoints that get set",
	["This option will toggle whether or not you are asked to confirm removing all waypoints.  If enabled, a dialog box will appear, requiring you to confirm removing the waypoints"] = "这个选项将切换设置当删除所有路径点时是否进行询问.  如果起用, 将显示一个对话框, 以使你确认删除路径点",
	["This setting allows you to change the opacity of the waypoint arrow, making it transparent or opaque"] = "这个设置可以改变路径箭头的透明度, 使之透明或不透明",
	["This setting allows you to change the scale of the waypoint arrow, making it larger or smaller"] = "这个设置可以改变路径箭头的比例尺寸, 使之变大或变小",
	["This setting allows you to specify the maximum height of the title text.  Any titles that are longer than this height (in game pixels) will be truncated."] = "这个设置可以详细设定标题文本的最大高度.  任何标题如果大于此高度(游戏内像素)将被删减.",
	["This setting allows you to specify the maximum width of the title text.  Any titles that are longer than this width (in game pixels) will be wrapped to the next line."] = "这个设置可以详细设定标题文本的最大宽度. 任何标题如果大于此高度(游戏内像素)将进行换行处理.",
	["This setting will control the distance at which the waypoint arrow switches to a downwards arrow, indicating you have arrived at your destination"] = "这个设置可以设定多少距离时路径箭头变换为向下,以指示你已经到达目的地",
	["This setting changes the modifier used by TomTom when right-clicking on the world map to create a waypoint"] = "这个设置用来更改+右键的组合键以用来创建一个Tomtom路径点", -- new
	["Title Height"] = "标题高度",
	["Title Width"] = "标题宽度",
	["TomTom"] = "TomTom",
	["TomTom Waypoint Arrow"] = "TomTom 路径箭头",
	["TomTom can display a tooltip containing information abouto waypoints, when they are moused over.  This setting toggles that functionality"] = "当鼠标指向路径点时,TomTom 可以显示包含本路径点信息的鼠标提示. 这个设置可以切换本功能",
	["TomTom can display multiple waypoint arrows on the minimap.  These options control the display of these waypoints"] = "TomTom 可以在小地图上显示多重路径箭头.  这些选项可以控制这些路径点的显示",
	["TomTom can display multiple waypoints on the world map.  These options control the display of these waypoints"] = "TomTom 可以在世界地图上显示多重路径点.  这些选项可以控制这些路径点的显示",
	["TomTom can hide waypoints in other zones, this setting toggles that functionality"] = "TomTom 可以隐藏其他地区的路径点, 这个设置可以切换本功能",
	["TomTom provides an arrow that can be placed anywhere on the screen.  Similar to the arrow in \"Crazy Taxi\" it will point you towards your next waypoint"] = "TomTom 提供了一个可以放在屏幕任何地方的箭头.  类似 \"疯狂巴士\" 箭头,他将指引你到达下个路径点",
	["TomTom provides you with a floating coordinate display that can be used to determine your current position.  These options can be used to enable or disable this display, or customize the block's display."] = "TomTom 提供了一个浮动的坐标模块,可以显示你当前的位置坐标. 这些选项可以设置该模块的开关, 或自定义模块的显示.",
	["TomTom waypoint"] = "TomTom 路径点",
	["TomTom's saved variables are organized so you can have shared options across all your characters, while having different sets of waypoints for each.  These options sections allow you to change the saved variable configurations so you can set up per-character options, or even share waypoints between characters"] = "TomTom 的保存函数是有条理的,所以你可以在你的角色间共享选项, 同时可对每个路径点进行不同的设置.  这些选项部分可以改变保存函数结构所以你可以设置每个角色的选项,乃至在角色之间分配路径点.",
	["Waypoint Arrow"] = "路径箭头",
	["Waypoint Options"] = "路径点选项",
	["Waypoint communication"] = "路径点消息",
	["Waypoint from %s"] = "路径点于 %s",
	["Waypoints can be automatically cleared when you reach them.  This slider allows you to customize the distance in yards that signals your \"arrival\" at the waypoint.  A setting of 0 turns off the auto-clearing feature\n\nChanging this setting only takes effect after reloading your interface."] = "当你到达路径点时插件会自动清除这些路径点.本项设置可以自定义还有多少码距离到达你的路径点. 当设置为0时关闭自动清除功能\n\n重载界面就可使设置生效.",
	["Waypoints profile"] = "路径点配置",
	["When a new waypoint is added, TomTom can automatically set the new waypoint as the \"Crazy Arrow\" waypoint."] = "当一个新的路径点被添加后, TomTom 可以自动的设定这个新的路径点为 \"疯狂箭头\" 模式.",
	["World Map"] = "世界地图",
	["Yes"] = "是",
	["\"Arrival Distance\""] = "\"到达距离\"",
	["|cffffff78/way <x> <y> [desc]|r - Adds a waypoint at x,y with descrtiption desc"] = "|cffffff78/way <x> <y> [注释]|r - 于X，Y坐标处添加一路径点并添加注释描述",
	["|cffffff78/way <zone> <x> <y> [desc]|r - Adds a waypoint at x,y in zone with description desc"] = "|cffffff78/way <地区> <x> <y> [注释]|r - 于本地区的X，Y坐标处添加一路径点并添加注释描述",
	["|cffffff78/way reset <zone>|r - Resets all waypoints in zone"] = "|cffffff78/way reset <地区>|r - 重置本地区所有路径点",
	["|cffffff78/way reset all|r - Resets all waypoints"] = "|cffffff78/way reset all|r - 重置所有路径点",
	["|cffffff78TomTom |r/way |cffffff78Usage:|r"] = "|cffffff78TomTom |r/way |cffffff78Usage:|r",
	["|cffffff78TomTom|r: Added '%s' (sent from %s) to zone %s"] = "|cffffff78TomTom|r: 添加 '%s' (自 %s) 到 %s",
}

setmetatable(TomTomLocals, {__index=function(t,k) rawset(t, k, k); return k; end})

end
