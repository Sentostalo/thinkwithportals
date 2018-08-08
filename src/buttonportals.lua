--7266184

local itemdata = {}
local players={}
local code
local binds = {}
local _, nickname = pcall(nil)
local host = string.match(nickname, "(.-)%.")


do tfm.exec.chatMessage = function(t,n) --placeholder chatMessage for testing
	if n == nil then
		n = 'All'
	end
		print(string.format('> [%s] %s',n,t:sub(1,1000))) 
	end
end

function split(inputstr, sep) --split a string, returning array of sections
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t,str)
	end
	return t
end

function bind_items(xml) --bind keys to portal spawns
	local dom = parseXml(xml) --parse the xml
	local selected = path(dom, "Z", "PORTAL", "PORTAL") --open up our portal tag with spawns
	local itemdata = {} 
	for _, obj in ipairs(selected) do --iterate through portal binds 
		local item = {}
		item.blue = true
		color = '0x2F7AC2'
		dark = '0x1C1C69'
		for param, val in pairs(obj.attribute)do --iterate through properties
			if param=='O' then
				item.blue = false
				color = '0xDC7930'
				dark = '0x813905'
			elseif param=='KEY' then
				key = tonumber(val)+48
			else
				item[param]=val --set item param equals value in the table
			end
		end
		itemdata[key]=item --insert item params into all items data table
		ui.addTextArea(key, ' <a size="12" href="event:_">'..tostring(key-48)..'</a>', nil, item.X-8, item.Y-8, 20, 20, color, dark, 0.5, false)
	end
	return itemdata --return all item data
end

function place_portal(id) --place a portal
	local item = itemdata[id] --find portal data by id
	item_id = 27 --orange portal
	if item.blue then
		item_id = 26 --blue portal
	end
	tfm.exec.addShamanObject(item_id, item.X, item.Y, 0, 0, 0,false) --spawn portal
end

function main() --main script--
	tfm.exec.disableAutoShaman()
	tfm.exec.disableAutoNewGame()
	tfm.exec.disableAutoTimeLeft()
	tfm.exec.disableAutoScore()
	tfm.exec.disableAfkDeath()
	tfm.exec.newGame('@7266184')
	for _,keycode in pairs({48,49,50,51,52,53,54,55,56,57,46})do --bind numkeys--
		tfm.exec.bindKeyboard(host, keycode, true, true)
	end
end

function eventNewGame() --handle new game
	local xml = '' --set xml to empty str
	code = tfm.get.room.currentMap
	if code:sub(1,1)=='@' then --if map isn't vanilla
		xml = tfm.get.room.xmlMapInfo.xml --set xml to map xml
	end
	itemdata = bind_items(xml) --setup item data and coords
	for name in pairs(tfm.get.room.playerList)do
		if not (name==host) then --kill all non host players
			tfm.exec.killPlayer(name)
		end
	end
end

function eventPlayerWon(name, _, sinceres) --handle win
	tfm.exec.chatMessage(name..' completed map '..code..' in '..(sinceres/100)..'s\n\nUse the command !skip to go to the next map or press the Delete key to respawn.')
end

function eventKeyboard(name, keycode) --handle keypress
	if name == host then --if host
		if itemdata[keycode] ~= nil then --if a numkey
			place_portal(keycode)
		elseif keycode == 46 then --if del key
			tfm.exec.killPlayer(name)
			tfm.exec.respawnPlayer(name)
		end
	end
end

function eventTextAreaCallback(id, name) --handle clicking on ui message
	if name == host then --if host
		if itemdata[id] ~= nil then
			place_portal(id) --place portal
		end
	end
end

function eventNewPlayer(name) --handle new player
	tfm.exec.chatMessage('Welcome to #thinkwithportals. You are spectating on '..host..'\'s session.', name)
end

--makinit xml lib
do	
	local namePattern = "[%a_:][%w%.%-_:]*"
	function parseXml(xml)
		local root = {}
		local parents = {}
		local element = root
		for closing, name, attributes, empty, text in string.gmatch(xml, "<(/?)(" .. namePattern .. ")(.-)(/?)>%s*([^<]*)%s*") do
			if closing == "/" then
				local parent = parents[element]
				if parent and name == element.name then
				  element = parent
				end
			else
				local child = {name = name, attribute = {}}
				table.insert(element, child)
				parents[child] = element
				if empty ~= "/" then
				  element = child
				end
				for name, value in string.gmatch(attributes, "(" .. namePattern .. ")%s*=%s*\"(.-)\"") do
				  child.attribute[name] = value
				end
			end
			if text ~= "" then
				local child = {text = text}
				table.insert(element, child)
				parents[child] = element
			end
		end
		return root[1]
	end

	function path(nodes, ...)
		nodes = {nodes}
		for i, name in ipairs(arg) do
			local match = {}
			for i, node in ipairs(nodes) do
				for i, child in ipairs(node) do
					if child.name == name then
						table.insert(match, child)
					end
				end
			end
			nodes = match
		end
		return nodes
	end
end

main() --run script--
