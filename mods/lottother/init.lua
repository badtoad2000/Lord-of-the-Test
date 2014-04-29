minetest.register_node("lottother:blue_torch", {
	description = "Blue Torch",
	drawtype = "torchlike",
	tiles = {
		{name="lottother_blue_torch_floor_animated.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=3.0}},
		{name="lottother_blue_torch_ceiling_animated.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=3.0}},
		{name="lottother_blue_torch_animated.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=3.0}}
	},
	inventory_image = "lottother_blue_torch_floor.png",
	wield_image = "lottother_blue_torch_floor.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = false,
	light_source = LIGHT_MAX-1,
	selection_box = {
		type = "wallmounted",
		wall_top = {-0.1, 0.5-0.6, -0.1, 0.1, 0.5, 0.1},
		wall_bottom = {-0.1, -0.5, -0.1, 0.1, -0.5+0.6, 0.1},
		wall_side = {-0.5, -0.3, -0.1, -0.5+0.3, 0.3, 0.1},
	},
	groups = {choppy=2,dig_immediate=3,flammable=1,attached_node=1,hot=2},
	legacy_wallmounted = true,
	sounds = default.node_sound_defaults(),
})
minetest.register_node("lottother:Orc_torch", {
	description = "Orc Torch",
	drawtype = "torchlike",
	tiles = {
		{name="lottother_orc_torch_floor_animated.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=3.0}},
		{name="lottother_orc_torch_ceiling_animated.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=3.0}},
		{name="lottother_orc_torch_animated.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=3.0}}
	},
	inventory_image = "lottother_orc_torch_floor.png",
	wield_image = "lottother_orc_torch_floor.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = false,
	light_source = LIGHT_MAX-1,
	selection_box = {
		type = "wallmounted",
		wall_top = {-0.1, 0.5-0.6, -0.1, 0.1, 0.5, 0.1},
		wall_bottom = {-0.1, -0.5, -0.1, 0.1, -0.5+0.6, 0.1},
		wall_side = {-0.5, -0.3, -0.1, -0.5+0.3, 0.3, 0.1},
	},
	groups = {choppy=2,dig_immediate=3,flammable=1,attached_node=1,hot=2},
	legacy_wallmounted = true,
	sounds = default.node_sound_defaults(),
})

minetest.register_node("lottother:air", {
	description = "Air Substitute",
	drawtype = "airlike",
	tiles = {name="lottother_air.png"},
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = false,
	groups = {not_in_creative_inventory=1},
	sounds = default.node_sound_defaults(),
})

minetest.register_node("lottother:blue_flame", {
	description = "Blue Flame",
	drawtype = "plantlike",
	tiles = {{
		name="lottother_blue_flame_animated.png",
		animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1},
	}},
	inventory_image = "lottother_blue_flame.png",
	light_source = 14,
	groups = {igniterblue=2,dig_immediate=3,hot=3},
	drop = '',
	walkable = false,
	buildable_to = true,
	damage_per_second = 4,
	
	after_place_node = function(pos, placer)
		fire.on_flame_add_at(pos)
	end,
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		fire.on_flame_remove_at(pos)
	end,
})

lottother = {}
lottother.D = 6
lottother.sounds = {}

function lottother.get_area_p0p1(pos)
	local p0 = {
		x=math.floor(pos.x/lottother.D)*lottother.D,
		y=math.floor(pos.y/lottother.D)*lottother.D,
		z=math.floor(pos.z/lottother.D)*lottother.D,
	}
	local p1 = {
		x=p0.x+lottother.D-1,
		y=p0.y+lottother.D-1,
		z=p0.z+lottother.D-1
	}
	return p0, p1
end

function lottother.update_sounds_around(pos)
	local p0, p1 = lottother.get_area_p0p1(pos)
	local cp = {x=(p0.x+p1.x)/2, y=(p0.y+p1.y)/2, z=(p0.z+p1.z)/2}
	local flames_p = minetest.find_nodes_in_area(p0, p1, {"lottother:blue_flame"})
	local should_have_sound = (#flames_p > 0)
	local wanted_sound = nil
	if #flames_p >= 9 then
		wanted_sound = {name="fire_large", gain=1.5}
	elseif #flames_p > 0 then
		wanted_sound = {name="fire_small", gain=1.5}
	end
	local p0_hash = minetest.hash_node_position(p0)
	local sound = lottother.sounds[p0_hash]
	if not sound then
		if should_have_sound then
			lottother.sounds[p0_hash] = {
				handle = minetest.sound_play(wanted_sound, {pos=cp, loop=true}),
				name = wanted_sound.name,
			}
		end
	else
		if not wanted_sound then
			minetest.sound_stop(sound.handle)
			lottother.sounds[p0_hash] = nil
		elseif sound.name ~= wanted_sound.name then
			minetest.sound_stop(sound.handle)
			lottother.sounds[p0_hash] = {
				handle = minetest.sound_play(wanted_sound, {pos=cp, loop=true}),
				name = wanted_sound.name,
			}
		end
	end
end

function lottother.on_flame_add_at(pos)
	lottother.update_sounds_around(pos)
end

function lottother.on_flame_remove_at(pos)
	lottother.update_sounds_around(pos)
end

function lottother.find_pos_for_flame_around(pos)
	return minetest.find_node_near(pos, 1, {"air"})
end

function lottother.flame_should_extinguish(pos)
	if minetest.setting_getbool("disable_lottother") then return true end
	local p0 = {x=pos.x-2, y=pos.y, z=pos.z-2}
	local p1 = {x=pos.x+2, y=pos.y, z=pos.z+2}
	local ps = minetest.find_nodes_in_area(p0, p1, {"group:puts_out_lottother"})
	return (#ps ~= 0)
end

minetest.register_abm({
	nodenames = {"group:flammableblue"},
	neighbors = {"group:igniterblue"},
	interval = 1,
	chance = 2,
	action = function(p0, node, _, _)
		if lottother.flame_should_extinguish(p0) then
			return
		end
		local p = lottother.find_pos_for_flame_around(p0)
		if p then
			minetest.set_node(p, {name="lottother:blue_flame"})
			lottother.on_flame_add_at(p)
		end
	end,
})

minetest.register_abm({
	nodenames = {"group:igniterblue"},
	neighbors = {"air"},
	interval = 2,
	chance = 10,
	action = function(p0, node, _, _)
		local reg = minetest.registered_nodes[node.name]
		if not reg or not reg.groups.igniterblue or reg.groups.igniterblue < 2 then
			return
		end
		local d = reg.groups.igniterblue
		local p = minetest.find_node_near(p0, d, {"group:flammableblue"})
		if p then
			if lottother.flame_should_extinguish(p) then
				return
			end
			local p2 = lottother.find_pos_for_flame_around(p)
			if p2 then
				minetest.set_node(p2, {name="lottother:blue_flame"})
				lottother.on_flame_add_at(p2)
			end
		end
	end,
})

minetest.register_abm({
	nodenames = {"lottother:blue_flame"},
	interval = 1,
	chance = 2,
	action = function(p0, node, _, _)
		if lottother.flame_should_extinguish(p0) then
			minetest.remove_node(p0)
			lottother.on_flame_remove_at(p0)
			return
		end
		if math.random(1,3) == 1 then
			return
		end
		if not minetest.find_node_near(p0, 1, {"group:flammableblue"}) then
			minetest.remove_node(p0)
			lottother.on_flame_remove_at(p0)
			return
		end
		if math.random(1,4) == 1 then
			local p = minetest.find_node_near(p0, 1, {"group:flammableblue"})
			if p then
				if lottother.flame_should_extinguish(p0) then
					return
				end
				minetest.remove_node(p)
				nodeupdate(p)
			end
		else
			minetest.remove_node(p0)
			lottother.on_flame_remove_at(p0)
		end
	end,
})

minetest.register_craft({
	output = 'lottother:blue_torch',
	recipe = {
		{'lottores:rough_rock_lump'},
		{'group:stick'},
	}
})
