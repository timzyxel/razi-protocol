local prototype_identity = {}

local function raw(type_name, name)
	return data.raw[type_name] and data.raw[type_name][name]
end

local function set_name(prototype, name)
	if prototype then
		prototype.localised_name = {"", name}
	end
end

local function set_description(prototype, description)
	if prototype then
		prototype.localised_description = {"", description}
	end
end

local function set_recipe_identity(recipe_name, name, description)
	local prototype = raw("recipe", recipe_name)
	set_name(prototype, name)
	set_description(prototype, description)
end

local function set_item_identity(item_name, name, description)
	set_name(raw("item", item_name), name)
	set_description(raw("item", item_name), description)
end

local function set_entity_identity(entity_type, entity_name, name, description)
	set_name(raw(entity_type, entity_name), name)
	set_description(raw(entity_type, entity_name), description)
end

local function set_technology_description(technology_name, description)
	set_description(raw("technology", technology_name), description)
end

local function set_energy_source_limit(entity, key, value)
	if entity and entity.energy_source then
		entity.energy_source[key] = value
	end
end

local function polish_solar()
	set_recipe_identity(
		"muluna-silicon-solar-panel",
		"Silicon Solar Panel",
		"A Muluna-style solar panel route that swaps copper-heavy electronics for silicon cells and aluminum. Same panel, different supply chain."
	)

	local tiny_solar = raw("solar-panel", "tiny-solar-panel")
	if tiny_solar then
		tiny_solar.production = "7.5kW"
		tiny_solar.max_health = math.max(tiny_solar.max_health or 0, 30)
		set_name(tiny_solar, "Compact Solar Panel")
		set_description(tiny_solar, "A fragile one-tile panel. Terrible per item, excellent when Ribbonia-style compact layouts matter more than raw efficiency.")
	end

	set_item_identity(
		"tiny-solar-panel",
		"Compact Solar Panel",
		"A small, fragile solar panel for tight builds, artificial trees, and tiny satellite work."
	)

	set_recipe_identity(
		"tiny-solar-panel",
		"Press Compact Solar Panels",
		"Ribbonia can press one normal panel into several compact panels. You gain placement flexibility, not free power."
	)
end

local function polish_accumulators()
	local big_accumulator = raw("accumulator", "big-accumulator")
	if big_accumulator then
		-- Make this a grid reserve, not just another accumulator sprite.
		set_entity_identity(
			"accumulator",
			"big-accumulator",
			"Moshine Grid Reserve",
			"Very high storage with deliberately slower charge and discharge. Best for smoothing AI-grid demand spikes, not combat burst power."
		)
		set_energy_source_limit(big_accumulator, "buffer_capacity", "40MJ")
		set_energy_source_limit(big_accumulator, "input_flow_limit", "1.5MW")
		set_energy_source_limit(big_accumulator, "output_flow_limit", "1.5MW")
	end

	set_item_identity(
		"big-accumulator",
		"Moshine Grid Reserve",
		"Stores a lot, moves power slowly. Treat it like a flywheel for Moshine data infrastructure."
	)
	set_recipe_identity(
		"big-accumulator",
		"Moshine Grid Reserve",
		"Uses Moshine magnetics to build a high-capacity, low-throughput accumulator."
	)
	set_technology_description(
		"electric-energy-big-accumulators",
		"Unlocks Moshine grid reserves: oversized accumulators for stabilizing data-center power instead of replacing fast accumulators everywhere."
	)
end

local function polish_inserters()
	local long_stack = raw("inserter", "long-stack-inserter")
	if long_stack then
		long_stack.rotation_speed = long_stack.rotation_speed and long_stack.rotation_speed * 0.95
		long_stack.extension_speed = long_stack.extension_speed and long_stack.extension_speed * 1.20
		set_description(long_stack, "Moshine's long stack inserter favors reach and extension speed over clean rotation. Great for awkward data-center spacing.")
	end

	set_item_identity(
		"long-stack-inserter",
		"Moshine Long Stack Inserter",
		"A long-reach stack inserter tuned for Moshine layouts."
	)
	set_recipe_identity(
		"long-stack-inserter",
		"Moshine Long Stack Inserter",
		"Builds the normal long stack inserter line with Moshine data-processing components."
	)

	local rubia_bulk = raw("inserter", "rubia-long-bulk-inserter")
	if rubia_bulk then
		rubia_bulk.energy_per_movement = "8kJ"
		rubia_bulk.energy_per_rotation = "8kJ"
		rubia_bulk.allow_custom_vectors = true
		set_name(rubia_bulk, "Rubia Wind-Handled Bulk Inserter")
		set_description(rubia_bulk, "A wind-safe long bulk inserter. Slightly hungry, but it behaves better inside Rubia's awful weather.")
	end

	local rubia_stack = raw("inserter", "rubia-long-stack-inserter")
	if rubia_stack then
		rubia_stack.energy_per_movement = "12kJ"
		rubia_stack.energy_per_rotation = "12kJ"
		rubia_stack.allow_custom_vectors = true
		set_name(rubia_stack, "Rubia Wind-Handled Stack Inserter")
		set_description(rubia_stack, "A Rubia-specific stack inserter built around wind correction and hostile-surface logistics, not just raw throughput.")
	end

	set_item_identity("rubia-long-bulk-inserter", "Rubia Wind-Handled Bulk Inserter", "A long bulk inserter reinforced for Rubia's wind.")
	set_item_identity("rubia-long-stack-inserter", "Rubia Wind-Handled Stack Inserter", "A stack inserter variant reinforced for Rubia's wind.")
	set_recipe_identity("rubia-long-bulk-inserter", "Rubia Wind-Handled Bulk Inserter", "Builds a wind-safe Rubia long bulk inserter.")
	set_recipe_identity("rubia-long-stack-inserter", "Rubia Wind-Handled Stack Inserter", "Builds a wind-safe Rubia long stack inserter.")
end

local function polish_cubium_dream_logistics()
	local dream_recipes = {
		["express-transport-belt-dream"] = "Dream-Fed Express Belt",
		["express-underground-belt-dream"] = "Dream-Fed Express Underground Belt",
		["express-splitter-dream"] = "Dream-Fed Express Splitter",
		["turbo-transport-belt-dream"] = "Inverted Dream Turbo Belt",
		["turbo-underground-belt-dream"] = "Inverted Dream Turbo Underground Belt",
		["turbo-splitter-dream"] = "Inverted Dream Turbo Splitter"
	}

	for recipe_name, name in pairs(dream_recipes) do
		local recipe = raw("recipe", recipe_name)
		if recipe then
			recipe.energy_required = math.max(recipe.energy_required or 1, 4)
			recipe.allow_quality = true
			set_name(recipe, name)
			set_description(recipe, "A Cubium conversion route. The belt is standard, but the supply chain loops through dreams and returns the cube shell.")
		end
	end

	set_technology_description(
		"express-transport-belt-dream",
		"Unlocks Cubium dream-fed express logistics. This is a weird material-conversion path, not a new faster belt tier."
	)
	set_technology_description(
		"turbo-transport-belt-dream",
		"Unlocks inverted-dream turbo logistics for late Cubium builds. Powerful, expensive, and deliberately cube-loop dependent."
	)
end

local function polish_ribbonia_lane_splitters()
	set_technology_description(
		"ribbonia-tech-lane-splitter",
		"Unlocks Ribbonia lane splitters. They are not another belt speed tier; they are compact routing tools for splitting one lane at a time."
	)

	for recipe_name, recipe in pairs(data.raw.recipe or {}) do
		if recipe_name:find("lane%-splitter$") then
			set_description(recipe, "Ribbonia compresses a normal splitter into lane-control hardware. Use it when layout control matters more than raw speed.")
		end
	end
end

local function polish_panglia_overclocks()
	for _, prototype_type in ipairs({"inserter", "transport-belt", "splitter"}) do
		for prototype_name, prototype in pairs(data.raw[prototype_type] or {}) do
			if prototype_name:find("_panglia_fast_version$") then
				set_description(prototype, "Panglia overclocks this while it sits on the planet's hidden root network. It drops back to the normal machine anywhere else.")
			end
		end
	end
end

function prototype_identity.data_final_fixes()
	polish_solar()
	polish_accumulators()
	polish_inserters()
	polish_cubium_dream_logistics()
	polish_ribbonia_lane_splitters()
	polish_panglia_overclocks()
end

return prototype_identity
