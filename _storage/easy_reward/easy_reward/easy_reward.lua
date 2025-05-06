-- v1.0.3 均等割り付けエディット追加
local addonName = "easy_reward"
local addon_name_lower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.3"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local json = require('json')

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
end
g.mkdir_new_folder()

function g.setup_hook_and_event(my_addon, origin_func_name, my_func_name, bool)

    g.FUNCS = g.FUNCS or {}
    if not g.FUNCS[origin_func_name] then
        g.FUNCS[origin_func_name] = _G[origin_func_name]
    end
    local origin_func = g.FUNCS[origin_func_name]
    local function hooked_function(...)

        local original_results

        if bool == true then
            original_results = {origin_func(...)}
        end

        g.ARGS = g.ARGS or {}
        g.ARGS[origin_func_name] = {...}
        imcAddOn.BroadMsg(origin_func_name)

        if bool == true and original_results ~= nil then
            return table.unpack(original_results)
        else
            return
        end
    end

    _G[origin_func_name] = hooked_function

    if not g.RAGISTER[origin_func_name] then -- g.RAGISTERはON_INIT内で都度初期化
        g.RAGISTER[origin_func_name] = true
        my_addon:RegisterMsg(origin_func_name, my_func_name)
    end
end

function g.get_event_args(origin_func_name)
    local args = g.ARGS[origin_func_name]
    if args then
        return table.unpack(args)
    end
    return nil
end

function EASY_REWARD_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame

    g.lang = option.GetCurrentCountry()
    -- g.lang = "en"
    g.RAGISTER = {}
    g.members = {}
    g.setup_hook_and_event(addon, "GUILDINVEN_SEND_INIT_MEMBER", "easy_reward_GUILDINVEN_SEND_INIT_MEMBER", false)
    g.setup_hook_and_event(addon, "GUILDINVEN_SEND_CLICK", "easy_reward_GUILDINVEN_SEND_CLICK", false)
    g.setup_hook_and_event(addon, "GUILDINVEN_SEND_TYPING", "easy_reward_GUILDINVEN_SEND_TYPING", true)

end

function g.log_to_file(message)

    local time = os.date("%Y%m%d")
    local file_path = string.format("../addons/%s/log_%s.txt", addon_name_lower, time)
    local file = io.open(file_path, "a")

    if file then
        local timestamp = os.date("[%Y-%m-%d %H:%M:%S] ")
        file:write(timestamp .. tostring(message) .. "\n")
        file:close()
    end
end

function easy_reward_GUILDINVEN_SEND_CLICK(parent, ctrl)

    local frame = ui.GetFrame('guildinven_send')

    local itemID = frame:GetUserValue('ITEM_ID');
    if itemID == 'None' then
        return;
    end

    if session.colonywar.GetProgressState() == true then
        local colonyRewardItem = GetClass('Item', GET_COLONY_REWARD_ITEM());
        if colonyRewardItem.ClassID == itemID then
            ui.SysMsg(ClMsg('CannotSendColonyReward'));
            return;
        end
    end

    local remainText = GET_CHILD_RECURSIVELY(frame, 'remainText');
    local remainCount = tonumber(remainText:GetTextByKey('count'));
    if remainCount == nil or remainCount < 0 then
        ui.SysMsg(ClMsg('LackOfHaveCount'));
        return;
    end

    local listBox = GET_CHILD_RECURSIVELY(frame, 'listBox');
    local listCount = listBox:GetChildCount();
    local aidList = {};
    local countList = {};

    local itemNameText = GET_CHILD_RECURSIVELY(frame, "itemNameText")
    local item_name = itemNameText:GetText()

    for i = 0, listCount - 1 do
        local child = listBox:GetChildByIndex(i);
        if child ~= nil and string.find(child:GetName(), 'ITEMSEND_') ~= nil then
            local aid = child:GetUserValue('MEMBER_AID');
            local sendCheck = GET_CHILD(child, 'sendCheck');
            local countEdit = child:GetChild('countEdit');
            local countValue = countEdit:GetText();
            if aid ~= 'None' and sendCheck:IsChecked() == 1 and countValue ~= nil and countValue ~= '' then
                aidList[#aidList + 1] = aid;
                countList[#countList + 1] = tonumber(countValue);
                local nameText = child:GetChild('nameText');
                local name = nameText:GetText();
                local msg = g.lang == "Japanese" and "個" or "pcs"
                local message = name .. ":" .. item_name .. ":" .. tonumber(countValue) .. msg
                g.log_to_file(message)
            end
        end
    end
    local itemGUID = frame:GetUserValue('ITEM_ID');
    ReqGuildInventorySend(itemGUID, aidList, countList);
    ui.CloseFrame('guildinven_send');
    local number_edit = GET_CHILD_RECURSIVELY(frame, 'number_edit')
    AUTO_CAST(number_edit)
    number_edit:SetText("0")
    easy_reward_count_clear(frame, ctrl, nil, nil)
end

function easy_reward_GUILDINVEN_SEND_TYPING(frame, orgfuncname)
    local parent, edit = g.get_event_args(orgfuncname)

    local aid = string.gsub(parent:GetName(), "ITEMSEND_", "")
    local sendCheck = GET_CHILD(parent, 'sendCheck');
    local ischeck = sendCheck:IsChecked()
    g.members[aid] = {
        ischeck = ischeck,
        item_count = tonumber(edit:GetText())
    }
    g.members.count = 0
    for key, value in pairs(g.members) do
        if type(value) == "table" then
            if value.ischeck == 1 then
                g.members.count = g.members.count + 1
            end
        end
    end

    local frame = parent:GetTopParentFrame()
    local selectcount = GET_CHILD(frame, 'selectcount')
    AUTO_CAST(selectcount)
    selectcount:SetFontName("black_18_b")
    local msg = (g.lang == "Japanese" and "選択人数: " or "Choices: ")
    selectcount:SetText(msg .. g.members.count)
    GUILDINVEN_SEND_UPDATE_COUNT_BOX(frame)
end

function easy_reward_member_list(frame, ctrl, aid, num)

    local ischeck = ctrl:IsChecked()
    if ctrl:GetName() == "div_check" then
        g.members.check = ischeck
        easy_reward_GUILDINVEN_SEND_INIT_MEMBER(frame)
    else
        local ctrl_set = ctrl:GetParent()
        local countEdit = GET_CHILD(ctrl_set, 'countEdit')
        local countValue = countEdit:GetText();
        local topframe = countEdit:GetTopParentFrame()
        local number_edit = GET_CHILD(topframe, 'number_edit')
        AUTO_CAST(number_edit)
        local all_number = number_edit:GetText()

        if all_number ~= 0 or all_number ~= "" or all_number ~= "None" then
            countValue = all_number
            countEdit:SetText(tostring(all_number))
        end
        if ischeck == 0 then
            countValue = 0
        end
        g.members[aid] = {
            ischeck = ischeck,
            item_count = tonumber(countValue)
        }
        easy_reward_GUILDINVEN_SEND_INIT_MEMBER(frame)
    end
end

function easy_reward_count_clear(frame, ctrl, str, num)

    for key, value in pairs(g.members) do
        if type(value) == "table" then
            value.item_count = 0
        end
    end
end

function easy_reward_number_enter(frame, ctrl, str, num)

    local item_count = tonumber(ctrl:GetText())
    for key, value in pairs(g.members) do
        if type(value) == "table" then
            if value.ischeck == 1 then
                value.item_count = item_count
            end
        end
    end
    easy_reward_GUILDINVEN_SEND_INIT_MEMBER(frame)
end

function easy_reward_GUILDINVEN_SEND_INIT_MEMBER(frame)

    local frame = ui.GetFrame('guildinven_send')

    local listBox = GET_CHILD_RECURSIVELY(frame, 'listBox');
    listBox:RemoveAllChild();

    local searchEdit = GET_CHILD_RECURSIVELY(frame, 'searchEdit');
    searchEdit:Resize(396, 30)
    searchEdit:SetMargin(0, 0, 0, 0)

    local line3 = GET_CHILD_RECURSIVELY(frame, 'line3');
    line3:ShowWindow(0)

    local itemNameText = GET_CHILD_RECURSIVELY(frame, 'itemNameText');
    AUTO_CAST(itemNameText)
    itemNameText:AdjustFontSizeByWidth(250)

    local closeBtn = GET_CHILD_RECURSIVELY(frame, 'closeBtn');
    AUTO_CAST(closeBtn)
    closeBtn:SetEventScript(ui.LBUTTONDOWN, "easy_reward_count_clear")

    local ODD_INDEX_BG_SKIN = frame:GetUserConfig('ODD_INDEX_BG_SKIN');
    local allMemberCheck = GET_CHILD_RECURSIVELY(frame, 'allMemberCheck');
    local list = session.party.GetPartyMemberList(PARTY_GUILD)
    local count = list:Count()

    local members_to_sort = {}
    for i = 0, count - 1 do
        local partyMemberInfo = list:Element(i)
        table.insert(members_to_sort, partyMemberInfo)
    end

    table.sort(members_to_sort, function(a, b)
        if a:GetName() ~= b:GetName() then
            return a:GetName() < b:GetName()
        else
            return a:GetAID() < b:GetAID()
        end
    end)

    g.members.count = 0

    for index, partyMemberInfo in ipairs(members_to_sort) do
        local aid = partyMemberInfo:GetAID()
        local name = partyMemberInfo:GetName()

        local ctrlSet = listBox:CreateOrGetControlSet('guild_item_send', 'ITEMSEND_' .. aid, 0, 0)
        ctrlSet:SetUserValue('MEMBER_AID', aid)

        local bgBox = ctrlSet:GetChild('bgBox')

        if index % 2 == 1 then
            bgBox:SetSkinName(ODD_INDEX_BG_SKIN)
            ctrlSet:SetUserValue('ODD_BG', 'YES')
        end

        local sendCheck = GET_CHILD(ctrlSet, 'sendCheck');
        AUTO_CAST(sendCheck)
        sendCheck:SetCheck((g.members[aid] and g.members[aid].ischeck) or allMemberCheck:IsChecked());
        local ischeck = sendCheck:IsChecked()
        if ischeck == 1 then
            g.members.count = g.members.count + 1
        end
        sendCheck:SetEventScript(ui.LBUTTONUP, "easy_reward_member_list")
        sendCheck:SetEventScriptArgString(ui.LBUTTONUP, aid)

        local countEdit = GET_CHILD(ctrlSet, 'countEdit')
        AUTO_CAST(countEdit)
        local count_value = (g.members[aid] and g.members[aid].item_count) or 0
        countEdit:SetText(tostring(count_value))

        local nameText = ctrlSet:GetChild('nameText');
        nameText:SetText(partyMemberInfo:GetName());

    end

    local haveText = GET_CHILD_RECURSIVELY(frame, "haveText")
    local item_count = haveText:GetTextByKey('count')

    local reward_count = 0
    if g.members.count and g.members.count > 0 then
        reward_count = math.floor(item_count / g.members.count)
    end

    local selectcount = frame:CreateOrGetControl('richtext', 'selectcount', 420, 70, 100, 25)
    AUTO_CAST(selectcount)
    selectcount:SetFontName("black_18_b")
    local msg = (g.lang == "Japanese" and "選択人数: " or "Choices: ")
    selectcount:SetText(msg .. g.members.count)

    local div_check = frame:CreateOrGetControl('checkbox', 'div_check', 250, 70, 25, 25)
    AUTO_CAST(div_check)

    if not g.members.check then
        g.members.check = 0
    end
    div_check:SetCheck(g.members.check)
    div_check:SetEventScript(ui.LBUTTONUP, "easy_reward_member_list")
    div_check:SetTextTooltip(g.lang == "Japanese" and "自動割り算" or "Auto Divide") -- Auto Divide

    local number_edit = frame:CreateOrGetControl('edit', 'number_edit', 180, 65, 60, 30)
    AUTO_CAST(number_edit)
    number_edit:SetEventScript(ui.ENTERKEY, "easy_reward_number_enter")
    number_edit:SetTextTooltip(g.lang == "Japanese" and "均等割り付け数" or "Evenly Distributed")
    number_edit:SetFontName("white_16_ol")
    number_edit:SetTextAlign("center", "center");

    for index, partyMemberInfo in ipairs(members_to_sort) do
        if g.members.check == 1 then
            local aid = partyMemberInfo:GetAID()
            local ctrlSet = GET_CHILD(listBox, "ITEMSEND_" .. aid)
            local sendCheck = GET_CHILD(ctrlSet, 'sendCheck');
            if sendCheck:IsChecked() == 1 then
                local countEdit = GET_CHILD(ctrlSet, 'countEdit');
                AUTO_CAST(countEdit)
                countEdit:SetText(tonumber(reward_count))
                GUILDINVEN_SEND_UPDATE_COUNT_BOX(frame)
            end
        end
    end
    GUILDINVEN_SEND_UPDATE_COUNT_BOX(frame)
    GBOX_AUTO_ALIGN(listBox, 0, 0, 0, true, false);
end
