--!strict
-- Caster lower-third ([[Caster & Commentary]], [[Screen - Match HUD]] → Bottom). Picks a line for an event from
-- Config/CasterLines, never repeating one of the last 5 used for that event, and fills {tokens}.
--   Caster.Pick(event, intensity, tokens) → (speaker, text) or nil
--   Caster.Show(parent, event, intensity, tokens, zIndex?) → shows the lower-third for ~3.5 s

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Theme = require(ReplicatedStorage.Shared.Config.Theme)
local CasterLines = require(ReplicatedStorage.Shared.Config.CasterLines)
local Components = require(script.Parent.Components)
local New = require(script.Parent.New)

local Caster = {}

local SPEAKERS = {
	Hector = { Name = "\"Hype\" Hector", Icon = "🎙", Color = Theme.Colors.Warning },
	Data = { Name = "Dr. Data", Icon = "📊", Color = Theme.Colors.Accent },
}
local HOLD = 3.5

local recent: { [string]: { number } } = {}
local current: Frame? = nil

function Caster.Pick(event: string, intensity: number?, tokens: { [string]: any }?): (string?, string?)
	local pool = CasterLines[event]
	if not pool then
		return nil, nil
	end
	local want = intensity or 1
	local used = recent[event] or {}
	recent[event] = used
	local options = {}
	for i, line in pool do
		if (line.Min or 1) <= want and not table.find(used, i) then
			table.insert(options, i)
		end
	end
	if #options == 0 then
		table.clear(used)
		for i, line in pool do
			if (line.Min or 1) <= want then
				table.insert(options, i)
			end
		end
	end
	if #options == 0 then
		return nil, nil
	end
	-- Prefer a line made for this intensity (finals get their own lines).
	local best = {}
	for _, i in options do
		if (pool[i].Min or 1) == want then
			table.insert(best, i)
		end
	end
	local pick = if #best > 0 and math.random() < 0.6 then best[math.random(1, #best)] else options[math.random(1, #options)]
	table.insert(used, pick)
	if #used > 5 then
		table.remove(used, 1)
	end
	local text = string.gsub(pool[pick].Text, "{(%w+)}", function(key)
		local v = tokens and tokens[key]
		return if v ~= nil then tostring(v) else "{" .. key .. "}"
	end)
	return pool[pick].Speaker, text
end

function Caster.Hide()
	if current then
		current:Destroy()
		current = nil
	end
end

function Caster.Show(parent: Instance, event: string, intensity: number?, tokens: { [string]: any }?, zIndex: number?)
	local speaker, text = Caster.Pick(event, intensity, tokens)
	if not speaker or not text then
		return
	end
	local who = SPEAKERS[speaker] or SPEAKERS.Hector
	local z = zIndex or 40
	if current then
		current:Destroy()
	end
	local bar = New("Frame", {
		Name = "Caster",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -Theme.Space.XXXL - 40),
		Size = UDim2.fromOffset(640, 72),
		BackgroundColor3 = Theme.Colors.Bg,
		BackgroundTransparency = 0.1,
		ZIndex = z,
		Parent = parent,
	})
	current = bar
	Components.Corner(bar, Theme.Radius.M)
	Components.Stroke(bar, who.Color)
	New("TextLabel", { BackgroundColor3 = who.Color, Size = UDim2.fromOffset(72, 72), Text = who.Icon, TextSize = 34, ZIndex = z + 1, Parent = bar }, { New("UICorner", { CornerRadius = UDim.new(0, Theme.Radius.M) }) })
	New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(84, 6), Size = UDim2.new(1, -96, 0, 20), FontFace = Theme.Fonts.Bold, TextSize = Theme.Type.Caption, TextColor3 = who.Color, TextXAlignment = Enum.TextXAlignment.Left, Text = who.Name, ZIndex = z + 1, Parent = bar })
	New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(84, 26), Size = UDim2.new(1, -96, 0, 40), FontFace = Theme.Fonts.Body, TextSize = Theme.Type.Body, TextColor3 = Theme.Colors.Text, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Text = text, ZIndex = z + 1, Parent = bar })
	local scale = New("UIScale", { Scale = 0.8, Parent = bar })
	TweenService:Create(scale, TweenInfo.new(Theme.Tween.Open, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	task.delay(HOLD, function()
		if bar.Parent then
			bar:Destroy()
		end
		if current == bar then
			current = nil
		end
	end)
end

return Caster
