function MINIMIZED_MARKET_BUTTON_ON_INIT(addon, frame)
	addon:RegisterMsg("GAME_START", "MINIMIZED_MARKET_BUTTON_OPEN_CHECK");
end

function MINIMIZED_MARKET_BUTTON_OPEN_CHECK(frame)

end

function MINIMIZED_MARKET_BUTTON_CLICK(parent, ctrl)
    control.CustomCommand("MARKET_UI_OPEN", 0)
end