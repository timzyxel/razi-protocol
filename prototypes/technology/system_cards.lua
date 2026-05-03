local system_cards = {}

local system_card_subgroup = "system-tech-card"

local function ensure_item_subgroup(name, group, order)
	if data.raw["item-subgroup"] and data.raw["item-subgroup"][name] then
		return
	end

	data:extend({
		{
			type = "item-subgroup",
			name = name,
			group = group,
			order = order
		}
	})
end

local card_definitions = {
	{
		name = "calidus-tech-card",
		localised_name = "Calidus Tech Card",
		tint = {r = 1.0, g = 0.86, b = 0.08},
		order = "s[system]-a[calidus]",
		unlock_technology_candidates = {
			"planet-discovery-castra",
			"planet-discovery-muluna",
			"moon-discovery-cerys"
		},
		ingredients = {
			"automation-science-pack",
			"logistic-science-pack",
			"military-science-pack",
			"chemical-science-pack",
			"production-science-pack",
			"utility-science-pack",
			"space-science-pack",
			"metallurgic-science-pack",
			"electromagnetic-science-pack",
			"agricultural-science-pack",
			"lithium-science-pack",
			"tungsten-science-pack",
			"lunar-science-pack",
			"interstellar-science-pack",
			"advanced-space-science-pack",
			"cerysian-science-pack"
		}
	},
	{
		name = "solaris-tech-card",
		localised_name = "Solaris Tech Card",
		tint = {r = 1.0, g = 0.52, b = 0.18},
		order = "s[system]-b[solaris]",
		unlock_technology_candidates = {
			"planet-discovery-castra"
		},
		ingredients = {
			"battlefield-science-pack",
			"planetaris-compression-science-pack",
			"planetaris-polishing-science-pack",
			"planetaris-bioengineering-science-pack",
			"planetaris-pathological-science-pack",
			"planetaris-refraction-science-pack",
			"electrochemical-science-pack"
		}
	},
	{
		name = "nyxaris-tech-card",
		localised_name = "Nyxaris Tech Card",
		tint = {r = 0.36, g = 0.62, b = 1.0},
		order = "s[system]-c[nyxaris]",
		unlock_technology_candidates = {
			"system-discovery-dea-dia",
			"planet-discovery-dea-dia",
			"planet-discovery-apia-carnova",
			"planet-discovery-moshine",
			"planet-discovery-pelagos"
		},
		ingredients = {
			"aerospace-science-pack",
			"dea-dia-science-pack",
			"insulation-science-pack",
			"thermodynamic-science-pack",
			"nuclear-science-pack",
			"apicultural-science-pack",
			"pelagos-science-pack"
		}
	},
	{
		name = "vibrant-tech-card",
		localised_name = "Vibrant Tech Card",
		tint = {r = 0.82, g = 0.28, b = 1.0},
		order = "s[system]-d[vibrant]",
		unlock_technology_candidates = {
			"planet-discovery-ribbonia",
			"planet-discovery-aquilo",
			"planet-discovery-maraxsis"
		},
		ingredients = {
			"ribbonia-alien-science-pack",
			"biorecycling-science-pack",
			"rubia-biofusion-science-pack",
			"galvanization-science-pack",
			"paracelsin-galvanization-science-pack",
			"hydraulic-science-pack"
		}
	},
	{
		name = "beetlejuice-tech-card",
		localised_name = "Beetlejuice Tech Card",
		tint = {r = 0.22, g = 1.0, b = 0.42},
		order = "s[system]-e[beetlejuice]",
		unlock_technology_candidates = {
			"planet-discovery-cubium",
			"planet-discovery-tenebris"
		},
		ingredients = {
			"bioluminescent-science-pack",
			"cryogenic-science-pack",
			"gas-manipulation-science-pack",
			"planet-crucible-science-pack",
			"golden-science-pack"
		}
	},
	{
		name = "deep-space-tech-card",
		localised_name = "Deep Space Tech Card",
		tint = {r = 0.18, g = 0.18, b = 0.22},
		order = "s[system]-f[deep-space]",
		unlock_technology_candidates = {
			"promethium-882-research"
		},
		fallback_ingredients = {
			"beetlejuice-tech-card",
			"promethium-science-pack"
		},
		ingredients = {
			"beetlejuice-tech-card",
			"promethium-science-pack",
			"promethium-882-science-pack"
		}
	}
}

local function science_pack_exists(name)
	return
		(data.raw.tool and data.raw.tool[name]) or
		(data.raw.item and data.raw.item[name])
end

local function build_recipe_ingredients(science_packs)
	local ingredients = {}

	for _, science_pack in ipairs(science_packs or {}) do
		if science_pack_exists(science_pack) then
			table.insert(ingredients, {type = "item", name = science_pack, amount = 1})
		end
	end

	return ingredients
end

local function build_card_ingredients(card)
	local ingredients = build_recipe_ingredients(card.ingredients)

	if #ingredients == 0 then
		ingredients = build_recipe_ingredients(card.fallback_ingredients)
	end

	return ingredients
end

local function add_recipe_unlock(technology_name, recipe_name)
	local technology = data.raw.technology and data.raw.technology[technology_name]
	if not technology then
		return
	end

	technology.effects = technology.effects or {}
	for _, effect in ipairs(technology.effects) do
		if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
			return
		end
	end

	table.insert(technology.effects, {
		type = "unlock-recipe",
		recipe = recipe_name
	})
end

local function find_first_existing_technology(candidates)
	for _, technology_name in ipairs(candidates or {}) do
		if data.raw.technology and data.raw.technology[technology_name] then
			return technology_name
		end
	end

	return nil
end

function system_cards.data_final_fixes()
	ensure_item_subgroup(system_card_subgroup, "intermediate-products", "z[science]-a[system-tech-card]")

	for _, card in ipairs(card_definitions) do
		local ingredients = build_card_ingredients(card)
		local unlock_technology = find_first_existing_technology(card.unlock_technology_candidates)

		if #ingredients > 0 then
			data:extend({
				{
					type = "tool",
					name = card.name,
					localised_name = {"", card.localised_name},
					localised_description = {"item-description.science-pack"},
					icons = {
						{
							icon = "__base__/graphics/icons/space-science-pack.png",
							icon_size = 64,
							tint = card.tint
						}
					},
					subgroup = system_card_subgroup,
					order = card.order,
					stack_size = 200,
					durability = 1,
					durability_description_key = "description.science-pack-remaining-amount-key",
					factoriopedia_durability_description_key = "description.factoriopedia-science-pack-remaining-amount-key",
					durability_description_value = "description.science-pack-remaining-amount-value"
				},
				{
					type = "recipe",
					name = card.name,
					localised_name = {"", card.localised_name},
					enabled = false,
					category = "crafting",
					energy_required = 10,
					ingredients = ingredients,
					results = {
						{type = "item", name = card.name, amount = 1}
					},
					subgroup = system_card_subgroup,
					order = card.order
				}
			})

			if unlock_technology then
				add_recipe_unlock(unlock_technology, card.name)
			end
		end
	end
end

return system_cards
