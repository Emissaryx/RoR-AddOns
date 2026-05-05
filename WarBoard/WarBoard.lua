if not WarBoard then WarBoard = {} end
local WarBoard = WarBoard
local WindowSetTintColor, WindowSetAlpha, WindowClearAnchors, WindowAddAnchor, CreateWindow, towstring, tostring, tinsert, tremove,
	  setmetatable, getmetatable, ipairs, type, WindowGetDimensions, WindowSetDimensions, gsub, sfind, WindowStartAlphaAnimation,
	  MakeOneButtonDialog, DestroyWindow, Tooltips
	  =
	  WindowSetTintColor, WindowSetAlpha, WindowClearAnchors, WindowAddAnchor, CreateWindow, towstring, tostring, table.insert, table.remove, 
	  setmetatable, getmetatable, ipairs, type, WindowGetDimensions, WindowSetDimensions, string.gsub, string.find, WindowStartAlphaAnimation,
	  DialogManager.MakeOneButtonDialog, DestroyWindow, Tooltips

local defaults = 
{
	Board = { Red = 0, Blue = 0, Green = 0, Alpha = 0.5, VertSpace = 5, HorizSpace = 10, },
	Mods = { Red = 0, Blue = 0, Green = 0, Alpha = 0.5, },
	RowAlign = { 2, 2, 2, 2, }
}
local Version = "5.3.2"
local UnloadedMods = {}
local LayOutMode = false
local ClickedWindow = nil
WarBoard.LoadedMods = {}

local function CopyTable(object)
	-- Code from http://lua-users.org/wiki/CopyTable
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		local new_table = {}
		lookup_table[object] = new_table
		for index, value in pairs(object) do
			new_table[_copy(index)] = _copy(value)
		end
		return setmetatable(new_table, getmetatable(object))
	end
	return _copy(object)
end

function WarBoard.Initialize()
	WarBoard.LoadGeneralSettings()
	WarBoard.Options.Initialize()
	if LibSlash then
		LibSlash.RegisterSlashCmd("warboard", WarBoard.SlashCommand)
	end
	RegisterEventHandler(SystemData.Events.LOADING_END, "WarBoard.SortMods")
	RegisterEventHandler(SystemData.Events.RELOAD_INTERFACE, "WarBoard.SortMods")
	d("WarBoard Loaded")
end

function WarBoard.LoadGeneralSettings()
	if WarBoardSettings then
		if not WarBoardSettings.Version or WarBoardSettings.Version ~= Version then
			WarBoardSettings = nil
		end
	end
	if not WarBoardSettings then
		WarBoard.LoadDefaults()
	end
	-- Create windows
	local TopBoard, BottomBoard = WarBoardSettings.Top.Board, WarBoardSettings.Bottom.Board
	if TopBoard.Enabled then
		CreateWindow("WarBoard", true)
		WindowSetTintColor("WarBoardBackground", TopBoard.Red, TopBoard.Green, TopBoard.Blue) 
		WindowSetAlpha("WarBoardBackground", TopBoard.Alpha)
		if TopBoard.ButtonsOn then
			CreateWindow("WarBoardOptionsButtonWindow", true)
			CreateWindow("WarBoardLayoutModeButtonWindow", true)
			WindowSetAlpha("WarBoardOptionsButton", 0)
			WindowSetAlpha("WarBoardLayoutModeButton", 0)
		end
	end
	if BottomBoard.Enabled then
		CreateWindowFromTemplate("BottomBoard", "WarBoard", "Root")
		WindowClearAnchors("BottomBoard")
		WindowAddAnchor ("BottomBoard", "bottomleft", "Root", "bottomleft", -1, -1)
		WindowAddAnchor ("BottomBoard", "bottomright", "Root", "bottomright", 0, -1)
		WindowSetTintColor ("BottomBoardBackground", BottomBoard.Red, BottomBoard.Green, BottomBoard.Blue)
		WindowSetAlpha ("BottomBoardBackground", BottomBoard.Alpha)
		if BottomBoard.ButtonsOn then
			CreateWindow("WarBoardBottomOptionsButtonWindow", true)
			CreateWindow("WarBoardBottomLayoutModeButtonWindow", true)
			WindowSetAlpha("BottomBoardOptionsButton", 0)
			WindowSetAlpha("BottomBoardLayoutModeButton", 0)
		end
	end
end

function WarBoard.LoadDefaults()
	WarBoardSettings = {}
	WarBoardSettings.Version = Version
	WarBoardSettings.DefaultBoard = "Top"

	WarBoardSettings.Top = CopyTable(defaults)
	WarBoardSettings.Top.ModRows = {}
	tinsert(WarBoardSettings.Top.ModRows, {})
	WarBoardSettings.Top.Board.Enabled = true
	WarBoardSettings.Top.Board.ButtonsOn = true

	WarBoardSettings.Bottom = CopyTable(defaults)
	WarBoardSettings.Bottom.ModRows = {}
	tinsert(WarBoardSettings.Bottom.ModRows, {})
	WarBoardSettings.Bottom.Board.Enabled = false
	WarBoardSettings.Bottom.Board.ButtonsOn = false
end

function WarBoard.SlashCommand()
	WindowSetShowing("WarBoardOptions", not WindowGetShowing("WarBoardOptions"))
end

function WarBoard.SortMods()
    if #WarBoard.LoadedMods == 0 then
        WarBoard.AnchorMods()
        return
    end

    UnloadedMods = {}

    if WarBoardSettings.Top.Board.Enabled then
        WarBoard.CheckSavedRow(WarBoardSettings.Top.ModRows)
    end
    if WarBoardSettings.Bottom.Board.Enabled then
        WarBoard.CheckSavedRow(WarBoardSettings.Bottom.ModRows)
    end

    -- purge unloaded mods safely (no index shift)
    if #UnloadedMods > 0 then
        local buckets = {}
        for _, m in ipairs(UnloadedMods) do
            local key = tostring(m.board) .. ":" .. m.row
            local b = buckets[key]
            if not b then b = { board = m.board, row = m.row, poses = {} }; buckets[key] = b end
            table.insert(b.poses, m.pos)
        end
        for _, b in pairs(buckets) do
            local rows = b.board
            local rowt = rows[b.row]
            if rowt then
                table.sort(b.poses, function(a, c) return a > c end)
                for _, p in ipairs(b.poses) do
                    if rowt[p] ~= nil then table.remove(rowt, p) end
                end
                if #rowt == 0 then table.remove(rows, b.row) end
            end
        end
    end

    -- pick a valid target board/rows
    local DefaultBoard = WarBoardSettings.DefaultBoard
    if not (WarBoardSettings[DefaultBoard] and WarBoardSettings[DefaultBoard].Board.Enabled) then
        DefaultBoard = (WarBoardSettings.Top.Board.Enabled and "Top") or (WarBoardSettings.Bottom.Board.Enabled and "Bottom") or nil
        if not DefaultBoard then
            WarBoard.AnchorMods() -- nowhere to place
            return
        end
    end
    local boardRows = WarBoardSettings[DefaultBoard].ModRows
    if not boardRows or #boardRows == 0 then
        boardRows = WarBoardSettings[DefaultBoard].ModRows or {}
        WarBoardSettings[DefaultBoard].ModRows = boardRows
        WarBoard.AddRow(boardRows)
    end

    -- place any new mods
    while #WarBoard.LoadedMods > 0 do
        local mod    = WarBoard.LoadedMods[#WarBoard.LoadedMods]
        local rowIdx = #boardRows
        local row    = boardRows[rowIdx]
        table.insert(row, mod)
        if WarBoard.CheckLength(WarBoardSettings[DefaultBoard], rowIdx) then
            table.remove(WarBoard.LoadedMods) -- consumed
        else
            table.remove(row)                 -- undo
            WarBoard.AddRow(boardRows)        -- new row, retry next loop
        end
    end

    WarBoard.AnchorMods()
end

-- Accepts a rows table (e.g., WarBoardSettings.Top.ModRows)
function WarBoard.CheckSavedRow(rows)
    if not rows then return end

    for rowIndex, row in ipairs(rows) do
        for pos, savedMod in ipairs(row) do
            local loadedPos = nil
            for i, mod in ipairs(WarBoard.LoadedMods) do
                if mod == savedMod then
                    loadedPos = i
                    break
                end
            end

            if loadedPos then
                table.remove(WarBoard.LoadedMods, loadedPos)
            else
                -- store which rows table this came from, plus row & position
                table.insert(UnloadedMods, { board = rows, row = rowIndex, pos = pos })
            end
        end
    end
end

-- Optional alias if you also use the plural name elsewhere
WarBoard.CheckSavedRows = WarBoard.CheckSavedRow

function WarBoard.AddRow(board)
	tinsert(board, {})
end

function WarBoard.CheckLength(board, row)
	local windowName = nil
	if board == WarBoardSettings.Top then
		windowName = "WarBoard"
	elseif board == WarBoardSettings.Bottom then
		windowName = "BottomBoard"
	end
	local WBx, WBy = WindowGetDimensions(windowName)
	local TotalModsLength = WarBoard.GetModsLength(board, row)
	local rootX = WindowGetDimensions("Root")
	if WBx == 0 then
		WBx = rootX
	end
	if row == 1 and board.Board.ButtonsOn then
		WBx = WBx - 60
	end
	if TotalModsLength < WBx then
		return true
	else
		return false
	end
end

function WarBoard.GetModsLength(board, row)
	local TotalModsLength = 0
	for k, v in ipairs(board.ModRows[ row ]) do
		local modX, modY = WindowGetDimensions(v)
		TotalModsLength = TotalModsLength + modX
	end
	if #board.ModRows[ row ] > 1 then
		local padding = (#board.ModRows[ row ] -1) * board.Board.HorizSpace
		TotalModsLength = TotalModsLength + padding
	end
	return TotalModsLength
end

function WarBoard.AnchorMods()
	local WBx, WBy = 0, 0
	local BBx, BBy = 0, 0
	local rootX = WindowGetDimensions("Root")

	if WarBoardSettings.Top.Board.Enabled then
		WBx, WBy = WindowGetDimensions("WarBoard")
		if WBx == 0 then
			WBx = rootX
		end
		if #WarBoardSettings.Top.ModRows > 1 then
			WindowSetDimensions("WarBoard", WBx, ((#WarBoardSettings.Top.ModRows) * 30) + ((#WarBoardSettings.Top.ModRows - 1) * WarBoardSettings.Top.Board.VertSpace) + 2)
		else
			WindowSetDimensions("WarBoard", WBx, 32)
		end
		for k, v in ipairs(WarBoardSettings.Top.ModRows) do
			WarBoard.AnchorModRow(WarBoardSettings.Top, k, WBx)
		end
	end

	if WarBoardSettings.Bottom.Board.Enabled then
		BBx, BBy = WindowGetDimensions("BottomBoard")
		if BBx == 0 then BBx = rootX end
		if #WarBoardSettings.Bottom.ModRows > 1 then
			WindowSetDimensions("BottomBoard", BBx, ((#WarBoardSettings.Bottom.ModRows) * 30) + ((#WarBoardSettings.Bottom.ModRows - 1) * WarBoardSettings.Bottom.Board.VertSpace) + 2)
		else
			WindowSetDimensions("BottomBoard", BBx, 32)
		end
		for k, v in ipairs(WarBoardSettings.Bottom.ModRows) do
			WarBoard.AnchorModRow(WarBoardSettings.Bottom, k, BBx)
		end
	end
end

function WarBoard.AnchorModRow(board, row, windowX)
	-- Guards
	if not board or not board.ModRows or not board.ModRows[row] then return end
	local mods = board.ModRows[row]
	if #mods == 0 then return end

	local windowName, point
	if board == WarBoardSettings.Top then
		windowName, point = "WarBoard", "top"
	elseif board == WarBoardSettings.Bottom then
		windowName, point = "BottomBoard", "bottom"
	else
		return
	end

	local totalLen = WarBoard.GetModsLength(board, row) or 0
	local align = (board.RowAlign and board.RowAlign[row]) or 2 -- 1=left, 2=center, 3=right

	for k, modWin in ipairs(mods) do
		-- vertical offset per row
		local yOffset = 0
		if row > 1 then
			yOffset = ((row - 1) * 30) + ((row - 1) * (board.Board.VertSpace or 0))
			if board == WarBoardSettings.Bottom then yOffset = -yOffset end
		end

		if k == 1 then
			-- starting x offset for the first mod in the row
			local startX
			if align == 1 then
				-- left align
				startX = (row == 1 and board.Board.ButtonsOn) and 30 or (board.Board.HorizSpace or 0)
			elseif align == 3 then
				-- right align
				startX = (windowX or 0) - totalLen
				startX = startX - ((row == 1 and board.Board.ButtonsOn) and 30 or (board.Board.HorizSpace or 0))
			else
				-- center (default)
				startX = math.floor(((windowX or 0) - totalLen) / 2 + 0.5)
			end
			if startX < 0 then startX = 0 end

			WindowClearAnchors(modWin)
			WindowAddAnchor(modWin, point .. "left", windowName, point .. "left", startX, yOffset)
		else
			-- subsequent mods anchored to previous
			local prevWin = mods[k - 1]
			WindowClearAnchors(modWin)
			WindowAddAnchor(modWin, point .. "right", prevWin, point .. "left", (board.Board.HorizSpace or 0), 0)
		end

		-- apply row tint/alpha to the mod background
		local bg = modWin .. "Background"
		WindowSetTintColor(bg, board.Mods.Red or 0, board.Mods.Green or 0, board.Mods.Blue or 0)
		WindowSetAlpha(bg, board.Mods.Alpha or 0)
	end
end

function WarBoard.AddMod(modName)
	tinsert(WarBoard.LoadedMods, modName)
	CreateWindow(modName, true)
	return true
end

function WarBoard.GetModPosition(modName)
	if WarBoardSettings.Top.Board.Enabled then
		for k, v in ipairs(WarBoardSettings.Top.ModRows) do
			local row = k
			for k, v in ipairs(WarBoardSettings.Top.ModRows[ row ]) do
				if v == modName then
					return "Top", row, k
				end
			end
		end
	end
	if WarBoardSettings.Bottom.Board.Enabled then
		for k, v in ipairs(WarBoardSettings.Bottom.ModRows) do
			local row = k
			for k, v in ipairs(WarBoardSettings.Bottom.ModRows[ row ]) do
				if v == modName then
					return "Bottom", row, k
				end
			end
		end
	end
end

function WarBoard.MoveModLeft()
  local win = SystemData.ActiveWindow and SystemData.ActiveWindow.name or ""
  if win == "" then return end
  local modName = string.gsub(win, "MoveLeft$", "")
  local board,row,pos = WarBoard.GetModPosition(modName)
  if not board then return end
  local rowT = WarBoardSettings[board].ModRows[row]
  table.remove(rowT, pos)
  -- insert at pos-1, or wrap to end if already first
  if pos > 1 then table.insert(rowT, pos-1, modName)
  else table.insert(rowT, modName) end
  WarBoard.AnchorMods()
end

function WarBoard.MoveModRight()
  local win = SystemData.ActiveWindow and SystemData.ActiveWindow.name or ""
  if win == "" then return end
  local modName = string.gsub(win, "MoveRight$", "")
  local board,row,pos = WarBoard.GetModPosition(modName)
  if not board then return end
  local rowT = WarBoardSettings[board].ModRows[row]
  if pos < #rowT then
    -- swap with next
    rowT[pos], rowT[pos+1] = rowT[pos+1], rowT[pos]
  else
    -- wrap to start
    table.remove(rowT, pos)
    table.insert(rowT, 1, modName)
  end
  WarBoard.AnchorMods()
end

function WarBoard.MoveModUp(modName)
  modName = (modName and modName ~= "") and modName or gsub((ClickedWindow or ""), "Move.*$", "")
  if modName == "" then return end
  local board,row,pos = WarBoard.GetModPosition(modName); if not board then return end
  local rows       = WarBoardSettings[board].ModRows
  local currentRow = rows[row]
  local targetRow  = (row == 1) and #rows or (row - 1)

  table.insert(rows[targetRow], modName)
  if WarBoard.CheckLength(WarBoardSettings[board], targetRow) then
    table.remove(currentRow, pos)
    if #currentRow == 0 and #rows > 1 then table.remove(rows, row) end
  else
    table.remove(rows[targetRow])
    MakeOneButtonDialog(towstring("WarBoard cannot move "..modName.." up, there is not enough room"), L"OK")
  end
  WarBoard.AnchorMods()
end

function WarBoard.MoveModDown(modName)
  modName = (modName and modName ~= "") and modName or gsub((ClickedWindow or ""), "Move.*$", "")
  if modName == "" then return end
  local board,row,pos = WarBoard.GetModPosition(modName); if not board then return end
  local rows       = WarBoardSettings[board].ModRows
  local currentRow = rows[row]
  local targetRow  = (row == #rows) and 1 or (row + 1)

  table.insert(rows[targetRow], modName)
  if WarBoard.CheckLength(WarBoardSettings[board], targetRow) then
    table.remove(currentRow, pos)
    if #currentRow == 0 and #rows > 1 then table.remove(rows, row) end
  else
    table.remove(rows[targetRow])
    MakeOneButtonDialog(towstring("WarBoard cannot move "..modName.." down, there is not enough room"), L"OK")
  end
  WarBoard.AnchorMods()
end

function WarBoard.ChangeModBoard(modName)
	if not modName then
		modName = gsub(ClickedWindow, "Move", "")
	end
	local board, row, pos = WarBoard.GetModPosition(modName)
	if board == "Top" then
		tinsert(WarBoardSettings.Bottom.ModRows[ #WarBoardSettings.Bottom.ModRows ], modName)
		if WarBoard.CheckLength(WarBoardSettings.Bottom, #WarBoardSettings.Bottom.ModRows) then
			tremove(WarBoardSettings.Top.ModRows[ row ], pos)
			if #WarBoardSettings.Top.ModRows[ row ] == 0  and #WarBoardSettings.Top.ModRows > 1 then
				tremove(WarBoardSettings.Top.ModRows, row)
			end
			WarBoard.AnchorMods()
		else
			tremove(WarBoardSettings.Bottom.ModRows[ #WarBoardSettings.Bottom.ModRows ])
			WarBoard.AddRow(WarBoardSettings.Bottom.ModRows)
			tinsert(WarBoardSettings.Bottom.ModRows[ #WarBoardSettings.Bottom.ModRows ], modName)
			tremove(WarBoardSettings.Top.ModRows[ row ], pos)
			if #WarBoardSettings.Top.ModRows[ row ] == 0  and #WarBoardSettings.Top.ModRows > 1 then
				tremove(WarBoardSettings.Top.ModRows, row)
			end
			WarBoard.AnchorMods()
		end
	elseif board == "Bottom" then
		tinsert(WarBoardSettings.Top.ModRows[ #WarBoardSettings.Top.ModRows ], modName)
		if WarBoard.CheckLength(WarBoardSettings.Top, #WarBoardSettings.Top.ModRows) then
			tremove(WarBoardSettings.Bottom.ModRows[ row ], pos)
			if #WarBoardSettings.Bottom.ModRows[ row ] == 0 and #WarBoardSettings.Bottom.ModRows > 1 then
				tremove(WarBoardSettings.Bottom.ModRows, row)
			end
			WarBoard.AnchorMods()
		else
			tremove(WarBoardSettings.Top.ModRows[ #WarBoardSettings.Top.ModRows ])
			WarBoard.AddRow(WarBoardSettings.Top.ModRows)
			tinsert(WarBoardSettings.Top.ModRows[ #WarBoardSettings.Top.ModRows ], modName)
			tremove(WarBoardSettings.Bottom.ModRows[ row ], pos)
			if #WarBoardSettings.Bottom.ModRows[ row ] == 0 and #WarBoardSettings.Bottom.ModRows > 1 then
				tremove(WarBoardSettings.Bottom.ModRows, row)
			end
			WarBoard.AnchorMods()
		end
	end
end

function WarBoard.OpenLayoutMenu()
    local win = SystemData.ActiveWindow and SystemData.ActiveWindow.name or ""
    if win == "" then return end

    ClickedWindow = win

    -- strip "Move", "MoveLeft", or "MoveRight" suffix
    local modName = gsub(ClickedWindow, "Move.*$", "")
    if modName == "" then return end

    local boardName, row = WarBoard.GetModPosition(modName)
    if not boardName or not WarBoardSettings[boardName] then return end

    local changeRow   = WarBoardSettings[boardName].ModRows and (#WarBoardSettings[boardName].ModRows > 1) or false
    local changeBoard = false
    local destBoard   = nil

    if boardName == "Top" and WarBoardSettings.Bottom and WarBoardSettings.Bottom.Board.Enabled then
        changeBoard, destBoard = true, "Bottom"
    elseif boardName == "Bottom" and WarBoardSettings.Top and WarBoardSettings.Top.Board.Enabled then
        changeBoard, destBoard = true, "Top"
    end

    if not changeRow and not changeBoard then return end
    if not EA_Window_ContextMenu then return end

    EA_Window_ContextMenu.CreateContextMenu(win)

    if changeRow then
        EA_Window_ContextMenu.AddMenuItem(L"Move Up",   WarBoard.MoveModUp,   false, true)
        EA_Window_ContextMenu.AddMenuItem(L"Move Down", WarBoard.MoveModDown, false, true)
    end
    if changeBoard and destBoard then
        EA_Window_ContextMenu.AddMenuItem(towstring("Move to "..destBoard.." Board"), WarBoard.ChangeModBoard, false, true)
    end

    EA_Window_ContextMenu.Finalize()
end

------------BUTTONS-----------
function WarBoard.OnOptionsButton()
	WindowSetShowing("WarBoardOptions", not WindowGetShowing("WarBoardOptions"))
end

function WarBoard.OnLayoutModeButton()
	if not LayOutMode then
		if WarBoardSettings.Top.Board.Enabled then
			for k, v in ipairs(WarBoardSettings.Top.ModRows) do
				local row = k
				for k, v in ipairs(WarBoardSettings.Top.ModRows[ row ]) do
					local windowName = v.."Move"
					CreateWindowFromTemplate(windowName, "LayoutTemplate", v)
					WindowAddAnchor(windowName, "topleft", v, "topleft", 0, 0)
					WindowAddAnchor(windowName, "bottomright", v, "bottomright", 0, 0)
					WindowSetTintColor(windowName.."Background", 0, 0, 0)
					WindowSetAlpha(windowName.."Background", 0.5)
				end
			end
		end
		if WarBoardSettings.Bottom.Board.Enabled then
			for k, v in ipairs(WarBoardSettings.Bottom.ModRows) do
				local row = k
				for k, v in ipairs(WarBoardSettings.Bottom.ModRows[ row ]) do
					local windowName = v.."Move"
					CreateWindowFromTemplate(windowName, "LayoutTemplate", v)
					WindowAddAnchor(windowName, "topleft", v, "topleft", 0, 0)
					WindowAddAnchor(windowName, "bottomright", v, "bottomright", 0, 0)
					WindowSetTintColor(windowName.."Background", 0, 0, 0)
					WindowSetAlpha(windowName.."Background", 0.5)
				end
			end
		end
		LayOutMode = true
	else
		if WarBoardSettings.Top.Board.Enabled then
			for k, v in ipairs(WarBoardSettings.Top.ModRows) do
				local row = k
				for k, v in ipairs(WarBoardSettings.Top.ModRows[ row ]) do
					local windowName = v.."Move"
					DestroyWindow(windowName)
				end
			end
		end
		if WarBoardSettings.Bottom.Board.Enabled then
			for k, v in ipairs(WarBoardSettings.Bottom.ModRows) do
				local row = k
				for k, v in ipairs(WarBoardSettings.Bottom.ModRows[ row ]) do
					local windowName = v.."Move"
					DestroyWindow(windowName)
				end
			end
		end
		LayOutMode = false
	end
end

function WarBoard.OnMouseOver()
	WindowStartAlphaAnimation("WarBoardOptionsButton", Window.AnimationType.EASE_OUT, 0, 1, 0.5, true, 0, 1)
	WindowStartAlphaAnimation("WarBoardLayoutModeButton", Window.AnimationType.EASE_OUT, 0, 1, 0.5, true, 0, 1)
	local windowName = SystemData.ActiveWindow.name
	if sfind(windowName, "Layout") then
		Tooltips.CreateTextOnlyTooltip(windowName, nil)
		Tooltips.AnchorTooltip(Tooltips.ANCHOR_WINDOW_BOTTOM)
		Tooltips.SetTooltipText(1, 1, L"WarBoard Layout")
		Tooltips.SetTooltipText(2, 1, L"Click to begin/exit WarBoard Layout editing")
		Tooltips.Finalize()
	elseif sfind(windowName, "Options") then
		Tooltips.CreateTextOnlyTooltip(windowName, nil)
		Tooltips.AnchorTooltip(Tooltips.ANCHOR_WINDOW_BOTTOM)
		Tooltips.SetTooltipText(1, 1, L"WarBoard Options")
		Tooltips.SetTooltipText(2, 1, L"Click to open WarBoard Options window")
		Tooltips.Finalize()
	end
end

function WarBoard.OnMouseOverEnd()
	WindowStartAlphaAnimation("WarBoardOptionsButton", Window.AnimationType.EASE_OUT, 1, 0, 0.5, true, 0, 1)
	WindowStartAlphaAnimation("WarBoardLayoutModeButton", Window.AnimationType.EASE_OUT, 1, 0, 0.5, true, 0, 1)
end

function WarBoard.OnMouseOverBottom()
	WindowStartAlphaAnimation("BottomBoardOptionsButton", Window.AnimationType.EASE_OUT, 0, 1, 0.5, true, 0, 1)
	WindowStartAlphaAnimation("BottomBoardLayoutModeButton", Window.AnimationType.EASE_OUT, 0, 1, 0.5, true, 0, 1)
	local windowName = SystemData.ActiveWindow.name
	if sfind(windowName, "Layout") then
		Tooltips.CreateTextOnlyTooltip(windowName, nil)
		Tooltips.AnchorTooltip(Tooltips.ANCHOR_WINDOW_TOP)
		Tooltips.SetTooltipText(1, 1, L"WarBoard Layout")
		Tooltips.SetTooltipText(2, 1, L"Click to begin/exit WarBoard Layout editing")
		Tooltips.Finalize()
	elseif sfind(windowName, "Options") then
		Tooltips.CreateTextOnlyTooltip(windowName, nil)
		Tooltips.AnchorTooltip(Tooltips.ANCHOR_WINDOW_TOP)
		Tooltips.SetTooltipText(1, 1, L"WarBoard Options")
		Tooltips.SetTooltipText(2, 1, L"Click to open WarBoard Options window")
		Tooltips.Finalize()
	end
end

function WarBoard.OnMouseOverEndBottom()
	WindowStartAlphaAnimation("BottomBoardOptionsButton", Window.AnimationType.EASE_OUT, 1, 0, 0.5, true, 0, 1)
	WindowStartAlphaAnimation("BottomBoardLayoutModeButton", Window.AnimationType.EASE_OUT, 1, 0, 0.5, true, 0, 1)
end

function WarBoard.GetModToolTipAnchor(modName)
	local board = WarBoard.GetModPosition(modName)
	if board == "Top" then
		return Tooltips.ANCHOR_WINDOW_BOTTOM
	elseif board == "Bottom" then
		return Tooltips.ANCHOR_WINDOW_TOP
	end
end
