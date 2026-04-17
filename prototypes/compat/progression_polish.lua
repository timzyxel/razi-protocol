local progression_polish = {}

local function technology(name)
	return data.raw.technology and data.raw.technology[name]
end

local function recipe(name)
	return data.raw.recipe and data.raw.recipe[name]
end

local function science_pack_exists(name)
	return data.raw.tool and data.raw.tool[name] ~= nil
end

local function technology_exists(name)
	return technology(name) ~= nil
end

local function add_prerequisite(tech, prerequisite)
	if not tech or not technology_exists(prerequisite) then
		return
	end

	tech.prerequisites = tech.prerequisites or {}
	for _, existing in ipairs(tech.prerequisites) do
		if existing == prerequisite then
			return
		end
	end

	table.insert(tech.prerequisites, prerequisite)
end

local function science_ingredients(science_packs)
	local ingredients = {}

	for _, science_pack in ipairs(science_packs) do
		if science_pack_exists(science_pack) then
			table.insert(ingredients, {science_pack, 1})
		end
	end

	return ingredients
end

local function ingredient_name(ingredient)
	return ingredient and (ingredient.name or ingredient[1])
end

local function remove_recipe_ingredient(recipe_name, ingredient_to_remove)
	local target_recipe = recipe(recipe_name)
	if not target_recipe or not target_recipe.ingredients then
		return
	end

	for index = #target_recipe.ingredients, 1, -1 do
		if ingredient_name(target_recipe.ingredients[index]) == ingredient_to_remove then
			table.remove(target_recipe.ingredients, index)
		end
	end
end

local function restore_muluna_green_plastic_gate()
	local green_plastic = technology("muluna-nanofoamed-polymers")
	if not green_plastic then
		return
	end

	-- Muluna wants this after a few planetary breakthroughs. Keep the list
	-- readable, but do not let it become a same-planet early unlock.
	green_plastic.enabled = true
	green_plastic.visible_when_disabled = nil
	green_plastic.prerequisites = {"space-science-pack"}
	add_prerequisite(green_plastic, "planet-discovery-muluna")
	add_prerequisite(green_plastic, "metallurgic-science-pack")
	add_prerequisite(green_plastic, "electromagnetic-science-pack")
	add_prerequisite(green_plastic, "agricultural-science-pack")

	local ingredients = science_ingredients({
		"automation-science-pack",
		"logistic-science-pack",
		"chemical-science-pack",
		"production-science-pack",
		"utility-science-pack",
		"space-science-pack",
		"metallurgic-science-pack",
		"electromagnetic-science-pack",
		"agricultural-science-pack"
	})

	if #ingredients > 0 then
		green_plastic.research_trigger = nil
		green_plastic.unit = {
			count = 1000,
			time = 60,
			ingredients = ingredients
		}
	end

	green_plastic.localised_description = {
		"",
		"Unlocks Muluna's nanofoamed polymer chain after combining Vulcanus, Fulgora, Gleba, and Muluna material science."
	}
end

local function clarify_long_stack_inserters()
	local moshine_long_stack = technology("long-stack-inserter")
	if moshine_long_stack then
		moshine_long_stack.localised_description = {
			"",
			"Unlocks the normal long stack inserter line through Moshine data processing."
		}
	end

	local rubia_long_stack = technology("rubia-long-stack-inserter")
	if not rubia_long_stack then
		return
	end

	rubia_long_stack.localised_name = {"", "Rubia Wind-Handled Stack Inserter"}
	rubia_long_stack.localised_description = {
		"",
		"Unlocks Rubia's wind-safe long stack inserter variant. It is a planet-specific upgrade, not a duplicate of Moshine's normal long stack inserter."
	}
	add_prerequisite(rubia_long_stack, "long-stack-inserter")
end

local function move_singularity_card_out_of_early_deep_space()
	-- The black deep-space card is the Nexus/Promethium bridge. K2 singularity
	-- cards should stay in the transceiver finale, not sneak into this earlier
	-- recipe and make the tree look like the ending starts too soon.
	remove_recipe_ingredient("deep-space-tech-card", "kr-singularity-tech-card")
end

local function loosen_matter_research_data_surface()
	local matter_data = recipe("kr-matter-research-data")
	if not matter_data then
		return
	end

	-- K2SO 1.6 moved this onto Aquilo pressure only. Razi moves Aquilo deep
	-- into Beetlejuice, so the data recipe needs to follow the broader K2SO
	-- matter route instead of hard-locking one planet.
	matter_data.surface_conditions = nil
end

local function spawn_definition_key(definition)
	return (definition.type or "asteroid") .. ":" .. tostring(definition.asteroid)
end

local function append_spawn_definitions(target, definitions)
	if not target or not definitions then
		return
	end

	target.asteroid_spawn_definitions = target.asteroid_spawn_definitions or {}

	local existing = {}
	for _, definition in ipairs(target.asteroid_spawn_definitions) do
		existing[spawn_definition_key(definition)] = true
	end

	for _, definition in ipairs(definitions) do
		local key = spawn_definition_key(definition)
		if not existing[key] then
			table.insert(target.asteroid_spawn_definitions, table.deepcopy(definition))
			existing[key] = true
		end
	end
end

local function add_imersite_to_far_space()
	if not mods["Imersite-Asteroids"] then
		return
	end

	local ok, imersite_asteroids = pcall(require, "__Imersite-Asteroids__.imersite-asteroids-spawn-definitions")
	if not ok then
		return
	end

	local inner_belt = imersite_asteroids.spawn_definitions(imersite_asteroids.inner_imersite_asteroid_belt)
	local outer_belt = imersite_asteroids.spawn_definitions(imersite_asteroids.outer_imersite_asteroid_belt)
	local local_orbit = imersite_asteroids.spawn_definitions(imersite_asteroids.inner_planet_asteroids, 0.4)

	-- The source mod only seeds Fulgora and a few vanilla lanes. In this pack,
	-- Imersite belongs in the ugly late-space routes too.
	for _, connection_name in ipairs({
		"sye-beetlejuice-cubium",
		"cubium-vesta",
		"vesta-aquilo",
		"sye-beetlejuice-tenebris",
		"tenebris-crucible-orbit",
		"crucible-orbit-vesta",
		"aquilo-solar-system-edge"
	}) do
		append_spawn_definitions(data.raw["space-connection"] and data.raw["space-connection"][connection_name], inner_belt)
	end

	for _, connection_name in ipairs({
		"solar-system-edge-nexus",
		"solar-system-edge-black-hole-approach",
		"black-hole-approach-black-hole",
		"nexus-oort-cloud",
		"oort-cloud-sol"
	}) do
		append_spawn_definitions(data.raw["space-connection"] and data.raw["space-connection"][connection_name], outer_belt)
	end

	for _, planet_name in ipairs({"cubium", "vesta", "aquilo", "nexus"}) do
		append_spawn_definitions(data.raw.planet and data.raw.planet[planet_name], local_orbit)
	end

	for _, location_name in ipairs({"solar-system-edge", "oort-cloud", "black-hole-approach"}) do
		append_spawn_definitions(data.raw["space-location"] and data.raw["space-location"][location_name], local_orbit)
	end
end

function progression_polish.data_final_fixes()
	restore_muluna_green_plastic_gate()
	clarify_long_stack_inserters()
	move_singularity_card_out_of_early_deep_space()
	loosen_matter_research_data_surface()
	add_imersite_to_far_space()
end

return progression_polish
