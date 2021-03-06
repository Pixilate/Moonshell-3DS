-- Internal SunShell variables
-- ui_enabled = true/false -- Sets Sunshell UI state (CallMainMenu force automatically ui_enabled to true value)
-- screenshots = true/false -- Sets Sunshell screenshot function through L button state (CallMainMenu force automatically screenshots to true value)

-- Internal SunShell extra functions

start_dir = System.currentDirectory()

-- * explode
-- PHP explode porting for LUA developing
function explode(div,str)
	pos = 0
	arr = {}
	for st,sp in function() return string.find(str,div,pos,true) end do
		table.insert(arr,string.sub(str,pos,st-1))
		pos = sp + 1
	end
	table.insert(arr,string.sub(str,pos))
	return arr
end

-- * CallMainMenu
-- Sets SunShell to Main Menu mode, usefull to exit from a module
function CallMainMenu()
	mode = nil
	module = "Main Menu"
	ui_enabled = true
	renderer = true
	screenshots = true
	refresh_screen = true
	refresh_screen2 = true
	System.currentDirectory(start_dir)
end

-- * SetBottomRefresh
-- Sets Refreshing Screen state for Bottom Screen
function SetBottomRefresh(value)
	refresh_screen = value
end

-- * SetTopRefresh
-- Sets Refreshing Screen state for Top Screen
function SetTopRefresh(value)
	refresh_screen2 = value
end

-- * DisableRenderer
-- Disable GPU renderer for both screens
function DisableRenderer()
	renderer = false
end

-- * CustomRenderBottom
-- Sets up a custom GPU rendering scene for bottom screen
function CustomRenderBottom(func)
	Graphics.initBlend(BOTTOM_SCREEN)
	func()
	Graphics.termBlend()
end

-- * CustomRenderTop
-- Sets up a custom GPU rendering scene for top screen
function CustomRenderTop(func)
	Graphics.initBlend(TOP_SCREEN)
	func()
	Graphics.termBlend()
end

-- * CloseBGApp
-- Close a selected BG App
function CloseBGApp(my_app)
	for i, apps in pairs(bg_apps) do
		if apps[3] == my_app then
			apps[2]()
			table.remove(bg_apps,i)
			break
		end
	end
end

-- * FormatTime
-- Format a number of seconds in a time-like string (Example: 123 seconds = 02:03)
function FormatTime(seconds)
	minute = math.floor(seconds/60)
	seconds = seconds%60
	hours = math.floor(minute/60)
	minute = minute%60
	if minute < 10 then
		minute = "0"..minute
	end
	if seconds < 10 then
		seconds = "0"..seconds
	end
	if hours == 0 then
		return minute..":"..seconds
	else
		return hours..":"..minute..":"..seconds
	end
end

-- * GarbageCollection
-- Free all allocated SunShell elements
function GarbageCollection()
	Graphics.freeImage(bg)
	Graphics.freeImage(b0)
	Graphics.freeImage(b1)
	Graphics.freeImage(b2)
	Graphics.freeImage(b3)
	Graphics.freeImage(b4)
	Graphics.freeImage(b5)
	Graphics.freeImage(charge)
	for i,tool in pairs(tools) do
		Graphics.freeImage(tool[1])
	end
end

-- * CropPrint
-- Used to print long strings on BOTTOM_SCREEN, it automatically crop too long strings
function CropPrint(x, y, text, color, screen)
	if string.len(text) > 50 then
		Font.print(ttf,x+2, y, string.sub(text,1,50) .. "...", color, screen)
	else
		Font.print(ttf,x+2, y, text, color, screen)
	end
end

-- * TopCropPrint
-- Used to print long strings on TOP_SCREEN, it automatically crop too long strings
function TopCropPrint(x, y, text, color, screen)
	if string.len(text) > 100 then
		Font.print(ttf,x+2, y, string.sub(text,1,100) .. "...", color, screen)
	else
		Font.print(ttf,x+2, y, text, color, screen)
	end
end

-- * DebugCropPrint
-- Used to print long strings on BOTTOM_SCREEN, it automatically crop too long strings
function DebugCropPrint(x, y, text, color, screen)
	if string.len(text) > 25 then
		Screen.debugPrint(x, y, string.sub(text,1,25) .. "...", color, screen)
	else
		Screen.debugPrint(x, y, text, color, screen)
	end
end

-- * DebugTopCropPrint
-- Used to print long strings on TOP_SCREEN, it automatically crop too long strings
function DebugTopCropPrint(x, y, text, color, screen)
	if string.len(text) > 42 then
		Screen.debugPrint(x, y, string.sub(text,1,42) .. "...", color, screen)
	else
		Screen.debugPrint(x, y, text, color, screen)
	end
end

-- * LastSpace
-- Return index of last space for text argument
function LastSpace(text)
	found = false
	start = -1
	while string.sub(text,start,start) ~= " " do
		start = start - 1
	end
	return start
end

-- * ErrorGenerator
-- PRIVATE FUNCTION: DO NOT USE
function ErrorGenerator(text)
	y = 68
	error_lines = {}
	while string.len(text) > 50 do
		endl = 51 + LastSpace(string.sub(text,1,50))
		table.insert(error_lines,{string.sub(text,1,endl), y})
		text = string.sub(text,endl+1,-1)
		y = y + 15
	end
	if string.len(text) > 0 then
		table.insert(error_lines,{text, y})
	end
end

-- * ShowError
-- Shows a SunShell error with a customizable text
function ShowError(text)
	confirm = false
	ErrorGenerator(text)
	max_y = error_lines[#error_lines][2] + 40
	Screen.fillEmptyRect(5,315,50,max_y,black,BOTTOM_SCREEN)
	Screen.fillRect(6,314,51,max_y-1,white,BOTTOM_SCREEN)
	Font.print(ttf,8,53,"Error",selected,BOTTOM_SCREEN)
	for i,line in pairs(error_lines) do
		Font.print(ttf,8,line[2],line[1],black,BOTTOM_SCREEN)
	end
	Screen.fillEmptyRect(147,176,max_y - 23, max_y - 8,black,BOTTOM_SCREEN)
	Font.print(ttf,155,max_y - 23,"OK",black,BOTTOM_SCREEN)
	Screen.flip()
	Screen.refresh()
	Screen.fillEmptyRect(5,315,50,max_y,black,BOTTOM_SCREEN)
	Screen.fillRect(6,314,51,max_y-1,white,BOTTOM_SCREEN)
	Font.print(ttf,8,53,"Error",selected,BOTTOM_SCREEN)
	for i,line in pairs(error_lines) do
		Font.print(ttf,8,line[2],line[1],black,BOTTOM_SCREEN)
	end
	Screen.fillEmptyRect(147,176,max_y - 23, max_y - 8,black,BOTTOM_SCREEN)
	Font.print(ttf,155,max_y - 23,"OK",black,BOTTOM_SCREEN)
	while not confirm do
		if (Controls.check(Controls.read(),KEY_TOUCH)) then
			x,y = Controls.readTouch()
			if x >= 147 and x <= 176 and y >= max_y - 23 and y <= max_y - 8 then
				confirm = true
			end
		end
	end
end

-- * ShowWarning
-- Shows a SunShell warning with a customizable text
function ShowWarning(text)
	confirm = false
	ErrorGenerator(text)
	max_y = error_lines[#error_lines][2] + 40
	Screen.fillEmptyRect(5,315,50,max_y,black,BOTTOM_SCREEN)
	Screen.fillRect(6,314,51,max_y-1,white,BOTTOM_SCREEN)
	Font.print(ttf,8,53,"Warning",selected,BOTTOM_SCREEN)
	for i,line in pairs(error_lines) do
		Font.print(ttf,8,line[2],line[1],black,BOTTOM_SCREEN)
	end
	Screen.fillEmptyRect(147,176,max_y - 23, max_y - 8,black,BOTTOM_SCREEN)
	Font.print(ttf,155,max_y - 23,"OK",black,BOTTOM_SCREEN)
	Screen.flip()
	Screen.refresh()
	Screen.fillEmptyRect(5,315,50,max_y,black,BOTTOM_SCREEN)
	Screen.fillRect(6,314,51,max_y-1,white,BOTTOM_SCREEN)
	Font.print(ttf,8,53,"Warning",selected,BOTTOM_SCREEN)
	for i,line in pairs(error_lines) do
		Font.print(ttf,8,line[2],line[1],black,BOTTOM_SCREEN)
	end
	Screen.fillEmptyRect(147,176,max_y - 23, max_y - 8,black,BOTTOM_SCREEN)
	Font.print(ttf,155,max_y - 23,"OK",black,BOTTOM_SCREEN)
	while not confirm do
		if (Controls.check(Controls.read(),KEY_TOUCH)) then
			x,y = Controls.readTouch()
			if x >= 147 and x <= 176 and y >= max_y - 23 and y <= max_y - 8 then
				confirm = true
			end
		end
	end
end

-- * LinesGenerator
-- Similar to CropPrint but for TOP_SCREEN, you can see Applications src to know how to use it
function LinesGenerator(text,y)
	error_lines = {}
	while string.len(text) > 60 do
		endl = 61 + LastSpace(string.sub(text,1,60))
		table.insert(error_lines,{string.sub(text,1,endl), y})
		text = string.sub(text,endl+1,-1)
		y = y + 15
	end
	if string.len(text) > 0 then
		table.insert(error_lines,{text, y})
	end
	return error_lines
end

-- * DebugLinesGenerator
-- Similar to CropPrint but for TOP_SCREEN, you can see Mail src to know how to use it
function DebugLinesGenerator(text,y)
	error_lines = {}
	while string.len(text) > 40 do
		endl = 41 + LastSpace(string.sub(text,1,40))
		table.insert(error_lines,{string.sub(text,1,endl), y})
		text = string.sub(text,endl+1,-1)
		y = y + 15
	end
	if string.len(text) > 0 then
		table.insert(error_lines,{text, y})
	end
	return error_lines
end

-- * AddIconTopbar
-- Add an Icon to Topbar
function AddIconTopbar(filename,id)
	table.insert(topbar_icons, {Graphics.loadImage(filename),id})
end

-- * FreeIconTopbar
-- Delete an Icon from Topbar
function FreeIconTopbar(my_app)
	for i, icon in pairs(topbar_icons) do
		if icon[2] == my_app then
			Graphics.freeImage(icon[1])
			table.remove(topbar_icons,i)
			break
		end
	end
end

-- * OneshotPrint
-- Optimized generic print function for code which needs to be executed only one time
function OneshotPrint(my_func)
	my_func()
	Screen.flip()
	Screen.refresh()
	my_func()
end

-- * CallKeyboard
-- Calls a new instance for a Danzeff Keyboard
function CallKeyboard(x, y)
	danzeff_mode = 1
	blockx = 2
	blocky = 2
	danzeff_x = x
	danzeff_y = y
	danzeff_map = {
		",abc.def!ghi-jkl\009m n?opq(rst:uvw)xyz",
		"\0\0\0001\0\0\0002\0\0\0003\0\0\0004\009\0 5\0\0\0006\0\0\0007\0\0\0008\0\00009",
		"^ABC@DEF*GHI_JKL\009M N\"OPQ=RST;UVW/XYZ",
		"'(.)\"<'>-[_]!{?}\009\0 \0+\\=/:@;#~$`%*^|&"
	}
	pic1 = Graphics.loadImage(theme_dir.."/images/keys.png")
	pic2 = Graphics.loadImage(theme_dir.."/images/nums.png")
	pic3 = Graphics.loadImage(theme_dir.."/images/keys_c.png")
	pic4 = Graphics.loadImage(theme_dir.."/images/nums_c.png")
	pic1m = Graphics.loadImage(theme_dir.."/images/keys_t.png")
	pic2m = Graphics.loadImage(theme_dir.."/images/nums_t.png")
	pic3m = Graphics.loadImage(theme_dir.."/images/keys_c_t.png")
	pic4m = Graphics.loadImage(theme_dir.."/images/nums_c_t.png")
	olddanzpad = KEY_A
end

-- * ShowKeyboard
-- Shows current keyboard instance
function ShowKeyboard()
	if danzeff_mode == 1 then
		h = pic1
		Graphics.drawImage(danzeff_x, danzeff_y, pic1m)
	elseif danzeff_mode == 2 then
		h = pic2
		Graphics.drawImage(danzeff_x, danzeff_y, pic2m)
	elseif danzeff_mode == 3 then
		h = pic3
		Graphics.drawImage(danzeff_x, danzeff_y, pic3m)
	else
		h = pic4
		Graphics.drawImage(danzeff_x, danzeff_y, pic4m)
	end
	danx = (blockx - 1) * 50
	dany = (blocky - 1) * 50
	Graphics.drawPartialImage(danzeff_x + danx, danzeff_y + dany, danx, dany, 50, 50, h)
end

-- * KeyboardInput()
-- Gets current keyboard input
function KeyboardInput()		
	cx, cy = Controls.readCirclePad()
	danzpad = Controls.read()
	posx = 2
	posy = 2	
	if cx < -50 then
		posx = 1
	end
	if cx > 50 then
		posx = 3
	end
	if cy > 50 then
		posy = 1
	end
	if cy < -50 then
		posy = 3
	end	
	if blocky ~= posy or blockx ~= posx then
		blocky = posy
		blockx = posx
	end	
	if danzeff_mode > 2 then
		danzeff_mode = danzeff_mode - 2
	end	
	if Controls.check(danzpad, KEY_R) and not Controls.check(olddanzpad, KEY_R) then
		if danzeff_mode == 1 then
			danzeff_mode = 2
		else
			danzeff_mode = 1
		end
	end
	if Controls.check(danzpad, KEY_R) then
		danzeff_mode = danzeff_mode + 2
	end	
	charpos = (blocky - 1) * 12 + (blockx - 1) * 4
	if Controls.check(danzpad, KEY_Y) and not Controls.check(olddanzpad, KEY_Y) then
		res = string.byte(danzeff_map[danzeff_mode], charpos + 2)
	elseif Controls.check(danzpad, KEY_A) and not Controls.check(olddanzpad, KEY_A) then
		res = string.byte(danzeff_map[danzeff_mode], charpos + 4)
	elseif Controls.check(danzpad, KEY_B) and not Controls.check(olddanzpad, KEY_B) then
		res = string.byte(danzeff_map[danzeff_mode], charpos + 3)
	elseif Controls.check(danzpad, KEY_X) and not Controls.check(olddanzpad, KEY_X) then
		res = string.byte(danzeff_map[danzeff_mode], charpos + 1)
	else
		res = 0
	end	
	olddanzpad = danzpad
	return res
end

-- * CloseKeyboard()
-- Close current keyboard instance
function CloseKeyboard()
	Graphics.freeImage(pic1)
	Graphics.freeImage(pic2)
	Graphics.freeImage(pic3)
	Graphics.freeImage(pic4)
	Graphics.freeImage(pic1m)
	Graphics.freeImage(pic2m)
	Graphics.freeImage(pic3m)
	Graphics.freeImage(pic4m)
end