--!strict
-- Logging. Log.Event = suspicious/notable events ([[Analytics & Metrics]] / [[Data Persistence]]); AnalyticsService
-- sets Log.Sink so these also reach Roblox analytics. Log.Info = plain Output lines.

local Log = {}

Log.Sink = nil :: ((name: string, player: Player?, details: string?) -> ())?

function Log.Event(name: string, player: Player?, details: string?)
	local who = if player then `{player.Name}({player.UserId})` else "server"
	warn(`[Analytics] {name} {who} {details or ""}`)
	local sink = Log.Sink
	if sink then
		task.spawn(sink, name, player, details)
	end
end

function Log.Info(tag: string, msg: string)
	print(`[{tag}] {msg}`)
end

return Log
