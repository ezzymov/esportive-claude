--!strict
-- DataService settings. Store names must match [[DataStore Registry]].

return {
	StoreName = "PlayerData",
	KeyPrefix = "Player_",

	-- Studio: ProfileStore already falls back to its mock store when API access is off.
	-- Set true to force the mock even with API access on (nothing persists between Play sessions).
	ForceMockInStudio = false,

	SaveNowCooldown = 10, -- seconds, 1 forced save per profile per window
	MaxGuardBlocks = 3, -- consecutive blocked saves before kick
	CurrencyMargin = 0.05, -- save guard: allowed drift vs logged transactions
	SizeWarnBytes = 1_000_000,
	SizeLimitBytes = 3_500_000,

	Messages = {
		LoadFailed = "Couldn't load your save. Please rejoin. Your progress is safe.",
		OtherServer = "Your save was opened on another server.",
		NewerVersion = "A new update is out, rejoin!",
		Migration = "We're updating your save. Please rejoin in a minute.",
		GuardKick = "Something went wrong with your save. Your last good save is safe. Please rejoin.",
	},
}
