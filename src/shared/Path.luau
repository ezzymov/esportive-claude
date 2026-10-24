--!strict
-- Dot paths into nested tables ("Currencies.Cash"). "" is the root. Used by DataService and the client mirror.

local Path = {}

function Path.Split(path: string): { string }
	if path == "" then
		return {}
	end
	return string.split(path, ".")
end

function Path.Get(root: any, path: string): any
	local node = root
	for _, key in Path.Split(path) do
		if type(node) ~= "table" then
			return nil
		end
		node = node[key]
	end
	return node
end

-- Returns the parent table and final key, or nil if a parent is missing. Path must not be "".
function Path.Parent(root: any, path: string): (any, string?)
	local keys = Path.Split(path)
	local node = root
	for i = 1, #keys - 1 do
		node = node[keys[i]]
		if type(node) ~= "table" then
			return nil, nil
		end
	end
	return node, keys[#keys]
end

-- True if `a` equals `b` or one is an ancestor of the other.
function Path.Related(a: string, b: string): boolean
	if a == "" or b == "" or a == b then
		return true
	end
	return string.sub(a, 1, #b + 1) == b .. "." or string.sub(b, 1, #a + 1) == a .. "."
end

return Path
