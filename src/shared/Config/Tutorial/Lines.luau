--!strict
-- Tutorial lines by stable id ([[Tutorial Voice Script]]). SoundId stays nil until the line is recorded (caption only).
-- Captions may use {team}; the audio never says names or numbers.

export type Line = { Speaker: string, Text: string, SoundId: string? }

local lines: { [string]: Line } = {
	-- 1 · NameTeam
	TUT_NAMETEAM_1 = { Speaker = "Dee", Text = "Every team needs a name. Make it loud." },
	TUT_NAMETEAM_HINT = { Speaker = "Dee", Text = "I already picked one for you. Keep it or change it." },
	TUT_NAMETEAM_CALL = { Speaker = "Dee", Text = "Kid, it's just a name. Tap the button, you can change it later. Free, even. For a while." },
	TUT_NAMETEAM_DONE = { Speaker = "Dee", Text = "Ooh. I'll paint that on a bedsheet." },
	-- 2 · PowerOn
	TUT_POWERON_1 = { Speaker = "Dee", Text = "Plug it in. Red cable, red port. I'm not a tech." },
	TUT_POWERON_HINT = { Speaker = "Dee", Text = "The cables go in the back of the tower. Match the colors." },
	TUT_POWERON_CALL = { Speaker = "Dee", Text = "Okay, I watched a video. Colors match colors, then you press the big button. That's all I've got." },
	TUT_POWERON_DONE = { Speaker = "Dee", Text = "It turned on! Nobody touch anything." },
	-- 3 · SitDesk
	TUT_SITDESK_1 = { Speaker = "Dee", Text = "Sit down. Apparently sitting makes money now." },
	TUT_SITDESK_HINT = { Speaker = "Dee", Text = "Your chair's the one with the tape on it." },
	TUT_SITDESK_CALL = { Speaker = "Dee", Text = "Kid, the internet pays you to practice on stream. I don't get it either. Go sit at your desk." },
	TUT_SITDESK_DONE = { Speaker = "Dee", Text = "Look at that number go up. Is that legal?" },
	-- 4 · FirstPug
	TUT_FIRSTPUG_1 = { Speaker = "Dee", Text = "Some strangers online need a fifth player. Go help them." },
	TUT_FIRSTPUG_HINT = { Speaker = "Dee", Text = "Hit the Pickup Game button on your screen." },
	TUT_FIRSTPUG_CALL = { Speaker = "Dee", Text = "You came all this way to play games. So play one! The button's right there on your desk screen." },
	HEC_FIRSTWIN = { Speaker = "Hector", Text = "FIRST WIN! From a GARAGE! Somebody write this down!" },
	-- 5 · AimTrainer
	TUT_AIM_1 = { Speaker = "Dee", Text = "That old arcade thing still works? Huh. Try it." },
	TUT_AIM_HINT = { Speaker = "Dee", Text = "The cabinet in the corner. It pays a little, too." },
	TUT_AIM_CALL = { Speaker = "Dee", Text = "Your uncle used to play that cabinet every night. Go see if you're better than him. It shouldn't be hard." },
	TUT_AIM_DONE = { Speaker = "Dee", Text = "Your aim got better. I could tell. Probably." },
	-- 6 · TechFix
	TUT_TECHFIX_1 = { Speaker = "Dee", Text = "Mrs. Park's computer died again. She pays." },
	TUT_TECHFIX_HINT = { Speaker = "Dee", Text = "She left it on the bench by the door." },
	TUT_TECHFIX_CALL = { Speaker = "Dee", Text = "Mrs. Park keeps calling me about that computer. Please fix it so she stops. I'll owe you." },
	TUT_TECHFIX_DONE = { Speaker = "Dee", Text = "She says you're a genius. She also says that about her cat." },
	-- 7 · FirstUpgrade
	TUT_UPGRADE_1 = { Speaker = "Dee", Text = "Better mouse, better aim. Even I get that." },
	TUT_UPGRADE_HINT = { Speaker = "Dee", Text = "That taped-up mouse has to go. Check the pad." },
	TUT_UPGRADE_CALL = { Speaker = "Dee", Text = "Kid, your mouse is held together with tape. You have enough cash for a new one. Treat yourself." },
	TUT_UPGRADE_DONE = { Speaker = "Dee", Text = "See? Your numbers went up. I'm learning." },
	-- 8 · SecondDesk
	TUT_DESK2_1 = { Speaker = "Dee", Text = "You can't carry a team alone. Literally. Buy another desk." },
	TUT_DESK2_HINT = { Speaker = "Dee", Text = "There's a glowing pad by the wall. Stand on it." },
	TUT_DESK2_CALL = { Speaker = "Dee", Text = "A team with one player is just… you. Save up and grab that second desk. Somebody's going to need it." },
	TUT_DESK2_DONE = { Speaker = "Dee", Text = "An empty desk. Very hopeful. I'll make a 'Hiring' sign." },
	-- 9 · FirstHire
	TUT_HIRE_1 = { Speaker = "Dee", Text = "Your friend Rusty from school is looking for a team." },
	TUT_HIRE_HINT = { Speaker = "Dee", Text = "The free agent board is up. Rusty's right at the top." },
	TUT_HIRE_CALL = { Speaker = "Dee", Text = "Rusty's mom told me he's been waiting by the phone. Don't make him wait. Hire him!" },
	TUT_HIRE_DISCOUNT = { Speaker = "Dee", Text = "Good news. Rusty says he'll play for cheap. Very cheap." },
	HEC_FIRSTHIRE = { Speaker = "Hector", Text = "A SIGNING! The roster doubles! Overnight! Incredible!" },
	TUT_HIRE_DONE = { Speaker = "Dee", Text = "His desk earns even when you're out. That's the trick." },
	-- 10 · TeamPug
	TUT_TEAMPUG_1 = { Speaker = "Dee", Text = "Two of you now. Go win something together." },
	TUT_TEAMPUG_HINT = { Speaker = "Dee", Text = "Same button as before. Now Rusty plays too." },
	TUT_TEAMPUG_CALL = { Speaker = "Dee", Text = "Rusty's been warming up for ten minutes. He's stretching. I didn't know you stretch for this. Go play!" },
	HEC_DYNASTY = { Speaker = "Hector", Text = "The dynasty begins! Remember where you saw it first!" },
	-- 11 · FirstUnbox
	TUT_UNBOX_1 = { Speaker = "Dee", Text = "You won a crate! Open it. I love surprises." },
	TUT_UNBOX_HINT = { Speaker = "Dee", Text = "Your crate is waiting. The glowing box." },
	TUT_UNBOX_CALL = { Speaker = "Dee", Text = "Kid, there's a whole new player in that box. Well, not literally. I hope. Open it!" },
	TUT_UNBOX_GLOW = { Speaker = "Dee", Text = "If it glows blue, that's good. I think." },
	HEC_FIRSTRARE = { Speaker = "Hector", Text = "BLUE! That is a RARE pull! What a start!" },
	-- 12 · SeatRare
	TUT_SEAT_1 = { Speaker = "Dee", Text = "New player needs a desk. Third one's on me. Kidding." },
	TUT_SEAT_HINT = { Speaker = "Dee", Text = "Another pad just showed up. You know the drill." },
	TUT_SEAT_CALL = { Speaker = "Dee", Text = "Your new player is standing in my garage holding a keyboard. It's awkward. Buy them a desk." },
	TUT_SEAT_DONE = { Speaker = "Dee", Text = "Three of you. It's starting to look like a real team." },
	-- 13 · Promotion
	TUT_PROMO_1 = { Speaker = "Dee", Text = "Win a few more and people will notice. That's Fame, right?" },
	TUT_PROMO_HINT = { Speaker = "Dee", Text = "Play another Pickup Game. Wins bring Fame." },
	TUT_PROMO_CALL = { Speaker = "Dee", Text = "The café down the street wants teams with a bit of a name. Win a couple more and they'll call." },
	TUT_RENAME_REMIND = { Speaker = "Dee", Text = "Last chance to change your team name for free." },
	HEC_PROMO_S2 = { Speaker = "Hector", Text = "Café Rookies, here they come! Out of the garage!" },
	TUT_GRADUATE = { Speaker = "Dee", Text = "You did it, kid. I'm keeping the old mouse. For the wall. xo Dee" },

	-- Situational
	TUT_BROKE = { Speaker = "Dee", Text = "Spent it all? Classic. Sit at your desk for a bit." },
	TUT_OFFPLOT = { Speaker = "Dee", Text = "Where are you going? The garage is this way." },
	TUT_WELCOMEBACK = { Speaker = "Dee", Text = "Welcome back! Let's pick up where you left off." },
	TUT_LOSS = { Speaker = "Dee", Text = "You lost? That's fine. Everybody loses. Go again." },
	TUT_STARTER_LETTER = { Speaker = "Dee", Text = "P.S. Here's a little something to get you started." },
}

return lines
