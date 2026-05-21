local cerys_cards = {}

local standard_tech_card_weight = 1000

local function add_unique_input(lab, input_name)
	if not (lab and lab.inputs and input_name) then
		return
	end

	for _, existing in ipairs(lab.inputs) do
		if existing == input_name then
			return
		end
	end

	table.insert(lab.inputs, input_name)
end

local function should_patch_cerys_card(name)
	if not name or not name:find("cerys", 1, true) then
		return false
	end

	return
		name:find("tech%-card") or
		name:find("tech_card", 1, true) or
		name:find("science%-pack")
end

local function patch_item_proto(proto)
	if not proto or not should_patch_cerys_card(proto.name) then
		return
	end

	proto.weight = standard_tech_card_weight

	-- Respect the field only when the source mod defines it.
	if proto.send_to_orbit_mode ~= nil then
		proto.send_to_orbit_mode = "automated"
	end
end

function cerys_cards.data_final_fixes()
	local cerys_science_inputs = {}

	for _, tool in pairs(data.raw.tool or {}) do
		patch_item_proto(tool)
		if should_patch_cerys_card(tool.name) then
			table.insert(cerys_science_inputs, tool.name)
		end
	end

	for _, item in pairs(data.raw.item or {}) do
		patch_item_proto(item)
		if should_patch_cerys_card(item.name) then
			table.insert(cerys_science_inputs, item.name)
		end
	end

	for _, lab in pairs(data.raw.lab or {}) do
		for _, input_name in ipairs(cerys_science_inputs) do
			add_unique_input(lab, input_name)
		end
	end
end

return cerys_cards
