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
