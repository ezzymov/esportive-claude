--!strict
-- PadController: your plot's buy pads. The server sets each pad's PadId attribute to the entry it currently shows
-- ("" = hidden/locked); this draws name, price and % progress over it and asks the server to buy it when your
-- character steps on it. The server re-checks everything (distance, unlock, prereqs, cash).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Shared.Net)
local Format = require(ReplicatedStorage.Shared.Format)
local Pads = require(ReplicatedStorage.Shared.Config.Pads)
local Theme = require(ReplicatedStorage.Shared.Config.Theme)
local Components = require(script.Parent.Parent.UI.Components)
local StateController = require(script.Parent.StateController)
local HudController = require(script.Parent.HudController)

local PadController = { Tier = 3 }

local DEBOUNCE = 0.5
local player = Players.LocalPlayer

local function buildBillboard(part: BasePart): (BillboardGui, TextLabel, TextLabel)
	local board = Instance.new("BillboardGui")
	board.Name = "PadLabel"
	board.Adornee = part
	board.Size = UDim2.fromScale(8, 2.6)
	board.StudsOffsetWorldSpace = Vector3.new(0, 3.5, 0)
	board.AlwaysOnTop = true
	board.MaxDistance = 60
	board.ResetOnSpawn = false
	local column = Instance.new("Frame")
	column.BackgroundTransparency = 1
	column.Size = UDim2.fromScale(1, 1)
	local layout = Instance.new("UIListLayout")
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = column
	column.Parent = board
	local name = Components.Label({ Text = "", Font = Theme.Fonts.Heading, Size = Theme.Type.H2, Order = 1 })
	name.Parent = column
	local price = Components.Label({ Text = "", Font = Theme.Fonts.Bold, Size = Theme.Type.Body, Order = 2 })
	price.Parent = column
	board.Parent = player:WaitForChild("PlayerGui")
	return board, name, price
end

local function bindPad(part: BasePart, buyRemote: RemoteFunction)
	local board, nameLabel, priceLabel = buildBillboard(part)

	local function current(): Pads.Pad?
		local id = part:GetAttribute("PadId")
		return if type(id) == "string" and id ~= "" then Pads.ById[id] else nil
	end

	local function refresh()
		local pad = current()
		board.Enabled = pad ~= nil
		if not pad then
			return
		end
		local cash = StateController:Get("Currencies.Cash") or 0
		local affordable = cash >= pad.Price
		nameLabel.Text = pad.Name
		priceLabel.Text = if affordable then Format.Cash(pad.Price) else `{Format.Cash(pad.Price)} ({math.floor(cash / pad.Price * 100)}%)`
		priceLabel.TextColor3 = if affordable then Theme.Colors.Success else Theme.Colors.TextMuted
		part.Color = if affordable then Theme.Colors.Success else Theme.Colors.Panel -- green glow when affordable
	end
	local stops = {
		StateController:Observe("Currencies.Cash", refresh),
		StateController:Observe("HQ.PadsBought", refresh),
	}
	local attr = part:GetAttributeChangedSignal("PadId"):Connect(refresh)
	refresh()

	local busy, last = false, 0
	local touch = part.Touched:Connect(function(hit)
		local character = player.Character
		if busy or not character or not hit:IsDescendantOf(character) or os.clock() - last < DEBOUNCE then
			return
		end
		local pad = current()
		if not pad then
			return
		end
		busy, last = true, os.clock()
		local ok, result = buyRemote:InvokeServer(pad.Id)
		busy = false
		if ok then
			HudController:Toast(`Bought {pad.Name}!`, Theme.Colors.Success)
			HudController:Float(`-{Format.Cash(pad.Price)}`, Theme.Colors.Danger, part)
		elseif type(result) == "table" and result.Need then
			HudController:Toast(`Need {Format.Cash(result.Need)} more`, Theme.Colors.Warning)
		elseif result ~= "Debounce" and result ~= "RateLimited" then
			HudController:Toast(`Can't buy that right now ({tostring(result)})`, Theme.Colors.Danger)
		end
	end)

	return function()
		touch:Disconnect()
		attr:Disconnect()
		for _, stop in stops do
			stop()
		end
		board:Destroy()
	end
end

-- Pads are found by their PadGroup attribute under your plot, so they bind whenever they stream in.
function PadController:Start()
	local buyRemote = Net.Get("Plot", "BuyPad") :: RemoteFunction
	StateController:WaitUntilLoaded()
	local unbind: { [Instance]: () -> () } = {}
	local function consider(inst: Instance)
		if inst:IsA("BasePart") and inst:GetAttribute("PadGroup") and not unbind[inst] then
			if inst:GetAttribute("OwnerUserId") == player.UserId then
				unbind[inst] = bindPad(inst, buyRemote)
			end
		end
	end
	local plots = workspace:WaitForChild("Plots")
	plots.DescendantAdded:Connect(function(inst)
		consider(inst)
		if inst:IsA("BasePart") and inst:GetAttribute("PadGroup") then
			inst:GetAttributeChangedSignal("OwnerUserId"):Connect(function()
				consider(inst)
			end)
		end
	end)
	plots.DescendantRemoving:Connect(function(inst)
		local stop = unbind[inst]
		unbind[inst] = nil
		if stop then
			stop()
		end
	end)
	for _, inst in plots:GetDescendants() do
		consider(inst)
		if inst:IsA("BasePart") and inst:GetAttribute("PadGroup") then
			inst:GetAttributeChangedSignal("OwnerUserId"):Connect(function()
				consider(inst)
			end)
		end
	end
end

return PadController
