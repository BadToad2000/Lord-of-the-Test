-- paragenv7 0.3.1 by paramat
-- For latest stable Minetest and back to 0.4.8
-- Depends default
-- Licenses: code WTFPL, textures CC BY-SA

-- new in 0.3.1:
-- ice varies thickness with temp
-- dirt as papyrus bed, check for water below papyrus
-- clay at mid-temp
-- 'is ground content' false for leaves only

-- TODO
-- fog

-- Parameters

local HITET = 0.4 -- High temperature threshold
local LOTET = -0.4 -- Low ..
local ICETET = -0.8 -- Ice ..
local HIHUT = 0.4 -- High humidity threshold
local LOHUT = -0.4 -- Low ..
local HIRAN = 0.4
local LORAN = -0.4
local PAPCHA = 3 -- Papyrus
local DUGCHA = 5 -- Dune grass
local biome_blend = minetest.setting_getbool("biome_blend")
local use_register_biome = minetest.setting_getbool("use_register_biome") or true

--Rarity for Trees

local TREE1 = 30
local TREE2 = 50
local TREE3 = 100
local TREE4 = 200
local TREE5 = 300
local TREE6 = 500
local TREE7 = 750
local TREE8 = 1000
local TREE9 = 2000
local TREE10 = 5000

--Rarity for Plants

local PLANT1 = 3
local PLANT2 = 5
local PLANT3 = 10
local PLANT4 = 20
local PLANT5 = 50
local PLANT6 = 100
local PLANT7 = 200
local PLANT8 = 500
local PLANT9 = 750
local PLANT10 = 1000
local PLANT11 = 2000
local PLANT12 = 5000
local PLANT13 = 10000

-- 2D noise for temperature

local np_temp = {
	offset = 0,
	scale = 1,
	spread = {x=512, y=512, z=512},
	seed = 9130,
	octaves = 3,
	persist = 0.5
}

-- 2D noise for humidity

local np_humid = {
	offset = 0,
	scale = 1,
	spread = {x=512, y=512, z=512},
	seed = -5500,
	octaves = 3,
	persist = 0.5
}

local np_random = {
	offset = 0,
	scale = 1,
	spread = {x=512, y=512, z=512},
	seed = 4510,
	octaves = 3,
	persist = 0.5
}

-- Stuff
lottmapgen = {}
local mapgen_params = minetest.get_mapgen_params()
local wl = mapgen_params.water_level

dofile(minetest.get_modpath("lottmapgen").."/nodes.lua")
dofile(minetest.get_modpath("lottmapgen").."/functions.lua")

if not use_register_biome then
-- On generated function
minetest.register_on_generated(function(minp, maxp, seed)
	if maxp.y < (mapgen_params.water_level-32) or minp.y > 5000 then
		return
	end

	local t1 = os.clock()
	local x1 = maxp.x
	local y1 = maxp.y
	local z1 = maxp.z
	local x0 = minp.x
	local y0 = math.max(minp.y, wl - 32)  -- currently only changing nodes to a depth of 32
	local z0 = minp.z

	--print ("[lottmapgen_checking] chunk minp ("..x0.." "..y0.." "..z0..")")

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()

	local c_air = minetest.get_content_id("air")
	local c_sand = minetest.get_content_id("default:sand")
	local c_desertsand = minetest.get_content_id("default:desert_sand")
	local c_snowblock = minetest.get_content_id("default:snowblock")
	local c_snow = minetest.get_content_id("default:snow")
	local c_ice = minetest.get_content_id("default:ice")
	local c_dirtsnow = minetest.get_content_id("default:dirt_with_snow")
	local c_dirtgrass = minetest.get_content_id("default:dirt_with_grass")
	local c_dirt = minetest.get_content_id("default:dirt")
	local c_dryshrub = minetest.get_content_id("default:dry_shrub")
	local c_clay = minetest.get_content_id("default:clay")
	local c_stone = minetest.get_content_id("default:stone")
	local c_desertstone = minetest.get_content_id("default:desert_stone")
	local c_stonecopper = minetest.get_content_id("default:stone_with_copper")
	local c_stoneiron = minetest.get_content_id("default:stone_with_iron")
	local c_stonecoal = minetest.get_content_id("default:stone_with_coal")
	local c_water = minetest.get_content_id("default:water_source")
	local c_river_water = minetest.get_content_id("default:river_water_source")
	local c_morwat = minetest.get_content_id("lottmapgen:blacksource")
	local c_morrivwat = minetest.get_content_id("lottmapgen:black_river_source")

	local c_morstone = minetest.get_content_id("lottmapgen:mordor_stone")
	local c_frozenstone = minetest.get_content_id("lottmapgen:frozen_stone")
	local c_dungrass = minetest.get_content_id("lottmapgen:dunland_grass")
	local c_gondorgrass = minetest.get_content_id("lottmapgen:gondor_grass")
	local c_loriengrass = minetest.get_content_id("lottmapgen:lorien_grass")
	local c_fangorngrass = minetest.get_content_id("lottmapgen:fangorn_grass")
	local c_mirkwoodgrass = minetest.get_content_id("lottmapgen:mirkwood_grass")
	local c_rohangrass = minetest.get_content_id("lottmapgen:rohan_grass")
	local c_shiregrass = minetest.get_content_id("lottmapgen:shire_grass")
	local c_ironhillgrass = minetest.get_content_id("lottmapgen:ironhill_grass")
	local c_salt = minetest.get_content_id("lottores:mineral_salt")
	local c_pearl = minetest.get_content_id("lottores:mineral_pearl")
	local c_angsnowblock = minetest.get_content_id("lottmapgen:angsnowblock")
	local c_mallos = minetest.get_content_id("lottplants:mallos")
	local c_seregon = minetest.get_content_id("lottplants:seregon")
	local c_bomordor = minetest.get_content_id("lottplants:brambles_of_mordor")
	local c_pilinehtar = minetest.get_content_id("lottplants:pilinehtar")
	local c_ithilgrass = minetest.get_content_id("lottmapgen:ithilien_grass")
	local c_melon = minetest.get_content_id("lottplants:melon_wild")
	local c_angfort = minetest.get_content_id("lottmapgen:angmarfort")
	local c_gonfort = minetest.get_content_id("lottmapgen:gondorfort")
	local c_hobhole = minetest.get_content_id("lottmapgen:hobbithole")
	local c_orcfort = minetest.get_content_id("lottmapgen:orcfort")
	local c_malltre = minetest.get_content_id("lottmapgen:mallornhouse")
	local c_lorhous = minetest.get_content_id("lottmapgen:lorienhouse")
	local c_mirktre = minetest.get_content_id("lottmapgen:mirkhouse")
	local c_rohfort = minetest.get_content_id("lottmapgen:rohanfort")

	local sidelen = x1 - x0 + 1
	local chulens = {x=sidelen, y=sidelen, z=sidelen}
	local minposxz = {x=x0, y=z0}

	local nvals_temp = minetest.get_perlin_map(np_temp, chulens):get2dMap_flat(minposxz)
	local nvals_humid = minetest.get_perlin_map(np_humid, chulens):get2dMap_flat(minposxz)
	local nvals_random = minetest.get_perlin_map(np_random, chulens):get2dMap_flat(minposxz)
	local offset = math.random(5,20)
	if biome_blend == true then
		chulens = {x=sidelen+2*offset, y=sidelen+2*offset, z=sidelen+2*offset}
		minposxz = {x=x0-offset, y=z0-offset }
		nvals_temp = minetest.get_perlin_map(np_temp, chulens):get2dMap(minposxz)
		nvals_humid = minetest.get_perlin_map(np_humid, chulens):get2dMap(minposxz)
		nvals_random = minetest.get_perlin_map(np_random, chulens):get2dMap(minposxz)
	end

	local nixz = 1
	for z = z0, z1 do
		for x = x0, x1 do -- for each column do
			local n_temp = nvals_temp[nixz] -- select biome
			local n_humid = nvals_humid[nixz]
			local n_ran = nvals_random[nixz]

			local biome = false

			if biome_blend ~= true then
				biome = lottmapgen_biomes(biome, n_temp, n_humid, n_ran, LOTET, LOHUT, LORAN, HITET, HIHUT, HIRAN)
			end

			local sandy = mapgen_params.water_level + math.random(1, 3) -- sandline
			local sandmin = mapgen_params.water_level - math.random(15, 20) -- lowest sand
			local open = true -- open to sky?
			local solid = true -- solid node above?
			local water = false -- water node above?
			local surfy = y1 + 80 -- y of last surface detected
			local get_biome_data = biome_blend
			for y = y1, y0, -1 do -- working down each column for each node do
				local vi = area:index(x, y, z)
				local nodid = data[vi]
				if nodid == c_air then
					solid = false
				else
					if get_biome_data then
						local offsetpos = {x = (x-x0) + offset + math.random(-offset, offset) + 1, z = (z - z0) + offset + math.random(-offset, offset) + 1}
						n_temp = nvals_temp[offsetpos.z][offsetpos.x] -- select biome
						n_humid = nvals_humid[offsetpos.z][offsetpos.x]
						n_ran = nvals_random[offsetpos.z][offsetpos.x]
						biome = lottmapgen_biomes(biome, n_temp, n_humid, n_ran, LOTET, LOHUT, LORAN, HITET, HIHUT, HIRAN)
					end

					if nodid == c_stone -- if stone
					or nodid == c_stonecopper
					or nodid == c_stoneiron
					or nodid == c_stonecoal then
						local fimadep = math.floor(6 - y / 512) + math.random(0, 1)
						local viuu = area:index(x, y - 2, z)
						local nodiduu = data[viuu]
						local via = area:index(x, y + 1, z)
						local nodida = data[via]

						if biome == 4 or biome == 12 then
							data[vi] = c_desertstone
						elseif biome == 8 then
							data[vi] = c_morstone
						elseif biome == 11 then
							if math.random(3) == 1 then
								data[vi] = c_stoneiron
							end
						end
						if not solid then -- if surface
							surfy = y
							if nodiduu ~= c_air and nodiduu ~= c_water and fimadep >= 1 then -- if supported by 2 stone nodes
								if nodida == c_river_water or data[area:index(x + 1, y, z)] == c_river_water
								or data[area:index(x, y, z + 1)] == c_river_water or data[area:index(x - 1, y, z)] == c_river_water
								or data[area:index(x, y, z - 1)] == c_river_water then
									if biome == 8 then
										data[vi] = c_morstone
									else
										data[vi] = c_sand
									end
								elseif y < sandmin then -- below the sand
									-- Can't really see a reason for potentially changing ores to stone. Do nothing.
									-- data[vi] = c_stone
								elseif y <= sandy then -- sand
									if biome ~= 8 then
										local elevation = y - mapgen_params.water_level
										data[vi] = c_sand
										if open and water and elevation == -1 and biome > 4 and math.random(PAPCHA) == 2 then -- papyrus
											lottmapgen_papyrus(x, (mapgen_params.water_level+1), z, area, data)
											data[via] = c_dirt
										elseif math.abs(n_temp) < 0.05 then
											if elevation == -1 then -- clay
												data[vi] = c_clay
											elseif elevation == -5 then -- salt
												data[vi] = c_salt
											elseif elevation == -20 then -- pearl
												data[vi] = c_pearl
											end
										end
										if open and elevation > math.random(2, 3) and math.random(DUGCHA) == 2 and biome ~= 7 then -- dune grass
											data[via] = c_dryshrub
										end
									end
								else -- above sandline
									if biome == 1 then
										if math.random(121) == 2 then
											data[vi] = c_ice
										elseif math.random(25) == 2 then
											data[vi] = c_frozenstone
										else
											data[vi] = c_angsnowblock
										end
									elseif biome == 2 then
										data[vi] = c_dirtsnow
									elseif biome == 3 then
										data[vi] = c_dirtsnow
									elseif biome == 4 then
										data[vi] = c_dungrass
									elseif biome == 5 then
										data[vi] = c_gondorgrass
									elseif biome == 6 then
										data[vi] = c_ithilgrass
									elseif biome == 7 then
										data[vi] = c_loriengrass
									elseif biome == 8 then
										data[vi] = c_morstone
									elseif biome == 9 then
										data[vi] = c_fangorngrass
									elseif biome == 10 then
										data[vi] = c_mirkwoodgrass
									elseif biome == 11 then
										data[vi] = c_ironhillgrass
									elseif biome == 12 then
										data[vi] = c_rohangrass
									elseif biome == 13 then
										data[vi] = c_shiregrass
									end
									if open then -- if open to sky then flora
										local y = surfy + 1
										if biome == 1 then
											if math.random(PLANT3) == 2 then
												data[via] = c_dryshrub
											elseif math.random(TREE10) == 2 then
												lottmapgen_beechtree(x, y, z, area, data)
											elseif math.random(TREE7) == 3 then
												lottmapgen_pinetree(x, y, z, area, data)
											elseif math.random(TREE8) == 4 then
												lottmapgen_firtree(x, y, z, area, data)
											elseif math.random(PLANT6) == 2 then
												data[via] = c_seregon
											elseif math.random(PLANT13) == 13 then
												data[vi] = c_angfort
											end
										elseif biome == 2 then
											data[via] = c_snowblock
										elseif biome == 3 then
											if math.random(PLANT3) == 2 then
												data[via] = c_dryshrub
											elseif math.random(TREE10) == 2 then
												lottmapgen_beechtree(x, y, z, area, data)
											elseif math.random(TREE4) == 3 then
												lottmapgen_pinetree(x, y, z, area, data)
											elseif math.random(TREE3) == 4 then
												lottmapgen_firtree(x, y, z, area, data)
											end
										elseif biome == 4 then
											if math.random(TREE5) == 2 then
												lottmapgen_defaulttree(x, y, z, area, data)
											elseif math.random(TREE7) == 3 then
												lottmapgen_appletree(x, y, z, area, data)
											elseif math.random (PLANT3) == 4 then
												lottmapgen_grass(data, via)
											end
										elseif biome == 5 then
											if math.random(TREE7) == 2 then
												lottmapgen_defaulttree(x, y, z, area, data)
											elseif math.random(TREE8) == 6 then
												lottmapgen_aldertree(x, y, z, area, data)
											elseif math.random(TREE9) == 3 then
												lottmapgen_appletree(x, y, z, area, data)
											elseif math.random(TREE8) == 4 then
												lottmapgen_plumtree(x, y, z, area, data)
											elseif math.random(TREE10) == 9 then
												lottmapgen_elmtree(x, y, z, area, data)
											elseif math.random(PLANT13) == 10 then
												lottmapgen_whitetree(x, y, z, area, data)
											elseif math.random(PLANT3) == 5 then
												lottmapgen_grass(data, via)
											elseif math.random(PLANT8) == 7 then
												lottmapgen_farmingplants(data, via)
											elseif math.random(PLANT13) == 8 then
												lottmapgen_farmingrareplants(data, via)
											elseif math.random(PLANT6) == 2 then
												data[via] = c_mallos
											elseif math.random(PLANT13) == 13 then
												data[vi] = c_gonfort
											end
										elseif biome == 6 then
											if math.random(TREE3) == 2 then
												lottmapgen_defaulttree(x, y, z, area, data)
											elseif math.random(TREE6) == 6 then
												lottmapgen_lebethrontree(x, y, z, area, data)
											elseif math.random(TREE3) == 3 then
												lottmapgen_appletree(x, y, z, area, data)
											elseif math.random(TREE5) == 10 then
												lottmapgen_culumaldatree(x, y, z, area, data)
											elseif math.random(TREE5) == 4 then
												lottmapgen_plumtree(x, y, z, area, data)
											elseif math.random(TREE9) == 9 then
												lottmapgen_elmtree(x, y, z, area, data)
											elseif math.random(PLANT8) == 7 then
												lottmapgen_farmingplants(data, via)
											elseif math.random(PLANT13) == 8 then
												data[via] = c_melon
											elseif math.random(PLANT5) == 11 then
												lottmapgen_ithildinplants(data, via)
											end
										elseif biome == 7 then
											if math.random(TREE3) == 2 then
												lottmapgen_mallornsmalltree(x, y, z, area, data)
											elseif math.random(TREE2) == 2 then
												lottmapgen_young_mallorn(x, y, z, area, data)
											elseif math.random(PLANT1) == 2 then
												lottmapgen_lorien_grass(data, via)
											elseif math.random(TREE5) == 3 then
												lottmapgen_mallorntree(x, y, z, area, data)
											elseif math.random(PLANT4) == 11 then
												lottmapgen_lorienplants(data, via)
											elseif math.random(PLANT13) == 13 then
												if math.random(1, 2) == 1 then
													data[vi] = c_malltre
												else
													data[vi] = c_lorhous
												end
											end
										elseif biome == 8 then
											if math.random(TREE10) == 2 then
												lottmapgen_burnedtree(x, y, z, area, data)
											elseif math.random(PLANT4) == 2 then
												data[via] = c_bomordor
											elseif math.random(PLANT13) == 13 then
												data[vi] = c_orcfort
											end
										elseif biome == 9 then
											if math.random(TREE3) == 2 then
												lottmapgen_defaulttree(x, y, z, area, data)
											elseif math.random(TREE4) == 6 then
												lottmapgen_rowantree(x, y, z, area, data)
											elseif math.random(TREE4) == 3 then
												lottmapgen_appletree(x, y, z, area, data)
											elseif math.random(TREE5) == 10 then
												lottmapgen_birchtree(x, y, z, area, data)
											elseif math.random(TREE5) == 4 then
												lottmapgen_plumtree(x, y, z, area, data)
											elseif math.random(TREE7) == 9 then
												lottmapgen_elmtree(x, y, z, area, data)
											elseif math.random(TREE6) == 11 then
												lottmapgen_oaktree(x, y, z, area, data)
											elseif math.random(PLANT4) == 7 then
												lottmapgen_farmingplants(data, via)
											elseif math.random(PLANT9) == 8 then
												data[via] = c_melon
											end
										elseif biome == 10 then
											if math.random(TREE2) == 2 then
												lottmapgen_mirktree(x, y, z, area, data)
											elseif math.random(TREE2) == 3 then
												lottmapgen_jungletree2(x, y, z, area, data)
											elseif math.random(PLANT13) == 13 then
												data[vi] = c_mirktre
											end
										elseif biome == 11 then
											if math.random(TREE10) == 2 then
												lottmapgen_beechtree(x, y, z, area, data)
											elseif math.random(TREE4) == 3 then
												lottmapgen_pinetree(x, y, z, area, data)
											elseif math.random(TREE6) == 4 then
												lottmapgen_firtree(x, y, z, area, data)
											end
										elseif biome == 12 then
											if math.random(TREE7) == 2 then
												lottmapgen_defaulttree(x, y, z, area, data)
											elseif math.random(TREE7) == 3 then
												lottmapgen_appletree(x, y, z, area, data)
											elseif math.random(TREE8) == 4 then
												lottmapgen_plumtree(x, y, z, area, data)
											elseif math.random(TREE10) == 9 then
												lottmapgen_elmtree(x, y, z, area, data)
											elseif math.random(PLANT2) == 5 then
												lottmapgen_grass(data, via)
											elseif math.random(PLANT8) == 6 then
												lottmapgen_farmingplants(data, via)
											elseif math.random(PLANT13) == 7 then
												data[via] = c_melon
											elseif math.random(PLANT6) == 2 then
												data[via] = c_pilinehtar
											elseif math.random(PLANT13) == 13 then
												data[vi] = c_rohfort
											end
										elseif biome == 13 then
											if math.random(TREE7) == 2 then
												lottmapgen_defaulttree(x, y, z, area, data)
											elseif math.random(TREE7) == 3 then
												lottmapgen_appletree(x, y, z, area, data)
											elseif math.random(TREE7) == 4 then
												lottmapgen_plumtree(x, y, z, area, data)
											elseif math.random(TREE7) == 9 then
												lottmapgen_oaktree(x, y, z, area, data)
											elseif math.random(PLANT7) == 7 then
												lottmapgen_farmingplants(data, via)
											elseif math.random(PLANT9) == 8 then
												data[via] = c_melon
											elseif math.random(PLANT13) == 13 then
												data[vi] = c_hobhole
											end
										end
									end
								end
							end
						else -- underground
							if nodiduu ~= c_air and nodiduu ~= c_water and surfy - y + 1 <= fimadep then
								if y <= sandy and y >= sandmin then
									if biome ~= 8 then
										data[vi] = c_sand
									end
								end
							end
						end
						open = false
						solid = true
						get_biome_data = biome_blend
					elseif nodid == c_water or nodid == c_river_water then
						if biome == 8 then
							if nodid == c_river_water then
								data[vi] = c_morrivwat
							else
								data[vi] = c_morwat
							end
						elseif n_temp < ICETET and y >= mapgen_params.water_level - math.floor((ICETET - n_temp) * 10) then --ice
							data[vi] = c_ice
						end
						solid = false
						water = true
						get_biome_data = biome_blend
					end
				end
			end
			nixz = nixz + 1
		end
	end
	vm:set_data(data)
	vm:set_lighting({day=0, night=0})
	vm:calc_lighting()
	vm:write_to_map(data)
	local chugent = math.ceil((os.clock() - t1) * 1000)
end)
end  -- use_register_biome

dofile(minetest.get_modpath("lottmapgen").."/schematics.lua")
dofile(minetest.get_modpath("lottmapgen").."/deco.lua")
dofile(minetest.get_modpath("lottmapgen").."/chests.lua")

if use_register_biome then
	--
	-- No biome uses default:dirt_with_grass, consider registering all biomes with that to indicate surface.
	--
	local mb_t = {
		-- -2.5, 2.5, 7.5, 12.5,              -- for ice depth
		-- 15, 25, 35, 45, 55, 65, 75, 85, 95, 105 -- for micro biomes
		20, 40, 55, 60, 80, 100 -- for micro biomes
	}
	-- local mb_h = { 5, 15, 25, 35, 45, 55, 65, 75, 85, 95, 105 }
	local mb_h = { 20, 40, 50, 60, 80, 100 }
	local biome_to_mb = {}
	local mb_biome_tab = {
		["angmar"] = { temp = 10, humid = 10,
			top = "default:dirt_with_snow",
			dust = "default:snow",
			water_top = "default:ice",
		},
		["snowplains"] = { temp = 20, humid = 50,
			top = "default:dirt_with_snow",
			dust = "default:snow",
			water_top = "default:ice",
		},
		["trollshaws"] = { temp = 10, humid = 90,
			top = "default:dirt_with_snow",
			dust = "default:snow",
			water_top = "default:ice",
		},

		["mordor"] = { temp = 50, humid = 30,
			top = "lottmapgen:mordor_stone",
			filler = "lottmapgen:mordor_stone",
			stone = "lottmapgen:mordor_stone",
			sand = "lottmapgen:mordor_stone",
			water_top = "lottmapgen:blacksource",
			water = "lottmapgen:blacksource",
			river = "lottmapgen:black_river_source"
		},
		["shire"] = { temp = 40, humid = 50,
			top = "lottmapgen:shire_grass"
		},
		["rohan"] = { temp = 50, humid = 50,
			top = "lottmapgen:rohan_grass",
			stone = "default:desert_stone"
		},
		["gondor"] = { temp = 60, humid = 50,
			top = "lottmapgen:gondor_grass"
		},
		["ithilien"] = { temp = 50, humid = 90,
			top = "lottmapgen:ithilien_grass"
		},

		["lorien"] = { temp = 90, humid = 30,
			top = "lottmapgen:lorien_grass"
		},
		["dunland"] = { temp = 80, humid = 60,
			top = "lottmapgen:dunland_grass",
			stone = "default:desert_stone"
		},
		["ironhills"] = { temp = 90, humid = 60,
			top = "lottmapgen:ironhill_grass"
		},
		["mirkwood"] = { temp = 100, humid = 60,
			top = "lottmapgen:mirkwood_grass"
		},
		["fangorn"] = { temp = 90, humid = 100,
			top = "lottmapgen:fangorn_grass"
		},
	}

	for biome_name, data in pairs(mb_biome_tab) do
		-- local dust, top, filler, stone, sand = {}, "default:grass", "default:dirt", "default:stone", "default:sand"
		-- local water_top, water, river, water_depth = "default:water_source", "default:water_source", "default:river_water_source", 1
		local t = data.temp
		local h = data.humid
		local mb_name = biome_name.."_t"..t.."_h"..h
		local mb_name_top, mb_name_sand, mb_name_bottom = mb_name.."_top", mb_name.."_sand", mb_name.."_bottom"

		-- if data.dust then dust = data.dust end
		-- if data.top then top = data.top end
		-- if data.filler then filler = data.filler end
		-- if data.stone then stone = data.stone end
		-- if data.sand then sand = data.sand end
		-- if data.water_top then water_top = data.water_top end
		-- if data.water then water = data.water end
		-- if data.river then river = data.river end

		local dust = not data.dust and nil or data.dust
		local top = not data.top and "default:grass" or data.top
		local filler = not data.filler and "default:dirt" or data.filler
		local stone = not data.stone and "default:stone" or data.stone
		local sand = not data.sand and "default:sand" or data.sand
		local water_top = not data.water_top and "default:water_source" or data.water_top
		local water_depth = not data.water_depth and 1 or data.water_depth
		local water = not data.water and "default:water_source" or data.water
		local river = not data.river and "default:river_water_source" or data.river

			if not biome_to_mb[biome_name] then
				biome_to_mb[biome_name] = { mb_name_top, mb_name_sand, mb_name_bottom }
				-- biome_to_mb[biome_name][1] = mb_name
			else
				biome_to_mb[biome_name][#biome_to_mb[biome_name] + 1] = mb_name_top
				biome_to_mb[biome_name][#biome_to_mb[biome_name] + 1] = mb_name_sand
				biome_to_mb[biome_name][#biome_to_mb[biome_name] + 1] = mb_name_bottom
			end

			-- Top layer
			minetest.register_biome({
				name = mb_name_top,
				node_dust = dust,
				node_top = top,
				depth_top = 1,
				node_filler = filler,
				depth_filler = 1,
				node_stone = stone,
				node_water_top = water_top,
				depth_water_top = water_depth,
				node_water = water,
				node_river_water = river,
				y_max = 31000,
				y_min = wl+4,
				heat_point = t,
				humidity_point = h,
			})

			-- Sand layer : wl +3, wl - 20
			minetest.register_biome({
				name = mb_name_sand,
				node_dust = dust,
				node_top = sand,
				depth_top = 1,
				node_filler = sand,
				depth_filler = 1,
				node_stone = stone,
				node_water_top = water_top,
				depth_water_top = water_depth,
				node_water = water,
				node_river_water = river,
				y_max = wl+3,
				y_min = wl-20,
				heat_point = t,
				humidity_point = h,
			})

			-- Bottom layer
			minetest.register_biome({
				name = mb_name_bottom,
				node_dust = dust,
				node_top = top,
				depth_top = 1,
				node_filler = filler,
				depth_filler = 1,
				node_stone = stone,
				node_water_top = water_top,
				depth_water_top = water_depth,
				node_water = water,
				node_river_water = river,
				y_min = wl-32,
				y_max = wl-21,
				heat_point = t,
				humidity_point = h,
			})

		-- clay:  wl - 1
		minetest.register_biome({
			name = "clay_"..h,
			node_top = "default:clay",
			depth_top = 1,
			node_stone = stone,
			node_water_top = water_top,
			depth_water_top = water_depth,
			node_water = water,
			node_river_water = river,
			y_min = wl-1,
			y_max = wl-1,
			heat_point = 50,
			humidity_point = h,
		})

		-- salt:  wl - 5
		minetest.register_biome({
			name = "salt_"..h,
			node_top = "lottores:mineral_salt",
			depth_top = 1,
			node_stone = stone,
			node_water_top = water_top,
			depth_water_top = water_depth,
			node_water = water,
			node_river_water = river,
			y_min = wl-5,
			y_max = wl-5,
			heat_point = 50,
			humidity_point = h,
		})

		-- pearl: wl - 20
		minetest.register_biome({
			name = "pearl_"..h,
			node_top = "lottores:mineral_pearl",
			depth_top = 1,
			node_stone = stone,
			node_water_top = water_top,
			depth_water_top = water_depth,
			node_water = water,
			node_river_water = river,
			y_min = wl-20,
			y_max = wl-20,
			heat_point = 50,
			humidity_point = h,
		})

	end  -- humid

end
