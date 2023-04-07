--[[
Copyright (C) 2020 roland1
modified at 2023 by apptestermc

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
--]]

local NAME = "append_pl_ch_feed"
local VERSION = "0.0.1"
function descriptor()
	return {
		title = NAME,
		version = VERSION,
		author = "apptestermc",
		license = "GPL",
		shortdesc = NAME,
		description = "Append YouTube playlist to playlist.m3u8",
		url = nil,
		capabilities = {},
	}
end

------------------------------------------
local file = {}
file.read = function(path)
	local fr, err = io.open(path, "rb")
	if not fr then return nil, err end
	local s, err = fr:read"*a"
	fr:close()
	if not s then return nil, err end
	return s
end
file.write = function(path, ...)
	local fa, err = io.open(path, "wb")
	if not fa then return nil, err end
	local o, err = fa:write(...)
	fa:close()
	return o, err
end
file.append = function(path, ...)
	local fa, err = io.open(path, "ab")
	if not fa then return nil, err end
	local o, err = fa:write(...)
	fa:close()
	return o, err
end
file.exist = function(path)
	local fa, err = io.open(path)
	if not fa then return false end
	fa:close()
	return true
end

------------------------------------------
local HELP = [[
<b>ALL FIELDS MUST BE NON-EMPTY.</b><br/>
<b>playlistName</b> For aesthetical reasons.<br/>
<b>playlistId</b> Unique playlist id. Can be found in urls like<br/>
https://www.youtube.com/...?list={playlistId}<br/>
Such urls can be pasted directly into this field.<br/>
<b>playlistPath</b> New Directories are <b>NOT</b> created.<br/>
A Path into the My Videos directory of vlc is preferable,<br/>
should end in .m3u8.<br/>
<b>[Append]</b> Converts Youtube playlist to rss playlist.<br/>
<b>[Clear]</b> Clears playlist entries from this dialog.
]]
local maybeStr = function(s,ss)
  if type(s) == "string" and s ~= "" then return s end
  return ss
end
function activate()
	local pd = package.config:sub(1, 1)
	local udd = vlc.config.userdatadir():gsub(pd.."+$", "")
	local uhd = vlc.config.homedir():gsub(pd.."+$", "")
	local confp = udd..pd..NAME..".playlistPath"
	local dlg = vlc.dialog(NAME)
	local txt,row = {},1
  local playlistPath0 = maybeStr(
    file.read(confp),
    uhd..pd.."Videos"..pd.."youtube.m3u8"
  )
  local tnames = {"playlistName", "playlistId", "playlistPath"}
	for _,lb in ipairs(tnames) do
		dlg:add_label(lb,1,row)
		txt[lb] = dlg:add_text_input("",2,row)
		row = row+1
	end
	txt.playlistPath:set_text(playlistPath0)
	local help_lb, help_cb

	dlg:add_button("Append",function()
    local buf = {}
    for i,tn in ipairs(tnames) do
      local x = txt[tn]:get_text()
      if not maybeStr(x,false) then
        if not help_lb then help_cb() end
        return
      end
      buf[i] = x
    end
    local pp = buf[3]
    if pp ~= playlistPath0 then file.write(confp,pp) end
    local ci = buf[2]:gsub('^.+list=([^/]+).*',"%1")

    if not file.exist(pp) and not file.write(pp,"#EXTM3U\n") then
      if not help_lb then help_cb() end
      return
    end

    if not file.append(
      pp,"\n",
      "#EXTINF:-1,",buf[1],"\n",
      "https://www.youtube.com/feeds/videos.xml?playlist_id=",ci,"\n"
    ) then
        if not help_lb then help_cb() end
        return
    end
	end,1,row)
	row = row+1

	dlg:add_button("Clear",function()
		for k = 1,2 do
			txt[ tnames[k] ]:set_text("")
		end
	end,1,row)
	row = row+1
	local row0 = row
	help_cb = function()
		if not help_lb then
			help_lb = dlg:add_html(HELP,2,row0,1,5)
		else
			dlg:del_widget(help_lb)
			help_lb = nil
		end
	end
	dlg:add_button("Help",help_cb, 1,row0)

	dlg:show()
end

function close()
	deactivate()
end

function deactivate()
	--if dlg then dlg:hide() end
	vlc.deactivate()
end

function input_changed()
end

function meta_changed() 
end
