-- Set private "Game" mode
mode = "Game"

-- Internal module settings
master_index_g = 0
p_g = 1
function CheckDirectory(src,key)
	tmp = System.listDirectory(src)
	for i,file in pairs(tmp) do
		if file.directory then
			if file.name == key then
				return true
			end
		end
	end
	return false
end
if build == "3DS" then
	my_apps = {}
	-- No access to AM service so manual CIA listing
	tmp = System.listDirectory("/Nintendo 3DS/")
	for i,file in pairs(tmp) do
		if file.directory then
			for z,subfile in pairs(System.listDirectory("/Nintendo 3DS/"..file.name.."/")) do
				if subfile.directory then
					my_path = "/Nintendo 3DS/"..file.name.."/"..subfile.name.."/"
					if CheckDirectory(my_path,"title") then
						my_path = my_path .. "title/"
						if CheckDirectory(my_path,"00040000") then
							for j,cia_file in pairs(System.listDirectory(my_path.."00040000/")) do
								if cia_file.directory then
									table.insert(my_apps,{false,tonumber(cia_file.name,16),"0x"..string.upper(string.sub(cia_file.name,1,-3)),"","0x"..string.upper(string.sub(cia_file.name,1,-3)),nil})
								end
							end
						end
					end
				end
			end
		end
	end
else
	my_apps = {}
	if build == "3DSX" then
		dir = System.listDirectory("/3ds/")
		for i,file in pairs(dir) do
			if file.directory then
				if System.doesFileExist("/3ds/"..(file.name).."/"..(file.name)..".3dsx") then
					if System.doesFileExist("/3ds/"..(file.name).."/"..(file.name)..".smdh") then
						app = System.extractSMDH("/3ds/"..(file.name).."/"..(file.name)..".smdh")
						table.insert(my_apps,{true,file.name,app.title,app.desc,app.author,app.icon})
					else
						table.insert(my_apps,{true,file.name,file.name,"","",nil})
					end
				end
			end
		end
	else
		table.insert(my_apps,{false,nil,"Game Cartridge","","0x0",nil})-- Insert Gamecard voice
		dir = System.listCIA()
		for i,file in pairs(dir) do
			if file.mediatype == SDMC then
				table.insert(my_apps,{false,file.unique_id,file.product_id,"","0x"..string.sub(string.format('%02X',file.unique_id),1,-3),nil})
			end
		end
	end
end

-- Module main cycle
function AppMainCycle()
	
	-- Draw top screen box
	Screen.fillEmptyRect(5,395,40,220,black,TOP_SCREEN)
	Screen.fillRect(6,394,41,219,white,TOP_SCREEN)
	
	-- Draw bottom screen listmenu and top screen info
	base_y = 0
	for l, file in pairs(my_apps) do
		if (base_y > 226) then
			break
		end
		if (l >= master_index_g) then
			if (l==p_g) then
				base_y2 = base_y
				if (base_y) == 0 then
					base_y = 2
				end
				Screen.fillRect(0,319,base_y-2,base_y2+12,selected_item,BOTTOM_SCREEN)
				CropPrint(9,45,file[3],selected,TOP_SCREEN)
				CropPrint(9,60,file[5],black,TOP_SCREEN)
				gw_rom = System.getGWRomID()
				if file[2] == nil and build == "CIA" and gw_rom ~= "" then -- GW roms support
					desc = LinesGenerator("This is a 3DS rom probably loaded with a Gateway card. Product-ID: "..gw_rom,90)
				else
					desc = LinesGenerator(file[4],90)
				end
				for i,line in pairs(desc) do
					Screen.debugPrint(9,line[2],line[1],black,TOP_SCREEN)
				end
				if file[6] ~= nil then
					Screen.fillEmptyRect(341,390,43,92,black,TOP_SCREEN)
					Screen.drawImage(342,44,file[6],TOP_SCREEN)
				end
				color = selected
				if (base_y) == 2 then
					base_y = 0
				end
			else
				color = black
			end
			if file[1] then
				CropPrint(0,base_y,file[2],color,BOTTOM_SCREEN)
			else
				CropPrint(0,base_y,file[3],color,BOTTOM_SCREEN)
			end
			base_y = base_y + 15
		end
	end
	
	-- Sets controls triggering
	if Controls.check(pad,KEY_B) or Controls.check(pad,KEY_START) then
		CallMainMenu()
		for l, file in pairs(my_apps) do
			if file[6] ~= nil then
				Screen.freeImage(file[6])
			end
		end
	elseif Controls.check(pad,KEY_A) then
		GarbageCollection()
		for i,bg_apps_code in pairs(bg_apps) do
			bg_apps_code[2]()
		end
		for l, file in pairs(my_apps) do
			if file[6] ~= nil then
				Screen.freeImage(file[6])
			end
		end
		Sound.term()
		if my_apps[p_g][1] then
			System.launch3DSX("/3ds/"..my_apps[p_g][2].."/"..my_apps[p_g][2]..".3dsx")
		else
			if my_apps[p_g][2] == nil then
				ShowWarning("You will be redirected to sysNand and your gamecard will be launched.")
				System.launchGamecard()
			else
				System.launchCIA(my_apps[p_g][2],SDMC)
			end
		end
	elseif (Controls.check(pad,KEY_DUP)) and not (Controls.check(oldpad,KEY_DUP)) then
		p_g = p_g - 1
		if (p_g >= 16) then
			master_index_g = p_g - 15
		end
	elseif (Controls.check(pad,KEY_DDOWN)) and not (Controls.check(oldpad,KEY_DDOWN)) then
		p_g = p_g + 1
		if (p_g >= 17) then
			master_index_g = p_g - 15
		end
	end
	if (p_g < 1) then
		p_g = #my_apps
		if (p_g >= 17) then
			master_index_g = p_g - 15
		end
	elseif (p_g > #my_apps) then
		master_index_g = 0
		p_g = 1
	end
end