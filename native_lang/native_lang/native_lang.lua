-- v0.0.4 フレームのコンテキストが上手く動かなかったの修正
-- v0.0.5 新規のチャットはTOTALフレームで処理されるらしいので、そこを排他しない様に。
-- v1.0.0 気になったところは直したから正式版
-- v1.0.1 ギアスコアランク作成、週ボスの所に表示、ヴェルニケ表も翻訳、ペット名翻訳
local addonName = "NATIVE_LANG"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.1"
local exe = "0.0.3"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")
local json = require('json')
local os = require("os")

--[[local folder_path = string.format("../addons/%s", addonNameLower)
os.execute('mkdir "' .. folder_path .. '"')]]

g.settings_location = string.format('../addons/%s/settings.json', addonNameLower)
g.send_msg = string.format('../addons/%s/send_msg.dat', addonNameLower)
g.recv_msg = string.format('../addons/%s/recv_msg.dat', addonNameLower)
g.send_name = string.format('../addons/%s/send_name.dat', addonNameLower)
g.recv_name = string.format('../addons/%s/recv_name.dat', addonNameLower)
g.restart = string.format('../addons/%s/restart.dat', addonNameLower)
g.gear_score = string.format('../addons/%s/gear_score.dat', addonNameLower)

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

function g.split(str, sep)
    local parts = {}
    for part in str:gmatch("([^" .. sep .. "]+)") do
        table.insert(parts, part)
    end
    return parts
end

local function WITH_HANGLE(str)
    for _, code in utf8.codes(str) do
        if code >= 0xAC00 and code <= 0xD7A3 then
            return true
        end
    end
    return false
end

local function WITH_JAPANESE(str)
    for _, code in utf8.codes(str) do
        if (code >= 0x3040 and code <= 0x309F) or -- ひらがな
        (code >= 0x30A0 and code <= 0x30FF) or -- カタカナ
        (code >= 0x4E00 and code <= 0x9FFF) then -- 漢字
            return true
        end
    end
    return false
end

local function WITH_ENGLISH(str)
    for _, code in utf8.codes(str) do
        if (code >= 0x41 and code <= 0x5A) or -- 'A' ～ 'Z'
        (code >= 0x61 and code <= 0x7A) then -- 'a' ～ 'z'
            return true
        end
    end
    return false
end

function native_lang_is_translation(str)
    if g.lang == "ja" then
        return WITH_HANGLE(str)
    elseif g.lang == "ko" then
        return WITH_JAPANESE(str)
    elseif g.lang == "en" then
        return WITH_HANGLE(str) or WITH_JAPANESE(str)
    end
    return false
end

function native_lang_save_settings()
    acutil.saveJSON(g.settings_location, g.settings)
end

function native_lang_load_settings()

    local settings = acutil.loadJSON(g.settings_location, g.settings)

    local lang = option.GetCurrentCountry()
    if lang == "Japanese" then
        g.lang = "ja"
    elseif lang == "kr" then
        g.lang = "ko"
    else
        g.lang = "en"
    end

    if not settings then

        settings = {
            use = 1,
            lang = g.lang
        }
    end
    g.settings = settings

    local function native_lang_open_or_create_file(file_path)
        local file = io.open(file_path, "r")
        if not file then
            file = io.open(file_path, "w")
            if file then
                file:close()
            end
        else
            file:close()
        end
    end

    native_lang_open_or_create_file(g.recv_name)

    local files = {g.send_name, g.send_msg, g.recv_msg}

    if not g.load then
        for _, file in ipairs(files) do
            os.remove(file)
            native_lang_open_or_create_file(file)
        end
        g.load = true
    end

    local file = io.open(g.recv_msg, "r")
    if file then
        for _ in file:lines() do
            g.recv_count = g.recv_count + 1
        end
        file:close() -- ファイルを閉じる
        if g.recv_count <= 10 then
            g.recv_count = 0
        end
    end

    native_lang_save_settings()

    local function native_lang_name_table_create()

        g.names = {}
        local name_file = io.open(g.recv_name, "r")

        if name_file then
            for line in name_file:lines() do
                local left_name, right_name = line:match("^(.-):::(.*)$")
                if left_name and right_name then
                    g.names[left_name] = right_name
                end
            end
            name_file:close()
        end
    end
    native_lang_name_table_create()

    g.gear_scores = {}
    local file = io.open(g.gear_score, "r")
    if file then
        for line in file:lines() do
            local org_name, teamName, guildIdx, value = line:match("([^:]+):::(%S+):::(%d+):::(%d+)")
            if native_lang_is_translation(teamName) and not g.names[org_name] then
                teamName = native_lang_process_name(org_name)
            end
            table.insert(g.gear_scores, {org_name, teamName, guildIdx, tonumber(value)})
        end
        file:close()
    else
        file = io.open(g.gear_score, "w")
        file:close()
    end
    table.sort(g.gear_scores, function(a, b)
        return a[4] > b[4] -- 3番目の要素がvalue
    end)

end

function native_lang_TOS_GOOGLE_TRANSLATE_ON_INIT(addon, frame)
    return
end

function native_lang_KOJA_NAME_TRANSLATER_ON_INIT(addon, frame)
    return
end

function NATIVE_LANG_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    g.chat_ids = g.chat_ids or {}
    g.name_len = 0
    g.msg_len = 0
    g.chat_check = g.chat_check or {}
    g.recv_count = 0

    g.gear_score_table = g.gear_score_table or {}

    -- tos_google_translate無効化
    g.SetupHook(native_lang_TOS_GOOGLE_TRANSLATE_ON_INIT, "TOS_GOOGLE_TRANSLATE_ON_INIT")
    -- koja_name_tarnslater無効化
    g.SetupHook(native_lang_KOJA_NAME_TRANSLATER_ON_INIT, "KOJA_NAME_TRANSLATER_ON_INIT")

    native_lang_load_settings()

    g.SetupHook(native_lang_UPDATE_PARTYINFO_HP, "UPDATE_PARTYINFO_HP")
    g.SetupHook(native_lang_DAMAGE_METER_GAUGE_SET, "DAMAGE_METER_GAUGE_SET")
    g.SetupHook(native_lang_UPDATE_COMPANION_TITLE, "UPDATE_COMPANION_TITLE")
    g.SetupHook(native_lang_GEAR_SCORE_RANKING_CREATE_INFO, "GEAR_SCORE_RANKING_CREATE_INFO")
    g.SetupHook(native_lang_SOLODUNGEON_RANKINGPAGE_FILL_RANK_CTRL, "SOLODUNGEON_RANKINGPAGE_FILL_RANK_CTRL")

    acutil.setupEvent(addon, "WEEKLY_BOSS_RANK_UPDATE", "native_lang_WEEKLY_BOSS_RANK_UPDATE");
    acutil.setupEvent(addon, "SHOW_PC_COMPARE", "native_lang_SHOW_PC_COMPARE");

    acutil.setupEvent(addon, "ON_EVENTBANNER_GEARSCORE", "native_lang_ON_EVENTBANNER_GEARSCORE");

    -- acutil.setupEvent(addon, "CHAT_TAB_BTN_CLICK", "native_lang_CHAT_TAB_BTN_CLICK");

    addon:RegisterMsg("GAME_START", "native_lang_GAME_START");
    addon:RegisterMsg("GAME_START_3SEC", "native_lang_GAME_START_3SEC");

end

function native_lang_SOLODUNGEON_RANKINGPAGE_FILL_RANK_CTRL(rankGbox, ctrlType, rank, week)

    if g.settings.use == 0 then
        base["SOLODUNGEON_RANKINGPAGE_FILL_RANK_CTRL"](rankGbox, ctrlType, rank, week)
    else
        native_lang_SOLODUNGEON_RANKINGPAGE_FILL_RANK_CTRL_(rankGbox, ctrlType, rank, week)
    end
end

function native_lang_SOLODUNGEON_RANKINGPAGE_FILL_RANK_CTRL_(rankGbox, ctrlType, rank, week)
    AUTO_CAST(rankGbox)
    local emblemSlotImageName = rankGbox:GetUserConfig("GUILD_EMBLEM_SLOT");
    local scoreInfo = session.soloDungeon.GetRankingByIndex(week, ctrlType, rank)
    if scoreInfo == nil then
        return;
    end

    local rankText = GET_CHILD_RECURSIVELY(rankGbox, "rankText")
    rankText:SetTextByKey("rank", rank + 1)

    local familyName = g.names[scoreInfo.familyName] or scoreInfo.familyName
    if native_lang_is_translation(familyName) and not g.names[familyName] then
        familyName = native_lang_process_name(familyName)
    end

    local teamNameText = GET_CHILD_RECURSIVELY(rankGbox, "teamNameText")
    teamNameText:SetTextByKey("teamname", familyName)

    local charLevelText = GET_CHILD_RECURSIVELY(rankGbox, "charLevelText")
    charLevelText:SetTextByKey("charlevel", scoreInfo.level)

    local guildName = g.names[scoreInfo.guildName] or scoreInfo.guildName
    if native_lang_is_translation(guildName) and not g.names[guildName] then
        guildName = native_lang_process_name(guildName)
    end

    local guildNameText = GET_CHILD_RECURSIVELY(rankGbox, "guildNameText")
    guildNameText:SetTextByKey("guildname", guildName);

    local emblemCtrl = GET_CHILD_RECURSIVELY(rankGbox, "guildEmblem")
    if emblemCtrl ~= nil then
        local worldID = session.party.GetMyWorldIDStr();
        local emblemImgName = guild.GetEmblemImageName(scoreInfo:GetGuildIDStr(), worldID);
        emblemCtrl:SetImage(emblemSlotImageName);
        if emblemImgName ~= 'None' then
            emblemCtrl:SetFileName(emblemImgName);
            emblemCtrl:Invalidate();
        else
            if scoreInfo:GetGuildIDStr() ~= "0" then
                GetGuildEmblemImage("SOLODUNGEON_UPDATE_GUILD_EMBLEM_IMAGE", scoreInfo:GetGuildIDStr())
            end
        end
    end

    local cnt = scoreInfo:GetJobHistoryCount()
    local jobTreeList = {}
    local jobTreeGbox = GET_CHILD_RECURSIVELY(rankGbox, "jobTreeGbox")
    for i = 0, cnt - 1 do
        local jobID = scoreInfo:GetJobHistoryByIndex(i)
        local jobCls = GetClassByType("Job", jobID)
        if jobCls ~= nil then
            local icon = jobCls.Icon
            if icon ~= nil then
                local rankImage = jobTreeGbox:CreateOrGetControl("picture", "rankImage_" .. i + 1, 35 * i, 0, 35, 35)
                rankImage = tolua.cast(rankImage, "ui::CPicture")
                rankImage:SetImage(icon)
                rankImage:SetEnableStretch(1);
                rankImage:EnableHitTest(0)

                if jobTreeList[jobID] == nil then
                    jobTreeList[jobID] = 1
                else
                    jobTreeList[jobID] = jobTreeList[jobID] + 1
                end
            end
        end
    end

    local jobtext = "";
    for jobid, grade in pairs(jobTreeList) do
        -- 클래스 이름{@st41}
        local jobCls = GetClassByType("Job", jobid)

        local jobName = TryGetProp(jobCls, "Name")
        jobtext = jobtext .. ("{@st41}") .. jobName

        jobtext = jobtext .. ('{nl}');
    end
    jobTreeGbox:SetTextTooltip(jobtext);

    local maxStageText = GET_CHILD_RECURSIVELY(rankGbox, "maxStageText")
    maxStageText:SetTextByKey("maxstage", scoreInfo.stage);

    local clear_time = scoreInfo.clear_time;
    if clear_time ~= 0 then
        clear_time = session.soloDungeon.GetClearTimeConvert(tonumber(clear_time));
    else
        clear_time = "03:00";
    end

    local killMonsterText = GET_CHILD_RECURSIVELY(rankGbox, "killMonsterText")
    killMonsterText:SetTextByKey("killmonster", clear_time)
end

function native_lang_GEAR_SCORE_RANKING_CREATE_INFO(ctrl, rank, guildIdx, teamName, charName, value)
    if g.settings.use == 0 then
        base["GEAR_SCORE_RANKING_CREATE_INFO"](ctrl, rank, guildIdx, teamName, charName, value)
    else
        native_lang_GEAR_SCORE_RANKING_CREATE_INFO_(ctrl, rank, guildIdx, teamName, charName, value)
    end
end

function native_lang_GEAR_SCORE_RANKING_CREATE_INFO_(ctrl, rank, guildIdx, teamName, charName, value)
    local guildPic = GET_CHILD(ctrl, "emblem_pic")
    local rankText = GET_CHILD(ctrl, "rank_text")
    local teamNameText = GET_CHILD(ctrl, "team_name_text")
    local charNameText = GET_CHILD(ctrl, "char_name_text")
    local valueText = GET_CHILD(ctrl, "value_text")

    local org_name = teamName:gsub("{#0000FF}", "")

    teamName = teamName:gsub("{#0000FF}", "")
    if native_lang_is_translation(teamName) then
        teamName = native_lang_process_name(teamName)
    end
    if native_lang_is_translation(charName) then
        charName = native_lang_process_name(charName)
    end
    rankText:SetTextByKey("value", rank)
    if teamName == GETMYFAMILYNAME() then
        teamName = "{#0000FF}" .. teamName
    end
    teamNameText:SetTextByKey("value", teamName)
    charNameText:SetTextByKey("value", charName)
    valueText:SetTextByKey("value", value)

    local frame = guildPic:GetTopParentFrame()
    local close_btn = GET_CHILD_RECURSIVELY(frame, "closeBtn")
    AUTO_CAST(close_btn)
    close_btn:SetEventScript(ui.LBUTTONDOWN, "native_lang_real_rank_save")

    if g.gear_score_table[org_name] then
        if tonumber(value) > tonumber(g.gear_score_table[org_name].value) then
            g.gear_score_table[org_name].value = value -- 値を更新
        end
    else
        g.gear_score_table[org_name] = {
            team_name = teamName,
            guildIdx = guildIdx,
            value = value
        }
    end
    if guildIdx ~= "0" then
        local worldID = session.party.GetMyWorldIDStr()
        local emblemImgName = guild.GetEmblemImageName(guildIdx, worldID)
        if emblemImgName ~= 'None' then
            guildPic:SetFileName(emblemImgName)
        end
    end
end

function native_lang_real_rank_save(frame, ctrl, str, num)

    local file_path = g.gear_score
    g.gear_scores = {}

    local file = io.open(file_path, "r")
    if file then
        for line in file:lines() do
            local org_name, teamName, guildIdx, value = line:match("([^:]+):::(%S+):::(%d+):::(%d+)")

            if not g.gear_score_table[org_name] then
                g.gear_score_table[org_name] = {
                    team_name = teamName,
                    guildIdx = guildIdx,
                    value = value
                }
            end
        end
        file:close()
    end

    for key, data in pairs(g.gear_score_table) do
        local team_name = data.team_name

        if native_lang_is_translation(team_name) and not g.names[key] then
            team_name = native_lang_process_name(key)
        end

        table.insert(g.gear_scores, {key, team_name, data.guildIdx, tonumber(data.value)})
    end

    table.sort(g.gear_scores, function(a, b)
        return a[4] > b[4] -- 3番目の要素がvalue
    end)

    local file = io.open(file_path, "w")
    if file then
        for _, score in ipairs(g.gear_scores) do
            local line = string.format("%s:::%s:::%s:::%d\n", score[1], score[2], score[3], score[4])
            file:write(line)
            file:flush()
        end
        file:close()
    end

    --[[for i, score in ipairs(g.gear_scores) do
        local teamName = score[1]
        local guildIdx = score[2]
        local value = score[3]
        print(string.format("チーム名: %s, ギルドインデックス: %d, 値: %d", teamName, guildIdx, value))
    end]]

end

function native_lang_mouseon(frame, ctrl, str, num)
    ctrl:SetFontName("yellow_20_ol_ds");
    ctrl:SetText("Maximum Rank>>")

end

function native_lang_mouseoff(frame, ctrl, str, num)
    ctrl:SetFontName("white_20_ol_ds");
    ctrl:SetText("Maximum Rank>>")
end

function native_lang_ON_EVENTBANNER_GEARSCORE()
    local frame = ui.GetFrame("ingameeventbanner")
    if g.settings.use == 0 then
        local real_rank = GET_CHILD_RECURSIVELY(frame, "real_rank")
        if real_rank ~= nil then
            real_rank:ShowWindow(0)
        end
        return
    end
    ReserveScript("native_lang_ON_EVENTBANNER_GEARSCORE_()", 0.5)
end

function native_lang_ON_EVENTBANNER_GEARSCORE_()

    local frame = ui.GetFrame("ingameeventbanner")
    local ranking_gear_score = GET_CHILD_RECURSIVELY(frame, "ranking_gear_score");
    AUTO_CAST(ranking_gear_score)
    local detail_btn = GET_CHILD(ranking_gear_score, "detail_btn");
    local detail_x, detail_y = detail_btn:GetX(), detail_btn:GetY()
    local real_rank = ranking_gear_score:CreateOrGetControl('button', "real_rank", detail_x - 180, detail_y, 100, 30);
    AUTO_CAST(real_rank)
    real_rank:SetSkinName("None")
    real_rank:SetEventScript(ui.LBUTTONUP, "native_lang_real_rank_frame")
    real_rank:SetEventScript(ui.MOUSEON, "native_lang_mouseon")
    real_rank:SetEventScript(ui.MOUSEOFF, "native_lang_mouseoff")
    real_rank:SetFontName("white_20_ol_ds");
    real_rank:SetText("Maximum Rank>>")
    real_rank:ShowWindow(1)
end

function native_lang_real_rank_frame_close(frame, ctrl, str, num)
    local frame = ui.GetFrame(addonNameLower .. "gear_score_info")
    frame:ShowWindow(0)
end

function native_lang_real_rank_frame(frame, ctrl, str, num)
    local frame = ui.CreateNewFrame("notice_on_pc", addonNameLower .. "gear_score_info", 0, 0, 0, 0)
    AUTO_CAST(frame)
    frame:SetPos(1000, 30)
    frame:SetSkinName("test_frame_low")
    frame:SetLayerLevel(1000);
    frame:RemoveAllChild()
    -- frame:SetTitleBarSkin("mainframe_03")

    local close_button = frame:CreateOrGetControl("button", "close_button", 0, 0, 30, 30)
    AUTO_CAST(close_button)
    close_button:SetImage("testclose_button")
    close_button:SetGravity(ui.RIGHT, ui.TOP)
    close_button:SetEventScript(ui.LBUTTONUP, "native_lang_real_rank_frame_close")
    close_button:SetMargin(0, 55, 0, 0)

    local rank_title = frame:CreateOrGetControl('richtext', 'rank_title', 15, 60, 60, 30)
    AUTO_CAST(rank_title)
    rank_title:SetFontName("white_20_ol_ds");
    rank_title:SetText("Rank")

    local name_title = frame:CreateOrGetControl('richtext', 'name_title', 120, 60, 200, 30)
    AUTO_CAST(name_title)
    name_title:SetFontName("white_20_ol_ds");
    name_title:SetText("Team Name")

    local score_title = frame:CreateOrGetControl('richtext', 'score_title', 330, 60, 80, 30)
    AUTO_CAST(score_title)
    score_title:SetFontName("white_20_ol_ds");
    score_title:SetText("Gear Score")

    local info_gbox = frame:CreateOrGetControl("groupbox", "info_gbox", 10, 95, frame:GetWidth() - 20,
        frame:GetHeight() - 55)
    AUTO_CAST(info_gbox)

    info_gbox:SetSkinName("bg")

    local y = 0
    local x = 480
    for i, entry in ipairs(g.gear_scores) do
        local rank_text = info_gbox:CreateOrGetControl('richtext', 'rank_text' .. i, 10, y + 5, 60, 30)
        AUTO_CAST(rank_text)
        rank_text:SetFontName("white_20_ol_ds");
        rank_text:SetText(i)

        local pic = info_gbox:CreateOrGetControl('picture', "pic" .. i, 80, y, 30, 30);
        AUTO_CAST(pic)
        -- pic:SetGravity(ui.LEFT, ui.TOP);
        if tostring(entry[3]) ~= "0" then
            local worldID = session.party.GetMyWorldIDStr()
            local emblemImgName = guild.GetEmblemImageName(tostring(entry[3]), worldID)

            if emblemImgName ~= 'None' then
                pic:SetFileName(emblemImgName)
                pic:SetEnableStretch(1);
            end
        end

        local name_text = info_gbox:CreateOrGetControl('richtext', 'name_text' .. i, 120, y + 5, 200, 30)
        AUTO_CAST(name_text)
        name_text:SetFontName("white_20_ol_ds");
        local name = entry[2] or entry[1]
        name_text:SetText(name)

        local score_text = info_gbox:CreateOrGetControl('richtext', 'score_text' .. i, 330, y + 5, 80, 30)
        AUTO_CAST(score_text)
        score_text:SetFontName("white_20_ol_ds");
        score_text:SetText(entry[4])

        y = y + 35

    end

    frame:Resize(x, 800)
    local title_gb = frame:CreateOrGetControl("groupbox", "title_gb", 0, 0, frame:GetWidth(), 55)
    title_gb:SetSkinName("test_frame_top")
    AUTO_CAST(title_gb)
    local title_text = title_gb:CreateOrGetControl("richtext", "title_text", 0, 0, ui.CENTER_HORZ, ui.TOP, 0, 15, 0, 0)
    AUTO_CAST(title_text);
    title_text:SetText('{ol}{s20}Maximum Gear Score Ranking')
    info_gbox:Resize(frame:GetWidth() - 20, frame:GetHeight() - 105)
    info_gbox:SetScrollPos(0)
    frame:ShowWindow(1)
end

function native_lang_UPDATE_COMPANION_TITLE(frame, handle)
    if g.settings.use == 0 then
        base["UPDATE_COMPANION_TITLE"](frame, handle)
    else
        native_lang_UPDATE_COMPANION_TITLE_(frame, handle)
    end
end

function native_lang_UPDATE_COMPANION_TITLE_(frame, handle)
    -- print(tostring(handle))
    frame = tolua.cast(frame, "ui::CObject");
    local petguid = session.pet.GetPetGuidByHandle(handle);
    local mycompinfoBox = GET_CHILD_RECURSIVELY(frame, "mycompinfo");
    if mycompinfoBox == nil then
        return;
    end

    local otherscompinfo = GET_CHILD_RECURSIVELY(frame, "otherscompinfo");
    if petguid == 'None' then
        mycompinfoBox:ShowWindow(0)
        otherscompinfo:ShowWindow(1)

        local targetinfo = info.GetTargetInfo(handle);
        if targetinfo == nil then
            return;
        end
        local othernameTxt = GET_CHILD_RECURSIVELY(frame, "othername");
        local origin_name = targetinfo.name
        local clean_name = origin_name:gsub("{.-}", ""):gsub("__+", "_"):match("^%s*(.-)%s*$")
        local trans_name = g.names[clean_name] or targetinfo.name
        if native_lang_is_translation(clean_name) then
            trans_name = native_lang_process_name(clean_name)
            othernameTxt:SetText(trans_name)
        else
            othernameTxt:SetText(trans_name)
        end

    else
        local myActor = GetMyPCObject();
        if myActor ~= nil and IsBuffApplied(myActor, "RidingCompanion") == "YES" then
            mycompinfoBox:ShowWindow(0);
        else
            mycompinfoBox:ShowWindow(1);
        end
        otherscompinfo:ShowWindow(0);

        local mynameRtext = GET_CHILD_RECURSIVELY(frame, "myname");
        local gauge_stamina = GET_CHILD_RECURSIVELY(frame, "StGauge");
        local gauge_HP = GET_CHILD_RECURSIVELY(frame, "HpGauge");

        local pet = session.pet.GetPetByGUID(petguid);
        mynameRtext:SetText(pet:GetName())

        local petObj = GetIES(pet:GetObject());
        gauge_stamina:SetPoint(petObj.Stamina, petObj.MaxStamina);

        local petInfo = info.GetStat(handle);
        gauge_HP:SetPoint(petInfo.HP, petInfo.maxHP);
    end
    frame:Invalidate()
end

--[[function native_lang_CHAT_TAB_BTN_CLICK(frame, msg)
    native_lang_replace()
end]]

function native_lang_SHOW_PC_COMPARE(frame, msg)
    local cid = acutil.getEventArgs(msg)
    local frame = ui.GetFrame("compare");
    frame:SetLayerLevel(102);

    if g.settings.use == 0 then
        return
    end
    local charNameRTxt = GET_CHILD_RECURSIVELY(frame, "charName", "ui::CRichText")
    local teamName = charNameRTxt:GetTextByKey("teamName")
    teamName = native_lang_process_name(teamName)

    local charName = charNameRTxt:GetTextByKey("charName")
    charName = native_lang_process_name(charName)

    charNameRTxt:SetTextByKey("teamName", teamName);
    charNameRTxt:SetTextByKey("charName", charName);
end

function native_lang_WEEKLY_BOSS_RANK_UPDATE()

    local wbrextend = nil
    local functionName = "WBREXTEND_ON_INIT" -- チェックしたい関数の名前を文字列として指定します
    if type(_G[functionName]) == "function" then
        wbrextend = true
    end

    local frame = ui.GetFrame("induninfo")
    local rankListBox = GET_CHILD_RECURSIVELY(frame, "rankListBox", "ui::CGroupBox");
    local cnt = session.weeklyboss.GetRankInfoListSize();

    if cnt == 0 then
        return;
    end
    for i = 1, cnt do
        local ctrlSet = GET_CHILD_RECURSIVELY(rankListBox, "CTRLSET_" .. i)
        local teamname = session.weeklyboss.GetRankInfoTeamName(i - 1);
        local org_name = teamname
        if g.settings.use == 0 then
            local name = GET_CHILD(ctrlSet, "attr_name_text", "ui::CRichText");
            name:SetTextByKey("value", teamname);
        else
            teamname = g.names[teamname] or teamname
            if native_lang_is_translation(teamname) then
                native_lang_process_name(teamname)
            end
            local name = GET_CHILD(ctrlSet, "attr_name_text", "ui::CRichText");
            name:SetTextByKey("value", teamname);

            if g.gear_scores then
                for _, score in ipairs(g.gear_scores) do
                    if score[1] == org_name then
                        local text_gs = rankListBox:CreateOrGetControl('button', "text_gs" .. i, 215, (i - 1) * 73 + 50,
                            100, 25);
                        AUTO_CAST(text_gs)
                        text_gs:SetSkinName("None")
                        local score_text = "{@st66b}{s16}Max Gear Score : " .. score[4]
                        text_gs:SetText(score_text)
                        text_gs:SetEventScript(ui.LBUTTONDOWN, "native_lang_real_rank_frame")
                        text_gs:SetTextTooltip("{ol}Left click{nl}" .. " Open the Maximum Gear Score Ranking frame")
                        break
                    end

                end

            end
        end

        function native_lang_MEMBERINFO_ONCLICK(frame, ctrl, str, num)
            ui.Chat('/memberinfo ' .. str);
            local compare = ui.GetFrame("compare")
            compare:SetLayerLevel(102);
        end

        local btn = rankListBox:CreateOrGetControl('button', "BTN_" .. i, 225, (i - 1) * 73 + 5, 100, 25);
        tolua.cast(btn, "ui::CButton");
        btn:SetEventScript(ui.LBUTTONUP, "native_lang_MEMBERINFO_ONCLICK");
        btn:SetEventScriptArgString(ui.LBUTTONUP, org_name);

        if wbrextend then
            btn:SetText("Memberinfo");

            if _G["WBREXTEND"][org_name] ~= nil then
                local txtGs = rankListBox:CreateOrGetControl('button', "txtGs_" .. i, 225, (i - 1) * 73 + 50, 100, 25);
                tolua.cast(txtGs, "ui::CButton");
                txtGs:SetText("GS: " .. _G["WBREXTEND"][org_name]);
                txtGs:SetEventScript(ui.LBUTTONUP, "GS_ONCLICK");
            end
        else
            btn:Resize(50, 25)
            btn:SetText("{ol}Info");
            btn:SetGravity(ui.RIGHT, ui.TOP)
            local rect = btn:GetMargin();
            btn:SetMargin(rect.left, rect.top + 45, rect.right + 25, rect.bottom);
        end
    end

end

function native_lang_switching()
    local chatframe = ui.GetFrame("chatframe")
    local trans_btn = GET_CHILD_RECURSIVELY(chatframe, "trans_btn")
    AUTO_CAST(trans_btn)

    if g.settings.use == 1 then
        g.settings.use = 0
        trans_btn:SetSkinName('test_gray_button')
        trans_btn:SetTextTooltip("Native Lang is suspended")
    else
        g.settings.use = 1
        trans_btn:SetSkinName("test_red_button")
        trans_btn:SetTextTooltip("Native Lang in use")
    end
    native_lang_save_settings()
end

function native_lang_restart()
    local file = io.open(g.restart, "w")
    file:write("restart")
    file:close()
    g.start = false
    g.load = false
    g.chat_ids = {}
    g.name_len = 0
    g.msg_len = 0
    g.chat_check = {}
    g.recv_count = 0
    ui.SysMsg("[Native Lang] restarted.{nl}" .. "Please return to the barracks once.")
end

function native_lang_context()

    local context = ui.CreateContextMenu("native_lang_context", "Native Lang", 0, 0, 50, 0)
    ui.AddContextMenuItem(context, "-----")

    local str_scp
    if g.settings.use == 1 then
        str_scp = string.format("native_lang_switching()")
        ui.AddContextMenuItem(context, "Native Lang stop", str_scp)
    else
        str_scp = string.format("native_lang_switching()")
        ui.AddContextMenuItem(context, "Native Lang operation", str_scp)
    end

    str_scp = string.format("native_lang_restart()")
    ui.AddContextMenuItem(context, "Restart", str_scp)

    ui.OpenContextMenu(context)
end

function native_lang_GAME_START()

    local function native_lang_frame_init()
        local chatframe = ui.GetFrame("chatframe")
        local tabgbox = GET_CHILD_RECURSIVELY(chatframe, "tabgbox")
        local trans_btn = tabgbox:CreateOrGetControl("button", "trans_btn", 270, -1, 30, 30)
        AUTO_CAST(trans_btn)
        if g.settings.use == 0 then
            trans_btn:SetSkinName('test_gray_button')
            trans_btn:SetTextTooltip("Native Lang is suspended")
        elseif g.settings.use == 1 then
            trans_btn:SetSkinName("test_red_button")
            trans_btn:SetTextTooltip("Native Lang in use")
        end

        trans_btn:SetText("{ol}{s14}{#FFFFFF}" .. g.lang)
        trans_btn:SetEventScript(ui.LBUTTONUP, "native_lang_context")
    end
    native_lang_frame_init()

    local function native_lang_translate_exe_start()
        --[[if g.settings.use == 0 then
            return
        end]]

        if not g.start then

            local exe_path = "../addons/native_lang/native_lang-v" .. exe .. ".exe"
            local file = io.open(exe_path, "r")
            if file then
                file:close()
                local command = string.format('start "" /min "%s"', exe_path)
                os.execute(command)
            else
                local tar_path = "../addons/native_lang/native_lang-v" .. exe .. ".tar"
                -- print(tar_path)
                local output_dir = "../addons/native_lang"

                -- tarコマンドの生成
                local tar_command = string.format('tar -xf "%s" -C "%s"', tar_path, output_dir)

                local result = os.execute(tar_command)

                if result then
                    local command = string.format('start "" /min "%s"', exe_path)
                    os.execute(command)
                end

            end

            g.start = true
        end

    end

    native_lang_translate_exe_start()

end

function native_lang_GAME_START_3SEC()
    acutil.setupEvent(g.addon, "DRAW_CHAT_MSG", "native_lang_DRAW_CHAT_MSG");
    g.addon:RegisterMsg("FPS_UPDATE", "native_lang_FPS_UPDATE");
end

function native_lang_FPS_UPDATE()

    native_lang_name_trans()

    function native_lang_name_dat_check()

        local recv_file = io.open(g.recv_name, "r")
        if recv_file then
            local name_len = recv_file:seek("end")
            if g.name_len == name_len then
                recv_file:close() -- ファイルを閉じる
                return
            else
                recv_file:seek("set", 0)
                for line in recv_file:lines() do
                    local org_name, trans_name = line:match("^(.-):::(.*)$")
                    g.names[org_name] = trans_name
                end
                g.name_len = name_len
                native_lang_replace()
            end
        end
    end
    native_lang_name_dat_check()

    function native_lang_msg_dat_check()

        local recv_file = io.open(g.recv_msg, "r")
        if recv_file then
            local msg_len = recv_file:seek("end")
            if g.msg_len == msg_len then
                recv_file:close() -- ファイルを閉じる
                return
            else
                recv_file:seek("set", 0)
                local current_line = g.recv_count + 1

                for line in recv_file:lines() do
                    if current_line >= g.recv_count then
                        local chat_id, msg_type, msg, separate_msg, org_msg, org_name = line:match(
                            "^(.-):::(.-):::(.-):::(.-):::(.-):::(.*)$")
                        if g.chat_ids[tostring(chat_id)] then
                            g.chat_ids[tostring(chat_id)].trans_msg = msg
                            g.chat_ids[tostring(chat_id)].name = g.names[org_name] or org_name

                            --[[if g.chat_ids[tostring(chat_id)].copy_ids ~= nil and msg_type ~= "System" then
                                for index, id in ipairs(g.chat_ids[tostring(chat_id)].copy_ids) do
                                    if id ~= chat_id then
                                        g.chat_ids[tostring(id)] = g.chat_ids[tostring(chat_id)]
                                    end
                                end
                            end]]
                        end
                    end
                end
                g.msg_len = msg_len
                g.recv_count = g.recv_count + 1

                native_lang_replace()
            end
        end
    end
    native_lang_msg_dat_check()
end

function native_lang_format_chat_message(frame, msg_type, right_name, msg)
    local msg_type_map = {
        Normal = 1,
        Shout = 2,
        Party = 3,
        Guild = 4,
        System = 7
    }

    local chat_type_id = msg_type_map[msg_type]
    if chat_type_id then

        local font_size = tonumber(GET_CHAT_FONT_SIZE())
        local font_style = frame:GetUserConfig("TEXTCHAT_FONTSTYLE_" .. msg_type:upper())
        local msg_front = string.format("[%s]%s : %s", ScpArgMsg("ChatType_" .. chat_type_id), right_name, msg)
        return msg_front, font_style, font_size
    end
    return nil, nil, nil
end

function native_lang_chat_replace(frame, msg_front, font_style, font_size, chat_id)

    local clustername = "cluster_" .. chat_id
    local cluster = GET_CHILD_RECURSIVELY(frame, clustername)
    local text = GET_CHILD_RECURSIVELY(cluster, "text")
    text:SetTextByKey("font", font_style)
    text:SetTextByKey("size", font_size)
    text:SetTextByKey("text", msg_front)
end

function native_lang_replace()

    if g.settings.use == 0 then
        return
    end
    local chatframe = ui.GetFrame("chatframe")
    local child_count = chatframe:GetChildCount()

    for i = 0, child_count - 1 do
        local child = chatframe:GetChildByIndex(i)

        -- if child:GetName() ~= "chatgbox_TOTAL" and string.find(child:GetName(), "chatgbox_") then
        if string.find(child:GetName(), "chatgbox_") then

            local chat_gbox = child:GetName()
            local gbox = GET_CHILD_RECURSIVELY(chatframe, chat_gbox)
            local gbox_child_count = gbox:GetChildCount()
            local ypos = 0

            for j = 0, gbox_child_count - 1 do
                local gbox_child = gbox:GetChildByIndex(j)
                local child_name = gbox_child:GetName()

                if tostring(child_name) ~= "_SCR" then

                    local margin_left = 20
                    local cluster = GET_CHILD(gbox, child_name)

                    local label = cluster:GetChild('bg')
                    local offsetX = chatframe:GetUserConfig("CTRLSET_OFFSETX")
                    local chat_Width = gbox:GetWidth()
                    local text = GET_CHILD_RECURSIVELY(cluster, "text")
                    local chat_id = tostring(string.gsub(child_name, "cluster_", ""))

                    if g.chat_ids[chat_id] ~= nil then
                        local msg = ""
                        if g.chat_ids[tostring(chat_id)].trans_msg ~= "" then
                            msg = g.chat_ids[tostring(chat_id)].trans_msg
                        else
                            msg = g.chat_ids[tostring(chat_id)].proc_msg
                        end

                        local separate_msg = g.chat_ids[tostring(chat_id)].separate_msg

                        if separate_msg and separate_msg ~= "None" then
                            separate_msg = separate_msg:gsub("},%s*{", "}{")
                            separate_msg = separate_msg:gsub("{%((%d+)}", "(%1") -- {(5 の部分を (5 に戻す
                            separate_msg = separate_msg:gsub("{%)}", ")")
                            separate_msg = separate_msg:gsub("{@dicID_%^%*%$(.-)%$%*^}", "@dicID_^*$%1$*^")
                            separate_msg = separate_msg:gsub("{img link_party 24 24}{(.-)}{/}",
                                "{img link_party 24 24}%1{/}")

                            msg = msg .. separate_msg
                        end

                        local msg_type = g.chat_ids[tostring(chat_id)].msg_type
                        local name = g.chat_ids[tostring(chat_id)].name

                        local msg_front, font_style, font_size =
                            native_lang_format_chat_message(chatframe, msg_type, name, msg)

                        if msg_front ~= nil then
                            native_lang_chat_replace(chatframe, msg_front, font_style, font_size, chat_id)
                            -- g.msg_front = msg_front
                        end

                    end

                    label:Resize(chat_Width - offsetX, text:GetHeight())
                    cluster:Resize(chat_Width, label:GetHeight())
                    cluster:SetOffset(margin_left, ypos)
                    ypos = ypos + cluster:GetHeight()
                end
            end
            if gbox:GetLineCount() == gbox:GetCurLine() + gbox:GetVisibleLineCount() then
                gbox:SetScrollPos(99999)
            end
        end
    end
end

function native_lang_system_msg_replace(chat_id, msg, msg_type, name, org_msg)

    function native_lang_system_msg_to_chat_ids(chat_id, msg, msg_type, name, org_msg, updated_msg)
        g.chat_ids[tostring(chat_id)] = {
            msg_type = msg_type,
            name = g.names[name] or name,
            org_name = name,
            org_msg = org_msg,
            proc_msg = msg,
            separate_msg = "None",
            trans_msg = updated_msg
        }
        native_lang_replace()
    end

    if string.find(msg, "https:") then
        native_lang_system_msg_to_chat_ids(chat_id, msg, msg_type, name, org_msg, msg)
        return 1

    elseif string.find(msg, "Guild_Colony_End_WorldMessage") then
        local start_pos = string.find(msg, "$*$partyName$*$", 1, true)
        start_pos = start_pos + 15
        local end_pos = string.find(msg, "#@!", start_pos, true)
        local guild_name = string.sub(msg, start_pos, end_pos - 1)
        local trimmed_name = guild_name:match("^%s*(.-)%s*$")
        local trans_guild_name = ""
        if g.names[trimmed_name] then
            trans_guild_name = g.names[guild_name]
        else
            trans_guild_name = guild_name
        end
        local updated_msg = string.sub(msg, 1, start_pos - 1) .. trans_guild_name .. string.sub(msg, end_pos)
        updated_msg = "{#DD0000}" .. updated_msg
        native_lang_system_msg_to_chat_ids(chat_id, msg, msg_type, name, org_msg, updated_msg)

        return 1
    elseif string.find(msg, "Guild_Colony_Occupation_WorldMessage") then
        local start_pos = string.find(msg, "$*$partyName$*$", 1, true)
        start_pos = start_pos + 15
        local end_pos = string.find(msg, "$*$mapName$*$", start_pos, true)
        local final_pos = string.find(msg, "|#@!", start_pos, true)
        local guild_name = string.sub(msg, start_pos, end_pos - 1)
        local trimmed_name = guild_name:match("^%s*(.-)%s*$")
        local trans_guild_name = ""
        if g.names[trimmed_name] then
            trans_guild_name = g.names[guild_name]
        else
            trans_guild_name = guild_name
        end
        local updated_msg = string.sub(msg, 1, start_pos - 1) .. trans_guild_name .. string.sub(msg, end_pos, final_pos)
        updated_msg = "{#DD0000}" .. updated_msg
        native_lang_system_msg_to_chat_ids(chat_id, msg, msg_type, name, org_msg, updated_msg)

        return 1
    elseif string.find(msg, "NOTICE_FIELDBOSS_RANK") then
        local start_pos = string.find(msg, "$*$name$*$", 1, true)
        start_pos = start_pos + 10
        local end_pos = string.find(msg, "#@!", start_pos, true)
        local names_str = string.sub(msg, start_pos, end_pos - 1)

        local replaced_names = {}
        for name_str in names_str:gmatch("([^,]+)") do -- カンマで分割
            local trimmed_name = name_str:match("^%s*(.-)%s*$") -- 前後の空白を削除

            if g.names[trimmed_name] then
                table.insert(replaced_names, g.names[trimmed_name]) -- 置き換え
            else
                table.insert(replaced_names, trimmed_name) -- 置き換えが無い場合はそのまま
            end
        end

        local new_names_str = table.concat(replaced_names, ", ")
        local updated_msg = string.sub(msg, 1, start_pos - 1) .. new_names_str .. string.sub(msg, end_pos)
        native_lang_system_msg_to_chat_ids(chat_id, msg, msg_type, name, org_msg, updated_msg)
        return 1
    elseif string.find(msg, "FIELDBOSS_WORLD_EVENT_WIN_MSG") then
        local start_pos = string.find(msg, "$*$PC$*$", 1, true)
        start_pos = start_pos + 8
        local end_pos = string.find(msg, "$*$ITEM$*$", start_pos, true)
        local final_pos = string.find(msg, "|#@!", start_pos, true)
        local name = string.sub(msg, start_pos, end_pos - 1)
        local trimmed_name = name:match("^%s*(.-)%s*$")
        local trans_name = ""
        if g.names[trimmed_name] then
            trans_name = g.names[name]
        else
            trans_name = name
        end
        local updated_msg = string.sub(msg, 1, start_pos - 1) .. trans_name .. string.sub(msg, end_pos, final_pos)
        updated_msg = "{#DD0000}" .. updated_msg
        native_lang_system_msg_to_chat_ids(chat_id, msg, msg_type, "", org_msg, updated_msg)
        return 1
    else
        return 0
    end
end
--[[CHAT_SYSTEM(
    "{#DD0000}!@#$FIELDBOSS_WORLD_EVENT_WIN_MSG{PC}{ITEM}$*$PC$*$슈라랏$*$ITEM$*$|$#유라테의 세 번째 권능#$|#@!")]]

function native_lang_DRAW_CHAT_MSG(frame, msg)

    if g.settings.use == 0 then
        return
    end
    local groupboxname, startindex, chatframe = acutil.getEventArgs(msg);

    if chatframe == nil then
        return;
    end

    local frame = ui.GetFrame("chatframe")
    local size = session.ui.GetMsgInfoSize(groupboxname)
    local chat = session.ui.GetChatMsgInfo(groupboxname, size - 1)
    local president = 0

    for i = startindex, size - 1 do
        local clusterinfo = session.ui.GetChatMsgInfo(groupboxname, i)
        local chat_id = clusterinfo:GetMsgInfoID()

        if g.chat_check[tostring(chat_id)] ~= true then
            -- table.insert(g.copy_ids, chat_id)
            g.chat_check[tostring(chat_id)] = true
        else
            return
        end

        local clustername = "cluster_" .. chat_id
        local cluster = GET_CHILD_RECURSIVELY(frame, clustername)

        if cluster == nil then

            return
        else

            local msg = chat:GetMsg()
            local org_msg = msg
            msg = msg:gsub("{#0000FF}", "{#FFFF00}")
            local name = chat:GetCommanderName()
            name = name:gsub(" %[(.-)%]", "")

            --[[if name == "あじのり" then
                name = "아지노리"
            end]]

            president = chat_id
            local msg_type = chat:GetMsgType()
            if msg_type ~= "Normal" and msg_type ~= "Shout" and msg_type ~= "Party" and msg_type ~= "Guild" and msg_type ~=
                "System" and msg_type ~= "GuildComm" and msg_type ~= "GuildNotice" then
                return
            end

            if string.find(msg, "{spine") then
                --[[local right_name = g.names[name] or name
                local msg_front, font_style, font_size = native_lang_format_chat_message(frame, msg_type, right_name,
                    msg)
                native_lang_chat_replace(frame, msg_front, font_style, font_size, chat_id)]]
                return
            end

            print(chat_id .. ":" .. name .. ":" .. msg)

            local sys_msg_find = native_lang_system_msg_replace(chat_id, msg, msg_type, "", org_msg)
            if sys_msg_find == 1 then
                return
            end
            if name == "System" then
                return
            end

            local index = tonumber(frame:GetUserValue("BTN_INDEX")) + 1
            local chat_option = ui.GetFrame("chat_option")
            local tabgbox = GET_CHILD_RECURSIVELY(chat_option, "tabgbox" .. index)
            local btn_general_pic = GET_CHILD_RECURSIVELY(tabgbox, "btn_general_pic")
            local btn_shout_pic = GET_CHILD_RECURSIVELY(tabgbox, "btn_shout_pic")
            local btn_party_pic = GET_CHILD_RECURSIVELY(tabgbox, "btn_party_pic")
            local btn_guild_pic = GET_CHILD_RECURSIVELY(tabgbox, "btn_guild_pic")
            local btn_system_pic = GET_CHILD_RECURSIVELY(tabgbox, "btn_system_pic")
            if btn_general_pic:IsVisible() == 0 and msg_type == "Normal" then
                return
            elseif btn_shout_pic:IsVisible() == 0 and msg_type == "Shout" then
                return
            elseif btn_party_pic:IsVisible() == 0 and msg_type == "Party" then
                return
            elseif btn_guild_pic:IsVisible() == 0 and msg_type == "Guild" then
                return
            elseif btn_system_pic:IsVisible() == 0 and msg_type == "System" then
                return
            end

            local function native_lang_msg_processing(msg)

                local function modify_string(msg)

                    local pattern = "{img link_party 24 24}(.-){/}"
                    msg = msg:gsub(pattern, "{img link_party 24 24}{" .. "%1" .. "}{/}")

                    msg = msg:gsub("(@dicID_%^%*%$.-%$%*%^)", "{%1}")

                    if string.find(msg, "Earring 30 30") then

                        msg = msg:gsub("%((%d+)", "{(%1}") -- (5 の部分を {(5 に
                        msg = msg:gsub("%)", "{)}")
                    end
                    local pattern3 = "!@#%$(.-)#@!"
                    msg = msg:gsub(pattern3, "{!@#%$(.-)#@!}")
                    return msg
                end

                local function wrapped_contents(msg)
                    local pattern = "{(.-)}"
                    local separate_msg = {}

                    for match in msg:gmatch(pattern) do
                        table.insert(separate_msg, "{" .. match .. "}")
                    end

                    msg = msg:gsub(pattern, "")
                    return msg, separate_msg
                end

                local function anti_pattern(proc_msg)
                    -- 特殊文字を含むリスト
                    local patterns = {",", "`", "~~", "&", "!", ":", ";", "%(", "%)", "%[", "%]", "%{", "%}", "%'",
                                      "%\"", "//"}

                    for _, pattern in ipairs(patterns) do
                        proc_msg = proc_msg:gsub(pattern .. "+", " ")

                    end
                    return proc_msg
                end

                msg = modify_string(msg)
                local proc_msg, separate_msg = wrapped_contents(msg)
                proc_msg = anti_pattern(proc_msg)
                proc_msg = proc_msg:gsub(" +", " ")
                return proc_msg, separate_msg

            end
            local proc_msg, separate_msg = native_lang_msg_processing(msg)

            g.chat_ids[tostring(chat_id)] = {
                msg_type = msg_type,
                name = g.names[name] or name,
                org_name = name,
                org_msg = org_msg,
                proc_msg = proc_msg,
                separate_msg = #separate_msg == 0 and "None" or table.concat(separate_msg, ","),
                trans_msg = ""
            }

            if native_lang_is_translation(name) then
                native_lang_process_name(name)
                g.chat_ids[tostring(chat_id)].name = g.names[name] or name
            end

            function native_lang_msg_send(send_msg, president)
                --[[g.chat_ids[tostring(president)].copy_ids = g.copy_ids
                g.copy_ids = {}]]

                local send_file = io.open(g.send_msg, "a")

                if send_file then
                    send_file:write(send_msg .. "\n")
                    send_file:flush()
                    send_file:close()
                end
            end

            function native_lang_is_translation_msg(msg)
                if g.lang == "ja" then
                    return WITH_HANGLE(msg) or WITH_ENGLISH(msg)
                elseif g.lang == "ko" then
                    return WITH_JAPANESE(msg) or WITH_ENGLISH(msg)
                elseif g.lang == "en" then
                    return WITH_HANGLE(msg) or WITH_JAPANESE(msg)
                end
                return false
            end

            if native_lang_is_translation_msg(proc_msg) then

                -- print(chat_id .. ":" .. name .. ":" .. proc_msg)

                local send_msg = chat_id .. ":::" .. msg_type .. ":::" .. proc_msg .. ":::" ..
                                     g.chat_ids[tostring(chat_id)].separate_msg .. ":::" .. msg .. ":::" .. name
                -- ReserveScript(string.format("native_lang_msg_send('%s',%d)", send_msg, president), 0.01)
                native_lang_msg_send(send_msg, president)
            else

                native_lang_replace()
            end
            -- break

        end
    end

end

--[[CHAT_SYSTEM(
    "{#DD0000}!@#$Guild_Colony_Occupation_WorldMessage$*$partyName$*$바이보라$*$mapName$*$|$#수로교 지역#$|#@!")]]
function native_lang_process_name(clean_name)

    if string.find(clean_name, "PartyMemberMapNChannel", 1, true) then
        return clean_name
    elseif string.find(clean_name, "★★", 1, true) then
        return clean_name
    end

    if g.names[clean_name] then
        local right_name = g.names[clean_name]
        return right_name
    end

    local name_file = io.open(g.recv_name, "r")
    local found = false

    if name_file then
        for line in name_file:lines() do
            local left_name, right_name = line:match("^(.-):::(.*)$")
            if left_name == clean_name then
                found = true
                g.names[left_name] = right_name
                name_file:close()
                return right_name
            end
        end
        name_file:close()
    end

    if not found then

        if native_lang_is_translation(clean_name) then

            local existing_keys = {}
            local read_file = io.open(g.send_name, "r")
            if read_file then
                for line in read_file:lines() do
                    local key = line:match("^(.-):::")

                    if key then
                        existing_keys[key] = true

                    end

                end
                read_file:close()
            end
            -- print(tostring(existing_keys[clean_name]))
            -- 重複がない場合に書き込む
            if not existing_keys[clean_name] then
                local append_file = io.open(g.send_name, "a")
                if append_file then
                    append_file:write(clean_name .. ":::" .. clean_name .. "\n")
                    append_file:flush()
                    append_file:close()
                end
            end
        end
    end
    return clean_name
end
function native_lang_name_trans()
    if g.settings.use == 0 then
        return
    end

    local selected_objects, selected_objects_count = SelectObject(GetMyPCObject(), 1000, "ALL")

    for i = 1, selected_objects_count do

        local handle = GetHandle(selected_objects[i])

        if handle ~= nil then
            if info.IsPC(handle) == 1 then
                local frame_name = "charbaseinfo1_" .. handle
                local pc_txt_frame = ui.GetFrame(frame_name)
                local shop_frame = ui.GetFrame("SELL_BALLOON_" .. handle)

                function native_lang_name_replace(ctrl)

                    local origin_name = ctrl:GetText()
                    if string.find(origin_name, "{img guild_master_mark 20 20}") then
                        origin_name = string.gsub(origin_name, "{img guild_master_mark 20 20}", "")
                    end
                    -- 
                    local clean_name = origin_name:gsub("{.-}", ""):gsub("__+", "_"):match("^%s*(.-)%s*$")
                    if native_lang_is_translation(clean_name) then

                        local trans_name = native_lang_process_name(clean_name)
                        if trans_name ~= clean_name then

                            if ctrl:GetName() == "givenName" then
                                local original_part = origin_name:sub(1, 9)
                                trans_name = original_part .. trans_name
                                ctrl:SetText(trans_name)
                                local ctrl_Width = ctrl:GetWidth()
                                local x = ctrl:GetX()
                                local family_name = GET_CHILD(pc_txt_frame, "familyName")
                                if family_name ~= nil then
                                    local frame_family_name_margin = family_name:GetMargin()
                                    family_name:SetMargin(x + ctrl_Width + 5, frame_family_name_margin.top,
                                        frame_family_name_margin.right, frame_family_name_margin.bottom)
                                end
                            elseif ctrl:GetName() == "familyName" or ctrl:GetName() == "name" then
                                local original_part = origin_name:sub(1, 9)
                                trans_name = original_part .. trans_name
                                ctrl:SetText(trans_name)
                            elseif ctrl:GetName() == "guildName" then
                                ctrl:SetText(trans_name)
                            elseif ctrl:GetName() == "text" then
                                ctrl:SetTextByKey("value", trans_name)
                            elseif ctrl:GetName() == "lv_title" then

                                ctrl:SetTextByKey("value", trans_name)
                            end

                        end

                    end
                end
                if pc_txt_frame ~= nil then

                    local given_name = GET_CHILD(pc_txt_frame, "givenName")
                    if given_name ~= nil then
                        native_lang_name_replace(given_name)
                    end

                    local family_name = GET_CHILD(pc_txt_frame, "familyName")
                    if family_name ~= nil then
                        native_lang_name_replace(family_name)
                    end

                    local frame_name = GET_CHILD(pc_txt_frame, "name")
                    if frame_name ~= nil then
                        native_lang_name_replace(frame_name)
                    end

                    local guild_name = GET_CHILD(pc_txt_frame, "guildName")
                    if guild_name ~= nil then
                        native_lang_name_replace(guild_name)
                    end
                end

                if shop_frame ~= nil then

                    local shop_text = GET_CHILD(shop_frame, "text")
                    if shop_text ~= nil then
                        native_lang_name_replace(shop_text)
                    end
                    local lv_box = GET_CHILD(shop_frame, "withLvBox");
                    if lv_box ~= nil then
                        local lv_title = GET_CHILD(lv_box, "lv_title");
                        if lv_title ~= nil then
                            native_lang_name_replace(lv_title)
                        end
                    end
                end

            end
        end
    end
end

function native_lang_UPDATE_PARTYINFO_HP(partyInfoCtrlSet, partyMemberInfo)

    if g.settings.use == 0 then
        base["UPDATE_PARTYINFO_HP"](partyInfoCtrlSet, partyMemberInfo)
    else
        local nameObj = partyInfoCtrlSet:GetChild('name_text');
        local nameRichText = tolua.cast(nameObj, "ui::CRichText");
        local name = nameRichText:GetTextByKey("name");

        if native_lang_is_translation(name) then
            local font = name:match("({.-})")
            name = name:gsub("{.-}", ""):match("^%s*(.-)%s*$")
            name = native_lang_process_name(name)
            if font then
                name = font .. name
            end
            nameRichText:SetTextByKey("name", name)
        end
        base["UPDATE_PARTYINFO_HP"](partyInfoCtrlSet, partyMemberInfo)
    end
end

function native_lang_DAMAGE_METER_GAUGE_SET(ctrl, leftStr, point, rightStr, skin)
    if g.settings.use == 0 then
        base["DAMAGE_METER_GAUGE_SET"](ctrl, leftStr, point, rightStr, skin)
    else
        local font = "{@st42b}{ds}{s12}"
        leftStr = leftStr:gsub("{@st42b}{ds}{s12}", ""):match("^%s*(.-)%s*$")
        leftStr = g.names[leftStr] or leftStr
        leftStr = font .. leftStr

        base["DAMAGE_METER_GAUGE_SET"](ctrl, leftStr, point, rightStr, skin)
    end
end

--[[function native_lang_UPDATE_PARTYINFO_HP(partyInfoCtrlSet, partyMemberInfo)
    _native_lang_UPDATE_PARTYINFO_HP(partyInfoCtrlSet, partyMemberInfo)
end]]

--[[function native_lang_DAMAGE_METER_GAUGE_SET(ctrl, leftStr, point, rightStr, skin)
    _native_lang_DAMAGE_METER_GAUGE_SET(ctrl, leftStr, point, rightStr, skin)
end]]

--[[function native_lang_name_trans()
    if g.settings.use == 0 then
        return
    end

    local selected_objects, selected_objects_count = SelectObject(GetMyPCObject(), 1000, "ALL")

    for i = 1, selected_objects_count do
        local handle = GetHandle(selected_objects[i])
        if handle ~= nil then
            if info.IsPC(handle) == 1 then
                local frame_name = "charbaseinfo1_" .. handle
                local pc_txt_frame = ui.GetFrame(frame_name)
                if pc_txt_frame ~= nil then

                    local function native_lang_given_name(frame_given_name, pc_txt_frame)
                        local given_name = frame_given_name:GetText()
                        local clean_name = given_name:gsub("{.-}", ""):gsub("__+", "_"):match("^%s*(.-)%s*$")

                        if native_lang_is_translation(clean_name) then
                            local right_name = native_lang_process_name(clean_name)
                            if right_name ~= clean_name then
                                local original_part = given_name:sub(1, 9)
                                local new_given_name = original_part .. right_name

                                frame_given_name:SetText(new_given_name)
                                local frame_given_name_Width = frame_given_name:GetWidth()
                                local x = frame_given_name:GetX();

                                local frame_family_name = GET_CHILD(pc_txt_frame, "familyName")
                                if frame_family_name ~= nil then
                                    local frame_family_name_margin = frame_family_name:GetMargin()
                                    frame_family_name:SetMargin(x + frame_given_name_Width + 5,
                                        frame_family_name_margin.top, frame_family_name_margin.right,
                                        frame_family_name_margin.bottom);
                                end
                            end
                        end
                    end

                    local frame_given_name = GET_CHILD(pc_txt_frame, "givenName")
                    if frame_given_name ~= nil then
                        native_lang_given_name(frame_given_name, pc_txt_frame)
                    end

                    local function native_lang_family_name(frame_family_name)
                        local family_name = frame_family_name:GetText()
                        local clean_name = family_name:gsub("{.-}", ""):gsub("__+", "_"):match("^%s*(.-)%s*$")

                        if native_lang_is_translation(clean_name) then
                            local right_name = native_lang_process_name(clean_name)
                            if right_name ~= clean_name then
                                local original_part = family_name:sub(1, 9)
                                local new_family_name = original_part .. right_name
                                frame_family_name:SetText(new_family_name)
                            end

                        end
                    end

                    local frame_family_name = GET_CHILD(pc_txt_frame, "familyName")
                    if frame_family_name ~= nil then
                        native_lang_family_name(frame_family_name)
                    end

                    local frame_name = GET_CHILD(pc_txt_frame, "name")
                    if frame_name ~= nil then
                        native_lang_family_name(frame_name)
                    end

                    local function native_lang_guild_name(frame_guild_name)

                        local guild_name = frame_guild_name:GetText()

                        if string.find(guild_name, "{img guild_master_mark 20 20}") then
                            guild_name = string.gsub(guild_name, "{img guild_master_mark 20 20}", "")
                        end

                        if native_lang_is_translation(guild_name) then
                            local new_guild_name = native_lang_process_name(guild_name)
                            if new_guild_name ~= guild_name then
                                frame_guild_name:SetText(new_guild_name)
                            end
                        end
                    end

                    local frame_guild_name = GET_CHILD(pc_txt_frame, "guildName")
                    if frame_guild_name ~= nil then
                        native_lang_guild_name(frame_guild_name)
                    end

                    local function native_lang_shop_name(shop_frame)
                        local shop_text = GET_CHILD(shop_frame, "text");
                        AUTO_CAST(shop_text)
                        if shop_text ~= nil then
                            local text = shop_text:GetText():gsub("{.-}", ""):gsub("__+", "_"):match("^%s*(.-)%s*$")
                            if native_lang_is_translation(text) then

                                local new_shop_name = native_lang_process_name(text)
                                if new_shop_name ~= text then
                                    shop_text:SetTextByKey("value", new_shop_name);
                                end
                            end
                        end
                        local frame_lv_box = GET_CHILD(shop_frame, "withLvBox");
                        if frame_lv_box ~= nil then
                            local frame_shop_name = GET_CHILD(frame_lv_box, "lv_title");
                            if frame_shop_name ~= nil then
                                local shop_name = frame_shop_name:GetText():gsub("{.-}", ""):gsub("__+", "_"):match(
                                    "^%s*(.-)%s*$")

                                if native_lang_is_translation(shop_name) then
                                    local new_shop_name = native_lang_process_name(shop_name)
                                    if new_shop_name ~= shop_name then
                                        frame_shop_name:SetTextByKey("value", new_shop_name);
                                    end
                                end
                            end
                        end
                    end
                    local shop_frame = ui.GetFrame("SELL_BALLOON_" .. handle);
                    if shop_frame ~= nil then
                        native_lang_shop_name(shop_frame)
                    end

                end
            end
        end
    end
end]]

--[[local function native_lang_chat_name_replace(frame, msg_type, msg, name, chat_id)

                local right_name = native_lang_process_name(name)

                local msg_front, font_style, font_size = native_lang_format_chat_message(frame, msg_type, right_name,
                                                                                         msg)
                native_lang_chat_replace(frame, msg_front, font_style, font_size, chat_id)
            end]]
--[[function native_lang_chat_name_replace_update(frame)

    local recv_file = io.open(g.recv_name, "r")
    if recv_file then
        local name_len = recv_file:seek("end")
        if g.name_len == name_len then
            recv_file:close() -- ファイルを閉じる
            return 1
        else
            recv_file:seek("set", 0)
            g.name_len = name_len

        end
    end

    for key_chat_id, chat in pairs(g.chat_ids) do
        -- if chat.name_trans == "Yes" then
        local name = chat.org_name
        local right_name = native_lang_process_name(frame, name)
        local org_msg = chat.org_msg
        local msg_tyep = chat.msg_type
        local msg_front, font_style, font_size = native_lang_format_chat_message(frame, msg_tyep, right_name, org_msg)
        if msg_front ~= nil then
            native_lang_chat_replace(frame, msg_front, font_style, font_size, tonumber(key_chat_id))
            chat.name = right_name
            -- chat.name_trans = "No"
        end
        -- end
    end
end]]
-- g.chat_ids = {}
--[[for key, value in pairs(g.chat_check) do
    -- テーブルの値を直接表示
    local chat_data = g.chat_ids[tostring(key)]
    if chat_data then
        print("Chatid:" .. key .. "msg_type:" .. chat_data.msg_type .. "proc_msg:" .. chat_data.proc_msg ..
                  "separate_msg:" .. chat_data.separate_msg)

    end
end]]
--[[function native_lang_chat_all_replace()

    local chatframe = ui.GetFrame("chatframe")
    local child_count = chatframe:GetChildCount()

    for i = 0, child_count - 1 do
        local child = chatframe:GetChildByIndex(i)
        if child:GetName() ~= "chatgbox_TOTAL" and string.find(child:GetName(), "chatgbox_") then
            local chat_gbox = child:GetName()
            local gbox = GET_CHILD_RECURSIVELY(chatframe, chat_gbox)
            local gbox_child_count = gbox:GetChildCount()
            local ypos = 0
            for j = 0, gbox_child_count - 1 do
                local gbox_child = gbox:GetChildByIndex(j)
                local child_name = gbox_child:GetName()

                if tostring(child_name) ~= "_SCR" then
                    local margin_left = 20
                    local cluster = GET_CHILD(gbox, child_name)
                    local label = cluster:GetChild('bg')
                    local offsetX = chatframe:GetUserConfig("CTRLSET_OFFSETX")
                    local chat_Width = gbox:GetWidth()
                    local text = GET_CHILD_RECURSIVELY(cluster, "text")
                    local chat_id = cluster:GetName():gsub("cluster_", "")

                    --[[local get_text = text:GetText()
                    if g.chat_ids[tostring(chat_id)] ~= nil then

                        g.chat_ids[tostring(chat_id)].trans_msg:find("{#FF0000}★{/}")
                    end]

                    label:Resize(chat_Width - offsetX, text:GetHeight())
                    cluster:Resize(chat_Width, label:GetHeight())
                    cluster:SetOffset(margin_left, ypos)
                    ypos = ypos + cluster:GetHeight()

                end
            end
            if gbox:GetLineCount() == gbox:GetCurLine() + gbox:GetVisibleLineCount() then
                gbox:SetScrollPos(99999)
            end

        end
    end
end]]

--[[function native_lang_UPDATE_PARTYINFO_HP(frame, msg)

    local party_info_ctrlSet, party_member_info = acutil.getEventArgs(msg);

    local party_info_frame = ui.GetFrame('partyinfo')
    local FAR_MEMBER_NAME_FONT_COLORTAG = party_info_frame:GetUserConfig("FAR_MEMBER_NAME_FONT_COLORTAG")
    local NEAR_MEMBER_NAME_FONT_COLORTAG = party_info_frame:GetUserConfig("NEAR_MEMBER_NAME_FONT_COLORTAG")

    local stat = party_member_info:GetInst();
    local pos = stat:GetPos();
    local my_handle = session.GetMyHandle();
    local distance = info.GetDestPosDistance(pos.x, pos.y, pos.z, my_handle);
    local shared_cls = GetClass("SharedConst", 'PARTY_SHARE_RANGE');
    local my_mapname = session.GetMapName();
    local party_member_mapname = GetClassByType("Map", party_member_info:GetMapID()).ClassName;

    local party_member_name = party_member_info:GetName();
    party_member_name:gsub(FAR_MEMBER_NAME_FONT_COLORTAG, "")
    party_member_name:gsub(FAR_MEMBER_NAME_FONT_COLORTAG, "")
    party_member_name = native_lang_process_name(nil, party_member_name)

    local name_obj = party_info_ctrlSet:GetChild('name_text');
    local name_text = tolua.cast(name_obj, "ui::CRichText");

    if distance < shared_cls.Value and my_mapname == party_member_mapname then

        party_member_name = NEAR_MEMBER_NAME_FONT_COLORTAG .. party_member_name;
        name_text:SetTextByKey("name", party_member_name);
    else

        party_member_name = FAR_MEMBER_NAME_FONT_COLORTAG .. party_member_name;
        name_text:SetTextByKey("name", party_member_name);
    end
end]]

--[[function native_lang_async_msg_send(frame)
    if g.settings.use == 0 then
        return 1
    end
    local recv_ids = {}
    local send_ids = {}

    local function load_chat_ids(file_name, ids_table)
        local file = io.open(file_name, 'r')
        if file then
            for line in file:lines() do
                local parts = line:split(":::") -- split関数を最適化
                if #parts >= 1 then
                    ids_table[parts[1] = true -- chat_idをキーにして存在することを保持
                end
            end
            file:close()
        end
    end

    load_chat_ids(g.recv_msg, recv_ids)
    load_chat_ids(g.send_msg, send_ids)

    local messages_to_send = {}

    for chat_id, chat_info in pairs(g.chat_ids) do
        local msg_trans = chat_info.msg_trans

        if msg_trans == "Yes" then

            if not recv_ids[tostring(chat_id)] and not send_ids[tostring(chat_id)] then
                local msg_type = chat_info.msg_type
                local send_msg_content =
                    chat_id .. ":::" .. msg_type .. ":::" .. g.chat_ids[tostring(chat_id)].proc_msg .. ":::" ..
                        g.chat_ids[tostring(chat_id)].separate_msg .. ":::" .. g.chat_ids[tostring(chat_id)].org_msg
                table.insert(messages_to_send, send_msg_content)

            end
        end
    end

    if #messages_to_send > 0 then
        local send_file = io.open(g.send_msg, "a")
        if send_file then
            for _, msg in ipairs(messages_to_send) do
                send_file:write(msg .. "\n")
            end
            send_file:flush()
            send_file:close()
        end
    end

    local frame = ui.GetFrame("chatframe")
    frame:RunUpdateScript("native_lang_msg_replace", 1.5)

    return 1
end]]
--[[function native_lang_chat_all_replace_init()
    if g.settings.use == 0 then
        return
    end
    local chatframe = ui.GetFrame("chatframe")

    local child_count = chatframe:GetChildCount()

    for i = 0, child_count - 1 do
        local child = chatframe:GetChildByIndex(i)

        if child:GetName() ~= "chatgbox_TOTAL" and string.find(child:GetName(), "chatgbox_") then
            local chat_gbox = child:GetName()

            local gbox = GET_CHILD_RECURSIVELY(chatframe, chat_gbox)
            local gbox_child_count = gbox:GetChildCount()
            local ypos = 0
            for j = 0, gbox_child_count - 1 do
                local gbox_child = gbox:GetChildByIndex(j)
                local child_name = gbox_child:GetName()
                if tostring(child_name) ~= "_SCR" then
                    local margin_left = 20
                    local cluster = GET_CHILD(gbox, child_name)

                    local label = cluster:GetChild('bg')
                    local offsetX = chatframe:GetUserConfig("CTRLSET_OFFSETX")
                    local chat_Width = gbox:GetWidth()
                    local text = GET_CHILD_RECURSIVELY(cluster, "text")
                    local frame_chat_id = tostring(string.gsub(child_name, "cluster_", ""))

                    if g.chat_ids[frame_chat_id] ~= nil then
                        local name = g.names[g.chat_ids[frame_chat_id].org_name] or g.chat_ids[frame_chat_id].org_name
                        local org_msg = g.chat_ids[frame_chat_id].org_msg
                        local separate_msg = g.chat_ids[frame_chat_id].separate_msg
                        if g.chat_ids[frame_chat_id].separate_msg ~= "None" then
                            separate_msg = separate_msg:gsub("},%s*{", "}{")
                            separate_msg = separate_msg:gsub("{%((%d+)}", "(%1") -- {(5 の部分を (5 に戻す
                            separate_msg = separate_msg:gsub("{%)}", ")")

                            separate_msg = separate_msg:gsub("{@dicID_%^%*%$(.-)%$%*^}", "@dicID_^*$%1$*^")

                            local pattern2 = "{img link_party 24 24}{(.-)}{/}"
                            separate_msg = separate_msg:gsub(pattern2, "{img link_party 24 24}%1{/}")
                        else
                            separate_msg = ""
                        end

                        local msg = g.chat_ids[frame_chat_id].trans_msg == "" and org_msg or
                                        g.chat_ids[frame_chat_id].trans_msg .. separate_msg
                        local msg_type = g.chat_ids[frame_chat_id].msg_type
                        local msg_front, font_style, font_size =
                            native_lang_format_chat_message(chatframe, msg_type, name, msg)
                        if msg_front ~= nil then

                            -- msg_front = msg_front .. "{#FF0000}★{/}"
                            native_lang_chat_replace(chatframe, msg_front, font_style, font_size, frame_chat_id)
                        end
                    end

                    label:Resize(chat_Width - offsetX, text:GetHeight())
                    cluster:Resize(chat_Width, label:GetHeight())
                    cluster:SetOffset(margin_left, ypos)
                    ypos = ypos + cluster:GetHeight()

                end
            end
            if gbox:GetLineCount() == gbox:GetCurLine() + gbox:GetVisibleLineCount() then
                gbox:SetScrollPos(99999)
            end
        end
    end

end]]
