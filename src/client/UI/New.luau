--!strict
-- New(className, props, children?) → Instance. Function values for signal names are connected
-- (New("TextButton", { Activated = fn })). Parent is set last so the tree is built before it renders.

local function New(className: string, props: { [string]: any }?, children: { Instance }?): any
	local inst = Instance.new(className)
	local parent = nil
	for key, value in props or {} do
		if key == "Parent" then
			parent = value
		elseif type(value) == "function" and typeof((inst :: any)[key]) == "RBXScriptSignal" then
			(inst :: any)[key]:Connect(value)
		else
			(inst :: any)[key] = value
		end
	end
	for _, child in children or {} do
		child.Parent = inst
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

return New
