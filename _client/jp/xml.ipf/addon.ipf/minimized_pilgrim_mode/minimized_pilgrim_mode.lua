function MINIMIZED_PILGRIM_MODE_ON_INIT(addon, frame)
	addon:RegisterMsg("GAME_START", "MINIMIZED_PILGRIM_MODE_OPEN_CHECK");
end

function MINIMIZED_PILGRIM_MODE_OPEN_CHECK(frame)
end

function MINIMIZED_PILGRIM_MODE_CLICK(parent, ctrl)
    ui.ToggleFrame('squad_manager');
end