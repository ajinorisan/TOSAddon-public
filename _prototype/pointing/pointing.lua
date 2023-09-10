---------------------------------------------------------------------------------------------
--★作者
--	Nekosuji（http://nekosuji.com/）
--★参考にしたaddon（スペシャルサンクス） 
--	rader
--	altarget
--	monsterstatus
--	cdtracker
---------------------------------------------------------------------------------------------

-- ●グローバルっぽい変数定義

local g_acutil = require('acutil');

local MINIMUM_ZOOM = 50;
local MAXIMUM_ZOOM = 1500;
local MINIMUM_XY = 0;
local MAXIMUM_XY = 359;

local g_isLock = false;			-- ターゲットロック中か否か
local g_isSelect = false;		-- ターゲット中か否か
local g_tarHandle = nil;		-- ターゲットハンドル
local g_height = 0;				-- 高さ補正値（FRAME_AUTO_POS_TO_OBJが解像度により狂うのを補正するための値）
local g_outMaxLenH = 10;		-- 上下外枠分割最大数
local g_outMaxLenW = 10;		-- 左右外枠分割最大数
local g_isMousFadeIn = false;	-- マウスカーソルがフェードイン中か否か
local g_mousFadeAlpha = 0;		-- マウスカーソルのフェード値

local g_isToggleOn = false;			-- トグルが有効か否か
local g_isEnableCircle = false;		-- ターゲットサークル表示が有効か否か
local g_isEnablePoint = false;		-- ポイント表示が有効か否か
local g_isEnableOutside = false;	-- 外枠表示が有効か否か
local g_isEnableInfo = false;		-- 情報表示が有効か否か
local g_isEnableAssist = false;		-- カメラアシストが有効か否か
local g_isEnableHideName = false;	-- 名称非表示が有効か否か

local g_check = false;			-- 
local g_isPvPMap = false;		-- PvPマップか否か
local g_CamAssistFrag = false;	-- カメラアシスト中か否か

local g_assistCurrentX = 45;	-- カメラ初期角度X
local g_assistCurrentY = 38;	-- カメラ初期角度Y

-- 範囲フレーム（名称で取得すると結構重いので、可能な限りグローバルに持つ）
local g_fieldFrame = nil;	-- フィールドUIフレーム
local g_frameL = {};		-- 外枠のフレーム
local g_frameR = {};
local g_frameT = {};
local g_frameB = {};
local g_frameLT = nil;
local g_frameRT = nil;
local g_frameLB = nil;
local g_frameRB = nil;

-- 範囲フレームを描画するか否か
local g_isOutDrawTbl ={
	l = {};
	t = {};
	r = {};
	b = {};
};

-- ターゲットサウンド
local g_soundTypes = {'__non__','button_click','button_click_2','button_click_3','button_click_4','cllection_inven_open','quest_ui_alarm_2','sys_popup_open_1','skill_cooltime','sys_alarm_mon_kill_count'};

local g_uiObjects = {};		-- 設定画面のコントロール

-- アップダウンボタンステータス
local g_upDownButtonState = {};



-- ●セッティング

local g_saveVer = 15;	-- 現在のセーブデータのバージョン
local g_saves = {};
local g_settings = {};
local g_default = {
	isEnableCircle = true;	-- ターゲットサークルが有効か否か

	isEnablePoint = true;	-- ターゲットポイントが有効か否か
	tarSoundMob = 2;		-- モンスターターゲット音
	tarSoundOther = 3;		-- モンスター以外のターゲット音

	isEnableOutside = true;	-- 外枠と外枠アイコンが有効か否か
	outColorA = 50;			-- 外枠のアルファ
	outColorR = 0;			-- R
	outColorG = 0;			-- G
	outColorB = 0;			-- B
	outL = 50;				-- 左,右,上,下幅
	outR = 50;
	outT = 50;
	outB = 50;
	outH = 8;
	outW = 10;

	isMouseCursor = false;	-- マウスカーソルの強調が有効か否か
	mousePrio = 200;		-- マウスカーソルのプライオリティ
	mouseSize = 100;		-- マウスカーソルサイズ（%）
	mouseColorA = 80;		-- マウスカーソルのアルファ
	mouseColorR = 0;		-- R
	mouseColorG = 100;		-- G
	mouseColorB = 0;		-- B
	isMouseFlash = true;	-- マウスカーソルを点滅させるか否か
	mouseInterval = 40;	-- マウスカーソルの点滅間隔(ms)

	isEnableInfo = false;	-- ターゲット情報ウィンドウが有効か否か
	infoX = -1;				-- 情報ウィンドウの位置
	infoY = -1;
	isInfoMainAtk	= true;	-- ダメージ比率（メイン攻撃）
	isInfoSubAtk	= true;	-- サブ攻撃
	isInfoMagicAtk	= true;	-- 魔法攻撃
	isInfoCri		= true;	-- クリ率＆クリ抵抗
	isInfoHitPane	= true;	-- 命中＆ブロック貫通率
	isInfoEvaBlock	= true;	-- 回避＆ブロック率
	isInfoPhysiRes	= true;	-- 物理ダメージ防御比率
	isInfoMagicRes	= true;	-- 魔法ダメージ防御比率
	isInfoGemaNota	= true;	-- ゲマトリア＆ノタリコン
	isInfoMaxMin	= true;	-- 数値の上限を適用するか否か

	isEnableAssist = false;	-- カメラアシストが有効か否か
	assistWindowX = 510;	-- 情報ウィンドウの位置
	assistWindowY = 880;
	assistZoom = 350;		-- 現在のズーム値
	isAssistDrawInfo = true; -- カメラ情報を表示するか否か
	isAssistRC = true;		-- 右クリックズームが有効か否か
	isAssistDrawPC = true;	-- ズーム中、PCを非表示にするか否か
	isAssistDelObj = true;	-- ズーム中、カーソルに触れたオブジェクトを消去するか否か
	assistRightZoom = 265;	-- アシスト時のズーム係数
	assistMoveRatioX = 75;	-- アシスト時の移動係数
	assistMoveRatioY = 150;	-- アシスト時の移動係数

	isEnableHideName = false;	-- 名前を隠すか否か
	isHideNameShowSelect = true;-- 　カーソル付近のプレイヤーの名前を表示するか否か
	isHideNameShowCtrl = false;	-- 　　Ctrlを押している場合表示
	isHideNamePvP = true;		-- 　PvPフィールドでのプライバシー保護を有効にするか否か
	isHideNameSalf = true;		-- 　自分の名前を隠すか否か
	hideNameSalfHP = 75;		-- 　　HP表示敷居％
	hideNameSalfMP = 66;		-- 　　MP表示敷居％
	hideNameSalfSTA = 25;		-- 　　STA表示敷居％
	hideNameSalfPet = 10;		-- 　　Pet空腹表示敷居％
	hideNameSalfPP = 50;		-- 　　ポイズンポット表示敷居%
	hideNameSalfDP = 50;		-- 　　死体の破片表示敷居%
	isHideNamePt = true;		-- 　PTの名前を隠すか否か
	hideNamePtHP = 75;			-- 　　HP表示敷居％
	hideNamePtMP = 33;			-- 　　MP表示敷居％
	isHideNameEtc = true;		-- 　それ以外の名前を隠すか否か
	hideNameEtcHP = 0;			-- 　　HP表示敷居％
	hideNameEtcMP = -1;			-- 　　MP表示敷居％
	isHideNamePet = true;		-- 　コンパニオンの名前を隠すか否か

	layer = 32;				-- 全体の描画優先度。この数字+1まで使用する（ネームプレートが31～32の間ぐらい）
	iconSize = 16;			-- ポイントアイコンサイズ
	tarDistance = 0;		-- 非強調するターゲットまでの距離

	isPointPT  = true;		-- △ポイント表示対象：PTメンバー
	isPointNPC = true;		-- 　NPC
	isPointMOB = true;		-- 　敵
	isPointSP  = true;		-- 　クリスタル
	isPointOBJ = true;		-- 　オブジェクト
	isPointETC = true;		-- 　その他のオブジェクト
	isPointPC  = true;		-- 〇自分自身

	isOutPointPT  = false;	-- △外枠ポイント表示対象：PTメンバー
	isOutPointNPC = false;	-- 　NPC
	isOutPointMOB = true;	-- 　敵
	isOutPointSP  = true;	-- 　クリスタル
	isOutPointOBJ = false;	-- 　オブジェクト
	isOutPointETC = false;	-- 　その他のオブジェクト

	isDisPointPT  = false;	-- △距離による強調対象：PTメンバー
	isDisPointNPC = false;	-- 　NPC
	isDisPointMOB = true;	-- 　敵
	isDisPointSP  = true;	-- 　クリスタル
	isDisPointOBJ = true;	-- 　オブジェクト
	isDisPointETC = true;	-- 　その他のオブジェクト

	isHidePointPtRide = false;	-- △非表示対象：PTメンバーの騎乗中のペット
	isHidePointPtPet = false;	-- 　PTメンバーの騎乗していないペット
	isHidePointPtObj = false;	-- 　PTメンバーのオブジェクト
	isHidePointRide = false;	-- 　騎乗中のペット
	isHidePointPet = false;		-- 　騎乗していないペット
	isHidePointObj = false;		-- 　オブジェクト
};





---------------------------------------------------------------------------------------------

-- ●共通コールバック関数定義

-- ◇初期化処理
function POINTING_ON_INIT(addon, frame)

--	CHAT_SYSTEM('pointing init.');
--	CHAT_SYSTEM( string.format( "ハンドル:%d ⇒ %d" , g_tarHandle, _handle) );

	-- 初期化
	PointingLoadSetting();	-- 設定読み込み
	g_uiObjects = {};		-- 設定画面のコントロール初期化
	PointingFragSet();		-- フラグ設定

	InitAll();				-- 全体初期化

	-- コールバック設定
	g_acutil.slashCommand('/pointing', POINTING_CHAT_CMD);				-- チャットコマンド
	g_acutil.setupHook(LOCKTARGET_POINTING, 'CTRLTARGETUI_OPEN');		-- ターゲットロック時に呼ばれる
	g_acutil.setupHook(UNLOCKTARGET_POINTING, 'CTRLTARGETUI_CLOSE');	-- ターゲットアンロック時に呼ばれる

	addon:RegisterMsg('BUFF_ADD', 'POINTING_CHANGE_BUFF');				-- BUFFが追加された場合
	addon:RegisterMsg('BUFF_REMOVE', 'POINTING_CHANGE_BUFF');			-- BUFFが削除された場合

--	addon:RegisterMsg('GAME_START_3SEC', 'POINTING_3SEC');				-- MAP切り替え後、3秒後に呼ばれる処理？
	addon:RegisterMsg('FPS_UPDATE', 'UPDATE_POINTING_FRAME');			-- 周期処理。1フレームに一度呼ばれるわけでは無い。
--	addon:RegisterMsg('MON_ENTER_SCENE', 'POINTING_MON_ENTER_SCENE');	-- モンスターが発生した場合？

	addon:RegisterMsg('TARGET_SET', 'SET_TARGET_POINTING');				-- ターゲットが選択された場合
	addon:RegisterMsg('TARGET_UPDATE', 'UPDATE_TARGET_POINTING');		-- ターゲットの状態が変化した場合？（ターゲット死亡を即座に判定）
	addon:RegisterMsg('TARGET_CLEAR', 'CLEAR_TARGET_CLEAR_POINTING');	-- ターゲットの選択が解除された場合

	frame:ShowWindow(1);
	frame:Resize(0,0);
	frame:RunUpdateScript('UpdateOutFrame', 0.2, 0, 0, 1);				-- 外枠周期処理：0.2秒に一度更新
	frame:RunUpdateScript('UpdateHideName', 0, 0, 0, 1);				-- 名称非表示全体周期処理：重いけど汚いから毎フレーム更新
	frame:RunUpdateScript('UpdateCameraAssistAngle', 0, 0, 0, 1);		-- カメラ右クリック回転処理（assist側のフレームに設定するとなぜか途中で呼ばれなくなるので、ここで呼び出し）

end



---- ◇MAP切り替え後、3秒後に呼ばれる処理？
--function POINTING_3SEC()
--end



-- ◇モンスター生成時に呼び出される処理
function POINTING_MON_ENTER_SCENE(frame, msg, str, handle)

	-- ターゲットポイントが無効の場合は抜ける
	if g_isEnablePoint==false then
		return;
	end

	-- ポイント：0.05秒後にポイント生成処理を呼び出す
	ReserveScript( string.format("CreatePoiontObject(%d)", handle), 0.05);

end



-- ◇周期処理
function UPDATE_POINTING_FRAME()

	local _isDispSizeChange = CalcAutoPosCorrctionHeight();	-- 解像度によるFRAME_AUTO_POS_TO_OBJのずれを計算する

	PointingFragSet();	-- フラグ設定

	if g_check==true then
		ClearTargetCursor();
		ClearOutFrame();
		ClearInformation();
		ClearCameraAssist();
		ClearHideName();
		local _listMob, _cntMob = SelectObject( GetMyPCObject(), 800, 'ALL');
		for _i = 1, _cntMob do
			PointingHideTarget( GetHandle( _listMob[_i] ) );
		end
		return;
	end

	-- 解像度が変わった場合
	if _isDispSizeChange==true then
		InitAll();
	end

	-- ターゲットポイントが無効の場合は抜ける
	if g_isEnablePoint==false then
		return;
	end

-- MON_ENTER_SCENEが機能しなくなったので
	-- 周囲のオブジェクトのアイコン生成
	local _listMob, _cntMob = SelectObject( GetMyPCObject(), 800, 'ALL');
	for _i = 1, _cntMob do
		local _handle = GetHandle( _listMob[_i] );
		if g_isEnablePoint and PointingHideTarget( _handle )==false then
			CreatePoiontObject( _handle );
		end
	end
--

	-- ポイント：PTメンバーのポイント生成
	CheckAndCreatePoiontParty();

end



-- ◇ ターゲットロック
function LOCKTARGET_POINTING()

	-- カーソル：ターゲットロック
	if g_isEnableCircle then
		LockTargetCursor();
	end

	return CTRLTARGETUI_OPEN_OLD();
end



-- ◇ ターゲットアンロック
function UNLOCKTARGET_POINTING()

	-- カーソル：ターゲットアンロック
	if g_isEnableCircle then
		UnlockTargetCursor();
	end

	return CTRLTARGETUI_CLOSE_OLD();
end



-- ◇ バフに変更があった場合
function POINTING_CHANGE_BUFF()

	-- 情報：情報更新
	if g_isEnableInfo then
		local _handle = session.GetTargetHandle();
		if g_tarHandle == _handle then
			RefreshInfomation(_handle)
		end
	end

end



-- ◇ ターゲット選択
function SET_TARGET_POINTING(frame, msg, argStr, argNum)

	local _handle = session.GetTargetHandle();

	-- ポイント：もし生成されていない場合、ここで生成してしまう
	if g_isEnablePoint and ui.GetFrame("pointing" .. _handle)==nil then
		CreatePoiontObject(_handle);
	end

	-- カーソル：ターゲット選択
	if g_isEnableCircle then
		SetTargetCursor(_handle);
	end

	-- モンスターの場合？
	if argStr ~= "None" and argNum ~= nil then
		-- 情報：情報更新
		if g_isEnableInfo then
			RefreshInfomation(_handle);
		end
	end

	g_tarHandle = _handle;	-- ターゲットを保存

end



-- ◇ ターゲットの状態が更新された
function UPDATE_TARGET_POINTING(frame, msg, argStr, argNum)

	local _handle = session.GetTargetHandle();

	-- ターゲットが同じ場合のみ更新
	if g_tarHandle == _handle then
		SET_TARGET_POINTING(frame, msg, argStr, argNum);
	end

end



-- ◇ ターゲット選択解除
function CLEAR_TARGET_CLEAR_POINTING(msgFrame, msg, argStr, handle)

	-- カーソル：ターゲット選択解除
	if g_isEnableCircle then
		ClearTargetCursor();
	end

	-- 情報：表示を消す
	if g_isEnableInfo then
		ClearInformation();
	end

	g_tarHandle = nil;	-- ターゲットクリア

end



-- ◇ チャットコマンド対応処理
function POINTING_CHAT_CMD(command)

	if g_check==true then
		return
	end

	local _cmd  = ''
	local _frame;

	-- 設定画面を開く
	if #command == 0 then

		_frame = ui.GetFrame('pointing_setting_sub')
		if _frame ~= nil and _frame:IsVisible() == 1 then
			_frame:ShowWindow(0);
			return;
		end

		_frame = ui.GetFrame('pointing_setting')
		if _frame == nil then
			CreateSettingFrame();
		elseif _frame:IsVisible() == 1 then
			_frame:ShowWindow(0);
		end

	elseif #command > 0 then

		_cmd = table.remove(command, 1)

		-- 設定画面が出ている場合は一度消す
		_frame = ui.GetFrame('pointing_setting')
		if _frame ~= nil and _frame:IsVisible() == 1 then
			_frame:ShowWindow(0);
		end

		_frame = ui.GetFrame('pointing_setting_sub')
		if _frame ~= nil and _frame:IsVisible() == 1 then
			_frame:ShowWindow(0);
		end

		-- ヘルプの場合
		if _cmd == 'help' then
			PointingCheckCommand();

		-- リセットの場合
		elseif _cmd == 'reset' then
			CHAT_SYSTEM('reset pointing settings.');
			g_settings = g_default;	-- 設定をリセット
			PointingSaveSetting();	-- 設定を保存
			InitAll();				-- 全体初期化

		-- トグルの場合
		elseif _cmd == 'toggle' then
			if g_isToggleOn then
				g_isToggleOn = false;
				PointingFragSet();
				InitAll();				-- 全体初期化
				CHAT_SYSTEM('pointing on.');
			else
				g_isToggleOn = true;
				ClearTargetCursor();
				ClearOutFrame();
				ClearInformation();
				ClearCameraAssist();
				ClearMouseCursor();
				ClearHideName();
				PointingFragSet();
				CHAT_SYSTEM('pointing off.');
			end

		-- カメラリセットの場合
		elseif _cmd == 'cam_reset' then
			g_assistCurrentX = 45;
			g_assistCurrentY = 38;
			if g_isEnableAssist then
				camera.CamRotate(g_assistCurrentY, g_assistCurrentX);
				CameraAssistSetText();
			end

		-- 引数が二つ以上の場合
		elseif #command > 0 then
			_cmd2 = table.remove(command, 1)

			-- 設定の保存の場合
			if _cmd == 'save' then

				if _cmd2 == '1' then
					g_saves.save1 = shallowcopy(g_saves.active);
					CHAT_SYSTEM('pointing save setting 1.');
				elseif _cmd2 == '2' then
					g_saves.save2 = shallowcopy(g_saves.active);
					CHAT_SYSTEM('pointing save setting 2.');
				elseif _cmd2 == '3' then
					g_saves.save3 = shallowcopy(g_saves.active);
					CHAT_SYSTEM('pointing save setting 3.');
				end
				PointingSaveSetting();

			-- 設定の読み込みの場合
			elseif _cmd == 'load' then

				-- 設定保存
				if _cmd2 == '1' then
					g_settings = shallowcopy(g_saves.save1);
					CHAT_SYSTEM('pointing load setting 1.');
				elseif _cmd2 == '2' then
					g_settings = shallowcopy(g_saves.save2);
					CHAT_SYSTEM('pointing load setting 2.');
				elseif _cmd2 == '3' then
					g_settings = shallowcopy(g_saves.save3);
					CHAT_SYSTEM('pointing load setting 3.');
				else
					return;
				end
				PointingSaveSetting();

				-- 初期化
				InitAll();

			-- カメラズームの場合
			elseif _cmd == 'zoom' then
				local _zoom1 = tonumber(_cmd2);
				if type(_zoom1) == "number" then
					if _zoom1 >= MINIMUM_ZOOM and _zoom1 <= MAXIMUM_ZOOM then
						g_settings.assistZoom = _zoom1;
						if g_isEnableAssist then
							CameraAssistSetText();
						end
						PointingSaveSetting();	-- 設定を保存
					else
						CHAT_SYSTEM("Invalid zoom level. Minimum is 50 and maximum is 1500.");
					end
				end

			end

		end

	end

end





---------------------------------------------------------------------------------------------

-- ●関数定義

--◇ 全体初期化
function InitAll()

	g_tarHandle = nil;
	g_height = 0;
	g_fieldFrame = ui.GetFrame("fieldui");

	CalcAutoPosCorrctionHeight();	-- 解像度によるFRAME_AUTO_POS_TO_OBJのずれを計算する

	-- カーソル：初期化
	if g_isEnableCircle then
		InitTargetCursor();
	end

	-- 範囲フレーム：初期化
	if g_isEnableOutside then
		InitOutFrame();
	end

	-- ポイント：初期化
	if g_isEnablePoint then
		InitPoint();
	end

	-- 情報：初期化
	if g_isEnableInfo then
		InitInformation();
	end

	-- カメラアシスト：初期化
	if g_isEnableAssist then
		InitCameraAssist();
	end

	-- マウスカーソル：初期化
	if g_settings.isMouseCursor then
		InitMouseCursor();
	end

end



-- 各種フラグ設定
function PointingFragSet()

	local _wpFrame = ui.GetFrame("worldpvp_score");
	g_check = (_wpFrame~=nil and _wpFrame:IsVisible()==1);

	g_isPvPMap = (UI_CHECK_NOT_PVP_MAP() == 0);
	g_isEnableCircle	= ( g_settings.isEnableCircle   and g_isToggleOn==false and g_check==false );
	g_isEnablePoint		= ( g_settings.isEnablePoint    and g_isToggleOn==false and g_check==false and g_isPvPMap==false );
	g_isEnableOutside	= ( g_settings.isEnableOutside  and g_isToggleOn==false and g_check==false and g_isPvPMap==false and g_isEnablePoint );
	g_isEnableInfo		= ( g_settings.isEnableInfo     and g_isToggleOn==false and g_check==false );
	g_isEnableAssist	= ( g_settings.isEnableAssist   and g_isToggleOn==false and g_check==false );
	g_isEnableHideName	= ( g_settings.isEnableHideName and g_isToggleOn==false and g_check==false );

end



--◇ ポイント：初期化処理
function InitPoint()

	-- プレイヤーキャラのアイコン生成
	if g_settings.isPointPC == true then
		local _handle = session.GetMyHandle();
		local _frame = CreatePoiontIcon( _handle, 1.0, "BB000000", g_settings.layer+1, "UpdatePointPC" );
		if _frame~=nil then
			-- 剣のカーソル生成
			local _iconSize = g_settings.iconSize + 2;
			local _pcCursor = _frame:CreateOrGetControl("picture", "cursor", _frame:GetWidth()/2-_iconSize/2, _frame:GetHeight()/2-_iconSize/2, _iconSize, _iconSize);
			tolua.cast(_pcCursor, "ui::CPicture");
			_pcCursor:SetImage("mon_info_melee");
			_pcCursor:EnableHitTest(0);
			_pcCursor:SetColorTone("FFFFFFFF");
			_pcCursor:SetEnableStretch(1);
			_pcCursor:SetAngle( info.GetAngle(_handle) + g_assistCurrentX-45 );
		end
	end

	-- 周囲のオブジェクトのアイコン生成
	local _listMob, _cntMob = SelectObject( GetMyPCObject(), 800, 'ALL');
	for _i = 1, _cntMob do
		local _handle = GetHandle( _listMob[_i] );
		if PointingHideTarget( _handle ) == false then
			CreatePoiontObject( _handle );
		end
	end

end



--◇ ポイント：オブジェクトのポイント生成
function CreatePoiontObject( handle )

	-- 有効な対象ではない場合
	local _isCheck, _isOut, _isDis, _monster = CheckPointTarget(handle);
	if _isCheck == false then
		return;
	end

	local _scale, _color = GetMonsterIconDesign( _monster, handle );
	local _frame = CreatePoiontIcon( handle, _scale, _color, g_settings.layer, "UpdatePointObject" );

	-- 範囲フレーム：外枠用アイコン生成
	if _isOut == true then
		_frame:SetLinkObject( CreateOutFrameIcon( handle, _scale, _color, g_settings.layer) );
	end

	UpdatePointObject(_frame);

end



--◇ ポイント：PTメンバーのポイント生成
function CheckAndCreatePoiontParty()

	-- ポイント表示対象でない場合
	if g_isEnablePoint==false or g_settings.isPointPT==false then
		return;
	end

	-- PTメンバー
	local _listPt = session.party.GetPartyMemberList( PARTY_NORMAL);
	if _listPt ~= nil then
		local _myInfo = session.party.GetMyPartyObj();
		local _cntPt = _listPt:Count();
		local _ptNo = 0;
		for _i = 0 , _cntPt - 1 do
			local _info = _listPt:Element(_i);
			if _info ~= nil then
				local _handle = _info:GetHandle();
				-- 自分自身ではない場合
				if _handle ~= session.GetMyHandle() then
					_ptNo = _ptNo + 1;
					-- 同一マップ、同一チャンネルの場合
					if _myInfo:GetMapID() == _info:GetMapID() and _myInfo:GetChannel() == _info:GetChannel() then
						local _frame = ui.GetFrame("pointing" .. _handle);
						-- まだ生成されていない場合
						if _frame==nil then
							_frame = CreatePoiontIcon( _handle, 1.0, "FF4444CC", g_settings.layer, "UpdatePointPT" );
							-- ポイント表示対象の場合
							if g_settings.isOutPointPT == true then
								_frame:SetLinkObject( CreateOutFrameIcon( _handle, 1.0, "FF7777FF", g_settings.layer) );
							end
						end
						-- 番号付与
						local _noText = _frame:CreateOrGetControl("richtext", "no", _frame:GetWidth()/2 -5, _frame:GetHeight()/2 -7, 7, 7);
						if _ptNo == 1 then
							_noText:SetText("{@st41}{s14}{#ffffff}".._ptNo);
						elseif _ptNo == 2 then
							_noText:SetText("{@st41}{s14}{#44ffff}".._ptNo);
						elseif _ptNo == 3 then
							_noText:SetText("{@st41}{s14}{#ff88ff}".._ptNo);
						else
							_noText:SetText("{@st41}{s14}{#ffff22}".._ptNo);
						end
						_frame:ShowWindow(1);
					end
				end
			end
		end
	end

end



--◇ ポイント：アイコン生成
function CreatePoiontIcon( handle, scale, color, prio, updateScript )

	-- 対象が存在しない場合？
	if handle==nil or world.GetActor(handle)==nil then
		return	nil;
	end

	-- フレームとアイコン生成
	local c_halfW = 25;	-- ベースフレームのサイズの半分
	local _frame = ui.GetFrame("pointing" .. handle);
	if (_frame == nil) then
		_frame = ui.CreateNewFrame("pointing", "pointing"..handle, 0);
	end
	_frame:SetLayerLevel(prio);
	_frame:RunUpdateScript(updateScript);
	_frame:ShowWindow(1);
	FRAME_AUTO_POS_TO_OBJ(_frame, handle, -c_halfW, -c_halfW-g_height, c_halfW*2, c_halfW*2);	-- ハンドルに対してフレームを、2D座標系で追随させる

	local _halfW = g_settings.iconSize/2 * scale;	-- ベースフレームのサイズの半分
	local _monIcon = _frame:CreateOrGetControl("picture", "icon", c_halfW-_halfW, c_halfW-_halfW, _halfW*2, _halfW*2);
	tolua.cast(_monIcon, "ui::CPicture");  
	_monIcon:SetImage("yabaidot");
	_monIcon:SetColorTone(color);
	_monIcon:SetEnableStretch(1);
	_monIcon:SetUserValue("HANDLE", handle);

	return	_frame;

end



--◇ ポイント：オブジェクト１ポイントごとの更新
function UpdatePointObject(frame)

	local _handle = frame:GetUserIValue("_AT_OFFSET_HANDLE");    -- FRAME_AUTO_POS_TO_OBJで設定されたハンドル取得？

	-- 削除
	if frame:IsVisible() == 0 then
		ui.DestroyFrame("pointing_out".._handle);
		ui.DestroyFrame("pointing".._handle);
		return 0;
	end

	-- ポイント対象かチェック
	local _isCheck, _isOut, _isDis, _monster, _info = CheckPointTarget(_handle);
	if g_isEnablePoint==false or _isCheck==false then
		frame:ShowWindow(0);
		UpdateOutFrameIcon( _handle, frame );
		return 1;
	elseif _isOut == false then
		frame:SetLinkObject(nil);
		ui.DestroyFrame("pointing_out".._handle);
	end

	-- 距離による非強調をする場合
	local _icon = frame:GetChild( "icon" );
	if _icon~=nil then
		_icon:SetAlpha(100);
		if g_settings.tarDistance ~= 0 and _isDis==true then
			tolua.cast(_icon, "ui::CPicture");  
			if _info ~= nil and _info.distance-_info.radius > g_settings.tarDistance then
				_icon:SetImage("yabaibatu");
			else
				_icon:SetImage("yabaidot");
			end
		end
	end

	-- 範囲フレーム：周期処理
	UpdateOutFrameIcon( _handle, frame );

	return 1;

end



--◇ ポイント：PTメンバー1ポイントごとの更新
function UpdatePointPT(frame)

	local _handle = frame:GetUserIValue("_AT_OFFSET_HANDLE");    -- FRAME_AUTO_POS_TO_OBJで設定されたハンドル取得？

	-- 削除
	if frame:IsVisible() == 0 then
		ui.DestroyFrame("pointing_out".._handle);
		ui.DestroyFrame("pointing".._handle);
		return 0;
	end

	-- PTメンバーとして残っているかどうか判別
	local _isPt = false;
	local _listPt = session.party.GetPartyMemberList( PARTY_NORMAL);
	if _listPt ~= nil then
		local _myInfo = session.party.GetMyPartyObj();
		local _cntPt = _listPt:Count();
		for _i = 0 , _cntPt - 1 do
			local _info = _listPt:Element(_i);
			if _handle == _info:GetHandle() then
				_isPt = true;
				break;
			end
		end
	end

	-- 対象が存在しない場合・・・消去
	if g_settings.isPointPT==false or g_isEnablePoint==false or _handle==nil or world.GetActor(_handle)==nil or _isPt==false then
		frame:ShowWindow(0);
		UpdateOutFrameIcon( _handle, frame );
		return 1;
	elseif g_settings.isOutPointPT == false then
		frame:SetLinkObject(nil);
		ui.DestroyFrame("pointing_out".._handle);
	end

	-- 距離による非強調をする場合
	local _icon = frame:GetChild( "icon" );
	if _icon~=nil then
		tolua.cast(_icon, "ui::CPicture");  
		_icon:SetAlpha(100);
		if g_settings.tarDistance ~= 0 and g_settings.isDisPointPT==true then
			local _info = info.GetTargetInfo(_handle);
			if _info ~= nil and _info.distance-_info.radius > g_settings.tarDistance then
				_icon:SetImage("yabaibatu");
			else
				_icon:SetImage("yabaidot");
			end
		else
			_icon:SetImage("yabaidot");
		end
	end

	-- 範囲フレーム：周期処理
	UpdateOutFrameIcon( _handle, frame );

	return 1;
end



--◇ ポイント：プレイヤーキャラのポイント更新
function UpdatePointPC(frame)

	local _handle = frame:GetUserIValue("_AT_OFFSET_HANDLE");    -- FRAME_AUTO_POS_TO_OBJで設定されたハンドル取得？

	-- 削除
	if frame:IsVisible() == 0 then
		ui.DestroyFrame("pointing".._handle);
		return 0;
	end

	-- 対象が存在しない場合・・・消去
	if g_settings.isPointPC==false or g_isEnablePoint==false or _handle==nil or world.GetActor(_handle)==nil then
		frame:ShowWindow(0);
		return 1;
	end

	-- 剣アイコン回転
	local _pcIcon = frame:GetChild("cursor");
	_pcIcon:SetAngle( info.GetAngle(_handle) + g_assistCurrentX-45 );

	return 1;

end



--◇ 範囲フレーム：初期化処理
function InitOutFrame()

	local _outLenH = g_settings.outH;
	if _outLenH > 1 then
		_outLenH = _outLenH + 1;
	end
	for _i = 1, g_outMaxLenH+1 do
		if _i>_outLenH then
			g_isOutDrawTbl.l[_i] = nil;
			g_isOutDrawTbl.r[_i] = nil;
		else
			g_isOutDrawTbl.l[_i] = false;
			g_isOutDrawTbl.r[_i] = false;
		end
	end

	local _outLenW = g_settings.outW;
	if _outLenW > 1 then
		_outLenW = _outLenW + 1;
	end
	for _i = 1, g_outMaxLenW+1 do
		if _i>_outLenW then
			g_isOutDrawTbl.t[_i] = nil;
			g_isOutDrawTbl.b[_i] = nil;
		else
			g_isOutDrawTbl.t[_i] = false;
			g_isOutDrawTbl.b[_i] = false;
		end
	end

	-- 枠のフレーム生成
	local _w, _h = g_fieldFrame:GetWidth(), g_fieldFrame:GetHeight();
	local _l, _r = g_settings.outL, g_settings.outR;
	local _t, _b = g_settings.outT, g_settings.outB;
	local _size;

	-- 割り切れない数だと、枠が被って汚いので調整する
	_r = _r + (_w-_l-_r)%g_settings.outW;
	_b = _b + (_h-_t-_b)%g_settings.outH;

	_size = (_h-_t-_b)/g_settings.outH;
	for _i = 1, g_outMaxLenH do
		if _i > g_settings.outH then
			ui.DestroyFrame("pointing_frame_l".._i); g_frameL[_i] = nil;
			ui.DestroyFrame("pointing_frame_r".._i); g_frameR[_i] = nil;
		else
			g_frameL[_i] = InitOneOutFrame( '_l'.._i,  0   , _t   +_size*(_i-1), _l, _size);
			g_frameR[_i] = InitOneOutFrame( '_r'.._i, _w-_r, _t   +_size*(_i-1), _r, _size);
		end
	end

	_size = (_w-_l-_r)/g_settings.outW;
	for _i = 1, g_outMaxLenW do
		if _i > g_settings.outW then
			ui.DestroyFrame("pointing_frame_t".._i); g_frameT[_i] = nil;
			ui.DestroyFrame("pointing_frame_b".._i); g_frameB[_i] = nil;
		else
			g_frameT[_i] = InitOneOutFrame( '_t'.._i, _l   +_size*(_i-1),  0   , _size, _t);
			g_frameB[_i] = InitOneOutFrame( '_b'.._i, _l   +_size*(_i-1), _h-_b, _size, _b);
		end
	end

	g_frameLT = InitOneOutFrame( '_lt',     0,     0, _l, _t);
	g_frameRT = InitOneOutFrame( '_rt', _w-_r,     0, _r, _t);
	g_frameLB = InitOneOutFrame( '_lb',     0, _h-_b, _l, _b);
	g_frameRB = InitOneOutFrame( '_rb', _w-_r, _h-_b, _r, _b);

end


--◇ 範囲フレーム：初期化処理
function InitOneOutFrame( name, x, y, w, h)

	local _frame = ui.GetFrame("pointing_frame"..name);
	if _frame == nil then
		_frame = ui.CreateNewFrame("pointing", "pointing_frame"..name, 0);
	end
	_frame:SetGravity(ui.LEFT,ui.TOP);
	_frame:SetLayerLevel(g_settings.layer);

	_frame:SetOffset( x, y);
	_frame:Resize( w, h);
	_frame:ShowWindow(1);

	local _pic = _frame:GetChild("point_circle");
	if _pic==nil then
		_pic = _frame:CreateOrGetControl("picture", "point_circle", 0, 0, 150, 150);
		tolua.cast(_pic, "ui::CPicture");
		_pic:SetImage("yabaiwaku");
		_pic:SetEnableStretch(1);
		_pic:EnableHitTest(0);
	end
	_pic:Resize( w, h);
	_pic:SetColorTone( string.format("%02x%02x%02x%02x",255*(g_settings.outColorA*0.01),255*(g_settings.outColorR*0.01),255*(g_settings.outColorG*0.01),255*(g_settings.outColorB*0.01)) );

	return	_frame;

end



--◇ 範囲フレーム：クリア
function ClearOutFrame()

	for _i = 1, g_outMaxLenH do ui.DestroyFrame("pointing_frame_l".._i); g_frameL[_i] = nil; end
	for _i = 1, g_outMaxLenH do ui.DestroyFrame("pointing_frame_r".._i); g_frameR[_i] = nil; end
	for _i = 1, g_outMaxLenW do ui.DestroyFrame("pointing_frame_t".._i); g_frameT[_i] = nil; end
	for _i = 1, g_outMaxLenW do ui.DestroyFrame("pointing_frame_b".._i); g_frameB[_i] = nil; end

	ui.DestroyFrame("pointing_frame_lt");	g_frameLT = nil;
	ui.DestroyFrame("pointing_frame_rt");	g_frameRT = nil;
	ui.DestroyFrame("pointing_frame_lb");	g_frameLB = nil;
	ui.DestroyFrame("pointing_frame_rb");	g_frameRB = nil;

end



--◇ 範囲フレーム：周期処理
function UpdateOutFrame(frame)

	-- 範囲フレームが無効の場合は抜ける
	if g_isEnableOutside==false or g_frameLT==nil then
		return	1;
	end

	-- 範囲フレーム描画設定
	local _l = {};	for _i = 1, g_settings.outH do _l[_i] = false; end
	local _t = {};	for _i = 1, g_settings.outW do _t[_i] = false; end
	local _r = {};	for _i = 1, g_settings.outH do _r[_i] = false; end
	local _b = {};	for _i = 1, g_settings.outW do _b[_i] = false; end

	-- アルファ設定
	SetOutFrameAlphaTbl( g_isOutDrawTbl.l, _l, _t, 1  , _b, 1  );
	SetOutFrameAlphaTbl( g_isOutDrawTbl.t, _t, _l, 1  , _r, 1  );
	SetOutFrameAlphaTbl( g_isOutDrawTbl.r, _r, _t, #_t, _b, #_b);
	SetOutFrameAlphaTbl( g_isOutDrawTbl.b, _b, _l, #_l, _r, #_r);

	-- 枠の描画
	for _i = 1, #_l do if _l[_i] then g_frameL[_i]:ShowWindow(1); else g_frameL[_i]:ShowWindow(0); end end
	for _i = 1, #_t do if _t[_i] then g_frameT[_i]:ShowWindow(1); else g_frameT[_i]:ShowWindow(0); end end
	for _i = 1, #_r do if _r[_i] then g_frameR[_i]:ShowWindow(1); else g_frameR[_i]:ShowWindow(0); end end
	for _i = 1, #_b do if _b[_i] then g_frameB[_i]:ShowWindow(1); else g_frameB[_i]:ShowWindow(0); end end

	-- 角の描画
	if g_isOutDrawTbl.l[1]				   == false and g_isOutDrawTbl.t[1]					== false then g_frameLT:ShowWindow(0); else g_frameLT:ShowWindow(1);  end
	if g_isOutDrawTbl.l[#g_isOutDrawTbl.l] == false and g_isOutDrawTbl.b[1]					== false then g_frameLB:ShowWindow(0); else g_frameLB:ShowWindow(1);  end
	if g_isOutDrawTbl.r[1]				   == false and g_isOutDrawTbl.t[#g_isOutDrawTbl.t] == false then g_frameRT:ShowWindow(0); else g_frameRT:ShowWindow(1);  end
	if g_isOutDrawTbl.r[#g_isOutDrawTbl.r] == false and g_isOutDrawTbl.b[#g_isOutDrawTbl.b] == false then g_frameRB:ShowWindow(0); else g_frameRB:ShowWindow(1);  end

	-- 描画フラグクリア
	for _i = 1, #g_isOutDrawTbl.l do g_isOutDrawTbl.l[_i] = false; end
	for _i = 1, #g_isOutDrawTbl.t do g_isOutDrawTbl.t[_i] = false; end
	for _i = 1, #g_isOutDrawTbl.r do g_isOutDrawTbl.r[_i] = false; end
	for _i = 1, #g_isOutDrawTbl.b do g_isOutDrawTbl.b[_i] = false; end

	return	1;

end



--◇ 範囲フレーム：枠一つのアルファ設定
function SetOutFrameAlphaTbl( drawTbl, alphaTbl, sideTbl1, num1, sideTbl2, num2)

	-- 角先端の場合
	if drawTbl[1] == true then
		-- 分割数が1しかない場合は側面に影響させない
		if #sideTbl1~=1 and #drawTbl~=1 then
			sideTbl1[num1] = true;
		end
		alphaTbl[1] = true;
	end
	-- 角終端の場合
	if drawTbl[#drawTbl] == true then
		-- 分割数が1しかない場合は側面に影響させない
		if #sideTbl2 ~=1 and #drawTbl~=1 then
			sideTbl2[num2] = true;
		end
		alphaTbl[#drawTbl-1] = true;
	end
	-- 中間の場合
	for _i = 2, #drawTbl-1 do
		if drawTbl[_i] == true then
			alphaTbl[_i] = true;
			alphaTbl[_i-1] = true;
		end
	end

end


--◇ 範囲フレーム：アイコン生成
function CreateOutFrameIcon( handle, scale, color, prio)

	-- 範囲フレームが無効の場合は抜ける
	if g_isEnableOutside==false then
		return	nil;
	end


	-- フレームとアイコン生成
	local c_halfW = 25;	-- ベースフレームのサイズの半分
	local _frame = ui.GetFrame("pointing_out" .. handle);
	if (_frame == nil) then
		_frame = ui.CreateNewFrame("pointing", "pointing_out"..handle, 0);
	end
	_frame:SetLayerLevel(prio+1);
	_frame:ShowWindow(1);
	_frame:SetOffset(-c_halfW, -c_halfW-g_height);
	_frame:Resize(c_halfW*2, c_halfW*2);

	local _halfW = g_settings.iconSize/2 * scale;	-- ベースフレームのサイズの半分
	local _monIcon = _frame:CreateOrGetControl("picture", "icon", c_halfW-_halfW, c_halfW-_halfW, _halfW*2, _halfW*2);
	tolua.cast(_monIcon, "ui::CPicture");  
	_monIcon:SetImage("yabaidot");
	_monIcon:SetColorTone(color);
	_monIcon:SetEnableStretch(1);

	return	_frame;

end



--◇ 範囲フレーム：アイコン周期処理
function UpdateOutFrameIcon( handle, frame )

	-- 範囲フレームが無効の場合は削除
	if g_isEnableOutside==false then
		frame:SetLinkObject(nil);
		ui.DestroyFrame("pointing_out"..handle);
		return;
	end

	-- 範囲フレーム用の処理
	local _outFrame = frame:GetLinkObject();
	if _outFrame ~= nil then
		local _icon = _outFrame:GetChild( "icon" );
		local _w, _h = g_fieldFrame:GetWidth()/2, g_fieldFrame:GetHeight()/2;
		local _posX = frame:GetX() + frame:GetWidth()/2  - _w;
		local _posY = frame:GetY() + frame:GetHeight()/2 - _h + g_height;
		local _l, _r = g_settings.outL - _w, g_fieldFrame:GetWidth()  - g_settings.outR - _w;
		local _t, _b = g_settings.outT - _h, g_fieldFrame:GetHeight() - g_settings.outB - _h;
		local _isOver = 0;	-- 0:オーバー無し, 1:左, 2:右, 3:上, 4:下

		-- 左画面オーバー
		if _posX<_l then
			_posY = _posY * (_l/_posX);
			_posX = _l;
			_isOver = 1;
		-- 右画面オーバー
		elseif _posX>_r then
			_posY = _posY * (_r/_posX);
			_posX = _r;
			_isOver = 2;
		end

		-- 上画面オーバー
		if _posY<_t then
			_posX = _posX * (_t/_posY);
			_posY = _t;
			_isOver = 3;
		-- 下画面オーバー
		elseif _posY>_b then
			_posX = _posX * (_b/_posY);
			_posY = _b;
			_isOver = 4;
		end

		-- 画面オーバーした場合
		if _isOver > 0 then

			-- 描画フラグ設定
			if _isOver == 1 then
				 g_isOutDrawTbl.l[ math.min( #g_isOutDrawTbl.l, math.floor( (_posY-_t)/((_b-_t)/#g_isOutDrawTbl.l) ) + 1 ) ] = true;
			elseif _isOver == 2 then
				 g_isOutDrawTbl.r[ math.min( #g_isOutDrawTbl.r, math.floor( (_posY-_t)/((_b-_t)/#g_isOutDrawTbl.r) ) + 1 ) ] = true;
			elseif _isOver == 3 then
				 g_isOutDrawTbl.t[ math.min( #g_isOutDrawTbl.t, math.floor( (_posX-_l)/((_r-_l)/#g_isOutDrawTbl.t) ) + 1 ) ] = true;
			else
				 g_isOutDrawTbl.b[ math.min( #g_isOutDrawTbl.b, math.floor( (_posX-_l)/((_r-_l)/#g_isOutDrawTbl.b) ) + 1 ) ] = true;
			end

			local _halfW = _outFrame:GetWidth()/2;
			_outFrame:SetPos( _posX - _halfW + _w, _posY - _halfW + _h - g_height);
			_outFrame:ShowWindow(1);
			_icon:SetAlpha(100);
			frame:GetChild( "icon" ):SetAlpha(50);

		-- 対象が画面内の場合
		else
			_icon:SetAlpha(0);
			_outFrame:ShowWindow(0);
		end

	end

end



--◇ カーソル：初期化
function InitTargetCursor()

	g_isLock = false;
	g_isSelect = false;

	local _frame = ui.GetFrame("pointing_cursor");
	if _frame == nil then
		_frame = ui.CreateNewFrame("pointing", "pointing_cursor", 0);
	end

end



--◇ カーソル：ターゲットロック
function LockTargetCursor()

	g_isLock = true;

	local _frame = ui.GetFrame("pointing_cursor");
	if _frame~=nil then
		local _picLock = _frame:GetChild("point_lock");
		if _picLock~=nil then
			_picLock:ShowWindow(1);
		end
	end

end



--◇ カーソル：ターゲットアンロック
function UnlockTargetCursor()

	g_isLock = false;

	local _frame = ui.GetFrame("pointing_cursor");
	if _frame~=nil then
		local _picLock = _frame:GetChild("point_lock");
		if _picLock~=nil then
			_picLock:ShowWindow(0);
		end
	end

end



--◇ カーソル：ターゲット選択
function SetTargetCursor( handle )

	local _frame = ui.GetFrame("pointing_cursor");

	-- カーソル対象かチェック
	local _isCheck, _isOut, _isDis, _monster = CheckPointTarget(handle);
	if _isCheck == false or _monster.MonRank == "Pet" then	-- ペットは騎乗中か否かで挙動が変わるのと、他人のはタゲれないっぽいので除外
		_frame:ShowWindow(0);
		g_isSelect = false;
		return;
	end

	-- サークルの色とサイズ取得
	local _scale, _color = GetMonsterIconDesign( _monster, handle);

 	_frame:ShowWindow(1);
	_frame:Resize(200*_scale, 220*_scale);

	-- サークル設定
	local _picCircle = _frame:GetChild("point_circle");
	if _picCircle==nil then
		_picCircle = _frame:CreateOrGetControl("picture", "point_circle", 0, 0, 220, 220);
		tolua.cast(_picCircle, "ui::CPicture");
		_picCircle:SetImage("yabaisentaku");
		_picCircle:SetEnableStretch(1);
		_picCircle:EnableHitTest(0);
		_picCircle:SetGravity(ui.CENTER_HORZ,ui.CENTER_VERT);
	end
	_picCircle:SetAngle( info.GetAngle(handle)+g_assistCurrentX );
	_picCircle:Resize(220*_scale, 220*_scale);
	_picCircle:SetColorTone(_color);

	-- ロックサークル設定
	local _picLock = _frame:GetChild("point_lock");
	if _picLock==nil then
		_picLock = _frame:CreateOrGetControl("picture", "point_lock", 0, 0, 95, 95);
		tolua.cast(_picLock, "ui::CPicture");
		_picLock:SetImage("questmap");
		_picLock:SetAngleLoop(-2);
		_picLock:SetEnableStretch(1);
		_picLock:EnableHitTest(0);
		_picLock:SetGravity(ui.CENTER_HORZ,ui.CENTER_VERT);
	end
	_picLock:Resize(95*_scale, 95*_scale);
	_picLock:SetColorTone(_color);

	-- ターゲットロック
	if g_isLock then
		_picLock:ShowWindow(1);
	else
		_picLock:ShowWindow(0);
	end

	-- 未選択状態の場合
	if g_isSelect==false then
		-- 選択音再生
		if info.IsNegativeRelation(handle) == 0 then
			if g_settings['tarSoundOther']~=1 then
				imcSound.PlaySoundEvent(g_soundTypes[g_settings['tarSoundOther']]);	-- 非敵対NPCの場合
			end
		else
			if g_settings['tarSoundMob']~=1 then
				imcSound.PlaySoundEvent(g_soundTypes[g_settings['tarSoundMob']]);	-- 敵対NPCの場合
			end
		end
	end
	g_isSelect = true;


	-- 位置設定
	FRAME_AUTO_POS_TO_OBJ(_frame, handle, - _frame:GetWidth() / 2, - _frame:GetHeight() / 2 - g_height, 0, 0);	-- ハンドルに対してフレームを、2D座標系で追随させる

	_frame:RunUpdateScript("UpdateTargetCursor");

end



--◇ カーソル：ターゲット選択解除
function ClearTargetCursor()

	local _frame = ui.GetFrame("pointing_cursor");
	if _frame~=nil then
		_frame:ShowWindow(0);
	end
	g_isSelect = false;

end



--◇ カーソル：ターゲット更新
function UpdateTargetCursor(frame)

	if g_isSelect == true then
		local _handle = session.GetTargetHandle();

		-- 有効な対象ではない場合
		local _isCheck, _isOut, _isDis, _monster, _info = CheckPointTarget(_handle);
		if _isCheck == false then
			frame:ShowWindow(0);
			g_isSelect = false;
			return	0;
		end

		-- カメラアシスト中にターゲット情報の無いオブジェクトを選択した場合
		if g_settings.isAssistDelObj==true and g_CamAssistFrag==true and (_monster==nil or _info==nil or _info.TargetWindow==0) then
			world.Leave( _handle, 0);
			frame:ShowWindow(0);
			g_isSelect = false;
			return	0;
		end

		local _picCircle = frame:GetChild("point_circle");
		local _picLock = frame:GetChild("point_lock");
		_picCircle:SetAngle( info.GetAngle(_handle)+g_assistCurrentX );
		_picCircle:SetAlpha(100);
		_picLock:SetAlpha(100);

		-- 距離による非強調をする場合
		local _textStyle = "{@st41}{s16}{#ffffff}";
		if _info ~= nil and g_settings.tarDistance ~= 0 and _isDis==true then
			if _info.distance-_info.radius > g_settings.tarDistance then
				_picCircle:SetAlpha(60);
				_picLock:SetAlpha(60);
				_textStyle = "{@st41}{s14}{#999999}";
			end
		end

		-- 対象までの距離を描写する
		local _distText = frame:CreateOrGetControl("richtext", "distance", frame:GetWidth()/2 +10, frame:GetHeight()/2 -20, 20, 20);
		if _info == nil then
			_distText:SetText("");
		else
			local _actor = world.GetActor(_handle);
			if _actor~=nil then
				_distText:SetText( string.format( "{s14}{ol}%s %d{s12}-%d", _textStyle, _info.distance, _info.radius ) );	--_actor:GetRadius()
			end
		end

	end

	return 1;
end



--◇ ポイント&カーソル：解像度によるFRAME_AUTO_POS_TO_OBJのずれを計算する
function CalcAutoPosCorrctionHeight()

	-- 1920x1080 がズレの無い状態。幅は解像度を変えても変わらないが、高さは変わる。
	-- 高さのズレは、おそらく-1080した数値の半分っぽい。
	local _h = (g_fieldFrame:GetHeight()-1080)/2;
	if g_height ~= _h then
		g_height = _h;
		return	true;
	end

	return	false;

end



--◇ ポイント&カーソル：有効な対象か判別
function CheckPointTarget(handle)

	-- ハンドルが存在しない場合
	if handle == nil or world.GetActor(handle)==nil then
		return	false, false, false, nil, nil;
	end

	-- モンスターではない場合（コンパニオンクローキングとか追加されたのでコンパニオンは除外しておく）
	local _monster = GetClass( "Monster", info.GetMonsterClassName(handle) );
	if _monster == nil or _monster.MonRank == "Pet" then
		return	false, false, false, nil, nil;
	end

	-- ターゲット不可オブジェクトの場合
	local _info = info.GetTargetInfo(handle);
	if _info==nil then
		return	false, false, false, _monster, nil;
	end

	-- 隠れている対象の場合
	local _buffCount = info.GetBuffCount(handle);
	for _i = 0, _buffCount - 1 do
		local _buff = info.GetBuffIndexed(handle, _i);
		if _buff.buffID == 148 or _buff.buffID == 271 or _buff.buffID == 9033 or _buff.buffID == 3026 or _buff.buffID == 120004 or _buff.buffID == 4544 or _buff.buffID == 6019 or _buff.buffID == 1010 or _buff.buffID == 292 then
			return	false, false, false, _monster, nil;
		end
	end

	local _str = 'OBJ';

	-- ターゲットウィンドウが出ないオブジェクトの場合
	if _info.TargetWindow==0 then
		_str = 'ETC';
	-- NPCの場合
	elseif _monster.MonRank == "NPC" then
		_str = 'NPC';
	-- ルートクリスタル
	elseif _monster.MonRank == "MISC" then
		if _monster.Faction == "RootCrystal" then
			_str = 'SP';
		end
	-- 敵対NPCの場合
	elseif info.IsNegativeRelation(handle) ~= 0 then
		_str = 'MOB';
	end

	-- ポイント対象じゃない場合
	if g_settings['isPoint'.._str]==false then
		return	false, false, false, _monster, _info;
	end

	-- 対象のHPが0の場合
	local _stat = info.GetStat(handle);
	if _stat==nil or _stat.HP<=0 then
		return	false, false, g_settings['isDisPoint'.._str], _monster, _info;
	end

	return	true, g_settings['isOutPoint'.._str], g_settings['isDisPoint'.._str], _monster, _info;

end



--◇ ポイント&カーソル：デザイン取得
function GetMonsterIconDesign( monster, handle )

	-- サークルの色とサイズを設定
	local _scale = 1;
	local _color = "FFFFFFFF";


	-- ターゲット不可(タゲ情報が出ない)オブジェクトの場合
	local _info = info.GetTargetInfo(handle);
	if _info==nil or _info.TargetWindow==0 then
		_color = "FF444444";
	-- NPCの場合
	elseif monster.MonRank == "NPC" then
		_color = "FF0044FF";
	-- その他のオブジェクト
	elseif monster.MonRank == "MISC" then
		if monster.Faction == "RootCrystal" then
			_color = "FF00FF15";
		else
			_color = "FFAAAAAA";
		end

	-- それ以外
	else
		-- 敵対NPCの場合
		if info.IsNegativeRelation(handle) ~= 0 then

			-- ボーナスチェック
			local _buffCnt = info.GetBuffCount(handle);
			for _i = 0, _buffCnt - 1 do
				local _buff = info.GetBuffIndexed(handle, _i);
				-- 金or銀
				if _buff.buffID == 5028 then
					return	2.0, "FFFCEB32", "Clover";
				-- 青
				elseif _buff.buffID == 5079 then
					return	1.7, "FF3538FF", "Clover";
				-- 赤
				elseif _buff.buffID == 5086 then
					return	1.5, "FFF435FF", "Clover";
				-- 紫
				elseif _buff.buffID == 5105 then
					return	1.5, "FFA435AA", "Clover";
				-- エリート
				elseif _buff.buffID == 5087 then
					return	1.5, "FFFF3333", "Clover";
				end
				
			end

			-- ボスモンスター
			if monster.MonRank == "Boss" then
				_color = "FFDD0000";
			-- 普通のモンスター
			else
				_color = "FFFF0000";
			end
		end

		if		monster.Size == "S"  then	_scale = 0.8;
		elseif	monster.Size == "M"  then	_scale = 1.0;
		elseif	monster.Size == "L"  then	_scale = 1.3;
		elseif	monster.Size == "XL" then	_scale = 1.7;
		end
	end


	return	_scale, _color;

end


---------------------------------------------------------------------------------------------------------------------------


--◇ 情報：初期化
function InitInformation()

	local _frame = ui.GetFrame('pointing_info');
	if _frame==nil then
		_frame = ui.CreateNewFrame( "pointing", "pointing_info", 0 );
	end

	_frame:EnableHitTest(0);				-- マウスの当たり判定無効
	_frame.EnableHittestFrame(_frame,0);	-- 〃
	_frame:EnableMove(0);
	_frame:EnableHide(1);					-- Escで消す
	_frame:SetLayerLevel(g_settings['layer']+1);
	_frame:SetSkinName('downbox');
	_frame:Resize(244,0);
	_frame:SetGravity(ui.CENTER_HORZ,ui.CENTER_VERT);
	_frame:SetAlpha(40);
	_frame:ShowWindow(0);
	_frame:SetEventScript(ui.LBUTTONUP, "MoveInformationWindow");
	_frame:RunUpdateScript('UpdateInfomation', 0, 0, 0, 1);				-- 全体周期処理

	local _chFrame = ui.GetFrame("channel");
	if g_settings['infoX']==-1 or g_settings['infoY']==-1 then
		g_settings['infoX'] = _chFrame:GetX() - _frame:GetWidth() - 45;
		g_settings['infoY'] = _chFrame:GetY();
	end
	_frame:SetOffset(g_settings['infoX'], g_settings['infoY']);


end



--◇ 情報：表示を消す
function ClearInformation()

	local _frame = ui.GetFrame("pointing_info");
	if _frame~=nil then
		_frame:ShowWindow(0);
	end

end



--◇ 情報：周期処理
function UpdateInfomation(frame)

	-- 情報ウィンドウの移動設定
	if keyboard.IsKeyPressed("LCTRL") == 1 then
		frame:EnableHitTest(1);				-- マウスの当たり判定有効
		frame.EnableHittestFrame(frame,1);	-- 〃
		frame:EnableMove(1);
	else
		frame:EnableHitTest(0);				-- マウスの当たり判定無効
		frame.EnableHittestFrame(frame,0);	-- 〃
		frame:EnableMove(0);
	end

	return	1;

end



--◇ 情報：更新
function RefreshInfomation( handle)

	local _frame = ui.GetFrame("pointing_info");
	if _frame==nil then
		return;
	end

	-- モンスターではない場合
	local _monster = GetClass( "Monster", info.GetMonsterClassName(handle) );
	if _monster == nil or _monster.MonRank == "Material" or _monster.MonRank == "Pet" or _monster.MonRank == "NPC" or _monster.MonRank == "MISC" then
		return;
	end

	-- ターゲット不可オブジェクト？の場合
	local _targetInfo = info.GetTargetInfo(handle);
	if _targetInfo==nil or _targetInfo.TargetWindow==0 then
		return;
	end

	_frame:ShowWindow(1);	-- ウィンドウ表示


	-- モンスターのステータス設定
 	_monster.Lv = _monster.Level;
 	_monster.STR = GET_MON_STAT(_monster, _monster.Lv, "STR");
 	_monster.CON = GET_MON_STAT(_monster, _monster.Lv, "CON");
 	_monster.INT = GET_MON_STAT(_monster, _monster.Lv, "INT");
 	_monster.MNA = GET_MON_STAT(_monster, _monster.Lv, "MNA");
 	_monster.DEX = GET_MON_STAT(_monster, _monster.Lv, "DEX");


	-- ステータス取得
	local _mobDef = SCR_Get_MON_DEF(_monster);
	local _mobMDef = SCR_Get_MON_MDEF(_monster);

	local _pc = GetMyPCObject();
	local _pcDef = SCR_Get_DEF(_pc);
	local _pcMDef = SCR_Get_MDEF(_pc);


	-- 表示周り
	local c_Height = 20;
	local c_LineSpace = 5;
	local _curHeight = c_LineSpace;
	local _font = "{s14}{ol}{@st41}{s15}";
	local _ctrl = nil;

	-- メイン攻撃ダメージ比率
	if g_settings.isInfoMainAtk==true then
		local _atkMain_Min	= GetDamagePer( SCR_Get_MINPATK(_pc), _mobDef);
		local _atkMain_Max	= GetDamagePer( SCR_Get_MAXPATK(_pc), _mobDef);
		_ctrl = _frame:CreateOrGetControl("richtext", "info_main_atk", 0, _curHeight, _frame:GetWidth(), c_Height);
		_ctrl:EnableHitTest(0);
		_ctrl:SetText( string.format( _font.." Main Atk    {#FFFFFF}%5.1f%% {#FFFFFF}- {#FFFFFF}%5.1f%%", _atkMain_Min, _atkMain_Max) );
		_curHeight = _curHeight + _ctrl:GetHeight();
	else
		_frame:RemoveChild( "info_main_atk" );
	end

	-- サブ攻撃ダメージ比率
	if g_settings.isInfoSubAtk==true then
		local _atkSub_Min	= GetDamagePer( SCR_Get_MINPATK_SUB(_pc), _mobDef);
		local _atkSub_Max	= GetDamagePer( SCR_Get_MAXPATK_SUB(_pc), _mobDef);
		_ctrl = _frame:CreateOrGetControl("richtext", "info_sub_atk", 0, _curHeight, _frame:GetWidth(), c_Height);
		_ctrl:EnableHitTest(0);
		_ctrl:SetText( string.format( _font.." Sub Atk     {#FFFFFF}%5.1f%% {#FFFFFF}- {#FFFFFF}%5.1f%%", _atkSub_Min, _atkSub_Max) );
		_curHeight = _curHeight + _ctrl:GetHeight();
	else
		_frame:RemoveChild( "info_sub_atk" );
	end

	-- 魔法攻撃ダメージ比率
	if g_settings.isInfoMagicAtk==true then
		local _atkMag_Min	= GetDamagePer( SCR_Get_MINMATK(_pc), _mobMDef);
		local _atkMag_Max	= GetDamagePer( SCR_Get_MAXMATK(_pc), _mobMDef);
		_ctrl = _frame:CreateOrGetControl("richtext", "info_magic_atk", 0, _curHeight, _frame:GetWidth(), c_Height);
		_ctrl:EnableHitTest(0);
		_ctrl:SetText( string.format( _font.." Magic Atk   {#FFFFFF}%5.1f%% {#FFFFFF}- {#FFFFFF}%5.1f%%", _atkMag_Min, _atkMag_Max) );
		_curHeight = _curHeight + _ctrl:GetHeight();
	else
		_frame:RemoveChild( "info_magic_atk" );
	end

	if g_settings.isInfoMainAtk==true or g_settings.isInfoSubAtk==true or g_settings.isInfoMagicAtk==true then
		_curHeight = _curHeight + c_LineSpace;
	end

	-- クリ率＆クリ抵抗
	if g_settings.isInfoCri==true then
		local _crit	 	= GetCriticalPer(  SCR_Get_CRTHR(_pc), SCR_Get_MON_CRTDR(_monster), _monster.Lv );
		local _criRes	= 100-GetCriticalPer(  SCR_Get_MON_CRTHR(_monster), SCR_Get_CRTDR(_pc), _pc.Lv );
		local _critClolor	= "{#FFFFFF}";
		local _criResClolor = "{#FFFFFF}";
		if g_settings.isInfoMaxMin == true then
			local _criMax = 50.0;
			if CHECK_ARMORMATERIAL(_pc,'Leather')==4 then _criMax = 60.0; end
			if _crit >= _criMax then _crit = _criMax; _critClolor = "{#ff7f7f}"; end
			if _crit <= 0       then _crit = 0;       _critClolor = "{#a9a9a9}"; end
			if _criRes >= 100 then _criRes = 100; _criResClolor = "{#ff7f7f}"; end
			if _criRes <= 50   then _criRes = 50; _criResClolor = "{#a9a9a9}"; end
		end
		_ctrl = _frame:CreateOrGetControl("richtext", "info_cri", 0, _curHeight, _frame:GetWidth(), c_Height);
		_ctrl:EnableHitTest(0);
		_ctrl:SetText( string.format( _font.." Cri/ CriRes ".._critClolor.."%5.1f%% {#FFFFFF}/ ".._criResClolor.."%5.1f%%", _crit, _criRes) );
		_curHeight = _curHeight + _ctrl:GetHeight();
	else
		_frame:RemoveChild( "info_cri" );
	end

	if g_settings.isInfoCri==true then
		_curHeight = _curHeight + c_LineSpace;
	end

	-- 命中＆ブロック貫通率
	if g_settings.isInfoHitPane==true then
--		local _hit	 	= 100-GetEvasionPer(SCR_Get_HR(_pc), SCR_Get_MON_DR(_monster),  );
--		local _penetr	= 100-GetBlockPer(	SCR_Get_BLK_BREAK(_pc), SCR_Get_MON_BLK(_monster), 0 );
		local _hit	 	= GetHitPer (SCR_Get_HR(_pc),        SCR_Get_MON_DR(_monster),  _pc.Lv, _monster.Lv );
		local _penetr	= GetPenePer(SCR_Get_BLK_BREAK(_pc), SCR_Get_MON_BLK(_monster), _monster.Lv, 0 );
		local _hitClolor	= "{#FFFFFF}";
		local _penetrClolor	= "{#FFFFFF}";
		if g_settings.isInfoMaxMin == true then
			if _hit >= 100 then _hit = 100; _hitClolor = "{#ff7f7f}"; end
			if _hit <= 0   then _hit = 0;   _hitClolor = "{#a9a9a9}"; end
			if _penetr >= 100 then _penetr = 100; _penetrClolor = "{#ff7f7f}"; end
			if _penetr <= 0   then _penetr = 0;   _penetrClolor = "{#a9a9a9}"; end
		end
		_ctrl = _frame:CreateOrGetControl("richtext", "info_hit", 0, _curHeight, _frame:GetWidth(), c_Height);
		_ctrl:EnableHitTest(0);
		_ctrl:SetText( string.format( _font.."{#808080} Hit/ Pene   ".._hitClolor.."%5.1f%% {#FFFFFF}/ ".._penetrClolor.."%5.1f%%", _hit, _penetr) );
		_curHeight = _curHeight + _ctrl:GetHeight();
	else
		_frame:RemoveChild( "info_hit" );
	end

	-- 回避＆ブロック率
	if g_settings.isInfoEvaBlock==true then
--		local _evasion	= GetEvasionPer(SCR_Get_MON_HR(_monster), SCR_Get_DR(_pc) );
--		local _block	= GetBlockPer(	SCR_Get_MON_BLK_BREAK(_monster), SCR_Get_BLK(_pc), 0 );
		local _evasion	= 100-GetHitPer (SCR_Get_MON_HR(_monster),        SCR_Get_DR(_pc), _monster.Lv, _pc.Lv );
		local _block	= 100-GetPenePer(SCR_Get_MON_BLK_BREAK(_monster), SCR_Get_BLK(_pc), _pc.Lv, 0 );
		local _evasionClolor	= "{#FFFFFF}";
		local _blockClolor	= "{#FFFFFF}";
		if g_settings.isInfoMaxMin == true then
			if _evasion >= 100 then _evasion = 100; _evasionClolor = "{#ff7f7f}"; end
			if _evasion <= 0   then _evasion = 0;   _evasionClolor = "{#a9a9a9}"; end
			if _block >= 100   then _block = 100;   _blockClolor = "{#ff7f7f}"; end
			if _block <= 0     then _block = 0;     _blockClolor = "{#a9a9a9}"; end
		end
		_ctrl = _frame:CreateOrGetControl("richtext", "info_eva", 0, _curHeight, _frame:GetWidth(), c_Height);
		_ctrl:EnableHitTest(0);
		_ctrl:SetText( string.format( _font.."{#808080} Eva/ Block  ".._evasionClolor.."%5.1f%% {#FFFFFF}/ ".._blockClolor.."%5.1f%%", _evasion, _block) );
		_curHeight = _curHeight + _ctrl:GetHeight();
	else
		_frame:RemoveChild( "info_eva" );
	end

	if g_settings.isInfoHitPane==true or g_settings.isInfoEvaBlock==true then
		_curHeight = _curHeight + c_LineSpace;
	end

	-- 物理ダメージ防御比率
	if g_settings.isInfoPhysiRes==true then
		local _physRes_Min	= 100-GetDamagePer( SCR_Get_MON_MINPATK(_monster), _pcDef);
		local _physRes_Max	= 100-GetDamagePer( SCR_Get_MON_MAXPATK(_monster), _pcDef);
		_ctrl = _frame:CreateOrGetControl("richtext", "info_physi_def", 0, _curHeight, _frame:GetWidth(), c_Height);
		_ctrl:EnableHitTest(0);
		_ctrl:SetText( string.format( _font.." Physi Res   {#FFFFFF}%5.1f%% {#FFFFFF}- {#FFFFFF}%5.1f%%", _physRes_Max, _physRes_Min) );
		_curHeight = _curHeight + _ctrl:GetHeight();
	else
		_frame:RemoveChild( "info_physi_def" );
	end

	-- 魔法ダメージ防御比率
	if g_settings.isInfoMagicRes==true then
		local _magRes_Min	= 100-GetDamagePer( SCR_Get_MON_MINMATK(_monster), _pcMDef);
		local _magRes_Max	= 100-GetDamagePer( SCR_Get_MON_MAXMATK(_monster), _pcMDef);
		_ctrl = _frame:CreateOrGetControl("richtext", "info_magi_def", 0, _curHeight, _frame:GetWidth(), c_Height);
		_ctrl:EnableHitTest(0);
		_ctrl:SetText( string.format( _font.." Magic Res   {#FFFFFF}%5.1f%% {#FFFFFF}- {#FFFFFF}%5.1f%%", _magRes_Max, _magRes_Min));
		_curHeight = _curHeight + _ctrl:GetHeight();
	else
		_frame:RemoveChild( "info_magi_def" );
	end

	if g_settings.isInfoPhysiRes==true or g_settings.isInfoMagicRes==true then
		_curHeight = _curHeight + c_LineSpace;
	end

	-- ゲマトリア&ノタリコン
	if g_settings.isInfoGemaNota==true then
		local _gematria		= GetGematria( _monster.SET );
		local _notarikon	= GetNotarikon( _monster.SET );
		_ctrl = _frame:CreateOrGetControl("richtext", "info_gama", 0, _curHeight, _frame:GetWidth(), c_Height);
		_ctrl:EnableHitTest(0);
		_ctrl:SetText( string.format( _font.." Gama/ Nota  {#FFFFFF}%6d {#FFFFFF}/ {#FFFFFF}%2d", _gematria, _notarikon) );
		_curHeight = _curHeight + _ctrl:GetHeight();
	else
		_frame:RemoveChild( "info_gama" );
	end

	-- 現在の高さ分詰める
	_curHeight = _curHeight + c_LineSpace;
	_frame:Resize( _frame:GetWidth(), _ctrl:GetY() + _ctrl:GetHeight() + 5);

	_frame:SetOffset(g_settings['infoX'], g_settings['infoY']);

end



--◇ 情報：ダメージ率を求める
function GetDamagePer( atk, def)
	return math.min(1, math.log10((atk / (def + 1)) ^ 0.9 + 1)) * 100;
end



--◇ 情報：共通計算式
--https://treeofsavior.com/page/news/view.php?n=1882
function CommonBattleFormula( atk, def, defLevel)
	if def>atk then
		return	0;
	end
	return	(math.log10( ( (atk-def) / (defLevel*15) * 100 ) + 6.01)*2.303 / 0.05827 - 30.8) * 0.8
end


--◇ 情報：クリティカル率を求める
--function GetCriticalPer( crit, critRes)
--	return math.max(0, crit - critRes) ^ 0.6;
--end
--function GetCriticalPer( crit, critRes)
--	return (math.max(0, crit / math.max(1,critRes) ) ^ 0.6-1) * 100;
--end
function GetCriticalPer( crit, critRes, defLevel)
	return	10 + CommonBattleFormula( crit, critRes, defLevel);
end



--◇ 情報：回避率を求める
--function GetEvasionPer( hit, avoid)
--	return (math.max(0, avoid - hit) ^ 0.65);
--end
--function GetEvasionPer( hit, avoid)
--	return (math.max(0, avoid / math.max(1,hit) ) ^ 0.37-1) * 100;
--end
function GetHitPer( hit, avoid, atkLevel, defLevel)
--	return	90 + CommonBattleFormula( hit, avoid, defLevel) + (atkLevel-defLevel)*2;
	return	90 + CommonBattleFormula( hit, avoid, defLevel) * ((atkLevel-defLevel)*0.02+1);
end



--◇ 情報：ブロック率を求める
--function GetBlockPer( pene, block, addPer)
--	return (math.max(0, block - pene) ^ 0.7 + addPer);
--end
--function GetBlockPer( pene, block, addPer)
--	return (math.max(0, block / math.max(1,pene) ) ^ 0.7-1) * 100 + addPer;
--end
function GetPenePer( pene, block, defLevel, addPer)
	return	70 + CommonBattleFormula( pene, block, defLevel) - addPer;
end



--◇ 情報：ゲマトリア
function GetGematria( name )
	-- ゲマトリアはSET内の文字を数字にして全部足した1桁目
	local _gema = 0;
	local _len = string.len(name);
	for _i = 1, _len do
		_gema = _gema + string.byte( string.sub(name,_i,_i) )
	end
	_gema = _gema % 10
	return	_gema;
end



--◇ 情報：ノタリコン
function GetNotarikon( name )
	-- ゲマトリアはSET内の文字を数字にして全部足した1桁目
	local _nota = 0;
	local _len = string.len(name);
	_nota = _nota + string.byte( string.sub(name,1,1) );
	_nota = _nota + string.byte( string.sub(name,_len,_len) );
	_nota = _nota % 10
	return	_nota;
end



--◇ 情報：ウィンドウが動かされた場合の処理
function MoveInformationWindow()

	local _frame = ui.GetFrame("pointing_info");
	if _frame~=nil then
		g_settings['infoX'] = _frame:GetX();
		g_settings['infoY'] = _frame:GetY();
		PointingSaveSetting();	-- 設定を保存
	end

end



---------------------------------------------------------------------------------------------------------------------------
--◆ カメラアシスト
local g_assistTimer = imcTime.GetAppTime();
local g_assistTimeElapsed = 0;
local g_assistSwitch = 1;

local g_assistMouseX = nil;
local g_assistMouseX2 = nil;
local g_assistMouseY = nil;
local g_assistMouseY2 = nil;

local g_nowAssistZoom = 0;		-- アシスト処理用
local g_nowAssistPosX = 0;
local g_nowAssistPosY = 0;
local g_nowAssistPosZ = 0;



--◇ カメラアシスト：初期化
function InitCameraAssist()

	local _frame = ui.GetFrame('pointing_camera_assist');
	if _frame==nil then
		_frame = ui.CreateNewFrame( "pointing", "pointing_camera_assist", 0 );
	end

	_frame:EnableHitTest(0);				-- マウスの当たり判定無効
	_frame.EnableHittestFrame(_frame,0);	-- 〃
	_frame:EnableMove(0);
--	_frame:EnableHide(1);					-- Escで消す
	_frame:SetLayerLevel(61);
	_frame:SetSkinName('');
	if g_settings.isAssistDrawInfo==true then
		_frame:Resize(60,60);
	else
		_frame:Resize(0,0);
	end
	_frame:SetBorder(0, 0, 0, 0);
	_frame:SetGravity(ui.CENTER_HORZ,ui.CENTER_VERT);
	_frame:SetAlpha(40);
	_frame:ShowWindow(1);
	_frame:SetEventScript(ui.LBUTTONUP, "MoveCameraAssistWindow");
	_frame:RunUpdateScript('UpdateCameraAssist', 0, 0, 0, 1);			-- 周期処理
	_frame:SetOffset(g_settings['assistWindowX'], g_settings['assistWindowY']);

	CameraAssistSetText();

	camera.CamRotate(g_assistCurrentY, g_assistCurrentX);
	camera.CustomZoom(g_settings.assistZoom);


end



--◇ カメラアシスト：表示を消す
function ClearCameraAssist()

	local _frame = ui.GetFrame("pointing_camera_assist");
	if _frame~=nil then
		_frame:ShowWindow(0);
	end

	camera.CamRotate(38, 45);
	camera.CustomZoom(240);	-- デフォが240ぐらい
	if g_check==false then
		camera.ChangeCamera(0, 0, 0, 0, 0, 0.5, 1.0, 0);
	end

end



--◇ カメラアシスト：右クリックで視点変更処理
function UpdateCameraAssistAngle(frame)

	-- アシストが無効の場合は抜ける
	if g_isEnableAssist==false then
		return 1;
	end

	local _frame = ui.GetFrame("pointing_camera_assist");
	if _frame==nil then
		return 1;
	end

	-- Ctrl+右クリックでカメラを回転させる処理
	if keyboard.IsKeyPressed("LCTRL") == 1 then
		if mouse.IsRBtnPressed() == 1 then
			g_assistTimeElapsed = imcTime.GetAppTime() - g_assistTimer;
			if g_assistTimeElapsed >= 0.05 and g_assistSwitch == 1 then
				g_assistMouseX = mouse.GetX();
				g_assistMouseY = mouse.GetY();
				g_assistMouseX2 = mouse.GetX();
				g_assistMouseY2 = mouse.GetY();
				g_assistTimeElapsed = 0;
				g_assistSwitch = 2;
			end
			if g_assistTimeElapsed >= 0.05 and g_assistSwitch == 2 then
				g_assistMouseX2 = mouse.GetX();
				g_assistMouseY2 = mouse.GetY();
				g_assistTimeElapsed = 0;
				g_assistSwitch = 1;
			end
			if g_assistMouseX < g_assistMouseX2 then
				local _rightX = g_assistMouseX2 - g_assistMouseX;
				local _rightX2 = math.ceil(_rightX / 5);
				g_assistCurrentX = g_assistCurrentX - _rightX2;
			end
			if g_assistMouseX > g_assistMouseX2 then
				local _leftX = g_assistMouseX - g_assistMouseX2;
				local _leftX2 = math.ceil(_leftX / 5);
				g_assistCurrentX = g_assistCurrentX + _leftX2;
			end
			if g_assistMouseY > g_assistMouseY2 then
				local _upY = g_assistMouseY - g_assistMouseY2;
				local _upY2 = math.ceil(_upY / 5);
				g_assistCurrentY = g_assistCurrentY - _upY2;
			end
			if g_assistMouseY < g_assistMouseY2 then
				local _downY = g_assistMouseY2 - g_assistMouseY;
				local _downY2 = math.ceil(_downY / 5);
				g_assistCurrentY = g_assistCurrentY + _downY2;
			end
			-- 範囲内に補正
			if g_assistCurrentX < MINIMUM_XY then
				g_assistCurrentX = MAXIMUM_XY;
			elseif g_assistCurrentX > MAXIMUM_XY then
				g_assistCurrentX = MINIMUM_XY;
			elseif g_assistCurrentY < MINIMUM_XY then
				g_assistCurrentY = MAXIMUM_XY;
			elseif g_assistCurrentY > MAXIMUM_XY then
				g_assistCurrentY = MINIMUM_XY;
			end
			-- 
			camera.CamRotate(g_assistCurrentY, g_assistCurrentX);
			CameraAssistSetText();
		else
			g_assistMouseX = nil;
			g_assistMouseY = nil;
			g_assistMouseX2 = nil;
			g_assistMouseY2 = nil;
		end
	end

	return	1;

end



--◇ カメラアシスト：周期処理
local g_CamAssistAtkFrag = false;
function UpdateCameraAssist(frame)

	-- ◆ アシストが無効の場合は抜ける
	if g_isEnableAssist==false then
		return 1;
	end

	-- ◆イベント中はアシスト全体的に無効
	local _frameBuff = ui.GetFrame('headsupdisplay');
	if _frameBuff~=nil and _frameBuff:IsVisible()==0 then
		return	1;
	end

	-- ◆情報ウィンドウの移動設定
	if keyboard.IsKeyPressed("LCTRL") == 1 then
		frame:EnableHitTest(1);				-- マウスの当たり判定有効
		frame.EnableHittestFrame(frame,1);	-- 〃
		frame:EnableMove(1);
	else
		frame:EnableHitTest(0);				-- マウスの当たり判定無効
		frame.EnableHittestFrame(frame,0);	-- 〃
		frame:EnableMove(0);
	end

	-- ◆ズーム処理
	if keyboard.IsKeyPressed("NEXT") == 1 then
		CameraAssistZoom( 1 );
	elseif keyboard.IsKeyPressed("PRIOR") == 1 then
		CameraAssistZoom( -1 );
	end
	if keyboard.IsKeyPressed("LCTRL") == 1 then
		if keyboard.IsKeyPressed("NEXT") == 1 then
			CameraAssistZoom( 5 );
		elseif keyboard.IsKeyPressed("PRIOR") == 1 then
			CameraAssistZoom( -5 );
		end
	end


	-- ◆ターゲットアシスト処理
	local _isAssist = keyboard.IsKeyPressed("LCTRL") ~= 1 and g_settings.isAssistRC == true and mouse.IsRBtnPressed() == 1;
	if _isAssist==true then
--		_frameBuff = ui.GetFrame('timeaction');				if _frameBuff~=nil and _frameBuff:IsVisible()==1 then _isAssist = false end
		_frameBuff = ui.GetFrame('inventory');				if _frameBuff~=nil and _frameBuff:IsVisible()==1 then _isAssist = false end
		_frameBuff = ui.GetFrame('party');					if _frameBuff~=nil and _frameBuff:IsVisible()==1 then _isAssist = false end
		_frameBuff = ui.GetFrame('friend');					if _frameBuff~=nil and _frameBuff:IsVisible()==1 then _isAssist = false end
		_frameBuff = ui.GetFrame('skillability');			if _frameBuff~=nil and _frameBuff:IsVisible()==1 then _isAssist = false end
		_frameBuff = ui.GetFrame('pointing_setting_sub');	if _frameBuff~=nil and _frameBuff:IsVisible()==1 then _isAssist = false end
--		_frameBuff = ui.GetFrame('fishing_item_bag');		if _frameBuff~=nil and _frameBuff:IsVisible()==1 then _isAssist = false end
	end
	if _isAssist==true then

		local _ratio = (math.max(math.abs(g_settings.assistZoom - g_settings.assistRightZoom)*0.5, 100) * 0.001);

		-- ズーム
--		g_nowAssistZoom = g_nowAssistZoom + (g_settings.assistZoom*(g_settings.assistZoomRatio*0.01) - g_nowAssistZoom) * 0.1;
		g_nowAssistZoom = g_nowAssistZoom + (g_settings.assistRightZoom - g_nowAssistZoom) * _ratio;

		-- ムーブ
		local _mx = mouse.GetX()/ui.GetRatioWidth();
		local _my = mouse.GetY()/ui.GetRatioHeight()-g_height;
		local _radX = g_assistCurrentX/180*3.14159;

		_mx = (_mx - (g_fieldFrame:GetWidth()*0.5) ) * (g_settings.assistMoveRatioX*0.001);
		_my = ((g_fieldFrame:GetHeight()*0.5) - _my) * (g_settings.assistMoveRatioY*0.001);

		local _mx2 = _mx*math.cos(_radX) - _my*math.sin(_radX);
		local _my2 = _mx*math.sin(_radX) + _my*math.cos(_radX);
		local _pos = GetMyActor():GetPos();

		g_nowAssistPosX = g_nowAssistPosX + (_pos.x+_mx2 - g_nowAssistPosX) * _ratio;
		g_nowAssistPosY = g_nowAssistPosY + (_pos.y - g_nowAssistPosY) * 0.05;
		g_nowAssistPosZ = g_nowAssistPosZ + (_pos.z+_my2 - g_nowAssistPosZ) * _ratio;

		camera.ChangeCamera(1, 0, g_nowAssistPosX, g_nowAssistPosY, g_nowAssistPosZ, 0, 1, 0);	-- 2=秒,3=割合

--		-- 右クリックの方向を向かせる
--		local _myActor = GetMyActor();
--		if _myActor:IsSkillState() == false then
--			local _isBuff = false;
--			local _buffCount = info.GetBuffCount(_myActor:GetHandleVal());
--			for _i = 0, _buffCount - 1 do
--				local _buff = info.GetBuffIndexed(_myActor:GetHandleVal(), _i);
--				if _buff.buffID == 3084 then
--					_isBuff = true;
--					break;
--				end
--			end
--
--			if _isBuff == false then
--				_myActor:SetRotate( math.atan2(_my2,_mx2) * 180 / 3.14159 );
--			end
--		end

--		-- 右クリック方向転換2:攻撃した瞬間当たり判定が出るのでこれは無意味だった
--		local _myActor = GetMyActor();
--		if g_CamAssistAtkFrag==false and _myActor:IsSkillState() == true then
--			local _skillID = _myActor:GetUseSkill();
--			local _sklName = GetClassByType("Skill", _skillID).ClassName;
--			if _sklName == "Normal_Attack" or _sklName == "Normal_Attack_TH" or _sklName == "Common_StaffAttack" or _sklName == "Common_DaggerAries" then
--				g_CamAssistAtkFrag = true;
--				_myActor:SetRotate( math.atan2(_my2,_mx2) * 180 / 3.14159 );
--			end
--		else
--			g_CamAssistAtkFrag=false;
--		end

		if g_CamAssistFrag == false then
			g_CamAssistFrag = true;

			-- 各種ウィンドウの当たり判定を消す
			local _frameBuff2 = nil;
			_frameBuff2 = ui.GetFrame('questinfoset_2');	if _frameBuff2 ~= nil then	_frameBuff2:EnableHitTest(0);	end
			_frameBuff2 = ui.GetFrame('minimap');			if _frameBuff2 ~= nil then	_frameBuff2:EnableHitTest(0);	end
			_frameBuff2 = ui.GetFrame('partyinfo');			if _frameBuff2 ~= nil then	_frameBuff2:EnableHitTest(0);	end
			_frameBuff2 = ui.GetFrame('chatframe');			if _frameBuff2 ~= nil then	_frameBuff2:EnableHitTest(0);	end
			_frameBuff2 = ui.GetFrame('challenge_mode');	if _frameBuff2 ~= nil then	_frameBuff2:EnableHitTest(0);	end

		end

		-- プレイヤーを消去する（消したままPvPが開始されることもあるかもしれないので復帰側は判定しない）
		if g_settings.isAssistDrawPC == true then
			if g_check==false and g_isPvPMap==false then
				graphic.SetDrawActor(-100);
				local _listMob, _cntMob = SelectObject(GetMyPCObject(), 800, "ALL");
				for _i = 1, _cntMob do
					local _handle = GetHandle( _listMob[_i] );
					if _listMob[_i].ClassName == 'PC' and session.GetMyHandle()~= _handle then
						movie.ShowModel( _handle, 0);
						local _frameShop = ui.GetFrame( "SELL_BALLOON_".._handle);
						if _frameShop~=nil and _frameShop:IsVisible()==1 then
							_frameShop:Resize( _frameShop:GetWidth(), 0);
						end
						local _frameCharInfo = ui.GetFrame( "charbaseinfo1_".._handle);
						if _frameCharInfo~=nil and _frameCharInfo:IsVisible()==1 then
							_frameCharInfo:Resize( _frameCharInfo:GetWidth(), 0);
						end
					end
				end
			end
		end

	else
		-- ズーム
		g_nowAssistZoom = (g_settings.assistZoom + g_nowAssistZoom) * 0.5;

		-- ムーブ
		local _pos = GetMyActor():GetPos();
		g_nowAssistPosX = (_pos.x + g_nowAssistPosX) * 0.5;
		g_nowAssistPosY = (_pos.y + g_nowAssistPosY) * 0.5;
		g_nowAssistPosZ = (_pos.z + g_nowAssistPosZ) * 0.5;

		camera.ChangeCamera(0, 0, 0, 0, 0, 0.5, 1.0, 0);

		if g_CamAssistFrag == true then
			g_CamAssistFrag = false;

			-- 各種ウィンドウの当たり判定を戻す
			local _frameBuff2 = nil;
			_frameBuff2 = ui.GetFrame('questinfoset_2');	if _frameBuff2 ~= nil then	_frameBuff2:EnableHitTest(1);	end
			_frameBuff2 = ui.GetFrame('minimap');			if _frameBuff2 ~= nil then	_frameBuff2:EnableHitTest(1);	end
			_frameBuff2 = ui.GetFrame('partyinfo');			if _frameBuff2 ~= nil then	_frameBuff2:EnableHitTest(1);	end
			_frameBuff2 = ui.GetFrame('chatframe');			if _frameBuff2 ~= nil then	_frameBuff2:EnableHitTest(1);	end
			_frameBuff2 = ui.GetFrame('challenge_mode');	if _frameBuff2 ~= nil then	_frameBuff2:EnableHitTest(1);	end

			-- プレイヤーの表示を戻す
			graphic.SetDrawActor(100);
			local _listMob, _cntMob = SelectObject(GetMyPCObject(), 800, "ALL");
			for _i = 1, _cntMob do
				local _handle = GetHandle( _listMob[_i] );
				if _listMob[_i].ClassName == 'PC' and session.GetMyHandle()~= _handle then
					movie.ShowModel( _handle, 1);
					local _frameShop = ui.GetFrame( "SELL_BALLOON_".._handle);
					if _frameShop~=nil and _frameShop:IsVisible()==1 and _frameShop:GetWidth()~=0 then
						_frameShop:Resize( 300, 100);
					end
					if g_isEnableHideName==false then
						local _frameCharInfo = ui.GetFrame( "charbaseinfo1_".._handle);
						if _frameCharInfo~=nil and _frameCharInfo:IsVisible()==1 then
							_frameCharInfo:Resize( _frameCharInfo:GetWidth(), 150);
						end
					end
				end
			end

		end

	end

	camera.CustomZoom( g_nowAssistZoom, 0, 1);	-- 2=秒,3=割合

	return 1;

end



--◇ カメラアシスト：ウィンドウが動かされた場合の処理
function MoveCameraAssistWindow()

	local _frame = ui.GetFrame("pointing_camera_assist");
	if _frame~=nil then
		g_settings['assistWindowX'] = _frame:GetX();
		g_settings['assistWindowY'] = _frame:GetY();
		PointingSaveSetting();	-- 設定を保存
	end

end



--◇ カメラアシスト：テキスト設定
function CameraAssistSetText()

	local _frame = ui.GetFrame("pointing_camera_assist");
	if _frame~=nil then
		local _textZ = _frame:CreateOrGetControl("richtext","textZ",0,-20,0,0);
		_textZ = tolua.cast(_textZ,"ui::CRichText");
		_textZ:SetGravity(ui.LEFT,ui.CENTER_VERT);
		_textZ:EnableHitTest(0);
		_textZ:SetText("{s16}{#B81313}{ol}Z : " .. g_settings.assistZoom);

		local _textX = _frame:CreateOrGetControl("richtext","textX",0,0,0,0);
		_textX = tolua.cast(_textX,"ui::CRichText");
		_textX:SetGravity(ui.LEFT,ui.CENTER_VERT);
		_textX:EnableHitTest(0);
		_textX:SetText("{s16}{#B81313}{ol}X : " .. g_assistCurrentX);

		local _textY = _frame:CreateOrGetControl("richtext","textY",0,20,0,0);
		_textY = tolua.cast(_textY,"ui::CRichText");
		_textY:SetGravity(ui.LEFT,ui.CENTER_VERT);
		_textY:EnableHitTest(0);
		_textY:SetText("{s16}{#B81313}{ol}Y : " .. g_assistCurrentY);
	end

end



--◇ カメラアシスト：ズーム
function CameraAssistZoom( num )
	g_settings.assistZoom = g_settings.assistZoom + num;

	if g_settings.assistZoom < MINIMUM_ZOOM then
		g_settings.assistZoom = MINIMUM_ZOOM;
	elseif g_settings.assistZoom > MAXIMUM_ZOOM then
		g_settings.assistZoom = MAXIMUM_ZOOM;
	end

	CameraAssistSetText();
	PointingSaveSetting();	-- 設定を保存
end


---------------------------------------------------------------------------------------------------------------------------



--◇ 名称非表示：クリア
function ClearHideName()

	local _frameMyInfo = ui.GetFrame( "charbaseinfo1_my");
	if _frameMyInfo~=nil and _frameMyInfo:IsVisible()==1 then
		_frameMyInfo:Resize( _frameMyInfo:GetWidth(), 150);
	end

	local _listMob, _cntMob = SelectObject( GetMyPCObject(), 800, 'ALL');
	for _i = 1, _cntMob do
		local _handle = GetHandle( _listMob[_i] );
		-- プレイヤー
		if _listMob[_i].ClassName=='PC' and session.GetMyHandle()~=_handle then
			local _frameCharInfo = ui.GetFrame( "charbaseinfo1_".._handle);
			if _frameCharInfo~=nil and _frameCharInfo:IsVisible()==1 then
				_frameCharInfo:Resize( _frameCharInfo:GetWidth(), 150);
			end
		else
			-- コンパニオン
			local _companion = GetClass( "Companion", info.GetMonsterClassName(_handle) );
			if _companion ~= nil then
				local _framePetInfo = ui.GetFrame( "companion_".._handle);
				if _framePetInfo~=nil and _framePetInfo:IsVisible()==1 then
					_framePetInfo:Resize( _framePetInfo:GetWidth(), 110);
				end
			end
		end
	end

end



--◇ 名称非表示：全体周期処理
function UpdateHideName(frame)

	-- 名称非表示が無効の場合は抜ける
	if g_isEnableHideName==false then
		return 1;
	end

	local _mx = mouse.GetX()/ui.GetRatioWidth();
	local _my = mouse.GetY()/ui.GetRatioHeight()-g_height;

	-- 自分の名称
	local _frameMyInfo = ui.GetFrame( "charbaseinfo1_my");
	if _frameMyInfo~=nil and _frameMyInfo:IsVisible()==1 then

		local _isDraw = false;
		if g_settings.isHideNameSalf==false then
			_isDraw = true;
		end

		-- カーソルの近くを表示するかチェック
		if g_settings.isHideNameShowSelect  and _isDraw==false then
			-- Ctrlキーが押されているかチェック
			if g_settings.isHideNameShowCtrl==false or keyboard.IsKeyPressed("LCTRL") == 1 then
				local _posX = _frameMyInfo:GetX();
				local _posY = _frameMyInfo:GetY();
				_posX = _posX + _frameMyInfo:GetWidth()*0.5;
				local _dist = math.pow( (_posX - _mx)*(_posX - _mx) + (_posY - _my)*(_posY - _my), 0.5 );
				if _dist < 75 then
					_isDraw = true;
				end
			end
		end

		if _isDraw then
			_frameMyInfo:Resize( _frameMyInfo:GetWidth(), 150);
		else
			_frameMyInfo:Resize( _frameMyInfo:GetWidth(), 0);
			CreateHideNameGauge( session.GetMyHandle(), "Salf" );
		end
	end

	-- PTとその他の名称
	local _listMob, _cntMob = SelectObject( GetMyPCObject(), 800, 'ALL');
	for _i = 1, _cntMob do
		local _handle = GetHandle( _listMob[_i] );
		if _listMob[_i].ClassName=='PC' and session.GetMyHandle()~=_handle then
			local _frameCharInfo = ui.GetFrame( "charbaseinfo1_".._handle);
			if _frameCharInfo~=nil and _frameCharInfo:IsVisible()==1 then

				-- PTメンバーか否か取得
				local _isPt = false;
				local _listPt = session.party.GetPartyMemberList( PARTY_NORMAL);
				if _listPt ~= nil then
					local _cntPt = _listPt:Count();
					for _i = 0 , _cntPt - 1 do
						local _info = _listPt:Element(_i);
						if _info ~= nil and _info:GetHandle()==_handle then
							_isPt = true;
							break;
						end
					end
				end

				-- PTメンバーのチェック
				local _isDraw = false;
				if g_settings.isHideNamePt==false and _isPt then
					_isDraw = true;
				-- その他のプレイヤーのチェック
				elseif g_settings.isHideNameEtc==false and _isPt==false then
					_isDraw = true;
				end

				-- カーソルの近くを表示するかチェック
				if g_settings.isHideNameShowSelect and (g_settings.isHideNamePvP and g_isPvPMap)==false and _isDraw==false then
					-- Ctrlキーが押されているかチェック
					if g_settings.isHideNameShowCtrl==false or keyboard.IsKeyPressed("LCTRL")==1 then
						local _posX = _frameCharInfo:GetX();
						local _posY = _frameCharInfo:GetY();
						_posX = _posX + _frameCharInfo:GetWidth()*0.5;
						local _dist = math.pow( (_posX - _mx)*(_posX - _mx) + (_posY - _my)*(_posY - _my), 0.5 );
						if _dist < 75 then
							_isDraw = true;
						end
					end
				end

				-- 表示非表示設定
				if _isDraw then
					_frameCharInfo:Resize( _frameCharInfo:GetWidth(), 150);
				else
					_frameCharInfo:Resize( _frameCharInfo:GetWidth(), 0);
					if _isPt then
						CreateHideNameGauge( _handle, "Pt" );
					else
						CreateHideNameGauge( _handle, "Etc" );
					end
				end
			end
		else
			-- コンパニオン
			local _companion = GetClass( "Companion", info.GetMonsterClassName(_handle) );
			if _companion ~= nil then

				local _framePetInfo = ui.GetFrame( "companion_".._handle);
				if _framePetInfo~=nil and _framePetInfo:IsVisible()==1 then

					local _isDraw = false;
					if g_settings.isHideNamePet==false then
						_isDraw = true;
					end

					-- カーソルの近くを表示するかチェック
					if g_settings.isHideNameShowSelect and (g_settings.isHideNamePvP and g_isPvPMap)==false and _isDraw==false then
						-- Ctrlキーが押されているかチェック
						if g_settings.isHideNameShowCtrl==false or keyboard.IsKeyPressed("LCTRL") == 1 then
							local _posX = _framePetInfo:GetX();
							local _posY = _framePetInfo:GetY();
							_posX = _posX + _framePetInfo:GetWidth()*0.5;
							local _dist = math.pow( (_posX - _mx)*(_posX - _mx) + (_posY - _my)*(_posY - _my), 0.5 );
							if _dist < 75 then
								_isDraw = true;
							end
						end
					end

					if _isDraw then
						_framePetInfo:Resize( _framePetInfo:GetWidth(), 110);
					else
						_framePetInfo:Resize( _framePetInfo:GetWidth(), 0);
					end

				end

			end
		end
	end

	return	1;

end



-- 名称非表示：ゲージフレームの作成
function CreateHideNameGauge( handle, target )

	local _frame = ui.GetFrame( "pointing_gage_info"..handle );
	if (_frame == nil) then
		_frame = ui.CreateNewFrame("pointing", "pointing_gage_info"..handle, 0);
		_frame:SetLayerLevel( 96 );
		_frame:EnableHitTest(0);
		_frame:Resize( 100, 30);
		_frame:ShowWindow(1);
		FRAME_AUTO_POS_TO_OBJ( _frame, handle, -50, -15+37, 100, 20);
		_frame:RunUpdateScript( 'UpdateHideNameGauge'..target, 0, 0, 0, 1);
	end

end



-- 名称非表示：ゲージ一つの描画
function DrawHideNameGauge( frame, gaugeType, min, max, skin, y, h)

	local _resourceGauge = frame:CreateOrGetControl("gauge", gaugeType, 0, y, 100, h);
	tolua.cast(_resourceGauge, "ui::CGauge");
	_resourceGauge:SetPoint( min, max);
	_resourceGauge:SetGravity( ui.CENTER_HORZ, ui.TOP);
	_resourceGauge:SetSkinName( skin );
	_resourceGauge:Resize(_resourceGauge:GetWidth(), _resourceGauge:GetHeight() );
	_resourceGauge:Invalidate();

end



-- プレイヤーのHP取得
local function GetPlayerHP( handle )

	local _stat = info.GetStat( handle );
	if _stat ~= nil then
		return _stat.HP, _stat.maxHP
	end

	return 0, 0

end



-- プレイヤーのSP取得
local function GetPlayerSP( handle )

	local _stat = info.GetStat( handle );
	if _stat ~= nil then
		return _stat.SP, _stat.maxSP
	end

	return 0, 0

end



-- プレイヤーのSTA取得
local function GetPlayerSTA( handle )

	local _stat = info.GetStat( handle );
	if _stat ~= nil then
		return _stat.Stamina, _stat.MaxStamina
	end

	return 0, 0

end



-- コンパニオンのスタミナ取得
local function GetPetStamina()

	local _petInfo = session.pet.GetSummonedPet();
	if _petInfo ~= nil then
		local _petObj = GetIES(_petInfo:GetObject());
		return _petObj.Stamina, _petObj.MaxStamina;
	end

	return 0, 0

end



--◇ 名称非表示：自分の周期処理
function UpdateHideNameGaugeSalf(frame)

	local _handle = frame:GetUserIValue("_AT_OFFSET_HANDLE");    -- FRAME_AUTO_POS_TO_OBJで設定されたハンドル取得？

	-- 削除
	if frame:IsVisible() == 0 then
		ui.DestroyFrame("pointing_gage_info".._handle);
		return 0;
	end

	-- 対象が存在しない場合・・・消去
	if g_isEnableHideName==false or _handle==nil or world.GetActor(_handle)==nil then
		frame:ShowWindow(0);
		return 1;
	end

	-- 元のキャラクター名が表示されていないか、Pointingによって隠されていない場合は削除
	local _frameInfo = ui.GetFrame( "charbaseinfo1_my");
	if _frameInfo==nil or _frameInfo:IsVisible()==0 or _frameInfo:GetHeight()~=0 then
		ui.DestroyFrame("pointing_gage_info".._handle);
		return 0;
	end


	-- ◆ゲージ表示
	local _min, _max;

	-- ペットのスタミナ
	_min,_max = GetPetStamina();
	if g_settings.hideNameSalfPet~=-1 and _max~=0 and (_min/_max<=g_settings.hideNameSalfPet*0.01) and world.GetActor( _handle ):GetVehicleState()==true then
		DrawHideNameGauge( frame, "petStaminaGauge", _min, _max, "pcinfo_gauge_sta1", 2, 3)
	else
		frame:RemoveChild("petStaminaGauge")
	end

	-- HP表示
	_min,_max = GetPlayerHP( _handle );
	if g_settings.hideNameSalfHP~=-1 and _max~=0 and (_min/_max<=g_settings.hideNameSalfHP*0.01) then
		DrawHideNameGauge( frame, "pcHpGauge", _min, _max, "pcinfo_gauge_hp2", 7, 4)
	else
		frame:RemoveChild("pcHpGauge")
	end

	-- SP表示
	_min,_max = GetPlayerSP( _handle );
	if g_settings.hideNameSalfMP~=-1 and _max~=0 and (_min/_max<=g_settings.hideNameSalfMP*0.01) then
		DrawHideNameGauge( frame, "pcMpGauge", _min, _max, "pcinfo_gauge_sp2", 12, 4)
	else
		frame:RemoveChild("pcMpGauge")
	end

	-- スタミナ表示
	_min,_max = GetPlayerSTA( _handle );
	if g_settings.hideNameSalfSTA~=-1 and _max~=0 and (_min/_max<=g_settings.hideNameSalfSTA*0.01) then
		DrawHideNameGauge( frame, "pcSpGauge", _min, _max, "pcinfo_gauge_sta2", 17, 4)
	else
		frame:RemoveChild("pcSpGauge")
	end

	frame:Invalidate();

	return	1;

end



--◇ 名称非表示：PTの周期処理
function UpdateHideNameGaugePt(frame)

	local _handle = frame:GetUserIValue("_AT_OFFSET_HANDLE");    -- FRAME_AUTO_POS_TO_OBJで設定されたハンドル取得？

	-- 削除
	if frame:IsVisible() == 0 then
		ui.DestroyFrame("pointing_gage_info".._handle);
		return 0;
	end

	-- 対象が存在しない場合・・・消去
	if g_isEnableHideName==false or _handle==nil or world.GetActor(_handle)==nil then
		frame:ShowWindow(0);
		return 1;
	end

	-- 元のキャラクター名が表示されていないか、Pointingによって隠されていない場合は削除
	local _frameInfo = ui.GetFrame( "charbaseinfo1_".._handle);
	if _frameInfo==nil or _frameInfo:IsVisible()==0 or _frameInfo:GetHeight()~=0 then
		ui.DestroyFrame("pointing_gage_info".._handle);
		return 0;
	end

	-- ◆ゲージ表示
	local _min, _max;

	-- HP表示
	_min,_max = GetPlayerHP( _handle );
	if g_settings.hideNamePtHP~=-1 and _max~=0 and (_min/_max<=g_settings.hideNamePtHP*0.01) then
		DrawHideNameGauge( frame, "pcHpGauge", _min, _max, "pcinfo_gauge_hp2", 7, 4)
	else
		frame:RemoveChild("pcHpGauge")
	end

	-- SP表示
	_min,_max = GetPlayerSP( _handle );
	if g_settings.hideNamePtMP~=-1 and _max~=0 and (_min/_max<=g_settings.hideNamePtMP*0.01) then
		DrawHideNameGauge( frame, "pcMpGauge", _min, _max, "pcinfo_gauge_sp2", 12, 4)
	else
		frame:RemoveChild("pcMpGauge")
	end

	frame:Invalidate();

	return	1;

end



--◇ 名称非表示：それ以外の周期処理
function UpdateHideNameGaugeEtc(frame)

	local _handle = frame:GetUserIValue("_AT_OFFSET_HANDLE");    -- FRAME_AUTO_POS_TO_OBJで設定されたハンドル取得？

	-- 削除
	if frame:IsVisible() == 0 then
		ui.DestroyFrame("pointing_gage_info".._handle);
		return 0;
	end

	-- 対象が存在しない場合・・・消去
	if g_isEnableHideName==false or _handle==nil or world.GetActor(_handle)==nil then
		frame:ShowWindow(0);
		return 1;
	end

	-- 元のキャラクター名が表示されていないか、Pointingによって隠されていない場合は削除
	local _frameInfo = ui.GetFrame( "charbaseinfo1_".._handle);
	if _frameInfo==nil or _frameInfo:IsVisible()==0 or _frameInfo:GetHeight()~=0 then
		ui.DestroyFrame("pointing_gage_info".._handle);
		return 0;
	end

	-- ◆ゲージ表示
	local _min, _max;

	-- HP表示
	_min,_max = GetPlayerHP( _handle );
	if _max~=0 and ((g_settings.hideNameEtcHP~=-1 and (_min/_max<=g_settings.hideNameEtcHP*0.01) or (g_settings.isHideNamePvP and g_isPvPMap))) then
		DrawHideNameGauge( frame, "pcHpGauge", _min, _max, "pcinfo_gauge_hp2", 7, 4);
	else
		frame:RemoveChild("pcHpGauge");
	end

	-- SP表示
	_min,_max = GetPlayerSP( _handle );
	if _max~=0 and ((g_settings.hideNameEtcMP~=-1 and (_min/_max<=g_settings.hideNameEtcMP*0.01) or (g_settings.isHideNamePvP and g_isPvPMap))) then
		DrawHideNameGauge( frame, "pcMpGauge", _min, _max, "pcinfo_gauge_sp2", 12, 4);
	else
		frame:RemoveChild("pcMpGauge");
	end

	frame:Invalidate();

	return	1;

end



---------------------------------------------------------------------------------------------------------------------------


--◇ マウスカーソル：初期化
function InitMouseCursor()

	if g_settings.isMouseCursor==false then
		return;
	end

	g_isMousFadeIn = false;
	g_mousFadeAlpha = 0;

	local _frame = ui.GetFrame('pointing_mouse');
	if _frame==nil then
		_frame = ui.CreateNewFrame( "pointing", "pointing_mouse", 0 );
	end

	local _size = 80*g_settings.mouseSize/100;

	_frame:EnableHitTest(0);				-- マウスの当たり判定無効
	_frame.EnableHittestFrame(_frame,0);	-- 〃

	_frame:EnableHide(0);					-- Escで消す
	_frame:SetLayerLevel(g_settings.mousePrio);
	_frame:SetSkinName('none');
	_frame:Resize(_size,_size);
	_frame:SetGravity(ui.CENTER_HORZ,ui.CENTER_VERT);
	_frame:SetAlpha(40);
	_frame:ShowWindow(1);
	_frame:SetOffset( mouse.GetX()/ui.GetRatioWidth()-_size/2, mouse.GetY()/ui.GetRatioHeight()-g_height-_size/2 );

	local _picCursor = _frame:GetChild("cursor");
	if _picCursor==nil then
		_picCursor = _frame:CreateOrGetControl("picture", "cursor", 0, 0, _size, _size);
		tolua.cast(_picCursor, "ui::CPicture");
		_picCursor:SetImage("yabaicursor");
		_picCursor:SetEnableStretch(1);
		_picCursor:EnableHitTest(0);
		_picCursor:SetGravity(ui.CENTER_HORZ,ui.CENTER_VERT);
	end
	_picCursor:Resize(_size, _size);
	_picCursor:SetColorTone( string.format("%02x%02x%02x%02x",255*(g_settings.mouseColorA*0.01),255*(g_settings.mouseColorR*0.01),255*(g_settings.mouseColorG*0.01),255*(g_settings.mouseColorB*0.01)) );
	_picCursor:SetAlpha(g_settings.mouseColorA);

	_frame:RunUpdateScript('UpdateMouseCursor', 0.01);					-- マウスカーソル強調周期処理：0.01秒に一度更新

	UpdateMouseCursor(_frame);

end



--◇ マウスカーソル：表示を消す
function ClearMouseCursor()

	local _frame = ui.GetFrame("pointing_mouse");
	if _frame~=nil then
		_frame:ShowWindow(0);
	end

end



--◇ マウスカーソル：周期処理
function UpdateMouseCursor(frame)

	if g_settings.isMouseCursor==false then
		ClearMouseCursor();
		return 0;
	end

	if frame==nil then
		return	0;
	end

	local _size = 80*g_settings.mouseSize/100;
	frame:SetOffset( mouse.GetX()/ui.GetRatioWidth()-_size/2, mouse.GetY()/ui.GetRatioHeight()-g_height-_size/2 );

	-- 点滅させる場合
	if g_settings.isMouseFlash==true then
		local _picCursor = frame:GetChild("cursor");
		if _picCursor==nil then
			return	1;
		end

		local _add = g_settings.mouseColorA / g_settings.mouseInterval;

		-- フェードイン
		if g_isMousFadeIn == true then
			g_mousFadeAlpha = g_mousFadeAlpha + _add;
			if g_mousFadeAlpha>g_settings.mouseColorA then
				g_mousFadeAlpha = g_settings.mouseColorA;
				g_isMousFadeIn = false
			end
		-- フェードアウト
		else
			g_mousFadeAlpha = g_mousFadeAlpha - _add;
			if g_mousFadeAlpha <= g_settings.mouseColorA/8 then
				g_mousFadeAlpha = g_settings.mouseColorA/8;
				g_isMousFadeIn = true
			end
		end
		_picCursor:SetAlpha(g_mousFadeAlpha);
	end

	return	1;

end


---------------------------------------------------------------------------------------------------------------------------


--◇ その他：オブジェクト非表示
function PointingHideTarget( handle )

	-- オブジェクト非表示
	if world.GetActor( info.GetOwner(handle) ) == nil then
		return	false;
	end

	-- ペットかどうかの判定
	local _isPet = false;
	local _monster = GetClass( "Monster", info.GetMonsterClassName(handle) );
	if _monster ~= nil then
		if _monster.MonRank == "Pet" then
			_isPet = true;
		end
	end

    -- 自分が所有しているオブジェクト
    if info.GetOwner(handle) == session.GetMyHandle() then
        return  false;
    end

	-- PTメンバーが所有しているオブジェクト
	local _listPt = session.party.GetPartyMemberList( PARTY_NORMAL);
	if _listPt ~= nil then
		local _cntPt = _listPt:Count();
		for _i = 0 , _cntPt - 1 do
			if info.GetOwner(handle) == _listPt:Element(_i):GetHandle() then
				if _isPet==true then
					if g_settings.isHidePointPtRide==true and world.GetActor(info.GetOwner(handle)):GetVehicleState()==true then
						world.Leave( handle, 0);
						return	true;
					elseif g_settings.isHidePointPtPet==true and world.GetActor(info.GetOwner(handle)):GetVehicleState()==false then
						world.Leave( handle, 0);
						return	true;
					end
				end
				if _isPet==false and g_settings.isHidePointPtObj==true then
					world.Leave( handle, 0);
					return	true;
				end
				return	false;
			end
		end
	end

	-- それ以外が所有しているオブジェクト
	if _isPet==true then
		if g_settings.isHidePointRide==true and world.GetActor(info.GetOwner(handle)):GetVehicleState()==true then
			world.Leave( handle, 0);
			return	true;
		elseif g_settings.isHidePointPet==true and world.GetActor(info.GetOwner(handle)):GetVehicleState()==false then
			world.Leave( handle, 0);
			return	true;
		end
	end
	if _isPet==false and g_settings.isHidePointObj==true and g_check==false then
		world.Leave( handle, 0);
		return	true;
	end

	return	false;

end


---------------------------------------------------------------------------------------------------------------------------


--◇ セッティング：設定ロード
function PointingLoadSetting()

	g_saves.version = g_saveVer;
	g_saves.active = shallowcopy(g_default);
	g_saves.save1 = shallowcopy(g_default);
	g_saves.save2 = shallowcopy(g_default);
	g_saves.save3 = shallowcopy(g_default);

	local _s, _err = g_acutil.loadJSON("../addons/pointing/settings.json");

	-- 正常にセーブデータが読み込まれた場合
	if _err or _s.version == nil or _s.version ~= g_saveVer then
	else
		g_saves = _s;
	end

--	-- セーブデータが存在しないか、バージョンが違う場合…クリア
--	if _err or _s.version == nil or _s.version ~= g_saveVer then
--		g_saves.version = g_saveVer;
--		g_saves.active = shallowcopy(g_default);
--		g_saves.save1 = shallowcopy(g_default);
--		g_saves.save2 = shallowcopy(g_default);
--		g_saves.save3 = shallowcopy(g_default);
--
--	else
--		g_saves = _s;
--	end

	g_settings = shallowcopy(g_saves.active);
	PointingSaveSetting();

end



--◇ セッティング：設定セーブ
function PointingSaveSetting()

	g_saves.active = shallowcopy(g_settings);
	g_acutil.saveJSON("../addons/pointing/settings.json", g_saves);

end



--◇ セッティング：セッティング画面を生成
function CreateSettingFrame()

	PointingLoadSetting();
	g_isToggleOn = false;
	PointingFragSet();
	InitAll();

	-- フレーム
	_frame = ui.CreateNewFrame('pointing','pointing_setting');
	_frame:EnableHitTest(1);
	_frame.EnableHittestFrame(_frame,1);
	_frame:EnableMove(1);
	_frame:EnableHide(1);
	_frame:SetLayerLevel(100);
	_frame:SetSkinName('tooltip1');
	_frame:SetAlpha(75);
	_frame:Resize(490,395);
	_frame:SetGravity(ui.CENTER_HORZ,ui.CENTER_VERT);
	_frame:SetEventScript(ui.RBUTTONUP,'CloseSettingFrame');

	-- ヘッダー
	CreatePointingText( _frame, 'header1', '{s24}Pointing Settings', 0, 15, 200, 55, ui.CENTER_HORZ, ui.TOP);

	-- ×ボタン
	CreatePointingButton( _frame, 'close', 'X', 445, 15, 30, 30, 'test_pvp_btn', 'CloseSettingFrame')

	-- トグルボタン setting, caption, x, y, w, h
	local _h = 32;
	CreatePointingToggleButton( _frame, 'isEnableCircle',  'Target Circle', 30, 55,      200, 32);	-- ターゲットサークルが有効か否か
	CreatePointingToggleButton( _frame, 'isEnablePoint',   '   Pointing  ', 30, 55+_h*1, 200, 32);	-- ターゲットポイントが有効か否か
	CreatePointingToggleButton( _frame, 'isMouseCursor',   'Mouse Cursor ', 30, 55+_h*2, 200, 32);	-- マウスカーソルの強調が有効か否か
	CreatePointingToggleButton( _frame, 'isEnableInfo',    ' Target Info ', 30, 55+_h*3, 200, 32);	-- ターゲット情報が有効か否か
	CreatePointingToggleButton( _frame, 'isEnableAssist',  'Camera Assist', 30, 55+_h*4, 200, 32);	-- カメラアシストが有効化否か
	CreatePointingToggleButton( _frame, 'isEnableHideName','  Hide Name  ', 30, 55+_h*5, 200, 32);	-- 名称非表示が有効化否か

	-- 設定ウィンドウボタン
	CreatePointingButton( _frame, 'p_ste', '{#ffffff}Point Status',  248, 55+_h*0, 200, 30, '', 'CreatePointStateFrame')				-- ポイント対象設定ボタン
	CreatePointingButton( _frame, 'p_set', '{#ffffff}Point Target',  248, 55+_h*1, 200, 30, '', 'CreatePointTargetFrame')
	CreatePointingButton( _frame, 'p_cur', '{#ffffff}Mouse Cursor',  248, 55+_h*2, 200, 30, '', 'CreatePointMouseCursorSettingFrame')
	CreatePointingButton( _frame, 'p_inf', '{#ffffff}Target Info',   248, 55+_h*3, 200, 30, '', 'CreatePointTargetInfoFrame')
	CreatePointingButton( _frame, 'p_cam', '{#ffffff}Camera Assist', 248, 55+_h*4, 200, 30, '', 'CreatePointCameraAssistFrame')
	CreatePointingButton( _frame, 'p_hid', '{#ffffff}Hide Name',     248, 55+_h*5, 200, 30, '', 'CreatePointHideNameFrame')

	-- ドロップダウンリスト setting, caption, list, x, y, w, h, capW
	CreatePointingDropDownList( _frame, 'tarSoundMob'  , 'Mob Sound', g_soundTypes, 35, 272, 415, 30, 95);	-- モンスター選択音
	CreatePointingDropDownList( _frame, 'tarSoundOther', 'Etc Sound', g_soundTypes, 35, 299, 415, 30, 95);	-- モンスター以外の選択音

	-- コマンド確認
	CreatePointingButton( _frame, 'cmd', '{#555500}chat command help', 30, 339, 193, 30, 'test_pvp_btn', 'PointingCheckCommand')

	-- セッティングリセット
	CreatePointingButton( _frame, 'reset', '{#ff0000}reset all settings', 262, 339, 193, 30, 'test_pvp_btn', 'PointingResetSettings')

end



--◇ セッティング：セッティング画面を閉じる
function CloseSettingFrame()

	local _frame = ui.GetFrame('pointing_setting');

	if _frame ~= nil then
		_frame:ShowWindow(0)
	end

end



--◇ セッティング：ポイントステータス設定画面
function CreatePointStateFrame( frame, control, argString, argNumber)

	-- 設定画面を閉じる
	CloseSettingFrame();

	-- フレーム
	_frame = ui.CreateNewFrame('pointing','pointing_setting_sub');
	_frame:EnableHitTest(1);
	_frame.EnableHittestFrame(_frame,1);
	_frame:EnableMove(1);
	_frame:EnableHide(1);
	_frame:SetLayerLevel(100);
	_frame:SetSkinName('tooltip1');
	_frame:SetAlpha(75);
	_frame:Resize(245,322);
	_frame:SetGravity(ui.CENTER_HORZ,ui.CENTER_VERT);
	_frame:SetEventScript(ui.RBUTTONUP,'ClosePointTargetFrame');

	-- ヘッダ
	CreatePointingText( _frame, 'header1', '{s24}Point Status  ', 0, 15, 200, 55, ui.CENTER_HORZ, ui.TOP);
	CreatePointingButton( _frame, 'close', 'X', 200, 15, 30, 30, 'test_pvp_btn', 'ClosePointTargetFrame')

	-- アップダウンボタン setting, caption, x, y, w, h, capW, numW, minNum, maxNum, addNumL,  addNumR
	CreatePointingUpDownButton( _frame, 'layer',      'Layer       :', 30,  55, 200, 32, 113, 30, 0, 100, 1, 10);	-- 全体の描画優先度
	CreatePointingUpDownButton( _frame, 'iconSize',   'Icon Size   :', 30,  84, 200, 32, 113, 30, 1, 50,  1, 10);	-- アイコンサイズ
	CreatePointingUpDownButton( _frame, 'tarDistance','Distance    :', 30, 113, 200, 32, 113, 30, 0, 500, 1, 10);	-- 非強調する距離

	-- 外枠
	CreatePointingCheckBox( _frame, 'isEnableOutside' , 'Outside Frame', 30, 142+8, 30,30, g_settings['isEnableOutside' ] );

	local _maxW = g_fieldFrame:GetWidth()/2 - 10;
	local _maxH = g_fieldFrame:GetHeight()/2 - 10;
	CreatePointingUpDownButton( _frame, 'outL',      'L:', 30+5,  176, 100, 32, 15, 30, 1, _maxW, 1, 10);			-- 枠左幅
	CreatePointingUpDownButton( _frame, 'outR',      'R:', 30+98, 176, 100, 32, 15, 30, 1, _maxW, 1, 10);			-- 枠右幅
	CreatePointingUpDownButton( _frame, 'outT',      'T:', 30+5,  201, 100, 32, 15, 30, 1, _maxH, 1, 10);			-- 枠上幅
	CreatePointingUpDownButton( _frame, 'outB',      'B:', 30+98, 201, 100, 32, 15, 30, 1, _maxH, 1, 10);			-- 枠下幅
	CreatePointingUpDownButton( _frame, 'outW',      'W:', 30+5,  226, 100, 32, 15, 30, 1, g_outMaxLenW, 1, 10);	-- 上下枠分割数
	CreatePointingUpDownButton( _frame, 'outH',      'H:', 30+98, 226, 100, 32, 15, 30, 1, g_outMaxLenH, 1, 10);	-- 左右枠分割数
	CreatePointingUpDownButton( _frame, 'outColorA', 'A:', 30+5,  251, 100, 32, 15, 30, 0, 100,   1, 10);			-- 枠の透明度
	CreatePointingUpDownButton( _frame, 'outColorR', 'R:', 30+98, 251, 100, 32, 15, 30, 0, 100,   1, 10);			-- 枠のカラー
	CreatePointingUpDownButton( _frame, 'outColorG', 'G:', 30+5,  276, 100, 32, 15, 30, 0, 100,   1, 10);
	CreatePointingUpDownButton( _frame, 'outColorB', 'B:', 30+98, 276, 100, 32, 15, 30, 0, 100,   1, 10);

end



--◇ セッティング：ポイントステータス設定画面を閉じる
function ClosePointStateFrame()

	local _frame = ui.GetFrame('pointing_setting_sub');
	if _frame ~= nil then
		_frame:ShowWindow(0);
	end

	PointingSaveSetting();

	CreateSettingFrame();

end



--◇ セッティング：ポイント対象設定画面
function CreatePointTargetFrame( frame, control, argString, argNumber)

	-- 設定画面を閉じる
	CloseSettingFrame();

	-- フレーム
	_frame = ui.CreateNewFrame('pointing','pointing_setting_sub');
	_frame:EnableHitTest(1);
	_frame.EnableHittestFrame(_frame,1);
	_frame:EnableMove(1);
	_frame:EnableHide(1);
	_frame:SetLayerLevel(100);
	_frame:SetSkinName('tooltip1');
	_frame:SetAlpha(75);
	_frame:Resize(375,484-32);
	_frame:SetGravity(ui.CENTER_HORZ,ui.CENTER_VERT);
	_frame:SetEventScript(ui.RBUTTONUP,'ClosePointTargetFrame');

	-- ×ボタン
	CreatePointingButton( _frame, 'close', 'X', 330, 15, 30, 30, 'test_pvp_btn', 'ClosePointTargetFrame')

	-- ポイントターゲット
	CreatePointingText( _frame, 'header1', '{s24}Point Target', 0, 15, 200, 55, ui.CENTER_HORZ, ui.TOP);
	CreatePointingCheckBox( _frame, 'isPointPT' , 'Party',	25,    45,   30,30, g_settings['isPointPT' ] );
	CreatePointingCheckBox( _frame, 'isPointNPC', 'NPC',	25+115,45,   30,30, g_settings['isPointNPC'] );
	CreatePointingCheckBox( _frame, 'isPointMOB', 'Enemy',	25+230,45,   30,30, g_settings['isPointMOB'] );
	CreatePointingCheckBox( _frame, 'isPointSP' , 'Crystal',25,    45+32,30,30, g_settings['isPointSP' ] );
	CreatePointingCheckBox( _frame, 'isPointOBJ', 'Object',	25+115,45+32,30,30, g_settings['isPointOBJ'] );
	CreatePointingCheckBox( _frame, 'isPointETC', 'Etc Obj',25+230,45+32,30,30, g_settings['isPointETC'] );
	CreatePointingCheckBox( _frame, 'isPointPC' , 'Player',	25,    45+64,30,30, g_settings['isPointPC' ] );

	-- 外枠ターゲット
	CreatePointingText( _frame, 'header2', '{s24}Outside Target', 0, 139, 200, 55, ui.CENTER_HORZ, ui.TOP);
	CreatePointingCheckBox( _frame, 'isOutPointPT' , 'Party',	25,    169,   30,30, g_settings['isOutPointPT' ] );
	CreatePointingCheckBox( _frame, 'isOutPointNPC', 'NPC',		25+115,169,   30,30, g_settings['isOutPointNPC'] );
	CreatePointingCheckBox( _frame, 'isOutPointMOB', 'Enemy',	25+230,169,   30,30, g_settings['isOutPointMOB'] );
	CreatePointingCheckBox( _frame, 'isOutPointSP' , 'Crystal',	25,    169+32,30,30, g_settings['isOutPointSP' ] );
	CreatePointingCheckBox( _frame, 'isOutPointOBJ', 'Object',	25+115,169+32,30,30, g_settings['isOutPointOBJ'] );
	CreatePointingCheckBox( _frame, 'isOutPointETC', 'Etc Obj',	25+230,169+32,30,30, g_settings['isOutPointETC'] );

	-- 距離対象
	CreatePointingText( _frame, 'header3', '{s24}Distance Target', 0, 241, 200, 55, ui.CENTER_HORZ, ui.TOP);
	CreatePointingCheckBox( _frame, 'isDisPointPT' , 'Party',	25,    271,   30,30, g_settings['isDisPointPT' ] );
	CreatePointingCheckBox( _frame, 'isDisPointNPC', 'NPC',		25+115,271,   30,30, g_settings['isDisPointNPC'] );
	CreatePointingCheckBox( _frame, 'isDisPointMOB', 'Enemy',	25+230,271,   30,30, g_settings['isDisPointMOB'] );
	CreatePointingCheckBox( _frame, 'isDisPointSP' , 'Crystal',	25,    271+32,30,30, g_settings['isDisPointSP' ] );
	CreatePointingCheckBox( _frame, 'isDisPointOBJ', 'Object',	25+115,271+32,30,30, g_settings['isDisPointOBJ'] );
	CreatePointingCheckBox( _frame, 'isDisPointETC', 'Etc Obj',	25+230,271+32,30,30, g_settings['isDisPointETC'] );

	-- 非表示対象
	CreatePointingText( _frame, 'header4', '{s24}Hide Target', 0, 343, 200, 55, ui.CENTER_HORZ, ui.TOP);
	CreatePointingCheckBox( _frame, 'isHidePointPtRide', 'PT Ride',	25    ,373,   30,30, g_settings['isHidePointPtRide'] );
	CreatePointingCheckBox( _frame, 'isHidePointPtPet',  'PT Pet',	25+115,373,   30,30, g_settings['isHidePointPtPet'] );
	CreatePointingCheckBox( _frame, 'isHidePointPtObj',  'PT Obj',	25+230,373,   30,30, g_settings['isHidePointPtObj' ] );
	CreatePointingCheckBox( _frame, 'isHidePointRide',   'Etc Ride',25    ,373+32,30,30, g_settings['isHidePointRide'] );
	CreatePointingCheckBox( _frame, 'isHidePointPet',    'Etc Pet',	25+115,373+32,30,30, g_settings['isHidePointPet'] );
	CreatePointingCheckBox( _frame, 'isHidePointObj',    'Etc Obj',	25+230,373+32,30,30, g_settings['isHidePointObj'] );

end



--◇ セッティング：ポイント対象設定画面を閉じる
function ClosePointTargetFrame()

	local _frame = ui.GetFrame('pointing_setting_sub');
	if _frame ~= nil then
		_frame:ShowWindow(0);
	end

	PointingSaveSetting();

	CreateSettingFrame();

end



--◇ セッティング：マウスカーソル強調設定画面
function CreatePointMouseCursorSettingFrame( frame, control, argString, argNumber)

	-- 設定画面を閉じる
	CloseSettingFrame();

	-- フレーム
	_frame = ui.CreateNewFrame('pointing','pointing_setting_sub');
	_frame:EnableHitTest(1);
	_frame.EnableHittestFrame(_frame,1);
	_frame:EnableMove(1);
	_frame:EnableHide(1);
	_frame:SetLayerLevel(100);
	_frame:SetSkinName('tooltip1');
	_frame:SetAlpha(75);
	_frame:Resize(245,267);
	_frame:SetGravity(ui.CENTER_HORZ,ui.CENTER_VERT);
	_frame:SetEventScript(ui.RBUTTONUP,'ClosePointMouseCursorSettingFrame');

	-- ヘッダ
	CreatePointingText( _frame, 'header1', '{s24}Mouse Cursor  ', 0, 15, 200, 55, ui.CENTER_HORZ, ui.TOP);
	CreatePointingButton( _frame, 'close', 'X', 200, 15, 30, 30, 'test_pvp_btn', 'ClosePointMouseCursorSettingFrame')

	-- プライオリティ
	CreatePointingUpDownButton( _frame, 'mousePrio',   'Priority:', 30+5, 55,    200, 32, 100, 30, 0, 200, 1, 10);	-- プライオリティ
	CreatePointingUpDownButton( _frame, 'mouseSize',   'Size(%) :', 30+5, 55+28, 200, 32, 100, 30, 1, 200, 1, 10);	-- サイズ

	-- カラー
	CreatePointingUpDownButton( _frame, 'mouseColorA', 'A:', 30+5,  55+64, 100, 32, 15, 30, 0, 100,   1, 10);		-- 透明度
	CreatePointingUpDownButton( _frame, 'mouseColorR', 'R:', 30+98, 55+64, 100, 32, 15, 30, 0, 100,   1, 10);		-- カラー
	CreatePointingUpDownButton( _frame, 'mouseColorG', 'G:', 30+5,  55+92, 100, 32, 15, 30, 0, 100,   1, 10);
	CreatePointingUpDownButton( _frame, 'mouseColorB', 'B:', 30+98, 55+92, 100, 32, 15, 30, 0, 100,   1, 10);

	-- 点滅するか否か
	CreatePointingCheckBox( _frame, 'isMouseFlash', 'Mouse Flash',	30+5,  55+128, 30, 30, g_settings['isMouseFlash'] );

	-- 点滅周期(ms)SetDuration(0.5秒)
	CreatePointingUpDownButton( _frame, 'mouseInterval', 'Interval:', 30+5, 55+156, 200, 32, 100, 30, 10, 100, 1, 10);

end



--◇ セッティング：マウスカーソル強調設定画面を閉じる
function ClosePointMouseCursorSettingFrame()

	local _frame = ui.GetFrame('pointing_setting_sub');
	if _frame ~= nil then
		_frame:ShowWindow(0);
	end

	PointingSaveSetting();

	CreateSettingFrame();

end



--◇ セッティング：ターゲット情報設定画面
function CreatePointTargetInfoFrame( frame, control, argString, argNumber)

	-- 設定画面を閉じる
	CloseSettingFrame();

	-- フレーム
	_frame = ui.CreateNewFrame('pointing','pointing_setting_sub');
	_frame:EnableHitTest(1);
	_frame.EnableHittestFrame(_frame,1);
	_frame:EnableMove(1);
	_frame:EnableHide(1);
	_frame:SetLayerLevel(100);
	_frame:SetSkinName('tooltip1');
	_frame:SetAlpha(75);
	_frame:Resize(305,379);
	_frame:SetGravity(ui.CENTER_HORZ,ui.CENTER_VERT);
	_frame:SetEventScript(ui.RBUTTONUP,'ClosePointMouseCursorSettingFrame');

	-- ヘッダ
	CreatePointingText( _frame, 'header1', '{s24}Target Information ', 0, 15, 200, 55, ui.CENTER_HORZ, ui.TOP);
	CreatePointingButton( _frame, 'close', 'X', 260, 15, 30, 30, 'test_pvp_btn', 'ClosePointTargetInfoFrame')

	-- カメラ情報を表示するか否か
	CreatePointingCheckBox( _frame, 'isInfoMainAtk',	'Main Attack',			30+5,  55+28*0,   30, 30, g_settings['isInfoMainAtk'] );
	CreatePointingCheckBox( _frame, 'isInfoSubAtk',		'Sub Attack',			30+5,  55+28*1,   30, 30, g_settings['isInfoSubAtk'] );
	CreatePointingCheckBox( _frame, 'isInfoMagicAtk',	'Magic Attack',			30+5,  55+28*2,   30, 30, g_settings['isInfoMagicAtk'] );
	CreatePointingCheckBox( _frame, 'isInfoCri',		'Critical & Resist',	30+5,  55+28*3,   30, 30, g_settings['isInfoCri'] );
	CreatePointingCheckBox( _frame, 'isInfoHitPane',	'Hit & Penetration',	30+5,  55+28*4,   30, 30, g_settings['isInfoHitPane'] );
	CreatePointingCheckBox( _frame, 'isInfoEvaBlock',	'Evasion & Block',		30+5,  55+28*5,   30, 30, g_settings['isInfoEvaBlock'] );
	CreatePointingCheckBox( _frame, 'isInfoPhysiRes',	'Physical Resist',		30+5,  55+28*6,   30, 30, g_settings['isInfoPhysiRes'] );
	CreatePointingCheckBox( _frame, 'isInfoMagicRes',	'Magic Resist',			30+5,  55+28*7,   30, 30, g_settings['isInfoMagicRes'] );
	CreatePointingCheckBox( _frame, 'isInfoGemaNota',	'Gematria & Notarikon',	30+5,  55+28*8,   30, 30, g_settings['isInfoGemaNota'] );

	CreatePointingCheckBox( _frame, 'isInfoMaxMin',		'Apply limits.',		30+5,  55+28*9+14,30, 30, g_settings['isInfoMaxMin'] );

end



--◇ セッティング：ターゲット情報設定画面を閉じる
function ClosePointTargetInfoFrame()

	local _frame = ui.GetFrame('pointing_setting_sub');
	if _frame ~= nil then
		_frame:ShowWindow(0);
	end

	PointingSaveSetting();

	CreateSettingFrame();

end



--◇ セッティング：カメラアシスト設定画面
function CreatePointCameraAssistFrame( frame, control, argString, argNumber)

	-- 設定画面を閉じる
	CloseSettingFrame();

	-- フレーム
	_frame = ui.CreateNewFrame('pointing','pointing_setting_sub');
	_frame:EnableHitTest(1);
	_frame.EnableHittestFrame(_frame,1);
	_frame:EnableMove(1);
	_frame:EnableHide(1);
	_frame:SetLayerLevel(100);
	_frame:SetSkinName('tooltip1');
	_frame:SetAlpha(75);
	_frame:Resize(245,297);
	_frame:SetGravity(ui.CENTER_HORZ,ui.CENTER_VERT);
	_frame:SetEventScript(ui.RBUTTONUP,'ClosePointMouseCursorSettingFrame');

	-- ヘッダ
	CreatePointingText( _frame, 'header1', '{s24}Camera Assist ', 0, 15, 200, 55, ui.CENTER_HORZ, ui.TOP);
	CreatePointingButton( _frame, 'close', 'X', 200, 15, 30, 30, 'test_pvp_btn', 'ClosePointCameraAssistFrame')

	-- カメラ情報を表示するか否か
	CreatePointingCheckBox( _frame, 'isAssistDrawInfo', 'Camera Information',	30+5,  55,   30, 30, g_settings['isAssistDrawInfo'] );


	-- 右クリックズーム
	CreatePointingCheckBox( _frame, 'isAssistRC',     'Right Click Zoom',	30+5,  89,    30, 30, g_settings['isAssistRC'] );		-- 右クリックズームが有効か否か
	CreatePointingCheckBox( _frame, 'isAssistDrawPC', 'Hide Players',		50+5,  89+28, 30, 30, g_settings['isAssistDrawPC'] );	-- ズーム中、PCを非表示にするか否か
	CreatePointingCheckBox( _frame, 'isAssistDelObj', 'Delete Object',		50+5,  89+56, 30, 30, g_settings['isAssistDelObj'] );	-- ズーム中、カーソルに触れたオブジェクトを消去するか否か

	-- 数値
	CreatePointingUpDownButton( _frame, 'assistRightZoom',  'ZoomDistance:', 30+5, 180,    200, 32, 100, 30, 50, 1500, 1, 10);	-- アシスト時のズーム距離
	CreatePointingUpDownButton( _frame, 'assistMoveRatioX', 'MoveRatioX:  ', 30+5, 180+28, 200, 32, 100, 30, 0, 900, 1, 10);	-- アシスト時の移動係数
	CreatePointingUpDownButton( _frame, 'assistMoveRatioY', 'MoveRatioY:  ', 30+5, 180+56, 200, 32, 100, 30, 0, 900, 1, 10);	-- アシスト時の移動係数

end



--◇ セッティング：カメラアシスト設定画面を閉じる
function ClosePointCameraAssistFrame()

	local _frame = ui.GetFrame('pointing_setting_sub');
	if _frame ~= nil then
		_frame:ShowWindow(0);
	end

	PointingSaveSetting();

	CreateSettingFrame();

end



--◇ セッティング：名称非表示設定画面
function CreatePointHideNameFrame( frame, control, argString, argNumber)

	-- 設定画面を閉じる
	CloseSettingFrame();

	-- フレーム
	_frame = ui.CreateNewFrame('pointing','pointing_setting_sub');
	_frame:EnableHitTest(1);
	_frame.EnableHittestFrame(_frame,1);
	_frame:EnableMove(1);
	_frame:EnableHide(1);
	_frame:SetLayerLevel(100);
	_frame:SetSkinName('tooltip1');
	_frame:SetAlpha(75);
	_frame:Resize(315,416);
	_frame:SetGravity(ui.CENTER_HORZ,ui.CENTER_VERT);
	_frame:SetEventScript(ui.RBUTTONUP,'ClosePointMouseCursorSettingFrame');

	-- ヘッダ
	CreatePointingText( _frame, 'header1', '{s24}Hide Name ', 0, 15, 200, 55, ui.CENTER_HORZ, ui.TOP);
	CreatePointingButton( _frame, 'close', 'X', 270, 15, 30, 30, 'test_pvp_btn', 'ClosePointHideNameFrame')

	-- カメラ情報を表示するか否か
	CreatePointingCheckBox( _frame, 'isHideNameShowSelect', 'Show players near cursor.',	30+5,  55,    30, 30, g_settings['isHideNameShowSelect'] );
	CreatePointingCheckBox( _frame, 'isHideNameShowCtrl',   'With the Ctrl key.',			50+5,  55+28,    30, 30, g_settings['isHideNameShowCtrl'] );
	CreatePointingCheckBox( _frame, 'isHideNamePvP',        'Enable PvP Privacy Mode.',		30+5,  83+34, 30, 30, g_settings['isHideNamePvP'] );

	-- プレイヤー情報
	CreatePointingCheckBox( _frame, 'isHideNameSalf',  'Hide Salf Name.',	30+5,  151,    30, 30, g_settings['isHideNameSalf'] );	-- 自分の名前を隠すか否か
	CreatePointingUpDownButton( _frame, 'hideNameSalfHP',  'HP%:',  50+5,  151+28, 200, 32, 40, 30, -1, 100, 1, 10);	-- 　HP表示敷居％
	CreatePointingUpDownButton( _frame, 'hideNameSalfMP',  'MP%:',  170+5, 151+28, 200, 32, 40, 30, -1, 100, 1, 10);	-- 　MP表示敷居％
	CreatePointingUpDownButton( _frame, 'hideNameSalfSTA', 'STA%:', 50+5,  151+56, 200, 32, 40, 30, -1, 100, 1, 10);	-- 　STA表示敷居％
	CreatePointingUpDownButton( _frame, 'hideNameSalfPet', 'Pet%:', 170+5, 151+56, 200, 32, 40, 30, -1, 100, 1, 10);	-- 　Pet空腹表示敷居％

	-- PTメンバー情報
	CreatePointingCheckBox( _frame, 'isHideNamePt',  'Hide PT Name.',	30+5,  241,    30, 30, g_settings['isHideNamePt'] );	-- PTメンバーの名前を隠すか否か
	CreatePointingUpDownButton( _frame, 'hideNamePtHP',  'HP%:',  50+5,  241+28, 200, 32, 40, 30, -1, 100, 1, 10);	-- 　HP表示敷居％
	CreatePointingUpDownButton( _frame, 'hideNamePtMP',  'MP%:',  170+5, 241+28, 200, 32, 40, 30, -1, 100, 1, 10);	-- 　MP表示敷居％

	-- その他のプレイヤー情報
	CreatePointingCheckBox( _frame, 'isHideNameEtc',  'Hide Etc Name.',	30+5,  303,    30, 30, g_settings['isHideNameEtc'] );	-- その他のプレイヤーの名前を隠すか否か
	CreatePointingUpDownButton( _frame, 'hideNameEtcHP',  'HP%:',  50+5,  303+28, 200, 32, 40, 30, -1, 100, 1, 10);	-- 　HP表示敷居％
	CreatePointingUpDownButton( _frame, 'hideNameEtcMP',  'MP%:',  170+5, 303+28, 200, 32, 40, 30, -1, 100, 1, 10);	-- 　MP表示敷居％

	-- コンパニオン
	CreatePointingCheckBox( _frame, 'isHideNamePet',  'Hide Pet Name.',	30+5,  365,    30, 30, g_settings['isHideNamePet'] );	-- コンパニオンの名前を隠すか否か

end



--◇ セッティング：カメラアシスト設定画面を閉じる
function ClosePointHideNameFrame()

	local _frame = ui.GetFrame('pointing_setting_sub');
	if _frame ~= nil then
		_frame:ShowWindow(0);
	end

	PointingSaveSetting();

	CreateSettingFrame();

end



--◇ セッティング：テキスト生成
function CreatePointingText( frame, name, caption, x, y, w, h, gravityW, gravityH)

	local _control =  frame:CreateOrGetControl('richtext','POINTING_'..name, x,y,w,h);
	_control = tolua.cast(_control,'ui::CRichText');
	_control:SetText('{@st66b}{#ffffff}'..caption..'{/}');
	_control:SetSkinName("textview");
	_control:EnableHitTest(0);
	_control:SetGravity(gravityW,gravityH);

end



--◇ セッティング：ボタン生成
function CreatePointingButton( frame, name, caption, x, y, w, h, skin, script)

	local _control = frame:CreateOrGetControl('button','POINTING_BTN_'..name, x, y, w, h);

	_control = tolua.cast(_control,'ui::CButton');
	_control:SetText('{@st66b}'..caption..'{/}');
	_control:SetClickSound("button_click_big");
	_control:SetOverSound("button_over");
	_control:SetEventScript(ui.LBUTTONUP, script);
	if skin ~= '' then
		_control:SetSkinName(skin);
	end

end



--◇ セッティング：トグルボタンの生成
function CreatePointingToggleButton( frame, setting, caption, x, y, w, h)

	local _enable = '';

	g_uiObjects[setting] = frame:CreateOrGetControl('button','POINTING_TB_'..setting, x, y, w, h);
	g_uiObjects[setting] = tolua.cast(g_uiObjects[setting],'ui::CButton');
	if g_settings[setting] then _enable = '{#00cc00}ON ' else _enable = '{#cc0000}OFF' end
	g_uiObjects[setting]:SetText('{@st66b}{#000000}'..caption..' : '.._enable..'{/}');
	g_uiObjects[setting]:SetClickSound("button_click_big");
	g_uiObjects[setting]:SetOverSound("button_over");
--	g_uiObjects[setting]:SetEventScript(ui.LBUTTONUP, "PointingToggleButton(\'"..setting.."\',\'"..caption.."\')");
	g_uiObjects[setting]:SetEventScript(ui.LBUTTONUP, "PointingToggleButton");
	g_uiObjects[setting]:SetEventScriptArgString(ui.LBUTTONUP, setting);
	g_uiObjects[setting]:SetSkinName("test_pvp_btn");

end


--◇ セッティング：トグルボタンのオンオフ
function PointingToggleButton( frame, control, setting, argNumber)

	local _str = string.sub( g_uiObjects[setting]:GetText(), 1, string.find(g_uiObjects[setting]:GetText(), ":") );

	-- 共通処理
	if g_settings[setting] then
		g_settings[setting] = false;
		g_uiObjects[setting]:SetText('{@st66b}{#000000}'.._str..' {#cc0000}OFF{/}');
	else
		g_settings[setting] = true;
		g_uiObjects[setting]:SetText('{@st66b}{#000000}'.._str..' {#00cc00}ON {/}');
	end

	-- 設定ごとの処理
	-- ターゲットサークル
	if setting == 'isEnableCircle' then
		if g_settings['isEnableCircle'] then
			InitTargetCursor();
		else
			ClearTargetCursor();
		end
	-- ターゲットポイント
	elseif setting == 'isEnablePoint' then
		if g_settings['isEnablePoint'] then
			if g_settings.isEnableOutside == true then
				InitOutFrame();
			end
			InitPoint();
		else
			ClearOutFrame();
		end
	-- 外枠と外枠アイコン
	elseif setting == 'isEnableOutside' then
		if g_settings['isEnablePoint'] then
			if g_settings['isEnableOutside'] then
				InitOutFrame();
				InitPoint();
			else
				ClearOutFrame();
			end
		end
	-- マウスカーソル
	elseif setting == 'isMouseCursor' then
		if g_settings['isMouseCursor'] then
			InitMouseCursor();
		else
			ClearMouseCursor();
		end
	-- 情報ウィンドウ
	elseif setting == 'isEnableInfo' then
		if g_settings['isEnableInfo'] then
			InitInformation();
		else
			ClearInformation();
		end
	-- カメラアシスト
	elseif setting == 'isEnableAssist' then
		if g_settings['isEnableAssist'] then
			InitCameraAssist();
		else
			ClearCameraAssist();
		end
	-- 名称非表示
	elseif setting == 'isEnableHideName' then
		if g_settings['isEnableHideName'] then
			-- 生成は特に無し
		else
			ClearHideName();
		end
	end

	PointingSaveSetting();

	UPDATE_POINTING_FRAME();	-- 即時反映させるため呼び出す

end



--◇ セッティング：アップダウンボタンの生成
function CreatePointingUpDownButton( frame, setting, caption, x, y, w, h, capW, numW, minNum, maxNum, addNumL,  addNumR)

	local _str = '';

	g_upDownButtonState[setting] = {};
	g_upDownButtonState[setting]['minNum'] = minNum;
	g_upDownButtonState[setting]['maxNum'] = maxNum;

	_str = setting..'Caption';
	g_uiObjects[_str] = frame:CreateOrGetControl('richtext','POINTING_UDC'..setting, x,y+5,w,h);
	g_uiObjects[_str] = tolua.cast(g_uiObjects[_str],'ui::CRichText');
	g_uiObjects[_str]:SetText('{@st66b}{#ffffff}'..caption..'{/}');
	g_uiObjects[_str]:SetSkinName("textview");
	g_uiObjects[_str]:EnableHitTest(0);

	_str = setting;
	g_uiObjects[_str] = frame:CreateOrGetControl('richtext','POINTING_UDT'..setting, x+capW+23,y+7,w,h);
	g_uiObjects[_str] = tolua.cast(g_uiObjects[_str],'ui::CRichText');
	g_uiObjects[_str]:SetText('{@st66b}{#ffffff}'..g_settings[setting]);
	g_uiObjects[_str]:SetSkinName("textview");
	g_uiObjects[_str]:EnableHitTest(0);

	_str = setting..'L';
	g_uiObjects[_str] = frame:CreateOrGetControl('button','POINTING_UDL'..setting, x+capW,y,20,h);
	g_uiObjects[_str] = tolua.cast(g_uiObjects[_str],'ui::CButton');
	g_uiObjects[_str]:SetText('{@st66b}{#000000}<{/}');
	g_uiObjects[_str]:SetClickSound("button_click_big");
	g_uiObjects[_str]:SetOverSound("button_over");
--	g_uiObjects[_str]:SetEventScript(ui.LBUTTONDOWN, "PointingUpDownButton(\'"..setting.."\',"..minNum..","..maxNum..",-"..addNumL..")");
--	g_uiObjects[_str]:SetEventScript(ui.RBUTTONDOWN, "PointingUpDownButton(\'"..setting.."\',"..minNum..","..maxNum..",-"..addNumR..")");
	g_uiObjects[_str]:SetEventScript(ui.LBUTTONDOWN, "PointingUpDownButton");
	g_uiObjects[_str]:SetEventScript(ui.RBUTTONDOWN, "PointingUpDownButton");
	g_uiObjects[_str]:SetEventScriptArgString(ui.LBUTTONDOWN, setting);
	g_uiObjects[_str]:SetEventScriptArgString(ui.RBUTTONDOWN, setting);
	g_uiObjects[_str]:SetEventScriptArgNumber(ui.LBUTTONDOWN, -addNumL);
	g_uiObjects[_str]:SetEventScriptArgNumber(ui.RBUTTONDOWN, -addNumR);
	g_uiObjects[_str]:SetSkinName("test_pvp_btn");

	_str = setting..'R';
	g_uiObjects[_str] = frame:CreateOrGetControl('button','POINTING_UDR'..setting, x+capW+23+numW,y,20,h);
	g_uiObjects[_str] = tolua.cast(g_uiObjects[_str],'ui::CButton');
	g_uiObjects[_str]:SetText('{@st66b}{#000000}>{/}');
	g_uiObjects[_str]:SetClickSound("button_click_big");
	g_uiObjects[_str]:SetOverSound("button_over");
--	g_uiObjects[_str]:SetEventScript(ui.LBUTTONDOWN, "PointingUpDownButton(\'"..setting.."\',"..minNum..","..maxNum..","..addNumL..")");
--	g_uiObjects[_str]:SetEventScript(ui.RBUTTONDOWN, "PointingUpDownButton(\'"..setting.."\',"..minNum..","..maxNum..","..addNumR..")");
	g_uiObjects[_str]:SetEventScript(ui.LBUTTONDOWN, "PointingUpDownButton");
	g_uiObjects[_str]:SetEventScript(ui.RBUTTONDOWN, "PointingUpDownButton");
	g_uiObjects[_str]:SetEventScriptArgString(ui.LBUTTONDOWN, setting);
	g_uiObjects[_str]:SetEventScriptArgString(ui.RBUTTONDOWN, setting);
	g_uiObjects[_str]:SetEventScriptArgNumber(ui.LBUTTONDOWN, addNumL);
	g_uiObjects[_str]:SetEventScriptArgNumber(ui.RBUTTONDOWN, addNumR);
	g_uiObjects[_str]:SetSkinName("test_pvp_btn");

end



--◇ セッティング：アップダウンボタンの上下処理
--function PointingUpDownButton( setting, minNum, maxNum, num)
function PointingUpDownButton( frame, control, setting, num)

	-- 共通処理
	g_settings[setting] = g_settings[setting] + num;
	if g_settings[setting]<=g_upDownButtonState[setting]['minNum'] then
		g_settings[setting] = g_upDownButtonState[setting]['minNum'];
	elseif g_settings[setting]>=g_upDownButtonState[setting]['maxNum'] then
		g_settings[setting] = g_upDownButtonState[setting]['maxNum'];
	end
	g_uiObjects[setting]:SetText('{@st66b}{#ffffff}'..g_settings[setting]..'{/}');

	-- 設定ごとの処理
	-- 外枠のアルファ
	if setting == 'outColorA' or setting == 'outColorR' or setting == 'outColorG' or setting == 'outColorB' then
		-- 範囲フレーム：初期化
		if g_settings.isEnablePoint and g_settings.isEnableOutside then
			InitOutFrame();
		end
	-- 外枠の左,右,上,下幅
	elseif setting == 'outL' or setting == 'outR' or setting == 'outT' or setting == 'outB' then
		-- 範囲フレーム：初期化
		if g_settings.isEnablePoint and g_settings.isEnableOutside then
			InitOutFrame();
		end
	-- 外枠の分割数
	elseif setting == 'outW' or setting == 'outH' then
		-- 範囲フレーム：初期化
		if g_settings.isEnablePoint and g_settings.isEnableOutside then
--			ClearOutFrame();
			InitOutFrame();
		end
	-- 全体の描画優先度
	elseif setting == 'layer' then
		InitAll();
	-- ポイントアイコンサイズ
	elseif setting == 'iconSize' then
		if g_settings['isEnablePoint'] then
			InitPoint();
		end
	-- 非強調する距離
	elseif setting == 'tarDistance' then
		if g_settings['isEnablePoint'] then
			InitPoint();
		end
	-- マウスカーソル
	elseif setting == 'mousePrio' or setting == 'mouseSize' or setting == 'mouseColorA' or setting == 'mouseColorR' or setting == 'mouseColorG' or setting == 'mouseColorB' or setting == 'mouseInterval' then
		if g_settings['isMouseCursor'] then
			InitMouseCursor();
		end
	end

	PointingSaveSetting();

end



--◇ セッティング：ドロップダウンリストの生成
function CreatePointingDropDownList( frame, setting, caption, list, x, y, w, h, capW)

	g_uiObjects[setting..'caption'] = frame:CreateOrGetControl('richtext','POINTING_CAP_'..setting, x, y, w, h);
	g_uiObjects[setting..'caption'] = tolua.cast(g_uiObjects[setting..'caption'],'ui::CRichText');
	g_uiObjects[setting..'caption']:SetText('{@st66b}{#ffffff}'..caption..' :{/}');
	g_uiObjects[setting..'caption']:SetSkinName("textview");
	g_uiObjects[setting..'caption']:EnableHitTest(0);

	g_uiObjects[setting] = frame:CreateOrGetControl('droplist','POINTING_DL_'..setting, x+capW, y, w-capW, h-10);
	g_uiObjects[setting] = tolua.cast(g_uiObjects[setting],'ui::CDropList');
	g_uiObjects[setting]:SetSkinName('droplist_normal');
	for _k, _v in pairs(list) do 
		g_uiObjects[setting]:AddItem( _k, _v, 0, "PointingDropDownSelect(\'"..setting.."\',".._k..")");
	end
	g_uiObjects[setting]:SelectItem( g_settings[setting]-1 );

end



--◇ セッティング：ドロップダウンリストの選択処理
function PointingDropDownSelect( setting, select )

	g_settings[setting] = select;

	PointingSaveSetting();

end



--◇ セッティング：チェックボックスの生成
function CreatePointingCheckBox( frame, setting, caption, x, y, w, h, isCheck)

	g_uiObjects[setting] = frame:CreateOrGetControl('checkbox','POINTING_CB_'..setting, x,y,w,h);
	g_uiObjects[setting] = tolua.cast(g_uiObjects[setting],'ui::CCheckBox');
	g_uiObjects[setting]:SetText('{@st66b}{#ffffff}'..caption..'{/}');
	g_uiObjects[setting]:SetClickSound("button_click_big");
	g_uiObjects[setting]:SetAnimation("MouseOnAnim",  "btn_mouseover");
	g_uiObjects[setting]:SetAnimation("MouseOffAnim", "btn_mouseoff");
	g_uiObjects[setting]:SetOverSound("button_over");
	g_uiObjects[setting]:SetEventScript(ui.LBUTTONUP, "PointingCheckBoxSelect");
	g_uiObjects[setting]:SetEventScriptArgString(ui.LBUTTONUP, setting);
	if isCheck==true then
		g_uiObjects[setting]:SetCheck(1);
	else
		g_uiObjects[setting]:SetCheck(0);
	end

end



--◇ セッティング：チェックボックスのオンオフ処理
function PointingCheckBoxSelect(frame, ctrl, argStr, argNum)

	local _isChecked = false;

	if ctrl:IsChecked() == 1 then
		_isChecked = true;
	end

	g_settings[argStr] = _isChecked;

	-- 個別処理
	local _str = "";

	-- チェックされた場合
	if _isChecked == true then
		if     argStr == 'isOutPointPT' then _str = 'isPointPT' ;
		elseif argStr == 'isOutPointNPC'then _str = 'isPointNPC';
		elseif argStr == 'isOutPointMOB'then _str = 'isPointMOB';
		elseif argStr == 'isOutPointSP' then _str = 'isPointSP' ;
		elseif argStr == 'isOutPointOBJ'then _str = 'isPointOBJ';
		elseif argStr == 'isOutPointETC'then _str = 'isPointETC';
		else
			InitAll();
			return;
		end

		if g_uiObjects[_str]:IsChecked() == 0 then
			g_uiObjects[argStr]:SetCheck(0);
		end

		InitAll();

	-- チェックが外された場合
	else
		if     argStr == 'isPointPT'	then _str = 'isOutPointPT' ;
		elseif argStr == 'isPointNPC'	then _str = 'isOutPointNPC';
		elseif argStr == 'isPointMOB'	then _str = 'isOutPointMOB';
		elseif argStr == 'isPointSP'	then _str = 'isOutPointSP' ;
		elseif argStr == 'isPointOBJ'	then _str = 'isOutPointOBJ';
		elseif argStr == 'isPointETC'	then _str = 'isOutPointETC';
		elseif argStr == 'isEnableOutside' then
			ClearOutFrame();
			InitAll();
			return;
		else
			InitAll();
			return;
		end

		g_uiObjects[_str]:SetCheck(0);
		g_settings[_str] = false;
		InitAll();

	end

end


--◇ セッティング：設定のリセット
function PointingResetSettings()

	ui.MsgBox("{s24}{#ff0000}WARNING!{#000000}{nl} {nl}{#03134d}".."{s18}Are you sure you want to reset all settings? This cannot be undone.","ui.Chat('/pointing reset')","Nope")

end



--◇ セッティング：コマンド出力
function PointingCheckCommand()

	ui.MsgBox("{s18}{#1908e3}/pointing{nl}"..
		"{#000000}Open the setting window.{nl} {nl}"..
		"{#1908e3}/pointing help{nl}"..
		"{#000000}Display help text.{nl} {nl}"..
		"{#1908e3}/pointing reset{nl}"..
		"{#000000}Return to initial state.{nl} {nl}"..
		"{#1908e3}/pointing toggle{nl}"..
		"{#000000}Temporarily disable the function.{nl} {nl}"..
		"{#1908e3}/pointing save <1~3>{nl}"..
		"{#000000}Save settings.{nl} {nl}"..
		"{#1908e3}/pointing load <1~3>{nl}"..
		"{#000000}Load settings.{nl} {nl}"..
		"{#1908e3}/pointing zoom <50~1500>{nl}"..
		"{#000000}Camera zoom.{nl} {nl}"..
		"{#1908e3}/pointing cam_reset{nl}"..
		"{#000000}Return the rotation of the camera.","Nope","Nope");

end


---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------



--◇ テーブルのコピー（内部配列のコピーはしない）
function shallowcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in pairs(orig) do
			copy[orig_key] = orig_value
		end
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end











