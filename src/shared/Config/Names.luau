--!strict
-- Name pools for [[Player Generator]] and the team auto-name ([[Team Identity]]). M1 subset; full bank in [[Gamertag Bank]].
-- All names are original. Tags are checked against Blocked before use.

return {
	-- Gamer tags: short nonsense, digit swaps, odd capitals, everyday words.
	TagWords = {
		"plonk", "kettle", "zekko", "tobsen", "mirrv", "fennic", "brisk", "quokk", "vantt", "lumo",
		"skiff", "rook1e", "dabbo", "nimz", "pebbl", "krait", "oxo", "juno", "tazz", "wyld",
		"gumbo", "frisk", "milo", "spud", "zaph", "corvo", "bramb", "taffy", "noodl", "yeti",
		"sprig", "kobi", "flint", "mochi", "razz", "bolt", "cinder", "pip", "torque", "vexi",
	},
	TagStyles = { "plain", "digit", "caps", "suffix" },
	Suffixes = { "x", "o", "z", "y", "er", "ie" },

	FirstNames = {
		"Alex", "Sam", "Jordan", "Mika", "Leo", "Nia", "Omar", "Ines", "Kenji", "Aroha",
		"Mateo", "Zara", "Yusuf", "Lena", "Ravi", "Chloe", "Tomas", "Ama", "Sora", "Ivan",
	},
	Countries = {
		{ "Portugal", "Lisbon" }, { "Brazil", "Recife" }, { "Canada", "Halifax" }, { "Japan", "Osaka" },
		{ "Nigeria", "Lagos" }, { "Poland", "Gdansk" }, { "Australia", "Perth" }, { "Mexico", "Puebla" },
		{ "India", "Pune" }, { "Sweden", "Malmo" }, { "Korea", "Busan" }, { "Egypt", "Alexandria" },
	},
	Quirks = {
		"never takes off their headset", "eats cereal at 3am", "streams every night", "has a lucky keyboard",
		"talks to their mouse", "speedruns old games", "counts every flick out loud", "naps between rounds",
	},

	-- Team auto-name: [Adjective] [Noun]. Ideas bank from [[Team Identity]].
	TeamAdjectives = { "Neon", "Crimson", "Pixel", "Static", "Apex", "Glitch", "Turbo", "Phantom", "Frost", "Overclock", "Garage", "Rusty" },
	TeamNouns = { "Wolves", "Vortex", "Reapers", "Drift", "Cartel", "Syndicate", "Tigers", "Lag", "Byte", "Kings", "Squad", "Gremlins" },
	DefaultTeamName = "Garage Squad",

	-- Bad-word and real-pro-tag block list (exact + contains). Keep lowercase.
	Blocked = { "donk", "s1mple", "zywoo", "faker", "niko" },
}
