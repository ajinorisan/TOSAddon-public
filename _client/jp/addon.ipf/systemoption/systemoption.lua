function SYSTEMOPTION_ON_INIT(addon, frame)
	addon:RegisterMsg('IES_VALUE_CHANGE', 'UPDATE_OPERATOR_CONFIG');
	INIT_GAMESYS_CONFIG(frame);
end

function SYSTEMOPTION_CREATE(frame)

	local bg2 = GET_CHILD_RECURSIVELY(frame, "bg2", "ui::CGroupBox")
	bg2:SetScrollPos(0)
	INIT_SCREEN_CONFIG(frame);
	INIT_SOUND_CONFIG(frame);
	INIT_LANGUAGE_CONFIG(frame);
	INIT_GRAPHIC_CONFIG(frame);
	INIT_CONTROL_CONFIG(frame);
	SET_SKL_CTRL_CONFIG(frame);
        SET_AUTO_CELL_SELECT_CONFIG(frame);
    	SET_DMG_FONT_SCALE_CONTROLLER(frame);
	SET_SHOW_PAD_SKILL_RANGE(frame);
	SET_SIMPLIFY_BUFF_EFFECTS(frame);
	SET_SIMPLIFY_MODEL(frame);
	SET_RENDER_SHADOW(frame);
	SET_QUESTINFOSET_TRANSPARENCY(frame);
end

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

		local lanUIString = option.GetPossibleCountryUIName(i);
		catelist:AddItem(i, lanUIString);

		local lanString = option.GetPossibleCountry(i);

		if option.GetCurrentCountry() == lanString then
			selIndex = i;
		end
	end

	catelist:SelectItem(selIndex);

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
		local resString = string.format("{@st42b}%d * %d{/}", width, height);
		catelist:AddItem(i, resString);

		if curWidth == width and curHeight == height then
			selIndex = i;
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
end

function INIT_GAMESYS_CONFIG(frame)
	local skillGizmoTargetAim = GET_CHILD_RECURSIVELY(frame, "check_SkillGizmoTargetAim", "ui::CCheckBox");
	if skillGizmoTargetAim ~= nil then
		local value = config.GetXMLConfig("EnableSkillGizmoTargetAim");
		skillGizmoTargetAim:SetCheck(tonumber(value));
		config.EnableSkillGizmoTargetAim(tonumber(value));
		config.ChangeXMLConfig("EnableSkillGizmoTargetAim", tostring(value));
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

function INIT_CONTROL_CONFIG(frame)
	local modeValue = config.GetXMLConfig("ControlMode");
	local getGroup = GET_CHILD_RECURSIVELY(frame, "pipwin_low", "ui::CGroupBox")
	local radioBtn = GET_CHILD_RECURSIVELY(frame, "controltype_" .. modeValue);
	radioBtn:SetCheck(true);
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
	UPDATE_CONTROL_MODE();
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

function SHOW_PERFORMANCE_VALUE(frame)
	local flag = config.GetXMLConfig("ShowPerformanceValue")
	SHOW_FPS_FRAME(flag)
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
	local lanIndex = lanCtrl:GetSelItemIndex();
	local lanString = option.GetPossibleCountry(lanIndex);
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

function UPDATE_OPERATOR_CONFIG(frame)
	
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

	local scrRadioBtn = GET_CHILD_RECURSIVELY(frame, "scrtype_1" , "ui::CRadioButton");
	local resCtrl = GET_CHILD_RECURSIVELY(frame, "resolutionList", "ui::CDropList");        
	local scrType = GET_RADIOBTN_NUMBER(scrRadioBtn);
	local resIndex = resCtrl:GetSelItemIndex();
	option.SetDisplayMode(scrType, resIndex, syncType);

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

	effect.ShowColonyEffectCostume();
end

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

function CONFIG_OTHER_PC_EFFECT(frame, ctrl, str, num)
	local isEnable = ctrl:IsChecked();
	if isEnable == 0 then
		local yesScp = "ENABLE_OTHER_PC_EFFECT_UNCHECK()";
		local noScp = "ENABLE_OTHER_PC_EFFECT_CHECK()";
		ui.MsgBox(ScpArgMsg("Ask_UnEnableOtherPCEffect_Text"), yesScp, noScp);
	end
end