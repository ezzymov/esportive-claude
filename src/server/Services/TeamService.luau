--!strict
-- TeamService ([[Team Identity]], [[Screen - Team Creator]]): Team/SetIdentity(name, tag, role, primary, tee) RF.
-- Server-side validation + TextService filtering (never on the client). Renaming is free before Stage 2; after that
-- it needs the 39 R$ product (not in M1, so it's refused). The Founder role can change until the card is minted.
-- Success: Flags.TeamCreated, bedsheet banner drops on the garage door, Founder tee recolors.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

local Lib = script.Parent.Parent.Lib
local Remote = require(Lib.Remote)
local Log = require(Lib.Log)
local Bus = require(Lib.Bus)
local DataService = require(script.Parent.DataService)
local PlotService = require(script.Parent.PlotService)
local Team = require(ReplicatedStorage.Shared.Config.Team)
local Roles = require(ReplicatedStorage.Shared.Config.Roles)
local Names = require(ReplicatedStorage.Shared.Config.Names)

local TeamService = { Tier = 3 }

local function trim(s: string): string
	return (string.gsub(string.gsub(s, "^%s+", ""), "%s+$", ""))
end

-- Returns the filtered text, or nil if Roblox changed it (hashed) or the filter failed.
local function filter(player: Player, text: string): string?
	local ok, result = pcall(function()
		local filtered = TextService:FilterStringAsync(text, player.UserId, Enum.TextFilterContext.PublicChat)
		return filtered:GetNonChatStringForBroadcastAsync()
	end)
	if not ok then
		Log.Event("text_filter_failed", player, tostring(result))
		return nil
	end
	if result ~= text then
		return nil
	end
	local lower = string.lower(text)
	for _, bad in Names.Blocked do
		if string.find(lower, bad, 1, true) then
			return nil
		end
	end
	return result
end

local function setIdentity(player: Player, rawName: string, rawTag: string, role: string, primary: number, tee: number): (boolean, any)
	local data = DataService:GetProfile(player)
	if not data then
		return false, "NotLoaded"
	end
	if data.Flags.TeamCreated and data.Stage >= 2 then
		return false, "RenameLocked" -- 39 R$ name change product arrives with MonetizationService
	end

	local name = trim(rawName)
	local tag = string.upper(trim(rawTag))
	if utf8.len(name) == nil or (utf8.len(name) :: number) < 1 or (utf8.len(name) :: number) > Team.NameMax then
		return false, "BadName"
	end
	if #tag < Team.TagMin or #tag > Team.TagMax or string.find(tag, "[^A-Z0-9]") then
		return false, "BadTag"
	end

	local cleanName = filter(player, name)
	local cleanTag = cleanName and filter(player, tag)
	if not cleanName or not cleanTag then
		return false, "Filtered"
	end

	local first = not data.Flags.TeamCreated
	DataService:Update(player, "Team", function(t)
		t.Name = cleanName
		t.Tag = cleanTag
		t.Colors = { Primary = primary, Tee = tee }
		t.Jersey = { Garment = "OwnTee" }
		if data.FounderUuid == "" then
			t.FounderRole = role -- fixed once the Founder card exists
		end
		return t
	end)
	DataService:Update(player, "Flags.TeamCreated", function()
		return true
	end)
	PlotService:RefreshBanner(player, true)
	PlotService:ApplyTee(player)
	Bus.Fire(player, "TeamCreated", { First = first })
	DataService:SaveNow(player, "TeamCreated")
	Log.Info("Team", `{player.Name} → {cleanName} [{cleanTag}] {role}`)
	return true, { Name = cleanName, Tag = cleanTag }
end

function TeamService:Init()
	Remote.Function("Team", "SetIdentity", {
		Args = {
			Remote.T.String(80),
			Remote.T.String(16),
			Remote.T.OneOf(Roles.Order),
			Remote.T.Int(1, #Team.Colors),
			Remote.T.Int(1, #Team.Colors),
		},
		Rate = { Count = 1, Per = 2 }, -- filtering is a web call
	}, setIdentity)
end

return TeamService
