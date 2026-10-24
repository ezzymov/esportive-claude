--!strict
-- Intro cutscene shot list + captions ([[Intro Cutscene]] → Shot list). Times in seconds from the start.
-- Captions live here so they're easy to translate. Speaker nil = on-screen text, no voice.

return {
	Length = 52,
	SkipAfter = 5, -- skip button appears after this many seconds
	SkipHold = 1, -- hold to skip, so it isn't hit by accident

	Shots = {
		{ Id = 1, At = 0, Name = "Skyline" },
		{ Id = 2, At = 5, Name = "VanBridge" },
		{ Id = 3, At = 10, Name = "VanInside" },
		{ Id = 4, At = 17, Name = "Phone" },
		{ Id = 5, At = 22, Name = "Street" },
		{ Id = 6, At = 28, Name = "StepOut" },
		{ Id = 7, At = 33, Name = "DoorUp" },
		{ Id = 8, At = 38, Name = "Unbox" },
		{ Id = 9, At = 43, Name = "Pullback" },
		{ Id = 10, At = 48, Name = "Title" },
	},

	Captions = {
		{ At = 11, Until = 14, Speaker = "Hector (radio)", Text = "...and that's how you win a world title!" },
		{ At = 14, Until = 17, Speaker = "Dr. Data (radio)", Text = "Every one of those players started somewhere smaller than this." },
		{ At = 28.5, Until = 33, Speaker = "Aunt Dee", Text = "Rent's free while you get started. Make me proud. Or at least make some money." },
	},

	Phone = { Rank = "Peak rank: Silver II", Text = "we're here 🙂", From = "Aunt Dee" },
	Title = { Logo = "eSports Tycoon", Tagline = "Every team starts with one player. You." },
}
