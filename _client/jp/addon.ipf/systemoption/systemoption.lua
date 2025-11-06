local json = require('json')
local PATH = require('path')

local system_option_setting = {}

local path_format = '..\\release\\addon_setting\\system_option\\%s\\settings.json'
system_option_setting.SettingsFileLocation = string.format(path_format, '0')

system_option_setting.Settings = {
	pc_id = {}
};

function load_evolution_stone_effect_value()	
    if not system_option_setting.Loaded then
        system_option_setting.SettingsFileLocation = string.format(path_format, session.loginInfo.GetUserID())
        local t, err = load_json(system_option_setting.SettingsFileLocation, system_option_setting.Settings);			
        if err then
            os.execute('mkdir ' .. PATH.dirname(system_option_setting.SettingsFileLocation))
        else
            system_option_setting.Settings = t;
            system_option_setting.Loaded = true;								
        end
    end
end

function save_evolution_stone_effect_value(value)	
	local t = system_option_setting.Settings.pc_id[session.GetMySession():GetCID()]
	if t == nil then		
		system_option_setting.Settings.pc_id[session.GetMySession():GetCID()] = {}
	end

	if system_option_setting.Settings.pc_id[session.GetMySession():GetCID()]['evolution_stone_effect_value'] == nil then
		system_option_setting.Settings.pc_id[session.GetMySession():GetCID()]["evolution_stone_effect_value"] = {}	
	end
	system_option_setting.Settings.pc_id[session.GetMySession():GetCID()]["evolution_stone_effect_value"]['level'] = value
    save_json(system_option_setting.SettingsFileLocation, system_option_setting.Settings);
end

function get_evolution_stone_effect_value()
    local t = system_option_setting.Settings.pc_id[session.GetMySession():GetCID()]    
    if t == nil or t['evolution_stone_effect_value'] == nil or t['evolution_stone_effect_value']['level'] == nil then
        return 255
    else
        return t['evolution_stone_effect_value']['level']
    end
end


function SYSTEMOPTION_ON_INIT(addon, frame)
	addon:RegisterMsg('IES_VALUE_CHANGE', 'UPDATE_OPERATOR_CONFIG');
	addon:RegisterMsg('RECEIVE_SERVER_NATION', 'UPDATE_RECEIVE_SERVER_NATION');
	load_evolution_stone_effect_value()
	load_fix_headsupdisplay_value()
	load_OnlySameNationChat_value()
	load_translation_language_value()
	INIT_GAMESYS_CONFIG(frame);	
end

function UPDATE_RECEIVE_SERVER_NATION(frame)	
	local OnlySameNationChat = GET_CHILD_RECURSIVELY(frame, 'OnlySameNationChat')
	if OnlySameNationChat ~= nil then
		OnlySameNationChat:SetCheck(0)
		OnlySameNationChat:ShowWindow(0)
	end
end

function CONFIG_FIRST_OPEN(frame)
	SYSTEMOPTION_CREATE(frame)
	UPDATE_OPERATOR_CONFIG(frame);
end

function SYS_OPTION_OPEN(frame)
	CONFIG_FIRST_OPEN(frame)
end

function SYS_OPTION_CLOSE()
end

function UPDATE_OPERATOR_CONFIG(frame)
end

function SYSTEMOPTION_CREATE(frame)
	local bg2 = GET_CHILD_RECURSIVELY(frame, "bg2", "ui::CGroupBox")
	bg2:SetScrollPos(0);

	INIT_SCREEN_CONFIG(frame);
	INIT_SOUND_CONFIG(frame);
	INIT_LANGUAGE_CONFIG(frame);
	INIT_GRAPHIC_CONFIG(frame);
	INIT_CONTROL_CONFIG(frame);
	SET_SKL_CTRL_CONFIG(frame);
    SET_AUTO_CELL_SELECT_CONFIG(frame);
    SET_DMG_FONT_SCALE_CONTROLLER(frame);
	SET_SHOW_PAD_SKILL_RANGE(frame);
	SET_SHOW_BOSS_SKILL_RANGE(frame);
	SET_SIMPLIFY_BUFF_EFFECTS(frame);
	SET_SIMPLIFY_MODEL(frame);
	SET_RENDER_SHADOW(frame);
	SET_QUESTINFOSET_TRANSPARENCY(frame);
	SET_COOLDOWN_DECIMAL_POINT_SEC(frame);
	SET_ENABLE_AUTO_CASTING(frame)
	SET_POPUP_PICK_ITEM(frame)
	SET_PICK_ITEM_MESSAGE(frame)
	SHOW_COLONY_BATTLEMESSAGE(frame);		
	SYSTEMOPTION_INIT_TAB(frame);
end

-- // System Option Tab Item // --
function SYSTEMOPTION_INIT_TAB(frame)
	local tab = GET_CHILD_RECURSIVELY(frame, "GameAndUIModeTab");
	local tabObj = tolua.cast(tab,  "ui::CTabControl");
	if tabObj ~= nil then
		tabObj:SelectTab(0);
		SYSTEMOPTION_SYSTEM_VIEW(frame);
	end
end

function SYSTEMOPTION_INIT_COLONY_HP_INFO_SIZE(frame)
	local sizeType = config.GetShowGuildInColonyPartyHpGaugeSizeType();
	if sizeType == 0 then
		local guildinColonyPartyHpInfoRadioBtn_Big = GET_CHILD_RECURSIVELY(frame, "guildInColonyPartyhpInfoSize_0", "ui::CRadioButton");
		if guildinColonyPartyHpInfoRadioBtn_Big ~= nil then
			guildinColonyPartyHpInfoRadioBtn_Big:SetCheck(true);
		end
	elseif sizeType == 1 then
		local guildinColonyPartyHpInfoRadioBtn_Small = GET_CHILD_RECURSIVELY(frame, "guildInColonyPartyhpInfoSize_1", "ui::CRadioButton");
		if guildinColonyPartyHpInfoRadioBtn_Small ~= nil then
			guildinColonyPartyHpInfoRadioBtn_Small:SetCheck(true);
		end
	end
	config.SetShowGuildInColonyPartyHpGaugeSizeType(sizeType);
end

function SYSTEMOPTION_TAB_CHANGE(frame, ctrl, argStr, argNum)
	local tab = GET_CHILD_RECURSIVELY(frame, "GameAndUIModeTab");
	local tabObj = tolua.cast(tab,  "ui::CTabControl");
	if tabObj ~= nil then
		local curIndex = tabObj:GetSelectItemIndex();
		if curIndex ~= nil then
			if curIndex == 0 then -- system : display, sound, performance, graphic...
				SYSTEMOPTION_SYSTEM_VIEW(frame);
			elseif curIndex == 1 then -- Game
				SYSTEMOPTION_GRAPHIC_VIEW(frame);
			elseif curIndex == 2 then -- PVP Setting
				SYSTEMOPTION_PVP_SETTING_VIEW(frame);
			end
		end
	end
end

function SYSTEMOPTION_GBOX_SHOW_WINDOW_SETTING(frame, boxName, isShow)
	local gBox = GET_CHILD_RECURSIVELY(frame, boxName);
	if gBox ~= nil then
		gBox:ShowWindow(isShow);
	end
end

function SYSTEMOPTION_SYSTEM_VIEW(frame)
	SYSTEMOPTION_GBOX_SHOW_WINDOW_SETTING(frame, "displayBox", 0);
	SYSTEMOPTION_GBOX_SHOW_WINDOW_SETTING(frame, "soundPerfBox", 0);
	SYSTEMOPTION_GBOX_SHOW_WINDOW_SETTING(frame, "soundBox", 1);
	SYSTEMOPTION_GBOX_SHOW_WINDOW_SETTING(frame, "graphicBox", 0);
	SYSTEMOPTION_GBOX_SHOW_WINDOW_SETTING(frame, "gameBox", 1);
	SYSTEMOPTION_GBOX_SHOW_WINDOW_SETTING(frame, "uiModeBox", 1);
	SYSTEMOPTION_GBOX_SHOW_WINDOW_SETTING(frame, "gamePVPSetting", 0);
end

function SYSTEMOPTION_GRAPHIC_VIEW(frame)
	SYSTEMOPTION_GBOX_SHOW_WINDOW_SETTING(frame, "displayBox", 1);
	SYSTEMOPTION_GBOX_SHOW_WINDOW_SETTING(frame, "soundPerfBox", 1);
	SYSTEMOPTION_GBOX_SHOW_WINDOW_SETTING(frame, "soundBox", 0);
	SYSTEMOPTION_GBOX_SHOW_WINDOW_SETTING(frame, "graphicBox", 1);
	SYSTEMOPTION_GBOX_SHOW_WINDOW_SETTING(frame, "gameBox", 0);
	SYSTEMOPTION_GBOX_SHOW_WINDOW_SETTING(frame, "uiModeBox", 0);
	SYSTEMOPTION_GBOX_SHOW_WINDOW_SETTING(frame, "gamePVPSetting", 0);
end

function SYSTEMOPTION_PVP_SETTING_VIEW(frame)
	SYSTEMOPTION_GBOX_SHOW_WINDOW_SETTING(frame, "displayBox", 0);
	SYSTEMOPTION_GBOX_SHOW_WINDOW_SETTING(frame, "soundPerfBox", 0);
	SYSTEMOPTION_GBOX_SHOW_WINDOW_SETTING(frame, "soundBox", 0);	
	SYSTEMOPTION_GBOX_SHOW_WINDOW_SETTING(frame, "graphicBox", 0);
	SYSTEMOPTION_GBOX_SHOW_WINDOW_SETTING(frame, "gameBox", 0);
	SYSTEMOPTION_GBOX_SHOW_WINDOW_SETTING(frame, "uiModeBox", 0);
	SYSTEMOPTION_GBOX_SHOW_WINDOW_SETTING(frame, "gamePVPSetting", 1);
	SYSTEMOPTION_INIT_COLONY_HP_INFO_SIZE(frame);
	SHOW_COLONY_GUILD_NAME(frame);
	SHOW_COLONY_TEAM_NAME(frame);
	SHOW_COLONY_ENEMY_GUILD_EMBLEM(frame);
	SHOW_COLONY_MY_BUFF(frame);
	SHOW_COLONY_PARTY_BUFF(frame);
	SHOW_COLONY_GUILD_BUFF(frame);
	SHOW_COLONY_ENEMY_BUFF(frame);	
end

function SYSTEMOPTION_PVP_SETTING_DEFAULT(frame)
	if frame == nil then return; end
	local chkShowPadSkillRange = GET_CHILD_RECURSIVELY(frame, "chkShowPadSkillRange", "ui::CCheckBox");
	if chkShowPadSkillRange ~= nil then
		local isCheck = config.IsEnableShowPadSkillRange();
		chkShowPadSkillRange:SetCheck(isCheck);
	end

	local chkSimplifyBuffEffects = GET_CHILD_RECURSIVELY(frame, "chkSimplifyBuffEffects", "ui::CCheckBox");
	if chkSimplifyBuffEffects ~= nil then
		local isCheck = config.IsEnableSimplifyBuffEffects();
		chkSimplifyBuffEffects:SetCheck(isCheck);
	end

	local chkSimplifyModel = GET_CHILD_RECURSIVELY(frame, "chkSimplifyModel", "ui::CCheckBox");
	if chkSimplifyModel ~= nil then
		local isCheck = config.IsEnableSimplifyModel();
		chkSimplifyModel:SetCheck(isCheck);
	end

	local chkShowGuildInColony = GET_CHILD_RECURSIVELY(frame, "chkShowGuildInColony", "ui::CCheckBox");
	if chkShowGuildInColony ~= nil then
		local isCheck = config.GetShowGuildInColony();
		chkShowGuildInColony:SetCheck(isCheck);
	end

	local chkShowGuildInColonyEffectCostume = GET_CHILD_RECURSIVELY(frame, "chkShowGuildInColonyEffectCostume", "ui::CCheckBox");
	if chkShowGuildInColonyEffectCostume ~= nil then
		local isCheck = config.GetShowGuildInColonyEffectCostume();
		chkShowGuildInColonyEffectCostume:SetCheck(isCheck);
	end

	local chkShowGuilldInColonyGuildName = GET_CHILD_RECURSIVELY(frame, "chkShowGuilldInColonyGuildName", "ui::CCheckBox");
	if chkShowGuilldInColonyGuildName ~= nil then
		local isCheck = config.GetShowGuildInColonyGuildName();
		chkShowGuilldInColonyGuildName:SetCheck(isCheck);
	end

	local isRadioCheck = config.GetShowGuildInColonyPartyHpGaugeSizeType();
	if isRadioCheck == 0 then
		local guildInColonyPartyhpInfoSize_0 = GET_CHILD_RECURSIVELY(frame, "guildInColonyPartyhpInfoSize_0", "ui::CRadioButton");
		if guildInColonyPartyhpInfoSize_0 ~= nil then
			guildInColonyPartyhpInfoSize_0:SetCheck(false);
			config.SetShowGuildInColonyPartyHpGaugeSizeType(sizeType);
		end
	elseif isRadioCheck == 1 then
		local guildInColonyPartyhpInfoSize_1 = GET_CHILD_RECURSIVELY(frame, "guildInColonyPartyhpInfoSize_1", "ui::CRadioButton");
		if guildInColonyPartyhpInfoSize_1 ~= nil then
			guildInColonyPartyhpInfoSize_1:SetCheck(true);
		end
	end

	local value = config.GetDmgFontScale();
	local dmgFontSizeController = GET_CHILD_RECURSIVELY(frame, "dmgFontSizeController", "ui::CSlideBar");
	if dmgFontSizeController ~= nil then
		config.SetDmgFontScale(value);
		dmgFontSizeController:SetLevel(value * 100);
	end

	local dmgFontSizeController_text = GET_CHILD_RECURSIVELY(frame, "dmgFontSizeController_text", "ui::CRichText");
	if dmgFontSizeController_text ~= nil then
		local str = string.format("%.2f", value);
		dmgFontSizeController_text:SetTextByKey("ctrlValue", str);
	end
end
-- // System Option Tab Item End // --

-- // Init Config // --
function INIT_LANGUAGE_CONFIG(frame)
	local getGroup = GET_CHILD_RECURSIVELY(frame, "pipwin_low", "ui::CGroupBox")
	local getPipwin_low = GET_CHILD_RECURSIVELY(frame, "pipwin_low", "ui::CGroupBox")
	local catelist = GET_CHILD_RECURSIVELY(frame, "languageList", "ui::CDropList");
	catelist:ClearItems();

	if dictionary.IsEnableDic() == false then
		catelist:ShowWindow(0);
		local language_title = GET_CHILD_RECURSIVELY(frame, "language_title");
		language_title:ShowWindow(0);
	end

	local selIndex = 0;
	local cnt = option.GetNumCountry();
	for i = 0 , cnt - 1 do
		local lanUIString =  option.GetPossibleCountryUIName(i);
		local lanUIString2 =  string.format("{@st42b}%s", option.GetPossibleCountryUIName(i));
		local NationGroup = GetServerNation();
		if (lanUIString ~= "kr") then 
			if NationGroup == "GLOBAL" then
				if (lanUIString ~= "Japanese")then
					catelist:AddItem(lanUIString, lanUIString2);
				end
			else
				catelist:AddItem(lanUIString, lanUIString2);
			end
		end
	end
	
	local lanString = option.GetCurrentCountry();
	catelist:SelectItemByKey(lanString);
end

function INIT_SCREEN_CONFIG(frame)
	local getGroup = GET_CHILD_RECURSIVELY(frame, "pipwin_low", "ui::CGroupBox")
	local getPipwin_low = GET_CHILD_RECURSIVELY(frame, "pipwin_low", "ui::CGroupBox")
	local catelist = GET_CHILD_RECURSIVELY(frame, "resolutionList", "ui::CDropList");
	catelist:ClearItems();

	local curWidth = option.GetClientWidth();
	local curHeight = option.GetClientHeight();
	local selIndex = 0;

	local cnt = option.GetDisplayModeCount();
	for i = 0 , cnt - 1 do
		local width = option.GetDisplayModeWidth(i);
		local height = option.GetDisplayModeHeight(i);
		if width ~= 0 or height ~= 0 then -- 0 = resolution is higher than current PC resolution
		local resString = string.format("{@st42b}%d * %d{/}", width, height);
		catelist:AddItem(i, resString);

		if curWidth == width and curHeight == height then
			selIndex = i;
		end
	end
	end

	catelist:SelectItem(selIndex);
	local scrMode = option.GetScreenMode();
	local scrBtn = GET_CHILD_RECURSIVELY(frame,"scrtype_" .. scrMode,"ui::CRadioButton");
	if scrBtn ~= nil then
		scrBtn:Select();
	end

	local autoPerfMode = config.GetAutoAdjustLowLevel();
	local autoPerfBtn = GET_CHILD_RECURSIVELY(frame,"perftype_" .. autoPerfMode);
	if autoPerfBtn ~= nil then
		autoPerfBtn:Select();
	end

	local chkOptimization = GET_CHILD_RECURSIVELY(frame, "check_optimization", "ui::CCheckBox");
	if nil ~= chkOptimization then
		chkOptimization:SetCheck(imcperfOnOff.IsEnableOptimization());
	end;

	local syncMode = option.IsEnableVSync()
	local syncBtn = GET_CHILD_RECURSIVELY(frame,"vsync_" .. syncMode,"ui::CRadioButton");
	if syncBtn ~= nil then
		syncBtn:Select()
	end
end

function INIT_SOUND_CONFIG(frame)
	SET_SLIDE_VAL(frame, "soundVol", "soundVol_text", config.GetSoundVolume());
	SET_SLIDE_VAL(frame, "musicVol", "musicVol_text", config.GetMusicVolume());
	SET_SLIDE_VAL(frame, "flutingVol", "flutingVol_text", config.GetFlutingVolume());
	SET_SLIDE_VAL(frame, "totalVol", "totalVol_text", config.GetTotalVolume());	
	SET_SLIDE_VAL(frame, "effect_transparency_my_value", "effect_transparency_my", config.GetMyEffectTransparency());
	SET_SLIDE_VAL(frame, "effect_transparency_other_value", "effect_transparency_other", config.GetOtherEffectTransparency());
	SET_SLIDE_VAL(frame, "effect_transparency_boss_monster_value", "effect_transparency_boss_monster", config.GetBossMonsterEffectTransparency());
	
	config.SetEvolutionStoneEffect(get_evolution_stone_effect_value());	
	SET_SLIDE_VAL(frame, "evolution_stone_effect_value", "evolution_stone_effect", config.GetEvolutionStoneEffect());

	local isOtherFlutingEnable = config.IsEnableOtherFluting();
	local chkOtherFlutingEnable = GET_CHILD_RECURSIVELY(frame, "check_fluting");
	if nil ~= chkOtherFlutingEnable then
		chkOtherFlutingEnable:SetCheck(isOtherFlutingEnable);
	end

	local isSoundReverbEnable = config.IsEnableSoundReverb();
	local checkSoundReverb = GET_CHILD_RECURSIVELY(frame, "check_soundReverb");
	if nil ~= checkSoundReverb then
		checkSoundReverb:SetCheck(isSoundReverbEnable);
	end

	if FLUTING_ENABLED ~= 1 then
		local flutingVol = GET_CHILD_RECURSIVELY(frame, "flutingVol");
		local flutingVol_text = GET_CHILD_RECURSIVELY(frame, "flutingVol_text");
		flutingVol:SetVisible(0);
		flutingVol_text:SetVisible(0);
		if chkOtherFlutingEnable ~= nil then
			chkOtherFlutingEnable:SetVisible(0);
		end

		local totalVol = GET_CHILD_RECURSIVELY(frame, "totalVol");
		local totalVol_text = GET_CHILD_RECURSIVELY(frame, "totalVol_text");
		totalVol:SetOffset(totalVol:GetOriginalX(), flutingVol:GetOriginalY());
		totalVol_text:SetOffset(totalVol_text:GetOriginalX(), flutingVol_text:GetOriginalY());

		local check_soundReverb = GET_CHILD_RECURSIVELY(frame, "check_soundReverb");
		check_soundReverb:SetOffset(totalVol_text:GetOriginalX(), totalVol_text:GetOriginalY());
	end
end

function INIT_GRAPHIC_CONFIG(frame)
	local bloom = GET_CHILD_RECURSIVELY(frame, "check_Bloom", "ui::CCheckBox");
	if nil ~= bloom then
	bloom:SetCheck(config.GetUseBloom());
	end;

	local warfog = GET_CHILD_RECURSIVELY(frame, "check_warfog", "ui::CCheckBox");
	if nil ~= warfog then
	warfog:SetCheck(config.GetUseWarfog());
	end;

	local fxaa = GET_CHILD_RECURSIVELY(frame, "check_fxaa", "ui::CCheckBox");
	if nil ~= fxaa then
	fxaa:SetCheck(config.GetUseFXAA());
	end;

	local glow = GET_CHILD_RECURSIVELY(frame, "check_HitGlow", "ui::CCheckBox");
	if nil ~= glow then
	glow:SetCheck(config.GetUseHitGlow());
	end;

	local depth = GET_CHILD_RECURSIVELY(frame, "check_Depth", "ui::CCheckBox");
	if nil ~= depth then
	depth:SetCheck(1);
	end;

	local softParticle = GET_CHILD_RECURSIVELY(frame, "check_SoftParticle", "ui::CCheckBox");
	if nil ~= softParticle then
	softParticle:SetCheck(config.GetUseSoftParticle());
	end;

	local highTexture = GET_CHILD_RECURSIVELY(frame, "check_highTexture", "ui::CCheckBox");
	if nil ~= highTexture then
	highTexture:SetCheck(config.GetHighTexture());
	end;

	local otherPCDamage = GET_CHILD_RECURSIVELY(frame, "check_ShowOtherPCDamageEffect", "ui::CCheckBox");
	if nil ~= otherPCDamage then
		otherPCDamage:SetCheck(config.GetOtherPCDamageEffect());
	end;

	local textEffectUnVisible = GET_CHILD_RECURSIVELY(frame, "check_ShowTextEffect", "ui::CCheckBox");
	if textEffectUnVisible ~= nil then
		textEffectUnVisible:SetCheck(config.GetUnVisibleTextEffect());
	end
	
	local Check_Enable_Daylight = GET_CHILD_RECURSIVELY(frame, "Check_Enable_Daylight", "ui::CCheckBox");
	if Check_Enable_Daylight ~= nil then
		Check_Enable_Daylight:SetCheck(config.GetEnableDayLight());
	end
	
	local performance_limit_text = GET_CHILD_RECURSIVELY(frame, "performance_limit_text");
	if performance_limit_text ~= nil then
		performance_limit_text:SetTextByKey("opValue", config.GetPerformanceLimit());
	end
	local performance_limit_slide = GET_CHILD_RECURSIVELY(frame, "performance_limit_slide");
	if performance_limit_slide ~= nil then
		performance_limit_slide:SetLevel(config.GetPerformanceLimit());
	end
	
	local bgmaxfps_text = GET_CHILD_RECURSIVELY(frame, "bgmaxfps_text");
	if bgmaxfps_text ~= nil then
		bgmaxfps_text:SetTextByKey("opValue", config.GetBackgroundMaxFPS());
	end
	local bgmaxfps_slide = GET_CHILD_RECURSIVELY(frame, "bgmaxfps_slide");
	if bgmaxfps_slide ~= nil then
		bgmaxfps_slide:SetLevel(config.GetBackgroundMaxFPS());
	end
	local max_particles = GET_CHILD_RECURSIVELY(frame, "max_particles");
	if max_particles ~= nil then
		max_particles:SetTextByKey("opValue", config.GetMaxParticles());
	end
	local max_particles_value = GET_CHILD_RECURSIVELY(frame, "max_particles_value");
	if max_particles_value ~= nil then
		max_particles_value:SetLevel(imc.bit_width(config.GetMaxParticles() * 1.5) - 1);
	end
 
	local IsEnableSummonAlpha = GET_CHILD_RECURSIVELY(frame, "Check_IsEnableSummonAlpha", "ui::CCheckBox");
	if IsEnableSummonAlpha ~= nil then
		IsEnableSummonAlpha:SetCheck(config.GetIsEnableSummonAlpha());
	end

	local isEnableEvolutionStoneEffect = GET_CHILD_RECURSIVELY(frame, "Check_IsEnableEvolutionStoneEffect", "ui::CCheckBox");
	if isEnableEvolutionStoneEffect ~= nil then
		isEnableEvolutionStoneEffect:SetCheck(config.GetIsEnableEvolutionStoneEffect());
	end

	local useURO = GET_CHILD_RECURSIVELY(frame, "check_UseURO", "ui::CCheckBox");
	if useURO ~= nil then
		useURO:SetCheck(config.GetUseURO());
	end
end

function INIT_GAMESYS_CONFIG(frame)
	local skillGizmoTargetAim = GET_CHILD_RECURSIVELY(frame, "check_SkillGizmoTargetAim", "ui::CCheckBox");
	if skillGizmoTargetAim ~= nil then
		local value = config.GetXMLConfig("EnableSkillGizmoTargetAim");
		skillGizmoTargetAim:SetCheck(tonumber(value));
		config.EnableSkillGizmoTargetAim(tonumber(value));
		config.ChangeXMLConfig("EnableSkillGizmoTargetAim", tostring(value));
	end

	local maintainTargetedSkillUi = GET_CHILD_RECURSIVELY(frame, "MaintainTargetedSkillUI", "ui::CCheckBox");
	if maintainTargetedSkillUi ~= nil then
		local value = config.GetXMLConfig("MaintainTargetedSkillUI");
		maintainTargetedSkillUi:SetCheck(tonumber(value));
		config.MaintainTargetedSkillUI(tonumber(value));
		config.ChangeXMLConfig("MaintainTargetedSkillUI", tostring(value));
	end

	local isEnableEffectTransparency = config.GetXMLConfig("EnableEffectTransparency");
	if isEnableEffectTransparency == 0 then
		EFFECT_TRANSPARENCY_OFF();
	end

	SYSTEMOPTION_PVP_SETTING_DEFAULT(frame);	
end

function INIT_CONTROL_CONFIG(frame)
	local modeValue = config.GetXMLConfig("ControlMode");
	local getGroup = GET_CHILD_RECURSIVELY(frame, "pipwin_low", "ui::CGroupBox")
	local radioBtn = GET_CHILD_RECURSIVELY(frame, "controltype_" .. modeValue);
	radioBtn:SetCheck(true);
end
-- // Init Config End // --

function UPDATE_SCREEN_CONFIG(frame)
	local scrMode = option.GetScreenMode();
	local catelist = GET_CHILD_RECURSIVELY(frame, "resolutionList", "ui::CDropList");
	if scrMode == 1 then
		catelist:ShowWindow(0);
	else
		catelist:ShowWindow(1);
	end
end

function SEL_CONFIG_GRAPHIC(frame)
	UPDATE_SCREEN_CONFIG(frame);
end

function APPLY_CONTROLMODE(frame)    
    if quickslot.IsEnableChange() == false then
        ui.SysMsg(ClMsg('CannotInCurrentState'));
        local prevSelectedType = config.GetXMLConfig('ControlMode');
        local radioBtn = GET_CHILD_RECURSIVELY(frame, 'controltype_'..prevSelectedType);
        radioBtn:Select();
        return;
    end

	local controlmodeRadioBtn = GET_CHILD_RECURSIVELY(frame, "controltype_0");    
	local controlmodeType = GET_RADIOBTN_NUMBER(controlmodeRadioBtn);
	config.ChangeXMLConfig("ControlMode", controlmodeType);
end

function APPLY_PERFMODE(frame)
	local perfRadioBtn = GET_CHILD_RECURSIVELY(frame, "perftype_0");    
	local perfType = GET_RADIOBTN_NUMBER(perfRadioBtn);
	
	local parent = frame:GetTopParentFrame();
	local highTexture = GET_CHILD_RECURSIVELY(parent, "check_highTexture", "ui::CCheckBox");
	local softParticle = GET_CHILD_RECURSIVELY(parent, "check_SoftParticle", "ui::CCheckBox");
	local otherPCDamage = GET_CHILD_RECURSIVELY(parent, "check_ShowOtherPCDamageEffect", "ui::CCheckBox");
	local renderShadow = GET_CHILD_RECURSIVELY(parent, "check_RenderShadow", "ui::CCheckBox");
	
	if 0 == perfType then
		graphic.EnableHighTexture(0);
		config.EnableOtherPCDamageEffect(0);
		softParticle:SetCheck(0);
        imcperfOnOff.EnableRenderShadow(0);
	else
		graphic.EnableHighTexture(1);
		config.EnableOtherPCDamageEffect(1);
		softParticle:SetCheck(1);
        imcperfOnOff.EnableRenderShadow(1);
	end

	highTexture:SetCheck(config.GetHighTexture());
	otherPCDamage:SetCheck(config.GetOtherPCDamageEffect());
	renderShadow:SetCheck(imcperfOnOff.IsEnableRenderShadow());

	config.SetAutoAdjustLowLevel(perfType)
	config.SaveConfig();
end

function APPLY_OPTIMIZATION(frame)
	if imcperfOnOff.IsEnableOptimization() == 1 then
		imcperfOnOff.EnableOptimization(0);
	else
		imcperfOnOff.EnableOptimization(1);
	end
end

function SHOW_PERFORMANCE_VALUE(frame)
	local flag = config.GetXMLConfig("ShowPerformanceValue")
	SHOW_FPS_FRAME(flag)
end

function SET_PERFORMANCE_LIMIT(frame, ctrl, str, num)
	tolua.cast(ctrl, "ui::CSlideBar");
	config.SetPerformanceLimit(ctrl:GetLevel());
	
	local txt = GET_CHILD_RECURSIVELY(frame, "performance_limit_text", "ui::CRichText");
	txt:SetTextByKey("opValue", ctrl:GetLevel());
end

function SET_BACKGROUND_MAXFPS(frame, ctrl, str, num)
	tolua.cast(ctrl, "ui::CSlideBar");
	config.SetBackgroundMaxFPS(ctrl:GetLevel());
	
	local txt = GET_CHILD_RECURSIVELY(frame, "bgmaxfps_text", "ui::CRichText");
	txt:SetTextByKey("opValue", ctrl:GetLevel());
end

function APPLY_SCREEN(frame)
	local scrRadioBtn = GET_CHILD_RECURSIVELY(frame, "scrtype_1" , "ui::CRadioButton");
	local resCtrl = GET_CHILD_RECURSIVELY(frame, "resolutionList", "ui::CDropList");    
	local scrType = GET_RADIOBTN_NUMBER(scrRadioBtn);
	local resIndex = resCtrl:GetSelItemIndex();
	option.SetDisplayMode(scrType, resIndex, option.IsEnableVSync());
	if scrType == 1 then
		resCtrl:ShowWindow(0);
	else
		resCtrl:ShowWindow(1);
	end

	config.SaveConfig();
end

function APPLY_LANGUAGE(frame)
	local lanCtrl = GET_CHILD_RECURSIVELY(frame, "languageList", "ui::CDropList");
	local lanString = lanCtrl:GetSelItemKey();
	option.SetCountry(lanString)

	config.SaveConfig();
end

function CHECK_CANCEL_SCREEN(frame, timer, str, num, totalTime)
	if totalTime >= 5 then
		timer:Stop();
		return;
	end

	if keyboard.IsKeyDown("BACKSPACE") == 1 then
		frame:EnableHide(0);
		timer:Stop();
		ReserveScript("CONFIG_ENABLE_HIDE()", 0.1);
		option.RecoverDisplayMode();
		INIT_SCREEN_CONFIG(frame);
		INIT_LANGUAGE_CONFIG(frame);
		return;
	end
end

function CONFIG_ENABLE_HIDE()
	local fr = ui.GetFrame("systemoption");
	fr:EnableHide(1);
end

function SET_SLIDE_VAL(frame, ctrlName, txtname, value)
	local slide = GET_CHILD_RECURSIVELY(frame, ctrlName, "ui::CSlideBar");
	slide:SetLevel(value);

	local txt = GET_CHILD_RECURSIVELY(frame, txtname, "ui::CRichText");
	local rate = value / 255 * 100;
	rate = math.floor(rate);
	txt:SetTextByKey("opValue", rate);
end

function SET_SKL_CTRL_CONFIG(frame)
	local value = config.GetSklCtrlSpd();
	local slide = GET_CHILD_RECURSIVELY(frame, "sklCtrlSpd", "ui::CSlideBar");
	slide:SetLevel(value);
	local txt = GET_CHILD_RECURSIVELY(frame, "sklCtrlSpd_text", "ui::CRichText");
	local rate = value / 10;
	rate = math.floor(rate);
	txt:SetTextByKey("opValue", rate);
end

function CONFIG_SKL_CTRL_SPD(frame, ctrl, str, num)
	tolua.cast(ctrl, "ui::CSlideBar");
	config.SetSklCtrlSpd(ctrl:GetLevel());
	SET_SKL_CTRL_CONFIG(frame);
end

function SET_AUTO_CELL_SELECT_CONFIG(frame)
	local value = config.GetAutoCellSelectSpd();
	local slide = GET_CHILD_RECURSIVELY(frame, "autoCellSelectSpd", "ui::CSlideBar");
	slide:SetLevel(value);
	local txt = GET_CHILD_RECURSIVELY(frame, "autoCellSelectSpd_text", "ui::CRichText");
	txt:SetTextByKey("ctrlValue", value);
end

function CONFIG_AUTO_CELL_SELECT_SPD(frame, ctrl, str, num)
    tolua.cast(ctrl, "ui::CSlideBar");
	config.SetAutoCellSelectSpd(ctrl:GetLevel());
	SET_AUTO_CELL_SELECT_CONFIG(frame);
end

function CONFIG_SOUNDVOL(frame, ctrl, str, num)
	tolua.cast(ctrl, "ui::CSlideBar");
	config.SetSoundVolume(ctrl:GetLevel());
	SET_SLIDE_VAL(frame, "soundVol", "soundVol_text", config.GetSoundVolume());
end

function CONFIG_MUSICVOL(frame, ctrl, str, num)
	tolua.cast(ctrl, "ui::CSlideBar");
	config.SetMusicVolume(ctrl:GetLevel());
	SET_SLIDE_VAL(frame, "musicVol", "musicVol_text", config.GetMusicVolume());
end

function CONFIG_TOTALVOL(frame, ctrl, str, num)
	tolua.cast(ctrl, "ui::CSlideBar");
	config.SetTotalVolume(ctrl:GetLevel());
	SET_SLIDE_VAL(frame, "totalVol", "totalVol_text", config.GetTotalVolume());
end

function CONFIG_FLUTINGVOL(frame, ctrl, str, num)
	tolua.cast(ctrl, "ui::CSlideBar");
	config.SetFlutingVolume(ctrl:GetLevel());
	SET_SLIDE_VAL(frame, "flutingVol", "flutingVol_text", config.GetFlutingVolume());
end

function SET_CHECKBOX_BY_IES_PROP(checkBox, idSpc, className, propName)
	local cls = GetClass(idSpc, className);
	checkBox:SetCheck(cls[propName]);
end

function CHANGE_SHARED_CONST(frame, checkBox, isch, numArg)
	local propName = checkBox:GetName();
	tolua.cast(checkBox, "ui::CCheckBox");
	local cls = GetClass("SharedConst", propName);
	local curValue = cls.Value;
	local changeValue = 1;
	if curValue == 1 then
		changeValue = 0;
	end

	iesman.ChangeIESProp("SharedConst", cls.ClassID, cls.ClassName, "Value", changeValue, "CHANGE BY OPTION", 1);
end

function APPLY_PKS_DELAY(frame)
	local minDelay = config.GetXMLConfig("MinPksDelay");
	local maxDelay = config.GetXMLConfig("MaxPksDelay");
	maxDelay = math.max(minDelay, maxDelay);

	debug.VPD(minDelay, maxDelay);

	local minPksDelay = GET_CHILD_RECURSIVELY(frame, "minPksDelay", "ui::CSlideBar");
	local maxPksDelay = GET_CHILD_RECURSIVELY(frame, "maxPksDelay", "ui::CSlideBar");
	minPksDelay:SetLevel(minDelay);
	maxPksDelay:SetLevel(maxDelay);

	local minPksDelay_text = GET_CHILD_RECURSIVELY(frame, "minPksDelay_text", "ui::CRichText");
	local maxPksDelay_text = GET_CHILD_RECURSIVELY(frame, "maxPksDelay_text", "ui::CRichText");
	minPksDelay_text:SetTextByKey("opValue", minDelay);
	maxPksDelay_text:SetTextByKey("opValue", maxDelay);
end

function ENABLE_WARFOG(parent, ctrl)
	local value = config.GetUseWarfog();
	graphic.EnableWarFog(1- value);
	config.SaveConfig();
end

function ENABLE_BLOOM(parent, ctrl)
	local value = config.GetUseBloom();
	graphic.EnableBloom(1- value);
	config.SaveConfig();
end

function ENABLE_FXAA(parent, ctrl)
	local value = config.GetUseFXAA();
	graphic.EnableFXAA(1- value);
	config.SaveConfig();
end

function ENABLE_HITGLOW(parent, ctrl)
	local value = config.GetUseHitGlow();
	graphic.EnableHitGlow(1- value);
	config.SaveConfig();
end

function ENABLE_DEPTH(parent, ctrl)
	local value = config.GetUseDepth();
	graphic.EnableDepth(1- value);
	config.SaveConfig();
end

function ENABLE_SOFTPARTICLE(parent, ctrl)
	local value = config.GetUseSoftParticle();
	graphic.EnableSoftParticle(1- value);
	config.SaveConfig();
end

function ENABLE_HIGHTTEXTURE(parent, ctrl)
	local value = config.GetHighTexture();
	graphic.EnableHighTexture(1- value);
	config.SaveConfig();
end

function ENABLE_LOW(parent, ctrl)
	local value = config.GetUseLowOption();
	graphic.EnableLowOption(1-value);
	config.SaveConfig();
end

function ENABEL_VSYNC(frame)
	local syncRadioBtn = GET_CHILD_RECURSIVELY(frame, "vsync_0" , "ui::CRadioButton");        
	local syncType = GET_RADIOBTN_NUMBER(syncRadioBtn);
	option.EnableVSync(syncType);
end

function ENABLE_OTHER_FLUTING(parent, ctrl)
	local value = config.IsEnableOtherFluting();
	config.EnableOtherFluting(1-value);
	config.SaveConfig();
end

function ENABLE_SKILLGIZMO_TARGETAIM(parent, ctrl)
	if ctrl == nil then return end
	config.ChangeXMLConfig("EnableSkillGizmoTargetAim", tostring(ctrl:IsChecked()));
end

function MAINTAIN_TARGETED_SKILL_UI(parent, ctrl)
	if ctrl == nil then return; end
	config.ChangeXMLConfig("MaintainTargetedSkillUI", tostring(ctrl:IsChecked()));
end

function UPDATE_TITLE_OPTION(frame)
    if IS_IN_EVENT_MAP() == true then    
        return;
	end
	
	if session.colonywar.GetIsColonyWarMap() == true then
		return;
	end

	world.UpdateTitleOption();
end

function UPDATE_COLONY_WAR_TITLE_OPTION(frame)
    if IS_IN_EVENT_MAP() == true then    
        return;
	end
	
	world.UpdateTitleOption();
end

function SHOW_COLONY_EFFECTCOSTUME(frame)
	if IS_IN_EVENT_MAP() == true then
		return;
	end

	local isShow = config.GetShowGuildInColonyEffectCostume();
	local chkShowGuildInColonyEffectCostume = GET_CHILD_RECURSIVELY(frame, "chkShowGuildInColonyEffectCostume", "ui::CCheckBox");
	if nil ~= chkShowGuildInColonyEffectCostume then
		chkShowGuildInColonyEffectCostume:SetCheck(isShow);
	end

	effect.ShowColonyEffectCostume(isShow);
end

-- // Colony Option // --
function SHOW_COLONY_BATTLEMESSAGE(frame)
	if IS_IN_EVENT_MAP() == true then
		return;
	end

	local isShow = config.GetShowGuildInColonyBattleMessage();
	local chkShowGuildInColonyBattleMessage = GET_CHILD_RECURSIVELY(frame, "chkShowGuildInColonyBattleMessage", "ui::CCheckBox");
	if chkShowGuildInColonyBattleMessage ~= nil then
		chkShowGuildInColonyBattleMessage:SetCheck(isShow);
	end

	config.SetShowGuildInColonyBattleMessage(isShow);
end

function SHOW_COLONY_GUILD_NAME(frame)
	if IS_IN_EVENT_MAP() == true then
		return;
	end

	local isShow = config.GetShowGuildInColonyGuildName();
	local chkShowGuildInColonyGuildName = GET_CHILD_RECURSIVELY(frame, "chkShowGuilldInColonyGuildName", "ui::CCheckBox");
	if chkShowGuildInColonyGuildName ~= nil then
		chkShowGuildInColonyGuildName:SetCheck(isShow);
	end

	config.SetShowGuildInColonyGuildName(isShow);
	world.UpdateTitleOption();
end

function SHOW_COLONY_TEAM_NAME(frame)
	if IS_IN_EVENT_MAP() == true then
		return;
	end

	local isShow = config.GetShowGuildInColonyTeamName();
	local chkShowGuildInColonyTeamName = GET_CHILD_RECURSIVELY(frame, "chkShowGuildInColonyTeamName", "ui::CCheckBox");
	if chkShowGuildInColonyTeamName ~= nil then
		chkShowGuildInColonyTeamName:SetCheck(isShow);
	end

	config.SetShowGuildInColonyTeamName(isShow);
	world.UpdateTitleOption();
end

function SHOW_COLONY_ENEMY_GUILD_EMBLEM(frame)
	if IS_IN_EVENT_MAP() == true then
		return;
	end

	local isShow = config.GetShowGuildInColonyEnemyGuildEmblem();
	local chkShowGuildInColonyEnemyGuildEmblem = GET_CHILD_RECURSIVELY(frame, "chkShowGuildInColonyEnemyGuildEmblem", "ui::CCheckBox");
	if chkShowGuildInColonyEnemyGuildEmblem ~= nil then
		chkShowGuildInColonyEnemyGuildEmblem:SetCheck(isShow);
	end

	config.SetShowGuildInColonyEnemyGuildEmblem(isShow);
	world.UpdateTitleOption();
end

function SHOW_COLONY_MY_BUFF(frame)
	if IS_IN_EVENT_MAP() == true then
		return;
	end

	local isShow = config.GetShowGuildInColonyMyBuff();
	local chkShowGuildInColonyMyBuff = GET_CHILD_RECURSIVELY(frame, "chkShowGuildInColonyMyBuff", "ui::CCheckBox");
	if chkShowGuildInColonyMyBuff ~= nil then
		chkShowGuildInColonyMyBuff:SetCheck(isShow);
	end

	config.SetShowGuildInColonyMyBuff(isShow);
end

function SHOW_COLONY_PARTY_BUFF(frame)
	if IS_IN_EVENT_MAP() == true then
		return;
	end

	local isShow = config.GetShowGuildInColonyPartyBuff();
	local chkShowGuildInColonyPartyBuff = GET_CHILD_RECURSIVELY(frame, "chkShowGuildInColonyPartyBuff", "ui::CCheckBox");
	if chkShowGuildInColonyPartyBuff ~= nil then
		chkShowGuildInColonyPartyBuff:SetCheck(isShow);
	end

	config.SetShowGuildInColonyPartyBuff(isShow);
end

function SHOW_COLONY_GUILD_BUFF(frame)
	if IS_IN_EVENT_MAP() == true then
		return;
	end

	local isShow = config.GetShowGuildInColonyGuildBuff();
	local chkShowGuildInColonyGuildBuff = GET_CHILD_RECURSIVELY(frame, "chkShowGuildInColonyGuildBuff", "ui::CCheckBox");
	if chkShowGuildInColonyGuildBuff ~= nil then
		chkShowGuildInColonyGuildBuff:SetCheck(isShow);
	end

	config.SetShowGuildInColonyGuildBuff(isShow);
end

function SHOW_COLONY_ENEMY_BUFF(frame)
	if IS_IN_EVENT_MAP() == true then
		return;
	end

	local isShow = config.GetShowGuildInColonyEnemyBuff();
	local chkShowGuildInColonyEnemyBuff = GET_CHILD_RECURSIVELY(frame, "chkShowGuildInColonyEnemyBuff", "ui::CCheckBox");
	if chkShowGuildInColonyEnemyBuff ~= nil then
		chkShowGuildInColonyEnemyBuff:SetCheck(isShow);
	end

	config.SetShowGuildInColonyEnemyBuff(isShow);
end

function APPLY_COLONY_HP_INFO_SIZE(frame)    
	local guildinColonyPartyHpInfoRadioBtn = GET_CHILD_RECURSIVELY(frame, "guildInColonyPartyhpInfoSize_0");    
	local sizeType = GET_RADIOBTN_NUMBER(guildinColonyPartyHpInfoRadioBtn);
	config.SetShowGuildInColonyPartyHpGaugeSizeType(sizeType);
end
-- // Colony Option End // --

function SET_DMG_FONT_SCALE_CONTROLLER(frame)
	local value = config.GetDmgFontScale();
	local slide = GET_CHILD_RECURSIVELY(frame, "dmgFontSizeController", "ui::CSlideBar");
	slide:SetLevel(value * 100);
	
	local txt = GET_CHILD_RECURSIVELY(frame, "dmgFontSizeController_text", "ui::CRichText");
	local str = string.format("%.2f", value);
	txt:SetTextByKey("ctrlValue", str);
end

function CONFIG_DMG_FONT_SCALE_CONTROLLER(frame, ctrl, str, num)
	local scale = ctrl:GetLevel() * 0.01;
	config.SetDmgFontScale(scale);
	SET_DMG_FONT_SCALE_CONTROLLER(frame);
end

function SET_SHOW_PAD_SKILL_RANGE(frame)
	local isEnable = config.IsEnableShowPadSkillRange();
	local chkShowPadSkillRange = GET_CHILD_RECURSIVELY(frame, "chkShowPadSkillRange", "ui::CCheckBox");
	if nil ~= chkShowPadSkillRange then
		chkShowPadSkillRange:SetCheck(isEnable);
	end;
end

function CONFIG_SHOW_PAD_SKILL_RANGE(frame, ctrl, str, num)
	config.SetEnableShowPadSkillRange(ctrl:IsChecked());
end

function SET_SHOW_BOSS_SKILL_RANGE(frame)
	local isEnable = config.IsEnableShowBossSkillRange();
	local chkShowBossSkillRange = GET_CHILD_RECURSIVELY(frame, "chkShowBossSkillRange", "ui::CCheckBox");
	if nil ~= chkShowBossSkillRange then
		chkShowBossSkillRange:SetCheck(isEnable);
	end;
end

function CONFIG_SHOW_BOSS_SKILL_RANGE(frame, ctrl, str, num)
	config.SetEnableShowBossSkillRange(ctrl:IsChecked());
end

function SET_SIMPLIFY_BUFF_EFFECTS(frame)
	local isEnable = config.IsEnableSimplifyBuffEffects();
	local chkSimplifyBuffEffects = GET_CHILD_RECURSIVELY(frame, "chkSimplifyBuffEffects", "ui::CCheckBox");
	if nil ~= chkSimplifyBuffEffects then
		chkSimplifyBuffEffects:SetCheck(isEnable);
	end;
end

function CONFIG_SIMPLIFY_BUFF_EFFECTS(frame, ctrl, str, num)
	config.SetEnableSimplifyBuffEffects(ctrl:IsChecked());
end

function SET_SIMPLIFY_MODEL(frame)
	local isEnable = config.IsEnableSimplifyModel();
	local chkSimplifyModel = GET_CHILD_RECURSIVELY(frame, "chkSimplifyModel", "ui::CCheckBox");
	if nil ~= chkSimplifyModel then
		chkSimplifyModel:SetCheck(isEnable);
	end;
end

function CONFIG_SIMPLIFY_MODEL(frame, ctrl, str, num)
	config.SetEnableSimplifyModel(ctrl:IsChecked());
end

function SET_RENDER_SHADOW(frame)
    local isEnable = config.IsRenderShadow();
    imcperfOnOff.EnableRenderShadow(isEnable);
	local chkRenderShadow = GET_CHILD_RECURSIVELY(frame, "check_RenderShadow", "ui::CCheckBox");
	if nil ~= chkRenderShadow then
		chkRenderShadow:SetCheck(isEnable);
	end
end

function CONFIG_RENDER_SHADOW(frame, ctrl, str, num)
    local isEnable = ctrl:IsChecked();
    config.SetRenderShadow(isEnable);
    imcperfOnOff.EnableRenderShadow(isEnable);
	config.SaveConfig();
end

function ENABLE_SOUND_REVERB(parent, ctrl)
	local value = config.IsEnableSoundReverb();
	config.EnableSoundReverb(1-value);
	config.SaveConfig();
end

function CONFIG_QUESTINFOSET_TRANSPARENCY(frame, ctrl, str, num)
    tolua.cast(ctrl, "ui::CSlideBar");
	config.SetQuestinfosetTransparency(ctrl:GetLevel());
	SET_QUESTINFOSET_TRANSPARENCY(frame);
end

function SET_QUESTINFOSET_TRANSPARENCY(frame)
	SET_SLIDE_VAL(frame, "questinfosetTransparency", "questinfosetTransparency_text", config.GetQuestinfosetTransparency());
	UPDATE_QUESTINFOSET_TRANSPARENCY(nil)
end

function CONFIG_MY_EFFECT_TRANSPARENCY(frame, ctrl, str, num)
	tolua.cast(ctrl, "ui::CSlideBar");
	config.SetMyEffectTransparency(ctrl:GetLevel());

	SET_SLIDE_VAL(frame, "effect_transparency_my_value", "effect_transparency_my", config.GetMyEffectTransparency());
end

function CONFIG_OTHER_EFFECT_TRANSPARENCY(frame, ctrl, str, num)
	tolua.cast(ctrl, "ui::CSlideBar");
	config.SetOtherEffectTransparency(ctrl:GetLevel());
	
	SET_SLIDE_VAL(frame, "effect_transparency_other_value", "effect_transparency_other", config.GetOtherEffectTransparency());
end

function CONFIG_BOSSMON_EFECT_TRANSPARENCY(frame, ctrl, str, num)
	tolua.cast(ctrl, "ui::CSlideBar");
	config.SetBossMonsterEffectTransparency(ctrl:GetLevel());
	SET_SLIDE_VAL(frame, "effect_transparency_boss_monster_value", "effect_transparency_boss_monster", config.GetBossMonsterEffectTransparency());
end

function CONFIG_MAX_PARTICLES(frame, ctrl, str, num)
	local num = math.pow(2, ctrl:GetLevel())
	config.SetMaxParticles(num);

	local txt = GET_CHILD_RECURSIVELY(frame, "max_particles");
	txt:SetTextByKey("opValue", num);
end

function CONFIG_OTHER_PC_EFFECT(frame, ctrl, str, num)
	local isEnable = ctrl:IsChecked();
	if isEnable == 0 then
		local yesScp = "ENABLE_OTHER_PC_EFFECT_UNCHECK()";
		local noScp = "ENABLE_OTHER_PC_EFFECT_CHECK()";
		ui.MsgBox(ScpArgMsg("Ask_UnEnableOtherPCEffect_Text"), yesScp, noScp);
	end
end

function CONFIG_EFFECT_TRANSPARENCY(frame, ctrl, str, num)
	local isEnable = ctrl:IsChecked();
	if isEnable == 0 then
		EFFECT_TRANSPARENCY_OFF();
	else
		ui.MsgBox(ScpArgMsg("Ask_UnEnableEffectTransparency_Text"), "EFFECT_TRANSPARENCY_ON", "EFFECT_TRANSPARENCY_OFF");
	end
end

function EFFECT_TRANSPARENCY_ON()
	local frame = ui.GetFrame("systemoption");
	local effect_transparency_my_value = GET_CHILD_RECURSIVELY(frame, "effect_transparency_my_value", "ui::CSlideBar");
	effect_transparency_my_value:SetEnable(1);

	local effect_transparency_other_value = GET_CHILD_RECURSIVELY(frame, "effect_transparency_other_value", "ui::CSlideBar");
	effect_transparency_other_value:SetEnable(1);

	local effect_transparency_boss_monster_value = GET_CHILD_RECURSIVELY(frame, "effect_transparency_boss_monster_value", "ui::CSlideBar");
	effect_transparency_boss_monster_value:SetEnable(1);

	local effect_transparency_evolution_stone_effect_value = GET_CHILD_RECURSIVELY(frame, "evolution_stone_effect_value", "ui::CSlideBar");
	effect_transparency_evolution_stone_effect_value:SetEnable(1);
end

function EFFECT_TRANSPARENCY_OFF()
	local frame = ui.GetFrame("systemoption");
	local check_EnableEffectTransparency = GET_CHILD_RECURSIVELY(frame, "check_EnableEffectTransparency", "ui::CSlideBar");
	check_EnableEffectTransparency:SetCheck(0);

	local effect_transparency_my_value = GET_CHILD_RECURSIVELY(frame, "effect_transparency_my_value", "ui::CSlideBar");
	effect_transparency_my_value:SetLevel(255);
	CONFIG_MY_EFFECT_TRANSPARENCY(frame, effect_transparency_my_value, "", 0);
	effect_transparency_my_value:SetEnable(0);
	
	local effect_transparency_other_value = GET_CHILD_RECURSIVELY(frame, "effect_transparency_other_value", "ui::CSlideBar");
	effect_transparency_other_value:SetLevel(255);
	CONFIG_OTHER_EFFECT_TRANSPARENCY(frame, effect_transparency_other_value, "", 0);
	effect_transparency_other_value:SetEnable(0);

	local effect_transparency_boss_monster_value = GET_CHILD_RECURSIVELY(frame, "effect_transparency_boss_monster_value", "ui::CSlideBar");
	effect_transparency_boss_monster_value:SetLevel(255);
	CONFIG_BOSSMON_EFECT_TRANSPARENCY(frame, effect_transparency_boss_monster_value, "", 0);
	effect_transparency_boss_monster_value:SetEnable(0);

	local effect_transparency_evolution_stone_effect_value = GET_CHILD_RECURSIVELY(frame, "evolution_stone_effect_value", "ui::CSlideBar");
	effect_transparency_evolution_stone_effect_value:SetLevel(255);
	CONFIG_EVOLUTIONSONTE_EFFECT(frame, effect_transparency_evolution_stone_effect_value, "", 150);
	effect_transparency_evolution_stone_effect_value:SetEnable(0);
end

function CONFIG_TEXTEFFECT_NOT_SHOW(frame, ctrl, str, num)
	local isEnable = ctrl:IsChecked();
    config.SetUnVisibleTextEffect(isEnable);
	config.SaveConfig();
end

function SET_ENABLE_DAYLIGHT_OPTION(frame, ctrl, str, num)
	local isEnable = ctrl:IsChecked();
    config.SetEnableDayLight(isEnable);
	config.SaveConfig();
end

function CONFIG_COOLDOWN_DECIMAL_POINT_SEC(frame, ctrl, str, num)
	tolua.cast(ctrl, "ui::CSlideBar")
	config.SetCoolDownDecimalPointSec(ctrl:GetLevel())
	SET_COOLDOWN_DECIMAL_POINT_SEC(frame)
end

function SET_COOLDOWN_DECIMAL_POINT_SEC(frame)
	local value = config.GetCoolDownDecimalPointSec()
	local slide = GET_CHILD_RECURSIVELY(frame, "coolDownDecimalPointSec", "ui::CSlideBar")
	slide:SetLevel(value)
	local txt = GET_CHILD_RECURSIVELY(frame, "coolDownDecimalPointSec_text", "ui::CRichText")
	if value <= 0 then
		txt:SetTextByKey("opValue", ClMsg("NONE"))
	else
		txt:SetTextByKey("opValue", ScpArgMsg("LowerThan{SEC}", "SEC", value))
	end
end

function SET_ENABLE_SUMMON_ALPHA(parent, ctrl)
	local isEnable = ctrl:IsChecked();
    config.SetIsEnableSummonAlpha(isEnable);
	config.SaveConfig();
end

function CONFIG_EVOLUTIONSONTE_EFFECT(frame, ctrl, str, num)
	tolua.cast(ctrl, "ui::CSlideBar");
	config.SetEvolutionStoneEffect(ctrl:GetLevel());
	SET_SLIDE_VAL(frame, "evolution_stone_effect_value", "evolution_stone_effect", config.GetEvolutionStoneEffect());
	save_evolution_stone_effect_value(ctrl:GetLevel())
end

function SET_USE_URO(parent, ctrl)
	local isEnable = ctrl:IsChecked();
    config.SetUseURO(isEnable);
	config.SaveConfig();
end

function CONFIG_ENABLE_AUTO_CASTING(parent, ctrl)
	local enable = ctrl:IsChecked()
	config.SetEnableAutoCasting(enable)
	config.SaveConfig()
end

function SET_ENABLE_AUTO_CASTING(frame)
	local Check_EnableAutoCasting = GET_CHILD_RECURSIVELY(frame, "Check_EnableAutoCasting", "ui::CCheckBox")
	if Check_EnableAutoCasting ~= nil then
		Check_EnableAutoCasting:SetCheck(config.GetEnableAutoCasting())
	end
end

-- 아이템 획득 팝업
function CONFIG_POPUP_PICK_ITEM(parent, ctrl)
	local enable = ctrl:IsChecked()		
	config.SetPopupPickItem(enable)
	config.SaveConfig()
end
function SET_POPUP_PICK_ITEM(frame)
	local Check_PopupPickItem = GET_CHILD_RECURSIVELY(frame, "Check_PopupPickItem", "ui::CCheckBox")
	if Check_PopupPickItem ~= nil then
		Check_PopupPickItem:SetCheck(config.GetPopupPickItem())
	end
end
-- 아이템 획득 메시지
function CONFIG_PICK_ITEM_MESSAGE(parent, ctrl)
	local enable = ctrl:IsChecked()		
	config.SetPickItemMessage(enable)
	config.SaveConfig()
end
function SET_PICK_ITEM_MESSAGE(frame)		
	local Check_PickItemMessage = GET_CHILD_RECURSIVELY(frame, "Check_PickItemMessage", "ui::CCheckBox")
	if Check_PickItemMessage ~= nil then
		Check_PickItemMessage:SetCheck(config.GetPickItemMessage())
	end
end
-- 성물(마력) 자동 충전
function CONFIG_RELIC_AUTO_CHARGE(parent, ctrl)
	local enable = ctrl:IsChecked()		
	config.SetRelicAutoCharge(enable)
	config.SaveConfig()
end
function SET_RELIC_AUTO_CHARGE(frame)
	local Check_RelicAutoCharge = GET_CHILD_RECURSIVELY(frame, "Check_RelicAutoCharge", "ui::CCheckBox")
	if Check_RelicAutoCharge ~= nil then
		Check_RelicAutoCharge:SetCheck(config.GetRelicAutoCharge())
	end
end
-- 튜토리얼 UI 보기
-- ShowTutorialnote
function CONFIG_SHOW_TUORIAL_NOTE(parent, ctrl)
	local enable = ctrl:IsChecked()
	config.SetShowTutorialnote(enable)
	config.SaveConfig()
end



function CLICK_FIX_HEADSUPDISPLAY_BUTTON(frame, check_box, str, num)
	local is_checked = check_box:IsChecked()
	
	if is_checked == 1 then
		frame:EnableMove(false)
		save_fix_headsupdisplay_value(1)
	else
		frame:EnableMove(true)
		save_fix_headsupdisplay_value(0)
	end
end

function save_fix_headsupdisplay_value(value)		
	local t = system_option_setting.Settings.pc_id[session.GetMySession():GetCID()]
	if t == nil then		
		system_option_setting.Settings.pc_id[session.GetMySession():GetCID()] = {}
	end

	if system_option_setting.Settings.pc_id[session.GetMySession():GetCID()]['evolution_stone_effect_value'] == nil then
		system_option_setting.Settings.pc_id[session.GetMySession():GetCID()]["evolution_stone_effect_value"] = {}	
	end
	system_option_setting.Settings.pc_id[session.GetMySession():GetCID()]["evolution_stone_effect_value"]['fix_hud'] = value	
    save_json(system_option_setting.SettingsFileLocation, system_option_setting.Settings);
end

function load_fix_headsupdisplay_value()
	local t = system_option_setting.Settings.pc_id[session.GetMySession():GetCID()]
	if t == nil then		
		return
	end

	if system_option_setting.Settings.pc_id[session.GetMySession():GetCID()]['evolution_stone_effect_value'] == nil then
		return
	end

	if system_option_setting.Settings.pc_id[session.GetMySession():GetCID()]["evolution_stone_effect_value"]['fix_hud'] == nil then
		return
	end
	local value = system_option_setting.Settings.pc_id[session.GetMySession():GetCID()]["evolution_stone_effect_value"]['fix_hud']
	local frame = ui.GetFrame('headsupdisplay')
	if value == 1 then		
		if frame ~= nil then
			local check_box = GET_CHILD_RECURSIVELY(frame, 'fix_pos')
			if check_box ~= nil then
				frame:EnableMove(false)
				check_box:SetCheck(1)
			end
		end
	else
		if frame ~= nil then
			local check_box = GET_CHILD_RECURSIVELY(frame, 'fix_pos')
			if check_box ~= nil then
				frame:EnableMove(true)
				check_box:SetCheck(0)
			end
		end
	end	
end
function CLICK_OnlySameNationChat_BOX(frame, check_box, str, num)
	local is_checked = check_box:IsChecked()
	
	if is_checked == 1 then		
		save_OnlySameNationChat_value(1)
	else		
		save_OnlySameNationChat_value(0)
	end
end

function save_translation_language_value(value)
	local t = system_option_setting.Settings.pc_id[session.GetMySession():GetCID()]
	if t == nil then		
		system_option_setting.Settings.pc_id[session.GetMySession():GetCID()] = {}
	end

	if system_option_setting.Settings.pc_id[session.GetMySession():GetCID()]['evolution_stone_effect_value'] == nil then
		system_option_setting.Settings.pc_id[session.GetMySession():GetCID()]["evolution_stone_effect_value"] = {}	
	end
	system_option_setting.Settings.pc_id[session.GetMySession():GetCID()]["evolution_stone_effect_value"]['translateLanguage'] = value	
    save_json(system_option_setting.SettingsFileLocation, system_option_setting.Settings);
end

function load_translation_language_value(value)
	local t = system_option_setting.Settings.pc_id[session.GetMySession():GetCID()]
	if t == nil then		
		return
	end

	if system_option_setting.Settings.pc_id[session.GetMySession():GetCID()]['evolution_stone_effect_value'] == nil then
		return
	end

	if system_option_setting.Settings.pc_id[session.GetMySession():GetCID()]["evolution_stone_effect_value"]['translateLanguage'] == nil then
		return
	end
	local value = system_option_setting.Settings.pc_id[session.GetMySession():GetCID()]["evolution_stone_effect_value"]['translateLanguage']
	
	item_etc_shared.set_language_translate_code(value)
	local code = item_etc_shared.get_language_translate_code()
	local frame = ui.GetFrame("chatframe")
	local lang_txt = GET_CHILD_RECURSIVELY(frame,"curr_language_txt")
	lang_txt:SetTextByKey("value",code)
end


function save_OnlySameNationChat_value(value)		
	local t = system_option_setting.Settings.pc_id[session.GetMySession():GetCID()]
	if t == nil then		
		system_option_setting.Settings.pc_id[session.GetMySession():GetCID()] = {}
	end

	if system_option_setting.Settings.pc_id[session.GetMySession():GetCID()]['evolution_stone_effect_value'] == nil then
		system_option_setting.Settings.pc_id[session.GetMySession():GetCID()]["evolution_stone_effect_value"] = {}	
	end
	system_option_setting.Settings.pc_id[session.GetMySession():GetCID()]["evolution_stone_effect_value"]['OnlySameNationChat'] = value	
    save_json(system_option_setting.SettingsFileLocation, system_option_setting.Settings);
end

function load_OnlySameNationChat_value()
	local t = system_option_setting.Settings.pc_id[session.GetMySession():GetCID()]
	if t == nil then		
		return
	end

	if system_option_setting.Settings.pc_id[session.GetMySession():GetCID()]['evolution_stone_effect_value'] == nil then
		return
	end

	if system_option_setting.Settings.pc_id[session.GetMySession():GetCID()]["evolution_stone_effect_value"]['OnlySameNationChat'] == nil then
		return
	end
	local value = system_option_setting.Settings.pc_id[session.GetMySession():GetCID()]["evolution_stone_effect_value"]['OnlySameNationChat']
	local frame = ui.GetFrame('systemoption')
	local check_box = GET_CHILD_RECURSIVELY(frame, 'OnlySameNationChat')
	if value == 1 then							
		check_box:SetCheck(1)
	else
		check_box:SetCheck(0)
	end	
end

function IS_ABLE_TO_DISPLAY_CHAT(from_nation, msg_type)	
	local frame = ui.GetFrame('systemoption')
	local check_box = GET_CHILD_RECURSIVELY(frame, 'OnlySameNationChat')
	if check_box:IsChecked() == 0 then
		return true
	end
	
	if config.GetServiceNation() == from_nation then
		return true
	end

	-- Party, Guild
	if msg_type == 'Normal' or msg_type == 'Shout' then -- 일반, 외침
		return false
	else
		return true
	end
end