set_prerequisites_if_exists("planet-discovery-aquilo", {"vibrant-discovery"})
set_prerequisites_if_exists("planet-discovery-secretas", {"planet-discovery-vesta"})
set_prerequisites_if_exists("planet-discovery-frozeta", {"planet-discovery-secretas"})

set_technology_unit_ingredients_if_exists("planet-discovery-secretas", build_integrated_science_ingredients({
	primary_science_packs = {
		"automation-science-pack",
		"logistic-science-pack",
		"production-science-pack",
		"utility-science-pack",
		"space-science-pack",
		"electromagnetic-science-pack",
		"cryogenic-science-pack",
		"aerospace-science-pack"
	},
	extra_science_packs = {
		"pelagos-science-pack"
	}
}))
