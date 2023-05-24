--애드온 이름
local addonName = 'Timer'
local addonNameUpper = string.upper(addonName)
local addonNameLower = string.lower(addonName)


--제작자 이름
local author = 'Charbon'
local authorUpper = string.upper(author)
local authorLower = string.lower(author)


--버전
local version = '1.0.7'


--전역 변수 설정
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][authorUpper] = _G['ADDONS'][authorUpper] or {}
_G['ADDONS'][authorUpper][addonNameUpper] = _G['ADDONS'][authorUpper][addonNameUpper] or {}
local Timer = _G['ADDONS'][authorUpper][addonNameUpper]


--라이브러리 변수 설정
local ACUtil = require('acutil')
local CharbonAPI = require('charbonapi')


--다국어
Timer.LangTable = {
  ['kr'] = {
    System = {
      None          = '설명 없음',
      Icon          = '타이머',
      RemainTime    = '남은 시간',
      TotalTime     = '전체 시간'
    },
    Message = {
      CannotLoadSettings     = '설정 파일을 불러오지 못했습니다.',
      InvalidCommand         = '잘못된 명령어입니다.',
      InvalidTotalTime       = '전체 시간을 5초 미만으로 설정할 수 없습니다.',
      TimerStart             = '타이머를 시작했습니다.',
      TimerStop              = '타이머를 종료합니다.',
      Timer10SecLeftWithDesc = '%s{pp 이 가} 10초 남았습니다.',
      TimerCompleteWithDesc  = '%s{pp 이 가} 등장합니다.',
      Timer10SecLeft         = '10초 남았습니다.',
      TimerComplete          = '타이머가 종료되었습니다.'
    }
  },
  ['jp'] = {
    System = {
      None          = '説明なし',
      Icon          = 'タイマー',
      RemainTime    = '残り時間',
      TotalTime     = '全体の時間'
    },
    Message = {
      CannotLoadSettings     = '設定ファイルをロードできません。',
      InvalidCommand         = '正しくない命令です。',
      InvalidTotalTime       = '全体の時間を5秒未満に設定することができません。',
      TimerStart             = 'タイマーを開始しました。',
      TimerStop              = 'タイマーを終了します。',
      Timer10SecLeftWithDesc = '%sが10秒残りました。',
      TimerCompleteWithDesc  = '%sが登場します。',
      Timer10SecLeft         = '10秒残りました。',
      TimerComplete          = 'タイマーが終了しました。'
    }
  },
  ['global'] = {
    System = {
      None          = 'No description',
      Icon          = 'Timer',
      RemainTime    = 'Time remaining',
      TotalTime     = 'Total time'
    },
    Message = {
      CannotLoadSettings     = 'Can not load settings.',
      InvalidCommand         = 'Invalid command.',
      InvalidTotalTime       = 'You can\'t set the total time to less than 5 seconds.',
      TimerStart             = 'Started the timer.',
      TimerStop              = 'End the timer.',
      Timer10SecLeftWithDesc = '%s has 10 seconds left.',
      TimerCompleteWithDesc  = '%s appears.',
      Timer10SecLeft         = '10 seconds left.',
      TimerComplete          = 'The timer has ended.'
    }
  }
}


--설정 파일 저장 위치
Timer.SettingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)


--기본 설정
Timer.DefaultSettings = {}
Timer.DefaultSettings.Position = {X = 400, Y = 300}


--상수 설정
Timer.StandardTick = 5


--변수 설정
Timer.timerTick = 0
Timer.startTick = 0
Timer.loopTick = 0
Timer.description = nil


--설정되어 있는 다국어 코드 반환
function Timer.GetLangCode(self)
  local langCode = self.Settings and self.Settings.LangCode

  if not langCode then
    langCode = option.GetCurrentCountry()

    if langCode == 'kr' then
      langCode = 'kr'
    elseif langCode == 'Japanese' then
      langCode = 'jp'
    else
      langCode = 'global'
    end
  end

  return langCode
end


--다국어 텍스트 반환
function Timer.GetLangText(self, key, ...)
  return CharbonAPI:GetLangText(self.LangTable, self:GetLangCode(), key, ...)
end


--로그 출력
function Timer.Log(self, mode, key, ...)
  return CharbonAPI:Log(mode, self.LangTable, self:GetLangCode(), key, ...)
end


--설정 파일 관리
function Timer.LoadSettings(self)
  local settings, err = ACUtil.loadJSON(self.SettingsFileLoc, self.DefaultSettings)

  --파일 I/O 오류 처리
  if err then
    self:Log('Normal', 'Message.CannotLoadSettings')
  end

  --기본 설정 적용
  if not settings then
    settings = self.DefaultSettings
  end

  --설정 저장
  self.Settings = settings
end


function Timer.SaveSettings(self)
  return ACUtil.saveJSON(self.SettingsFileLoc, self.Settings)
end


--UI 표시
function Timer.ShowFrame(self, flag)
  --잘못된 매개변수 예외 처리
  if flag ~= nil and flag ~= true and flag ~= false then
    return false
  end

  --UI 표시 상태를 받지 않았다면 토글 설정
  if flag == nil then
    flag = self.Frame:IsVisible() == 0
  end

  --UI 업데이트
  self.Frame:SetPos(self.Settings.Position.X, self.Settings.Position.Y)
  self.Frame:ShowWindow(flag and 1 or 0)
  self:UpdateFrame()

  return true
end


function Timer.ToggleFrame(self)
  return self:ShowFrame()
end


--UI 현재 위치 저장
function Timer.SaveFramePosition(self, X, Y)
  self.Settings.Position.X = X
  self.Settings.Position.Y = Y
  self:SaveSettings()
end


--UI 업데이트
function Timer.UpdateFrame(self)
  self:UpdateTimerDesc()
  self:UpdateTimerRemaining()
  self:UpdateTimerTotal()
  self:UpdateFrameLanguage()
end


function Timer.UpdateTimerDesc(self)
  local desc = self:GetTimerDesc()

  if not desc then
    desc = self:GetLangText('System.None')
  end

  self:GetTimerDescObj():SetTextByKey('value', desc)
end


--남은 시간 업데이트
function Timer.UpdateTimerRemaining(self)
  self:GetRemainMinuteObj():SetTextByKey('value', self:GetMinute())
  self:GetRemainSecondObj():SetTextByKey('value', self:GetSecond())
end


--전체 시간 업데이트
function Timer.UpdateTimerTotal(self)
  self:GetTotalMinuteObj():SetTextByKey('value', self:GetTotalMinute())
  self:GetTotalSecondObj():SetTextByKey('value', self:GetTotalSecond())
end


--다국어 업데이트
function Timer.UpdateFrameLanguage(self)
  self:GetRemainTimeTextObj():SetTextByKey('value', self:GetLangText('System.RemainTime'))
  self:GetTotalTimeTextObj():SetTextByKey('value', self:GetLangText('System.TotalTime'))
end


--UI 오브젝트 반환
function Timer.GetTimerObj(self)
  local timerTickObj = GET_CHILD(self.Frame, 'timerTick', 'ui::CAddOnTimer')
  timerTickObj:SetUpdateScript('TIMER_ON_TICK')
  return timerTickObj
end


function Timer.GetTimerDescObj(self)
  return GET_CHILD(self.Frame, 'timerDesc', 'ui::CRichText')
end


function Timer.GetRemainTimeTextObj(self)
  return GET_CHILD(self.Frame, 'remainTimeText', 'ui::CRichText')
end


function Timer.GetRemainClockGbox(self)
  return GET_CHILD(self.Frame, 'remainClockGbox', 'ui::CGroupBox')
end


function Timer.GetRemainMinuteObj(self)
  return GET_CHILD(self:GetRemainClockGbox(), 'remainMin', 'ui::CRichText')
end


function Timer.GetRemainSecondObj(self)
  return GET_CHILD(self:GetRemainClockGbox(), 'remainSec', 'ui::CRichText')
end


function Timer.GetTotalTimeTextObj(self)
  return GET_CHILD(self.Frame, 'totalTimeText', 'ui::CRichText')
end


function Timer.GetTotalClockGbox(self)
  return GET_CHILD(self.Frame, 'totalClockGbox', 'ui::CGroupBox')
end


function Timer.GetTotalMinuteObj(self)
  return GET_CHILD(self:GetTotalClockGbox(), 'totalMin', 'ui::CRichText')
end


function Timer.GetTotalSecondObj(self)
  return GET_CHILD(self:GetTotalClockGbox(), 'totalSec', 'ui::CRichText')
end


--타이머 시작
function Timer.StartTimer(self, startSec, loopSec, desc)
  --타이머를 처음 시작하는 경우
  if startSec and loopSec then
    local startTick = startSec * self.StandardTick
    local loopTick = loopSec * self.StandardTick
    self:SetLoopTick(startTick, loopTick)
    self:SetTimerDesc(desc)
  end

  --타이머 시작
  self:GetTimerObj():Start(self:GetInterval())
end


--타이머 중지
function Timer.StopTimer(self)
  self:GetTimerObj():Stop()
end


--타이머 반복 시작
function Timer.LoopTimer(self)
  --반복 설정된 시간으로 초기화
  self:SetTick(self.loopTick)

  --타이머 시작
  self:GetTimerObj():Start(self:GetInterval())
end


--타이머 시간 계산
function Timer.TickTimer(self)
  --매 초마다
  if self.timerTick % self.StandardTick == 0 then
    TIMER_ON_EVERY_SEC()
  end

  --10초 남았을 경우
  if self.timerTick == self.StandardTick * 10 then
    TIMER_ON_10SEC_LEFT()

  --타이머가 끝났을 경우
  elseif self.timerTick == 0 then
    self:StopTimer()
    TIMER_ON_COMPLETE()
    return
  end

  self.timerTick = self.timerTick - 1
end


--타이머 간격 계산
function Timer.GetInterval(self)
  return 1 / self.StandardTick
end


--현재 타이머 시간 설정
function Timer.SetTick(self, tick)
  self.timerTick = math.floor(tick)
end


--타이머 반복 시간 설정
function Timer.SetLoopTick(self, startTick, loopTick)
  self.startTick = math.floor(startTick)
  self.loopTick = math.floor(loopTick)
  self:SetTick(startTick)
end


--타이머 설명 설정
function Timer.GetTimerDesc(self, desc)
  return self.description
end


function Timer.SetTimerDesc(self, desc)
  self.description = (desc and desc ~= '') and desc or nil
end


--타이머 시간 반환
function Timer.GetMinute(self)
  return string.format('%02d', math.floor(self.timerTick / self.StandardTick / 60))
end


function Timer.GetSecond(self)
  return string.format('%02d', math.floor(self.timerTick / self.StandardTick % 60))
end


function Timer.GetTotalMinute(self)
  return string.format('%02d', math.floor(self.loopTick / self.StandardTick / 60))
end


function Timer.GetTotalSecond(self)
  return string.format('%02d', math.floor(self.loopTick / self.StandardTick % 60))
end


--타이머 종료 이펙트 재생
function Timer.ExecEffect(self)
  local handle = session.GetMyHandle()
  local actor = world.GetActor(handle)
  effect.PlayActorEffect(actor, 'F_sys_TPBOX_great_300', 'None', 2.0, 5.0)
end


--타이머 시간 계산
function TIMER_ON_TICK(frame)
  Timer:TickTimer()
end


--타이머 매 초마다 이벤트
function TIMER_ON_EVERY_SEC()
  Timer:UpdateTimerRemaining()
end


--타이머 종료 10초 전 이벤트
function TIMER_ON_10SEC_LEFT()
  local desc = Timer:GetTimerDesc()

  if desc then
    Timer:Log('Warning', 'Message.Timer10SecLeftWithDesc', desc)
  else
    Timer:Log('Warning', 'Message.Timer10SecLeft')
  end
end


--타이머 종료 이벤트
function TIMER_ON_COMPLETE()
  local desc = Timer:GetTimerDesc()

  if desc then
    Timer:Log('Warning', 'Message.TimerCompleteWithDesc', desc)
  else
    Timer:Log('Warning', 'Message.TimerComplete')
  end

  --타이머 종료 시 이펙트 출력 후 반복 시작
  Timer:ExecEffect()
  Timer:LoopTimer()
end


--UI 표시 설정
function TIMER_TOGGLE()
  Timer:ToggleFrame()
end


function TIMER_OPEN()
  Timer:ShowFrame(true)
end


function TIMER_CLOSE()
  Timer:Log('Normal', 'Message.TimerStop')
  Timer:StopTimer()
  Timer:ShowFrame(false)
end


--UI 드래그 이벤트
function TIMER_END_DRAG()
  local X = Timer.Frame:GetX()
  local Y = Timer.Frame:GetY()
  Timer:SaveFramePosition(X, Y)
end


--채팅 명령어 이벤트
function TIMER_ON_COMMAND(commands)
  --명령어 포맷 확인
  if #commands < 2 then
    TIMER_CLOSE()
    return
  end

  local startSec = tonumber(table.remove(commands, 1))
  local loopSec = tonumber(table.remove(commands, 1))
  local desc = table.concat(commands, ' ')

  --타이머 시작
  if startSec and loopSec then
    if loopSec < 5 then
      Timer:Log('Normal', 'Message.InvalidTotalTime')
      return
    end

    Timer:StopTimer()
    Timer:StartTimer(startSec, loopSec, desc)
    TIMER_OPEN()

    Timer:Log('Normal', 'Message.TimerStart')
  else
    Timer:Log('Normal', 'Message.InvalidCommand')
  end
end


--애드온 초기화 이벤트
function TIMER_ON_INIT(addon, frame)
  Timer.Addon = addon
  Timer.Frame = frame

  --설정 파일 처리
  if not Timer.Loaded then
    Timer:LoadSettings()
    Timer:SaveSettings()
    Timer.Loaded = true
  end

  --이벤트 등록
  ACUtil.slashCommand('/타이머', TIMER_ON_COMMAND)
  ACUtil.slashCommand('/timer', TIMER_ON_COMMAND)
end
