-- !!!market_favorite
--[==[function market_favorite_rebuild_ON_DROP(frame, ctrl, str, num)
    EBI_try_catch {
        try = function()
            local liftIcon = ui.GetLiftIcon()
            local liftParent = liftIcon:GetParent()
            local slot = tolua.cast(ctrl, 'ui::CSlot')
            local iconInfo = liftIcon:GetInfo()

            local invitem = GET_ITEM_BY_GUID(iconInfo:GetIESID())

            if iconInfo == nil or slot == nil or invitem == nil then

                return
            end
            local itemobj = GetIES(invitem:GetObject())
            if (iconInfo:GetIESID() == '0') then
                if (liftParent:GetName() == 'pic') then
                    local parent = liftParent:GetParent()
                    while (string.starts(parent:GetName(), 'ITEM') == false) do
                        parent = parent:GetParent()
                        if (parent == nil) then
                            CHAT_SYSTEM('失敗')
                            return
                        end
                    end

                    --[[local row = tonumber(parent:GetUserValue('DETAIL_ROW'))
                    local mySession = session.GetMySession()
                    local cid = mySession:GetCID()
                    local count = session.market.GetItemCount()]]
                    local row = tonumber(parent:GetUserValue('DETAIL_ROW'))
                    local marketItem = session.market.GetItemByIndex(row)
                    local obj = GetIES(marketItem:GetObject())

                    -- アイコンを生成
                    local item_cls = GetClassByType("Item", obj.ClassID)
                    -- IESを生成
                    if item_cls then
                        slot:SetUserValue('clsid', tostring(obj.ClassID))
                        g.settings.items[num] = {
                            ["clsid"] = obj.ClassID
                        }
                        SET_SLOT_ITEM_CLS(slot, item_cls)
                        SET_SLOT_STYLESET(slot, item_cls)

                    end
                else
                    return
                end
            else

                local item_cls = GetClassByType("Item", itemobj.ClassID)
                if item_cls then
                    slot:SetUserValue('clsid', tostring(itemobj.ClassID))
                    g.settings.items[num] = {
                        ["clsid"] = itemobj.ClassID
                    }

                    SET_SLOT_ITEM_CLS(slot, item_cls)
                    SET_SLOT_STYLESET(slot, item_cls)

                end
            end
            market_favorite_rebuild_SAVE_SETTINGS()
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }
end]==] --[[function market_favorite_rebuild_MARKET_ADD_SEARCH_OPTION_GROUP(my_frame, my_msg)

    local optionGroupSet, ctrl, hideDeleteCtrl = g.get_event_args(my_msg)

    local function GET_DETAIL_OPTION_CTRLSET_COUNT(optionGroupSet)
        local ctrlsetCnt = 0
        local childCnt = optionGroupSet:GetChildCount()
        for i = 0, childCnt - 1 do
            local child = optionGroupSet:GetChildByIndex(i)
            if string.find(child:GetName(), 'SELECT_') ~= nil and child:IsVisible() == 1 then
                ctrlsetCnt = ctrlsetCnt + 1
            end
        end
        return ctrlsetCnt
    end

    if GET_DETAIL_OPTION_CTRLSET_COUNT(optionGroupSet) >= 8 then
        return
    end

    local curSelectCnt = optionGroupSet:GetUserIValue('ADD_SELECT_COUNT')
    optionGroupSet:SetUserValue('ADD_SELECT_COUNT', curSelectCnt + 1)
    local childIdx = curSelectCnt
    local selectSet = optionGroupSet:CreateOrGetControlSet('market_option_group_select', 'SELECT_' .. childIdx, 0, 0)
    local minEdit = GET_CHILD_RECURSIVELY(selectSet, 'minEdit')
    local maxEdit = GET_CHILD_RECURSIVELY(selectSet, 'maxEdit')
    minEdit:SetText('0')
    maxEdit:SetText('')

    if hideDeleteCtrl == true then
        local deleteText = GET_CHILD(selectSet, 'deleteText')
        deleteText:ShowWindow(0)
        optionGroupSet:SetUserValue('HIDE_CHILD_INDEX', childIdx)
    else
        local hideChildIdx = optionGroupSet:GetUserValue('HIDE_CHILD_INDEX')
        local hideChild = GET_CHILD(optionGroupSet, 'SELECT_' .. hideChildIdx)
        if hideChild ~= nil then
            local hideDelText = GET_CHILD(hideChild, 'deleteText')
            hideDelText:ShowWindow(1)
            optionGroupSet:SetUserValue('HIDE_CHILD_INDEX', 'None')
        end
    end
    print(tostring("etst1"))
    local groupList = GET_CHILD(selectSet, 'groupList')
    MARKET_INIT_OPTION_GROUP_DROPLIST(groupList)

    local function ALIGN_OPTION_GROUP_SET(optionGroupSet)
        local Y_ADD_MARGIN = 6
        local staticText = GET_CHILD(optionGroupSet, 'staticText')
        local ypos = staticText:GetY() + staticText:GetHeight() + Y_ADD_MARGIN
        local childCnt = optionGroupSet:GetChildCount()

        local visibleSelectChildCount = 0
        local visibleChild = nil
        for i = 0, childCnt - 1 do
            local child = optionGroupSet:GetChildByIndex(i)
            if string.find(child:GetName(), 'SELECT_') ~= nil then
                child:SetOffset(child:GetX(), ypos)
                visibleChild = child
                ypos = ypos + child:GetHeight()
                visibleSelectChildCount = visibleSelectChildCount + 1
            end
        end
        local addOptionBtn = GET_CHILD(optionGroupSet, 'addOptionBtn')
        addOptionBtn:SetOffset(0, ypos)
        ypos = ypos + addOptionBtn:GetHeight() + Y_ADD_MARGIN
        optionGroupSet:Resize(optionGroupSet:GetWidth(), ypos)
        return visibleSelectChildCount, visibleChild
    end
    print(tostring(tostring(optionGroupSet)))
    ALIGN_OPTION_GROUP_SET(optionGroupSet)
    print(tostring("test2"))
    local function ALIGN_ALL_CATEGORY(frame)
        local cateListBox = GET_CHILD_RECURSIVELY(frame, 'cateListBox')
        local selectedCtrlset = GET_CHILD_RECURSIVELY(frame, 'CATEGORY_' .. frame:GetUserValue('SELECTED_CATEGORY'))
        local subCateBox = GET_CHILD_RECURSIVELY(frame, 'detailBox')
        GBOX_AUTO_ALIGN(subCateBox, 0, 1, 0, true, true)
        ALIGN_CATEGORY_BOX(cateListBox, selectedCtrlset, subCateBox)
    end
    ALIGN_ALL_CATEGORY(optionGroupSet:GetTopParentFrame())
    print(tostring(tostring(selectSet)))
    return selectSet
end]] --[[function market_favorite_rebuild_get_market_guid(market_sell)

    local count = session.market.GetItemCount()

    print("--- Checking g.temp_tbl ---")
    for key, value in pairs(g.temp_tbl) do
        print(string.format("  Key: %s, Value: %s", tostring(key), tostring(value)))
    end
    print("---------------------------")

    for i = 0, count - 1 do
        local marketItem = session.market.GetItemByIndex(i)

        local market_guid = marketItem:GetMarketGuid()
        print(tostring(market_guid))
        if not g.temp_tbl[tostring(marketItem:GetMarketGuid())] then

            g.settings.sell_items[g.login_name][g.item_index].market_guid = market_guid
            market_favorite_rebuild_SAVE_SETTINGS()
            return 0
        end

    end
    return 0
end]] --[[function g.utf8_sub(str, start_char, end_char)
    if not str or str == "" then
        return ""
    end

    -- end_charが省略された場合は、最後までを意味する
    end_char = end_char or -1

    -- utf8.offset(文字列, 文字インデックス, 開始バイト位置)
    -- 文字列の先頭から、指定した文字数分のオフセット（バイト位置）を取得する
    local start_byte = utf8.offset(str, start_char)

    -- もし開始位置が見つからなければ（範囲外）、空文字を返す
    if not start_byte then
        return ""
    end

    local end_byte
    if end_char == -1 then
        -- 終了位置が-1なら、最後までを意味するので引数を省略
        end_byte = -1
    else
        -- 終了位置の次の文字の開始バイト位置を取得
        local next_char_byte = utf8.offset(str, end_char + 1)
        if next_char_byte then
            -- 次の文字の開始位置の1つ手前が、終了文字の最後のバイト
            end_byte = next_char_byte - 1
        else
            -- 次の文字が見つからない = 最後の文字まで
            end_byte = -1
        end
    end

    if end_byte == -1 then
        return string.sub(str, start_byte)
    else
        return string.sub(str, start_byte, end_byte)
    end
end]] --[==[local acutil = require('acutil')
-- デフォルト設定

-- 文字処理用

-- $Id: utf8.lua 179 2009-04-03 18:10:03Z pasta $
--
-- Provides UTF-8 aware string functions implemented in pure lua:
-- * utf8len(s)
-- * utf8sub(s, i, j)
-- * utf8reverse(s)
-- * utf8char(unicode)
-- * utf8unicode(s, i, j)
-- * utf8gensub(s, sub_len)
-- * utf8find(str, regex, init, plain)
-- * utf8match(str, regex, init)
-- * utf8gmatch(str, regex, all)
-- * utf8gsub(str, regex, repl, limit)
--
-- If utf8data.lua (containing the lower<->upper case mappings) is loaded, these
-- additional functions are available:
-- * utf8upper(s)
-- * utf8lower(s)
--
-- All functions behave as their non UTF-8 aware counterparts with the exception
-- that UTF-8 characters are used instead of bytes for all units.

--[[
Copyright (c) 2006-2007, Kyle Smith
All rights reserved.

Contributors:
	Alimov Stepan

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the author nor the names of its contributors may be
      used to endorse or promote products derived from this software without
      specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES LOSS OF USE, DATA, OR PROFITS OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

-- ABNF from RFC 3629
-- 
-- UTF8-octets = *( UTF8-char )
-- UTF8-char   = UTF8-1 / UTF8-2 / UTF8-3 / UTF8-4
-- UTF8-1      = %x00-7F
-- UTF8-2      = %xC2-DF UTF8-tail
-- UTF8-3      = %xE0 %xA0-BF UTF8-tail / %xE1-EC 2( UTF8-tail ) /
--               %xED %x80-9F UTF8-tail / %xEE-EF 2( UTF8-tail )
-- UTF8-4      = %xF0 %x90-BF 2( UTF8-tail ) / %xF1-F3 3( UTF8-tail ) /
--               %xF4 %x80-8F 2( UTF8-tail )
-- UTF8-tail   = %x80-BF
-- 

local byte = string.byte
local char = string.char
local dump = string.dump
local find = string.find
local format = string.format
local gmatch = string.gmatch
local gsub = string.gsub
local len = string.len
local lower = string.lower
local match = string.match
local rep = string.rep
local reverse = string.reverse
local sub = string.sub
local upper = string.upper

-- returns the number of bytes used by the UTF-8 character at byte i in s
-- also doubles as a UTF-8 character validator
local function utf8charbytes(s, i)
    -- argument defaults
    i = i or 1

    -- argument checking
    if type(s) ~= "string" then
        error("bad argument #1 to 'utf8charbytes' (string expected, got " .. type(s) .. ")")
    end
    if type(i) ~= "number" then
        error("bad argument #2 to 'utf8charbytes' (number expected, got " .. type(i) .. ")")
    end

    local c = byte(s, i)

    -- determine bytes needed for character, based on RFC 3629
    -- validate byte 1
    if c > 0 and c <= 127 then
        -- UTF8-1
        return 1

    elseif c >= 194 and c <= 223 then
        -- UTF8-2
        local c2 = byte(s, i + 1)

        if not c2 then
            error("UTF-8 string terminated early")
        end

        -- validate byte 2
        if c2 < 128 or c2 > 191 then
            error("Invalid UTF-8 character")
        end

        return 2

    elseif c >= 224 and c <= 239 then
        -- UTF8-3
        local c2 = byte(s, i + 1)
        local c3 = byte(s, i + 2)

        if not c2 or not c3 then
            error("UTF-8 string terminated early")
        end

        -- validate byte 2
        if c == 224 and (c2 < 160 or c2 > 191) then
            error("Invalid UTF-8 character")
        elseif c == 237 and (c2 < 128 or c2 > 159) then
            error("Invalid UTF-8 character")
        elseif c2 < 128 or c2 > 191 then
            error("Invalid UTF-8 character")
        end

        -- validate byte 3
        if c3 < 128 or c3 > 191 then
            error("Invalid UTF-8 character")
        end

        return 3

    elseif c >= 240 and c <= 244 then
        -- UTF8-4
        local c2 = byte(s, i + 1)
        local c3 = byte(s, i + 2)
        local c4 = byte(s, i + 3)

        if not c2 or not c3 or not c4 then
            error("UTF-8 string terminated early")
        end

        -- validate byte 2
        if c == 240 and (c2 < 144 or c2 > 191) then
            error("Invalid UTF-8 character")
        elseif c == 244 and (c2 < 128 or c2 > 143) then
            error("Invalid UTF-8 character")
        elseif c2 < 128 or c2 > 191 then
            error("Invalid UTF-8 character")
        end

        -- validate byte 3
        if c3 < 128 or c3 > 191 then
            error("Invalid UTF-8 character")
        end

        -- validate byte 4
        if c4 < 128 or c4 > 191 then
            error("Invalid UTF-8 character")
        end

        return 4

    else
        error("Invalid UTF-8 character")
    end
end

-- returns the number of characters in a UTF-8 string
local function utf8len(s)
    -- argument checking
    if type(s) ~= "string" then
        for k, v in pairs(s) do
            print('"', tostring(k), '"', tostring(v), '"')
        end
        error("bad argument #1 to 'utf8len' (string expected, got " .. type(s) .. ")")
    end

    local pos = 1
    local bytes = len(s)
    local len = 0

    while pos <= bytes do
        len = len + 1
        pos = pos + utf8charbytes(s, pos)
    end

    return len
end

-- functions identically to string.sub except that i and j are UTF-8 characters
-- instead of bytes
local function utf8sub(s, i, j)
    -- argument defaults
    j = j or -1

    local pos = 1
    local bytes = len(s)
    local len = 0

    -- only set l if i or j is negative
    local l = (i >= 0 and j >= 0) or utf8len(s)
    local startChar = (i >= 0) and i or l + i + 1
    local endChar = (j >= 0) and j or l + j + 1

    -- can't have start before end!
    if startChar > endChar then
        return ""
    end

    -- byte offsets to pass to string.sub
    local startByte, endByte = 1, bytes

    while pos <= bytes do
        len = len + 1

        if len == startChar then
            startByte = pos
        end

        pos = pos + utf8charbytes(s, pos)

        if len == endChar then
            endByte = pos - 1
            break
        end
    end

    if startChar > len then
        startByte = bytes + 1
    end
    if endChar < 1 then
        endByte = 0
    end

    return sub(s, startByte, endByte)
end

-- replace UTF-8 characters based on a mapping table
local function utf8replace(s, mapping)
    -- argument checking
    if type(s) ~= "string" then
        error("bad argument #1 to 'utf8replace' (string expected, got " .. type(s) .. ")")
    end
    if type(mapping) ~= "table" then
        error("bad argument #2 to 'utf8replace' (table expected, got " .. type(mapping) .. ")")
    end

    local pos = 1
    local bytes = len(s)
    local charbytes
    local newstr = ""

    while pos <= bytes do
        charbytes = utf8charbytes(s, pos)
        local c = sub(s, pos, pos + charbytes - 1)

        newstr = newstr .. (mapping[c] or c)

        pos = pos + charbytes
    end

    return newstr
end

-- identical to string.upper except it knows about unicode simple case conversions
local function utf8upper(s)
    return utf8replace(s, utf8_lc_uc)
end

-- identical to string.lower except it knows about unicode simple case conversions
local function utf8lower(s)
    return utf8replace(s, utf8_uc_lc)
end

-- identical to string.reverse except that it supports UTF-8
local function utf8reverse(s)
    -- argument checking
    if type(s) ~= "string" then
        error("bad argument #1 to 'utf8reverse' (string expected, got " .. type(s) .. ")")
    end

    local bytes = len(s)
    local pos = bytes
    local charbytes
    local newstr = ""

    while pos > 0 do
        c = byte(s, pos)
        while c >= 128 and c <= 191 do
            pos = pos - 1
            c = byte(s, pos)
        end

        charbytes = utf8charbytes(s, pos)

        newstr = newstr .. sub(s, pos, pos + charbytes - 1)

        pos = pos - 1
    end

    return newstr
end

-- http://en.wikipedia.org/wiki/Utf8
-- http://developer.coronalabs.com/code/utf-8-conversion-utility
local function utf8char(unicode)
    if unicode <= 0x7F then
        return char(unicode)
    end

    if (unicode <= 0x7FF) then
        local Byte0 = 0xC0 + math.floor(unicode / 0x40)
        local Byte1 = 0x80 + (unicode % 0x40)
        return char(Byte0, Byte1)
    end

    if (unicode <= 0xFFFF) then
        local Byte0 = 0xE0 + math.floor(unicode / 0x1000)
        local Byte1 = 0x80 + (math.floor(unicode / 0x40) % 0x40)
        local Byte2 = 0x80 + (unicode % 0x40)
        return char(Byte0, Byte1, Byte2)
    end

    if (unicode <= 0x10FFFF) then
        local code = unicode
        local Byte3 = 0x80 + (code % 0x40)
        code = math.floor(code / 0x40)
        local Byte2 = 0x80 + (code % 0x40)
        code = math.floor(code / 0x40)
        local Byte1 = 0x80 + (code % 0x40)
        code = math.floor(code / 0x40)
        local Byte0 = 0xF0 + code

        return char(Byte0, Byte1, Byte2, Byte3)
    end

    error 'Unicode cannot be greater than U+10FFFF!'
end

local shift_6 = 2 ^ 6
local shift_12 = 2 ^ 12
local shift_18 = 2 ^ 18

local utf8unicode
utf8unicode = function(str, i, j, byte_pos)
    i = i or 1
    j = j or i

    if i > j then
        return
    end

    local char, bytes

    if byte_pos then
        bytes = utf8charbytes(str, byte_pos)
        char = sub(str, byte_pos, byte_pos - 1 + bytes)
    else
        char, byte_pos = utf8sub(str, i, i), 0
        bytes = #char
    end

    local unicode

    if bytes == 1 then
        unicode = byte(char)
    end
    if bytes == 2 then
        local byte0, byte1 = byte(char, 1, 2)
        local code0, code1 = byte0 - 0xC0, byte1 - 0x80
        unicode = code0 * shift_6 + code1
    end
    if bytes == 3 then
        local byte0, byte1, byte2 = byte(char, 1, 3)
        local code0, code1, code2 = byte0 - 0xE0, byte1 - 0x80, byte2 - 0x80
        unicode = code0 * shift_12 + code1 * shift_6 + code2
    end
    if bytes == 4 then
        local byte0, byte1, byte2, byte3 = byte(char, 1, 4)
        local code0, code1, code2, code3 = byte0 - 0xF0, byte1 - 0x80, byte2 - 0x80, byte3 - 0x80
        unicode = code0 * shift_18 + code1 * shift_12 + code2 * shift_6 + code3
    end

    return unicode, utf8unicode(str, i + 1, j, byte_pos + bytes)
end

-- Returns an iterator which returns the next substring and its byte interval
local function utf8gensub(str, sub_len)
    sub_len = sub_len or 1
    local byte_pos = 1
    local len = #str
    return function(skip)
        if skip then
            byte_pos = byte_pos + skip
        end
        local char_count = 0
        local start = byte_pos
        repeat
            if byte_pos > len then
                return
            end
            char_count = char_count + 1
            local bytes = utf8charbytes(str, byte_pos)
            byte_pos = byte_pos + bytes

        until char_count == sub_len

        local last = byte_pos - 1
        local sub = sub(str, start, last)
        return sub, start, last
    end
end

local function binsearch(sortedTable, item, comp)
    local head, tail = 1, #sortedTable
    local mid = math.floor((head + tail) / 2)
    if not comp then
        while (tail - head) > 1 do
            if sortedTable[tonumber(mid)] > item then
                tail = mid
            else
                head = mid
            end
            mid = math.floor((head + tail) / 2)
        end
    else
    end
    if sortedTable[tonumber(head)] == item then
        return true, tonumber(head)
    elseif sortedTable[tonumber(tail)] == item then
        return true, tonumber(tail)
    else
        return false
    end
end
local function classMatchGenerator(class, plain)
    local codes = {}
    local ranges = {}
    local ignore = false
    local range = false
    local firstletter = true
    local unmatch = false

    local it = utf8gensub(class)

    local skip
    for c, bs, be in it do
        skip = be
        if not ignore and not plain then
            if c == "%" then
                ignore = true
            elseif c == "-" then
                table.insert(codes, utf8unicode(c))
                range = true
            elseif c == "^" then
                if not firstletter then
                    error('!!!')
                else
                    unmatch = true
                end
            elseif c == ']' then
                break
            else
                if not range then
                    table.insert(codes, utf8unicode(c))
                else
                    table.remove(codes) -- removing '-'
                    table.insert(ranges, {table.remove(codes), utf8unicode(c)})
                    range = false
                end
            end
        elseif ignore and not plain then
            if c == 'a' then -- %a: represents all letters. (ONLY ASCII)
                table.insert(ranges, {65, 90}) -- A - Z
                table.insert(ranges, {97, 122}) -- a - z
            elseif c == 'c' then -- %c: represents all control characters.
                table.insert(ranges, {0, 31})
                table.insert(codes, 127)
            elseif c == 'd' then -- %d: represents all digits.
                table.insert(ranges, {48, 57}) -- 0 - 9
            elseif c == 'g' then -- %g: represents all printable characters except space.
                table.insert(ranges, {1, 8})
                table.insert(ranges, {14, 31})
                table.insert(ranges, {33, 132})
                table.insert(ranges, {134, 159})
                table.insert(ranges, {161, 5759})
                table.insert(ranges, {5761, 8191})
                table.insert(ranges, {8203, 8231})
                table.insert(ranges, {8234, 8238})
                table.insert(ranges, {8240, 8286})
                table.insert(ranges, {8288, 12287})
            elseif c == 'l' then -- %l: represents all lowercase letters. (ONLY ASCII)
                table.insert(ranges, {97, 122}) -- a - z
            elseif c == 'p' then -- %p: represents all punctuation characters. (ONLY ASCII)
                table.insert(ranges, {33, 47})
                table.insert(ranges, {58, 64})
                table.insert(ranges, {91, 96})
                table.insert(ranges, {123, 126})
            elseif c == 's' then -- %s: represents all space characters.
                table.insert(ranges, {9, 13})
                table.insert(codes, 32)
                table.insert(codes, 133)
                table.insert(codes, 160)
                table.insert(codes, 5760)
                table.insert(ranges, {8192, 8202})
                table.insert(codes, 8232)
                table.insert(codes, 8233)
                table.insert(codes, 8239)
                table.insert(codes, 8287)
                table.insert(codes, 12288)
            elseif c == 'u' then -- %u: represents all uppercase letters. (ONLY ASCII)
                table.insert(ranges, {65, 90}) -- A - Z
            elseif c == 'w' then -- %w: represents all alphanumeric characters. (ONLY ASCII)
                table.insert(ranges, {48, 57}) -- 0 - 9
                table.insert(ranges, {65, 90}) -- A - Z
                table.insert(ranges, {97, 122}) -- a - z
            elseif c == 'x' then -- %x: represents all hexadecimal digits.
                table.insert(ranges, {48, 57}) -- 0 - 9
                table.insert(ranges, {65, 70}) -- A - F
                table.insert(ranges, {97, 102}) -- a - f
            else
                if not range then
                    table.insert(codes, utf8unicode(c))
                else
                    table.remove(codes) -- removing '-'
                    table.insert(ranges, {table.remove(codes), utf8unicode(c)})
                    range = false
                end
            end
            ignore = false
        else
            if not range then
                table.insert(codes, utf8unicode(c))
            else
                table.remove(codes) -- removing '-'
                table.insert(ranges, {table.remove(codes), utf8unicode(c)})
                range = false
            end
            ignore = false
        end

        firstletter = false
    end

    table.sort(codes)

    local function inRanges(charCode)
        for _, r in ipairs(ranges) do
            if r[1] <= charCode and charCode <= r[2] then
                return true
            end
        end
        return false
    end
    if not unmatch then
        return function(charCode)
            return binsearch(codes, charCode) or inRanges(charCode)
        end, skip
    else
        return function(charCode)
            return charCode ~= -1 and not (binsearch(codes, charCode) or inRanges(charCode))
        end, skip
    end
end

-- utf8sub with extra argument, and extra result value 
local function utf8subWithBytes(s, i, j, sb)
    -- argument defaults
    j = j or -1

    local pos = sb or 1
    local bytes = len(s)
    local len = 0

    -- only set l if i or j is negative
    local l = (i >= 0 and j >= 0) or utf8len(s)
    local startChar = (i >= 0) and i or l + i + 1
    local endChar = (j >= 0) and j or l + j + 1

    -- can't have start before end!
    if startChar > endChar then
        return ""
    end

    -- byte offsets to pass to string.sub
    local startByte, endByte = 1, bytes

    while pos <= bytes do
        len = len + 1

        if len == startChar then
            startByte = pos
        end

        pos = pos + utf8charbytes(s, pos)

        if len == endChar then
            endByte = pos - 1
            break
        end
    end

    if startChar > len then
        startByte = bytes + 1
    end
    if endChar < 1 then
        endByte = 0
    end

    return sub(s, startByte, endByte), endByte + 1
end

local cache = setmetatable({}, {
    __mode = 'kv'
})
local cachePlain = setmetatable({}, {
    __mode = 'kv'
})
local function matcherGenerator(regex, plain)
    local matcher = {
        functions = {},
        captures = {}
    }
    if not plain then
        cache[regex] = matcher
    else
        cachePlain[regex] = matcher
    end
    local function simple(func)
        return function(cC)
            if func(cC) then
                matcher:nextFunc()
                matcher:nextStr()
            else
                matcher:reset()
            end
        end
    end
    local function star(func)
        return function(cC)
            if func(cC) then
                matcher:fullResetOnNextFunc()
                matcher:nextStr()
            else
                matcher:nextFunc()
            end
        end
    end
    local function minus(func)
        return function(cC)
            if func(cC) then
                matcher:fullResetOnNextStr()
            end
            matcher:nextFunc()
        end
    end
    local function question(func)
        return function(cC)
            if func(cC) then
                matcher:fullResetOnNextFunc()
                matcher:nextStr()
            end
            matcher:nextFunc()
        end
    end

    local function capture(id)
        return function(cC)
            local l = matcher.captures[id][2] - matcher.captures[id][1]
            local captured = utf8sub(matcher.string, matcher.captures[id][1], matcher.captures[id][2])
            local check = utf8sub(matcher.string, matcher.str, matcher.str + l)
            if captured == check then
                for i = 0, l do
                    matcher:nextStr()
                end
                matcher:nextFunc()
            else
                matcher:reset()
            end
        end
    end
    local function captureStart(id)
        return function(cC)
            matcher.captures[id][1] = matcher.str
            matcher:nextFunc()
        end
    end
    local function captureStop(id)
        return function(cC)
            matcher.captures[id][2] = matcher.str - 1
            matcher:nextFunc()
        end
    end

    local function balancer(str)
        local sum = 0
        local bc, ec = utf8sub(str, 1, 1), utf8sub(str, 2, 2)
        local skip = len(bc) + len(ec)
        bc, ec = utf8unicode(bc), utf8unicode(ec)
        return function(cC)
            if cC == ec and sum > 0 then
                sum = sum - 1
                if sum == 0 then
                    matcher:nextFunc()
                end
                matcher:nextStr()
            elseif cC == bc then
                sum = sum + 1
                matcher:nextStr()
            else
                if sum == 0 or cC == -1 then
                    sum = 0
                    matcher:reset()
                else
                    matcher:nextStr()
                end
            end
        end, skip
    end

    matcher.functions[1] = function(cC)
        matcher:fullResetOnNextStr()
        matcher.seqStart = matcher.str
        matcher:nextFunc()
        if (matcher.str > matcher.startStr and matcher.fromStart) or matcher.str >= matcher.stringLen then
            matcher.stop = true
            matcher.seqStart = nil
        end
    end

    local lastFunc
    local ignore = false
    local skip = nil
    local it = (function()
        local gen = utf8gensub(regex)
        return function()
            return gen(skip)
        end
    end)()
    local cs = {}
    for c, bs, be in it do
        skip = nil
        if plain then
            table.insert(matcher.functions, simple(classMatchGenerator(c, plain)))
        else
            if ignore then
                if find('123456789', c, 1, true) then
                    if lastFunc then
                        table.insert(matcher.functions, simple(lastFunc))
                        lastFunc = nil
                    end
                    table.insert(matcher.functions, capture(tonumber(c)))
                elseif c == 'b' then
                    if lastFunc then
                        table.insert(matcher.functions, simple(lastFunc))
                        lastFunc = nil
                    end
                    local b
                    b, skip = balancer(sub(regex, be + 1, be + 9))
                    table.insert(matcher.functions, b)
                else
                    lastFunc = classMatchGenerator('%' .. c)
                end
                ignore = false
            else
                if c == '*' then
                    if lastFunc then
                        table.insert(matcher.functions, star(lastFunc))
                        lastFunc = nil
                    else
                        error('invalid regex after ' .. sub(regex, 1, bs))
                    end
                elseif c == '+' then
                    if lastFunc then
                        table.insert(matcher.functions, simple(lastFunc))
                        table.insert(matcher.functions, star(lastFunc))
                        lastFunc = nil
                    else
                        error('invalid regex after ' .. sub(regex, 1, bs))
                    end
                elseif c == '-' then
                    if lastFunc then
                        table.insert(matcher.functions, minus(lastFunc))
                        lastFunc = nil
                    else
                        error('invalid regex after ' .. sub(regex, 1, bs))
                    end
                elseif c == '?' then
                    if lastFunc then
                        table.insert(matcher.functions, question(lastFunc))
                        lastFunc = nil
                    else
                        error('invalid regex after ' .. sub(regex, 1, bs))
                    end
                elseif c == '^' then
                    if bs == 1 then
                        matcher.fromStart = true
                    else
                        error('invalid regex after ' .. sub(regex, 1, bs))
                    end
                elseif c == '$' then
                    if be == len(regex) then
                        matcher.toEnd = true
                    else
                        error('invalid regex after ' .. sub(regex, 1, bs))
                    end
                elseif c == '[' then
                    if lastFunc then
                        table.insert(matcher.functions, simple(lastFunc))
                    end
                    lastFunc, skip = classMatchGenerator(sub(regex, be + 1))
                elseif c == '(' then
                    if lastFunc then
                        table.insert(matcher.functions, simple(lastFunc))
                        lastFunc = nil
                    end
                    table.insert(matcher.captures, {})
                    table.insert(cs, #matcher.captures)
                    table.insert(matcher.functions, captureStart(cs[#cs]))
                    if sub(regex, be + 1, be + 1) == ')' then
                        matcher.captures[#matcher.captures].empty = true
                    end
                elseif c == ')' then
                    if lastFunc then
                        table.insert(matcher.functions, simple(lastFunc))
                        lastFunc = nil
                    end
                    local cap = table.remove(cs)
                    if not cap then
                        error('invalid capture: "(" missing')
                    end
                    table.insert(matcher.functions, captureStop(cap))
                elseif c == '.' then
                    if lastFunc then
                        table.insert(matcher.functions, simple(lastFunc))
                    end
                    lastFunc = function(cC)
                        return cC ~= -1
                    end
                elseif c == '%' then
                    ignore = true
                else
                    if lastFunc then
                        table.insert(matcher.functions, simple(lastFunc))
                    end
                    lastFunc = classMatchGenerator(c)
                end
            end
        end
    end
    if #cs > 0 then
        error('invalid capture: ")" missing')
    end
    if lastFunc then
        table.insert(matcher.functions, simple(lastFunc))
    end
    lastFunc = nil
    ignore = nil

    table.insert(matcher.functions, function()
        if matcher.toEnd and matcher.str ~= matcher.stringLen then
            matcher:reset()
        else
            matcher.stop = true
        end
    end)

    matcher.nextFunc = function(self)
        self.func = self.func + 1
    end
    matcher.nextStr = function(self)
        self.str = self.str + 1
    end
    matcher.strReset = function(self)
        local oldReset = self.reset
        local str = self.str
        self.reset = function(s)
            s.str = str
            s.reset = oldReset
        end
    end
    matcher.fullResetOnNextFunc = function(self)
        local oldReset = self.reset
        local func = self.func + 1
        local str = self.str
        self.reset = function(s)
            s.func = func
            s.str = str
            s.reset = oldReset
        end
    end
    matcher.fullResetOnNextStr = function(self)
        local oldReset = self.reset
        local str = self.str + 1
        local func = self.func
        self.reset = function(s)
            s.func = func
            s.str = str
            s.reset = oldReset
        end
    end

    matcher.process = function(self, str, start)

        self.func = 1
        start = start or 1
        self.startStr = (start >= 0) and start or utf8len(str) + start + 1
        self.seqStart = self.startStr
        self.str = self.startStr
        self.stringLen = utf8len(str) + 1
        self.string = str
        self.stop = false

        self.reset = function(s)
            s.func = 1
        end

        local lastPos = self.str
        local lastByte
        local char
        while not self.stop do
            if self.str < self.stringLen then
                --[[ if lastPos < self.str then
					print('last byte', lastByte)
					char, lastByte = utf8subWithBytes(str, 1, self.str - lastPos - 1, lastByte)
					char, lastByte = utf8subWithBytes(str, 1, 1, lastByte)
					lastByte = lastByte - 1
				else
					char, lastByte = utf8subWithBytes(str, self.str, self.str)
				end
				lastPos = self.str ]]
                char = utf8sub(str, self.str, self.str)
                -- print('char', char, utf8unicode(char))
                self.functions[self.func](utf8unicode(char))
            else
                self.functions[self.func](-1)
            end
        end

        if self.seqStart then
            local captures = {}
            for _, pair in pairs(self.captures) do
                if pair.empty then
                    table.insert(captures, pair[1])
                else
                    table.insert(captures, utf8sub(str, pair[1], pair[2]))
                end
            end
            return self.seqStart, self.str - 1, unpack(captures)
        end
    end

    return matcher
end

-- string.find
local function utf8find(str, regex, init, plain)
    local matcher = cache[regex] or matcherGenerator(regex, plain)
    return matcher:process(str, init)
end

-- string.match
local function utf8match(str, regex, init)
    init = init or 1
    local found = {utf8find(str, regex, init)}
    if found[1] then
        if found[3] then
            return unpack(found, 3)
        end
        return utf8sub(str, found[1], found[2])
    end
end

-- string.gmatch
local function utf8gmatch(str, regex, all)
    regex = (utf8sub(regex, 1, 1) ~= '^') and regex or '%' .. regex
    local lastChar = 1
    return function()
        local found = {utf8find(str, regex, lastChar)}
        if found[1] then
            lastChar = found[2] + 1
            if found[all and 1 or 3] then
                return unpack(found, all and 1 or 3)
            end
            return utf8sub(str, found[1], found[2])
        end
    end
end

local function replace(repl, args)
    local ret = ''
    if type(repl) == 'string' then
        local ignore = false
        local num = 0
        for c in utf8gensub(repl) do
            if not ignore then
                if c == '%' then
                    ignore = true
                else
                    ret = ret .. c
                end
            else
                num = tonumber(c)
                if num then
                    ret = ret .. args[num]
                else
                    ret = ret .. c
                end
                ignore = false
            end
        end
    elseif type(repl) == 'table' then
        ret = repl[args[1] or args[0]] or ''
    elseif type(repl) == 'function' then
        if #args > 0 then
            ret = repl(unpack(args, 1)) or ''
        else
            ret = repl(args[0]) or ''
        end
    end
    return ret
end
-- string.gsub
local function utf8gsub(str, regex, repl, limit)
    limit = limit or -1
    local ret = ''
    local prevEnd = 1
    local it = utf8gmatch(str, regex, true)
    local found = {it()}
    local n = 0
    while #found > 0 and limit ~= n do
        local args = {
            [0] = utf8sub(str, found[1], found[2]),
            unpack(found, 3)
        }
        ret = ret .. utf8sub(str, prevEnd, found[1] - 1) .. replace(repl, args)
        prevEnd = found[2] + 1
        n = n + 1
        found = {it()}
    end
    return ret .. utf8sub(str, prevEnd), n
end

---------

local translationtable = {
    Favorites = {
        jp = "お気に入り",
        en = "Favorites"
    },
    HavntopenMarket = {
        jp = "マーケット画面を開いていません",
        en = "Please open the market window."
    }
}

local function L_(str)
    if (option.GetCurrentCountry() == "Japanese") then
        return translationtable[str].jp
    else
        return translationtable[str].en
    end
end

--[[function market_favorite_rebuild_SAVETOSTRUCTURE()
    local frame = ui.GetFrame('market_favorite_rebuild')
    if (frame == nil) then
        return
    end
    local slotset = frame:GetChild('slot_set')
    if (slotset == nil) then
        return
    end
    slotset = tolua.cast(slotset, 'ui::CSlotSet')

    for i = 0, slotset:GetSlotCount() - 1 do
        local slot = slotset:GetSlotByIndex(i)
        if (slot ~= nil) then
            local val = slot:GetUserValue('clsid')
            g.settings.items[i + 1] = {
                clsid = tonumber(val)
            }

        else

            g.settings.items[i + 1] = nil
        end
    end
end
function market_favorite_rebuild_LOADFROMSTRUCTURE()
    local frame = ui.GetFrame('market_favorite_rebuild')
    if (frame == nil or g.settings.items == nil) then
        return
    end

    local obj = frame:GetChild('slot_set')
    local slotset = tolua.cast(obj, 'ui::CSlotSet')
    if (slotset == nil) then
        return
    end
    slotset:ClearIconAll()

    for i = 0, slotset:GetSlotCount() - 1 do
        -- statements
        local slot = slotset:GetSlotByIndex(i)
        if (slot ~= nil) then
            slot:SetText("")
            slot:RemoveAllChild()
            slot:SetSkinName('invenslot2')
        end
    end
    for i = 1, #g.settings.items do
        EBI_try_catch {
            try = function()

                local item = g.settings.items[i]
                if (item ~= nil) then

                    local slot = slotset:GetSlotByIndex(i - 1)
                    if (item['clsid'] ~= nil) then
                        slot:SetUserValue('clsid', tostring(item['clsid']))
                        -- アイコンを生成
                        local invitem = GetClassByType("Item", item['clsid'])

                        SET_SLOT_ITEM_CLS(slot, invitem)
                        SET_SLOT_STYLESET(slot, invitem)
                    end
                end
            end,
            catch = function(error)
                CHAT_SYSTEM(error)
            end
        }
    end
end]]
--[[function market_favorite_rebuild_INIT_FRAME(frame)
    EBI_try_catch {
        try = function()

        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }
end]]
--[[function market_favorite_rebuild_MARKET_ITEMLIST_JUMPER(frame, msg, argStr, argNum)
    if (OLD_ON_MARKET_ITEM_LIST ~= nil) then
        OLD_ON_MARKET_ITEM_LIST(frame, msg, argStr, argNum)
    end
    market_favorite_rebuild_MARKET_ITEMLIST(frame)
end
function market_favorite_rebuild_MARKET_ITEMLIST(frame)
    EBI_try_catch {
        try = function()
            local frame = ui.GetFrame('market')

            for i = 0, 20 do
                -- statements
                local ctrl2 = GET_CHILD_RECURSIVELY(frame, 'ITEM2EQUIP_' .. tostring(i))
                local ctrl1 = GET_CHILD_RECURSIVELY(frame, 'ITEM_EQUIP_' .. tostring(i))
                local pic

                if (ctrl2 ~= nil) then
                    pic = GET_CHILD_RECURSIVELY(ctrl2, 'pic')
                elseif (ctrl1 ~= nil) then
                    -- statements

                    pic = GET_CHILD_RECURSIVELY(ctrl1, 'pic')
                end

            end
        end,
        catch = function(error)
            CHAT_SYSTEM(error)
        end
    }
end]]
--[[function market_favorite_rebuild_MARKET_FIND_PAGE(frame, page)
    local function CLAMP_MARKET_PAGE_NUMBER(frame, pageControllerName, page)
        if page == nil then
            return 0
        end
        local pagecontrol = GET_CHILD(frame, pageControllerName)
        local MaxPage = pagecontrol:GetMaxPage()
        if page >= MaxPage then
            page = MaxPage - 1
        elseif page <= 0 then
            page = 0
        end
        return page
    end

    page = CLAMP_MARKET_PAGE_NUMBER(frame, 'pagecontrol', page)

    local function GET_SEARCH_PRICE_ORDER(frame)
        local priceOrderCheck_0 = GET_CHILD_RECURSIVELY(frame, 'priceOrderCheck_0')
        local priceOrderCheck_1 = GET_CHILD_RECURSIVELY(frame, 'priceOrderCheck_1')
        if priceOrderCheck_0 == nil or priceOrderCheck_1 == nil then
            return -1
        end

        if priceOrderCheck_0:IsChecked() == 1 then
            return 0
        end
        if priceOrderCheck_1:IsChecked() == 1 then
            return 1
        end
        return 0 -- default
    end

    local orderByDesc = GET_SEARCH_PRICE_ORDER(frame)
    if orderByDesc < 0 then
        return
    end

    local function GET_SEARCH_TEXT(frame)
        local defaultValue = ''
        local market_search = GET_CHILD_RECURSIVELY(frame, 'itemSearchSet')
        if market_search ~= nil and market_search:IsVisible() == 1 then
            local searchEdit = GET_CHILD_RECURSIVELY(market_search, 'searchEdit')
            local findItem = searchEdit:GetText()
            local minLength = 0
            local findItemStrLength = findItem.len(findItem)
            local maxLength = 120
            if config.GetServiceNation() == "GLOBAL" then
                minLength = 1
                maxLength = 40
            elseif config.GetServiceNation() == "JPN" then
                maxLength = 120
            elseif config.GetServiceNation() == "KOR" then
                maxLength = 120
            end
            if findItemStrLength ~= 0 then -- 있다면 길이 조건 체크
                if findItemStrLength <= minLength then
                    ui.SysMsg(ClMsg("InvalidFindItemQueryMin"))
                    return defaultValue
                elseif findItemStrLength > maxLength then
                    ui.SysMsg(ClMsg("InvalidFindItemQueryMax"))
                    return defaultValue
                end
            end
            return findItem
        end
        return defaultValue
    end

    local searchText = GET_SEARCH_TEXT(frame)
    local category, _category, _subCategory = GET_CATEGORY_STRING(frame)
    if category == '' and searchText == '' then
        return
    end

    if searchText ~= '' and ui.GetPaperLength(searchText) < 2 then
        ui.SysMsg(ClMsg('InvalidFindItemQueryMin'))
        return
    end

    local function GET_SEARCH_OPTION(frame)
        local optionName, optionValue = {}, {}
        local optionSet = {} -- for checking duplicate option
        local category = frame:GetUserValue('SELECTED_CATEGORY')

        -- level range
        local levelRangeSet = GET_CHILD_RECURSIVELY(frame, 'levelRangeSet')
        if levelRangeSet ~= nil and levelRangeSet:IsVisible() == 1 then
            local minEdit = GET_CHILD_RECURSIVELY(levelRangeSet, 'minEdit')
            local maxEdit = GET_CHILD_RECURSIVELY(levelRangeSet, 'maxEdit')
            local opValue = GET_MINMAX_QUERY_VALUE_STRING(minEdit, maxEdit)
            if opValue ~= '' then
                local opName = 'CT_UseLv'
                if category == 'OPTMisc' then
                    opName = 'Level'
                end
                optionName[#optionName + 1] = opName
                optionValue[#optionValue + 1] = opValue
                optionSet[opName] = true
            end
        end

        -- grade
        local gradeCheckSet = GET_CHILD_RECURSIVELY(frame, 'gradeCheckSet')
        if gradeCheckSet ~= nil and gradeCheckSet:IsVisible() == 1 then
            local checkStr = ''
            local matchCnt, lastMatch = 0, nil
            local childCnt = gradeCheckSet:GetChildCount()
            for i = 0, childCnt - 1 do
                local child = gradeCheckSet:GetChildByIndex(i)
                if string.find(child:GetName(), 'gradeCheck_') ~= nil then
                    AUTO_CAST(child)
                    if child:IsChecked() == 1 then
                        local grade = string.sub(child:GetName(), string.find(child:GetName(), '_') + 1)
                        checkStr = checkStr .. grade .. ''
                        matchCnt = matchCnt + 1
                        lastMatch = grade
                    end
                end
            end
            if checkStr ~= '' then
                if matchCnt == 1 then
                    checkStr = checkStr .. lastMatch
                end
                local opName = 'CT_ItemGrade'
                optionName[#optionName + 1] = opName
                optionValue[#optionValue + 1] = checkStr
                optionSet[opName] = true
            end
        end

        -- random option flag
        local appCheckSet = GET_CHILD_RECURSIVELY(frame, 'appCheckSet')
        if appCheckSet ~= nil and appCheckSet:IsVisible() == 1 then
            local ranOpName, ranOpValue
            local appCheck_0 = GET_CHILD(appCheckSet, 'appCheck_0')
            if appCheck_0:IsChecked() == 1 then
                ranOpName = 'Random_Item'
                ranOpValue = '2'
            end

            local appCheck_1 = GET_CHILD(appCheckSet, 'appCheck_1')
            if appCheck_1:IsChecked() == 1 then
                ranOpName = 'Random_Item'
                ranOpValue = '1'
            end

            if ranOpName ~= nil then
                optionName[#optionName + 1] = ranOpName
                optionValue[#optionValue + 1] = ranOpValue
                optionSet[ranOpName] = true
            end
        end

        -- detail setting
        local detailOptionSet = GET_CHILD_RECURSIVELY(frame, 'detailOptionSet')
        if detailOptionSet ~= nil and detailOptionSet:IsVisible() == 1 then
            local curCnt = detailOptionSet:GetUserIValue('ADD_SELECT_COUNT')
            for i = 0, curCnt do
                local selectSet = GET_CHILD_RECURSIVELY(detailOptionSet, 'SELECT_' .. i)
                if selectSet ~= nil and selectSet:IsVisible() == 1 then
                    local nameList = GET_CHILD(selectSet, 'groupList')
                    local opName = nameList:GetSelItemKey()
                    if opName ~= '' then
                        local opValue = GET_MINMAX_QUERY_VALUE_STRING(GET_CHILD_RECURSIVELY(selectSet, 'minEdit'),
                            GET_CHILD_RECURSIVELY(selectSet, 'maxEdit'))
                        if opValue ~= '' and optionSet[opName] == nil then
                            optionName[#optionName + 1] = opName
                            optionValue[#optionValue + 1] = opValue
                            optionSet[opName] = true
                        end
                    end
                end
            end
        end

        -- option group
        local optionGroupSet = GET_CHILD_RECURSIVELY(frame, 'optionGroupSet')
        if optionGroupSet ~= nil and optionGroupSet:IsVisible() == 1 then
            local curCnt = optionGroupSet:GetUserIValue('ADD_SELECT_COUNT')
            for i = 0, curCnt do
                local selectSet = GET_CHILD_RECURSIVELY(optionGroupSet, 'SELECT_' .. i)
                if selectSet ~= nil then
                    local nameList = GET_CHILD(selectSet, 'nameList')
                    local opName = nameList:GetSelItemKey()
                    if opName ~= '' then
                        local opValue = GET_MINMAX_QUERY_VALUE_STRING(GET_CHILD_RECURSIVELY(selectSet, 'minEdit'),
                            GET_CHILD_RECURSIVELY(selectSet, 'maxEdit'))
                        if opValue ~= '' and optionSet[opName] == nil then
                            optionName[#optionName + 1] = opName
                            optionValue[#optionValue + 1] = opValue
                            optionSet[opName] = true
                        end
                    end
                end
            end
        end

        -- gem option
        local gemOptionSet = GET_CHILD_RECURSIVELY(frame, 'gemOptionSet')
        if gemOptionSet ~= nil and gemOptionSet:IsVisible() == 1 then
            local levelMinEdit = GET_CHILD_RECURSIVELY(gemOptionSet, 'levelMinEdit')
            local levelMaxEdit = GET_CHILD_RECURSIVELY(gemOptionSet, 'levelMaxEdit')
            local roastingMinEdit = GET_CHILD_RECURSIVELY(gemOptionSet, 'roastingMinEdit')
            local roastingMaxEdit = GET_CHILD_RECURSIVELY(gemOptionSet, 'roastingMaxEdit')
            if category == 'Gem' then
                local opValue = GET_MINMAX_QUERY_VALUE_STRING(levelMinEdit, levelMaxEdit)
                if opValue ~= '' then
                    optionName[#optionName + 1] = 'GemLevel'
                    optionValue[#optionValue + 1] = opValue
                    optionSet['GemLevel'] = true
                end

                local roastOpValue = GET_MINMAX_QUERY_VALUE_STRING(roastingMinEdit, roastingMaxEdit)
                if roastOpValue ~= '' then
                    optionName[#optionName + 1] = 'GemRoastingLv'
                    optionValue[#optionValue + 1] = roastOpValue
                    optionSet['GemRoastingLv'] = true
                end
            elseif category == 'Card' then
                local opValue = GET_MINMAX_QUERY_VALUE_STRING(levelMinEdit, levelMaxEdit)
                if opValue ~= '' then
                    optionName[#optionName + 1] = 'CardLevel'
                    optionValue[#optionValue + 1] = opValue
                    optionSet['CardLevel'] = true
                end
            end
        end

        return optionName, optionValue
    end

    local optionKey, optionValue = GET_SEARCH_OPTION(frame)
    local itemCntPerPage = GET_MARKET_SEARCH_ITEM_COUNT(_category)
    MarketSearch(page + 1, orderByDesc, searchText, category, optionKey, optionValue, itemCntPerPage)
    DISABLE_BUTTON_DOUBLECLICK_WITH_CHILD(frame:GetName(), 'commitSet', 'searchBtn', 1)
    MARKET_OPTION_BOX_CLOSE_CLICK(frame)
end

function market_favorite_rebuild_MARKET_REQ_LIST(frame)
    frame = frame:GetTopParentFrame()
    market_favorite_rebuild_MARKET_FIND_PAGE(frame, 0)
end]]

--[[function market_favorite_rebuild_TOGGLE_FRAME()
    if g.frame:IsVisible() == 0 then
        -- 非表示->表示
        g.frame:ShowWindow(1)
        g.settings.enable = true
    else
        -- 表示->非表示
        g.frame:ShowWindow(0)
        g.settings.show = false
    end

    market_favorite_rebuild_SAVE_SETTINGS()
end]]

-- フレーム場所保存処理
]==] --[==[function MINI_ADDONS_LANG(str)
    -- !追加の度に更新
    if g.lang == "Japanese" then
        if str == "Skip confirmation for admission of 4 or less people" then
            str = "4人以下入場時の確認をスキップ"
        elseif str == "Raid records movable and resizable" then
            str = "レイドレコードを移動可能にしてサイズを変更"
        elseif str == "Hide buffs for party members" then
            str = "パーティーメンバーのバフを非表示にします"
        elseif str == "You can choose which buffs to display" then
            str = "表示するバフを選択できます"
        elseif str == "Perfect and Black Market notices not displayed in chat" then
            str = "パーフェクトとブラックマーケットのお知らせをチャットに表示しません"
        elseif str == "Fixed channel display misalignment for Japanese ver" then
            str = "チャンネル表示のズレを修正"
        elseif str == "Hide minibutton in upper right corner during raid" then
            str = "レイド時右上のミニボタン非表示"
        elseif str == "Keep shop list open when moving to town" then
            str = "街では、右上の商店一覧を常に表示します"
        elseif str == "Allow moving selection frame on restart" then
            str = "リスタート時の選択肢フレームを動かせる様にします"
        elseif str == "Automatic display of pet summon frame" then
            str = "ペット召喚フレームを自動表示"
        elseif str == "Controls various dialogs" then
            str = "各種ダイアログをコントロールします"
        elseif str == "Set auto casting per character" then
            str = "オートキャスティングをキャラ毎に設定"
        elseif str == "Automatically used when acquiring coin items" then
            str =
                "傭兵団コイン、シーズンコイン、王国再建団コインを取得時に自動で使用します"
        elseif str == "Notification of forgetting to equip ark and emblem upon entry to the hard raid" then
            str = "ハードレイド入場時にアークやエンブレムの装備忘れをお知らせします"
        elseif str == "Lower frame layer level during auto match" then
            str = "オートマッチ時のフレームのレイヤーレベルを下げます"
        elseif str == "Hide the quest list" then
            str = "クエストリストを非表示にします"
        elseif str == "Change the upper left display to the character's name" then
            str = "左上の表示をキャラクター名に変更します"
        elseif str == "Displays the channel switching frame" then
            str = "チャンネル切替フレームを表示します"
        elseif str == "Adjust my effects from 1 to 100" then
            str = "自分のエフェクトを調整します。1~100"
        elseif str == "Adjust boss effects from 1 to 100" then
            str = "ボスのエフェクトを調整します。1~100"
        elseif str == "Adjust other people's effects from 1 to 100, recommended 75" then
            str = "他人のエフェクトを調整します。1~100。おすすめは75"
        elseif str == "Automate the display of the Goddess Protection gacha frame" then
            str = "女神の加護ガチャフレーム表示を自動化します"
        elseif str == "When turned on, the gacha starts automatically.CC required for switching" then
            str = "ONにすると自動でガチャスタートします。切替にCC必要です"
        elseif str == "Automatically sets items for skill refining" then
            str = "スキル錬成のアイテムを自動でセットします"
        elseif str == "Add a Relic to the character's gauge" then
            str = "キャラクターゲージにレリックを追加します"
        elseif str == "Prevents character change mistakes during the hard raid on the Dreamy& Abyss" then
            str = "夢幻＆深淵のハードレイド時のキャラクターチェンジミスを防ぎます"
        elseif str == "Toggle party info frame. For mouse mode.Party info rightclick" then
            str =
                "パーティーフレームの表示切替。右クリックで小さくします。マウスモード用"
        elseif str == "The maximum coin limit for each store is raised to 99999" then
            str = "各商店のコインの上限を99999に引き上げます"
        elseif str == "Always move the BGM player in city" then
            str = "街でBGMプレイヤーを常に動かします"
        elseif str == "Notify others of vakarine equipment in raid" then
            str = "レイド時、ヴァカリネ装備を他人にお知らせ"
        elseif str == "Receive weekly boss reward automatically" then -- "Receive Velnice dungeon reward automatically"
            str = "週間ボスレイド報酬を自動で受け取り"
        elseif str == "Receive Velnice dungeon reward automatically" then -- 
            str = "ヴェルニケダンジョン報酬を自動で受け取り"
        elseif str == "Hide the potion frame of the cupole.Memorizes frame position even when OFF" then -- Hide Ragana in city
            str = "クポルのポーションフレームを非表示に。OFFでもフレームの位置記憶"
        elseif str == "Hide Ragana in city" then -- icor_status_search
            str = "街にいるラガナを非表示にします" -- Equip Refining, Automate weapon/armor enhancement
        elseif str == "Equip Refining, Automate weapon/armor enhancement" then
            str = "装備錬成、武器防具ステータス付与を自動化"
        elseif str == "Search the status of icor in the inventory" then
            str = "インベントリでイコルをステータス検索出来る様に" -- Remember the previous level of the Velnice dungeon
        elseif str == "Remember the previous level of the Velnice dungeon" then -- Eliminate around separate buff frame
            str = "ヴェルニケダンジョンの前回の階層を覚えます"
        elseif str == "Eliminate around separate buff frame" then -- Group chat selection can be selected from chat frame
            str = "セパレートバフフレームの周りを綺麗にします"
        elseif str == "Group chats can be selected from chat frame" then -- Group chat selection can be selected from chat frame
            str = "グループチャットをチャットフレームから選択出来ます" -- "Add member info to various rightclick menu"
        elseif str == "Add member info to various rightclick menu" then -- Announcing the arrival of Baubas
            str = "様々な右クリックメニューにメンバーインフォを追加します"
        elseif str == "Announcing the arrival of Baubas" then
            str = "バウバス登場をお知らせ"
        elseif str == "Death of a PT member is indicated in Nicochat" then
            str = "PTメンバーの死亡をニコチャットで表示"
        elseif str == "Notification switch to guild chat" then
            str = "ギルドチャットへのお知らせ切替え"
        elseif str == "Check to enable" then
            str = "チェックすると有効化"
        elseif str == "※Character change is required to enable or disable some functions" then
            str = "※一部の機能の有効化、無効化の切替はキャラクターチェンジが必要です"
        end
    elseif g.lang == "kr" then
        if str == "Skip confirmation for admission of 4 or less people" then
            str = "4인 이하 입장 시 확인을 건너뜁니다"
        elseif str == "Raid records movable and resizable" then
            str = "레이드 기록의 이동이 가능하고, 크기 조절을 할 수 있습니다"
        elseif str == "Hide buffs for party members" then
            str = "파티원 버프를 숨깁니다"
        elseif str == "You can choose which buffs to display" then
            str = "표시할 버프를 선택할 수 있습니다"
        elseif str == "Perfect and Black Market notices not displayed in chat" then
            str = "완벽함 메시지 및 블랙 마켓 공지를 채팅에 표시 하지 않습니다"
        elseif str == "Fixed channel display misalignment for Japanese ver" then
            str = "일본어 버전의 채널 표시 정렬을 수정했습니다"
        elseif str == "Hide minibutton in upper right corner during raid" then
            str = "레이드 중 오른쪽 상단의 미니 버튼을 숨깁니다"
        elseif str == "Keep shop list open when moving to town" then
            str = "도시 이동 시 상점 목록을 항상 열어둡니다"
        elseif str == "Allow moving selection frame on restart" then
            str = "재시작 시 선택 프레임을 이동할 수 있게 합니다"
        elseif str == "Automatic display of pet summon frame" then
            str = "펫 소환 프레임을 자동으로 표시합니다"
        elseif str == "Controls various dialogs" then
            str = "각종 채팅을 제어합니다"
        elseif str == "Set auto casting per character" then
            str = "캐릭터별로 자동 시전 설정"
        elseif str == "Automatically used when acquiring coin items" then
            str =
                "용병단 증표, 시즌 여신의 증표, 왕국 재건단 주화를 획득할 때 자동으로 사용합니다"
        elseif str == "Notification of forgetting to equip ark and emblem upon entry to the hard raid" then
            str = "하드 레이드 입장시 아크 및 인장의 미착용을 알립니다"
        elseif str == "Lower frame layer level during auto match" then
            str = "자동 매칭 시 프레임 레이어 레벨을 낮춥니다"
        elseif str == "Hide the quest list" then
            str = "퀘스트 목록을 숨깁니다"
        elseif str == "Change the upper left display to the character's name" then
            str = "왼쪽 상단 표시를 캐릭터 이름으로 변경합니다"
        elseif str == "Displays the channel switching frame" then
            str = "채널 전환 프레임을 표시합니다"
        elseif str == "Adjust my effects from 1 to 100" then
            str = "자신의 효과를 조정합니다 1에서 100까지"
        elseif str == "Adjust boss effects from 1 to 100" then
            str = "보스 효과를 1에서 100으로 조정"
        elseif str == "Adjust other people's effects from 1 to 100, recommended 75" then
            str = "다른 사람의 이펙트를 1에서 100까지 조정합니다. 추천 75"
        elseif str == "Automate the display of the Goddess Protection gacha frame" then
            str = "여신의 가호 가챠 프레임 표시를 자동화합니다"
        elseif str == "When turned on, the gacha starts automatically.CC required for switching" then
            str = "ON으로 설정하면 자동으로 가챠가 시작됩니다. 전환 시 CC 필요합니다"
        elseif str == "Automatically sets items for skill refining" then
            str = "스킬 연성을 위한 아이템을 자동으로 설정합니다"
        elseif str == "Add a Relic to the character's gauge" then
            str = "캐릭터 게이지에 유물을 추가합니다"
        elseif str == "Prevents character change mistakes during the hard raid on the Dreamy& Abyss" then
            str = "몽환 & 심연의 하드 레이드 중 캐릭터 변경 실수를 방지합니다"
        elseif str == "Toggle party info frame. For mouse mode.Party info rightclick" then
            str = "파티 정보 프레임 표시 전환. 마우스 모드용. 오른쪽 클릭으로 작게 합니다"
        elseif str == "The maximum coin limit for each store is raised to 99999" then
            str = "각 상점의 코인 최대 한도를 99999로 올립니다"
        elseif str == "Always move the BGM player in city" then
            str = "도시에서 BGM 플레이어 항상 이동"
        elseif str == "Notify others of vakarine equipment in raid" then
            str = "레이드에서 바카리네 장비를 착용시 다른 플레이어에게 알립니다"
        elseif str == "Receive weekly boss reward automatically" then ---- Hide Ragana in city
            str = " 주간 보스 레이드 보상을 자동으로 수령"
        elseif str == "Receive Velnice dungeon reward automatically" then -- 
            str = "벨니체 던전 보상 자동 받기"
        elseif str == "Hide the potion frame of the cupole.Memorizes frame position even when OFF" then
            str = "큐폴의 포션 프레임을 숨기고, OFF 상태에서도 프레임 위치를 기억합니다."
        elseif str == "Hide Ragana in city" then
            str = "도시에 있는 라가나를 숨깁니다"
        elseif str == "Equip Refining, Automate weapon/armor enhancement" then
            str = "장비 연성, 무기 방어구 스테이터스 부여 자동화"
        elseif str == "Search the status of icor in the inventory" then
            str = "인벤토리에서 'icor' 상태 검색하기"
        elseif str == "Remember the previous level of the Velnice dungeon" then
            str = "베르니케 던전의 이전 계층을 기억합니다"
        elseif str == "Eliminate around separate buff frame" then
            str = "분리형 버프 프레임 주변을 없앱니다"
        elseif str == "Group chats can be selected from chat frame" then -- Group chat selection can be selected from chat frame
            str = "채팅 프레임에서 그룹 채팅을 선택할 수 있습니다"
        elseif str == "Add member info to various rightclick menu" then
            str = "다양한 우클릭 메뉴에 회원 정보를 추가합니다"
        elseif str == "Announcing the arrival of Baubas" then -- Announcing the arrival of Baubas
            str = "바우버스 등장 소식" -- "Add member info to various rightclick menu"
        elseif str == "Notification switch to guild chat" then ---- "Death of a PT member is indicated in Nicochat PTメンバーの死亡をニコチャットで表示 PT 멤버의 사망을 니코챗으로 표시하기"
            str = "길드 채팅으로 알림 전환"
        elseif str == "Death of a PT member is indicated in Nicochat" then
            str = "PT 멤버의 사망을 니코챗으로 표시하기"
        elseif str == "Check to enable" then
            str = "체크 시 활성화"
        elseif str == "※Character change is required to enable or disable some functions" then
            str = "※일부 기능을 활성화하거나 비활성화하려면 캐릭터 변경이 필요합니다"
        end
    end
    return str
end

function MINI_ADDONS_subframe_open(frame, ctrl, str)
    local sub_frame = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "sub_frame", 0, 0, 0, 0)
    AUTO_CAST(sub_frame)
    sub_frame:SetSkinName("test_frame_low")
    sub_frame:SetLayerLevel(94)
    sub_frame:EnableHittestFrame(1)
    sub_frame:ShowTitleBar(0)
    sub_frame:RemoveAllChild()

    local title = sub_frame:CreateOrGetControl("richtext", "title", 30, 10)
    AUTO_CAST(title)
    local str = string.gsub(str, "{ol}", "")
    title:SetText("{@st66b18}" .. str)

    local gbox = sub_frame:CreateOrGetControl("groupbox", "gbox", 10, 30, 0, 0)
    AUTO_CAST(gbox)
    gbox:SetSkinName("bg")

    local close = sub_frame:CreateOrGetControl("button", "close", 0, 0, 30, 30)
    AUTO_CAST(close)
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetSkinName("None")
    close:SetText("{img testclose_button 30 30}")
    close:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_subframe_close")

    local ctrl_name = ctrl:GetName()
    local y = 10
    local x = 0
    if ctrl_name == "chats" then

        local settings = {{
            name = "chat_system",
            check = g.settings.chat_system,
            text = g.lang == "Japanese" and
                "{ol}パーフェクトとブラックマーケットのお知らせをチャットに表示しません" or
                g.lang == "kr" and
                "{ol}완벽함 메시지 및 블랙 마켓 공지를 채팅에 표시 하지 않습니다" or
                "{ol}Perfect and Black Market notices not displayed in chat"
        }, {
            name = "group_chat",
            check = g.settings.group_chat,
            text = g.lang == "Japanese" and
                "{ol}グループチャットをチャットフレームから選択出来ます" or g.lang == "kr" and
                "{ol}채팅 프레임에서 그룹 채팅을 선택할 수 있습니다" or
                "{ol}Group chats can be selected from chat frame"
        }, {
            name = "baubas_call",
            check = g.settings.baubas_call.use,
            text = g.lang == "Japanese" and "{ol}バウバス登場をお知らせ" or g.lang == "kr" and
                "{ol}바우버스 등장 소식" or "{ol}Announcing the arrival of Baubas"
        }, {
            name = "chat_recv",
            check = g.settings.chat_recv,
            text = g.lang == "Japanese" and "{ol}PTメンバーの死亡をニコチャットで表示" or g.lang ==
                "kr" and "{ol}PT 멤버의 사망을 니코챗으로 표시하기" or
                "{ol}Death of a PT member is indicated in Nicochat"
        }}

        for i, setting in ipairs(settings) do
            local checkbox = gbox:CreateOrGetControl('checkbox', setting.name, 10, y, 25, 25)
            AUTO_CAST(checkbox)
            checkbox:SetCheck(setting.check)
            checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
            checkbox:SetText(setting.text)
            local temp_text = g.lang == "Japanese" and "{ol}チェックすると有効化" or g.lang == "kr" and
                                  "{ol}체크 시 활성화" or "{ol}Check to enable"
            checkbox:SetTextTooltip(temp_text)
            local text_width = checkbox:GetWidth()
            if x < text_width then
                x = text_width
            end

            if setting.name == "baubas_call" then
                local baubas_call_btn = gbox:CreateOrGetControl('button', 'baubas_call_btn', text_width + 15, y - 5, 50,
                                                                30)
                AUTO_CAST(baubas_call_btn)
                if g.settings.baubas_call.guild_notice == 0 or not g.settings.baubas_call.guild_notice then
                    baubas_call_btn:SetText("{ol}{#FFFFFF}OFF")
                    baubas_call_btn:SetSkinName("test_gray_button")
                    g.settings.baubas_call.guild_notice = 0
                    MINI_ADDONS_SAVE_SETTINGS()
                else
                    baubas_call_btn:SetText("{ol}{#FFFFFF}ON")
                    baubas_call_btn:SetSkinName("test_red_button")

                end
                local temp_text = g.lang == "Japanese" and "{ol}ギルドチャットへのお知らせ切替え" or
                                      g.lang == "kr" and "{ol}길드 채팅으로 알림 전환" or
                                      "{ol}Notification switch to guild chat"
                baubas_call_btn:SetTextTooltip(temp_text)
                baubas_call_btn:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_baubas_call_switch")
                local btn_width = baubas_call_btn:GetWidth()
                if x < text_width + 15 + btn_width then
                    x = text_width + 15 + btn_width
                end
            end
            y = y + 30
        end
    elseif ctrl_name == "chars" then
        local settings = {{
            name = "my_effect",
            check = g.settings.my_effect or 0,
            text = g.lang == "Japanese" and "{ol}自分のエフェクトを調整します(1~100)" or g.lang == "kr" and
                "{ol}나만의 효과를 조정합니다(1~100)" or "{ol}Adjust my effects(1~100)"
        }, {
            name = "other_effect",
            check = g.settings.other_effect,
            text = g.lang == "Japanese" and "{ol}他人のエフェクトを調整します(1~100)" or g.lang == "kr" and
                "{ol}다른 사람의 효과를 조정합니다(1~100)" or "{ol}Adjust other people's effects(1~100)"
        }, {
            name = "boss_effect",
            check = g.settings.boss_effect or 0,
            text = g.lang == "Japanese" and "{ol}ボスのエフェクトを調整します(1~100)" or g.lang == "kr" and
                "{ol}보스 효과를 조정합니다(1~100)" or "{ol}Adjust boss effects(1~100)"
        }, {
            name = "auto_cast",
            check = g.settings.auto_cast,
            text = g.lang == "Japanese" and "{ol}オートキャスティングをキャラ毎に設定" or g.lang ==
                "kr" and "{ol}캐릭터별로 자동 시전 설정" or "{ol}Set auto casting per character"
        }, {
            name = "pc_name",
            check = g.settings.pc_name,
            text = g.lang == "Japanese" and "{ol}左上の名前をキャラクター名に変更します" or g.lang ==
                "kr" and "{ol}좌측 상단의 이름을 캐릭터 이름으로 변경합니다" or
                "{ol}Change the name in the top left to your character's name"
        }, {
            name = "relic_gauge",
            check = g.settings.relic_gauge,
            text = g.lang == "Japanese" and "{ol}キャラクターゲージにレリックを追加します" or g.lang ==
                "kr" and "{ol}캐릭터 게이지에 유물을 추가합니다" or
                "{ol}Add a Relic to the character's gauge"
        }}
        for i, setting in ipairs(settings) do
            local checkbox = gbox:CreateOrGetControl('checkbox', setting.name, 10, y, 25, 25)
            AUTO_CAST(checkbox)
            checkbox:SetCheck(setting.check)
            checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
            checkbox:SetText(setting.text)
            local temp_text = g.lang == "Japanese" and "{ol}チェックすると有効化" or g.lang == "kr" and
                                  "{ol}체크 시 활성화" or "{ol}Check to enable"
            checkbox:SetTextTooltip(temp_text)
            local text_width = checkbox:GetWidth()
            if x < text_width then
                x = text_width
            end
            if setting.name == "other_effect" then
                local other_effect_edit = gbox:CreateOrGetControl('edit', 'other_effect_edit', text_width + 15, y, 60,
                                                                  25)
                AUTO_CAST(other_effect_edit)
                other_effect_edit:SetEventScript(ui.ENTERKEY, "MINI_ADDONS_OTHER_EFFECT_EDIT")
                other_effect_edit:SetTextTooltip("{ol}1~100")
                other_effect_edit:SetFontName("white_16_ol")
                other_effect_edit:SetTextAlign("center", "center")
                local other_effect = config.GetOtherEffectTransparency()
                local num = math.floor(other_effect * 0.392156862745 + 0.5)
                other_effect_edit:SetText("{ol}" .. num)
                if x < text_width + 15 + 60 then
                    x = text_width + 15 + 60
                end
            elseif setting.name == "my_effect" then

                local my_effect_edit = gbox:CreateOrGetControl('edit', 'my_effect_edit', text_width + 15, y, 60, 25)
                AUTO_CAST(my_effect_edit)
                my_effect_edit:SetEventScript(ui.ENTERKEY, "MINI_ADDONS_MY_EFFECT_EDIT")
                my_effect_edit:SetTextTooltip("{ol}1~100")
                my_effect_edit:SetFontName("white_16_ol")
                my_effect_edit:SetTextAlign("center", "center")

                local my_effect = config.GetMyEffectTransparency()
                local num = math.floor(my_effect * 0.392156862745 + 0.5)
                my_effect_edit:SetText("{ol}" .. num)
                if x < text_width + 15 + 60 then
                    x = text_width + 15 + 60
                end
            elseif setting.name == "boss_effect" then

                local boss_effect_edit = gbox:CreateOrGetControl('edit', 'boss_effect_edit', text_width + 15, y, 60, 25)
                AUTO_CAST(boss_effect_edit)
                boss_effect_edit:SetEventScript(ui.ENTERKEY, "MINI_ADDONS_BOSS_EFFECT_EDIT")
                boss_effect_edit:SetTextTooltip("{ol}1~100")
                boss_effect_edit:SetFontName("white_16_ol")
                boss_effect_edit:SetTextAlign("center", "center")

                local boss_effect = config.GetBossMonsterEffectTransparency()
                local num = math.floor(boss_effect * 0.392156862745 + 0.5)
                boss_effect_edit:SetText("{ol}" .. num)
                if x < text_width + 15 + 60 then
                    x = text_width + 15 + 60
                end
            end
            y = y + 30
        end

    elseif ctrl_name == "frames" then
        local settings = {{
            name = "raid_record",
            check = g.settings.raid_record,
            text = g.lang == "Japanese" and "{ol}レイドレコードを移動可能にしてサイズを変更" or
                g.lang == "kr" and
                "{ol}레이드 기록의 이동이 가능하고, 크기 조절을 할 수 있습니다" or
                "{ol}Raid records movable and resizable"
        }, {
            name = "mini_btn",
            check = g.settings.mini_btn,
            text = g.lang == "Japanese" and "{ol}レイド時右上のミニボタン非表示" or g.lang == "kr" and
                "{ol}레이드 중 오른쪽 상단의 미니 버튼을 숨깁니다" or
                "{ol}Hide minibutton in upper right corner during raid"
        }, {
            name = "market_display",
            check = g.settings.market_display,
            text = g.lang == "Japanese" and "{ol}街では、右上の商店一覧を常に表示します" or g.lang ==
                "kr" and "{ol}도시 이동 시 상점 목록을 항상 열어둡니다" or
                "{ol}Keep shop list open when moving to city"
        }, {
            name = "restart_move",
            check = g.settings.restart_move,
            text = g.lang == "Japanese" and
                "{ol}リスタート時の選択肢フレームを動かせる様にします" or g.lang == "kr" and
                "{ol}재시작 시 선택 프레임을 이동할 수 있게 합니다" or
                "{ol}Allow moving selection frame on restart"
        }, {
            name = "automatch_layer",
            check = g.settings.automatch_layer,
            text = g.lang == "Japanese" and
                "{ol}オートマッチ時のフレームのレイヤーレベルを下げます" or g.lang == "kr" and
                "{ol}자동 매칭 시 프레임 레이어 레벨을 낮춥니다" or
                "{ol}Lower frame layer level during auto match"
        }, {
            name = "quest_hide",
            check = g.settings.quest_hide,
            text = g.lang == "Japanese" and "{ol}クエストリストを非表示にします" or g.lang == "kr" and
                "{ol}퀘스트 목록을 숨깁니다" or "{ol}Hide the quest list"
        }, {
            name = "channel_info",
            check = g.settings.channel_info,
            text = g.lang == "Japanese" and "{ol}チャンネル切替フレームを表示します" or g.lang == "kr" and
                "{ol}채널 전환 프레임을 표시합니다" or "{ol}Displays the channel switching frame"
        }, {
            name = "auto_gacha",
            check = g.settings.auto_gacha,
            text = g.lang == "Japanese" and "{ol}女神の加護ガチャフレーム表示を自動化します" or
                g.lang == "kr" and "{ol}여신의 가호 가챠 프레임 표시를 자동화합니다" or
                "{ol}Automate the display of the Goddess Protection gacha frame"
        }, {
            name = "party_info",
            check = g.settings.party_info,
            text = g.lang == "Japanese" and
                "{ol}パーティーフレームの表示切替。右クリックで小さくします。マウスモード用" or
                g.lang == "kr" and
                "{ol}파티 정보 프레임 표시 전환. 마우스 모드용. 오른쪽 클릭으로 작게 합니다" or
                "{ol}Toggle party info frame. For mouse mode.Party info rightclick"
        }, {
            name = "cupole_portion",
            check = g.settings.cupole_portion.use,
            text = g.lang == "Japanese" and
                "{ol}クポルのポーションフレームを非表示に。OFFでもフレームの位置記憶" or
                g.lang == "kr" and
                "{ol}큐폴의 포션 프레임을 숨기고, OFF 상태에서도 프레임 위치를 기억합니다" or
                "{ol}Hide the potion frame of the cupole.Memorizes frame position even when OFF"
        }, {
            name = "separated_buff", -- separated_buff
            check = g.settings.separated_buff,
            text = g.lang == "Japanese" and "{ol}セパレートバフフレームの周りを綺麗にします" or
                g.lang == "kr" and "{ol}분리형 버프 프레임 주변을 없앱니다" or
                "{ol}Eliminate around separate buff frame"
        }}
        for i, setting in ipairs(settings) do
            local checkbox = gbox:CreateOrGetControl('checkbox', setting.name, 10, y, 25, 25)
            AUTO_CAST(checkbox)
            checkbox:SetCheck(setting.check)
            checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
            checkbox:SetText(setting.text)
            local temp_text = g.lang == "Japanese" and "{ol}チェックすると有効化" or g.lang == "kr" and
                                  "{ol}체크 시 활성화" or "{ol}Check to enable"
            checkbox:SetTextTooltip(temp_text)
            local text_width = checkbox:GetWidth()
            if x < text_width then
                x = text_width
            end
            if setting.name == "auto_gacha" then
                local auto_gacha_btn = gbox:CreateOrGetControl('button', 'auto_gacha_btn', text_width + 15, y - 5, 50,
                                                               30)
                AUTO_CAST(auto_gacha_btn)
                if g.settings.auto_gacha_start == 0 or g.settings.auto_gacha_start == nil then
                    auto_gacha_btn:SetText("{ol}{#FFFFFF}OFF")
                    auto_gacha_btn:SetSkinName("test_gray_button")
                    g.settings.auto_gacha_start = 0
                    MINI_ADDONS_SAVE_SETTINGS()
                else
                    auto_gacha_btn:SetText("{ol}{#FFFFFF}ON")
                    auto_gacha_btn:SetSkinName("test_red_button")
                end
                local temp_text = g.lang == "Japanese" and
                                      "{ol}ONにすると自動でガチャスタートします。切替にCC必要です" or
                                      g.lang == "kr" and
                                      "{ol}ON으로 설정하면 자동으로 가챠가 시작됩니다. 전환 시 CC 필요합니다" or
                                      "{ol}When turned on, the gacha starts automatically.CC required for switching"
                auto_gacha_btn:SetTextTooltip(temp_text)
                auto_gacha_btn:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_GP_AUTOSTART_OPERATION")
                if x < text_width + 15 + 50 then
                    x = text_width + 15 + 50
                end
            end
            y = y + 30
        end
    elseif ctrl_name == "autos" then
        local settings = {{
            name = "coin_use",
            check = g.settings.coin_use,
            text = g.lang == "Japanese" and "{ol}各種コインを取得時に自動で使用します" or g.lang ==
                "kr" and "{ol}각종 코인 획득 시 자동 사용" or
                "{ol}Automatically use various coins upon acquisition"
        }, {
            name = "skill_enchant",
            check = g.settings.skill_enchant,
            text = g.lang == "Japanese" and "{ol}スキル錬成のアイテムを自動でセットします" or g.lang ==
                "kr" and "{ol}스킬 연성을 위한 아이템을 자동으로 설정합니다" or
                "{ol}Automatically sets items for skill refining"
        }, {
            name = "weekly_boss_reward",
            check = g.settings.weekly_boss_reward,
            text = g.lang == "Japanese" and "{ol}週間ボスレイド報酬を自動で受け取り" or g.lang == "kr" and
                "{ol}주간 보스 레이드 보상을 자동으로 수령" or
                "{ol}Receive weekly boss reward automatically"
        }, {
            name = "solodun_reward",
            check = g.settings.solodun_reward,
            text = g.lang == "Japanese" and "{ol}ヴェルニケダンジョン報酬を自動で受け取り" or g.lang ==
                "kr" and "{ol}벨니체 던전 보상 자동 받기" or
                "{ol}Receive Velnice dungeon reward automatically"
        }, {
            name = "status_upgrade",
            check = g.settings.status_upgrade,
            text = g.lang == "Japanese" and "{ol}装備錬成、武器防具ステータス付与を自動化" or g.lang ==
                "kr" and "{ol}장비 연성, 무기 방어구 스테이터스 부여 자동화" or
                "{ol}Equip Refining, Automate weapon/armor enhancement"
        }}

        for i, setting in ipairs(settings) do
            local checkbox = gbox:CreateOrGetControl('checkbox', setting.name, 10, y, 25, 25)
            AUTO_CAST(checkbox)
            checkbox:SetCheck(setting.check)
            checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
            checkbox:SetText(setting.text)
            local temp_text = g.lang == "Japanese" and "{ol}チェックすると有効化" or g.lang == "kr" and
                                  "{ol}체크 시 활성화" or "{ol}Check to enable"
            checkbox:SetTextTooltip(temp_text)
            local text_width = checkbox:GetWidth()
            if x < text_width then
                x = text_width
            end
            if setting.name == "weekly_boss_reward" then
                if not g.settings.reward_switch then
                    g.settings.reward_switch = 1
                    MINI_ADDONS_SAVE_SETTINGS()
                end
                local switch = gbox:CreateOrGetControl('button', 'switch', text_width + 15, y, 80, 25)
                AUTO_CAST(switch)
                if g.settings.reward_switch == 1 then
                    switch:SetText(g.lang == "Japanese" and "{ol}先週分" or g.lang == "kr" and "{ol}지난 주분" or
                                       "{ol}last week")
                else
                    switch:SetText(g.lang == "Japanese" and "{ol}今週分" or g.lang == "kr" and "{ol}이번 주분" or
                                       "{ol}this week")
                end
                switch:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_WEEKLY_BOSS_REWARD_SWITCH")

                local temp_text =
                    g.lang == "Japanese" and "{ol}ダメージ報酬受取り週切替" or g.lang == "kr" and
                        "{ol}데미지 보상 수령 주차 변경" or "{ol}Switch Damage Reward Receipt Week"
                switch:SetTextTooltip(temp_text)

                if x < text_width + 15 + 80 then
                    x = text_width + 15 + 80
                end
            end
            y = y + 30
        end
    end

    sub_frame:Resize(x + 65, y + 45)

    gbox:Resize(sub_frame:GetWidth() - 20, sub_frame:GetHeight() - 40)
    local screen_width = ui.GetClientInitialWidth()
    local screen_height = ui.GetClientInitialHeight() -- 画面の高さ
    local width = sub_frame:GetWidth()
    local frame_y = frame:GetY()

    sub_frame:SetPos((screen_width - width) / 2 + 250, screen_height / 2 - 200)
    sub_frame:ShowWindow(1)

end

function MINI_ADDONS_SETTING_FRAME_INIT(frame, ctrl, str, num)

    local frame = ui.GetFrame("mini_addons")
    if frame:GetWidth() > 100 and str == "false" then
        frame:Resize(0, 0)
        frame:ShowWindow(0)
        return
    end

    frame:SetSkinName("test_frame_low")
    frame:SetLayerLevel(93)
    frame:EnableHittestFrame(1)
    frame:ShowTitleBar(0)
    frame:RemoveAllChild()
    frame:SetEventScript(ui.RBUTTONUP, "MINI_ADDONS_FRAME_CLOSE")

    local title = frame:CreateOrGetControl("richtext", "title", 30, 10)
    AUTO_CAST(title)
    title:SetText("{@st66b18}Mini Addons")

    local gbox = frame:CreateOrGetControl("groupbox", "gbox", 10, 30, 0, 0)
    AUTO_CAST(gbox)
    -- gbox:SetSkinName("test_frame_midle_light")
    gbox:SetSkinName("bg")

    local close = frame:CreateOrGetControl("button", "close", 615, 5, 30, 30)
    AUTO_CAST(close)
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetSkinName("None")
    close:SetText("{img testclose_button 30 30}")
    close:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_FRAME_CLOSE")
    -- !
    local settings = {{
        name = "under_staff",
        check = g.settings.under_staff,
        text = "{ol}" .. MINI_ADDONS_LANG("Skip confirmation for admission of 4 or less people")
    }, --[[{
        name = "raid_record",
        check = g.settings.raid_record,
        text = "{ol}" .. MINI_ADDONS_LANG("Raid records movable and resizable")
    },]] {
        name = "party_buff",
        check = g.settings.party_buff,
        text = "{ol}" .. MINI_ADDONS_LANG("Hide buffs for party members")
    }, --[[{
        name = "chat_system",
        check = g.settings.chat_system,
        text = "{ol}" .. MINI_ADDONS_LANG("Perfect and Black Market notices not displayed in chat")
    }]] {
        name = "channel_display",
        check = g.settings.channel_display,
        text = "{ol}" .. MINI_ADDONS_LANG("Fixed channel display misalignment for Japanese ver")
    }, --[[{
        name = "mini_btn",
        check = g.settings.mini_btn,
        text = "{ol}" .. MINI_ADDONS_LANG("Hide minibutton in upper right corner during raid")
    }, {
        name = "market_display",
        check = g.settings.market_display,
        text = "{ol}" .. MINI_ADDONS_LANG("Keep shop list open when moving to town")
    }, {
        name = "restart_move",
        check = g.settings.restart_move,
        text = "{ol}" .. MINI_ADDONS_LANG("Allow moving selection frame on restart")
    },]] {
        name = "dialog_ctrl",
        check = g.settings.dialog_ctrl,
        text = "{ol}" .. MINI_ADDONS_LANG("Controls various dialogs")
    }, --[[ {
        name = "auto_cast",
        check = g.settings.auto_cast,
        text = "{ol}" .. MINI_ADDONS_LANG("Set auto casting per character")
    }, {
        name = "coin_use",
        check = g.settings.coin_use,
        text = "{ol}" .. MINI_ADDONS_LANG("Automatically used when acquiring coin items")
    },]] {
        name = "equip_info",
        check = g.settings.equip_info,
        text = "{ol}" ..
            MINI_ADDONS_LANG("Notification of forgetting to equip ark and emblem upon entry to the hard raid")
    }, --[[{
        name = "automatch_layer",
        check = g.settings.automatch_layer,
        text = "{ol}" .. MINI_ADDONS_LANG("Lower frame layer level during auto match")
    }, {
        name = "quest_hide",
        check = g.settings.quest_hide,
        text = "{ol}" .. MINI_ADDONS_LANG("Hide the quest list")
    }, {
        name = "pc_name",
        check = g.settings.pc_name,
        text = "{ol}" .. MINI_ADDONS_LANG("Change the upper left display to the character's name")
    },]] --[[ {
        name = "channel_info",
        check = g.settings.channel_info,
        text = "{ol}" .. MINI_ADDONS_LANG("Displays the channel switching frame")
    }, {
        name = "my_effect",
        check = g.settings.my_effect or 0,
        text = "{ol}" .. MINI_ADDONS_LANG("Adjust my effects from 1 to 100")
    }, {
        name = "other_effect",
        check = g.settings.other_effect,
        text = "{ol}" .. MINI_ADDONS_LANG("Adjust other people's effects from 1 to 100, recommended 75")
    }, {
        name = "boss_effect",
        check = g.settings.boss_effect or 0,
        text = "{ol}" .. MINI_ADDONS_LANG("Adjust boss effects from 1 to 100")
    },{
        name = "auto_gacha",
        check = g.settings.auto_gacha,
        text = "{ol}" .. MINI_ADDONS_LANG("Automate the display of the Goddess Protection gacha frame")
    }, {
        name = "skill_enchant",
        check = g.settings.skill_enchant,
        text = "{ol}" .. MINI_ADDONS_LANG("Automatically sets items for skill refining")
    },]] --[[{
        name = "relic_gauge",
        check = g.settings.relic_gauge,
        text = "{ol}" .. MINI_ADDONS_LANG("Add a Relic to the character's gauge")
    },  {
        name = "raid_check",
        check = g.settings.raid_check,
        text = "{ol}" ..
            MINI_ADDONS_LANG("Prevents character change mistakes during the hard raid on the Dreamy& Abyss")
    }, {
        name = "party_info",
        check = g.settings.party_info,
        text = "{ol}" .. MINI_ADDONS_LANG("Toggle party info frame. For mouse mode.Party info rightclick")
    },]] {
        name = "coin_count",
        check = g.settings.coin_count,
        text = "{ol}" .. MINI_ADDONS_LANG("The maximum coin limit for each store is raised to 99999")
    }, {
        name = "bgm",
        check = g.settings.bgm,
        text = "{ol}" .. MINI_ADDONS_LANG("Always move the BGM player in city")
    }, {
        name = "vakarine",
        check = g.settings.vakarine,
        text = "{ol}" .. MINI_ADDONS_LANG("Notify others of vakarine equipment in raid")
    }, --[[{
        name = "weekly_boss_reward",
        check = g.settings.weekly_boss_reward,
        text = "{ol}" .. MINI_ADDONS_LANG("Receive weekly boss reward automatically") -- solodun_reward
    }, {
        name = "solodun_reward",
        check = g.settings.solodun_reward,
        text = "{ol}" .. MINI_ADDONS_LANG("Receive Velnice dungeon reward automatically") -- solodun_reward
    },]] --[[ {
        name = "cupole_portion",
        check = g.settings.cupole_portion.use,
        text = "{ol}" ..
            MINI_ADDONS_LANG("Hide the potion frame of the cupole.Memorizes frame position even when OFF")

    },]] {
        name = "goodbye_ragana",
        check = g.settings.goodbye_ragana,
        text = "{ol}" .. MINI_ADDONS_LANG("Hide Ragana in city")

    }, --[[ {
        name = "status_upgrade",
        check = g.settings.status_upgrade,
        text = "{ol}" .. MINI_ADDONS_LANG("Equip Refining, Automate weapon/armor enhancement")

    },]] {
        name = "icor_status_search",
        check = g.settings.icor_status_search,
        text = "{ol}" .. MINI_ADDONS_LANG("Search the status of icor in the inventory")

    }, {
        name = "velnice", -- separated_buff
        check = g.settings.velnice.use,
        text = "{ol}" .. MINI_ADDONS_LANG("Remember the previous level of the Velnice dungeon")

    }, --[[{
        name = "separated_buff", -- separated_buff
        check = g.settings.separated_buff,
        text = "{ol}" .. MINI_ADDONS_LANG("Eliminate around separate buff frame")

    },]] --[[{
        name = "group_chat", -- separated_buff
        check = g.settings.group_chat,
        text = "{ol}" .. MINI_ADDONS_LANG("Group chats can be selected from chat frame")

    },]] {
        name = "memberinfo",
        check = g.settings.memberinfo,
        text = "{ol}" .. MINI_ADDONS_LANG("Add member info to various rightclick menu")

    } --[[{
        name = "baubas_call",
        check = g.settings.baubas_call.use,
        text = "{ol}" .. MINI_ADDONS_LANG("Announcing the arrival of Baubas")

    }, {
        name = "chat_recv",
        check = g.settings.chat_recv,
        text = "{ol}" .. MINI_ADDONS_LANG("Death of a PT member is indicated in Nicochat")

    }]] }

    local y = 130
    local x = 0
    for i, setting in ipairs(settings) do

        local checkbox = gbox:CreateOrGetControl('checkbox', setting.name, 10, y, 25, 25)
        AUTO_CAST(checkbox)
        checkbox:SetCheck(setting.check)
        checkbox:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
        checkbox:SetText(setting.text)
        checkbox:SetTextTooltip(MINI_ADDONS_LANG("Check to enable"))
        local text_width = checkbox:GetWidth()
        if x < text_width then
            x = text_width
        end

        if setting.name == "party_buff" then
            local party_buff_btn = gbox:CreateOrGetControl("button", "party_buff_btn", text_width + 15, y - 5, 50, 30)
            AUTO_CAST(party_buff_btn)
            party_buff_btn:SetText("{ol}{#FFFFFF}bufflist")
            party_buff_btn:SetTextTooltip(MINI_ADDONS_LANG("You can choose which buffs to display"))
            party_buff_btn:SetSkinName("test_red_button")
            party_buff_btn:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_BUFFLIST_FRAME_INIT")

            local pt_buff = gbox:CreateOrGetControl('checkbox', "pt_buff", text_width + 15 + 70, y - 5, 25, 25)
            AUTO_CAST(pt_buff)

            pt_buff:SetCheck(g.settings.pt_buff or 0)
            pt_buff:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_ISCHECK")
            local text = g.lang == "Japanese" and "チェックすると初見バフ非表示" or g.lang == "kr" and
                             "체크하면 첫눈에 반한 버프 숨기기" or "First-time buffs hidden when checked"
            pt_buff:SetTextTooltip(text)

            if x < text_width + 50 + 25 then
                x = text_width + 50 + 25
            end

            --[[elseif setting.name == "baubas_call" then
            local baubas_call_btn = gbox:CreateOrGetControl('button', 'baubas_call_btn', textWidth + 15, x - 5, 50, 30)
            AUTO_CAST(baubas_call_btn)
            if g.settings.baubas_call.guild_notice == 0 or not g.settings.baubas_call.guild_notice then
                baubas_call_btn:SetText("{ol}{#FFFFFF}OFF")
                baubas_call_btn:SetSkinName("test_gray_button")
                g.settings.baubas_call.guild_notice = 0
                MINI_ADDONS_SAVE_SETTINGS()
            else
                baubas_call_btn:SetText("{ol}{#FFFFFF}ON")
                baubas_call_btn:SetSkinName("test_red_button")

            end
            baubas_call_btn:SetTextTooltip(MINI_ADDONS_LANG("Notification switch to guild chat"))
            baubas_call_btn:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_baubas_call_switch")
        elseif setting.name == "auto_gacha" then
            local auto_gacha_btn = gbox:CreateOrGetControl('button', 'auto_gacha_btn', textWidth + 15, x - 5, 50, 30)
            AUTO_CAST(auto_gacha_btn)
            if g.settings.auto_gacha_start == 0 or g.settings.auto_gacha_start == nil then
                auto_gacha_btn:SetText("{ol}{#FFFFFF}OFF")
                auto_gacha_btn:SetSkinName("test_gray_button")
                g.settings.auto_gacha_start = 0
                MINI_ADDONS_SAVE_SETTINGS()
            else
                auto_gacha_btn:SetText("{ol}{#FFFFFF}ON")
                auto_gacha_btn:SetSkinName("test_red_button")

            end
            auto_gacha_btn:SetTextTooltip(MINI_ADDONS_LANG(
                "When turned on, the gacha starts automatically.CC required for switching"))
            auto_gacha_btn:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_GP_AUTOSTART_OPERATION")
        elseif setting.name == "other_effect" then
            local other_effect_edit =
                gbox:CreateOrGetControl('edit', 'other_effect_edit', textWidth + 15, x - 5, 60, 25)
            AUTO_CAST(other_effect_edit)
            other_effect_edit:SetEventScript(ui.ENTERKEY, "MINI_ADDONS_OTHER_EFFECT_EDIT")
            other_effect_edit:SetTextTooltip("{ol}1~100")
            other_effect_edit:SetFontName("white_16_ol")
            other_effect_edit:SetTextAlign("center", "center")
            local other_effect = config.GetOtherEffectTransparency()
            local num = math.floor(other_effect * 0.392156862745 + 0.5)
            other_effect_edit:SetText("{ol}" .. num)
        elseif setting.name == "my_effect" then

            local my_effect_edit = gbox:CreateOrGetControl('edit', 'my_effect_edit', textWidth + 15, x - 5, 60, 25)
            AUTO_CAST(my_effect_edit)
            my_effect_edit:SetEventScript(ui.ENTERKEY, "MINI_ADDONS_MY_EFFECT_EDIT")
            my_effect_edit:SetTextTooltip("{ol}1~100")
            my_effect_edit:SetFontName("white_16_ol")
            my_effect_edit:SetTextAlign("center", "center")

            local my_effect = config.GetMyEffectTransparency()
            local num = math.floor(my_effect * 0.392156862745 + 0.5)
            my_effect_edit:SetText("{ol}" .. num)
        elseif setting.name == "boss_effect" then

            local boss_effect_edit = gbox:CreateOrGetControl('edit', 'boss_effect_edit', textWidth + 15, x - 5, 60, 25)
            AUTO_CAST(boss_effect_edit)
            boss_effect_edit:SetEventScript(ui.ENTERKEY, "MINI_ADDONS_BOSS_EFFECT_EDIT")
            boss_effect_edit:SetTextTooltip("{ol}1~100")
            boss_effect_edit:SetFontName("white_16_ol")
            boss_effect_edit:SetTextAlign("center", "center")

            local boss_effect = config.GetBossMonsterEffectTransparency()
            local num = math.floor(boss_effect * 0.392156862745 + 0.5)
            boss_effect_edit:SetText("{ol}" .. num)
        elseif setting.name == "weekly_boss_reward" then
            -- g.lang = "en"
            if not g.settings.reward_switch then
                g.settings.reward_switch = 1
                MINI_ADDONS_SAVE_SETTINGS()
            end
            local switch = gbox:CreateOrGetControl('button', 'switch', textWidth + 15, y, 80, 25)
            AUTO_CAST(switch)
            if g.settings.reward_switch == 1 then
                switch:SetText(g.lang == "Japanese" and "{ol}先週分" or "{ol}last week")
            else
                switch:SetText(g.lang == "Japanese" and "{ol}今週分" or "{ol}this week")
            end
            switch:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_WEEKLY_BOSS_REWARD_SWITCH")
            local switch_width = switch:GetWidth()
            local switch_text = frame:CreateOrGetControl("richtext", "switch_text", textWidth + 15 + switch_width,
                x + 2, 80, 25)
            AUTO_CAST(switch_text)
            switch_text:SetText(g.lang == "Japanese" and "{ol}ダメージ報酬切替" or "{ol}Damage Reward Switch")
            -- g.lang = "Japanese"]]
        end
        y = y + 30

    end

    local description = gbox:CreateOrGetControl("richtext", "description", 10, y + 5)
    local temp_text = g.lang == "Japanese" and
                          "{ol}{#FFA500}※一部の機能の有効化、無効化の切替はキャラクターチェンジが必要です" or
                          g.lang == "kr" and
                          "{ol}{#FFA500}※일부 기능을 활성화하거나 비활성화하려면 캐릭터 변경이 필요합니다" or
                          "{ol}{#FFA500}※Character change is required to enable or disable some functions"
    description:SetText(temp_text)
    local text_width = description:GetWidth()
    if x < text_width then
        x = text_width
    end
    y = y + 30

    frame:Resize(x + 65, y + 45)
    gbox:Resize(frame:GetWidth() - 20, frame:GetHeight() - 40)
    local screenWidth = ui.GetClientInitialWidth() -- 画面の幅
    local screenHeight = ui.GetClientInitialHeight() -- 画面の高さ
    local frameWidth = frame:GetWidth() -- フレームの幅
    local frameHeight = frame:GetHeight() -- フレームの高さ

    -- frame:SetPos((screenWidth - frameWidth) / 2, (screenHeight - frameHeight) / 2)
    frame:SetPos((screenWidth - frameWidth) / 2, (screenHeight - frameHeight) / 2)

    local chats = gbox:CreateOrGetControl("button", "chats", 40, 10, 0, 25)
    AUTO_CAST(chats)
    chats:SetSkinName("None")
    local temp_text = g.lang == "Japanese" and "{ol}チャット関連" or g.lang == "kr" and "{ol}채팅 관련" or
                          "{ol}Chat-related"
    chats:SetText(temp_text)
    chats:SetTextAlign('left', 'center')
    chats:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_subframe_open")
    chats:SetEventScriptArgString(ui.LBUTTONUP, temp_text)
    chats:SetEventScript(ui.RBUTTONUP, "MINI_ADDONS_subframe_close")

    local chars = gbox:CreateOrGetControl("button", "chars", 40, 40, 0, 25)
    AUTO_CAST(chars)
    chars:SetSkinName("None")
    local temp_text = g.lang == "Japanese" and "{ol}キャラクター関連" or g.lang == "kr" and
                          "{ol}캐릭터 관련" or "{ol}Character-related"
    chars:SetText(temp_text)
    chars:SetTextAlign('left', 'center')
    chars:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_subframe_open")
    chars:SetEventScriptArgString(ui.LBUTTONUP, temp_text)
    chars:SetEventScript(ui.RBUTTONUP, "MINI_ADDONS_subframe_close")

    local frames = gbox:CreateOrGetControl("button", "frames", 40, 70, 0, 25)
    AUTO_CAST(frames)
    frames:SetSkinName("None")
    local temp_text = g.lang == "Japanese" and "{ol}フレーム関連" or g.lang == "kr" and "{ol}프레임 관련" or
                          "{ol}Frame-related"
    frames:SetText(temp_text)
    frames:SetTextAlign('left', 'center')
    frames:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_subframe_open")
    frames:SetEventScriptArgString(ui.LBUTTONUP, temp_text)
    frames:SetEventScript(ui.RBUTTONUP, "MINI_ADDONS_subframe_close")

    local autos = gbox:CreateOrGetControl("button", "autos", 40, 100, 0, 25)
    AUTO_CAST(autos)
    autos:SetSkinName("None")
    local temp_text =
        g.lang == "Japanese" and "{ol}自動処理関連" or g.lang == "kr" and "{ol}자동 처리 관련" or
            "{ol}Automation-related"
    autos:SetText(temp_text)
    autos:SetTextAlign('left', 'center')
    autos:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_subframe_open")
    autos:SetEventScriptArgString(ui.LBUTTONUP, temp_text)
    autos:SetEventScript(ui.RBUTTONUP, "MINI_ADDONS_subframe_close")

    frame:ShowWindow(1)
end]==] --[==[function MINI_ADDONS_CHAT_GROUPLIST_OPTION_OK(frame)

    local frame = ui.GetFrame("chat_grouplist_option")
    local roomid = frame:GetUserValue("ROOMID")

    local selectedColor = frame:GetUserValue("SelectedColor")
    local info = session.chat.GetByStringID(roomid)

    if info == nil then
        frame:ShowWindow(0)
        return
    end

    if info:GetRoomType() == 3 then

        local titleedit = GET_CHILD_RECURSIVELY(frame, "groupname_edit")
        local newtitle = titleedit:GetText()

        g.settings.group_name[tostring(roomid)] = newtitle
        MINI_ADDONS_SAVE_SETTINGS()

        local chatframe = ui.GetFrame("chat")
        -- local chat_type
        if chatframe ~= nil then

            ui.SetChatType(5)
            MINI_ADDONS_SEND_POPUP_FRAME_CHAT(_, _, roomid, 1)

            local frame = ui.GetFrame('chat_grouplist')
            local gbox = GET_CHILD_RECURSIVELY(frame, "chatlist_group")

            local eachcset = GET_CHILD_RECURSIVELY(gbox, 'btn_' .. roomid)
            local title = g.settings.group_name[roomid]
            local titletext = GET_CHILD(eachcset, "title")

            AUTO_CAST(titletext)
            local persons = string.match(titletext:GetText(), "%[[^%]]+%]")
            titletext:SetText(title .. persons)
            frame:ShowWindow(0)
        end

    end

end

function MINI_ADDONS_CHAT_SET_TO_TITLENAME(targetName, roomid)

    local frame = ui.GetFrame('chat')
    AUTO_CAST(frame)
    local chatEditCtrl = frame:GetChild('mainchat')
    AUTO_CAST(chatEditCtrl)
    local titleCtrl = GET_CHILD(frame, 'edit_to_bg')
    AUTO_CAST(titleCtrl)
    local editbg = GET_CHILD(frame, 'edit_bg')
    AUTO_CAST(editbg)
    local name = GET_CHILD(titleCtrl, 'title_to')
    AUTO_CAST(name)

    local btn_ChatType = GET_CHILD(frame, 'button_type')

    titleCtrl:SetOffset(btn_ChatType:GetOriginalWidth(), titleCtrl:GetOriginalY())
    local offsetX = btn_ChatType:GetOriginalWidth() -- 시작 offset은 type btn 넓이 다음으로.
    local titleText = ''
    local isVisible = 0

    if targetName ~= "" then

        isVisible = 1
        titleText = targetName
        if titleText == "" or titleText == nil then
            return
        end

    end
    -- 이름을 먼저 설정해줘야 크기와 위치 설정이 이루어진다.

    if titleText ~= '' then
        titleCtrl:Resize(name:GetWidth() + 20, titleCtrl:GetOriginalHeight())

        name:SetText(titleText)
        name:ShowWindow(1)

    else
        titleCtrl:Resize(name:GetWidth(), titleCtrl:GetOriginalHeight())
    end

    if isVisible == 1 then
        titleCtrl:SetVisible(1)
        offsetX = offsetX + titleCtrl:GetWidth()

    else
        titleCtrl:SetVisible(0)
    end

    local width = chatEditCtrl:GetOriginalWidth() - titleCtrl:GetWidth() - btn_ChatType:GetWidth()
    chatEditCtrl:Resize(width, chatEditCtrl:GetOriginalHeight())
    chatEditCtrl:SetOffset(offsetX, chatEditCtrl:GetOriginalY())
    -- print(tostring(targetName) .. ":" .. tostring(titleText))
    frame:Invalidate()
end

function MINI_ADDONS_SEND_POPUP_FRAME_CHAT(frame, ctrl, roomid, num)

    local chatframe = ui.GetFrame('chat')
    local edit = chatframe:GetChild('mainchat')
    AUTO_CAST(edit)
    edit:RunEnterKeyScript()
    ui.ProcessReturnKey()

    local info = session.chat.GetByStringID(roomid)
    if info == nil then
        g.room_id = nil
        chatframe:ShowWindow(0)
        return
    end

    local chat_type = chatframe:GetUserValue("CHAT_TYPE_SELECTED_VALUE")
    -- CHAT_SYSTEM(chat_type)
    ui.SetChatType(5)
    MINI_ADDONS_CHAT_SET_TO_TITLENAME(g.settings.group_name[tostring(roomid)], roomid)
    ui.SetChatType(chat_type - 1)

    for room_id, title in pairs(g.settings.group_name) do

        local info = session.chat.GetByStringID(room_id)

        if info:GetRoomType() == 3 then

            session.chat.SetRoomConfigTitle(room_id, title)

        end
    end

    g.room_id = roomid
    ui.SetGroupChatTargetID(roomid)
    chatframe:ShowWindow(0)

    if num == 1 then
        local frame = ui.GetFrame('chat_grouplist')
        frame:ShowWindow(0)
        chatframe:ShowWindow(1)
    end
end

function MINI_ADDONS_CHAT_CREATE_OR_UPDATE_GROUP_LIST_3SEC(frame, msg, str, num)
    CHAT_GROUPLIST_SELECT_LISTTYPE(3)
end

function MINI_ADDONS_CHAT_GROUPLIST_SELECT_LISTTYPE(my_frame, my_msg)

    local type = g.get_event_args(my_msg)

    if type ~= 3 then
        return
    end

    local frame = ui.GetFrame("chat_grouplist")
    local gbox = GET_CHILD_RECURSIVELY(frame, "chatlist_group")

    local child_count = gbox:GetChildCount()
    local existing_room_ids = {}

    for i = 0, child_count - 1 do
        local child = gbox:GetChildByIndex(i)
        if string.find(child:GetName(), "btn_") then
            local room_id = string.gsub(child:GetName(), "btn_", "")
            local eachcset = GET_CHILD_RECURSIVELY(gbox, 'btn_' .. room_id)

            eachcset:SetEventScript(ui.LBUTTONUP, 'MINI_ADDONS_SEND_POPUP_FRAME_CHAT')
            eachcset:SetEventScriptArgString(ui.LBUTTONUP, room_id)
            eachcset:SetEventScriptArgNumber(ui.LBUTTONUP, 1)

            eachcset:SetEventScript(ui.RBUTTONUP, 'MINI_ADDONS_SEND_POPUP_FRAME_CHAT')
            eachcset:SetEventScriptArgString(ui.RBUTTONUP, room_id)
            eachcset:SetEventScriptArgNumber(ui.RBUTTONUP, 1)

            eachcset:SetTextTooltip(g.lang == "Japanese" and
                                        "{ol}右クリック:メインチャットのグループを切り替えます" or
                                        "{ol}Right click:Switch the main chat group")

            local titletext = GET_CHILD(eachcset, "title")

            local title = string.gsub(titletext:GetText(), "%[%s*[^%]]-%s*%]", "")
            g.settings.group_name[tostring(room_id)] = g.settings.group_name[tostring(room_id)] or title

            existing_room_ids[tostring(room_id)] = true

        end
    end

    function MINI_ADDONS_CHAT_GROUP_CONTEXT(frame, ctrl, str, num)

        local context = ui.CreateContextMenu("select_group", " ", 0, 0, 0, 0)

        for key, value in pairs(g.settings.group_name) do
            ui.AddContextMenuItem(context, value, string.format("MINI_ADDONS_SEND_POPUP_FRAME_CHAT(%s,%s,'%s',%d)",
                                                                "nil", "main_chat", key, 1))
        end
        ui.OpenContextMenu(context)
    end

    if type(g.settings.group_name) == "table" then
        for room_id in pairs(g.settings.group_name) do
            if not existing_room_ids[room_id] then
                g.settings.group_name[room_id] = nil
                g.room_id = nil
            else
                local info = session.chat.GetByStringID(room_id)

                if info:GetRoomType() == 3 then

                    local frame = ui.GetFrame('chat')
                    local titleCtrl = GET_CHILD(frame, 'edit_to_bg')
                    local name = GET_CHILD(titleCtrl, 'title_to')
                    AUTO_CAST(name)
                    name:SetEventScript(ui.LBUTTONUP, "MINI_ADDONS_CHAT_GROUP_CONTEXT")
                    name:SetTextTooltip(g.lang == "Japanese" and "左クリック：グループチャット選択" or
                                            "{ol}Left click:Select group chat")
                    frame:Invalidate()

                    g.temp_id = room_id

                    local eachcset = GET_CHILD_RECURSIVELY(gbox, 'btn_' .. room_id)
                    local title = g.settings.group_name[room_id]
                    local titletext = GET_CHILD(eachcset, "title")

                    AUTO_CAST(titletext)

                    local persons = string.match(titletext:GetText(), "%[[^%]]+%]")
                    titletext:SetText(title .. persons)

                end
            end
        end
        MINI_ADDONS_SAVE_SETTINGS()
        if not g.group_chat then
            MINI_ADDONS_SEND_POPUP_FRAME_CHAT(frame, _, g.room_id or g.temp_id, _)
        end
        g.group_chat = true
    end

end

function MINI_ADDONS_GROUPCHAT_OUT(frame)

    local frame = ui.GetFrame("chat_grouplist_option")
    local roomid = frame:GetUserValue("ROOMID")
    g.settings.group_name[roomid] = nil
    MINI_ADDONS_SAVE_SETTINGS()

    g.room_id = nil
    CHAT_GROUPLIST_SELECT_LISTTYPE(3)
end

function MINI_ADDONS_CREATE_NEW_GROUPCHAT()
    ReserveScript(string.format("CHAT_GROUPLIST_SELECT_LISTTYPE(%d)", 3), 1.0)
end]==] --[[function MINI_ADDONS_ISCHECK(frame, ctrl, argStr, argNum)
    local ischeck = ctrl:IsChecked()
    local ctrlname = ctrl:GetName()
    -- !追加の度に更新
    local setting_names = {
        other_effect = "other_effect",
        my_effect = "my_effect",
        boss_effect = "boss_effect",
        channel_info = "channel_info",
        pc_name = "pc_name",
        quest_hide = "quest_hide",
        automatch_layer = "automatch_layer",
        equip_info = "equip_info",
        under_staff = "under_staff",
        raid_record = "raid_record",
        party_buff = "party_buff",
        chat_system = "chat_system",
        channel_display = "channel_display",
        mini_btn = "mini_btn",
        market_display = "market_display",
        restart_move = "restart_move",
        pet_init = "pet_init",
        dialog_ctrl = "dialog_ctrl",
        auto_cast = "auto_cast",
        coin_use = "coin_use",
        auto_gacha = "auto_gacha",
        skill_enchant = "skill_enchant",
        party_info = "party_info",
        relic_gauge = "relic_gauge",
        raid_check = "raid_check",
        coin_count = "coin_count",
        bgm = "bgm",
        vakarine = "vakarine",
        weekly_boss_reward = "weekly_boss_reward",
        solodun_reward = "solodun_reward",
        cupole_portion = "cupole_portion",
        goodbye_ragana = "goodbye_ragana",
        status_upgrade = "status_upgrade",
        icor_status_search = "icor_status_search",
        velnice = "velnice",
        separated_buff = "separated_buff",
        group_chat = "group_chat",
        memberinfo = "memberinfo",
        baubas_call = "baubas_call",
        pt_buff = "pt_buff",
        chat_recv = "chat_recv"
    }

    for settingName, checkboxName in pairs(setting_names) do
        if ctrlname == checkboxName then
            if checkboxName == "cupole_portion" or checkboxName == "velnice" or checkboxName == "baubas_call" then

                g.settings[settingName].use = ischeck
            else
                g.settings[settingName] = ischeck
            end
            if checkboxName == "bgm" then
                if ischeck == 0 then
                    local max_frame = ui.GetFrame("bgmplayer")
                    local play_btn = GET_CHILD_RECURSIVELY(max_frame, "playStart_btn")
                    BGMPLAYER_PLAY(max_frame, play_btn)
                end
            elseif checkboxName == "quest_hide" then
                if ischeck == 0 then
                    MINI_ADDONS_QUESTINFO_SHOW()
                else
                    MINI_ADDONS_QUESTINFO_HIDE_RESERVE()
                end
            end
            break
        end
    end

    MINI_ADDONS_SAVE_SETTINGS()

end]] 
