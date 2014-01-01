
explorer_xp={}
explorer_xp.path=minetest.get_worldpath()

minetest.register_on_joinplayer(function(ObjectRef)
	explorer_xp[ObjectRef:get_player_name()]=0
end)

minetest.register_on_newplayer(function(ObjectRef)
	local newplayer=ObjectRef:get_player_name()
	explorer_xp[newplayer]=0
	local path =minetest.get_worldpath()
	minetest.after(1,function(param)
	os.execute("mkdir " ..path.."/players_conf/")
	local player_conf=io.open(path.."/players_conf/"..newplayer..".conf","w+")
	player_conf.close()
	local player_conf= Settings(path.."/players_conf/"..newplayer..".conf")
	player_conf:set("discovered_map","0")
	player_conf:write()
	end,{path=path,newplayer=newplayer})
end)

minetest.register_on_generated(function(minp, maxp, blockseed)
	local center={x=minp.x+math.abs(minp.x-maxp.x),y=minp.y+math.abs(minp.y-maxp.y),z=minp.z+math.abs(minp.z-maxp.z)}
	local nearest=nil
	for i,v in pairs(minetest.get_connected_players()) do
	local player =v:getpos()
	local dist=math.sqrt(math.pow((center.x-player.x),2)+math.pow((center.z-player.z),2)+math.pow((center.y-player.y),2))
		if nearest==nil then
			nearest={player=v:get_player_name(),dist=dist}
		elseif dist<nearest.dist then  
			nearest.dist = dist
			nearest.player=v:get_player_name()
			
		end
	
	end
	explorer_xp[nearest.player]=explorer_xp[nearest.player]+1
	if explorer_xp[nearest.player]>10 then
		local player_conf= Settings(explorer_xp.path.."/players_conf/"..nearest.player..".conf")
		local player_discovered_map_xp=tonumber(player_conf:get("discovered_map"))
		player_conf:set("discovered_map",tostring(player_discovered_map_xp+explorer_xp[nearest.player]))
		explorer_xp[nearest.player]=0
		player_conf:write()
	end
end)
