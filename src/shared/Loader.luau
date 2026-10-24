--!strict
-- Boots every ModuleScript in a folder: all Init (sync, in Tier order), then all Start (each in its own thread).
-- A module is a table with optional Tier (number, lower boots first), Init(self) and Start(self).

local Loader = {}

function Loader.Load(folder: Instance): { [string]: any }
	local modules = {}
	for _, child in folder:GetChildren() do
		if child:IsA("ModuleScript") then
			table.insert(modules, { Name = child.Name, Module = (require :: any)(child) })
		end
	end
	table.sort(modules, function(a, b)
		local ta, tb = a.Module.Tier or 99, b.Module.Tier or 99
		if ta ~= tb then
			return ta < tb
		end
		return a.Name < b.Name
	end)

	for _, entry in modules do
		if entry.Module.Init then
			local ok, err = pcall(entry.Module.Init, entry.Module)
			if not ok then
				error(`[Loader] {entry.Name}:Init failed: {err}`)
			end
		end
	end
	for _, entry in modules do
		if entry.Module.Start then
			task.spawn(entry.Module.Start, entry.Module)
		end
	end

	local byName = {}
	for _, entry in modules do
		byName[entry.Name] = entry.Module
	end
	return byName
end

return Loader
