-- shared_event_new_season_server.lua

season_server_no_sell_item_list = {}

-- 20.08 여름 시즌서버
function IS_SEASON_SERVER(pc)
    local acc = nil
    if IsServerSection() == 1 and pc ~= nil then
        acc = GetAccountObj(pc)
    elseif IsServerSection() ~= 1 then
        acc = GetMyAccountObj()
    end

    if acc ~= nil then
        local marker = TryGetProp(acc, 'SeasonServerMarker', 'None')
        if marker == '2022-06-09' then
            return --[[ 'YES' ]]"NO";
        end
    end

    local groupid = GetServerGroupID();
    
    -- qa 1006, 스테이지 8001/8002
    if (GetServerNation() == "KOR" and (groupid == 1006 or groupid == 8002)) then
        return --[[ "YES" ]]"NO";
    end

    if (GetServerNation() == "KOR" and groupid == 3002) then
        return --[[ "YES" ]]"NO";
    end

    if (GetServerNation() == "GLOBAL" and (groupid == 10001 or groupid == 10003 or groupid == 10004 or groupid == 10005)) then
        return --[[ "YES" ]]"NO";
    end

    return "NO";
end

-- 시즌서버 출신?? 플레이어 체크시에 해당 함수를 사용할 것
function IS_SEASON_SERVER_PLAYER(pc)
    if pc ~= nil then
        local accObj = nil;
        if IsServerObj(pc) == 1 then
            accObj = GetAccountObj(pc);
        else
            accObj = GetMyAccountObj();
        end

        if accObj == nil then
            return "NO";
        end
        
        local value = TryGetProp(accObj, "EVENT_NEW_SEASON_SERVER_ACCOUNT", 0);     
        if value == GET_SEASON_SERVER_CHECK_PROP_VALUE() then
            return "YES";
        else
            return "NO";
        end
    end

    return 'NO'
end

function IS_SEASON_SERVER_OPEN()
    local now_time = date_time.get_lua_now_datetime_str();
    local end_time = "2020-08-06 06:00:00";
    
    return date_time.is_later_than(now_time, end_time);
end

function GET_SEASON_SERVER_CHECK_PROP_VALUE()
    if GetServerNation() == "KOR" then
        return 1;
    end

    if GetServerNation() == "GLOBAL" then
        return 2;
    end
end

function GET_SEASON_SERVER_OPEN_DATE()
    return '2022-06-09'
end

--[[
    스페셜 생성권 지급 기간 여부 및 지급 수량 체크용
    기존 계정의 경우 DB작업을 통해 일괄 지급 가능하지만
    신규 팀 생성시에는 DbBarrackNameSave.cpp 에서 이 스크립트를 통해 체크하여 지급한다.
]]
function GET_SPECIAL_CREATE_TICKET_INFO()
    local startTime = '2022-06-09 06:00:00'
    local endTime = '2022-07-28 05:59:59'
    local setCount = '1'

    return startTime, endTime, setCount
end

function IS_ABLE_SPECIAL_CREATE_TICKET(pc)
    if pc == nil then
        return false, nil
    end

    local accObj = nil
    local etcObj = nil
    if IsServerObj(pc) == 1 then
        accObj = GetAccountObj(pc)
        etcObj = GetETCObject(pc)
    else
        accObj = GetMyAccountObj()
        etcObj = GetMyEtcObject()
    end

    local ticket_count = TryGetProp(accObj, 'SPECIAL_CREATE_TICKET_COUNT', 0)
    if accObj == nil or ticket_count <= 0 then
        if etcObj == nil or TryGetProp(etcObj, 'SettingProgressState', 0) == 0 or TryGetProp(etcObj, 'SettingProgressState', 0) >= 5 then
            return false, 'HaveNoSpecialCreateTicket'
        end
    end

    -- 카운트가 1이면 기간제로 무상 제공
    -- 1보다 큰 양의 정수이면 아이템 사용해서 얻은 것
    if ticket_count == 1 then
        local startTime, endTime = GET_SPECIAL_CREATE_TICKET_INFO()
        local nowTime = date_time.get_lua_now_datetime_str()
        if IsServerSection() == 0 then
            local server_time = geTime.GetServerSystemTime()
            nowTime = date_time.lua_datetime_to_str(date_time.get_lua_datetime(server_time.wYear, server_time.wMonth, server_time.wDay, server_time.wHour, server_time.wMinute, server_time.wSecond))
        end
    
        if date_time.is_later_than(startTime, nowTime) == true or date_time.is_later_than(nowTime, endTime) == true then
            return false, 'SpecialCreateTicketExpired'
        end
    end

    return true
end

function SEASON_SERVER_MAX_LEVEL_UP_REWARD(self, tx, level)
    if GetServerNation() == 'KOR' and IS_SEASON_SERVER(self) == 'YES' and level == 470 then
        local acc = GetAccountObj(self)
        if TryGetProp(acc, 'SEASON_SERVER_2022_06_09', 0) == 0 then
            TxSetIESProp(tx, acc, 'SEASON_SERVER_2022_06_09', 1);
            TxGiveItem(tx, 'SeasonServerOpen_MaxLevel_Box', 1, 'LevelUp')
        end
    end
end

function costume_boss_map_check(map_name)
    local cls = GetClass('Map', map_name)
    if TryGetProp(cls, 'MapType', 'None') == "Field" and TryGetProp(cls, 'RewardEXPBM', 0)  > 0.1 then
        if TryGetProp(cls, 'QuestLevel', 0) >= 150 then            
            return true
        end
    end
    
    return false
end

function ep14_field_boss_map_check(map_name)
    if map_name == 'ep14_2_d_castle_3' then        
        return true
    else
        return false
    end
end

local check_map_name_list = nil
function make_check_map_name_list()
    if check_map_name_list ~= nil then
        return
    end

    check_map_name_list = {}
    check_map_name_list["f_siauliai_46_1"] = "(봄볕나무 숲,Spring Light Woods,春光の森)"
    check_map_name_list["f_siauliai_46_2"] = "(우키스 경작지,Uskis Arable Land,ウキス耕作地)"
    check_map_name_list["f_siauliai_46_3"] = "(빌나 숲,Vilna Forest,ビルナ森)"
    check_map_name_list["f_siauliai_46_4"] = "(다이나 양봉지,Dina Bee Farm,ダイナ養蜂地)"
    check_map_name_list["f_katyn_18"] = "(쿨레 고개,Kule Peak,クレー峠)"
    check_map_name_list["id_catacomb_02"] = "(발류스의 영면지,Valius' Eternal Resting Place,バリュスの永眠地)"
    check_map_name_list["id_catacomb_04"] = "(리티니스 지하묘,Underground Grave of Ritinis,リティニス地下墓地)"
    check_map_name_list["f_flash_58"] = "(딩고파실 지구,Dingofasil District,ディンゴパシル地区)"
    check_map_name_list["f_flash_59"] = "(베르크티 광장,Verkti Square,ベルクティ広場)"
    check_map_name_list["f_flash_60"] = "(록소나 장터,Roxona Marketplace,ルクソナ市場)"
    check_map_name_list["f_flash_61"] = "(루클리스 거리,Ruklys Street,ルクリス通り)"
    check_map_name_list["f_flash_63"] = "(중심시가,Downtown,中心市街地)"
    check_map_name_list["f_flash_64"] = "(내성곽지구,Inner Enceinte District,城郭内地区)"
    check_map_name_list["d_underfortress_65"] = "(대지의 요새 전초구역,Sentry Bailey,[大地の要塞]前哨区域)"
    check_map_name_list["d_underfortress_66"] = "(대지의 요새 대립의 훈련장,Drill Ground of Confliction,[大地の要塞]対立の訓練場)"
    check_map_name_list["d_underfortress_67"] = "(대지의 요새 거주구역,Resident Quarter,[大地の要塞]居住区域)"
    check_map_name_list["d_underfortress_68"] = "(대지의 요새 저장구역,Storage Quarter,[大地の要塞]保存区域)"
    check_map_name_list["d_underfortress_69"] = "(대지의 요새 결전지,Fortress Battlegrounds,大地の要塞の決戦地)"
    check_map_name_list["f_tableland_70"] = "(이브레 고원,Ibre Plateau,イヴレー高原)"
    check_map_name_list["f_tableland_71"] = "(마당 고원,Grand Yard Mesa,マダン高原)"
    check_map_name_list["f_tableland_72"] = "(스벤티마스 유형지,Sventimas Exile,スベンティマス流刑地)"
    check_map_name_list["f_tableland_73"] = "(카듀멜 절벽,Kadumel Cliff,カデュメルの絶壁)"
    check_map_name_list["f_tableland_74"] = "(강철 고원,Steel Heights,鋼鉄高原)"
    check_map_name_list["d_prison_78"] = "(칼레이마스 접견소,Kalejimas Visiting Room,[カレイマス]接見所)"
    check_map_name_list["d_prison_79"] = "(칼레이마스 보관실,Storage,[カレイマス]保管室)"
    check_map_name_list["d_prison_80"] = "(칼레이마스 독방구역,Solitary Cells,[カレイマス]独房区域)"
    check_map_name_list["d_prison_81"] = "(칼레이마스 작업장,Workshop,[カレイマス]作業場)"
    check_map_name_list["d_prison_82"] = "(칼레이마스 심문실,Investigation Room,[カレイマス]尋問室)"
    check_map_name_list["f_3cmlake_85"] = "(바린웰 85수역,Barynwell 85 Waters,バリンウェル85水域)"
    check_map_name_list["f_3cmlake_86"] = "(바린웰 86수역,Barynwell 86 Waters,バリンウェル86水域)"
    check_map_name_list["f_3cmlake_87"] = "(바린웰 87수역,Barynwell 87 Waters,バリンウェル87水域)"
    check_map_name_list["d_startower_88"] = "(별의 탑 1층,Astral Tower 1F,星の塔 1階)"
    check_map_name_list["d_startower_89"] = "(별의 탑 4층,Astral Tower 4F,星の塔 4階)"
    check_map_name_list["d_startower_90"] = "(별의 탑 12층,Astral Tower 12F,星の塔 12階)"
    check_map_name_list["d_startower_91"] = "(별의 탑 20층,Astral Tower 20F,星の塔 20階)"
    check_map_name_list["d_startower_92"] = "(별의 탑 21층,Astral Tower 21F,星の塔 21階)"
    check_map_name_list["f_dcapital_103"] = "(타니엘 1세 기념구,Taniel I Commemorative Orb,タニエル1世の記念区)"
    check_map_name_list["f_dcapital_105"] = "(발티넬 기념구,Baltinel Memorial,ヴァルティネ記念区)"
    check_map_name_list["f_dcapital_106"] = "(글리헬 기념구,Gliehel Memorial,グリヘル記念区)"
    check_map_name_list["f_dcapital_107"] = "(프리넬 기념구,Frienel Memorial,プリネル記念区)"
    check_map_name_list["f_katyn_45_1"] = "(그리나스 숲길,Grynas Trails,グリナス森の道)"
    check_map_name_list["f_katyn_45_2"] = "(그리나스 수련장,Grynas Training Camp,グリナス修練場)"
    check_map_name_list["f_katyn_45_3"] = "(그리나스 구릉지,Grynas Hills,グリナス丘陵地)"
    check_map_name_list["f_whitetrees_23_1"] = "(에메트 숲,Emmet Forest,エメット森)"
    check_map_name_list["f_maple_23_2"] = "(피스티스 숲,Pystis Forest,ピスティス森)"
    check_map_name_list["f_whitetrees_23_3"] = "(실라 숲,Syla Forest,シーラ森)"
    check_map_name_list["f_tableland_28_1"] = "(메사파슬라,Mesafasla,メサパスラ)"
    check_map_name_list["f_tableland_28_2"] = "(스토가스 고원,Stogas Plateau,ストーガス高原)"
    check_map_name_list["f_farm_49_2"] = "(샤튼 농장,Shaton Farm,シャトン農場)"
    check_map_name_list["f_farm_49_3"] = "(샤튼 저수구역,Shaton Reservoir,シャトン貯水区域)"
    check_map_name_list["f_pilgrimroad_41_1"] = "(타우마스 숲길,Thaumas Trail,タウマスの林道)"
    check_map_name_list["f_pilgrimroad_41_2"] = "(살비야스 숲,Salvia Forest,サルビヤスの森)"
    check_map_name_list["f_pilgrimroad_41_3"] = "(래스보이 호숫가,Rasvoy Lake,レスボーイ湖のほとり)"
    check_map_name_list["f_pilgrimroad_41_4"] = "(섹타 숲,Sekta Forest,セクターの森)"
    check_map_name_list["f_pilgrimroad_41_5"] = "(오아쓰 기념지,Oasseu Memorial,オアス記念地)"
    check_map_name_list["d_abbey_41_6"] = "(메이번 대수도원,Maven Abbey,メイバーン大修道院)"
    check_map_name_list["d_thorn_39_1"] = "(빌티스 숲,Viltis Forest,ビルティスの森)"
    check_map_name_list["d_thorn_39_2"] = "(글라데 언덕길,Glade Hillroad,グラデ丘の道)"
    check_map_name_list["d_thorn_39_3"] = "(라우키메 저습지,Laukyme Swamp,ラウキメ低湿地)"
    check_map_name_list["d_abbey_39_4"] = "(틸라 수도원,Tyla Monastery,ティルラ修道院)"
    check_map_name_list["f_remains_37_1"] = "(누오로딘 폭포,Nuoridin Falls,ヌオルディンの滝)"
    check_map_name_list["f_remains_37_2"] = "(나뮤 사원터,Namu Temple,ナミュー寺院跡)"
    check_map_name_list["f_remains_37_3"] = "(이스토라 유적지,Istora Ruins,イストラ遺跡)"
    check_map_name_list["f_castle_20_4"] = "(도심성벽 제 8구역,City Wall District 8,都心城壁・第8区域)"
    check_map_name_list["f_dcapital_20_5"] = "(제로멜 공원,Jeromel Park ,ジェロメル公園)"
    check_map_name_list["f_dcapital_20_6"] = "(요나엘 기념구,Jonael Memorial,ヨナエル記念区)"
    check_map_name_list["f_whitetrees_21_1"] = "(유데이안 숲,Yudejan Forest,ユデイアンの森)"
    check_map_name_list["f_whitetrees_21_2"] = "(노브리어 숲,Nobreer Forest,ノブリアの森)"
    check_map_name_list["f_whitetrees_22_1"] = "(테레쉬 숲,Teresh Forest,テレシュの森)"
    check_map_name_list["f_whitetrees_22_2"] = "(테켈 피난지,Tekel Shelter,テケル避難地)"
    check_map_name_list["f_whitetrees_22_3"] = "(이졸라챠 고원,Izoliacjia Plateau,イゾラーチャ高原)"
    check_map_name_list["d_abbey_22_4"] = "(나르바스 사원,Narvas Temple,ナルバス寺院)"
    check_map_name_list["d_abbey_22_5"] = "(나르바스 사원 별관,Narvas Temple Annex,ナルバス寺院別館)"
    check_map_name_list["d_fantasylibrary_48_1"] = "(사우시스 9관,Sausis Room 9,サウシス9館)"
    check_map_name_list["d_fantasylibrary_48_2"] = "(사우시스 10관,Sausis Room 10,サウシス10館)"
    check_map_name_list["d_fantasylibrary_48_3"] = "(발란디스 2관,Valandis Room 2,バランディス2館)"
    check_map_name_list["d_fantasylibrary_48_4"] = "(발란디스 3관,Valandis Room 3,バランディス3館)"
    check_map_name_list["d_fantasylibrary_48_5"] = "(발란디스 91관,Valandis Room 91,バランディス91館)"
    check_map_name_list["f_maple_25_1"] = "(네토 숲,Nheto Forest,ネルト森)"
    check_map_name_list["f_maple_25_2"] = "(스팔빈가스 숲,Svalphinghas Forest,スパルガス森)"
    check_map_name_list["f_maple_25_3"] = "(라다르 숲,Lhadar Forest,ラダル森)"
    check_map_name_list["id_catacomb_25_4"] = "(티메리스 사원,Timerys Temple,ティメリス寺院)"
    check_map_name_list["f_flash_29_1"] = "(연안요새,Coastal Fortress,沿岸要塞)"
    check_map_name_list["f_coral_32_1"] = "(크란토 연안,Cranto Coast,クラント沿岸)"
    check_map_name_list["f_coral_32_2"] = "(이기티 연안,Igti Coast,イギティ沿岸)"
    check_map_name_list["f_orchard_34_1"] = "(알레멧 숲,Alemeth Forest,アレメテの森)"
    check_map_name_list["f_orchard_34_3"] = "(바르하 숲,Barha Forest,バルハの森)"
    check_map_name_list["f_siauliai_35_1"] = "(나하스 숲,Nahash Forest,ナハスの森)"
    check_map_name_list["f_coral_35_2"] = "(베라 연안,Vera Coast,ベーラ沿岸)"
    check_map_name_list["d_abbey_35_3"] = "(엘고스 수도원 별관,Elgos Monastery Annex,エルゴス修道院別館)"
    check_map_name_list["d_abbey_35_4"] = "(엘고스 수도원 본원,Elgos Monastery Main Building,エルゴス修道院本院)"
    check_map_name_list["id_catacomb_38_1"] = "(바이덴티스 신당,Videntis Shrine,バイデンティス神堂)"
    check_map_name_list["id_catacomb_38_2"] = "(모크슬 묘실,Mokusul Chamber,モクスルの墓室)"
    check_map_name_list["f_coral_44_1"] = "(제테오 해안,Zeteor Coast,ゼテオの岸)"
    check_map_name_list["f_coral_44_2"] = "(아이테오 해안,Iotheo Coast,アイテオの岸)"
    check_map_name_list["f_coral_44_3"] = "(에페로타오 해안,Eperotao Coast,アペロタオの岸)"
    check_map_name_list["d_limestonecave_52_1"] = "(테브린 종유동 1구역,Tevhrin Stalactite Cave Section 1,テブリン鍾乳洞1区域)"
    check_map_name_list["d_limestonecave_52_2"] = "(테브린 종유동 2구역,Tevhrin Stalactite Cave Section 2,テブリン鍾乳洞2区域)"
    check_map_name_list["d_limestonecave_52_3"] = "(테브린 종유동 3구역,Tevhrin Stalactite Cave Section 3,テブリン鍾乳洞3区域)"
    check_map_name_list["d_limestonecave_52_4"] = "(테브린 종유동 4구역,Tevhrin Stalactite Cave Section 4,テブリン鍾乳洞4区域)"
    check_map_name_list["d_limestonecave_52_5"] = "(테브린 종유동 5구역,Tevhrin Stalactite Cave Section 5,テブリン鍾乳洞5区域)"
    check_map_name_list["d_velniasprison_51_1"] = "(마족수감소 1구역,Demon Prison District 1,魔族収監所 第1区域)"
    check_map_name_list["d_velniasprison_51_2"] = "(마족수감소 2구역,Demon Prison District 2,魔族収監所 第2区域)"
    check_map_name_list["d_velniasprison_51_3"] = "(마족수감소 4구역,Demon Prison District 4,魔族収監所 第4区域)"
    check_map_name_list["d_velniasprison_51_4"] = "(마족수감소 3구역,Demon Prison District 3,魔族収監所 第3区域)"
    check_map_name_list["d_velniasprison_51_5"] = "(마족수감소 5구역,Demon Prison District 5,魔族収監所 第5区域)"
    check_map_name_list["d_limestonecave_55_1"] = "(알렘빅 동굴,Alembique Cave,アレンビック洞窟)"
    check_map_name_list["f_bracken_43_1"] = "(아르커스 숲,Arcus Forest,アルコス森)"
    check_map_name_list["f_bracken_43_2"] = "(파마르 숲,Phamer Forest,パマル森)"
    check_map_name_list["f_bracken_43_3"] = "(지부리나스 숲,Ziburynas Forest,ジブリナス森)"
    check_map_name_list["f_bracken_43_4"] = "(몰로게오 숲,Mollogheo Forest,モロゲオ森)"
    check_map_name_list["f_farm_47_1"] = "(테넌츠 농장,Tenants' Farm,テナンツ農場)"
    check_map_name_list["f_farm_47_2"] = "(수로교 지역,Aqueduct Bridge Area,水路橋地域)"
    check_map_name_list["f_tableland_11_1"] = "(베다 고원,Vedas Plateau,ベダ高原)"
    check_map_name_list["f_3cmlake_26_1"] = "(란코 26수역,Lanko 26 Waters,ランコ水域・第26区)"
    check_map_name_list["f_3cmlake_26_2"] = "(란코 22수역,Lanko 22 Waters,ランコ水域・第22区)"
    check_map_name_list["d_firetower_69_1"] = "(지마 수코트,Zima Suecourt,ジーマ・スコット)"
    check_map_name_list["f_nicopolis_81_1"] = "(스타리 타운,Starry Town,スタリータウン)"
    check_map_name_list["f_nicopolis_81_2"] = "(펠라인 포스트 타운,Feline Post Town,フェラインポストタウン)"
    check_map_name_list["f_nicopolis_81_3"] = "(스펠토움 타운,Spell Tome Town,スフェルトウムタウン)"    
end

make_check_map_name_list()

function get_check_map_name_list(class_name)
    return check_map_name_list[class_name]
end

function pc_monster_map_check(map_name)
    local cls = GetClass('Map', map_name)
    if TryGetProp(cls, 'MapType', 'None') == "Field" and TryGetProp(cls, 'RewardEXPBM', 0)  > 0.1 then
        if TryGetProp(cls, 'QuestLevel', 0) >= 150 then            
            return true
        end
    end
    
    return false
end