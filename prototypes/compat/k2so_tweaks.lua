local compat = {}

local xy_k2so_placeholder_connections = { -- Cuz fuckin hell xy loves to complain.
	{
		name = "nauvis-moshine",
		from = "nauvis",
		to = "moshine",
		length = 25000
	},
	{
		name = "vulcanus-moshine",
		from = "vulcanus",
		to = "moshine",
		length = 10000
	}
}

local function xy_k2so_enhancements_active()
	return mods["xy-k2so-enhancements-nulls-fork"] or mods["xy-k2so-enhancements"]
end

local function patch_xy_k2so_globals()
	if xy_k2so_enhancements_active() and not sounds then
		sounds = require("__base__.prototypes.entity.sounds")
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

local function add_xy_k2so_placeholder_connections()
	if not xy_k2so_enhancements_active() then
		return
	end

	local asteroid_util = require("__space-age__.prototypes.planet.asteroid-spawn-definitions")

	for _, connection in pairs(xy_k2so_placeholder_connections) do
		if not route_exists(connection.name) and location_exists(connection.from) and location_exists(connection.to) then
			data:extend({
				{
					type = "space-connection",
					name = connection.name,
					subgroup = "planet-connections",
					from = connection.from,
					to = connection.to,
					length = connection.length,
					asteroid_spawn_definitions = asteroid_util.spawn_definitions(asteroid_util.nauvis_fulgora)
				}
			})
		end
	end
end

local function remove_xy_k2so_placeholder_connections()
	if not data.raw["space-connection"] then
		return
	end

	for _, connection in pairs(xy_k2so_placeholder_connections) do
		data.raw["space-connection"][connection.name] = nil
	end

	data.raw["space-connection"]["moshine-maraxsis"] = nil
end

local function item_exists(name)
	return
		(data.raw.item and data.raw.item[name]) or
		(data.raw.ammo and data.raw.ammo[name]) or
		(data.raw.tool and data.raw.tool[name])
end

local function entry_name(entry)
	return entry and (entry.name or entry[1])
end

local function set_entry_name(entry, name)
	if entry.name then
		entry.name = name
	else
		entry[1] = name
	end
end

local function replace_recipe_ingredient(recipe_name, from, to)
	local recipe = data.raw.recipe and data.raw.recipe[recipe_name]
	if not recipe then
		return
	end

	local function replace_in_ingredients(ingredients)
		for _, ingredient in pairs(ingredients or {}) do
			if entry_name(ingredient) == from then
				set_entry_name(ingredient, to)
			end
		end
	end

	replace_in_ingredients(recipe.ingredients)
	if recipe.normal then
		replace_in_ingredients(recipe.normal.ingredients)
	end
	if recipe.expensive then
		replace_in_ingredients(recipe.expensive.ingredients)
	end
end

local function replace_missing_magazine_ingredients_globally(from, to)
	if item_exists(from) or not item_exists(to) then
		return
	end

	for recipe_name, _ in pairs(data.raw.recipe or {}) do
		replace_recipe_ingredient(recipe_name, from, to)
	end
end

local function fix_corrosive_magazine_without_k2_rifles()
	if item_exists("kr-rifle-magazine") or not item_exists("firearm-magazine") then
		return
	end

	-- nulls-k2so-tweaks upgrades Pelagos' corrosive ammo to use K2 rifle
	-- magazines. K2SO only creates those when realistic weapons are enabled.
	replace_recipe_ingredient("corrosive-firearm-magazine", "kr-rifle-magazine", "firearm-magazine")
end

function compat.data()
	patch_xy_k2so_globals()
	add_xy_k2so_placeholder_connections()
end

function compat.data_updates()
	patch_xy_k2so_globals()
	remove_xy_k2so_placeholder_connections()
end

function compat.data_final_fixes()
	fix_corrosive_magazine_without_k2_rifles()
	replace_missing_magazine_ingredients_globally("kr-rifle-magazine", "firearm-magazine")
end

return compat
