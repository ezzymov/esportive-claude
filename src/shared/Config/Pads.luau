--!strict
-- Buy pads ([[Plot & HQ]]): { Id, Room, Group, Price, Requires, Unlock, Builds }. Prices from [[Stage 1 - Garage Squad]].
-- Group = which physical pad shows the entry (one pad per Group per plot, placed at the World.Garage anchor of the same name).
-- Unlock = named profile condition (PlotService.Unlocks) on top of Requires. A pad shows only when both pass.
-- Builds.Desk = station slot the pad adds; Builds.Accessory = gear given to the Founder card.
-- Station tier upgrades (M0 test pad) move to the Stage 2 Tech Shop so they don't break Stage 1 pacing.

export type Pad = {
	Id: string,
	Room: string,
	Group: string,
	Price: number,
	Requires: { string },
	Unlock: string?,
	Builds: { Desk: number?, Accessory: string? },
	Name: string,
	Stage: number,
}

local list: { Pad } = {
	{
		Id = "Founder_Mouse",
		Room = "Garage",
		Group = "Pad_Mouse",
		Price = 150,
		Requires = {},
		Unlock = "PickupWon",
		Builds = { Accessory = "ClikkBasic" },
		Name = "Better Mouse",
		Stage = 1,
	},
	{
		Id = "Desk2",
		Room = "Garage",
		Group = "Pad_Desk2",
		Price = 300,
		Requires = { "Founder_Mouse" },
		Builds = { Desk = 2 },
		Name = "2nd Desk",
		Stage = 1,
	},
	{
		Id = "Desk3",
		Room = "Garage",
		Group = "Pad_Desk3",
		Price = 500,
		Requires = { "Desk2" },
		Unlock = "Hired",
		Builds = { Desk = 3 },
		Name = "3rd Desk",
		Stage = 1,
	},
	-- Stage 2 · Café annex: rented café PCs for the 5-slot roster ([[HQ Era Visual Guide]] → Café Corner).
	-- Price: first pad of a new era ≈ 3× the last one ([[Plot & HQ]] → Rules & numbers).
	{
		Id = "Desk4",
		Room = "Cafe",
		Group = "Pad_Desk4",
		Price = 1_500,
		Requires = { "Desk3" },
		Unlock = "Stage2",
		Builds = { Desk = 4 },
		Name = "Café PC 4",
		Stage = 2,
	},
	{
		Id = "Desk5",
		Room = "Cafe",
		Group = "Pad_Desk5",
		Price = 2_000,
		Requires = { "Desk4" },
		Unlock = "Stage2",
		Builds = { Desk = 5 },
		Name = "Café PC 5",
		Stage = 2,
	},
}

local pads: { [string]: Pad } = {}
local order: { string } = {}
for _, pad in list do
	pads[pad.Id] = pad
	table.insert(order, pad.Id)
end

return {
	ById = pads,
	Order = order, -- build order; the next unbought pad in a group is the one shown
	MaxVisible = 3,
}
