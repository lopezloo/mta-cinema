function table.find(table, find)
	if not table or not find then return false end
	for k, v in pairs(table) do
		if v == find then
			return k
		end
	end
	return false
end