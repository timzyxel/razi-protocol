local compat = {}

local function delete_route(name)
	if data.raw["space-connection"] then
		data.raw["space-connection"][name] = nil
	end
end

local function route_exists(name)
	return data.raw["space-connection"] and data.raw["space-connection"][name]
end

local function location_exists(name)
	return
		(data.raw.planet and data.raw.planet[name]) or
		(data.raw["space-location"] and data.raw["space-location"][name])
end

local function move_terrapalus_to_calidus()
	if not (mods["terrapalus"] and mods["PlanetsLib"]) then
		return
	end

	if data.raw.planet and data.raw.planet.terrapalus then
		PlanetsLib:update({
			{
				type = "planet",
				name = "terrapalus",
				subgroup = "planets",
				is_satellite = false,
				draw_orbit = true,
				orbit = {
					parent = {
						type = "space-location",
						name = "star"
					},
					distance = 18,
					orientation = 0.32,
					sprite = {
						type = "sprite",
						filename = "__razi-protocol__/graphics/orbits/orbit_18.png",
						size = 1475
					}
				}
			}
		})
	end

	delete_route("gleba-terrapalus")

	if not route_exists("sye-calidus-terrapalus") and location_exists("sye-calidus") and location_exists("terrapalus") then
		local asteroid_util = require("__space-age__.prototypes.planet.asteroid-spawn-definitions")

		data:extend({
			{
				type = "space-connection",
				name = "sye-calidus-terrapalus",
				subgroup = "planet-connections",
				from = "sye-calidus",
				to = "terrapalus",
				order = "b[calidus]-t[terrapalus]",
				length = 9000,
				asteroid_spawn_definitions = asteroid_util.spawn_definitions(asteroid_util.nauvis_gleba)
			}
		})
	end
end

function compat.data_updates()
	move_terrapalus_to_calidus()
end

return compat
