-- shared_archeology_simple.lua
-- 간단한 고고학 옵션 시스템 (ClassID + 수치)

-- Arc_Prefix_NT 직렬화 (다중 옵션 지원)
-- 단일 옵션: option_cls_id, value → "{option_cls_id};{value}"
-- 다중 옵션: options_list → "{id1};{val1},{id2};{val2},{id3};{val3}"
-- 예: "1;3" = ClassID 1번 옵션, 수치 3
-- 예: "1;3,5;10,7;15" = 3개 옵션
function SERIALIZE_ARCHEOLOGY_OPTION(option_cls_id_or_list, value)
    -- 단일 옵션 (하위 호환)
    if type(option_cls_id_or_list) == "number" then
        return option_cls_id_or_list .. ";" .. value
    end

    -- 다중 옵션 리스트: { {id1, val1}, {id2, val2}, ... }
    if type(option_cls_id_or_list) == "table" then
        local parts = {}
        for i, opt in ipairs(option_cls_id_or_list) do
            table.insert(parts, opt[1] .. ";" .. opt[2])
        end
        return table.concat(parts, ",")
    end

    return "None"
end

-- Arc_Prefix_NT 역직렬화 (다중 옵션 지원)
-- 반환: { {option_cls_id, value}, {option_cls_id, value}, ... }
function DESERIALIZE_ARCHEOLOGY_OPTION(arc_prefix)
    if not arc_prefix or arc_prefix == "" or arc_prefix == "None" then
        return {}
    end

    local results = {}

    -- 콤마로 분리 (다중 옵션)
    local option_strs = StringSplit(arc_prefix, ",")

    for i, opt_str in ipairs(option_strs) do
        local parts = StringSplit(opt_str, ";")
        if #parts >= 2 then
            local option_cls_id = tonumber(parts[1])
            local value = tonumber(parts[2])
            if option_cls_id and value then
                table.insert(results, {option_cls_id, value})
            end
        end
    end

    return results
end

-- 옵션 정보 가져오기 (다중 옵션 지원)
-- 반환: { {tag, value, desc, grade}, {tag, value, desc, grade}, ... }
function GET_ARCHEOLOGY_OPTION_INFO(arc_prefix)
    local options = DESERIALIZE_ARCHEOLOGY_OPTION(arc_prefix)

    if not options or #options == 0 then
        return {}
    end

    local results = {}

    for i, opt in ipairs(options) do
        local option_cls_id = opt[1]
        local value = opt[2]

        local opt_cls = GetClassByType('archeology_option_list', option_cls_id)
        if opt_cls then
            table.insert(results, {
                tag = TryGetProp(opt_cls, "Stat", "UNKNOWN"),
                value = value,
                desc = TryGetProp(opt_cls, "Desc", ""),
                grade = TryGetProp(opt_cls, "Grade", 1)
            })
        end
    end

    return results
end

