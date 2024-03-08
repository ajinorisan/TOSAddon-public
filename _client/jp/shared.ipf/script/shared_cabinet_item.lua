-- shared_cabinet_item.lua

local function replace(text, to_be_replaced, replace_with)
	local retText = text
	local strFindStart, strFindEnd = string.find(text, to_be_replaced)	
    if strFindStart ~= nil then
		local nStringCnt = string.len(text)		
		retText = string.sub(text, 1, strFindStart-1) .. replace_with ..  string.sub(text, strFindEnd+1, nStringCnt)		
    else
        retText = text
	end
	
    return retText
end


g_cabinet_required_item_list = nil -- 보관함 등록 및 업그레이드시에 필요한 재료 목록

local luciferi_return_item_list = nil
local acc_group_list = nil -- acc 그룹 AccountProperty 리스트
local acc_upgrade_group_list = nil

local function make_cabinet_required_item_list()
    if g_cabinet_required_item_list ~= nil then
        return
    end
    g_cabinet_required_item_list = {}
    acc_group_list = {}
    acc_upgrade_group_list = {}

    local category_list = {}
    category_list['Weapon'] = 4
    category_list['Armor'] = 3
    category_list['Accessory'] = 1
    category_list['Ark'] = 1
    --2022/03 DY
    category_list['Skillgem'] = 1
    --
    category_list['Relicgem'] = 1
    category_list['Artefact'] = 1

    for k, v in pairs(category_list) do
        g_cabinet_required_item_list[k] = {} -- 카테고리 생성
    end



    -- g_cabinet_required_item_list[category][item_name][level][재료] = 개수

    local class_list, cnt = GetClassList('cabinet_weapon')    
    for i = 0, cnt - 1 do
        local entry_cls = GetClassByIndexFromList(class_list, i) -- 보관함 목록
        if entry_cls ~= nil then
            local item_name = TryGetProp(entry_cls, 'ClassName', 'None')      
            local max_lv = TryGetProp(entry_cls, 'MaxUpgrade', 1)
            local item_cls = GetClass('Item', item_name)
            if item_cls ~= nil and TryGetProp(entry_cls, 'Basic', 0) == 0 then
                if g_cabinet_required_item_list['Weapon'][item_name] == nil then
                    g_cabinet_required_item_list['Weapon'][item_name] = {}
                end
                local lv = 1
                for lv = 1, max_lv do
                    if g_cabinet_required_item_list['Weapon'][item_name][lv] == nil then
                        g_cabinet_required_item_list['Weapon'][item_name][lv] = {}  -- 레벨별 재료
                    end
                    
                    if lv == 1 or lv == 4 then
                        g_cabinet_required_item_list['Weapon'][item_name][lv][item_name] = 1 -- 1레벨 바이보라 1개 추가                        
                    end

                    if TryGetProp(item_cls, 'StringArg', 'None') == 'Vibora' then
                        if lv == 2 then
                            g_cabinet_required_item_list['Weapon'][item_name][lv]['EP12_enrich_Vibora_misc_NoTrade'] = 2
                            g_cabinet_required_item_list['Weapon'][item_name][lv]['GabijaCertificate'] = 20000
                        elseif lv == 3 then
                            g_cabinet_required_item_list['Weapon'][item_name][lv]['EP12_enrich_Vibora_misc_NoTrade'] = 5
                            g_cabinet_required_item_list['Weapon'][item_name][lv]['GabijaCertificate'] = 50000
                        elseif lv == 4 then
                            g_cabinet_required_item_list['Weapon'][item_name][lv]['EP12_enrich_Vibora_misc_NoTrade'] = 10
                            g_cabinet_required_item_list['Weapon'][item_name][lv]['GabijaCertificate'] = 100000
                        end
                    end
                end
            end
        end
    end

    local class_list, cnt = GetClassList('cabinet_armor')    
    for i = 0, cnt - 1 do
        local entry_cls = GetClassByIndexFromList(class_list, i) -- 보관함 목록
        if entry_cls ~= nil then
            local item_name = TryGetProp(entry_cls, 'ClassName', 'None')
            local max_lv = TryGetProp(entry_cls, 'MaxUpgrade', 1)
            local item_cls = GetClass('Item', item_name)
            if item_cls ~= nil and TryGetProp(entry_cls, 'Basic', 0) == 0 then
                if g_cabinet_required_item_list['Armor'][item_name] == nil then
                    g_cabinet_required_item_list['Armor'][item_name] = {}
                end
                local lv = 1

                if string.find(TryGetProp(item_cls, 'StringArg2', 'None'), 'goddess_noble') ~= nil then
                    for lv = 1, max_lv do
                        if g_cabinet_required_item_list['Armor'][item_name][lv] == nil then
                            g_cabinet_required_item_list['Armor'][item_name][lv] = {}  -- 레벨별 재료
                        end
                        
                        local misc = TryGetProp(item_cls, 'StringArg2', 'None')
                        if lv == 1 then
                            g_cabinet_required_item_list['Armor'][item_name][lv][misc] = 10
                        elseif lv == 2 then
                            misc = replace(misc, 'lv1_', 'lv2_')
                            g_cabinet_required_item_list['Armor'][item_name][lv][misc] = 10
                        elseif lv == 3 then
                            misc = replace(misc, 'lv1_', 'lv3_')
                            g_cabinet_required_item_list['Armor'][item_name][lv][misc] = 10
                        end

                    end
                elseif TryGetProp(item_cls, 'StringArg', 'None') == 'goddess' or TryGetProp(item_cls, 'StringArg', 'None') == 'evil' then                
                    for lv = 1, max_lv do
                        if g_cabinet_required_item_list['Armor'][item_name][lv] == nil then
                            g_cabinet_required_item_list['Armor'][item_name][lv] = {}  -- 레벨별 재료
                        end

                        if lv == 1 or lv == 3 then
                            g_cabinet_required_item_list['Armor'][item_name][lv]['misc_archenium_NoTrade'] = 1 -- 아케늄
                            g_cabinet_required_item_list['Armor'][item_name][lv]['evil_misc'] = 1 -- 검붉은
                            g_cabinet_required_item_list['Armor'][item_name][lv]['goddess_misc'] = 1 -- 신력                        
                        end

                        if TryGetProp(item_cls, 'StringArg', 'None') == 'evil' or TryGetProp(item_cls, 'StringArg', 'None') == 'goddess' then
                            if lv == 2 then
                                g_cabinet_required_item_list['Armor'][item_name][lv]['EP12_enrich_Goddess_misc_NoTrade'] = 3
                                g_cabinet_required_item_list['Armor'][item_name][lv]['GabijaCertificate'] = 12500
                            elseif lv == 3 then
                                g_cabinet_required_item_list['Armor'][item_name][lv]['EP12_enrich_Goddess_misc_NoTrade'] = 6
                                g_cabinet_required_item_list['Armor'][item_name][lv]['GabijaCertificate'] = 25000
                            end
                        end
                    end
                else
                    if g_cabinet_required_item_list['Armor'][item_name][lv] == nil then
                        g_cabinet_required_item_list['Armor'][item_name][lv] = {}  -- 레벨별 재료
                    end
                    g_cabinet_required_item_list['Armor'][item_name][lv][item_name] = 1
                end
            end
        end
    end
    
    local class_list, cnt = GetClassList('cabinet_accessory')
    for i = 0, cnt - 1 do
        local category = 'Accessory'
        local entry_cls = GetClassByIndexFromList(class_list, i) -- 보관함 목록        
        if entry_cls ~= nil then
            local item_name = TryGetProp(entry_cls, 'ClassName', 'None')
            local max_lv = TryGetProp(entry_cls, 'MaxUpgrade', 1)
            local item_cls = GetClass('Item', item_name)
            local group = TryGetProp(entry_cls, 'Group', 0)
            local acc_prop = TryGetProp(entry_cls, 'AccountProperty', 'None')
            local acc_upgrade_prop = TryGetProp(entry_cls, 'UpgradeAccountProperty', 'None')
            if item_cls ~= nil and TryGetProp(entry_cls, 'Basic', 0) == 0 and (TryGetProp(item_cls, 'StringArg', 'None') == 'Luciferi' or TryGetProp(item_cls, 'StringArg', 'None') == 'Acc_EP12') then
                if acc_group_list[group] == nil then
                    acc_group_list[group] = {}
                end

                if acc_upgrade_group_list[group] == nil then
                    acc_upgrade_group_list[group] = {}
                end

                if acc_prop ~= 'None' then
                    table.insert(acc_group_list[group], acc_prop)                             
                end

                if acc_upgrade_prop ~= 'None' then
                    table.insert(acc_upgrade_group_list[group], acc_upgrade_prop)           
                end

                if g_cabinet_required_item_list[category][item_name] == nil then
                    g_cabinet_required_item_list[category][item_name] = {}
                end
                local lv = 1                
                for lv = 1, max_lv do
                    if g_cabinet_required_item_list[category][item_name][lv] == nil then
                        g_cabinet_required_item_list[category][item_name][lv] = {}  -- 레벨별 재료
                    end
                    
                    if lv == 1 then
                        if item_name == 'EP12_NECK05_HIGH_002' or item_name == 'EP12_BRC05_HIGH_002' then   -- 카랄리엔 이스가리티
                            g_cabinet_required_item_list[category][item_name][lv]['NECK05_012'] = 1
                            g_cabinet_required_item_list[category][item_name][lv]['BRC05_012__1'] = 1
                            g_cabinet_required_item_list[category][item_name][lv]['BRC05_012__2'] = 1
                            g_cabinet_required_item_list[category][item_name][lv]['NECK05_004'] = 1
                            g_cabinet_required_item_list[category][item_name][lv]['BRC05_004__1'] = 1
                            g_cabinet_required_item_list[category][item_name][lv]['BRC05_004__2'] = 1
                        elseif item_name == 'EP12_NECK05_HIGH_001' or item_name == 'EP12_BRC05_HIGH_001' then   -- 카랄리엔 주오다
                            g_cabinet_required_item_list[category][item_name][lv]['NECK05_010'] = 1
                            g_cabinet_required_item_list[category][item_name][lv]['BRC05_010__1'] = 1
                            g_cabinet_required_item_list[category][item_name][lv]['BRC05_010__2'] = 1
                            g_cabinet_required_item_list[category][item_name][lv]['NECK05_006'] = 1
                            g_cabinet_required_item_list[category][item_name][lv]['BRC05_006__1'] = 1
                            g_cabinet_required_item_list[category][item_name][lv]['BRC05_006__2'] = 1
                        elseif item_name == 'EP12_BRC05_HIGH_003' then                                          -- 카랄리엔 칸트리베 1
                            g_cabinet_required_item_list[category][item_name][lv]['NECK05_009'] = 1
                            g_cabinet_required_item_list[category][item_name][lv]['BRC05_009__1'] = 1
                            g_cabinet_required_item_list[category][item_name][lv]['BRC05_009__2'] = 1
                            g_cabinet_required_item_list[category][item_name][lv]['NECK05_007'] = 1
                            g_cabinet_required_item_list[category][item_name][lv]['BRC05_007__1'] = 1
                            g_cabinet_required_item_list[category][item_name][lv]['BRC05_007__2'] = 1
                        elseif item_name == 'EP12_NECK05_HIGH_003' then                                         -- 카랄리엔 칸트리베 2
                            g_cabinet_required_item_list[category][item_name][lv] = {}
                            g_cabinet_required_item_list[category][item_name][lv]['NECK05_009'] = 1  
                            g_cabinet_required_item_list[category][item_name][lv]['BRC05_009__1'] = 1
                            g_cabinet_required_item_list[category][item_name][lv]['BRC05_009__2'] = 1
                            g_cabinet_required_item_list[category][item_name][lv]['NECK05_005'] = 1
                            g_cabinet_required_item_list[category][item_name][lv]['BRC05_005__1'] = 1
                            g_cabinet_required_item_list[category][item_name][lv]['BRC05_005__2'] = 1                                                    
                        elseif item_name == 'EP12_NECK05_HIGH_006' or item_name == 'EP12_BRC05_HIGH_006' then   -- 카랄리엔 트리우카스
                            g_cabinet_required_item_list[category][item_name][lv]['NECK05_011'] = 1     -- 모링포니아 트리우카스 네클리스
                            g_cabinet_required_item_list[category][item_name][lv]['BRC05_011__1'] = 1   -- 모링포니아 트리우카스 브레이슬릿
                            g_cabinet_required_item_list[category][item_name][lv]['BRC05_011__2'] = 1
                            g_cabinet_required_item_list[category][item_name][lv]['NECK05_001'] = 1     -- 드라코나스 리느키 시트 네클리스
                            g_cabinet_required_item_list[category][item_name][lv]['BRC05_001__1'] = 1   -- 드라코나스 리느키 시트 브레이슬릿
                            g_cabinet_required_item_list[category][item_name][lv]['BRC05_001__2'] = 1
                        elseif item_name == 'EP12_NECK05_HIGH_007' or item_name == 'EP12_BRC05_HIGH_007' then -- 카랄리엔 프리데티
                            g_cabinet_required_item_list[category][item_name][lv]['NECK05_008'] = 1     -- 모링포니아 피크티스 네클리스
                            g_cabinet_required_item_list[category][item_name][lv]['BRC05_008__1'] = 1   -- 모링포니아 피크티스 브레이슬릿
                            g_cabinet_required_item_list[category][item_name][lv]['BRC05_008__2'] = 1
                            g_cabinet_required_item_list[category][item_name][lv]['NECK05_002'] = 1     -- 드라코나스 카이트 무어 네클리스
                            g_cabinet_required_item_list[category][item_name][lv]['BRC05_002__1'] = 1   -- 드라코나스 카이트 무어 브레이슬릿
                            g_cabinet_required_item_list[category][item_name][lv]['BRC05_002__2'] = 1
                        elseif item_name == 'EP12_NECK05_HIGH_005' or item_name == 'EP12_BRC05_HIGH_005' then   -- 카랄리엔 피크티스
                            g_cabinet_required_item_list[category][item_name][lv]['NECK05_008'] = 1     -- 모링포니아 피크티스 네클리스
                            g_cabinet_required_item_list[category][item_name][lv]['BRC05_008__1'] = 1   -- 모링포니아 피크티스 브레이슬릿
                            g_cabinet_required_item_list[category][item_name][lv]['BRC05_008__2'] = 1
                            g_cabinet_required_item_list[category][item_name][lv]['NECK05_003'] = 1     -- 드라코나스 파시우테스 네클리스
                            g_cabinet_required_item_list[category][item_name][lv]['BRC05_003__1'] = 1   -- 드라코나스 파시우테스 브레이슬릿
                            g_cabinet_required_item_list[category][item_name][lv]['BRC05_003__2'] = 1
                        end
                    end

                    if lv == 1 then
                        g_cabinet_required_item_list[category][item_name][lv]['misc_mothstone_NoTrade'] = 1  -- 바이올렛틴
                    end

                    if lv == 2 then
                        g_cabinet_required_item_list[category][item_name][lv]['misc_luferium_NoTrade'] = 1  -- 루페리움
                        g_cabinet_required_item_list[category][item_name][lv]['misc_Telharsha_neck'] = 72  -- 의장품
                    end
                end
            end
        end
    end

    local class_list, cnt = GetClassList('cabinet_ark')
    for i = 0, cnt - 1 do
        local category = 'Ark'
        local entry_cls = GetClassByIndexFromList(class_list, i) -- 보관함 목록
        if entry_cls ~= nil then
            local item_name = TryGetProp(entry_cls, 'ClassName', 'None')
            local max_lv = TryGetProp(entry_cls, 'MaxUpgrade', 1)
            local item_cls = GetClass('Item', item_name)
            local group = TryGetProp(entry_cls, 'Group', 0)
            local acc_prop = TryGetProp(entry_cls, 'AccountProperty', 'None')
            if TryGetProp(item_cls, 'StringArg2', 'None') == 'Made_Ark' then
                if g_cabinet_required_item_list[category][item_name] == nil then
                    g_cabinet_required_item_list[category][item_name] = {}
                end
                local lv = 1
                for lv = 1, max_lv do
                    if g_cabinet_required_item_list[category][item_name][lv] == nil then
                        g_cabinet_required_item_list[category][item_name][lv] = {}  -- 레벨별 재료
                    end
                    g_cabinet_required_item_list[category][item_name][lv]['misc_thierrynium_NoTrade'] = 1
                    g_cabinet_required_item_list[category][item_name][lv]['Piece_LegendMisc'] = 4
                end
            end
        end
    end

    --Skillgem 추가 : 2022/02/24 DY
    local class_list, cnt = GetClassList("cabinet_skillgem")
    for i=0, cnt-1 do
        local category = 'Skillgem'
        local entry_cls = GetClassByIndexFromList(class_list,i) -- 보관함 목록
        
        if entry_cls ~= nil then
            local item_name = TryGetProp(entry_cls, 'ClassName','None')
            local max_lv = TryGetProp(entry_cls,'MaxUpgrade',0)
            local item_cls = GetClass('Item',item_name)
            local acc_prop = TryGetProp(entry_cls, 'AccountProperty', 'None')
            local acc_upgrade_prop = TryGetProp(entry_cls, 'UpgradeAccountProperty', 'None') --미사용
   
            --*조건 이렇게만 해도 되는지 확인해볼필요가있음*
            if item_cls ~= nil and TryGetProp(entry_cls,'Basic',0) == 0 and (TryGetProp(item_cls,'StringArg','None'))=='SkillGem' then
                if g_cabinet_required_item_list['Skillgem'][item_name] ==nil then
                    g_cabinet_required_item_list['Skillgem'][item_name] = {}
                end
                local lv = 0 --스킬잼은 현재 업그레이드 미사용으로 lv 0 , 추후 잼 업그레이드 컨텐츠 추가될경우 위해 upgrade카테고리 보유
                for lv=0, max_lv do
                    if g_cabinet_required_item_list['Skillgem'][item_name][lv] ==nil then
                        g_cabinet_required_item_list['Skillgem'][item_name][lv] ={}
                    end
                    g_cabinet_required_item_list['Skillgem'][item_name][lv][item_name]=1 -- 스킬잼 
                   
                end
            end
        end
    end

    local class_list,cnt = GetClassList('cabinet_relicgem')
    for i =0,cnt -1 do
        local entry_cls = GetClassByIndexFromList(class_list,i)
        if entry_cls ~=nil then
            local item_name = TryGetProp(entry_cls,'ClassName','None')
            local max_lv    = TryGetProp(entry_cls,'MaxUpgrade',1)
            local item_cls  = GetClass('Item',item_name)
            if item_cls ~= nil and TryGetProp(entry_cls,'Basic',0) == 0 then
                if g_cabinet_required_item_list['Relicgem'][item_name] == nil then
                    g_cabinet_required_item_list['Relicgem'][item_name] = {}
                end
                local lv = 1
                for lv = 1 ,max_lv do
                    if g_cabinet_required_item_list['Relicgem'][item_name][lv] ==nil then
                        g_cabinet_required_item_list['Relicgem'][item_name][lv] ={}
                    end
                    g_cabinet_required_item_list['Relicgem'][item_name][lv][item_name] = 1
                end
            end
        end
    end

    local class_list,cnt = GetClassList('cabinet_artefact')
    for i =0,cnt -1 do
        local entry_cls = GetClassByIndexFromList(class_list,i)
        if entry_cls ~=nil then
            local item_name = TryGetProp(entry_cls,'ClassName','None')
            local max_lv    = TryGetProp(entry_cls,'MaxUpgrade',1)
            local item_cls  = GetClass('Item',item_name)
            if item_cls ~= nil and TryGetProp(entry_cls,'Basic',0) == 0 then
                if g_cabinet_required_item_list['Artefact'][item_name] == nil then
                    g_cabinet_required_item_list['Artefact'][item_name] = {}
                end
                local lv = 1
                for lv = 1 ,max_lv do
                    if g_cabinet_required_item_list['Artefact'][item_name][lv] ==nil then
                        g_cabinet_required_item_list['Artefact'][item_name][lv] ={}
                    end
                    g_cabinet_required_item_list['Artefact'][item_name][lv][item_name] = 1
                end
            end
        end
    end
end

make_cabinet_required_item_list()

function GET_ACC_GROUP_PROPERTY_LIST(group)
    return acc_group_list[group]
end

function GET_ACC_UPGRADE_GROUP_PROPERTY_LIST(group)
    return acc_upgrade_group_list[group]
end

function GET_REGISTER_MATERIAL(category, item_name, lv)
 
    if g_cabinet_required_item_list[category] == nil then
        return nil
    end

    if g_cabinet_required_item_list[category][item_name] == nil then
        return nil
    end
    
    return g_cabinet_required_item_list[category][item_name][lv]
end

-- 장비보관함 아이템 레벨 표기방식이, 성물젬은 무기나 방어구와 다르게 되어있어 호환불가
function ITEM_CABINET_GET_RELICGEM_UPGRADE_ACC_PROP(frame,itemCls)
	local acc = GetMyAccountObj()
	local category = ITEM_CABINET_GET_CATEGORY(frame)
    if category~="Relicgem" then
        return 0
    end
    local clsName  = TryGetProp(itemCls,"ClassName") 
    local id_space = 'cabinet_'..string.lower(category)
    local cabinet_itemCls  = GetClass(id_space,clsName)
    local upgradeAccountProp = TryGetProp(cabinet_itemCls,"UpgradeAccountProperty","None")
	if upgradeAccountProp~='None' then
        local propVal  = TryGetProp(acc,upgradeAccountProp)
		return propVal
	end
	return 0
end
  
function ITEM_CABINET_GET_RELICGEM_ACC_PROP(frame,itemCls)
	local acc = GetMyAccountObj()
	local category = ITEM_CABINET_GET_CATEGORY(frame)
    if category~="Relicgem" then
        return 0
    end
    local clsName  = TryGetProp(itemCls,"ClassName") 
    local id_space = 'cabinet_'..string.lower(category)
    local cabinet_itemCls  = GetClass(id_space,clsName)
    local accountProp = TryGetProp(cabinet_itemCls,"AccountProperty","None")
	if upgradeAccountProp~='None' then
        local propVal  = TryGetProp(acc,accountProp)
		return propVal
	end
	return 0
end

-- 클라에서 표기용
function GET_CABINET_ITEM_NAME(cls, acc)
    if cls == nil or acc == nil then
        return 'None'
    end
    --계정에서 아이템별 업그레이드 상황을 받아온다 
    if TryGetProp(cls, 'Upgrade', 'None') == 1 then
        local name = TryGetProp(cls, 'ClassName', 'None')
         --성물젬은 무기나 갑옷과 다르게 레벨별 아이템이 분류되있지 않아 젬레벨을 갱신해 표기
        local category = TryGetProp(cls,"Category","None")
   
        local upgrade_property = TryGetProp(cls, 'UpgradeAccountProperty', 0) 
        local lv = TryGetProp(acc, upgrade_property, 0)
        if category == "Relicgem" then 
            return name 
        end

        if lv <= 1 then
            return name
        else
            name = name .. '_Lv' .. lv
            return name
        end
 
    else
        return TryGetProp(cls, 'ClassName', 'None')
    end
end

-- 다음 레벨 표시용
function GET_UPGRADE_CABINET_ITEM_NAME(cls, lv)
    if cls == nil then
        return 'None'
    end
    
    -- Relicgem 은 해당 Func 미사용
    if TryGetProp(cls,'Category','None') =="Relicgem" then
        local name = TryGetProp(cls, 'ClassName', 'None')        
        return name  -- Relicgem 은 무기 또는 여마신 방어구와 다르게 아이템+lv 표기로 item.xml 추가되어있지 않다. 
    end

    if TryGetProp(cls, 'Upgrade', 'None') == 1 then
        local name = TryGetProp(cls, 'ClassName', 'None')        
        if lv <= 1 then
            return name
        else
            name = name .. '_Lv' .. lv
            return name
        end
    else
        return TryGetProp(cls, 'ClassName', 'None')
    end
end

function GET_ORIGINAL_VIBORA_NAME(name)
    local cls = GetClass('Item', name)
    if cls == nil then return name end
    if TryGetProp(cls, 'StringArg', 'None') ~= 'Vibora' 
    and TryGetProp(cls, 'StringArg', 'None') ~= 'goddess' 
    and TryGetProp(cls, 'StringArg', 'None') ~= 'evil' then
        return name
    end

    local lv = TryGetProp(cls, 'NumberArg1', 0)
    if lv < 2 then return name end

    local token = StringSplit(name, '_')
    local suffix = token[#token]    
    if suffix == 'Lv' .. lv then
        local n = ''
        for i = 1, #token - 1 do
            if i == #token - 1 then
                n = n .. token[i]
            else
                n = n .. token[i] .. '_'
            end            
        end

        return n
    end

    return name
end


function GET_CABINET_ACC_ITEM_NAME(cls, acc)
    if cls == nil or acc == nil then
        return 'None'
    end
    
    if TryGetProp(cls, 'Upgrade', 'None') == 1 then
        local name = TryGetProp(cls, 'ClassName', 'None')
        local upgrade_property = TryGetProp(cls, 'UpgradeAccountProperty', 0)
        
        local lv = TryGetProp(acc, upgrade_property, 0)        
        if lv <= 1 then
            return name
        elseif lv == 2 then
            if name == 'EP12_NECK05_HIGH_006' then
                return 'EP12_NECK06_HIGH_005'
            end

            if name == 'EP12_BRC05_HIGH_006' then
                return 'EP12_BRC06_HIGH_005'
            end

            if name == 'EP12_NECK05_HIGH_007' then
                return 'EP12_NECK06_HIGH_006'                
            end

            if name == 'EP12_BRC05_HIGH_007' then
                return 'EP12_BRC06_HIGH_006'
            end

            if name == 'EP12_NECK05_HIGH_005' then
                return 'EP12_NECK06_HIGH_004'
            end

            if name == 'EP12_BRC05_HIGH_005' then
                return 'EP12_BRC06_HIGH_004'
            end

            if string.find(name, '_NECK05_') ~= nil then
                name = replace(name, '_NECK05_', '_NECK06_')
                return name
            elseif string.find(name, '_BRC05_') ~= nil then
                name = replace(name, '_BRC05_', '_BRC06_')
                return name
            else
                return name
            end
        else
            return name
        end
    else
        return TryGetProp(cls, 'ClassName', 'None')
    end
end

function GET_UPGRADE_CABINET_ACC_ITEM_NAME(cls, lv)
    if cls == nil then
        return 'None'
    end
    
    if TryGetProp(cls, 'Upgrade', 'None') == 1 then
        local name = TryGetProp(cls, 'ClassName', 'None')
        if lv <= 1 then
            return name
        elseif lv == 2 then
            if name == 'EP12_NECK05_HIGH_006' then
                return 'EP12_NECK06_HIGH_005'
            end

            if name == 'EP12_BRC05_HIGH_006' then
                return 'EP12_BRC06_HIGH_005'
            end

            if name == 'EP12_NECK05_HIGH_007' then
                return 'EP12_NECK06_HIGH_006'                
            end

            if name == 'EP12_BRC05_HIGH_007' then
                return 'EP12_BRC06_HIGH_006'
            end

            if name == 'EP12_NECK05_HIGH_005' then
                return 'EP12_NECK06_HIGH_004'
            end

            if name == 'EP12_BRC05_HIGH_005' then
                return 'EP12_BRC06_HIGH_004'
            end

            if string.find(name, '_NECK05_') ~= nil then
                name = replace(name, '_NECK05_', '_NECK06_')
                return name
            elseif string.find(name, '_BRC05_') ~= nil then
                name = replace(name, '_BRC05_', '_BRC06_')
                return name
            else
                return name
            end
        else
            return name
        end
    else
        return TryGetProp(cls, 'ClassName', 'None')
    end
end

function CHECK_ENCHANT_VALIDATION(target_item, category, type, aObj, pc)
    if target_item == nil then 
        return false, 'IMPOSSIBLE_ITEM'
    end
    
    if item_goddess_growth.is_goddess_growth_item(target_item) == true then
        return false, 'IMPOSSIBLE_ITEM'
    end

    if TryGetProp(target_item, 'ItemGrade', 1) < 6 then        
        return false, "OnlyEquipGoddessItemOnSlot";
    end

    if TryGetProp(target_item, 'NeedRandomOption', 1) == 1 then        
        return false, "NeedAppraisd";
    end

    if TryGetProp(target_item, 'ClassType', 'None') == 'None' then
        -- 클래스 타입이 맞지 않음
        return false, "NotMatchItemClassType";
    end

    local idspace = 'None'
    if category == 'Weapon' then
        idspace = 'cabinet_weapon'
    elseif category == 'Armor' then
        idspace = 'cabinet_armor'
    elseif category == 'Artefact' then
        idspace = 'cabinet_artefact'
    end    
    
    if idspace == 'None' then         
        return false;
    end

    local entry_cls = GetClassByType(idspace, type)
    if entry_cls == nil then        
        return false;
    end

    if TryGetProp(entry_cls, 'GetItemFunc', 'None') == 'None' then return false; end
	
	local get_name_func = _G[TryGetProp(entry_cls, 'GetItemFunc', 'None')];
	if get_name_func == nil then return false; end

    local inheritance_item_name = get_name_func(entry_cls, aObj)
    if inheritance_item_name == 'None' then return false end
    local inheritance_item_name_cls = GetClass('Item', inheritance_item_name)
    if inheritance_item_name_cls == nil then return false end

    if TryGetProp(inheritance_item_name_cls, 'ClassType', 'None') == 'None' then
        return false, "NotMatchItemClassType";
    end

    if TryGetProp(target_item, 'InheritanceItemName', 'None') == TryGetProp(inheritance_item_name_cls, 'ClassName', 'None') then        
        return false, "AlreadyPrefixOption";
    end

    if TryGetProp(target_item, 'BriquettingIndex', 'None') == TryGetProp(inheritance_item_name_cls, 'ClassID', 'None') then        
        return false, "AlreadyBriquet";
    end

    if TryGetProp(inheritance_item_name_cls, 'ClassType', 'None') == 'Arcane' then        
        local target_class_type = TryGetProp(target_item, 'ClassType', 'None')
        if IS_WEAPON_TYPE(target_class_type) == false then
            if IsServerSection() == 1 and pc ~= nil then
                SendSysMsg(pc, 'OnlyEnchantToWeapon')            
            end
            return false, "OnlyEnchantToWeapon"
        else
            -- 바이보라 비전을 부여하고자 하는 경우
            local add_option = TryGetProp(inheritance_item_name_cls, 'AdditionalOption_1', 'None')
            if add_option ~= 'None' then
                if IsServerSection() == 1 and pc ~= nil then
                    local target_guid = GetIESID(target_item)    
                    local spot = GetItemEquipSpotByGuid(pc, target_guid)                
                    if spot ~= 'LAST' then
                        if IS_EQUIP_UNIQUE_VIBORA_BY_OPTION_NAME(pc, spot, add_option) == false then
                            return false, "OnlyOneUniqueViboraEquip"
                        end
                        
                        if GET_EQUIP_UNIQUE_VIBORA_COUNT_BY_OPTION_NAME(pc, spot, add_option) >= MAX_EQUIPTED_UNIQUE_VIBORA_COUNT then
                            return false, nil, ScpArgMsg("EquipedMaxUniqueVibora{count}", "count", MAX_EQUIPTED_UNIQUE_VIBORA_COUNT)
                        end
                    end
                end
            end
        end        
    else
        if category == 'Armor' then -- 갈리미베 방어구 예외처리(모든 방어구 부위에 장착)
            local target_classtype = TryGetProp(target_item, 'ClassType', 'None')
            if target_classtype == 'Shirt' or target_classtype == 'Pants' or target_classtype == 'Boots' or target_classtype == 'Gloves' then
                local str_arg = TryGetProp(inheritance_item_name_cls, 'StringArg', 'None')
                if str_arg == 'EP13GALIMYBEARMOR' then
                    return true
                end
            end
        end

        if TryGetProp(target_item, 'ClassType', 'None') ~= TryGetProp(inheritance_item_name_cls, 'ClassType', 'None') then            
            return false, "NotMatchItemClassType";
        end
    end

    return true;
end

-- 착용한 고유 바이보라 개수를 리턴한다. 
-- equip_slot_name : 착용 교체시에 착용할 위치를 전달, 교체되는 방식이기 때문에, 해당 부위의 착용여부를 체크하지 않음
-- equip_slot_name {'LH', 'RH', 'LH_SUB', 'RH_SUB'}
function GET_EQUIP_UNIQUE_VIBORA_COUNT(pc, equip_slot_name, item)
    local slot_list = {'LH', 'RH', 'LH_SUB', 'RH_SUB'}
    
    if item == nil then
        return 0
    end

    local inheritance = TryGetProp(item, 'InheritanceItemName', 'None')
    if inheritance == 'None' then
        return 0
    end

    local cls_1 = GetClass("Item", inheritance)

    if cls_1 == nil then
        return 0
    end

    local _add_option = TryGetProp(cls_1, 'AdditionalOption_1', 'None')
    if _add_option == 'None' then
        return 0
    end

    local count = 0    
    for k, v in pairs(slot_list) do
        if equip_slot_name ~= v then
            local itemObj = nil
            if IsServerSection() == 1 then
                itemObj = GetEquipItem(pc, v)
            else
                local equip_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(v));
                if equip_item ~= nil then
                    itemObj = GetIES(equip_item:GetObject())
                end            
            end

            if itemObj ~= nil then
                local inheritance_name = TryGetProp(itemObj, 'InheritanceItemName', 'None')
                if inheritance_name ~= 'None' then
                    local cls = GetClass('Item', inheritance_name)
                    if cls ~= nil then
                        local add_option = TryGetProp(cls, 'AdditionalOption_1', 'None')
                        if add_option ~= 'None' then
                            count = count + 1
                        end
                    end
                end
            end
        end
    end

    return count
end

function GET_EQUIP_UNIQUE_VIBORA_COUNT_BY_OPTION_NAME(pc, equip_slot_name, option_name)
    local slot_list = {'LH', 'RH', 'LH_SUB', 'RH_SUB'}
    
    local _add_option = option_name
    if _add_option == 'None' then
        return 0
    end

    local count = 0    
    for k, v in pairs(slot_list) do
        if equip_slot_name ~= v then
            local itemObj = nil
            if IsServerSection() == 1 then
                itemObj = GetEquipItem(pc, v)
            else
                local equip_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(v));
                if equip_item ~= nil then
                    itemObj = GetIES(equip_item:GetObject())
                end            
            end

            if itemObj ~= nil then
                local inheritance_name = TryGetProp(itemObj, 'InheritanceItemName', 'None')
                if inheritance_name ~= 'None' then
                    local cls = GetClass('Item', inheritance_name)
                    if cls ~= nil then
                        local add_option = TryGetProp(cls, 'AdditionalOption_1', 'None')
                        if add_option ~= 'None' then
                            count = count + 1
                        end
                    end
                end
            end
        end
    end

    return count
end

-- 착용할 바이보라가 고유한 바이보라인가
-- true 인 경우 착용 가능
function IS_EQUIP_UNIQUE_VIBORA(pc, equip_slot_name, item)
    local slot_list = {'LH', 'RH', 'LH_SUB', 'RH_SUB' }
    
    if item == nil then
        return false
    end

    local inheritance = TryGetProp(item, 'InheritanceItemName', 'None')
    if inheritance == 'None' then
        return true
    end

    local cls_1 = GetClass("Item", inheritance)
    
    if cls_1 == nil then
        return false
    end
    
    local _add_option = TryGetProp(cls_1, 'AdditionalOption_1', 'None')
    if _add_option == 'None' then
        return true
    end
    
    for k, v in pairs(slot_list) do
        if equip_slot_name ~= v then
            local itemObj = nil
            if IsServerSection() == 1 then
                itemObj = GetEquipItem(pc, v)
            else
                local equip_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(v));
                if equip_item ~= nil then
                    itemObj = GetIES(equip_item:GetObject())
                end            
            end

            if itemObj ~= nil then
                local inheritance_name = TryGetProp(itemObj, 'InheritanceItemName', 'None')
                if inheritance_name ~= 'None' then
                    local cls = GetClass('Item', inheritance_name)
                    if cls ~= nil then
                        local add_option = TryGetProp(cls, 'AdditionalOption_1', 'None')
                        if add_option == _add_option then
                            return false
                        end
                    end
                end
            end
        end
    end

    return true
end

function IS_EQUIP_UNIQUE_VIBORA_BY_OPTION_NAME(pc, equip_slot_name, option_name)
    local slot_list = {'LH', 'RH', 'LH_SUB', 'RH_SUB' }
        
    local _add_option = option_name
    if _add_option == 'None' then
        return true
    end

    for k, v in pairs(slot_list) do
        if equip_slot_name ~= v then
            local itemObj = nil
            if IsServerSection() == 1 then
                itemObj = GetEquipItem(pc, v)
            else
                local equip_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(v));
                if equip_item ~= nil then
                    itemObj = GetIES(equip_item:GetObject())
                end            
            end

            if itemObj ~= nil then
                local inheritance_name = TryGetProp(itemObj, 'InheritanceItemName', 'None')
                if inheritance_name ~= 'None' then
                    local cls = GetClass('Item', inheritance_name)
                    if cls ~= nil then
                        local add_option = TryGetProp(cls, 'AdditionalOption_1', 'None')
                        if add_option == _add_option then
                            return false
                        end
                    end
                end
            end
        end
    end

    return true
end

function IS_ACCOUNT_COIN(name)
    local cls = GetClass('accountprop_inventory_list', name)
    if cls == nil then
        return false
    else
        if TryGetProp(cls, 'StringCoin', 'None') == 'YES' then
            return true
        else
            return false
        end
    end
end

function IS_STRING_COIN(name)
    local cls = GetClass('accountprop_inventory_list', name)
    if cls == nil then
        return false
    else
        if TryGetProp(cls, 'StringCoin', 'None') == 'YES' then
            return true
        else
            return false
        end
    end
end

function GET_ACC_CABINET_COST(entry_cls, acc)        
    if TryGetProp(entry_cls, 'Category', 'None') == 'Accessory' then        
        local cost = TryGetProp(entry_cls, 'MakeCostSilver', 5000000)
        local upgrade_prop = TryGetProp(entry_cls, 'UpgradeAccountProperty', 'None')
        local lv = TryGetProp(acc, upgrade_prop, 0)        
        if lv <= 1 then
            cost = math.floor(cost * 0.4)
        end

        return cost
    end

    return TryGetProp(entry_cls, 'MakeCostSilver', 5000000)
end

-- 보관함 개방권
local cabinet_item_armor_list = nil
local cabinet_armor_list_type = nil

local cabinet_item_acc_list = nil
local cabinet_acc_list_type = nil

local cabinet_item_luci_acc_list = nil
local cabinet_luci_acc_list_type = nil

local cabinet_item_ark_list = nil
local cabinet_ark_list_type = nil

function init_cabinet_item_armor_list()
    if cabinet_item_armor_list ~= nil then
        return
    end

    cabinet_armor_list_type = {'Gabija', 'Dalia', 'installation', 'Vakarine', 'Austeja', 'Zemyna', 'EVIL', 'EVIL_SUMMONNER'} 

    cabinet_item_armor_list = {}    
    local prefix = 'EP12'
    local suffix_list = {'TOP', 'LEG', 'HAND', 'FOOT'}    

    for k, v in pairs(cabinet_armor_list_type) do        
        cabinet_item_armor_list[v] = {}
        for _, v2 in pairs(suffix_list) do           
            local name = prefix .. '_' .. v .. '_' .. v2 
            table.insert(cabinet_item_armor_list[v], name)
        end
    end
end
function init_cabinet_item_acc_list()
    if cabinet_item_acc_list ~= nil then
        return
    end

    if cabinet_item_luci_acc_list ~= nil then
        return
    end

    cabinet_acc_list_type = {'isgariti', 'juoda', 'kantrybe', 'triukas', 'predeti', 'piktis'}
    cabinet_item_acc_list = {}

    cabinet_item_acc_list['isgariti'] = {}
    table.insert(cabinet_item_acc_list['isgariti'], 'EP12_NECK05_HIGH_002')
    table.insert(cabinet_item_acc_list['isgariti'], 'EP12_BRC05_HIGH_002')

    cabinet_item_acc_list['juoda'] = {}
    table.insert(cabinet_item_acc_list['juoda'], 'EP12_NECK05_HIGH_001')
    table.insert(cabinet_item_acc_list['juoda'], 'EP12_BRC05_HIGH_001')

    cabinet_item_acc_list['kantrybe'] = {}
    table.insert(cabinet_item_acc_list['kantrybe'], 'EP12_NECK05_HIGH_003')
    table.insert(cabinet_item_acc_list['kantrybe'], 'EP12_BRC05_HIGH_003')

    cabinet_item_acc_list['triukas'] = {}
    table.insert(cabinet_item_acc_list['triukas'], 'EP12_NECK05_HIGH_006')
    table.insert(cabinet_item_acc_list['triukas'], 'EP12_BRC05_HIGH_006')

    cabinet_item_acc_list['predeti'] = {}
    table.insert(cabinet_item_acc_list['predeti'], 'EP12_NECK05_HIGH_007')
    table.insert(cabinet_item_acc_list['predeti'], 'EP12_BRC05_HIGH_007')

    cabinet_item_acc_list['piktis'] = {}
    table.insert(cabinet_item_acc_list['piktis'], 'EP12_NECK05_HIGH_005')
    table.insert(cabinet_item_acc_list['piktis'], 'EP12_BRC05_HIGH_005')

    cabinet_luci_acc_list_type = {'isgariti_2', 'juoda_2', 'kantrybe_2', 'triukas_2', 'predeti_2', 'piktis_2'}
    cabinet_item_luci_acc_list = {}

    cabinet_item_luci_acc_list['isgariti_2'] = {}
    table.insert(cabinet_item_luci_acc_list['isgariti_2'], 'EP12_NECK06_HIGH_002')
    table.insert(cabinet_item_luci_acc_list['isgariti_2'], 'EP12_BRC06_HIGH_002')

    cabinet_item_luci_acc_list['juoda_2'] = {}
    table.insert(cabinet_item_luci_acc_list['juoda_2'], 'EP12_NECK06_HIGH_001')
    table.insert(cabinet_item_luci_acc_list['juoda_2'], 'EP12_BRC06_HIGH_001')

    cabinet_item_luci_acc_list['kantrybe_2'] = {}
    table.insert(cabinet_item_luci_acc_list['kantrybe_2'], 'EP12_NECK06_HIGH_003')
    table.insert(cabinet_item_luci_acc_list['kantrybe_2'], 'EP12_BRC06_HIGH_003')

    cabinet_item_luci_acc_list['triukas_2'] = {}
    table.insert(cabinet_item_luci_acc_list['triukas_2'], 'EP12_NECK06_HIGH_005')
    table.insert(cabinet_item_luci_acc_list['triukas_2'], 'EP12_BRC06_HIGH_005')

    cabinet_item_luci_acc_list['predeti_2'] = {}
    table.insert(cabinet_item_luci_acc_list['predeti_2'], 'EP12_NECK06_HIGH_006')
    table.insert(cabinet_item_luci_acc_list['predeti_2'], 'EP12_BRC06_HIGH_006')

    cabinet_item_luci_acc_list['piktis_2'] = {}
    table.insert(cabinet_item_luci_acc_list['piktis_2'], 'EP12_NECK06_HIGH_004')
    table.insert(cabinet_item_luci_acc_list['piktis_2'], 'EP12_BRC06_HIGH_004')

end
function init_cabinet_item_ark_list()
    if cabinet_item_ark_list ~= nil then
        return
    end

    cabinet_ark_list_type = {'Ark_thunderbolt', 'Ark_dispersion', 'Ark_overpower', 'Ark_wind', 'Ark_punishment', 'Ark_healingwave', 'Ark_storm'}
    cabinet_item_ark_list = {}

    for _, v in pairs(cabinet_ark_list_type) do
        cabinet_item_ark_list[v] = v
    end    
end

init_cabinet_item_armor_list()
init_cabinet_item_acc_list()
init_cabinet_item_ark_list()

function GET_CABINET_ARMOR_TYPE_BY_INDEX(index)
    return cabinet_armor_list_type[index]
end
function GET_CABINET_ARMOR_INDEX(type)
    for i = 1, #cabinet_armor_list_type do
        if cabinet_armor_list_type[i] == type then
            return i
        end
    end
    return 0
end
function GET_CABINET_ITEM_ARMOR_TYPE_LIST()
    return cabinet_armor_list_type
end
function GET_CABINET_ITEM_ARMOR_LIST(name)
    return cabinet_item_armor_list[name]
end

function GET_CABINET_ACC_INDEX(type)
    for i = 1, #cabinet_armor_list_type do
        if cabinet_acc_list_type[i] == type then
            return i
        end
    end
    return 0
end
function GET_CABINET_ITEM_ACC_TYPE_LIST()
    return cabinet_acc_list_type
end
function GET_CABINET_ITEM_ACC_LIST(name)
    return cabinet_item_acc_list[name]
end

function GET_CABINET_LUCI_ACC_INDEX(type)
    for i = 1, #cabinet_armor_list_type do
        if cabinet_luci_acc_list_type[i] == type then
            return i
        end
    end
    return 0
end
function GET_CABINET_ITEM_LUCI_ACC_TYPE_LIST()
    return cabinet_luci_acc_list_type
end
function GET_CABINET_ITEM_LUCI_ACC_LIST(name)
    return cabinet_item_luci_acc_list[name..'_2']
end

function GET_CABINET_ARK_INDEX(type)
    for i = 1, #cabinet_ark_list_type do
        if cabinet_ark_list_type[i] == type then
            return i
        end
    end
    return 0
end
function GET_CABINET_ITEM_ARK_TYPE_LIST()
    return cabinet_ark_list_type
end
function GET_CABINET_ITEM_ARK_LIST(name)
    return cabinet_item_ark_list[name]
end

function IS_VALID_CABINET_ITEM_ARMOR_OPEN(acc, type) -- type 아이템 종류(가비야, 아우스테야 등)
    local list = GET_CABINET_ITEM_ARMOR_LIST(type)
    if list == nil then
        return 0, 'NotValidItem'
    end

    local count = 0
    for _, v in pairs(list) do
        local cls = GetClass('cabinet_armor', v)
        if cls == nil then
            return 0, 'NotValidItem'
        end
        local prop = TryGetProp(cls, 'AccountProperty', 'None')
        local prop_2 = TryGetProp(cls, 'UpgradeAccountProperty', 'None')
        if prop == 'None' or prop_2 == 'None' then
            return 0, 'NotValidItem'
        end

        if TryGetProp(acc, prop, 0) ~= 0 or TryGetProp(acc, prop_2, 0) ~= 0 then
            count = count + 1
        end
    end
    if count == 4 then
        return 0
    elseif count == 0 then
        return 1
    else
        return 2
    end

    return 1
end

function IS_VALID_CABINET_ITEM_ACC_OPEN(acc, type)
    local list = GET_CABINET_ITEM_ACC_LIST(type)
    if list == nil then
        return 0, 'NotValidItem'
    end

    for _, v in pairs(list) do
        local cls = GetClass('cabinet_accessory', v)
        if cls == nil then
            return 0, 'NotValidItem'
        end
        local prop = TryGetProp(cls, 'AccountProperty', 'None')
        local prop_2 = TryGetProp(cls, 'UpgradeAccountProperty', 'None')
        if prop == 'None' or prop_2 == 'None' then
            return 0, 'NotValidItem'
        end

        if TryGetProp(acc, prop, 0) ~= 0 or TryGetProp(acc, prop_2, 0) ~= 0 then
            return 0
        end
    end
    
    return 1
end

-- 카랄리엔
function IS_VALID_CREATE_CABINET_ITEM_ACC_OPEN(acc, type)
    local list = GET_CABINET_ITEM_ACC_LIST(type)
    if list == nil then
        return 0, 'NotValidItem'
    end

    for _, v in pairs(list) do
        local cls = GetClass('cabinet_accessory', v)
        if cls == nil then
            return 0, 'NotValidItem'
        end
        local prop = TryGetProp(cls, 'AccountProperty', 'None')
        local prop_2 = TryGetProp(cls, 'UpgradeAccountProperty', 'None')
        if prop == 'None' or prop_2 == 'None' then
            return 0, 'NotValidItem'
        end
        
        if TryGetProp(acc, prop, 0) == 1 and TryGetProp(acc, prop_2, 0) >= 1 then
            return 1
        end
    end
    
    return 0
end
-- 루시페리
function IS_VALID_CREATE_CABINET_ITEM_ACC2_OPEN(acc, type)
    local list = GET_CABINET_ITEM_ACC_LIST(type)
    if list == nil then
        return 0, 'NotValidItem'
    end

    for _, v in pairs(list) do
        local cls = GetClass('cabinet_accessory', v)
        if cls == nil then
            return 0, 'NotValidItem'
        end
        local prop = TryGetProp(cls, 'AccountProperty', 'None')
        local prop_2 = TryGetProp(cls, 'UpgradeAccountProperty', 'None')
        if prop == 'None' or prop_2 == 'None' then
            return 0, 'NotValidItem'
        end
        
        if TryGetProp(acc, prop, 0) == 1 and TryGetProp(acc, prop_2, 0) > 1 then
            return 1
        end
    end
    
    return 0
end

--루시페리 개방권 전용
function IS_VALID_CABINET_ITEM_LUCI_ACC_OPEN(acc, type)
    local list = GET_CABINET_ITEM_ACC_LIST(type)
    if list == nil then
        return 0, 'NotValidItem'
    end

    for _, v in pairs(list) do
        local cls = GetClass('cabinet_accessory', v)
        if cls == nil then
            return 0, 'NotValidItem'
        end
        local prop = TryGetProp(cls, 'AccountProperty', 'None')
        local prop_2 = TryGetProp(cls, 'UpgradeAccountProperty', 'None')
        if prop == 'None' or prop_2 == 'None' then
            return 0, 'NotValidItem'
        end

        if TryGetProp(acc, prop_2, 0) == 2 then
            return 0
        end
    end
    
    return 1
end

function IS_VALID_CABINET_ITEM_ARK_OPEN(acc, type)
    local name = type    
    if name == nil then
        return 0, 'NotValidItem'
    end

    local cls = GetClass('cabinet_ark', name)
    if cls == nil then
        return 0, 'NotValidItem'
    end

    local prop = TryGetProp(cls, 'AccountProperty', 'None')    
    if prop == 'None' then
        return 0, 'NotValidItem'
    end

    if TryGetProp(acc, prop, 0) ~= 0 then
        return 0
    end
    
    return 1
end


function IS_VALID_ARK_LVUP_BY_SCROLL(ark, scroll)
    if TryGetProp(ark, 'CharacterBelonging', 0) ~= 1 then 
        return false, 'CanExecCuzCharacterBelonging'
    end

    if TryGetProp(ark, 'GroupName', 'None') ~= 'Ark' then
        return false, 'NotValidItem'
    end

    if TryGetProp(ark, 'StringArg2', 'None') ~= 'Made_Ark' then
        return false, 'NotValidItem'
    end
    
    local name = TryGetProp(ark, 'ClassName', 'None')
    if string.find(name, 'Event_Ark') ~= nil then
        return false, 'CantUseEventItem'
    end

    if TryGetProp(scroll, 'StringArg', 'None') ~= 'ArkLVUPScroll' then
        return false, 'NotValidItem'
    end

    local now_lv = TryGetProp(ark, 'ArkLevel', 1)    
    local goal_lv = TryGetProp(scroll, 'NumberArg1', 0)    
    if now_lv >= goal_lv then
        return false, 'ItemLevelIsGreaterThanMatItem'
    end

    return true
end