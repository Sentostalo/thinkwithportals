--timing functions to work with the tfm api
--spawns shaman objects periodically by using eventLoop
--the items are specified within the itemdata table

itemdata = {
	{id='32', coord="725,25", max="2", delay="1000"},
	{id='39', coord="200,200;400,200;600,200", max="6", delay="500"},
}

function split(inputstr, sep) --split a string, returning array of sections
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t,str)
	end
	return t
end

function setupCoordinates() --modify itemdata in place to setup coordinates
	for _,item in pairs(itemdata) do
		local parsed = {}
		local coords = split(item['coord'],';') --split the coordinate pairs
		for _,coord in pairs(coords) do
			table.insert(parsed,split(coord, ',')) --insert the split up x,y pair
		end
		item.coords = parsed --set the parsed coordinates
		item.currentcoords = parsed[1] --set the current coordinates
		item.currentindex=1 --set the current coordinate index
		item.spawned = {}
	end
end

function timeTasks(tasklist)
	if i == nil then
		i = 0
	end
	if math.floor(i)==i then --if not a half second
		for _,item in pairs(tasklist) do --iterate through timed tasks
			if(i%(item.delay/1000)==0)then --divide current timestamp by task delay in seconds, if no remainder execute task
				local x = item.currentcoords[1] --get x
				local y = item.currentcoords[2] --get y
				local objectid = tfm.exec.addShamanObject(item.id, x, y, 0,0,0,false) --add object
				--tfm.exec.removeObject(objectId-item.max)
				table.insert(item.spawned, objectid)
				if #item.spawned > tonumber(item.max) then --if the amount of items is over the max
					tfm.exec.removeObject(item.spawned[1]) --despawn the least recently spawned item
					table.remove(item.spawned, 1) --remove the id of least recently spawned item
				end
				if item.currentindex < #item.coords then --if the current index is within the table limits
					item.currentindex = item.currentindex + 1 --add to it
				else --otherwise
					item.currentindex = 1 --reset it to the start of the table
				end
				
				item.currentcoords = item.coords[item.currentindex] --set the current coords to the next coords.
				
			else --there is a remainder, this task should not be executed yet
			end
		end
		if i==300 then --reset i if it reaches 300 (end of round shouldnt exceed this)
			i=0
		end
	end
	i=i+0.5 --increment i by another 0.5 seconds
end

function eventLoop()
	timeTasks(itemdata)
end

setupCoordinates()

