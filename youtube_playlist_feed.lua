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


function probe()
     return (vlc.access == "http" or vlc.access == "https")
     and vlc.path:find("www.youtube.com/feeds/videos.xml?playlist_id=",1,true)
     -- maybe without www.
end

local filter = function(lab)
  local function f(node,i)
    i = i or 1
    local ch = node[i]
    if ch == nil then return
    elseif type(ch) == "table" and ch.label
    and ch.label == lab then return i+1,ch
    else return f(node,i+1)
    end
  end
  return f
end

function parse()
  local s = vlc.read(1e9)
  local tree = collect(s)
  local _,feed = filter"feed"(tree)
  local items = {}
  local f2 = function(lab) --TODO pcall.
    local f = filter(lab)
    return function(...)
      local _,ch = f(...)
      return ch
    end
  end
  local rch = function(s)
    if type(s) == "string" then return vlc.strings.resolve_xml_special_chars(s)
    else return nil
    end
  end
  
  local name = rch( f2"title"(feed)[1] )
  vlc.msg.info("Playlist name " .. name)
  local author = rch( f2"name"(f2"author"(feed))[1] )
  vlc.msg.info("Playlist author " .. author)

  for _,entry in filter"entry", feed do
    local mgroup = f2"media:group"(entry)
    local mcom = f2"media:community"(mgroup)

    local item = {
      path = f2"link"(entry).xarg.href,
      title = rch( f2"title"(entry)[1] ),
      artist = rch( f2"name"(f2"author"(entry))[1] ) ,
      arturl = f2"media:thumbnail"(mgroup).xarg.url,
      description = rch( f2"media:description"(mgroup)[1] ),
      rating = f2"media:starRating"(mcom).xarg.average,
      date = f2"published"(entry)[1],
      tracknum = f2"media:statistics"(mcom).xarg.views,
    }
    items[#items+1] = item
  end
   
  return items
end

------------------------
-- see http://lua-users.org/wiki/LuaXml

function parseargs(s)
  local arg = {}
  string.gsub(s, "([%w:_%-]+)=([\"'])(.-)%2", function (w, _, a)
    arg[w] = a
  end)
  return arg
end

function collect(s)
  local stack = {}
  local top = {}
  table.insert(stack, top)
  local ni,c,label,xarg, empty
  local i, j = 1, 1
  while true do
--    ni,j,c,label,xarg, empty = string.find(s, "<(%/?)([%w:]+)(.-)(%/?)>", i)
    ni,j,c,label,xarg, empty = string.find(s, "<(%/?)([%w:_%-]+)(.-)(%/?)>", i)
    if not ni then break end
    local text = string.sub(s, i, ni-1)
    if not string.find(text, "^%s*$") then
      table.insert(top, text)
    end
    if empty == "/" then  -- empty element tag
      table.insert(top, {label=label, xarg=parseargs(xarg), empty=1})
    elseif c == "" then   -- start tag
      top = {label=label, xarg=parseargs(xarg)}
      table.insert(stack, top)   -- new level
    else  -- end tag
      local toclose = table.remove(stack)  -- remove top
      top = stack[#stack]
      if #stack < 1 then
        error("nothing to close with "..label)
      end
      if toclose.label ~= label then
        error("trying to close "..toclose.label.." with "..label)
      end
      table.insert(top, toclose)
    end
    i = j+1
  end
  local text = string.sub(s, i)
  if not string.find(text, "^%s*$") then
    table.insert(stack[#stack], text)
  end
  if #stack > 1 then
    error("unclosed "..stack[#stack].label)
  end
  return stack[1]
end

