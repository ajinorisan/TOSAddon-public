-----큐폴 UI등록
function CUPOLE_RANKUP_SCENE_ON_INIT(addon,frame)
    addon:RegisterMsg('SET_CUPOLE_EXP_UP', 'ON_SET_CUPOLE_EXP_UP_PLAY_SCENE');
end

function ON_SET_CUPOLE_EXP_UP_PLAY_SCENE(frame, msg, argStr, argNum)
    ui.OpenFrame("cupole_rankup_scene");
    local cupole_rankup_scene = ui.GetFrame("cupole_rankup_scene");
    local select_index = GET_GLOBAL_SELECT_CUPOLE();    
    local kupole = GET_CUPOLE_CLASS_BY_INDEX(select_index)
    local Name = TryGetProp(kupole, "ClassName", "None")

    CUPOLE_POSE(Name.."_Render", "celebration")


    CHNAGE_ALL_CUPOLE_UIMODEL_STATE(2);
end

function OPEN_CUPOLE_RANKUP_SCENE(frame)
    frame:RunUpdateScript("UPDATE_CUPOLE")
    local NameTxt = GET_CHILD_RECURSIVELY(frame,"Name")
    local select_index = GET_GLOBAL_SELECT_CUPOLE();    
    local kupole = GET_CUPOLE_CLASS_BY_INDEX(select_index)
    local Name = TryGetProp(kupole, "Dec_Name", "None")
    local EffectBG = GET_CHILD_RECURSIVELY(frame,"EffectBG")
    local MainEffectBG = GET_CHILD_RECURSIVELY(frame,"MainEffectBG")

    
    NameTxt:SetTextByKey("name", Name)

    EffectBG:PlayUIEffect("UI_Kupole_RankUp", 2.5, "UI_Kupole_RankUp")
    MainEffectBG:PlayUIEffect("UI_Kupole_LevelUp", 12, "UI_Kupole_LevelUp")
    frame:RunUpdateScript("ACTIVATE_CUPOLE_RANKUP_SCENE",0.75)

end

function CLOSE_CUPOLE_RANKUP_SCENE(frame)
    frame:StopUpdateScript('UPDATE_CUPOLE')

    local select_index = GET_GLOBAL_SELECT_CUPOLE();    
    local kupole = GET_CUPOLE_CLASS_BY_INDEX(select_index)
    local Name = TryGetProp(kupole, "ClassName", "None")
    local EffectBG = GET_CHILD_RECURSIVELY(frame,"EffectBG")
    local MainEffectBG = GET_CHILD_RECURSIVELY(frame,"MainEffectBG")
    local bgimg = GET_CHILD_RECURSIVELY(frame, "bgimg")
    
    CUPOLE_POSE(Name.."_Render", "std")
    CHNAGE_ALL_CUPOLE_UIMODEL_STATE(1);

    EffectBG:StopUIEffect("UI_Kupole_RankUp", true, 0.5);
    MainEffectBG:StopUIEffect("UI_Kupole_LevelUp", true, 0.5);
    bgimg:SetEventScript(ui.LBUTTONUP, "None");

end

function PRESS_CLOSE_BTN(parent, ctrl, argStr, argNum)
    ui.CloseFrame("cupole_rankup_scene")
end

function ACTIVATE_CUPOLE_RANKUP_SCENE(frame,elapsedTime)
    local bgimg = GET_CHILD_RECURSIVELY(frame, "bgimg")
    bgimg:SetEventScript(ui.LBUTTONUP, "END_CUPOLE_RANKUP_SCENE");
    return 0;
end
 
function END_CUPOLE_RANKUP_SCENE(frame, ctrl, argStr, argNum)
    ui.CloseFrame("cupole_rankup_scene")
end