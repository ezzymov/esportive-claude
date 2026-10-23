---
tags: [feature, social]
status: designed
priority: P1
stage: 2
system_type: CoreMechanic
engine_layer: ServerService
dependencies:
  - "[[Player Generator]]"
  - "[[Data Schema]]"
affected_ui:
  - "[[Screen - Roster]]"
  - "[[Screen - Settings & Odds]]"
roblox_execution_environment: ServerScriptService
---
# Friend Signings

## Summary
Your Roblox friends can become players on your team, using **their real Roblox avatar** wearing your jersey. It's a strong social hook ("I signed you to my team!") and a natural invite loop.

## Who can appear
- Friends from your Roblox friends list (`Players:GetFriendsAsync`).
- **Only friends who have joined eSports Tycoon at least once** and have **"Let friends sign me"** turned on (default ON; toggle in [[Screen - Settings & Odds]]).
- Friends who haven't played show as an **invite card** instead ("Invite Sam to sign them").
- Max 5 friend cards on the Friends Board at a time (refreshes daily, shows friends who were online most recently first).

## How it works
1. **Friends Board** tab on the free agent screen (Stage 2). Each card shows the friend's display name, avatar in your jersey, role, rarity, OVR.
2. **Sign** for a small fee (Cash). No salary for the first season ("playing for the love of the game").
3. Friend appears at a station in your HQ with their real avatar + your jersey and headset.
4. Next time that friend joins, they get an inbox message: "**{YourTeam}** signed you!" with a small gift (Gems or a Rookie Crate) and a **Sign back** button.

## Stats and design
- **Look:** friend's avatar from `Players:GetHumanoidDescriptionFromUserId`, with your team jersey layered on top. Refreshed at most every 24 h (if they change their avatar, it updates).
- **Name:** friend's Roblox display name (already Roblox-approved). Gamer tag line shows "@username" small underneath.
- **Stats:** generated with [[Player Generator]] using `seed = hash(yourUserId, friendUserId)`. So the same friend is always the same card **for you**, but has different stats on other people's teams. Nothing is based on the friend's real skill or data.
- **Rarity:** Uncommon 45% · Rare 35% · Epic 17% · Legendary 3%.
- **Trait:** always gets **Real Friend** plus one normal trait.
  - *Real Friend*: +5 team morale; +10% stats while that friend is in the same server as you.

## Friend Bond
- Play in the **same server** as the friend → Bond XP (per 10 min together, per friend scrim, per trade).
- Bond levels 1–5: each level gives +2 to all stats and +2 Potential (max +10 / +10).
- Bond 5 unlocks a **duo cutscene** in clips (both players celebrate together) and the "Best Friends" achievement.

## Limits
- Max **2 friend players in the active five**; any number on the bench.
- Friend cards are **untradeable and can't be sold** on any market (they're someone's real avatar). They can be released.
- Friend cards don't appear in clips shared to the global feed **unless** the friend has played and allowed signing (which is already required). Server-only clips are always fine.

## Opt-out and safety
- Turning off "Let friends sign me" removes you from everyone's teams on their next join. Their card becomes a generated player with the same stats and a new look, plus a refund of the signing fee.
- If the friendship ends (unfriended), same as opt-out.
- Blocked users never appear.
- Banned or deleted accounts turn into generated players.
- No friend data is stored beyond `UserId` and the signing date. Display names and avatars are fetched live, never saved.

## Invite loop
- Invite card uses `SocialService:PromptGameInvite`.
- When the invited friend joins for the first time: both players get a **Rare Crate**, and the friend is instantly available to sign (Rare+ guaranteed for that first signing).
- Achievement chain: sign 1 / 5 / 10 friends.

## Server / data requirements
```lua
PlayerCard.Source = "Friend", PlayerCard.FriendUserId = 123456
Profile.Friends = { Board = {userIds}, BoardRefreshedAt, Bond = {[userId] = {Level, Xp}} }
GlobalStore "FriendSignPrefs" = {[userId] = {HasPlayed = true, AllowSigning = true}}
```
- `GetFriendsAsync` pages are cached per session; check `FriendSignPrefs` before showing a card.
- Avatar fetch failures fall back to a generated look until the next try.

## UI screens
- Friends Board tab in [[Screen - Roster]] → Free Agents
- Inbox notification card ("You were signed!")

## Acceptance criteria
- [ ] Only friends who played and allowed signing appear as signable
- [ ] Friend's avatar shows at a station wearing your jersey
- [ ] Friend gets the "you were signed" message and gift on next join
- [ ] Opting out removes the friend from others' rosters with a refund
- [ ] Friend cards can't be added to trades

## Open questions
- Should under-13 accounts default to "Let friends sign me" OFF? Safer; lean yes.
