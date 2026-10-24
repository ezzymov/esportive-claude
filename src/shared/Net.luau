--!strict
-- Client-side lookup for Remotes/<Service>/<Action>. The server creates them; the client only waits.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = {}

local TIMEOUT = 30

function Net.Get(service: string, action: string): any
	local root = ReplicatedStorage:WaitForChild("Remotes")
	local folder = root:WaitForChild(service, TIMEOUT)
	assert(folder, `[Net] Remotes/{service} missing`)
	local remote = folder:WaitForChild(action, TIMEOUT)
	assert(remote, `[Net] Remotes/{service}/{action} missing`)
	return remote
end

return Net
