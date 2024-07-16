function formatGold(value)
	local number = tostring(value)

	number = string.reverse(number)
	number = string.gsub(number, "(%d%d%d)", "%1,")
	number = string.reverse(number)

	if string.sub(number, 1, 1) == "," then
		number = string.sub(number, 2)
	end

	return number
end


function calculateCombatValues(percent)
	local values = {}

	if percent == 0 then
		values.color = "#AE0F0F"
		values.tooltip = "0% (immune)"
	elseif percent < 100 then
		values.color = "#E4C00A"
		values.tooltip = percent .. "% (strong)"
	elseif percent == 100 then
		values.color = "#FFFFFF"
		values.tooltip = "100% (neutral)"
	else
		values.color = "#18CE18"
		values.tooltip = percent .. "% (weak)"
	end

	if percent > 100 then
		values.margin = 15 + (125 - percent) * 0.28
	else
		values.margin = 22 + (100 - percent) * 0.21
	end

	if values.margin < 0 then
		values.margin = 0
	elseif values.margin > 65 then
		values.margin = 65
	end

	return values
end

function formatSaleData(data)
	local s, sell, b, buy = {}, {}, {}, {}

	for i = 0, #data do
		local value = data[i]

		if value then
			if value.salePrice > 0 then
				if s[value.name] and value.name == "Rashid" then
					s[value.name].various = true
				end

				if not s[value.name] then
					local formated = {
						various = false,
						price = value.salePrice,
						location = value.location
					}

					s[value.name] = formated
				end
			end

			if value.buyPrice > 0 then
				if b[value.name] and value.name == "Rashid" then
					b[value.name].various = true
				end

				if not b[value.name] then
					local formated = {
						various = false,
						price = value.buyPrice,
						location = value.location
					}

					b[value.name] = formated
				end
			end
		end
	end

	for name, value in pairs(s) do
		if value.various then
			table.insert(sell, string.format("%s gp, %s\nResidence: %s", formatGold(value.price), name, "Various Locations"))
		else
			table.insert(sell, string.format("%s gp, %s\nResidence: %s", formatGold(value.price), name, value.location))
		end
	end

	for name, value in pairs(b) do
		if value.various then
			table.insert(buy, string.format("%s gp, %s\nResidence: %s", formatGold(value.price), name, "Various Locations"))
		else
			table.insert(buy, string.format("%s gp, %s\nResidence: %s", formatGold(value.price), name, value.location))
		end
	end

	return sell, buy
end

function compareItems(item1, item2)
	local marketData1 = item1:getMarketData()
	local marketData2 = item2:getMarketData()

	return marketData1.name:lower() < marketData2.name:lower()
end

function hasHandedFilter(categoryId)
	local ids = {
		17,
		18,
		19,
		20,
		21,
		1000
	}

	if table.contains(ids, categoryId) then
		return true
	end

	return false
end

function hasClassificationFilter(categoryId)
	local ids = {
		1,
		24,
		7,
		15,
		17,
		18,
		19,
		20,
		21,
		1000
	}

	if table.contains(ids, categoryId) then
		return true
	end

	return false
end
