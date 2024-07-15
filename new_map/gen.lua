local mapgen = LuaMap:init()

local function map_init(mapmeta)
	-- creates a terrain noise
	mapgen:add_noise_2D("terrain", {
		np_vals = {
			offset = 0,
			scale = 1,
			spread = {x=784, y=145, z=784},
			seed = LuaMap.generate_seed(),
			octaves = 5,
			persist = 0.63,
			lacunarity = 2.0,
			flags = ""
		},
		ymin = mapmeta.pos1.y,
		ymax = mapmeta.pos2.y,
	})
end


local c_stone = minetest.get_content_id("default:stone")
local c_water = minetest.get_content_id("default:water_source")
local c_sand = minetest.get_content_id("default:sand")


function mapgen:logic(pos, seed, content)
	if pos.y < 0 then -- Water level
		content = c_water
	end
	if pos.y < self.noise_vals.terrain * 100 then
		content = c_stone

	end

	return content
end

function mapgen:postcalc(data, area, vm, minp, maxp, seed)
	biomegen.generate_all(data, area, vm, minp, maxp, seed)
end

local function map_generator(mapmeta)
	local pos1, pos2 = mapmeta.pos1, mapmeta.pos2
	local vm = minetest.get_voxel_manip()
	local emin, emax = vm:read_from_map(pos1, pos2)
	local area = VoxelArea:new{MinEdge = emin, MaxEdge = emax}
	local data = vm:get_data()

	pos1, pos2 = ctf_map.prepare_area(pos1, pos2, data, area)

	mapgen:generate(vm, emin, emax, area, data, pos1, pos2)
	ctf_map.allocate_teams_territory(mapmeta, data, area)


	ctf_map.place_flags(mapmeta, data, area, 3)

	vm:set_data(data)
	vm:write_to_map()
	vm:update_map()
	minetest.debug("new_map: map generated")
end

return {on_placemap = map_generator, init = map_init}