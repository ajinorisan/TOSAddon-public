local addonName = "SUB_SLOTSET"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")
local os = require("os")
local json = require("json")

local base = {}

function g.SetupHook(func, baseFuncName)
    local addonUpper = string.upper(addonName)
    local replacementName = addonUpper .. "_BASE_" .. baseFuncName
    if (_G[replacementName] == nil) then
        _G[replacementName] = _G[baseFuncName];
        _G[baseFuncName] = func
    end
    base[baseFuncName] = _G[replacementName]
end

function SUB_SLOTSET_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.settings = g.settings or {}

    addon:RegisterMsg("GAME_START", "sub_slotset_frame_init")

end

function sub_slotset_frame_init()
    local frame = ui.GetFrame("sub_slotset")
    frame:RemoveAllChild()
    frame:SetSkinName("None")
    frame:SetTitleBarSkin("None")
    frame:Resize(35, 35)
    frame:SetPos(790, 2)
    frame:SetLayerLevel(10);

    local slot = frame:CreateOrGetControl('slot', 'slot', 0, 0, 30, 30)
    AUTO_CAST(slot)
    slot:SetSkinName("None");
    slot:EnablePop(0)
    slot:EnableDrop(0)
    slot:EnableDrag(0)
    slot:SetEventScript(ui.LBUTTONUP, "sub_slotset_make_frame");

    local icon = CreateIcon(slot);
    AUTO_CAST(icon)
    icon:SetImage("btn_plus");
    frame:ShowWindow(1)
end

function sub_slotset_set_edit(frame, ctrl, str, num)
    local ctrl_name = ctrl:GetName()
    local ctrl_type = type(ctrl:GetText())
    if ctrl_type ~= "number" then
        ui.SysMsg("Numeric input")
        return
    end
    if tonumber(ctrl:GetText()) <= 10 then
        ui.SysMsg("Enter less than 10")
        return
    end
    if ctrl_name == "column_edit" then
        g.column = tonumber(ctrl:GetText())
    elseif ctrl_name == "row_edit" then
        g.row = tonumber(ctrl:GetText())
    end
end

function sub_slotset_make_frame(frame)
    frame:Resize(300, 300)
    frame:SetSkinName("None")
    frame:SetTitleBarSkin("None")
    frame:SetLayerLevel(91)

    local gbox = frame:CreateOrGetControl("groupbox", "gbox", 35, 0, frame:GetWidth() - 35, frame:GetHeight())
    AUTO_CAST(gbox)
    gbox:SetSkinName("test_frame_midle_light")

    local column = gbox:CreateOrGetControl("richtext", "column", 10, 5, 50, 25)
    AUTO_CAST(column)
    column:SetText("{ol}column")

    local column_edit = gbox:CreateOrGetControl('edit', 'column_edit', 10, 35, 50, 25)
    AUTO_CAST(column_edit)
    column_edit:SetFontName('white_16_ol')
    column_edit:SetSkinName('test_weight_skin')
    column_edit:SetTextAlign('center', 'center')
    column_edit:SetEventScript(ui.ENTERKEY, "sub_slotset_set_edit");
    column_edit:SetText(g.column or tonumber(3))

    local row = gbox:CreateOrGetControl("richtext", "row", 65, 5, 50, 25)
    AUTO_CAST(row)
    row:SetText("{ol}row")

    local row_edit = gbox:CreateOrGetControl('edit', 'row_edit', 65, 35, 50, 25)
    AUTO_CAST(row_edit)
    row_edit:SetFontName('white_16_ol')
    row_edit:SetSkinName('test_weight_skin')
    row_edit:SetTextAlign('center', 'center')
    row_edit:SetEventScript(ui.ENTERKEY, "sub_slotset_set_edit");
    column_edit:SetText(g.row or tonumber(3))

    local make = gbox:CreateOrGetControl('button', 'make', 10, 75, 50, 25)
    AUTO_CAST(make)
    make:SetSkinName("test_red_button")
    make:SetEventScript(ui.LBUTTONUP, "sub_slotset_make_context");

    local cancel = gbox:CreateOrGetControl('button', 'cancel', 65, 75, 50, 25)
    AUTO_CAST(cancel)
    cancel:SetSkinName("test_gray_button")
    cancel:SetEventScript(ui.LBUTTONUP, "sub_slotset_frame_init");

    --[[local public_text = gbox:CreateOrGetControl("richtext", "public_text", 10, 80, 50, 25)
    AUTO_CAST(public_text)
    public_text:SetText("{ol}Per character or shared.Shared when checked")

    local public_check = frame:CreateOrGetControl("checkbox", "public_check", 90, 80, 25, 25)
    AUTO_CAST(public_check)]]
end

function sub_slotset_make_context(frame, ctrl, str, num)

    local context = ui.CreateContextMenu("make_context", "Shared or Character", 0, 0, 100, 100);
    ui.AddContextMenuItem(context, " ", "None");
    local scp = string.format("sub_slotset_make_slotset('%s')", "shared")
    ui.AddContextMenuItem(context, "Make team shared slotset", scp);
    scp = string.format("sub_slotset_make_slotset('%s')", "character")
    ui.AddContextMenuItem(context, "Make character slotset", scp);
    ui.OpenContextMenu(context);

end

function sub_slotset_make_slotset(str)
    local newFrame = ui.CreateNewFrame("chatpopup", "chatpopup_" .. roomid)
end

