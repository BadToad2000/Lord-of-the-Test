minetest.register_craftitem("lottfarming:orc_food", {
	description = "Orc Food",
	inventory_image = "lottfarming_orc_food.png",
	on_use = function(itemstack, user, pointed_thing)
		local name = user:get_player_name()
		local privs = minetest.get_player_privs(name)
		if minetest.get_player_privs(name).GAMEorc then
			hud.item_eat(6)
			hud.hunger[name] = math.min(20, hud.hunger[name] + 6)
			hud.set_hunger(user)
		else
			hud.hunger[name] = 20
			hud.set_hunger(user)
			local first_screen = user:hud_add({
				hud_elem_type = "image",
				position = {x=0, y=0},
				scale = {x=100, y=100},
				text = "orc_food.png",
				offset = {x=0, y=0},
			})
			minetest.after(10, function()
				user:hud_remove(first_screen)
				local second_screen = user:hud_add({
					hud_elem_type = "image",
					position = {x=0.5, y=0.5},
					scale = {x=-100, y=-100},
					text = "orc_food1.png",
					offset = {x=0, y=0},
				})
				minetest.after(10, function()
					user:hud_remove(second_screen)
				end)
			end)
		end
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "lottfarming:orc_food 4",
	recipe = {
		{"default:dirt", "lottfarming:potato_cooked", "default:dirt"},
		{"lottmobs:meat_raw", "farming:bread", "lottmobs:meat_raw"},
		{"default:dirt", "default:dirt", "default:dirt"},
	}
})

minetest.register_craftitem("lottfarming:orc_medicine", {
	description = "Orc medicine",
	inventory_image = "lottfarming_orc_medicine.png",
	on_use = function(itemstack, user, pointed_thing)
		user:set_hp(20)
		local first_screen = user:hud_add({
			hud_elem_type = "image",
			position = {x=0, y=0},
			scale = {x=100, y=100},
			text = "orc_medicine.png",
			offset = {x=0, y=0},
		})
		minetest.after(10, function()
			user:hud_remove(first_screen)
			local second_screen = user:hud_add({
				hud_elem_type = "image",
				position = {x=0.5, y=0.5},
				scale = {x=-100, y=-100},
				text = "orc_medicine1.png",
				offset = {x=0, y=0},
			})
			minetest.after(10, function()
				user:hud_remove(second_screen)
			end)
		end)
	end,
})

minetest.register_craft({
	output = "lottfarming:orc_medicine 2",
	recipe = {
		{"", "lottfarming:berries", ""},
		{"lottfarming:berries", "lottfarming:orc_food", "lottfarming:berries"},
		{"", "vessels:drinking_glass", ""},
	}
})
