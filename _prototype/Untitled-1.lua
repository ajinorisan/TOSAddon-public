-- 錬成アイテムセット
acutil.setupEvent(addon, "COMMON_SKILL_ENCHANT_MAT_SET", "MINI_ADDONS_COMMON_SKILL_ENCHANT_MAT_SET");
acutil.setupEvent(addon, "SUCCESS_COMMON_SKILL_ENCHANT", "MINI_ADDONS_SUCCESS_COMMON_SKILL_ENCHANT");

function MINI_ADDONS_COMMON_SKILL_ENCHANT_MAT_SET(frame, msg)
    local itemObj = acutil.getEventArgs(msg)
    local frame = ui.GetFrame('common_skill_enchant')

    ReserveScript(string.format("COMMON_SKILL_ENCHANT_ADD_MAT('%s')", frame), 0.2)
end

function MINI_ADDONS_SUCCESS_COMMON_SKILL_ENCHANT(frame, msg)
    local msg, arg_str, arg_num = acutil.getEventArgs(msg)
    local frame = ui.GetFrame('common_skill_enchant')
    print(tostring(msg))
    print(tostring(arg_str))
    print(tostring(arg_num))

    ReserveScript(string.format("COMMON_SKILL_ENCHANT_ADD_MAT('%s')", frame), 0.9)

end

-- 加護ガチャ
local mapprop = session.GetCurrentMapProp();
local mapCls = GetClassByType("Map", mapprop.type);
if IS_GODPROTECTION_MAP(mapCls) ~= false then

    addon:RegisterMsg('FIELD_BOSS_WORLD_EVENT_START', 'MINI_ADDONS_GP_DO_OPEN');

end
function MINI_ADDONS_GP_DO_OPEN()
    ReserveScript("GODPROTECTION_DO_OPEN()", 2.0);
    ReserveScript("MINI_ADDONS_GP_AUTOSTART()", 3.0)
    return
end

function MINI_ADDONS_GP_AUTOSTART()
    local frame = ui.GetFrame("godprotection")

    local multiple_count = 20
    GODPROTECTION_MULTI_COUNT_UPDATE(frame, multiple_count)

    local edit = GET_CHILD_RECURSIVELY(frame, "auto_edit");
    local count = 99999999
    local next_count = count - 1;
    edit:SetText(next_count);

    local parent = GET_CHILD_RECURSIVELY(frame, "auto_gb");
    local auto_btn = GET_CHILD_RECURSIVELY(frame, "auto_btn")
    GODPROTECTION_AUTO_START_BTN_CLICK(parent, auto_btn)

    if auto_btn:IsEnable() == 1 then
        ReserveScript("MINI_ADDONS_GP_AUTOSTART()", 1.0)
        return
    else
        return
    end

end
