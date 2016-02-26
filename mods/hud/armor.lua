minetest.after(0, function()
 if not armor.def then
	minetest.after(2,minetest.chat_send_all,"#Better HUD: Please update your version of 3darmor")
	HUD_SHOW_ARMOR = false
 end
end)

function hud.get_armor(player)
	if not player or not armor.def then
		return
	end
	local name = player:get_player_name()
	armor:set_player_armor(player)
	hud.set_armor(name, armor.def[name].state, armor.def[name].count, armor.def[name].level)
end

function hud.set_armor(name, ges_state, items, armor_value)
	if ges_state == 0 and items == 0 then
		hud.armor[name] = 0
	else
		local max_items = 5
		if items == 6 then max_items = items end
		local max = max_items*65535
		local lvl = (max - ges_state)/max

		hud.armor[name] = lvl*(items*(20/max_items))
		hud.armor_value[name] = armor_value
	end
end
