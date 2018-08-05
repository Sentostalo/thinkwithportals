players={}

function eventNewPlayer(name) --bind stuff for a new player--
	for _,keycode in pairs({88,90})do --bind z and x keys--
		tfm.exec.bindKeyboard(name, keycode, true, true)
		tfm.exec.bindKeyboard(name, keycode, false, true)
	end
	system.bindMouse(name,true) --bind mouse--
	players[name]={blueportal=false, doportal=false} --setup playerdata--
end

function eventKeyboard(name, keycode, down, px, py) --handle keyboard press--
	if down then --if pressed key--
		players[name].doportal=true --allow portals to be placed--
		if keycode == 90 then --z, blue portal--
			players[name].blueportal=true
		elseif keycode == 88 then --x, orange portal--
			players[name].blueportal=false
		end
	else --not pressed--
		players[name].doportal=false --stop portals being placed--
	end
end

function eventMouse(name, mx, my) --handle mouse press--
	if players[name].doportal then --if do portal--
		if players[name].blueportal then --if do blue portal--
			tfm.exec.addShamanObject(26, mx, my, 0, 0, 0, false) --spawn blue portal--
			return
		end
		tfm.exec.addShamanObject(27, mx, my, 0, 0, 0, false) --instead, spawn orange portal--
	end
end

function main() --main script--
	for n,v in pairs(tfm.get.room.playerList) do --for existing players--
		eventNewPlayer(n) --setup binds--
	end
end


main() --run script--
