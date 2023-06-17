function DRAW_EXPAND_SKILL_TOOLTIP(tooltipframe, yPos, ExpandSkillTooltip)

	local gBox = GET_CHILD(tooltipframe, 'skill_desc_expand', 'ui::CGroupBox')
	gBox:RemoveChild('expand_skill_tooltip')

	if string.find(ExpandSkillTooltip, '/') ~= nil then
		local desclist = StringSplit(ExpandSkillTooltip, '/')

		for i = 1, #desclist do
			gBox:RemoveChild('expand_skill_tooltip_' .. tostring(i))
			if i >= 2 then
				yPos = yPos + 260
			end

			local tooltip_equip_property_CSet = gBox:CreateOrGetControlSet('expand_skill_tooltip', 'expand_skill_tooltip_' .. tostring(i), 500, yPos);
			local property_gbox = GET_CHILD(tooltip_equip_property_CSet, 'property_gbox', 'ui::CGroupBox');

			tooltip_equip_property_CSet:Resize(tooltip_equip_property_CSet:GetWidth(), tooltip_equip_property_CSet:GetHeight() + property_gbox:GetHeight() + property_gbox:GetY())

			local name_text = GET_CHILD_RECURSIVELY(tooltip_equip_property_CSet, "name");
			local name = TryGetProp(GetClass('ExpandSkillTooltip', desclist[i]), 'Name', 'None')

			local icon = TryGetProp(GetClass('ExpandSkillTooltip', desclist[i]), 'Icon', 'None')
			if icon ~= 'None' then
				name = '{img icon_' .. icon .. ' 28 28}' .. ' ' .. name
			end

			name_text:SetTextByKey('rtxt', name)

			local desc_text = GET_CHILD_RECURSIVELY(tooltip_equip_property_CSet, "desc");
			local desc = TryGetProp(GetClass('ExpandSkillTooltip', desclist[i]), 'Desc', 'None')

			desc_text:SetTextByKey('xtxt', desc)

			gBox:Resize(gBox:GetWidth(), gBox:GetHeight() + tooltip_equip_property_CSet:GetHeight())
			
			if i >= 2 then
				tooltipframe:Resize(tooltipframe:GetWidth(), 900)
			end
		end

	else

		for i = 1, 3 do
			gBox:RemoveChild('expand_skill_tooltip_' .. tostring(i))
		end

		local tooltip_equip_property_CSet = gBox:CreateOrGetControlSet('expand_skill_tooltip', 'expand_skill_tooltip', 500, yPos);
		local property_gbox = GET_CHILD(tooltip_equip_property_CSet, 'property_gbox', 'ui::CGroupBox');

		tooltip_equip_property_CSet:Resize(tooltip_equip_property_CSet:GetWidth(), tooltip_equip_property_CSet:GetHeight() + property_gbox:GetHeight() + property_gbox:GetY())

		local name_text = GET_CHILD_RECURSIVELY(tooltip_equip_property_CSet, "name");
		local name = TryGetProp(GetClass('ExpandSkillTooltip', ExpandSkillTooltip), 'Name', 'None')

		local icon = TryGetProp(GetClass('ExpandSkillTooltip', ExpandSkillTooltip), 'Icon', 'None')
		if icon ~= 'None' then
			name = '{img icon_' .. icon .. ' 28 28}' .. ' ' .. name
		end

		name_text:SetTextByKey('rtxt', name)

		local desc_text = GET_CHILD_RECURSIVELY(tooltip_equip_property_CSet, "desc");
		local desc = TryGetProp(GetClass('ExpandSkillTooltip', ExpandSkillTooltip), 'Desc', 'None')

		desc_text:SetTextByKey('xtxt', desc)

		gBox:Resize(gBox:GetWidth(), gBox:GetHeight() + tooltip_equip_property_CSet:GetHeight())

	end

end

