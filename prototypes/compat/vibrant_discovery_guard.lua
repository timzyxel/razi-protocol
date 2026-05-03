local vibrant_discovery_guard = {}

function vibrant_discovery_guard.data_final_fixes()
	set_technology_unit_ingredients_if_exists("planet-discovery-paracelsin", {
		{"automation-science-pack", 1},
		{"logistic-science-pack", 1},
		{"utility-science-pack", 1},
		{"space-science-pack", 1},
		{"electromagnetic-science-pack", 1},
		{"cryogenic-science-pack", 1},
		{"apicultural-science-pack", 1},
		{"pelagos-science-pack", 1}
	})
end

return vibrant_discovery_guard
