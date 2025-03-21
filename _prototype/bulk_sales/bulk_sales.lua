local addon_name = "BULK_SALES"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "1.0.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]

function g.mkdir_new_folder()
    local function create_folder(folder_path, file_path)
        local file = io.open(file_path, "r")
        if not file then
            os.execute('mkdir "' .. folder_path .. '"')
            file = io.open(file_path, "w")
            if file then
                file:write("A new file has been created")
                file:close()
            end
        else
            file:close()
        end
    end
    local folder = string.format("../addons/%s", addon_name_lower)
    local file_path = string.format("../addons/%s/mkdir.txt", addon_name_lower)
    create_folder(folder, file_path)

    local active_id = session.loginInfo.GetAID()
    local user_folder = string.format("../addons/%s/%s", addon_name_lower, active_id)
    local user_file_path = string.format("../addons/%s/%s/mkdir.txt", addon_name_lower, active_id)
    create_folder(user_folder, user_file_path)
end
g.mkdir_new_folder()

function g.setup_hook(my_func, origin_func_name)

    local original_func = _G[origin_func_name]
    local function hooked_function(...)
        -- print(origin_func_name .. " が呼び出されました。")
        my_func(...)
        _G[origin_func_name] = original_func
    end
    _G[origin_func_name] = hooked_function
end

function g.save_json(path, tbl)

    local file = io.open(path, "w")
    local str = json.encode(tbl)
    file:write(str)
    file:close()
end

function g.load_json(path)

    local file = io.open(path, "r")

    if file then
        local content = file:read("*all")
        file:close()
        local table = json.decode(content)
        return table
    else
        return nil
    end
end

function g.save_settings()
    g.save_json(g.settings_path, g.settings)
end

function g.load_settings()

    local settings = g.load_json(g.settings_path)

    if not settings then
        settings = {}
    end

    g.settings = settings
    g.save_settings()
end

function BULK_SALES_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.lang = option.GetCurrentCountry()
    g.cid = session.GetMySession():GetCID()
    g.login_name = session.GetMySession():GetPCApc():GetName()

    addon:RegisterMsg('DIALOG_CLOSE', 'bulk_sales_SHOP_ON_MSG');
end

function bulk_sales_SHOP_ON_MSG(frame, msg, str, num)

    if msg ~= "" then
        return
    end

    local frame = ui.GetFrame("bulk_sales")

    frame:SetSkinName("None")
    frame:SetTitleBarSkin("None")

    local slotset = frame:CreateOrGetControl('slotset', 'slotset', 0, 0, 0, 0)
    AUTO_CAST(slotset);
    slotset:EnablePop(1)
    slotset:EnableDrag(1)
    slotset:EnableDrop(1)
    slotset:EnableHitTest(1);
    slotset:SetColRow(10, 20)
    slotset:SetSlotSize(40, 40)
    slotset:SetSpc(1, 1)
    slotset:SetSkinName('invenslot2')
    slotset:CreateSlots()

    frame:Resize(slotset:GetWidth() + 10, slotset:GetHeight() + 10)
    frame:ShowWindow(1)
end
