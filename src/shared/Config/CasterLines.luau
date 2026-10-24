--!strict
-- Caster lines ([[Caster & Commentary]]): "Hype" Hector (loud play-by-play) and Dr. Data (calm analyst).
-- [event] = { { Speaker, Text, Min? } }. The client picks one for each event the server result contains, skipping the
-- last 5 used per event. Min = lowest intensity the line plays at (1 scrim/pickup · 2 tournament · 3 final).
-- Tokens: {team} {opponent} {player} {score} {map}. Names are server-filtered or generated, never typed text.

export type Line = { Speaker: string, Text: string, Min: number? }

local lines: { [string]: { Line } } = {
	-- Matches ---------------------------------------------------------------------------------------------------
	MatchStart = {
		{ Speaker = "Hector", Text = "Here we go, {team} looking hungry!" },
		{ Speaker = "Data", Text = "{team} against {opponent} on {map}. The numbers say close. The numbers have been wrong before." },
		{ Speaker = "Hector", Text = "Headsets on, snacks down, it's {map} time!" },
		{ Speaker = "Data", Text = "Key stat today: who wins the first duels. Everything else is decoration." },
		{ Speaker = "Hector", Text = "{opponent} said they'd win this in their sleep. Wake UP, {opponent}!" },
		{ Speaker = "Hector", Text = "Lights, cameras, CHAOS! Welcome to {map}!", Min = 2 },
		{ Speaker = "Data", Text = "A final. Everyone says it's just another match. Everyone is lying.", Min = 3 },
	},
	Ace = {
		{ Speaker = "Hector", Text = "FIVE! {player} takes ALL FIVE! That's an ACE!" },
		{ Speaker = "Data", Text = "Five kills, one player, no help required. That's an ace for {player}." },
		{ Speaker = "Hector", Text = "{player} just cleared the server! Someone check their monitor for smoke!" },
		{ Speaker = "Hector", Text = "ACE! ACE! Somebody clip that, I'm shaking!" },
		{ Speaker = "Data", Text = "Statistically rare. Emotionally devastating for {opponent}." },
	},
	Clutch = {
		{ Speaker = "Hector", Text = "1v{n}… {player} is NOT leaving this server without a fight!" },
		{ Speaker = "Data", Text = "Last one standing against {n}, and {player} wins it. That's a clutch." },
		{ Speaker = "Hector", Text = "Ice in the veins! {player} closes out the 1v{n}!" },
		{ Speaker = "Hector", Text = "They left {player} alone. Big mistake. HUGE." },
		{ Speaker = "Data", Text = "Calm hands, slow breathing, {n} opponents down. Textbook." },
	},
	Flawless = {
		{ Speaker = "Hector", Text = "Flawless round for {team}! Not a scratch!" },
		{ Speaker = "Data", Text = "Five alive at the end of the round. {team} made that look easy." },
		{ Speaker = "Hector", Text = "Clean sweep! Somebody tell {opponent} the round started!" },
		{ Speaker = "Data", Text = "Zero deaths. That's what good spacing gets you." },
		{ Speaker = "Hector", Text = "FLAWLESS! {team} didn't even break a sweat!" },
	},
	Momentum = {
		{ Speaker = "Hector", Text = "{team} are on FIRE! {n} rounds in a row!" },
		{ Speaker = "Data", Text = "That's {n} straight for {team}. Momentum is real, and it's on their side." },
		{ Speaker = "Hector", Text = "Can anyone stop {team}?! Asking for {opponent}!" },
		{ Speaker = "Data", Text = "{opponent} needs a timeout. They don't get one. Unfortunate." },
		{ Speaker = "Hector", Text = "The streak keeps rolling! {team} smell blood!" },
	},
	MatchPoint = {
		{ Speaker = "Hector", Text = "MATCH POINT! One round from glory!" },
		{ Speaker = "Data", Text = "Match point at {score}. One round decides a lot of feelings." },
		{ Speaker = "Hector", Text = "This is it! Hands steady, hearts racing!" },
		{ Speaker = "Data", Text = "Match point. Historically, this is when people forget how mice work." },
		{ Speaker = "Hector", Text = "One more! ONE MORE!" },
	},
	Overtime = {
		{ Speaker = "Hector", Text = "OVERTIME! Nobody wants to go home!" },
		{ Speaker = "Data", Text = "Twelve all. We play on. My coffee is not prepared for this." },
		{ Speaker = "Hector", Text = "Extra rounds! Free entertainment! You're welcome!" },
		{ Speaker = "Data", Text = "Overtime. Both teams equally good, or equally tired." },
		{ Speaker = "Hector", Text = "We're going LONGER! Somebody order pizza!" },
	},
	Comeback = {
		{ Speaker = "Hector", Text = "THE COMEBACK! {team} were dead and buried and they CLIMBED OUT!" },
		{ Speaker = "Data", Text = "Down by five or more and still won. File that under 'never give up'." },
		{ Speaker = "Hector", Text = "From the floor to the TOP! What a turnaround from {team}!" },
		{ Speaker = "Data", Text = "Win probability said no. {team} said yes." },
		{ Speaker = "Hector", Text = "Write it in the history books! THE REVERSE SWEEP!" },
	},
	Upset = {
		{ Speaker = "Hector", Text = "Nobody had {team} winning this. NOBODY." },
		{ Speaker = "Data", Text = "{opponent} were the much stronger team on paper. Paper doesn't play matches." },
		{ Speaker = "Hector", Text = "UPSET! UPSET! Bring me a new bracket!" },
		{ Speaker = "Data", Text = "That result will break a lot of predictions. Including mine." },
		{ Speaker = "Hector", Text = "David, meet Goliath. Goliath, meet the floor!" },
	},
	Record = {
		{ Speaker = "Data", Text = "{player} just set a new personal best: {n} kills." },
		{ Speaker = "Hector", Text = "Career high for {player}! {n} kills! Frame it!" },
		{ Speaker = "Data", Text = "New record for {player}. The stat sheet needs a bigger column." },
		{ Speaker = "Hector", Text = "{player} has never played like this! {n} KILLS!" },
		{ Speaker = "Data", Text = "Best game of {player}'s career so far. Noted." },
	},
	Victory = {
		{ Speaker = "Hector", Text = "VICTORY for {team}! {score}!" },
		{ Speaker = "Data", Text = "{team} take it {score}. Well played." },
		{ Speaker = "Hector", Text = "GG! {team} walk away winners!" },
		{ Speaker = "Data", Text = "Final score {score}. The better team today, and the scoreboard agrees." },
		{ Speaker = "Hector", Text = "THAT'S THE GAME! {team}, take a bow!" },
		{ Speaker = "Hector", Text = "CHAMPIONS! {team} lift the trophy!", Min = 3 },
	},
	Defeat = {
		{ Speaker = "Data", Text = "{opponent} take it {score}. {team} will learn from this one." },
		{ Speaker = "Hector", Text = "Tough one for {team}. Shake it off, go again!" },
		{ Speaker = "Data", Text = "Not today for {team}. The replay will be educational." },
		{ Speaker = "Hector", Text = "Heads up, {team}! Legends lose too. Then they come back." },
		{ Speaker = "Data", Text = "{score}. Close enough to hurt, far enough to count." },
	},
	Halftime = {
		{ Speaker = "Data", Text = "Halftime, {score}. Sides swap. So do strategies, hopefully." },
		{ Speaker = "Hector", Text = "Half done! Grab a drink, stretch those wrists!" },
		{ Speaker = "Data", Text = "Halfway. Anything can happen. Mostly the things I predicted." },
		{ Speaker = "Hector", Text = "Switching sides! Same energy, new view!" },
		{ Speaker = "Data", Text = "Twelve rounds in at {score}. Let's see who adjusts." },
	},

	-- Case reveals ----------------------------------------------------------------------------------------------
	CaseCommon = {
		{ Speaker = "Data", Text = "A Common. Every roster needs a solid base." },
		{ Speaker = "Hector", Text = "Grey glow! Hey, the classics never go out of style!" },
		{ Speaker = "Data", Text = "Common. Not flashy. Neither is winning, usually." },
	},
	CaseUncommon = {
		{ Speaker = "Hector", Text = "Green! That's a step up!" },
		{ Speaker = "Data", Text = "Uncommon. A sensible pickup." },
		{ Speaker = "Hector", Text = "Green means GO! Nice pull!" },
	},
	CaseRare = {
		{ Speaker = "Hector", Text = "Ooh, blue glow, that's a nice one." },
		{ Speaker = "Data", Text = "Rare. Your scouts would approve." },
		{ Speaker = "Hector", Text = "BLUE! That's a RARE! Now we're talking!" },
	},
	CaseEpic = {
		{ Speaker = "Hector", Text = "PURPLE! That's an EPIC! My headset just fell off!" },
		{ Speaker = "Data", Text = "Epic. That one changes lineups." },
		{ Speaker = "Hector", Text = "EPIC PULL! Somebody hold my mic!" },
	},
	CaseLegendary = {
		{ Speaker = "Hector", Text = "GOLD! GOLD! A LEGENDARY! I need to sit down!" },
		{ Speaker = "Data", Text = "Legendary. Two percent. I am, briefly, excited." },
		{ Speaker = "Hector", Text = "THAT'S A LEGENDARY! Frame it, print it, tell your grandma!" },
	},
	CaseMythic = {
		{ Speaker = "Hector", Text = "THAT'S A MYTHIC! I'm going to need a minute." },
		{ Speaker = "Data", Text = "Mythic. I have run the numbers. The numbers are speechless." },
		{ Speaker = "Hector", Text = "RED GLOW! MYTHIC! THE SERVER IS SHAKING!" },
	},
}

return lines
