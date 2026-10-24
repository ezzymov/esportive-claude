# Data Schema & Code Layout

## Principles
- **Server authoritative** for money, rolls, matches, contracts. Client = display + requests.
- RemoteEvents/Functions validate every request (rate limit, ownership, affordability).
- DataStore with session lock (ProfileStore) + autosave + forced saves after valuable events + save on leave and on shutdown. Full rules: [[Data Persistence]] (shutdown/updates: [[Shutdown & Update Handling]], `Version` + migrations: [[Save Versioning & Migrations]], backups: [[Backups & Recovery]], every store: [[DataStore Registry]]).

## Player profile (Luau table)
```lua
Profile = {
  Version = 1,
  Team = { Name, Tag, LogoId, Colors, Jersey },
  Currencies = { Cash, Gems, Shards, Fame, Followers, LegacyPoints },
  Stage = 1, Rebirths = 0,
  Roster = { [id] = PlayerCard },      -- active + bench + academy
  Inventory = { Parts = {}, Cosmetics = {}, Boosters = {} },
  Stations = { [slot] = { PlayerId, Parts = { CPU, GPU, Monitor, Chair, Desk } } },  -- mouse/keyboard/headset are Accessories now
  Staff = {}, Sponsors = {}, Clips = {}, Trophies = {},
  PityCounters = { Epic, Legendary, Mythic },
  Quests = {}, Settings = {}, LastSeen = 0,
  HQ = { Era, PadsBought = {}, Decor = {}, HQLevel = 0 },
  Training = {}, Rivals = {}, Achievements = {}, Collection = {},
  Arena = {}, Hype = 0, LegacyPoints = 0, LegacyPerks = {}, LegacyHall = {},
  Snapshot = {}, PendingEvent = nil, EventCooldownUntil = 0,
  Streak = { Day = 0, LastClaim = 0 }, PassTier = 0, Purchases = {},
  Tournament = nil,                    -- running timed tournament, see [[Matches & Tournaments]] → Tournament timing
  -- Inventory also gets TimeSkips = { Quick, Hour, Big } ([[Time Skip Tickets]])
}
PlayerCard = { Id, Name, Role, Rarity, Stats = {Aim,...}, Potential, Trait, Salary, Morale, Fatigue,
  Source, GrantedBy?, GrantId?, Tradeable, SeasonId?, Original?,     -- admin/season fields: [[Admin Panel]], [[Monthly Seasons]]
  Accessories = { Mouse?, Keyboard?, Headset?, Sleeve?, Glasses?, Charm? } }  -- SkinItem Uuids in Inventory.Cosmetics; see [[Accessories]]
-- Gear stats are never stored: GearService computes them from Accessories + applied stickers + Stage.
-- Profile also gets: ClaimedGrants = { [GrantId] = true }, ModNotes = {}, Warnings = {}
```

### Added in M1 (2026-10-23)
No `Version` bump: every field has a default, so `Reconcile()` fills it in. Code: `DataService/Template.luau`.
```lua
Team = { ..., Colors = { Primary = colorIndex, Tee = colorIndex },  -- indexes into Config/Team.Colors
         Jersey = { Garment = "OwnTee" }, FounderRole = "Flex" }    -- role locks once the Founder card exists
Inventory.Cases = { [caseId] = count }                             -- M1: RookieCrate
Stations = { ["1"] = { PlayerId, Tier = 1, Parts = {} }, ... }    -- slot keys are strings; "1" = Founder desk
FounderUuid = ""
Flags = { IntroSeen, StarterLetterSeen, TeamCreated, StationPowered } -- one-shot onboarding flags (false)
Ftue = {
  PlaySeconds,            -- total time in game (12-min Rusty guardrail)
  PickupGames, PickupWins, TeamPugLosses, AimRuns, TechFixJobs,
  CratesEarned, CratesOpened, FirstHireAt, RustyDiscount,
  StarterRoll = { Id?, Seed? },  -- Rookie Crate's Rare, rolled when the crate is granted (no reroll on rejoin)
  BeatAt = { [stepId] = playSeconds },  -- test-run report (DevHooks "Beats")
  Funnel = { [funnelStep] = playSeconds },
}
Tutorial = { Version = 1, Step = "NameTeam" | ... | "Done", Completed = { [stepId] = unix }, Skipped, HintLevel }
Achievements.GarageGraduate = unix
PlayerCard += { Seed, Source = "Founder" | "Key" | "Generated" | "Pug", KeyId?, Xp = { [stat] = 0–99 } (Founder),
                Age, Country (index), GenVersion, Morale }
-- Name, bio and look are rebuilt from Seed (Shared/Generator), never stored. Founder name = live display name.
```

### Added in M2/M3 (2026-10-23)
No `Version` bump (every field has a default; `Tournament` defaults to nil). Code: `DataService/Template.luau`.
```lua
Inventory.Parts       = { [partId] = spare copies }        -- equipped ones live on Stations[slot].Parts[partSlot]
Inventory.Accessories = { [itemId] = spare copies }        -- equipped ones live on PlayerCard.Accessories[slot] (item id)
Inventory.Cases       = { [caseId] = count }                -- StarterCrate = the Stage 1 FTUE crate (was RookieCrate in M1)
CaseStats   = { Opened = 0, NextFreeAt = 0 }               -- lifetime opens; os.time() of the next free Rookie Crate (0 = not started)
PityCounters = { Epic, Legendary, Mythic }                 -- one family (Core) for now
Collection  = { [itemId] = os.time() first owned }         -- drives the NEW! badge
Stations[slot] = { PlayerId, Tier, Parts = { CPU?, GPU?, Monitor?, Chair?, Desk? } }  -- desks 1–5 = the active five
Chemistry   = { ["idA|idB"] = matches played together }    -- ids sorted; cleared on release
MapMastery  = { [mapId] = 0–100 }
Competition = { Scrims, ScrimWins, Cups, CupWins }
Trophies    = { { Def, Name, Place, At } }                 -- array; the trophy shelf shows the newest 8
TournamentLog = { { Def, Name, Place, At } }               -- newest first, last 5
Tournament  = nil | {
  Id, Def, Seed, RegisteredAt, Status = "Running" | "Eliminated" | "Won",
  You,                                                     -- your bracket slot
  Teams  = { { Id = "You" | aiTeamId, Name, Tag, Color, Ovr, Seed, SeedNo } },   -- bracket slot order
  Rounds = { { Name, LocksAt, PlaysAt, Played, Matches = { { A, B, W, Score?, Map? } } } },
  Pool, Bans,                                              -- map pool at registration; your veto order
  Snapshots = { [round] = { Players = { { Card, Gear, PartMult, Morale, Fatigue, Best } }, Chemistry, Mastery, Bans } },
  Mine   = { [round] = { Round, Opponent, Win, Score, Map, Mvp } },
  Place, Prize = { Cash, Fame, Case, Trophy }, Unwatched, Recap = { lines },
}
PlayerCard += { Fatigue, FatigueAt, MoraleAt, MatchesPlayed, BestKills }  -- condition recovers lazily from the *At times
```
- Accessories are counted by item id for now (plain models, no seed/finish). When [[Skin Pattern System]] items arrive, a migration turns each count into Uuid items.
- `Tournament` holds arrays, so services change it as a whole table (dot paths use string keys).

## Folder layout (Rojo-friendly)
```
ReplicatedStorage/
  Shared/  (Config modules: Rarities, Cases, Parts, Stages, Theme)
  Remotes/
ServerScriptService/
  Services/ DataService, EconomyService, CaseService, RosterService, MatchService, ClipService, SponsorService
ServerStorage/ (assets, case models)
StarterPlayerScripts/
  Controllers/ UIController, CaseOpenController, ...
StarterGui/ (ScreenGuis built from UI notes)
```

See also [[Services & Remotes]], [[Match Simulation]], [[Security & Anti-Exploit]], [[Analytics & Metrics]], [[Content Catalog]].

## Config-driven content
All cases, parts, players, sponsors live in data modules (or JSON → module) so Claude can add content without touching logic.
