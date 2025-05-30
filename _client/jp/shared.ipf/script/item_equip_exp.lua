﻿-- item_equip_exp.lua

-- cpp로 이전됨, 사용하지 않음
function GET_MORE_EXP_BOOST_TOKEN(pc)
	local sumExp = 0.0;
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Premium_boostToken');	-- 경험의 서 경험치
	for i = 1, 20 do
		local name = string.format('Premium_boostToken%02d', i)
		sumExp = sumExp + IsBuffAppliedEXP(pc, name);	-- 경험의서 버프 적용
	end	
	return sumExp;
end

function GET_MORE_LEGEND_EXP_UP_CARD(pc)
	local sumExp = 0.0;
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'CARD_ExpUP_LV1');	-- 레전드 카드 ---	
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'CARD_ExpUP_LV2');	-- 레전드 카드 ---
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'CARD_ExpUP_LV3');	-- 레전드 카드 ---
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'CARD_ExpUP_LV4');	-- 레전드 카드 ---
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'CARD_ExpUP_LV5');	-- 레전드 카드 ---
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'CARD_ExpUP_LV6');	-- 레전드 카드 ---
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'CARD_ExpUP_LV7');	-- 레전드 카드 ---
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'CARD_ExpUP_LV8');	-- 레전드 카드 ---
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'CARD_ExpUP_LV9');	-- 레전드 카드 ---
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'CARD_ExpUP_LV10');	-- 레전드 카드 ---
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'CARD_ExpUP_bayl_LV1');	
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'CARD_ExpUP_bayl_LV2');
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'CARD_ExpUP_bayl_LV3');
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'CARD_ExpUP_bayl_LV4');
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'CARD_ExpUP_bayl_LV5');
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'CARD_ExpUP_bayl_LV6');
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'CARD_ExpUP_bayl_LV7');
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'CARD_ExpUP_bayl_LV8');
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'CARD_ExpUP_bayl_LV9');
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'CARD_ExpUP_bayl_LV10');
	return sumExp;
end

function GET_MORE_EVENT_EXP(pc)
	local sumExp = 0.0;
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_LargeSongPyeon');	-- 대왕송편
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_Largehoney_Songpyeon'); -- 대왕꿀송편
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_161110_candy'); -- 대왕꿀송편
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_161215_1'); -- 축복이 깃든 새싹 1단계
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_161215_2'); -- 축복이 깃든 새싹 2단계
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_161215_3'); -- 축복이 깃든 새싹 3단계
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_161215_4'); -- 축복이 깃든 새싹 4단계
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_161215_5'); -- 축복이 깃든 새싹 5단계
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Premium_Fortunecookie_1'); -- 포춘 쿠키 1단계
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Premium_Fortunecookie_2'); -- 포춘 쿠키 2단계
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Premium_Fortunecookie_3'); -- 포춘 쿠키 3단계
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Premium_Fortunecookie_4'); -- 포춘 쿠키 4단계
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Premium_Fortunecookie_5'); -- 포춘 쿠키 5단계
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_Rice_Soup');	-- 떡국
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_LargeRice_Soup');	-- 특대 떡국
    sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_WhiteDay_Buff');	-- 화이트데이
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_FireSongPyeon'); --폭죽 버프
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_Steam_Base_Buff'); --해외 버프
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_Nru_Buff_Item'); --해외 신규 유저 이벤트
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_7Day_Exp_1'); --출석 체크
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_7Day_Exp_2'); --출석 체크
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_7Day_Exp_3'); --출석 체크
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_7Day_Exp_4'); --출석 체크
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_7Day_Exp_5'); --출석 체크
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_7Day_Exp_6'); --출석 체크
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_Steam_Happy_New_Year'); --해외 신년 이벤트	
    sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_Goddess');	-- 여신의 조각상
    sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_RedOrb_GM');	-- 이벤트 참여
    sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_WeddingCake'); -- 웨딩 케잌
    sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_Steam_Wedding'); --스팀 웨딩 이벤트
    sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_1706_FREE_EXPUP'); --이런 이벤트
    sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_1712_SECOND_BUFF'); --2주년 기념수의 축복
    sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_1712_XMAS_FIRE'); --크리스마스 폭죽 이벤트
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_1802_CHOCO_BUFF1'); --발렌타인 초콜릿
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_1802_CHOCO_BUFF2'); --발렌타인 초콜릿
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_1802_CHOCO_BUFF3'); --발렌타인 초콜릿
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_1802_CHOCO_BUFF4'); --발렌타인 초콜릿
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_1802_CHOCO_BUFF5'); --발렌타인 초콜릿
    sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_1802_weekend'); --3월 주말 이벤트
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_1804_ARBOR_BUFF_7'); --2018년 식목일 이벤트
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_1805_CHILDREN'); --2018년 트린이날 폭죽 이벤트
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_1805_WEEKEND_BUFF'); --EVENT_1805_WEEKEND
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_1805_NEWUSER_BUFF_1'); --너, 내 동료가 돼라 이벤트 1
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_1805_NEWUSER_BUFF_2'); --너, 내 동료가 돼라 이벤트 2
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_1807_POOL_TABLE_BUFF'); --[Summer Festa] 휴식
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_1807_BALL_CRACKER'); --[Summer Festa] 폭죽
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_1807_WEEKEND_BUFF_1'); --[For 10] 경험치 버닝
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_1810_FALL_LEAF_BUFF4'); --ENTER_EVENT_1810_FALL_LEAF
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_1810_GUILD_EXPUP'); --길드 있어 트오세 있다 시즌2
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_ThanksgivingDay'); --붉은 씨앗
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'BaseCamp_Buff'); --베이스 캠프
--	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_1902_WEEKEND_BUFF_1'); --EVENT_1902_WEEKEND
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'GuildColony_Attendance_Reward_EXP_Buff_1'); --콜로니전  참여 보상 1단계
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'GuildColony_Attendance_Reward_EXP_Buff_2'); --콜로니전  참여 보상 2단계
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'GuildColony_Attendance_Reward_EXP_Buff_3'); --콜로니전  참여 보상 3단계
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'GuildColony_Attendance_Reward_EXP_Buff_4'); --콜로니전  참여 보상 4단계
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'GuildColony_Attendance_Reward_EXP_Buff_5'); --콜로니전  참여 보상 5단계
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_Steam_Carnival_Fire_2'); --스팀 카니발 불꽃축제 이벤트 --
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_ep11_Expup'); --자라나라 나무나무 주말 앤 버닝 이벤트 -- --EVENT_1903_WEEKEND
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_ep11_Expup_base'); --자라나라 나무나무 주말 앤 버닝 이벤트 --
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_Monster_EXP_UP'); --해외 페이스북 컴패니언 이벤트
--	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT1909_FULLMOON_BUFF_EXP_1'); --[보름달 키우기 대작전] 경험치 획득량 증가 1단계
--	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT1909_FULLMOON_BUFF_EXP_2'); --[보름달 키우기 대작전] 경험치 획득량 증가 2단계
--	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT1909_FULLMOON_BUFF_EXP_3'); --[보름달 키우기 대작전] 경험치 획득량 증가 3단계
--	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT1909_FULLMOON_BUFF_EXP_4'); --[보름달 키우기 대작전] 경험치 획득량 증가 4단계
--	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT1909_FULLMOON_BUFF_EXP_5'); --[보름달 키우기 대작전] 경험치 획득량 증가 5단계
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_Expup_50'); --burning_event
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_Expup_100'); --burning_event
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_Expup_100_vertigo'); --vertigo exp_event
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'STM_PIZZA_BUFF'); --피자
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'NEWUSER_PARTY_BUFF') -- 신규/복귀 유저 파티 버프
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2002_CHOCO_BUFF1'); -- 더 달콤한 발렌타인 초콜릿 1단계
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2002_CHOCO_BUFF2'); -- 더 달콤한 발렌타인 초콜릿 2단계
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2002_CHOCO_BUFF3'); -- 더 달콤한 발렌타인 초콜릿 3단계
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2002_CHOCO_BUFF4'); -- 더 달콤한 발렌타인 초콜릿 4단계
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2002_CHOCO_BUFF5'); -- 더 달콤한 발렌타인 초콜릿 5단계
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2002_FISHING_CAT_BUFF'); -- 2002 낚시 이벤트 고양이 버프
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_Steam_New_World_Buff'); -- 스팀 시즌 서버 혜택
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_SEASON_NEWWRORLD_PASSIVE_2'); -- 2002 [이벤트] 유대감
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2004_FRUIT_BUFF1'); -- 축복받은 열매 1단계
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2004_FRUIT_BUFF2'); -- 축복받은 열매 2단계
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2004_FRUIT_BUFF3'); -- 축복받은 열매 3단계
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2004_FRUIT_BUFF4'); -- 축복받은 열매 4단계
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2004_FRUIT_BUFF5'); -- 축복받은 열매 5단계
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_1905_TOS_CHIILD_BUFF1'); --자라나라 나무나무 성장 버프 --
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2006_SUMMER_brochette'); -- 여름 이벤트 맛있는 꼬치 경험치 증가 5% --
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2006_SUMMER_mojito'); -- 여름 이벤트 짜릿한 레몬아이스티 경험치 증가 5% --
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2006_SUMMER_coconut'); -- 여름 이벤트 시원한 코코넛주스 경험치 증가 5% --
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2006_SUMMER_bingsu'); -- 여름 이벤트 달달한 과일빙 경험치 증가 5%수 --
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2006_SUMMER_softice'); -- 여름 이벤트 부드러운 소프트아이스크림 경험치 증가 5% --
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2006_SUMMER_EXPUP_brochette'); -- 여름 이벤트 맛있는 꼬치 경험치 증가 30% --
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2006_SUMMER_EXPUP_mojito'); -- 여름 이벤트 짜릿한 레몬아이스티 경험치 증가 30% --
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2006_SUMMER_EXPUP_coconut'); -- 여름 이벤트 시원한 코코넛주스 경험치 증가 30% --
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2006_SUMMER_EXPUP_bingsu'); -- 여름 이벤트 달달한 과일빙수 경험치 증가 30% --
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2006_SUMMER_EXPUP_softice'); -- 여름 이벤트 부드러운 소프트아이스크림 경험치 증가 30% --
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2008_OBON_FULLMOON_BUFF'); -- jpn 추석 이벤트 보름달 버프
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2006_SWEET_ZONGZI_1'); -- 2006 단쫑즈 1단계 --
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2006_SWEET_ZONGZI_2'); -- 2006 단쫑즈 2단계 --
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2006_SWEET_ZONGZI_3'); -- 2006 단쫑즈 3단계 --
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2006_SWEET_ZONGZI_4'); -- 2006 단쫑즈 4단계 --
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2006_SWEET_ZONGZI_5'); -- 2006 단쫑즈 5단계 --
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2006_SALTY_ZONGZI'); -- 2006 짠쫑즈 --
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_Kor_New_World_Buff'); -- 스팀 시즌 서버 혜택
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2008_OBON_FULLMOON_BUFF'); -- jpn 추석 이벤트 보름달 버프
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2011_1YEAR_JPN_BUFF'); -- JPN 1주년 버프
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2011_STM_HARVEST_BUFF'); -- STM 수확제 이벤트
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2101_NEW_YEAR_JPN_BUFF'); -- JPN 2021신년 버프
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2012_FRUIT_BUFF'); -- EP13 경험의 열매 이벤트 버프
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2012_EXP_BUFF'); -- EP13 이벤트 성장 지원 버프
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'event_RiceCake_Buff_1'); -- 가레떡 1단계 이벤트 버프
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'event_RiceCake_Buff_2'); -- 가레떡 2단계 이벤트 버프
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'event_RiceCake_Buff_3'); -- 가레떡 3단계 이벤트 버프
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'event_RiceCake_Buff_4'); -- 가레떡 4단계 이벤트 버프
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'event_RiceCake_Buff_5'); -- 가레떡 5단계 이벤트 버프
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_LuckyBreak_Add_Exp_1'); -- 럭키브레이크 성장 경험치 증가 1
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_LuckyBreak_Add_Exp_2'); -- 럭키브레이크 성장 경험치 증가 2
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Event_LuckyBreak_Add_Exp_3'); -- 럭키브레이크 성장 경험치 증가 3
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2107_APPLE_BUFF'); -- NEXT_이벤트1
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2107_APPLE_GOLD_BUFF'); -- NEXT_이벤트2
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Premium_Valentine_1'); -- 발렌타인 초코 1단계
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Premium_Valentine_2'); -- 발렌타인 초코 2단계
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Premium_Valentine_3'); -- 발렌타인 초코 3단계
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Premium_Valentine_4'); -- 발렌타인 초코 4단계
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Premium_Valentine_5'); -- 발렌타인 초코 5단계
	-- sumExp = sumExp + IsBuffAppliedEXP(pc, 'pet_mermaidpopo_buff'); -- 머메이드 포포
	-- sumExp = sumExp + IsBuffAppliedEXP(pc, 'pet_mermaidpopo2_buff'); -- 머맨 포포
	-- sumExp = sumExp + IsBuffAppliedEXP(pc, 'sticky_wild_honey'); -- 끈적끈적 야생 꿀

	sumExp = sumExp + IsBuffAppliedEXP(pc, 'EVENT_2102_STATUE_BUFF'); -- STM 딥디르비와 여신상 버프
	if  TryGetProp(pc, 'Lv', 0) < 450 then
	    sumExp = sumExp + IsBuffAppliedEXP(pc, 'ITEM_BUFF_2020ArborDay_ExpUP'); --2020 근본--
	end
	if  TryGetProp(pc, 'Lv', 0) < 460 then
	    sumExp = sumExp + IsBuffAppliedEXP(pc, 'ITEM_BUFF_2021ArborDay_ExpUP'); --2021 근본--
	end
	if  TryGetProp(pc, 'Lv', 0) < PC_MAX_LEVEL then
	    sumExp = sumExp + IsBuffAppliedEXP(pc, 'pet_sparrow_thanksgivng_buff'); --달맞이 참새 동행 버프--
	end

	if  TryGetProp(pc, 'Lv', 0) < PC_MAX_LEVEL then
	    sumExp = sumExp + IsBuffAppliedEXP(pc, 'pet_winter_rabbit_buff'); --하얀 눈 토끼 동행 버프--
	end

	if  TryGetProp(pc, 'Lv', 0) < PC_MAX_LEVEL then
	    sumExp = sumExp + IsBuffAppliedEXP(pc, 'pet_arborday_rabbit_buff'); -- 근본 토끼 동행 버프--
	end
	
	if  TryGetProp(pc, 'Lv', 0) < PC_MAX_LEVEL then
	    sumExp = sumExp + IsBuffAppliedEXP(pc, 'pet_twnpanda_buff'); -- 판다 동행 버프--
	end

	if  TryGetProp(pc, 'Lv', 0) < 460 then
	    sumExp = sumExp + IsBuffAppliedEXP(pc, 'premium_seal_2021_buff'); -- 2021 근본 인장 버프--
	end

	if TryGetProp(pc, 'Lv', 0) >= 450 and TryGetProp(pc, 'Lv', 0) < 460 then
		sumExp = sumExp + 6
	end

	if IS_SEASON_SERVER(pc) == 'YES' then
		sumExp = sumExp + 12
	end

	sumExp = sumExp + IsBuffAppliedEXP(pc, 'ExpUpGuildEvent'); 	

	return sumExp; 
end

function GET_MORE_ANCIENT_EXP(pc)
	local sumExp = 0.0;
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Ancient_boostToken');
	
	if IsBuffApplied(pc, 'Ancient_boostToken_vertigo') == 'YES' then
		if GetClassString('Map', GetZoneName(pc), 'MapType') == 'Field' then
			sumExp = sumExp + IsBuffAppliedEXP(pc, 'Ancient_boostToken_vertigo');
		end
	end
	
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Ancient_boostToken_150');
	sumExp = sumExp + IsBuffAppliedEXP(pc, 'Ancient_boostToken_200');
	
	
	if IsBuffApplied(pc, "pet_sparrow_thanksgivng_buff") == "YES" then
	    sumExp = sumExp + 1
	end
    
    if IsBuffApplied(pc, "pet_winter_rabbit_buff") == "YES" then
	    sumExp = sumExp + 1
	end
    
    if IsBuffApplied(pc, "pet_twnpanda_buff") == "YES" then
	    sumExp = sumExp + 1
	end
    
	return sumExp;
end

-- cpp로 이전됨, 더 이상 사용하지 않음
function GET_MORE_EVENT_EXP_JAEDDURY(pc)
	local sumExp = 0.0;
	if "YES" == IsBuffApplied(pc, 'Event_CharExpRate') then
		local etc = GetETCObject(pc);
		local rate = TryGetProp(etc, "EventCharExpRate");
		if rate ~= nil and rate > 0 then
			sumExp = sumExp + rate;
		end		
	end	
	return sumExp; 
end

-- 아이템의 exp 를 설정 ItemExp
function GET_MIX_MATERIAL_EXP(item)
	if item.EquipXpGroup == "None" then
		return 0;
	end

	local prop = geItemTable.GetProp(item.ClassID);
	local itemExp = TryGetProp(item, 'ItemExp')
	
	if itemExp ~= nil then
	    if item.ItemType == "Equip" then
	        return item.UseLv;
	    elseif item.EquipXpGroup == 'hethran_material' then
			return itemExp;
		elseif item.EquipXpGroup =='Gem' and itemExp > 0 then
    	    return itemExp;
	    end

		return prop:GetMaterialExp(itemExp);
	end
	
	return 0;
end

function GET_ITEM_LEVEL(item)
	local expValue = TryGetProp(item, "ItemExp", 0);
	if expValue == nil then
		return 0;
	end
    local ClassID = TryGetProp(item, 'ClassID', 0)
	local prop = geItemTable.GetProp(ClassID);
	local itemExp = TryGetProp(item, 'ItemExp');
	return prop:GetLevel(itemExp);

end

function GET_ITEM_MAX_LEVEL(item)
	local prop = geItemTable.GetProp(item.ClassID);	
	return prop:GetMaxLevel();
end

function GET_ITEM_PREV_LEVEL(item, Exp)
	
	if Exp == nil then
		Exp = item.ItemExp;
	end

	local prop = geItemTable.GetProp(item.ClassID);	
	local lv = prop:GetPrevByExp(Exp); 

	return lv;
end


function GET_ITEM_LEVEL_EXP(item, itemExp)

	if itemExp == nil then
		itemExp = item.ItemExp;
	end

	local prop = geItemTable.GetProp(item.ClassID);
	local lv = prop:GetLevel(itemExp);
	local curExp = prop:GetCurExp(itemExp);
	local maxExp = prop:GetMaxExp(itemExp);
	return lv, curExp, maxExp;

end

function GET_ITEM_LEVEL_EXP_BYCLASSID(ClassID, itemExp)
	local prop = geItemTable.GetProp(ClassID);
	local lv = prop:GetLevel(itemExp);
	local curExp = prop:GetCurExp(itemExp);
	local maxExp = prop:GetMaxExp(itemExp);
	return lv, curExp, maxExp;

end


function IS_ITEM_UPGRADABLE(item)

	local prop = geItemTable.GetProp(item.ClassID);
	if prop:Upgradable() == false then
		return false;
	end

	local curLevel = GET_ITEM_LEVEL(item);
	if curLevel >= prop:GetMaxLevel() and prop:GetMaxLevel() > 0 then
		return true;
	end

	return false;

end

function GET_MATERIAL_PRICE(item)

	local prop = geItemTable.GetProp(item.ClassID);
	local lv = prop:GetExpInfo(item.ItemExp);
	if lv == nil then
		return item.MaterialPrice;
	end

	return lv.priceMultiple * item.MaterialPrice

end

function GET_ITEM_EXP_BY_LEVEL(item, level)

	local prop = geItemTable.GetProp(item.ClassID);
	local lv = prop:GetExpInfoByLevel(level);
	if lv == nil then
		return 0;
	end

	return lv.totalExp;


end

function GET_WEAPON_PARAM_LIST(item, list)

	local prop = geItemTable.GetProp(item.ClassID);
	local cnt = prop:GetExpPropCount();
	list[1] = "Level";
	for i = 0 , cnt - 1 do
		list[i+2] = prop:GetExPropByIndex(i);
	end

end

-- 일반 경험의 서
function SCR_BUFF_ENTER_Premium_boostToken(self, buff, arg1, arg2, over)
	local id = TryGetProp(buff, 'ClassID', 0)
	if id > 0 then
		local cls = GetClassByType('Buff', id)
		if cls ~= nil then
			local rate = TryGetProp(cls, 'BuffExpUP', 0)
			local before = GetExProp(self, 'Premium_boostToken_rate')
			SetExProp(self, 'Premium_boostToken_rate', before + rate)
		end

		self.RSta_BM = self.RSta_BM + 500;
	end
end
function SCR_BUFF_LEAVE_Premium_boostToken(self, buff, arg1, arg2, over)
	local id = TryGetProp(buff, 'ClassID', 0)
	if id > 0 then
		local cls = GetClassByType('Buff', id)
		if cls ~= nil then
			local rate = TryGetProp(cls, 'BuffExpUP', 0)
			local before = GetExProp(self, 'Premium_boostToken_rate')
			local after = before - rate
			if after < 0 then
				after = 0
			end
			SetExProp(self, 'Premium_boostToken_rate', after)
		end

    	self.RSta_BM = self.RSta_BM - 500;
		
    	if GetBuffRemainTime(buff) <= 0 then
    	    SendSysMsg(self, "Premium_boostToken_EndMsg");
    	    PremiumItemMongoLog(self, "BoostToken", "End", 0);        
    	end
	end
end

-- 4배
function SCR_BUFF_ENTER_Premium_boostToken02(self, buff, arg1, arg2, over)
	local id = TryGetProp(buff, 'ClassID', 0)
	if id > 0 then
		local cls = GetClassByType('Buff', id)
		if cls ~= nil then
			local rate = TryGetProp(cls, 'BuffExpUP', 0)
			local before = GetExProp(self, 'Premium_boostToken_rate')
			SetExProp(self, 'Premium_boostToken_rate', before + rate)
		end

		self.RSta_BM = self.RSta_BM + 2000;
	end
end
function SCR_BUFF_LEAVE_Premium_boostToken02(self, buff, arg1, arg2, over)
	local id = TryGetProp(buff, 'ClassID', 0)
	if id > 0 then
		local cls = GetClassByType('Buff', id)
		if cls ~= nil then
			local rate = TryGetProp(cls, 'BuffExpUP', 0)
			local before = GetExProp(self, 'Premium_boostToken_rate')
			local after = before - rate
			if after < 0 then
				after = 0
			end
			SetExProp(self, 'Premium_boostToken_rate', after)
		end

    	self.RSta_BM = self.RSta_BM - 2000;
		
    	if GetBuffRemainTime(buff) <= 0 then
    	    SendSysMsg(self, "Premium_boostToken_EndMsg");
    	    PremiumItemMongoLog(self, "BoostToken", "End", 0);
    	    ReqConsumePremiumBuff(self, 'Premium_boostToken02', 5);
    	end
	end
end

-- 8배
function SCR_BUFF_ENTER_Premium_boostToken03(self, buff, arg1, arg2, over)
	local id = TryGetProp(buff, 'ClassID', 0)
	if id > 0 then
		local cls = GetClassByType('Buff', id)
		if cls ~= nil then
			local rate = TryGetProp(cls, 'BuffExpUP', 0)
			local before = GetExProp(self, 'Premium_boostToken_rate')
			SetExProp(self, 'Premium_boostToken_rate', before + rate)
		end

		self.RSta_BM = self.RSta_BM + 4000;
	end
end
function SCR_BUFF_LEAVE_Premium_boostToken03(self, buff, arg1, arg2, over)
	local id = TryGetProp(buff, 'ClassID', 0)
	if id > 0 then
		local cls = GetClassByType('Buff', id)
		if cls ~= nil then
			local rate = TryGetProp(cls, 'BuffExpUP', 0)
			local before = GetExProp(self, 'Premium_boostToken_rate')
			local after = before - rate
			if after < 0 then
				after = 0
			end
			SetExProp(self, 'Premium_boostToken_rate', after)
		end
		 
		self.RSta_BM = self.RSta_BM - 4000;

		if buff ~= nil and GetBuffRemainTime(buff) <= 0 then    
			SendSysMsg(self, "Premium_boostToken_EndMsg");
			PremiumItemMongoLog(self, "BoostToken", "End", 0);
			ReqConsumePremiumBuff(self, 'Premium_boostToken03', 5);
		end
	end
end

function SCR_BUFF_ENTER_Premium_boostToken04(self, buff, arg1, arg2, over)
	local id = TryGetProp(buff, 'ClassID', 0)
	if id > 0 then
		local cls = GetClassByType('Buff', id)
		if cls ~= nil then
			local rate = TryGetProp(cls, 'BuffExpUP', 0)
			local before = GetExProp(self, 'Premium_boostToken_rate')
			SetExProp(self, 'Premium_boostToken_rate', before + rate)
		end
		
		self.RSta_BM = self.RSta_BM + 500
	end
end
function SCR_BUFF_LEAVE_Premium_boostToken04(self, buff, arg1, arg2, over)
	local id = TryGetProp(buff, 'ClassID', 0)
	if id > 0 then
		local cls = GetClassByType('Buff', id)
		if cls ~= nil then
			local rate = TryGetProp(cls, 'BuffExpUP', 0)
			local before = GetExProp(self, 'Premium_boostToken_rate')
			local after = before - rate
			if after < 0 then
				after = 0
			end
			SetExProp(self, 'Premium_boostToken_rate', after)
		end
		
		self.RSta_BM = self.RSta_BM - 500;
    
		if GetBuffRemainTime(buff) <= 0 then
			SendSysMsg(self, "Premium_boostToken_EndMsg");
			PremiumItemMongoLog(self, "BoostToken", "End", 0);
		end
	end
end

-- 16배
function SCR_BUFF_ENTER_Premium_boostToken05(self, buff, arg1, arg2, over)
	local id = TryGetProp(buff, 'ClassID', 0)
	if id > 0 then
		local cls = GetClassByType('Buff', id)
		if cls ~= nil then
			local rate = TryGetProp(cls, 'BuffExpUP', 0)
			local before = GetExProp(self, 'Premium_boostToken_rate')
			SetExProp(self, 'Premium_boostToken_rate', before + rate)
		end
		
		self.RSta_BM = self.RSta_BM + 4000;
	end
end
function SCR_BUFF_LEAVE_Premium_boostToken05(self, buff, arg1, arg2, over)
	local id = TryGetProp(buff, 'ClassID', 0)
	if id > 0 then
		local cls = GetClassByType('Buff', id)
		if cls ~= nil then
			local rate = TryGetProp(cls, 'BuffExpUP', 0)
			local before = GetExProp(self, 'Premium_boostToken_rate')
			local after = before - rate
			if after < 0 then
				after = 0
			end
			SetExProp(self, 'Premium_boostToken_rate', after)
		end
		
		self.RSta_BM = self.RSta_BM - 4000;

		if buff ~= nil and GetBuffRemainTime(buff) <= 0 then    
			SendSysMsg(self, "Premium_boostToken_EndMsg");
			PremiumItemMongoLog(self, "BoostToken", "End", 0);
			ReqConsumePremiumBuff(self, 'Premium_boostToken05', 5);
		end
	end
end

-- 32배
function SCR_BUFF_ENTER_Premium_boostToken06(self, buff, arg1, arg2, over)
	local id = TryGetProp(buff, 'ClassID', 0)
	if id > 0 then
		local cls = GetClassByType('Buff', id)
		if cls ~= nil then
			local rate = TryGetProp(cls, 'BuffExpUP', 0)
			local before = GetExProp(self, 'Premium_boostToken_rate')
			SetExProp(self, 'Premium_boostToken_rate', before + rate)
		end
		
		self.RSta_BM = self.RSta_BM + 4000;
	end
end
function SCR_BUFF_LEAVE_Premium_boostToken06(self, buff, arg1, arg2, over)
	local id = TryGetProp(buff, 'ClassID', 0)
	if id > 0 then
		local cls = GetClassByType('Buff', id)
		if cls ~= nil then
			local rate = TryGetProp(cls, 'BuffExpUP', 0)
			local before = GetExProp(self, 'Premium_boostToken_rate')
			local after = before - rate
			if after < 0 then
				after = 0
			end
			SetExProp(self, 'Premium_boostToken_rate', after)
		end
		
		self.RSta_BM = self.RSta_BM - 4000;

		if buff ~= nil and GetBuffRemainTime(buff) <= 0 then    
			SendSysMsg(self, "Premium_boostToken_EndMsg");
			PremiumItemMongoLog(self, "BoostToken", "End", 0);
			ReqConsumePremiumBuff(self, 'Premium_boostToken06', 5);
		end
	end
end
