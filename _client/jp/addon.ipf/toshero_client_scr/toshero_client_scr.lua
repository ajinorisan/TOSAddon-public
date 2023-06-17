-- 콘텐츠 시작 시 이펙트 켜기를 권장

function TOSHERO_SCR_EFFECT_ON(arg1)

    if arg1 == 1 then
        ENABLE_OTHER_PC_EFFECT_CHECK()
        return
    else
        return
    end
end

function TOSHERO_TALK_EFFECT_READY_MGS_BOX(frame)
    local msg = ScpArgMsg("TOSHeroOnOtherPCEffect")

    ui.MsgBox(msg, "TOSHERO_SCR_EFFECT_ON(1)", nil)
end