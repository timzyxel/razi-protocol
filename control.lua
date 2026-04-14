local transceiver_gate_technology = "razi-intergalactic-transceiver-signal"
local active_transceiver_name = "kr-activated-intergalactic-transceiver"

local function unlock_transceiver_gate(force)
	if not (force and force.valid) then
		return
	end

	local technology = force.technologies[transceiver_gate_technology]
	if technology and not technology.researched then
		technology.enabled = true
		technology.researched = true
	end
end

local function check_entity(entity)
	if entity and entity.valid and entity.name == active_transceiver_name then
		unlock_transceiver_gate(entity.force)
	end
end

local function check_existing_transceivers()
	if not game then
		return
	end

	for _, surface in pairs(game.surfaces) do
		local entities = surface.find_entities_filtered({
			name = active_transceiver_name,
			limit = 1
		})

		if entities[1] then
			unlock_transceiver_gate(entities[1].force)
		end
	end
end

local function on_entity_built(event)
	check_entity(event.entity or event.destination or event.created_entity)
end

-- K2SO raises a build event when the charged transceiver becomes the active one.
-- The slow scan covers old saves and any weird script ordering.
script.on_init(check_existing_transceivers)
script.on_configuration_changed(check_existing_transceivers)
script.on_nth_tick(600, check_existing_transceivers)
script.on_event({
	defines.events.on_built_entity,
	defines.events.on_robot_built_entity,
	defines.events.on_entity_cloned,
	defines.events.script_raised_built,
	defines.events.script_raised_revive
}, on_entity_built)
