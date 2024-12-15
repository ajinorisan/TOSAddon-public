function MINIMIZED_PARTY_BOARD_ON_INIT(addon, frame)
	addon:RegisterMsg("GAME_START", "MINIMIZED_PARTY_BOARD_BUTTON_OPEN_CHECK");
end

function MINIMIZED_PARTY_BOARD_BUTTON_OPEN_CHECK(frame)
end

function MINIMIZED_PARTY_BOARD_CLICK(parent, ctrl)
    ui.ToggleFrame('party_search_board')
end