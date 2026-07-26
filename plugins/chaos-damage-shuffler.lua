local plugin = {}

plugin.name = "Chaos Damage Shuffler"
plugin.author = "authorblues and kalimag (MMDS), Phiggle, Rogue_Millipede, Shadow Hog, expeditedDelivery, Smight, endrift, ZoSym, Extreme0, L Thammy"
plugin.minversion = "2.9.1"
plugin.settings =
{
	{ name='InfiniteLives', type='boolean', label='Infinite* Lives (see notes)' },
	{ name='ClingerSpeed', type='boolean', label='BT NES: Auto-Clinger-Winger (unpatched ONLY)' },
	{ name='BTSNESRash', type='boolean', label='BT SNES: I want Rash, pick 2P, give Pimple 1 HP'},
	{ name='SuppressLog', type='boolean', label='Suppress "ROM unrecognized"/"on Level 1" logs'},
	{ name='DebugSingleGame', type='boolean', label='Debugging: Rearm the shuffler logic even if no new game was loaded' },
	{ name='SMW2YI_MiniBonusSwaps', type='boolean', label="Yoshi's Island: Shuffle on Mini Battle damage/loss", default=true},
	{ name='IceClimberBonusSwaps', type='boolean', label="Ice Climber (NES): Shuffle on failing the bonus game"},
	{ name='grace', type='number', label="Minimum grace period before swapping (won't go < 10 frames)", default=10 },
}

plugin.description =
[[
	This is a mod of the excellent Mega Man Damage Shuffler plugin by authorblues and kalimag.
	Get swapped to a different game upon taking damage. Supported games listed below. What is 'damage' depends on the game!
	If your ROM is not recognized, no damage swap will occur. Most of the time, NTSC-U versions are supported.
	For Battletoads games, you can choose the level where you start and enable other bonuses.
	Multiplayer shuffling supported.
	Randomizers should be supported (e.g., ALTTPR, VARIA, ZOoTR, SMZ3) by adding your game's hash to the .dat file.
	Additional ideas from the TownEater fork have been implemented.
	Thank you to Diabetus, Smight and ConstantineDTW for extensive playthroughs that tracked down bugs!

	ENABLE EXPANSION SLOT FOR N64 GAMES! This should be the default configuration, but check!

	YOU WILL NEED BizHawk 2.10 MINIMUM for Sega CD and Sega Saturn games to be recognized and shuffled correctly!

	Supported games:

	BATTLETOADS BLOCK
	-Battletoads (NES), 1-2p - also works with the bugfix patch by Ti: https://www.romhacking.net/hacks/2528/
	-Battletoads in Battlemaniacs (SNES), 1-2p
	-Battletoads-Double Dragon (NES), 1-2p
	-Battletoads-Double Dragon (SNES), 1-2p, including if patched to use level select by default (see instructions)
	-Battletoads (Arcade), 1p

	MARIO BLOCK
	-Mario Bros. (NES), 1-2p
	-Super Mario Bros. (NES), 1-2p
	-Super Mario Bros. 2 JP ("Lost Levels"), NES version, 1p
	-Super Mario Bros. 2 USA (NES), 1p
	-Super Mario Bros. 3 (NES), 1-2p (includes battle mode)
	-Somari (NES, unlicensed), 1p
	-Super Mario World (SNES), 1-2p
	-Super Mario World 2: Yoshi's Island (SNES), 1p plus 2p secret mini battles
	--- check toggle for whether you want mini battle damage/losses to swap!
	-Super Mario All-Stars (SNES), 1-2p, with or without World (includes SMB3 battle mode)
	-Super Mario Land (GB or GBC DX patch), 1p
	-Super Mario Land 2: 6 Golden Coins (GB or GBC DX patch), 1p
	-Super Mario 64 (N64), 1p - including Better Non-Stop hack
	-New Super Mario Bros. (DS), 1p

	CASTLEVANIA BLOCK
	-Castlevania (NES), 1p
	-Castlevania II (NES), 1p
	-Castlevania III (NES, or Famicom with translation patch), 1p
	-Super Castlevania IV (SNES), 1p
	-Castlevania: Dracula X (SNES), 1p
	-Castlevania II - Belmont's Revenge (GB), 1p
	-Castlevania: Bloodlines (Genesis/Mega Drive), 1p
	-Castlevania: Rondo of Blood (TG16-CD), 1p
	-Castlevania (N64), 1p (in-progress, grabbing shuffles excessively)
	-Castlevania: Legacy of Darkness (N64), 1p (in-progress, grabbing and poison shuffle excessively)
	-Castlevania: Symphony of the Night (PSX), 1p
	-Castlevania: Aria of Sorrow (GBA), 1p
	-Castlevania: Dawn of Sorrow (DS), 1p
	-Castlevania: Portrait of Ruin (DS), 1p
	-Castlevania: Order of Ecclesia (DS), 1p

	METROID BLOCK - should not shuffle on losing health from being "drained" by acid, heat, shinesparking, certain enemies
	-Metroid (NES), 1p
	-Metroid II (GB or GBC color patch), 1p
	-Super Metroid (SNES) - 1p, US/JP version
	-Metroid Fusion (GBA), 1p
	-Metroid Zero Mission (GBA), 1p

	ZELDA BLOCK
	-The Legend of Zelda (NES), 1p
	-Zelda II The Adventure of Link (NES), 1p
	-The Legend of Zelda: A Link to the Past (SNES) - 1p, US or JP 1.0
	-Link's Awakening (GB), 1p
	-Link's Awakening DX (GBC), 1p
	-Ocarina of Time (N64), 1p
	-Majora's Mask (N64), 1p
	-Oracle of Seasons (GBC), 1p
	-Oracle of Ages (GBC), 1p
	-Minish Cap (GBA), 1p

	THE LINK/SAMUS BLOCK
	-Super Metroid x LTTP Crossover Randomizer, aka SMZ3 (SNES), 1p

	CONTRA BLOCK
	-Contra/Probotector (NES), 1-2p
	-Super C/Super Contra/Probotector II (NES), 1-2p
	-Contra III: The Alien Wars/Super Probotector: Alien Rebels/Contra Spirits (SNES), 1-2p
	-Contra: Hard Corps (Genesis/Mega Drive), 1-2p

	KONG BLOCK
	-Donkey Kong Country (SNES), 1p, 2p Contest, or 2p Team
	-Donkey Kong Country 2: Diddy's Kong Quest (SNES), 1p, 2p Contest, or 2p Team
	-Donkey Kong Country 3: Dixie Kong's Double Trouble (SNES), 1p, 2p Contest, or 2p Team
	-DKC x Mario (SNES, DKC1 hack by RainbowSprinklez), 1p
	-Donkey Kong Land (GB), 1p

	KIRBY BLOCK
	-Kirby's Dream Land (GB), 1p
	-Kirby's Adventure (NES), 1p
	-Kirby: Super Star (SNES), 1p
	-Kirby: Nightmare in Dream Land (GBA), 1p
	-Kirby and the Amazing Mirror (GBA), 1p
	
	SONIC BLOCK
	-Sonic the Hedgehog (Genesis/Mega Drive), 1p
	-Sonic the Hedgehog 2 (Genesis/Mega Drive), 1p (2p support someday)
	-Sonic the Hedgehog 3 (Genesis/Mega Drive), 1p (2p support someday)
	-Sonic & Knuckles (Genesis/Mega Drive), 1p
	-Sonic the Hedgehog 3 & Knuckles (Genesis/Mega Drive), 1p (2p support someday)
	-Knuckles the Echidna in Sonic the Hedgehog 2 (Genesis/Mega Drive), 1p
	-Sonic the Hedgehog Spinball (Genesis) (Genesis/Mega Drive), 1p (multiplayer someday?)
	-Sonic the Hedgehog CD (Sega [Mega] CD), 1p
	-Sonic 3D Blast: Flickies' Island (Genesis/Mega Drive), 1p
	-Sonic 3D Blast (Saturn), 1p

	ADDITIONAL SUPPORTED GAMES
	-ActRaiser (SNES), 1p
	-Adventures in the Magic Kingdom (NES), 1p
	-Adventures of the Gummi Bears (bootleg) (Genesis/Mega Drive), 1p
	-Aero the Acro-Bat (SNES), 1p
	-Aladdin (Genesis/Mega Drive), 1p
	-Aladdin (SNES), 1p
	-Alundra (PSX), 1p, supports patched versions (e.g., Unworked Designs)
	-Anticipation (NES), up to 4 players, shuffles on incorrect player answers, correct CPU answers, and running out of time.
	-Arkanoid: Doh it Again (SNES), 1p
	-Astro Boy - Omega Factor (USA) (GBA), 1p
	-Bakuretsu Muteki Bangaioh (Japan) (N64), 1p
	-Banjo-Kazooie (N64), 1p
	-Bao Qing Tian (Ch) (NES), 1p
	-Batman (NES), 1p
	-Blades of Steel (NES - NA/Europe), 1-2p
	-Bonk's Adventure (TG-16), 1p
	-Bubble Bobble (NES), 1p
	-Bubsy in Claws Encounters of the Furred Kind (aka Bubsy 1) (SNES), 1p
	-Bubsy in Fractured Furry Tales (Jaguar), 1p
	-Bubsy 3D: Furbitten Planet (PS1), 1p
	-Bucky O'Hare (NES), 1p
	-Bugs Bunny: Birthday Blowout (NES), 1p
	-Bugs Bunny: Crazy Castle (NES), 1p
	-Captain Novolin (SNES), 1p
	-Chip and Dale Rescue Rangers 1 (NES), 1-2p
	-Chip and Dale Rescue Rangers 2 (NES), 1-2p
	-Crash Bandicoot 1-3 (PSX), 1p, US version
	-Crash Bandicoot 4 (Bootleg) (NES), 1p
	-Cybernator (USA) (SNES), 1p
	-Darkwing Duck (NES), 1p
	-Demon's Crest (SNES), 1p
	-Dick Tracy (NES), 1p
	-Do-Re-Mi Fantasy - Milon no Dokidoki Daibouken (SNES), 1p
	-Double Dragon 1 (NES), 1-2p, Mode A or B, shuffles on knockdown and death
	-Double Dragon 2 (NES), 1-2p, shuffles on knockdown and death
	-DuckTales (NES), 1p
	-DuckTales 2 (NES), 1p
	-Dynamite Headdy (Genesis/Mega Drive), 1p
	-Earnest Evans, Mega CD
	-Einhänder (PSX), 1p
	-F-Zero (SNES), 1p
	-Family Feud (SNES), 1-2p
	-Garfield: A Week of Garfield (NES), 1p
	-Gargoyle's Quest II (NES), 1p
	-Ghosts'n Goblins (NES), 1p
	-Ghouls'n Ghosts (Genesis/Mega Drive), 1p
	-Gimmick! (NES/Famicom), 1p
	-Goof Troop (SNES), 1-2p
	-Gremlins 2: The New Batch (NES), 1p
	-Gunstar Heroes (Genesis/Mega Drive), 1p
	-Hammerin' Harry (NES), 1p
	-Hercules II (Bootleg) (Genesis/Mega Drive), 1p
	-High Seas Havoc (Genesis/Mega Drive), 1p
	-Ice Climber (NES), 1-2p
	--- check toggle for whether you want bonus game losses to swap!
	-Indiana Jones and the Last Crusade (Genesis/Mega Drive), 1p
	-I.Q.: Intelligent Qube (PS1), 1p (2p someday?)
	-Jackal (NES), 1-2p
	-Jackie Chan's Action Kung-Fu (NES), 1p
	-James Bond Jr. (SNES), 1p
	-Jaws (NES), 1p
	-Jim Power - The Lost Dimension in 3D (SNES), 1p
	-Journey to Silius (NES), 1p
	-Jungle Book, The (NES, SNES, Genesis/Mega Drive), 1p
	-Jurassic Park (SNES), 1p
	-Kabuki Quantum Fighter (NES), 1p
	-Kuru Kuru Kururin (GBA), 1p
	-Last Alert (TG-16 CD), 1p
	-Little Samson (NES), 1p
	-Lion King, The (NES), 1p
	-Lion King, The (bootleg) (NES), 1p
	-Lion King, The (SNES), 1p
	-Lion King 2 (bootleg) (Genesis/Mega Drive), 1p
	-Magical Kid's Doropie / Krion Conquest (NES), 1p
	-Majuu Ou (Japan) / King of Demons (SNES), 1p
	-Marble Madness (NES), 1-2p
	-Mario Kart: Super Circuit (SNES), 1p, Grand Prix - shuffles on collisions with other karts (lost coins or have 0 coins), falls
	-Mario Paint (SNES), joystick hack, Gnat Attack, 1p
	-Math Blaster - Episode 1 (SNES), 1p
	-Mega Q*Bert (Genesis/Mega Drive), 1p
	-Mendel Palace (NES), 1p
	-Metal Slug - Super Vehicle-001 (Arcade), 1p
	-Metal Storm (NES), 1p
	-Mighty Morphin Power Rangers - The Movie (SNES), 1p
	-Minnesota Fats - Pool Legend (Saturn), 1p story mode
	-Ms. Pac-Man (Tengen) (NES), 1p
	-Monopoly (NES), 1-8p (on one controller), shuffles on any human player going bankrupt, going or failing to roll out of jail, and losing money (not when buying, trading, or setting up game)
	-Mortal Kombat (Genesis/Mega Drive), 1p (for now)
	-Mortal Kombat II (SNES), 1p (for now)
	-Mystic Warriors (Arcade), 1p
	-NBA JAM Tournament Edition (PSX), 1p - shuffles on points scored by opponent and on end of quarter
	-Ninja Gaiden (NES), 1p
	-Ninja Gaiden II - The Dark Sword of Chaos (NES), 1p
	-Ninja Gaiden III - The Ancient Ship of Doom (NES), 1p
	-Ninjawarriors (SNES), 1p
	-PaRappa the Rapper (PSX), 1p - shuffles on dropping a rank
	-Pebble Beach Golf Links (Sega Saturn), 1p - Tournament Mode, shuffles after stroke
	-Pepsiman (PSX), 1p
	-Pictionary (NES)
	-Pocky & Rocky (SNES), 1-2p
	-Pocky & Rocky 2 (SNES), 1-2p
	-Power Blade (NES), 1p
	-Power Blade 2 (NES), 1p
	-Powerslave/Exhumed, Saturn
	-Psycho-Nics Oscar (World revision 0) (Arcade), 1p
	-Rainbow Islands - The Story of Bubble Bobble 2 (NES), 1p
	-Resident Evil (PSX), 1p - includes OG, Director's Cut, Dualshock and True Director's Cut Hack
	-Resident Evil 2 (PSX), 1p - includes Regular & DualShock Ver (recommend using multi-disk bundler to work between disks)
	-Resident Evil 3 (PSX), 1p
	-Ristar (Genesis/Mega Drive), 1p
	-Rock 'n Roll Racing (SNES), 1p
	-Rocket Knight Adventures (Genesis/Mega Drive), 1p
	-Rollergames (NES), 1p
	-Rubble Saver II (GB), 1p
	-Sanrio World Smash Ball! (SNES), 1-2p
	-Saturday Night Slam Masters (SNES), 1p
	-SD Gundam Psycho Salamander no Kyoui (Arcade), 1p
	-SD Gundam Sangokushi Rainbow Tairiku Senki (Japan) (Arcade), 1p
	-Shaq-Fu (Genesis/Mega Drive), 1p
	-Shatterhand (NES), 1p
	-Shinobi III (Genesis/Mega Drive), 1p
	-Simpsons: Bart vs. the World (NES), 1p
	-Snake Rattle 'n Roll (NES), 1p
	-Sonic Jam 6 (bootleg) (Genesis/Mega Drive), 1p
	-Sparkster (SNES), 1p
	-StarTropics (NES), 1p
	-Street Fighter 2010: The Final Fight (NES), 1p
	-Streets of Rage II (Genesis/Mega Drive), 1-2p (includes duel mode)
	-Star Fox 64 (N64), 1p-4p
	-Sunset Riders (SNES, Genesis, Arcade), 1p
	-Super Aladdin (bootleg) (NES), 1p
	-Super Contra 7 (bootleg) (NES), 1-2p
	-Super Dodge Ball (NES), 1-2p, all modes
	-Super Ghouls'n Ghosts (SNES), 1p
	-Super Mario Kart (SNES), 1-2p - shuffles on collisions with other karts (lost coins or have 0 coins), falls
	-Sonic Mario Bros., Squirrel King mechanics (bootleg) (Genesis/Mega Drive), 1p
	-Super Monkey Ball Jr. (GBA), 1p
	-Super Smash TV (SNES), 1p
	-TaleSpin (NES), 1p
	-Tarzan: Lord of the Jungle (unreleased) (SNES), 1p
	-Tecmo Super Bowl (NES), 1p (on opponent scores, giveaways, giving up first down, failing to get a first down)
	-Teenage Mutant Ninja Turtles (NES), 1p
	-Teenage Mutant Ninja Turtles II: The Arcade Game (NES), 1-2p
	-Teenage Mutant Ninja Turtles III: The Manhattan Project (NES), 1-2p
	-Teenage Mutant Ninja Turtles IV: Turtles in Time (SNES), 1-2p
	-The Magical Quest Starring Mickey Mouse (SNES), 1-2p
	-The Magical Quest 2: The Great Circus Mystery Starring Mickey & Minnie (SNES), 1-2p
	-The Magical Quest 3: Mickey to Donald - Magical Adventure 3 (SNES), 1-2p
	-Tiny Toon Adventures (NES), 1p
	-Titenic (bootleg) (NES), 1p
	-Trip World (GB) and Trip World DX (GBC), 1p
	-Tony Hawk's Pro Skater (PSX), 1p
	-Tony Hawk's Pro Skater 2 (PSX), 1p
	-Tony Hawk's Pro Skater 3 (PSX), 1p
	-Tony Hawk's Pro Skater 4 (PSX), 1p
	-Twisted Metal 2 (PSX), 1p
	-U.N. Squadron (SNES), 1p
	-Ultimate Mortal Kombat 3 (SNES), 1p (for now)
	-Vice: Project Doom (NES), 1p
	-Vs. Ice Climber, set IC4-4 B-1 (Arcade), 1p
	-WarioWare, Inc.: Mega Microgame$! (GBA), 1p - bonus games including 2p are pending
	-Wild Guns (SNES), 1p
	-Windjammers / Flying Power Disc (Arcade), 1p
	-Wit's (NES), 1p
	-Wolf Fang SS - Kuuga 2001 (Japan) (Saturn), 1p

	NICHE ZONE
	- NES 240p Suite: shuffles on every second that passes in Stopwatch Mode. Can be useful for testing a single game.


	----PREPARATION----
	Set Min and Max Seconds VERY HIGH, assuming you don't want time swaps in addition to damage swaps.
	If adding N64 games, enable the Expansion Slot. Some games will fail to shuffle or crash BizHawk without it.

	Non-Battletoads games: just put your game in the games folder.

	Battletoads games:
	To run the game just like any other game, simply put it in the games folder.
	If you intend to use the plugin's level skip to shuffle multiple levels at once:
	-Put multiple copies of your ROM into the games folder - one for every starting level you want to include.
	-Rename the ROM files to START with two-digit numbers, like 01, 02, 03, etc., as below.

	Battletoads (NES):
	-Level range: 01 to 13
	-How to level select: Automatically enabled.

	Battletoads in Battlemaniacs (SNES):
	-Level range: 01 to 08
	-How to level select: Pimple will start with 1 HP and no lives if you specify a level higher than 1, OR if you click the "I want Rash" option. Let Pimple die. Then, if using Pimple, continue (the continue gets refunded), or if using Rash (1p or 2p), just let the timer run out. You get an on-screen reminder to do this, and the reminder is gone when you shuffle back.

	Battletoads-Double Dragon (NES):
	-Level range: 01 to 14
	-How to level select: the Level select screen is automatically enabled. A message on screen the first time will tell you which level to pick after character select.

	Battletoads-Double Dragon (SNES):
	-Level range: 01 to 14
	-How to level select: A message on screen the first time will tell you what level to pick after you choose characters. But, for now, you have to enable level select yourself :(
	--OPTION ONE: just enter the cheat code at the character select screen. The screen blinks when it's entered correctly.
	--OPTION TWO: Patch your ROM(s) with the Game Genie code DD6F-1923. Here is a patcher! https://www.romhacking.net/utilities/1054/

	----BATTLETOADS EXAMPLES AND TIPS----
	To shuffle every single level of Battletoads NES, make 13 copies with filenames starting with 01 through 13.

	You can include one copy each of all these Battletoads games, with no special naming, to simply have damage shuffling starting from level 1.

	If you want a Battletoads-Double Dragon run without mid-level checkpoints (1-1, 2-1, 3-1, ... 7-1), then only add files that start with: 01, 03, 06, 09, 11, 13, 14.

	You could do an "all Turbo Tunnels" run with BT NES = 03, BTDD (either/both) = 05, and BT SNES = 04. Throw in Surf City (BT NES 05), Volkmire's Inferno (BT NES 07), Roller Coaster (BT SNES 06), the awful spaceship levels (BTDD 09 and 10)...


	----OPTIONS----

	Infinite Lives will make it far easier to progress. The lives refill on each swap.
	- Thank you to kalimag for work that made infinite lives persist through your final game!
	- Infinite lives do not activate for the second player on NES Clinger-Winger on an unpatched ROM, since P2 can't move. Use the patch if you want two-player Clinger-Winger for some reason!
	- Several games do not have 'lives' to make infinite, such as Anticipation, Super Metroid, A Link to the Past, and others. Nothing will change in these games with this option.
	- ADVANCED: To override individual games (for example, to turn OFF infinite lives for a given game): find #TO_OVERRIDE_INFINITE_LIVES in this plugin and consult the example.

	Auto-Clinger-Winger NES: You can enable max speed and auto-clear the maze (level 11).
	-- You MUST use an unpatched ROM for this option to activate. The second player will not be able to move, so only Rash can get to the boss in 2p. Infinite Lives will be disabled for the second player in this scenario to prevent a softlock.
	-- You still have to beat the boss. If you use Infinite Lives, this could make Clinger-Winger fairly trivial.

	Rash 1-player mode in Battlemaniacs (SNES): see above! Start in 2p, let Pimple die and let the continue timer run out to deathwarp. Make sure your 2p controller is mapped the same as 1p aside from Start, so you can progress. In the future, this may be more automated.

	Debugging: Rearm the shuffler logic even if no new game was loaded - useful for testing new games/revisions if not using the damage-debug plugin. You can set PAUSE_ON_SWAP in the plugin to true if you want BizHawk to pause every time a swap would otherwise happen.

	Suppress Logs: if you do not want the lua console log to tell you about file naming errors, or unrecognized ROMs. This can help keep the log cleaner if you are also using the Mega Man Damage Shuffler or other plugins!

	Grace period: 10 frames is the default minimum frames between swaps. Adjust up as needed. This idea originated in the TownEater fork of the damage shuffler!

	Enjoy? Send bug reports?

]]

local NO_MATCH = 'NONE'

-- debugging settings
local PAUSE_ON_SWAP = false -- pause whenever a swap would occur

local tags = {}
local tag
local gamemeta
local prevdata
local debug_timer
local swap_scheduled
local shouldSwap
local gamesleft
local prev_framecount


local bt_nes_level_names = { "Ragnarok's Canyon",
	"Wookie Hole",
	"Turbo Tunnel",
	"Arctic Caverns",
	"Surf City",
	"Karnath's Lair",
	"Volkmire's Inferno",
	"Intruder Excluder",
	"Terra Tubes",
	"Rat Race",
	"Clinger-Winger",
	"The Revolution",
	"Armageddon"}

local btdd_level_names = { "1-1", "1-2", "2-1", "2-2", "2-3", "3-1", "3-2", "3-3", "4-1", "4-2", "5-1", "5-2", "6-1", "7-1"}

local bt_snes_level_names = { "Khaos Mountains",
	"Hollow Tree",
	"Bonus Stage 1",
	"Turbo Tunnel Rematch",
	"Karnath's Revenge",
	"Roller Coaster",
	"Bonus Stage 2",
	"Dark Tower"}

local bt_snes_level_recoder = { 0, 1, 2, 3, 4, 6, 8, 7 } -- THIS GAME DOESN'T STORE LEVELS IN THE ORDER YOU PLAY THEM, COOL
---------------

-- update value in prevdata and return whether the value has changed, new value, and old value
-- value is only considered changed if it wasn't nil before
local function update_prev(key, value)
	if key == nil or value == nil then
		error("update_prev requires both a key and a value")
	end
	local prev_value = prevdata[key]
	prevdata[key] = value
	local changed = prev_value ~= nil and value ~= prev_value
	return changed, value, prev_value
end

-- Sets prevdata[key] to start_value.
-- If reset is true, the start_value always replaces any previous value.
-- if keep_highest is true, start_value only replaces a lower previous value.
-- Otherwise, any existing previous value is kept.
local function start_countdown(key, start_value, reset, keep_highest)
	assert(key ~= nil and type(start_value) == "number", "start_countdown requires both a key and a numeric start_value")
	local prev_value = prevdata[key]
	if reset or type(prev_value) ~= "number" or (keep_highest and start_value > prev_value) then
		prevdata[key] = start_value
		return true
	else
		return false -- countdown not changed
	end
end

-- Decrements countdown in prevdata[key].
-- If the countdown has reached 0, the countdown is cleared and the function returns true.
-- Otherwise, returns false and the previous value.
local function update_countdown(key)
	local prev_value = prevdata[key]
	if type(prev_value) == "number" then
		if prev_value > 0 then
			prevdata[key] = prev_value - 1
			return false, prev_value - 1
		else
			prevdata[key] = nil
			return true
		end
	end
	return false
end

-- If value is a number between min and max (inclusive), return value.
-- Otherwise, return fallback (or nil if unspecified)
local function value_in_range(value, min, max, fallback)
	if type(value) == 'number' and value >= min and value <= max then
		return value
	else
		return fallback
	end
end

-- Follow a 32-bit pointer chain, given a start address and a series of offsets.
-- Returns the final address in the chain, or nil if any addresses in the chain are invalid.
-- If restricted is true, only the typical address space 0x8000_0000-0x801F_FFFF is considered valid.
-- If restricted is false, other valid but uncommon ways to address ram are allowed.
function follow_psx_ptr(restricted, address, ...)
	if select('#', ...) == 0 then -- assume 0 offset if none are specified
		return follow_psx_ptr(restricted, address, 0)
	end

	-- PSX ram is mirrored at multiple locations, see https://psx-spx.consoledev.net/memorymap/
	-- BizHawk doesn't let us read from KSEG0/1 through the System Bus domain, so we need to mask out the segment and read from main memory.
	-- This might be a little bit overengineered for the common use case. Doesn't currently handle scratchpad (DCache) addresses.
	local function parse_address(address)
		local segment = (address & 0xE0000000) >> 28
		local phys_address = address & ~0xE0000000
		if not restricted and phys_address < 0x800000 then
			phys_address = phys_address % 0x200000
		end
		return phys_address, segment
	end
	local function is_valid(address, restricted)
		phys_address, segment = parse_address(address)
		return phys_address >= 0 and phys_address < 0x200000 and
			(segment == 0x8 or (not restricted and (segment == 0x0 or segment == 0xA)))
	end
	local function read_ptr(address)
		if address & 3 ~= 0 then -- unaligned read is invalid
			return math.mininteger
		end
		return mainmemory.read_u32_le((parse_address(address)))
	end

	if not is_valid(address) then
		error(string.format("Invalid PSX ram address 0x%.8X", address))
	end

	for i = 1, select('#', ...) do -- loop through offset varargs
		local offset = select(i, ...)
		address = read_ptr(address) + offset
		if not is_valid(address, restricted) then
			return nil
		end
	end
	return (parse_address(address)) -- need the () here to return only the first value
end

local function sml1_swap(gamemeta)
	return function()
		local size_changed, shrinking, prev_shrinking = update_prev('shrinking', gamemeta.getsmlsize())
		-- when this variable is 3, Mario is shrinking
		local lives_changed, lives, prev_lives = update_prev('lives', gamemeta.getlives())
		-- usual lives counter idea
		local game_over_changed, game_over_bar, prev_game_over_bar = update_prev('game_over_bar', gamemeta.getgameover() ~= 57)
		-- this variable goes to 57 to show the GAME OVER bar
		return
			(size_changed and shrinking == 3) or
			(lives_changed and lives < prev_lives) or
			(game_over_changed and game_over_bar)
	end
end

local function somari_swap(gamemeta)
	return function()
		local sprite_changed, sprite, prev_sprite = update_prev('sprite', gamemeta.getsprite())
		local shield_changed, shield, prev_shield = update_prev('shield', gamemeta.getshield())
		return
			(sprite_changed and sprite == 10 and shield_changed == false) or -- when this variable is 9, Somari hurt sprite is on
			(sprite_changed and prev_sprite == 09) -- we just transitioned from the "you died" sprite
	end
end

local function FamilyFeud_SNES_swap(gamemeta)
	return function()
		local strike_changed, strike, prev_strike = update_prev('strike', gamemeta.getstrike()) 
		local player_changed, player, prev_player = update_prev('player', gamemeta.getwhichplayer())
		return
			(strike_changed and strike == 1) and  -- we just got a strike or 0
			(player < 2), 30 -- It's player 1 or 2, not the CPU; give 30 frames of buzzer before and after (roughly) swaps
		end
	end

local function singleplayer_withlives_swap(gamemeta)
	return function(data)
		-- if a method is provided and we are not in normal gameplay, don't ever swap
		if gamemeta.gmode and not gamemeta.gmode() then
			return false
		end
		
		local p1currhp = gamemeta.p1gethp()
		local p1currlc = gamemeta.p1getlc()
		local currtogglecheck = 0
		if gamemeta.gettogglecheck ~= nil then
			currtogglecheck = gamemeta.gettogglecheck()
		end
		
		local maxhp = gamemeta.maxhp()
		local minhp = gamemeta.minhp or 0

		-- health must be within an acceptable range to count
		-- ON ACCOUNT OF ALL THE GARBAGE VALUES BEING STORED IN THESE ADDRESSES
		if p1currhp < minhp or p1currhp > maxhp then
			return false
		end

		-- retrieve previous health and lives before backup
		local p1prevhp = data.p1prevhp
		local p1prevlc = data.p1prevlc
		local prevtogglecheck = data.prevtogglecheck

		data.p1prevhp = p1currhp
		data.p1prevlc = p1currlc
		data.prevtogglecheck = currtogglecheck
		
		-- if we have found a toggle flag, that changes at the same time as a junk hp/lives change, then don't swap.
		if prevtogglecheck ~= nil and prevtogglecheck ~= currtogglecheck then
			return false
		end

		-- Sometimes you will want to update hp and lives without triggering a swap (e.g., on swapping between characters).
		-- If a method is provided for swap_exceptions and its conditions are true, process the hp and lives but don't swap.
		if gamemeta.swap_exceptions and gamemeta.swap_exceptions(gamemeta) then
			return false
		end
		
		-- this delay ensures that when the game ticks away health for the end of a level,
		-- we can catch its purpose and hopefully not swap, since this isnt damage related
		if data.p1hpcountdown ~= nil and data.p1hpcountdown > 0 then
			data.p1hpcountdown = data.p1hpcountdown - 1
			if data.p1hpcountdown == 0 and p1currhp > minhp then
				return true
			end
		end
		
		-- if the health goes to 0, we will rely on the life count to tell us whether to swap
		if p1prevhp ~= nil and p1currhp < p1prevhp and p1currhp > minhp and p1currhp < maxhp then
			data.p1hpcountdown = gamemeta.delay or 3
		end

		-- check to see if the life count went down
		
		if p1prevlc ~= nil and p1currlc == p1prevlc - 1 then
			-- MUST CHECK THAT LIVES ALWAYS GO DOWN BY 1. BUT THIS SHOULD HELP REMOVE NONSENSE SWAPS
			return true
		end

		-- sometimes you want to swap for things that don't take standard health or lives, like non-standard game overs
		if gamemeta.other_swaps and gamemeta.other_swaps() then
			data.p1hpcountdown = gamemeta.delay or 3
		end
		
		return false
	end
end

local function supermetroid_swap(gamemeta)
	return function()
		local hp_changed, currhp, prev_hp = update_prev('hp', gamemeta.gethp())
		local invuln_changed, invuln, prev_invuln = update_prev('invuln', gamemeta.getinvuln())
		-- when this variable is over 0, i-frames are on
		local samusstate_changed, samusstate, prevsamusstate = update_prev('samusstate', gamemeta.getsamusstate())
		-- this variable covers Samus states like saving, dying, normal gameplay, etc.

		return
			(invuln_changed and prev_invuln == 0 and currhp > 0 and hp_changed)
			-- i-frames just started, and we lost health on getting bumped (so, not for steam)
			or (samusstate_changed and samusstate == 25)
			-- Samus death animation just ended
	end
end

local function SMZ3_swap(gamemeta)
	return function(data)
		-- if a method is provided and we are not in normal gameplay, don't ever swap
		if gamemeta.gmode and not gamemeta.gmode() then
			return false
		end
		
		local currlinkhp = gamemeta.getlinkhp()
		local currlinklc = gamemeta.getlinklc()
		local currwhichgame = gamemeta.getwhichgame()

		local samushp_changed, currsamushp, samusprev_hp = update_prev('samushp', gamemeta.getsamushp())
		local invuln_changed, invuln, prev_invuln = update_prev('invuln', gamemeta.getinvuln())
		-- when this variable is over 0, i-frames are on
		local samusstate_changed, samusstate, prevsamusstate = update_prev('samusstate', gamemeta.getsamusstate())
		-- this variable covers Samus states like saving, dying, normal gameplay, etc.	
		
		local maxhp = gamemeta.maxhp()
		local minhp = gamemeta.minhp or 0
		
		-- Samus swaps
		if currwhichgame == 255 and
			((invuln_changed and prev_invuln == 0 and currsamushp > 0 and samushp_changed)
			-- i-frames just started and lost health
			or (samusstate_changed and samusstate == 25))
			-- Samus death animation just ended
		then
			return true
		end

		-- other swaps are geared toward LTTP specifically

		-- health must be within an acceptable range to count
		-- ON ACCOUNT OF ALL THE GARBAGE VALUES BEING STORED IN THESE ADDRESSES
		if currwhichgame == 0 and (currlinkhp < minhp or currlinkhp > maxhp) then
			return false
		end

		-- retrieve previous health and lives before backup
		local prevlinkhp = data.prevlinkhp
		local prevlinklc = data.prevlinklc
		local prevwhichgame = data.prevwhichgame
		
		data.prevlinkhp = currlinkhp
		data.prevlinklc = currlinklc
		data.prevwhichgame = currwhichgame

		-- DO NOT SWAP ON GAME CHANGE
		if prevwhichgame ~= nil and prevwhichgame ~= currwhichgame then
			return false
		end

		-- this delay ensures that when the game ticks away health for the end of a level,
		-- we can catch its purpose and hopefully not swap, since this isnt damage related
		if currwhichgame == 0 then
			if data.p1hpcountdown ~= nil and data.p1hpcountdown > 0 then
				data.p1hpcountdown = data.p1hpcountdown - 1
				if data.p1hpcountdown == 0 and currlinkhp > minhp then
					return true
				end
			end
			
			-- if the health goes to 0, we will rely on the life count to tell us whether to swap
			if prevlinkhp ~= nil and currlinkhp < prevlinkhp then
				data.p1hpcountdown = gamemeta.delay or 3
			end

			-- check to see if the life count went down
			
			if prevlinklc ~= nil and currlinklc < prevlinklc then
				return true
			end

		end
		
		return false
	end
end

local function twoplayers_withlives_swap(gamemeta)
	return function(data)
		-- if a method is provided and we are not in normal gameplay, don't ever swap
		if gamemeta.gmode and not gamemeta.gmode() then
			return false
		end

		local p1currhp = gamemeta.p1gethp()
		local p1currlc = gamemeta.p1getlc()
		local p2currhp = gamemeta.p2gethp()
		local p2currlc = gamemeta.p2getlc()
		local currtogglecheck = 0
		if gamemeta.gettogglecheck ~= nil then
			currtogglecheck = gamemeta.gettogglecheck()
		end
		
		-- we should now be able to use the typical shuffler functions normally.

		local maxhp = gamemeta.maxhp()
		local minhp = gamemeta.minhp or 0

		-- health must be within an acceptable range to count
		-- ON ACCOUNT OF ALL THE GARBAGE VALUES BEING STORED IN THESE ADDRESSES
		if p1currhp < minhp or p1currhp > maxhp then
			return false
		elseif p2currhp < minhp or p2currhp > maxhp then
			return false
		end

		-- retrieve previous health and lives before backup
		local p1prevhp = data.p1prevhp
		local p1prevlc = data.p1prevlc
		local p2prevhp = data.p2prevhp
		local p2prevlc = data.p2prevlc
		local prevtogglecheck = data.prevtogglecheck

		data.p1prevhp = p1currhp
		data.p1prevlc = p1currlc
		data.p2prevhp = p2currhp
		data.p2prevlc = p2currlc
		data.prevtogglecheck = currtogglecheck
		
		
		-- if we have found a toggle flag, that changes at the same time as a junk hp/lives change, then don't swap.
		if prevtogglecheck ~= nil and prevtogglecheck ~= currtogglecheck then
			return false
		end

		-- Sometimes you will want to update hp and lives without triggering a swap (e.g., on swapping between characters).
		-- If a method is provided for swap_exceptions and its conditions are true, process the hp and lives but don't swap.
		if gamemeta.swap_exceptions and gamemeta.swap_exceptions(gamemeta) then
			return false
		end

		-- this delay ensures that when the game ticks away health for the end of a level,
		-- we can catch its purpose and hopefully not swap, since this isnt damage related
		if data.p1hpcountdown ~= nil and data.p1hpcountdown > 0 then
			data.p1hpcountdown = data.p1hpcountdown - 1
			if data.p1hpcountdown == 0 and p1currhp > minhp then
				return true
			end
		end

		if data.p2hpcountdown ~= nil and data.p2hpcountdown > 0 then
			data.p2hpcountdown = data.p2hpcountdown - 1
			if data.p2hpcountdown == 0 and p2currhp > minhp then
				return true
			end
		end

		-- if the health goes to 0, we will rely on the life count to tell us whether to swap
		if p1prevhp ~= nil and p1currhp < p1prevhp and p1currhp > minhp and p1currhp < maxhp then
			data.p1hpcountdown = gamemeta.delay or 3
		end
		
		if p2prevhp ~= nil and p2currhp < p2prevhp and p2currhp > minhp and p2currhp < maxhp then
			data.p2hpcountdown = gamemeta.delay or 3
		end

		-- check to see if the life count went down
		
		if p1prevlc ~= nil and p1currlc == p1prevlc - 1 then
			return true
		end
		
		if p2prevlc ~= nil and p2currlc == p2prevlc - 1 then
			return true
		end

		-- sometimes you want to swap for things that don't take standard health or lives, like non-standard game overs
		if gamemeta.other_swaps and gamemeta.other_swaps() then
			data.p1hpcountdown = gamemeta.delay or 3
			data.p2hpcountdown = gamemeta.delay or 3
		end

		return false
	end
end

local function SMAS_swap(gamemeta)
	return function(data)
		-- if a method is provided and we are not in normal gameplay, don't ever swap
		if gamemeta.gmode and not gamemeta.gmode() then
			return false
		end

		local p1currhp = gamemeta.p1gethp()
		local p1currlc = gamemeta.p1getlc()
		local p2currhp = gamemeta.p2gethp()
		local p2currlc = gamemeta.p2getlc()
		local currsmb2mode = gamemeta.getsmb2mode()
		local currtogglecheck = 0
		if gamemeta.gettogglecheck ~= nil then
			currtogglecheck = gamemeta.gettogglecheck()
		end
		
		-- we should now be able to use the typical shuffler functions normally.

		local maxhp = gamemeta.maxhp()
		local minhp = gamemeta.minhp or 0

		-- health must be within an acceptable range to count
		-- ON ACCOUNT OF ALL THE GARBAGE VALUES BEING STORED IN THESE ADDRESSES
		if p1currhp < minhp or p1currhp > maxhp then
			return false
		elseif p2currhp < minhp or p2currhp > maxhp then
			return false
		end

		-- retrieve previous health and lives before backup
		local p1prevhp = data.p1prevhp
		local p1prevlc = data.p1prevlc
		local p2prevhp = data.p2prevhp
		local p2prevlc = data.p2prevlc
		local prevsmb2mode = data.prevsmb2mode
		local prevtogglecheck = data.prevtogglecheck
		
		data.p1prevhp = p1currhp
		data.p1prevlc = p1currlc
		data.p2prevhp = p2currhp
		data.p2prevlc = p2currlc
		data.prevsmb2mode = currsmb2mode
		data.prevtogglecheck = currtogglecheck
		
		-- DON'T SWAP WHEN WE JUST CAME OUT OF SMB2 SLOTS OR MENU
		if currsmb2mode ~= prevsmb2mode then
			return false
		end
		
		--if we have found a toggle flag, that changes at the same time as a junk hp/lives change, then don't swap.
		if prevtogglecheck ~= nil and prevtogglecheck ~= currtogglecheck then
			return false
		end

		-- this delay ensures that when the game ticks away health for the end of a level,
		-- we can catch its purpose and hopefully not swap, since this isnt damage related
		if data.p1hpcountdown ~= nil and data.p1hpcountdown > 0 then
			data.p1hpcountdown = data.p1hpcountdown - 1
			if data.p1hpcountdown == 0 and p1currhp > minhp then
				return true
			end
		end

		if data.p2hpcountdown ~= nil and data.p2hpcountdown > 0 then
			data.p2hpcountdown = data.p2hpcountdown - 1
			if data.p2hpcountdown == 0 and p2currhp > minhp then
				return true
			end
		end

		-- if the health goes to 0, we will rely on the life count to tell us whether to swap
		if p1prevhp ~= nil and p1currhp < p1prevhp then
			data.p1hpcountdown = gamemeta.delay or 3
		end
		
		if p2prevhp ~= nil and p2currhp < p2prevhp then
			data.p2hpcountdown = gamemeta.delay or 3
		end

		-- check to see if the life count went down
		
		if p1prevlc ~= nil and p1currlc == p1prevlc - 1 then
			return true
		end
		
		if p2prevlc ~= nil and p2currlc == p2prevlc - 1 then
			return true
		end

		return false
	end
end

local function sdbnes_swap(gamemeta)
	return function(data)
		-- if a method is provided and we are not in normal gameplay, don't ever swap
		if gamemeta.gmode and not gamemeta.gmode() then
			return false
		end

		local currhowmanyplayers = gamemeta.gethowmanyplayers()
		local currmode = gamemeta.getmode()
		local p1currhp1 = gamemeta.p1gethp1()
		local p1currhp2 = gamemeta.p1gethp2()
		local p1currhp3 = gamemeta.p1gethp3()
		local p2currhp1 = gamemeta.p2gethp1()
		local p2currhp2 = gamemeta.p2gethp2()
		local p2currhp3 = gamemeta.p2gethp3()
		local p1currbbplayer = gamemeta.p1getbbplayer()
		local p2currbbplayer = gamemeta.p2getbbplayer()
		
		local maxhp = gamemeta.maxhp()
		local minhp = gamemeta.minhp or 0
		
		-- health must be within an acceptable range to count
		-- ON ACCOUNT OF ALL THE GARBAGE VALUES BEING STORED IN THESE ADDRESSES
		
		-- NOTE: IN SDB, ONLY p1currhp1 and p1currbbplayer seem to inherit garbage values
		
		if p1currhp1 < minhp or (p1currhp1 > maxhp and currmode < 2) then
			return false
		elseif p1currbbplayer > 33 and currmode == 2 then
			-- highest value for this is 33
			return false
		end
		
		local p1currhp = p1currhp1 + p1currhp2 + p1currhp3 -- team 1
		local p2currhp = p2currhp1 + p2currhp2 + p2currhp3 -- team 2
		
		-- consider transforming the player to 1-6 to make this easy to look up.
		
		local beanballplayerhps = {
		memory.read_u8(0x0323, "RAM"),
		memory.read_u8(0x0393, "RAM"),
		memory.read_u8(0x0403, "RAM"),
		memory.read_u8(0x035B, "RAM"),
		memory.read_u8(0x03CB, "RAM"),
		memory.read_u8(0x043B, "RAM"),
		}
		
		-- 0 for 1, 16 for 2, 32 for 3, 1 for 4, 17 for 5, 33 for 6
		local p1currhpbb= beanballplayerhps[p1currbbplayer]
		local p2currhpbb= beanballplayerhps[p2currbbplayer]
		-- sub in the bb healths if we are in bb
		
		if currmode == 2 then
			p1currhp = p1currhpbb
			if currhowmanyplayers == 2 then
				p2currhp = p2currhpbb
			else
				p2currhp = 0
			end
		end

		-- retrieve previous health and mode/player info from before backup
		
		local prevhowmanyplayers = data.prevhowmanyplayers
		local prevmode = data.prevmode
		local p1prevhp = data.p1prevhp
		local p2prevhp = data.p2prevhp
		local p1prevbbplayer = data.p1prevbbplayer
		local p2prevbbplayer = data.p2prevbbplayer

		data.prevhowmanyplayers = currhowmanyplayers
		data.prevmode = currmode
		data.p1prevhp = p1currhp
		data.p2prevhp = p2currhp
		data.p1prevbbplayer = p1currbbplayer
		data.p2prevbbplayer = p2currbbplayer

		-- this delay ensures that when the game ticks away health for the end of a level,
		-- we can catch its purpose and hopefully not swap, since this isnt damage related
		if data.p1hpcountdown ~= nil and data.p1hpcountdown > 0 then
			data.p1hpcountdown = data.p1hpcountdown - 1
			if data.p1hpcountdown == 0 and p1currhp > minhp then
				return true
			end
		end

		if data.p2hpcountdown ~= nil and data.p2hpcountdown > 0 then
			data.p2hpcountdown = data.p2hpcountdown - 1
			if data.p2hpcountdown == 0 and p2currhp > minhp and currhowmanyplayers == 2
			then
				return true
			end
		end

		-- if the health goes to 0, we will rely on the life count to tell us whether to swap
		if p1prevhp ~= nil and p1currhp ~= nil and p1currhp < p1prevhp then
			data.p1hpcountdown = gamemeta.delay or 3
		end
		
		if p2prevhp ~= nil and p2currhp ~= nil and p2currhp < p2prevhp and currhowmanyplayers == 2
		then
			data.p2hpcountdown = gamemeta.delay or 3
		end

		return false
	end
end

local function antic_swap(gamemeta)
	return function(data)
		-- We will swap on 3 scenarios. They work across all players.
		-- 1. There is a specific address that goes to 192 when a human player gets a letter wrong,
		-- then ticks down frame by frame to 0 or 16. Never moves up otherwise.
		-- 2. There is an address that counts down the die from 6 to 0.
		-- When you run out of time, this value hits 0, and you should swap.
		-- 3. There is an address that counts down the time to type in a guess.
		-- A CPU player will always provide a correct answer when this activates.
		-- However, when a human player runs out of time, this hits 0, then goes to 255.
		-- This should swap on 255, IGNORING the title screen.
		-- THESE VARIABLES ARE SHARED IN MULTIPLAYER YAY
		
		-- 4. We can now swap on a correct computer answer.
		-- Found value that is "who buzzed in"
		-- Found value for "faded out with correct answer," rolls up from 0 to 31
		-- if the computer rang in, and that value increases to 31, SWAP
		
		-- human player value 00AC can be 1, 2, 3, 4
		
		-- when who buzzed in > than 00AC, then we should swap if they get it right

		local _, currbotchedletter, prevbotchedletter = update_prev('botched_letter', gamemeta.getbotchedletter())
		local _, currbuzzintime, prevbuzzintime = update_prev('buzz_in_time', gamemeta.getbuzzintime())
		local _, currtypetime, prevtypetime = update_prev('type_time', gamemeta.gettypetime())
		local _, curranswerright, prevanswerright = update_prev('answer_right', gamemeta.getanswerright())

		-- wrong letter
		if prevbotchedletter ~= nil and currbotchedletter > prevbotchedletter then
			-- remember, only goes up when a wrong answer is guessed.
			return true
		end
		
		-- ran out of time to buzz in (ranges from 0-6, resets to 6 once the die appears, shuffle on drop to 0)
		if memory.read_u8(0x046E, "RAM") <= -- who rang in, defaults to 0
			memory.read_u8(0x00AC, "RAM") -- how many humans, defaults to 1 - so, not a computer player being award spaces
			and prevbuzzintime ~= nil and prevbuzzintime ~= 255
			and currbuzzintime < prevbuzzintime -- it'll stay on 0 for a while.
			and currbuzzintime == 0
		then
			-- NOTE: will reset to 0 also when all human players are out of guesses and no one else can answer.
			-- We don't want a second swap in those cases.
			-- In this case, currbotchedletter will == 0 or 16, and guess time will be < 25.
			if currtypetime < 25 and (currbotchedletter == 0 or currbotchedletter == 16) then
				return false
			end
			
			return true
		end
		
		-- ran out of time to type answer (ranges from 0-25, goes to 255 when timer is completely done)
		if prevtypetime ~= nil and prevtypetime == 0 and currtypetime == 255 then
			-- it'll stay on 255 for a while.
			return true
		end
		
		-- CPU correct answer swap
		if memory.read_u8(0x046E, "RAM") > -- who rang in, defaults to 0
			memory.read_u8(0x00AC, "RAM") -- how many humans, defaults to 1
			and prevanswerright ~= nil
			and curranswerright > prevanswerright -- this value rolls up when a card is awarded
			and curranswerright == 31 -- and hits 31 at max
		then
			return true -- swap!
		end

		return false
	end
end

local function smb3_swap(gamemeta)
	return function()
		-- if this address goes up from 0, invuln frames just got triggered.
		local invuln_changed, invuln_curr, invuln_prev = update_prev('invuln_curr', gamemeta.getinvuln())
		local boot_changed, boot = update_prev('boot', gamemeta.getboot()) -- Kuribo's shoe status
		local statue_changed, statue = update_prev('statue', gamemeta.getstatue()) -- tanooki statue status
		
		local p1_lives_changed, p1_lives_curr, p1_lives_prev = update_prev('p1_lives_curr', gamemeta.p1getlc())
		local p2_lives_changed, p2_lives_curr, p2_lives_prev = update_prev('p2_lives_curr', gamemeta.p2getlc())
		
		-- this will return whether we are in the 2p card battle (true/false)
		local smb3battling_changed, smb3battling_curr, smb3battling_prev = update_prev('smb3battling_curr', gamemeta.getsmb3battling())
		
		return (smb3battling_changed -- mode changed to/from active gameplay
				and smb3battling_prev == true) -- we were just in battle mode)
			or (invuln_changed and invuln_prev == 0 and not boot_changed and statue == 0)
			-- boot_changed if we dropped out of boot status, statue > 0 if statue timer counting down
			or (p1_lives_changed and p1_lives_curr < p1_lives_prev)
			or (p2_lives_changed and p2_lives_curr < p2_lives_prev)
	end
end

local function smk_swap(gamemeta)
	return function()
		local _, inbattlemode = update_prev('battlemode', gamemeta.getmode() == 14)
		-- battle mode == 14, if we are in battle mode, then "falls" shouldn't shuffle because they don't deduct HP
		
		local p1bumping, p1currbump, p1prevbump = update_prev('p1currbump', gamemeta.p1getbump())
		-- if > 0, p1 is colliding with something
		local p1coinschanged, p1currcoins, p1prevcoins = update_prev('p1currcoins', gamemeta.p1getcoins())
		-- coin count p1 - if goes down on bump, we'll swap (NOT ON LAKITU FEE)
		local p1spinningout, p1currspinout, p1prevspinout = update_prev('p1currspinout',
			-- if we start spinning out after a collision, swap (NOT ON BAD DRIFT)
			(gamemeta.p1getspinout() == 12 or -- crash
			gamemeta.p1getspinout() == 14 or -- spin out left
			gamemeta.p1getspinout() == 16 or -- spin out right
			gamemeta.p1getspinout() == 26)) -- also crash
		local p1falling, p1currfall, p1prevfall = update_prev('p1currfall', gamemeta.p1getfall() > 2)
		-- >2 means you fell, 4 for pit, 6 for lava, 8 for water
		local p1shrinking, p1currshrink, p1prevshrink = update_prev('p1currshrink', gamemeta.p1getshrink())
		-- if > 0, you are shrinking, then it counts down to 0
		local p1moled, p1currmoled, p1prevmoled = update_prev('p1currmoled', gamemeta.p1getmoled() >= 152)
		-- if >= 152, a mole just hopped on you, when off it drops to 24, then 0
		local _, p1finished = update_prev('p1finished', gamemeta.p1getfinished() == 120)
		-- 120 means last lap completed in a race
		
		local p2bumping, p2currbump, p2prevbump = update_prev('p2currbump', gamemeta.p2getbump())
		-- if > 0, p2 is colliding with something
		local p2coinschanged, p2currcoins, p2prevcoins = update_prev('p2currcoins', gamemeta.p2getcoins())
		-- coin count p2 - if goes down on bump, we'll swap (NOT ON LAKITU FEE)
		local p2spinningout, p2currspinout, p2prevspinout = update_prev('p2currspinout',
			-- if we start spinning out after a collision, swap (NOT ON BAD DRIFT)
			(gamemeta.p2getspinout() == 12 or -- crash
			gamemeta.p2getspinout() == 14 or -- spin out left
			gamemeta.p2getspinout() == 16 or -- spin out right
			gamemeta.p2getspinout() == 26)) -- also crash
		local p2falling, p2currfall, p2prevfall = update_prev('p2currfall', gamemeta.p2getfall() > 2)
		-- >2 means you fell, 4 for pit, 6 for lava, 8 for water
		local p2shrinking, p2currshrink, p2prevshrink = update_prev('p2currshrink', gamemeta.p2getshrink())
		-- if > 0, you are shrinking, then it counts down to 0
		local p2moled, p2currmoled, p2prevmoled = update_prev('p2currmoled', gamemeta.p2getmoled() >= 152)
		-- if >= 152, a mole just hopped on you, when off it drops to 24, then 0
		local _, p2finished = update_prev('p2finished', gamemeta.p2getfinished() == 120)
		-- 120 means last lap completed in a race
		
		local p2IsActive = gamemeta.p2getIsActive()
		-- 2p variables still get updated even if 2p is CPU, so we have to ignore all of those unless we are in 2p mode.
		
		return 
			p1finished == false -- haven't crossed finish line already in a race
			and (
				(p1falling and p1currfall and not inbattlemode) -- p1 just started falling into pit, lava, water outside of battle
				-- or (p1shrinking and p1prevshrink == 0) -- p1 just started shrinking, or got run over so frame timer dropped more than 1 unit
				or (p1moled and p1currmoled) -- p1 just started shrinking
				or (p1bumping and -- p1 just started colliding AND EITHER
					((p1coinschanged and p1currcoins < p1prevcoins) -- coins dropped or
					or (p1currcoins == 0 and p1spinningout)) -- no coins and we just started spinning out
					or p1prevbump == 0 and p1currbump > 200) -- bump value goes this high when squished
				)
			or
			p2IsActive == true and (
				p2finished == false -- haven't crossed finish line already in a race
				and (
					(p2falling and p2currfall and not inbattlemode) -- p2 just started falling into pit, lava, water outside of battle
					-- or (p2shrinking and p2prevshrink == 0) -- p2 just started shrinking, or got run over so frame timer dropped more than 1 unit
					or (p2moled and p2currmoled) -- p2 just started shrinking
					or (p2bumping and -- p2 just started colliding AND EITHER
						((p2coinschanged and p2currcoins < p2prevcoins) -- coins dropped or
						or (p2currcoins == 0 and p2spinningout)) -- no coins and we just started spinning out
						or p2prevbump == 0 and p2currbump > 200) -- bump value goes this high when squished
					)
				)
	end
end

local function fzero_snes_swap(gamemeta)
	-- alternative option for F-Zero swapping, currently testing this out
	-- 0x00F5 is "collided with a wall", pops up to 9 then drops by 1 every frame back down to 0.
	-- We don't want a swap on just being "in" the wall or grazing it, necessarily.
	-- 0x00E9 is "hitting a guardrail" and is separate from colliding with the wall.
	-- So, you can say "no swaps" on hitting a guardrail == true when colliding with wall == false.
	-- can experiment with "invuln frames just popped from 0" AND either wall bump or other bump?
	return function()
		if 	memory.read_u8(0x0054, "WRAM") == 2 -- gamestate = "racing," and
			and memory.read_u8(0x0055, "WRAM") == 3 -- the race has started, and
			and memory.read_u8(0x00C8, "WRAM") == 0 -- invulnerability frames are done (0)
		then
			return false -- don't swap when all of those are true	
		end
		
		local hitwall_changed, hittingwall, prev_hittingwall = update_prev('hittingwall', gamemeta.gethittingwall())
		-- when this variable pops up from 0, you're hitting a wall.
		local invuln_changed, invuln, prev_invuln = update_prev('invuln', gamemeta.getinvuln())
		-- this pops up from 0 if you get i-frames, only goes up slightly for being in a wall
		local bump_changed, bump, prev_bump = update_prev('bump', gamemeta.getbump())
		-- this variable pops up if you are bounced by another car, a mine, etc.

		return
			(hitwall_changed and prev_hittingwall == 0) or
			(invuln_changed and invuln > prev_invuln and invuln >6) or
			(bump_changed and prev_bump == 0)
	end
end

local function Monopoly_NES_swap(gamemeta)
	-- goals: swap when you lose money, go to jail, or go bankrupt
	-- don't swap if: setting options at start of game, buying a property, winning an auction, trading, building on a property	
	return function(data)

		local _, currInEditor, prevInEditor = update_prev('in_editor', gamemeta.getInEditor())

		-- this needs cleanup with a table or something
		
		local _, p1currHuman, p1prevHuman = update_prev('p1_human', gamemeta.getp1Human())
		local _, p2currHuman, p2prevHuman = update_prev('p2_human', gamemeta.getp2Human())
		local _, p3currHuman, p3prevHuman = update_prev('p3_human', gamemeta.getp3Human())
		local _, p4currHuman, p4prevHuman = update_prev('p4_human', gamemeta.getp4Human())
		local _, p5currHuman, p5prevHuman = update_prev('p5_human', gamemeta.getp5Human())
		local _, p6currHuman, p6prevHuman = update_prev('p6_human', gamemeta.getp6Human())
		local _, p7currHuman, p7prevHuman = update_prev('p7_human', gamemeta.getp7Human())
		local _, p8currHuman, p8prevHuman = update_prev('p8_human', gamemeta.getp8Human())
		
		local _, p1currInJail, p1prevInJail = update_prev('p1_in_jail', gamemeta.getp1InJail())
		local _, p2currInJail, p2prevInJail = update_prev('p2_in_jail', gamemeta.getp2InJail())
		local _, p3currInJail, p3prevInJail = update_prev('p3_in_jail', gamemeta.getp3InJail())
		local _, p4currInJail, p4prevInJail = update_prev('p4_in_jail', gamemeta.getp4InJail())
		local _, p5currInJail, p5prevInJail = update_prev('p5_in_jail', gamemeta.getp5InJail())
		local _, p6currInJail, p6prevInJail = update_prev('p6_in_jail', gamemeta.getp6InJail())
		local _, p7currInJail, p7prevInJail = update_prev('p7_in_jail', gamemeta.getp7InJail())
		local _, p8currInJail, p8prevInJail = update_prev('p8_in_jail', gamemeta.getp8InJail())
		
		local _, p1currBankrupt, p1prevBankrupt = update_prev('p1_bankrupt', gamemeta.getp1Bankrupt())
		local _, p2currBankrupt, p2prevBankrupt = update_prev('p2_bankrupt', gamemeta.getp2Bankrupt())
		local _, p3currBankrupt, p3prevBankrupt = update_prev('p3_bankrupt', gamemeta.getp3Bankrupt())
		local _, p4currBankrupt, p4prevBankrupt = update_prev('p4_bankrupt', gamemeta.getp4Bankrupt())
		local _, p5currBankrupt, p5prevBankrupt = update_prev('p5_bankrupt', gamemeta.getp5Bankrupt())
		local _, p6currBankrupt, p6prevBankrupt = update_prev('p6_bankrupt', gamemeta.getp6Bankrupt())
		local _, p7currBankrupt, p7prevBankrupt = update_prev('p7_bankrupt', gamemeta.getp7Bankrupt())
		local _, p8currBankrupt, p8prevBankrupt = update_prev('p8_bankrupt', gamemeta.getp8Bankrupt())
		
		local _, p1currMoney, p1prevMoney = update_prev('p1_money', gamemeta.getp1Money())
		local _, p2currMoney, p2prevMoney = update_prev('p2_money', gamemeta.getp2Money())
		local _, p3currMoney, p3prevMoney = update_prev('p3_money', gamemeta.getp3Money())
		local _, p4currMoney, p4prevMoney = update_prev('p4_money', gamemeta.getp4Money())
		local _, p5currMoney, p5prevMoney = update_prev('p5_money', gamemeta.getp5Money())
		local _, p6currMoney, p6prevMoney = update_prev('p6_money', gamemeta.getp6Money())
		local _, p7currMoney, p7prevMoney = update_prev('p7_money', gamemeta.getp7Money())
		local _, p8currMoney, p8prevMoney = update_prev('p8_money', gamemeta.getp8Money())
		
		-- check all the property statuses
		-- each byte includes "owned," "owned by whom," "in a monopoly," "has buildings," "mortgaged," etc.
		-- these also, critically, change on the same frame as money changes
		
		local changedSpace01, currSpace01, prevSpace01 = update_prev('space_01', gamemeta.getSpace01())
		local changedSpace03, currSpace03, prevSpace03 = update_prev('space_03', gamemeta.getSpace03())
		local changedSpace05, currSpace05, prevSpace05 = update_prev('space_05', gamemeta.getSpace05())
		local changedSpace06, currSpace06, prevSpace06 = update_prev('space_06', gamemeta.getSpace06())
		local changedSpace08, currSpace08, prevSpace08 = update_prev('space_08', gamemeta.getSpace08())
		local changedSpace09, currSpace09, prevSpace09 = update_prev('space_09', gamemeta.getSpace09())
		local changedSpace11, currSpace11, prevSpace11 = update_prev('space_11', gamemeta.getSpace11())
		local changedSpace12, currSpace12, prevSpace12 = update_prev('space_12', gamemeta.getSpace12())
		local changedSpace13, currSpace13, prevSpace13 = update_prev('space_13', gamemeta.getSpace13())
		local changedSpace14, currSpace14, prevSpace14 = update_prev('space_14', gamemeta.getSpace14())
		local changedSpace15, currSpace15, prevSpace15 = update_prev('space_15', gamemeta.getSpace15())
		local changedSpace16, currSpace16, prevSpace16 = update_prev('space_16', gamemeta.getSpace16())
		local changedSpace18, currSpace18, prevSpace18 = update_prev('space_18', gamemeta.getSpace18())
		local changedSpace19, currSpace19, prevSpace19 = update_prev('space_19', gamemeta.getSpace19())
		local changedSpace21, currSpace21, prevSpace21 = update_prev('space_21', gamemeta.getSpace21())
		local changedSpace23, currSpace23, prevSpace23 = update_prev('space_23', gamemeta.getSpace23())
		local changedSpace24, currSpace24, prevSpace24 = update_prev('space_24', gamemeta.getSpace24())
		local changedSpace25, currSpace25, prevSpace25 = update_prev('space_25', gamemeta.getSpace25())
		local changedSpace26, currSpace26, prevSpace26 = update_prev('space_26', gamemeta.getSpace26())
		local changedSpace27, currSpace27, prevSpace27 = update_prev('space_27', gamemeta.getSpace27())
		local changedSpace28, currSpace28, prevSpace28 = update_prev('space_28', gamemeta.getSpace28())
		local changedSpace29, currSpace29, prevSpace29 = update_prev('space_29', gamemeta.getSpace29())
		local changedSpace31, currSpace31, prevSpace31 = update_prev('space_31', gamemeta.getSpace31())
		local changedSpace32, currSpace32, prevSpace32 = update_prev('space_32', gamemeta.getSpace32())
		local changedSpace34, currSpace34, prevSpace34 = update_prev('space_34', gamemeta.getSpace34())
		local changedSpace35, currSpace35, prevSpace35 = update_prev('space_35', gamemeta.getSpace35())
		local changedSpace37, currSpace37, prevSpace37 = update_prev('space_37', gamemeta.getSpace37())
		local changedSpace39, currSpace39, prevSpace39 = update_prev('space_39', gamemeta.getSpace39())
		
		-- start by ruling out times to swap
		if
			-- you are manually editing money before game
			currInEditor == 1 or
			-- any of the property values changed on the same frame
			changedSpace01 or changedSpace03 or
			changedSpace05 or changedSpace06 or
			changedSpace08 or changedSpace09 or
			changedSpace11 or changedSpace12 or
			changedSpace13 or changedSpace14 or
			changedSpace15 or changedSpace16 or
			changedSpace18 or changedSpace19 or
			changedSpace21 or changedSpace23 or
			changedSpace24 or changedSpace25 or
			changedSpace26 or changedSpace27 or
			changedSpace28 or changedSpace29 or
			changedSpace31 or changedSpace32 or
			changedSpace34 or changedSpace35 or
			changedSpace37 or changedSpace39 or
			-- there are no active players, like on final screen or menus
			((p1currBankrupt + p2currBankrupt + p3currBankrupt + p4currBankrupt +
				p5currBankrupt + p6currBankrupt + p7currBankrupt + p8currBankrupt) == 255*8)
		then
			return false
		end -- don't swap when any of those are true
		
		-- Now, we assume that money going down, player going bankrupt, player jail counter going up for a human means we swap

		-- implement delay so that we can catch the cause of the swap
		if data.p1countdown ~= nil and data.p1countdown > 0 then
			data.p1countdown = data.p1countdown - 1
			if data.p1countdown == 0 then
				return true
			end
		end
		
		if data.p2countdown ~= nil and data.p2countdown > 0 then
			data.p2countdown = data.p2countdown - 1
			if data.p2countdown == 0 then
				return true
			end
		end
	
		if data.p3countdown ~= nil and data.p3countdown > 0 then
			data.p3countdown = data.p3countdown - 1
			if data.p3countdown == 0 then
				return true
			end
		end
		
		if data.p4countdown ~= nil and data.p4countdown > 0 then
			data.p4countdown = data.p4countdown - 1
			if data.p4countdown == 0 then
				return true
			end
		end
		
		if data.p5countdown ~= nil and data.p5countdown > 0 then
			data.p5countdown = data.p5countdown - 1
			if data.p5countdown == 0 then
				return true
			end
		end
		
		if data.p6countdown ~= nil and data.p6countdown > 0 then
			data.p6countdown = data.p6countdown - 1
			if data.p6countdown == 0 then
				return true
			end
		end
		
		if data.p7countdown ~= nil and data.p7countdown > 0 then
			data.p7countdown = data.p7countdown - 1
			if data.p7countdown == 0 then
				return true
			end
		end
		
		if data.p8countdown ~= nil and data.p8countdown > 0 then
			data.p8countdown = data.p8countdown - 1
			if data.p8countdown == 0 then
				return true
			end
		end
		
		-- if money goes down, or jail counter goes up, or bankrupt hits true for a human, start the countdown
		if
			p1prevHuman ~= nil and p1currHuman == 0 and
			((p1prevMoney ~= nil and p1currMoney < p1prevMoney) or
			(p1prevInJail ~= nil and p1currInJail > p1prevInJail) or
			(p1prevBankrupt ~= nil and p1currBankrupt == 255 and p1prevBankrupt == 0)) == true
		then
			data.p1countdown = gamemeta.delay
		elseif
			p2prevHuman ~= nil and p2currHuman == 0 and
			((p2prevMoney ~= nil and p2currMoney < p2prevMoney) or
			(p2prevInJail ~= nil and p2currInJail > p2prevInJail) or
			(p2prevBankrupt ~= nil and p2currBankrupt == 255 and p2prevBankrupt == 0)) == true
		then
			data.p2countdown = gamemeta.delay
		elseif
			p3prevHuman ~= nil and p3currHuman == 0 and
			((p3prevMoney ~= nil and p3currMoney < p3prevMoney) or
			(p3prevInJail ~= nil and p3currInJail > p3prevInJail) or
			(p3prevBankrupt ~= nil and p3currBankrupt == 255 and p3prevBankrupt == 0)) == true
		then
			data.p3countdown = gamemeta.delay
		elseif
			p4prevHuman ~= nil and p4currHuman == 0 and
			((p4prevMoney ~= nil and p4currMoney < p4prevMoney) or
			(p4prevInJail ~= nil and p4currInJail > p4prevInJail) or
			(p4prevBankrupt ~= nil and p4currBankrupt == 255 and p4prevBankrupt == 0)) == true
		then
			data.p4countdown = gamemeta.delay
		elseif
			p5prevHuman ~= nil and p5currHuman == 0 and
			((p5prevMoney ~= nil and p5currMoney < p5prevMoney) or
			(p5prevInJail ~= nil and p5currInJail > p5prevInJail) or
			(p5prevBankrupt ~= nil and p5currBankrupt == 255 and p5prevBankrupt == 0)) == true
		then
			data.p5countdown = gamemeta.delay
		elseif
			p6prevHuman ~= nil and p6currHuman == 0 and
			((p6prevMoney ~= nil and p6currMoney < p6prevMoney) or
			(p6prevInJail ~= nil and p6currInJail > p6prevInJail) or
			(p6prevBankrupt ~= nil and p6currBankrupt == 255 and p6prevBankrupt == 0)) == true
		then
			data.p6countdown = gamemeta.delay
		elseif
			p7prevHuman ~= nil and p7currHuman == 0 and
			((p7prevMoney ~= nil and p7currMoney < p7prevMoney) or
			(p7prevInJail ~= nil and p7currInJail > p7prevInJail) or
			(p7prevBankrupt ~= nil and p7currBankrupt == 255 and p7prevBankrupt == 0)) == true
		then
			data.p7countdown = gamemeta.delay
		elseif
			p8prevHuman ~= nil and p8currHuman == 0 and
			((p8prevMoney ~= nil and p8currMoney < p8prevMoney) or
			(p8prevInJail ~= nil and p8currInJail > p8prevInJail) or
			(p8prevBankrupt ~= nil and p8currBankrupt == 255 and p8prevBankrupt == 0)) == true
		then
			data.p8countdown = gamemeta.delay
		end
	end
end

local function iframe_health_swap(gamemeta)
	return function(data)
		local iframes_changed, iframes_curr, iframes_prev = update_prev('iframes', gamemeta.get_iframes())
		local health_changed, health_curr, health_prev = false, 0, 0
		-- If a swap is already scheduled, decrease it but do no further processing.
		if data.delayCountdown ~= nil and data.delayCountdown > 0 then
			--console.log("delayCountdown: "..data.delayCountdown);
			data.delayCountdown = data.delayCountdown - 1
			if data.delayCountdown == 0 then
				--console.log("delayCountdown is 0; swapping");
				return true;
			end
			return false;
		end
		if gamemeta.get_health then
			health_changed, health_curr, health_prev = update_prev('health', gamemeta.get_health())
		end
		local iframe_minimum = 0
		if gamemeta.iframe_minimum then
			iframe_minimum = gamemeta.iframe_minimum()
		end
		-- check if we're in a valid gamestate
		if not gamemeta.is_valid_gamestate() then
			return false
		end
		-- assumptions: by default, the iframe counter is at 0
		-- if iframes > 0, you got hit
		-- some games will let you take damage on 1 iframe left
		-- (presumably, iframes go down to 0, then it checks for damage, then sets iframes back to max)
		-- certain games do damage over time using a short iframe timer, so check a minimum iframe count to shuffle
		local iframes_valid = iframes_changed and iframes_curr > iframes_prev and iframes_prev <= 1 and iframes_curr >= iframe_minimum
		if gamemeta.get_health then
			-- check 0 health for games that don't set iframes on death
			if (iframes_valid or health_curr == 0) and health_changed and health_curr < health_prev then
				data.delayCountdown = gamemeta.delay or 3
			end
		elseif iframes_valid then
			data.delayCountdown = gamemeta.delay or 3
		end
		-- sometimes you want to swap for things that don't give iframes and change health, like non-standard game overs
		if gamemeta.other_swaps() then
			data.delayCountdown = gamemeta.delay or 3
		end
	end
end

local function health_swap(gamemeta)
	return function(data)
		-- return without updating health values, 'batching' damage taken until this becomes false
		if gamemeta.suspend_updates and gamemeta.suspend_updates() then
			return false
		end
		-- for games where iframes are unhelpful
		local health_changed, health_curr, health_prev = update_prev('health', gamemeta.get_health())
		-- If a swap is already scheduled, decrease it but do no further processing.
		if data.delayCountdown ~= nil and data.delayCountdown > 0 then
			--console.log("delayCountdown: "..data.delayCountdown);
			data.delayCountdown = data.delayCountdown - 1
			if data.delayCountdown == 0 then
				--console.log("delayCountdown is 0; swapping");
				return true;
			end
			return false;
		end
		-- check if we're in a valid gamestate
		if not gamemeta.is_valid_gamestate() then
			return false
		end
		if health_changed and health_curr < health_prev then
			data.delayCountdown = gamemeta.delay or 3
		end
		-- sometimes you want to swap for things that don't reduce health
		if gamemeta.other_swaps() then
			data.delayCountdown = gamemeta.delay or 3
		end
	end
end

-- Credit to Rogue_Millipede for the basis of this code
local function sotn_swap(gamemeta)
	return function ()
		-- check if we're in a valid gamestate
		if not gamemeta.is_valid_gamestate() then
			return false
		end
		-- health must be within an acceptable range to count
		-- ON ACCOUNT OF ALL THE GARBAGE VALUES BEING STORED IN THESE ADDRESSES
		local max_health = gamemeta.max_health()
		local min_health = gamemeta.min_health or 0
		if gamemeta.get_health() < min_health or gamemeta.get_health() > max_health then
			return false
		end

		local health_changed, health_curr, health_prev = update_prev('health', gamemeta.get_health())
		local iframes_changed, iframes_curr, iframes_prev = update_prev('iframes', gamemeta.get_iframes())
		local state_changed, state_curr, state_prev = update_prev("player_state", gamemeta.get_player_state())
		local game_over_check_changed, game_over_check_curr, game_over_check_prev = update_prev("game_over_check", gamemeta.game_over_check())

		if ((health_changed and health_curr < health_prev) -- health went down
				or (gamemeta.stone_state and state_changed and state_curr == gamemeta.stone_state)) -- 0 damage, but player was petrified
			and iframes_changed and iframes_curr > iframes_prev -- I-frames went up (i.e.: it isn't water)
			and health_curr > min_health -- We didn't just die (delay until the game over check passes)
		then
			return true
		end

		if (game_over_check_changed and game_over_check_curr) then -- Game over is starting
			return true
		end

		return false -- Nothing that would change the game occurred
	end
end

local function jonathan_charlotte_swap(gamemeta)
	return function (data)
		-- wow! two iframe counters!
		local j_iframes_changed, j_iframes_curr, j_iframes_prev = update_prev('jonathan iframes', gamemeta.get_jonathan_iframes())
		local c_iframes_changed, c_iframes_curr, c_iframes_prev = update_prev('charlotte iframes', gamemeta.get_charlotte_iframes())
		local health_changed, health_curr, health_prev = update_prev('health', gamemeta.get_health())
		-- If a swap is already scheduled, decrease it but do no further processing.
		if data.delayCountdown ~= nil and data.delayCountdown > 0 then
			--console.log("delayCountdown: "..data.delayCountdown);
			data.delayCountdown = data.delayCountdown - 1
			if data.delayCountdown == 0 then
				--console.log("delayCountdown is 0; swapping");
				return true;
			end
			return false;
		end
		if not gamemeta.is_valid_gamestate() then
			return false
		end
		-- unlike Symphony, Portrait sets iframes on death, don't need to check for that
		if gamemeta.is_jonathan() and j_iframes_changed and j_iframes_prev <= 1
			and health_changed and health_curr < health_prev
		then
			-- jonathan!
			data.delayCountdown = gamemeta.delay or 3
		elseif not gamemeta.is_jonathan() and c_iframes_changed and c_iframes_prev <= 1
			and health_changed and health_curr < health_prev
		then
			-- charlotte!
			data.delayCountdown = gamemeta.delay or 3
		end
	end
end

local function damage_buffer_swap(gamemeta)
	return function (data)
		-- games that instead of decreasing health directly, set a "damage buffer" value that then decreases health per frame
		local iframes_changed, iframes_curr, iframes_prev = update_prev('iframes', gamemeta.get_iframes())
		local buffer_changed, buffer_curr, buffer_prev = update_prev('damage buffer', gamemeta.get_damage_buffer())
		-- If a swap is already scheduled, decrease it but do no further processing.
		if data.delayCountdown ~= nil and data.delayCountdown > 0 then
			--console.log("delayCountdown: "..data.delayCountdown);
			data.delayCountdown = data.delayCountdown - 1
			if data.delayCountdown == 0 then
				--console.log("delayCountdown is 0; swapping");
				return true;
			end
			return false;
		end
		if not gamemeta.is_valid_gamestate() then
			return false
		end
		if iframes_changed and iframes_prev == 0 and buffer_changed and buffer_curr > buffer_prev then
			-- if the buffer is very large, it may not hit 0 before iframes run out
			-- will this ever actually happen in practice? maybe not, but may as well future-proof this
			data.delayCountdown = gamemeta.delay or 3
		end
		-- sometimes you want to swap for things that don't reduce health
		if gamemeta.other_swaps() then
			data.delayCountdown = gamemeta.delay or 3
		end
	end
end

local function ocarina_swap(gamemeta)
	return function ()
		-- every version of ocarina of time has different memory addresses so it gets its own function
		-- so all the miscellaneous shuffle conditions only have to be written once
		-- local iframes_changed, iframes_curr, iframes_prev = update_prev('iframes', gamemeta.get_iframes())
		-- redeads don't do iframes, and while they set a "grabbed" variable on link,
		-- the same variable is set by dead hand's hands, which deal no damage and must be grabbed by to make it show up
		-- this same variable is also set by morpha, whose grab damage is much faster than redeads'
		-- shabom (bubbles in jabu) and big skulltulas set iframes 3 frames after damage and so don't shuffle
		-- so i guess we're back to ignoring iframes! this game
		-- i would really have liked to only shuffle once when initially grabbed by redead/morpha
		-- but that's part of the actor's data and i really don't want to deal with that
		local internal_health = gamemeta.get_health()
		-- 0x0: full heart
		-- 0x1-0x5: quarter heart
		-- 0x6-0xA: half heart
		-- 0xB-0xF: three quarter heart
		-- convert internal health to "quarter hearts displayed"
		-- to only shuffle when fire damage etc makes health visibly decrease
		local partialHeart = internal_health % 0x10
		local fullHearts = (internal_health - partialHeart) / 0x10
		if partialHeart == 0 then
			partialHeart = 0
		elseif partialHeart <= 5 then
			partialHeart = 1
		elseif partialHeart <= 10 then
			partialHeart = 2
		else
			partialHeart = 3
		end
		local health_curr = fullHearts * 4 + partialHeart
		local health_changed, _, health_prev = update_prev('health', health_curr)
		-- local link_grabbed = gamemeta.is_link_grabbed()
		-- local void_changed, void_curr, _ = update_prev('void', gamemeta.get_respawn_flag())
		-- 1: standard void out, 0xFF: dampe race void out, wallmaster
		-- 0xFE: ganon's tower collapse time up, sun's song in time-stopped area
		-- no longer needed since we no longer check iframes
		local savefile = gamemeta.get_savefile()
		-- 0-2 for save files 1-3, 255 on title/file select/etc
		local max_health = gamemeta.get_max_health()
		-- since all memory is 0 on reset, need a value that is not 0 during gameplay to check gamestate is valid
		local text_id_changed, text_id_curr, _ = update_prev('text id', gamemeta.get_text_id())
		-- 0 when no textbox present, otherwise the id of the textbox's text
		-- this won't play well with text randomization, or hacks that change which ids are used for certain things
		-- but it's a lot simpler than wading through n64 memory allocation to detect these conditions other ways
		if savefile >= 3 or max_health == 0 then
			return false
		end
		-- if ((iframes_changed and iframes_prev <= 1 and iframes_curr > iframes_prev) or health_curr == 0 or link_grabbed)
		if health_changed and health_curr < health_prev then
			return true, 15 -- ocarina updates health 9 whole frames before you actually see link get hit for some reason
			-- then add a bit extra so the player has time to notice the hit
			-- 9 "emulator frames", ocarina runs at 20 fps so 3 visible frames
		end
		-- volcano time up just sets health to 0, which shuffles
		-- gerudo spin attack that sends to jail deals damage and sets iframes as well
		-- the timer running out in ganon's tower collapse refills your health??? ok
		if text_id_changed
			and (text_id_curr == 0x702D -- caught by hyrule castle guard
				-- "Hey you! Stop! You, kid, over there!"
				or text_id_curr == 0x6000 -- caught by gerudo guard
				-- "Halt! Stay where you are!"
				or text_id_curr == 0x4082 -- fish escaped from hook
				-- "Hey, what happened? You lost it!"
				or text_id_curr == 0x203D -- lost first ingo horse race
				-- "Hee hee hee... Too bad for you! I get your 50 Rupees."
				or text_id_curr == 0x203E -- lost second ingo horse race
				-- "Wah ha hah! You're just a kid, after all!"
				or text_id_curr == 0x102D -- lost at ocarina memory game
				-- "Too bad...Heh heh!"
				or text_id_curr == 0x71AD -- lost at shooting gallery, zora diving game
				-- "Too bad! Practice hard and come back!"
				or text_id_curr == 0x2081 -- lost at cucco search game
				-- "Time's up! Too baaaaad!! These are some great Cuccos aren't they!"
				or text_id_curr == 0x71B0)-- trade item expired
				-- "Oh, no! Time's up!"
			-- bombchu bowling uses 0x001A "Do you want to play again?" for both losing and winning
		then
			return true, 60
		end
		return false
	end
end

local function Pebble_Beach_Golf_Links_swap(gamemeta)
	return function(data)
		-- If a swap is already scheduled, decrease it but do no further processing.
		if data.delayCountdown ~= nil and data.delayCountdown > 0 then
			--console.log("delayCountdown: "..data.delayCountdown);
			data.delayCountdown = data.delayCountdown - 1
			if data.delayCountdown == 0 then
				--console.log("delayCountdown is 0; swapping");
				return true;
			end
			return false;
		end

		if (gamemeta.gmode and not gamemeta.gmode()) then
			return false; -- Not actually in a round
		end
		local holeChanged, hole, prevHole = update_prev('hole', gamemeta.getHole());
		if (hole < 1 or hole > 18) then -- There are only 18 holes.
			return false;
		end
		if (holeChanged) then
			--console.log("Hole has changed from "..prevHole.." to "..hole.."; setting P1 strokes to 0");
			update_prev('p1HoleStrokes', 0); -- Reset this now before we actually care
		end
		local player1ScoreArray = gamemeta.getPlayer1Scores();
		local player1StrokesChanged, player1Strokes, prevPlayer1Strokes = update_prev('p1HoleStrokes', player1ScoreArray[hole]);
		if (player1StrokesChanged) then
			--console.log("P1 Strokes on hole "..hole.." has changed from "..prevPlayer1Strokes.." to "..player1Strokes);
		end
		if (player1StrokesChanged and (player1Strokes == (prevPlayer1Strokes + 1) or player1Strokes == (prevPlayer1Strokes + 2))) then
			data.delayCountdown = gamemeta.delay;
		end
	end
end

local function NBA_Jam_swap(gamemeta)
	return function(data)
		-- Swap if other team scores, quarter changes, or shot timer runs out while player is holding the ball
		local opposingTeamScoreChanged, opposingTeamScore, prevOpposingTeamScore = update_prev('opposingTeamScore', gamemeta.getOpposingTeamScore());
		local teamWithBallChanged, teamWithBall, prevTeamWithBall = update_prev('teamWithBall', gamemeta.getTeamWithBall());
		local shotClockChanged, shotClock, prevShotClock = update_prev('shotClock', gamemeta.getOpposingTeamScore());
		local shotClockViolationMessageTimerChanged, shotClockViolationMessageTimer, prevShotClockViolationMessageTimer = update_prev('shotClockViolationMessageTimer', gamemeta.getShotClockViolationMessageTimer());
		local quarterChanged, quarter, prevQuarter = update_prev('quarter', gamemeta.getQuarter());
		
		-- If quarter changed, swap immediately.
		if (quarterChanged and quarter == (prevQuarter+1)) then
			--console.log(string.format("Quarter went from %d to %d; swapping", prevQuarter, quarter));
			return true;
		end
		-- If a swap is already scheduled, decrease it but do no further processing.
		if data.delayCountdown ~= nil and data.delayCountdown > 0 then
			--console.log("delayCountdown: "..data.delayCountdown);
			data.delayCountdown = data.delayCountdown - 1
			if data.delayCountdown == 0 then
				--console.log("delayCountdown is 0; swapping");
				return true;
			end
			return false;
		end
		-- Don't do any further processing if the game mode is wrong.
		if (gamemeta.gmode and not gamemeta.gmode()) then
			return false;
		end
		-- If opposing team score went up, swap after a delay
		if (opposingTeamScoreChanged and opposingTeamScore > prevOpposingTeamScore) then
			--console.log(string.format("Opposing team score went from %d to %d; swapping in %d frames", prevOpposingTeamScore, opposingTeamScore, gamemeta.delay));
			data.delayCountdown = gamemeta.delay;
		end
		-- If "SHOT CLOCK VIOLATION" is flashing on-screen and the player's team had the ball, swap after a delay
		if (shotClockViolationMessageTimerChanged and shotClockViolationMessageTimer > prevShotClockViolationMessageTimer) then
			if (teamWithBall == 0 or (teamWithBall == -1 and teamWithBallChanged and prevTeamWithBall == 0)) then
				--console.log(string.format("Player held the ball too long without shooting; swapping in %d frames", gamemeta.delay));
				data.delayCountdown = gamemeta.delay;
			end
		end
	end
end

-- An entire clone of singleplayer_withlives_swap because RKA has to be SPECIAL
-- with everything it does vis-à-vis health and lives 😒
local function Rocket_Knight_Adventures_swap(gamemeta)
	return function(data)
		-- if a method is provided and we are not in normal gameplay, don't ever swap
		if gamemeta.gmode and not gamemeta.gmode() then
			--console.log("Not gamemode; skipping");
			return false
		end

		local p1currhp = gamemeta.p1gethp()
		local p1currlc = gamemeta.p1getlc()
		local currtogglecheck = 0
		if gamemeta.gettogglecheck ~= nil then currtogglecheck = gamemeta.gettogglecheck() end

		local maxhp = gamemeta.maxhp()

		-- health must be within an acceptable range to count
		-- ON ACCOUNT OF ALL THE GARBAGE VALUES BEING STORED IN THESE ADDRESSES
		-- but don't check minhp BECAUSE ANY NEGATIVE VALUE IS VALID IN THIS GAME
		if p1currhp > maxhp then
			--console.log("p1currhp ("..p1currhp..") > "..maxhp.."; skipping");
			return false
		end

		-- retrieve previous health and lives before backup
		local p1prevhp = data.p1prevhp
		local p1prevlc = data.p1prevlc
		local prevtogglecheck = data.prevtogglecheck

		data.p1prevhp = p1currhp
		data.p1prevlc = p1currlc
		data.prevtogglecheck = currtogglecheck

		--if we have found a toggle flag, that changes at the same time as a junk hp/lives change, then don't swap.
		if prevtogglecheck ~= nil and prevtogglecheck ~= currtogglecheck then return false end

		-- this delay ensures that when the game ticks away health for the end of a level,
		-- we can catch its purpose and hopefully not swap, since this isnt damage related
		if data.p1hpcountdown ~= nil and data.p1hpcountdown > 0 then
			data.p1hpcountdown = data.p1hpcountdown - 1
			--console.log("p1hpcountdown: "..data.p1hpcountdown);
			if data.p1hpcountdown == 0 and p1currhp >= 0 then
				--console.log("p1hpcountdown is 0; HP "..p1currhp.." >= 0, so swapping");
				return true
			end
		end

		-- if health goes below 0, we will rely on life count to tell us whether to swap
		if p1prevhp ~= nil and p1currhp < p1prevhp then
			data.p1hpcountdown = gamemeta.delay or 3
			--console.log("HP went from "..p1prevhp.." to "..p1currhp.."; setting p1hpcountdown to "..data.p1hpcountdown);
		end

		-- check to see if life count went down
		if p1prevlc ~= nil and p1currlc == p1prevlc - 1 then -- MUST CHECK THAT LIVES ALWAYS GO DOWN BY 1. BUT THIS SHOULD HELP REMOVE NONSENSE SWAPS
			--console.log("Lives went from "..p1prevlc.." to "..p1currlc..", so swapping");
			return true
		end

		--console.log("All good; health: "..p1currhp..", lives: "..p1currlc);
		return false
	end
end

-- 240p Suite on NES has a stopwatch, so you can force a swap within a second
-- Useful if you only have one real game to test swaps on
local function StopWatch_swap(gamemeta)
	return function()
		if gamemeta.gmode and not gamemeta.gmode() then
			return false
		end

		local secondsChanged, seconds, prevSeconds = update_prev('seconds', memory.read_u8(0x0029, "RAM"));
		if (secondsChanged) then return true end;
		return false;
	end
end

local function castlevania_n64_swap(gamemeta)
	return function(data)
		-- TODO: These games have poison DOTs. Every single tick would shuffle. Is that desirable?

		-- Derive the gamestate ID the way the game does, rather roundaboutly:
		-- a pointer to a RAM address with a pointer to ANOTHER RAM address with
		-- the data we seek 0x24 (36) bytes later. Memory management, everyone!
		local gamestate = nil
		local prevGamestate = nil
		local gamestateChanged = nil
		if gamemeta.gamestate_ptr_addr then
			local gamestate_ptr_addr = gamemeta.gamestate_ptr_addr();
			local gamestate_ptr = memory.read_u32_be(gamestate_ptr_addr & 0x7FFFFF, "RDRAM");
			gamestateChanged, gamestate, prevGamestate = update_prev('gamestate', memory.read_s32_be((gamestate_ptr + 0x24) & 0x7FFFFF, "RDRAM"));
		end
		-- Debug test
		--[[if gamestateChanged then
			if prevGamestate then
				console.log("Gamestate changed from "..prevGamestate.." to "..gamestate);
			else
				console.log("Gamestate changed to "..gamestate);
			end
		end]]
		-- If all the pieces are in place, check if we're in gameplay or are about to head to a Game Over
		if gamestate and ((gamemeta.gameplaymode and gamestate ~= gamemeta.gameplaymode())
				and (gamemeta.enteringgameovermode and gamestate ~= gamemeta.enteringgameovermode())) then
			return false -- Don't ever swap if we aren't doing either of those
		end

		local p1currhp = gamemeta.p1gethp()
		local maxhp = gamemeta.maxhp()
		local minhp = gamemeta.minhp or 0

		-- Health must be within an acceptable range to count
		if p1currhp < minhp or p1currhp > maxhp then
			return false
		end

		-- Retrieve previous health before backup
		local p1prevhp = data.p1prevhp
		-- Backup current health
		data.p1prevhp = p1currhp

		-- This delay is for games that tick away health at the end of a level.
		-- CV64 doesn't do that (in fact you GAIN health at level's end), but
		-- I'm too chicken to change it.
		if data.p1hpcountdown ~= nil and data.p1hpcountdown > 0 then
			data.p1hpcountdown = data.p1hpcountdown - 1
			--console.log("p1hpcountdown: "..data.p1hpcountdown);
			if data.p1hpcountdown == 0 and p1currhp > minhp then
				--console.log("p1hpcountdown is 0; HP "..p1currhp.." > "..minhp..", so swapping");
				return true
			end
			-- If health goes to 0, rely on whether we're going to the Game Over
			-- gamestate to tell us whether to swap
		end

		if p1prevhp ~= nil and p1currhp < p1prevhp then
			data.p1hpcountdown = gamemeta.delay or 3
			--console.log("HP went from "..p1prevhp.." to "..p1currhp.."; setting p1hpcountdown to "..data.p1hpcountdown);
		end

		-- Are we about to go to a Game Over state? Swap if we are!
		if gamestate and gamemeta.enteringgameovermode and gamemeta.gameplaymode and gamestateChanged
				and gamestate == gamemeta.enteringgameovermode() and prevGamestate == gamemeta.gameplaymode() then
			--console.log("Detected shift from gameplay to Game Over, so swapping");
			return true
		end

		return false
	end
end

local function mario_swap(gamemeta)
	return function(data)	
		
		-- swap function for mario-type games where you have a status value instead of health
		-- as not all status value decreases count as damage and zero may be a valid status,
		-- we consult damage_table to know what status changes we should swap for
		-- if getting hit in state x puts you in state y, damage_table[x] = y
		
		local lives_changed, lives, prev_lives = update_prev('lives', gamemeta.get_lives())
		local status_changed, status, prev_status = update_prev('status', gamemeta.get_status())
		
		-- check if we're in a valid gamestate
		if not gamemeta.is_valid_gamestate() then
			return false
		end
		
		-- did our status change actually count as damage
		if status_changed and gamemeta.damage_table[prev_status] == status then
			return true, gamemeta.delay
		end
		
		-- otherwise we swap on lives going down
		if lives_changed and lives < prev_lives then
			return true, gamemeta.delay
		end
		
		-- allow any custom overrides
		if gamemeta.other_swaps then
			local swap, delay = gamemeta.other_swaps()
			return swap, delay or gamemeta.delay
		end
		
		return false
	end
end

local function sonic_swap(gamemeta)
	return function(data)
--[[	Logic:
			Swap if I-frames went up AND (rings lost OR shield lost)
			Swap if lives go down by 1
		There's probably some extra niceties to consider like delaying the swap on life loss to account for fades, but just get this working first ]]

		-- Log changes even if we're not in the right game mode, so resets to 0 when the game isn't active don't shuffle
		local p1_rings_changed, p1_rings_curr, p1_rings_prev = update_prev('p1rings', gamemeta.get_rings())
		local p1_shield_changed, p1_shield_curr, p1_shield_prev = update_prev('p1shield', gamemeta.get_shield())
		local p1_lives_changed, p1_lives_curr, p1_lives_prev = update_prev('p1lives', gamemeta.get_lives())
		local p1_iframes_changed, p1_iframes_curr, p1_iframes_prev = update_prev('p1iframes', gamemeta.get_iframes())

		-- Debugging block
		--[[iframes_display_cond = (p1_iframes_changed and p1_iframes_curr > p1_iframes_prev)
		iframes_cond = (p1_iframes_curr ~= 0) -- I-frames are non-zero
		rings_cond = (p1_rings_changed and p1_rings_curr < p1_rings_prev)
		shield_cond = (p1_shield_changed and p1_shield_curr < p1_shield_prev)
		if (p1_rings_changed and p1_rings_curr == 0) then
			console.log("Rings: "..p1_rings_prev.." -> "..p1_rings_curr)
		end
		if (p1_shield_changed and p1_shield_curr == 0) then
			console.log("Shield: "..p1_shield_prev.." -> "..p1_shield_curr)
		end
		if (p1_iframes_changed and p1_iframes_curr > p1_iframes_prev) then
			console.log("I-Frames: "..p1_iframes_prev.." -> "..p1_iframes_curr)
		end
		if (p1_lives_changed and p1_lives_curr == p1_lives_prev - 1) then
			console.log("Lives: "..p1_lives_prev.." -> "..p1_lives_curr)
		end
		if (iframes_display_cond or rings_cond or shield_cond) then
			console.log("--------------------")
			console.log("Iframes non-zero: "..tostring(iframes_cond))
			console.log("Ring(s) lost: "..tostring(rings_cond))
			console.log("Shield lost: "..tostring(shield_cond))
			console.log("Overall: "..tostring(iframes_cond and (rings_cond or shield_cond)))
			if gamemeta.gmode then
				console.log("Valid Game Mode: "..tostring(gamemeta.gmode()))
			end
			console.log("")
		end]]

		-- if a method is provided and we are not in normal gameplay, don't ever swap
		if gamemeta.gmode and not gamemeta.gmode() then
			return false
		end

		if p1_iframes_curr ~= 0 -- I-frames non-zero
			and ( -- either of the below must be true, can't be a dummy knockback (which the games sometimes do)
				(p1_rings_changed and p1_rings_curr < p1_rings_prev) -- rings lost
				or (p1_shield_changed and p1_shield_curr < p1_shield_prev) -- shield lost
			) -- but also I-frames MUST be non-zero, i.e.: ring drain should not cause shuffles
		then
			return true
		end

		if (p1_lives_changed and p1_lives_curr == p1_lives_prev - 1) then -- Lives went down
			return true
		end

		return false
	end
end

local function iq_swap(gamemeta)
	return function(data)
		local p1_rows_changed, p1_rows_curr, p1_rows_prev = update_prev('p1_rows', gamemeta.get_rows())
		local p1_cube_limit_changed, p1_cube_limit_curr, p1_cube_limit_prev = update_prev('p1_cube_limit', gamemeta.get_cube_limit())
		local p1_gamemode_changed, p1_gamemode_curr, p1_gamemode_prev = update_prev('p1_gamemode', gamemeta.get_gamemode())
		local p1_squished_changed, p1_squished_curr, p1_squished_prev = update_prev('p1_squished', gamemeta.get_squished())

		-- if a method is provided and we are not in normal gameplay, don't ever swap
		-- TODO: find relevant values and make such a method
		if gamemeta.gmode and not gamemeta.gmode() then
			return false
		end

		if (p1_squished_changed and p1_squished_prev == 0 and p1_squished_curr == 1) then
			return true -- squimsh
		end
		if (p1_squished_curr == 1) then
			return false -- Don't process more cube or row deductions until all the cubes have fallen off the stage
		end

		if (p1_cube_limit_changed and p1_cube_limit_curr < p1_cube_limit_prev) then
			return true -- You let a Cube fall!
		end
		if (p1_rows_changed and p1_rows_curr < p1_rows_prev) then
			return true -- You let too many Cubes fall or captured a Forbidden Cube!
		end
		if (p1_gamemode_changed and p1_gamemode_curr == 0x13 and p1_gamemode_prev == 0x12) then
			return true -- You died! Shift before the IQ screen appears
		end
		return false
	end
end

local function resident_evil_1(gamemeta)
	return function(data)
		-- To avoid swapping when poisoned since poison does not inflict any sort of hit other than drain your health. We will use the address for when the player is in control.
		-- This address will also have unique values for what damages the player. A value of 2 is for typical hits, 5 is for when grabbed by zombies, 6 is for when grabbed by animals. 3 is when you die normally & 7 is for instakills

		local playercontrol = gamemeta.hit()
		local previouscontrol = data.hit
		data.hit = playercontrol

		-- This is for the in-game state. 0 is for when you are in-game and 1 is for when you are in the main menu/game over/load file screen. We will use this for cutscene deaths if the player fails a condition that forces a game over.

		local ingamestate = gamemeta.state()
		local previousstate = data.state
		data.state = ingamestate

		-- This is for the end fight against Tyrant. A timer starts once you get to the roof. If timer goes to 0, a cutscene of the mansion exploding is shown. This is unique to only this scenario so we can use this to tell if player fails.
		local cutscene = gamemeta.cut()
		data.cut = cutscene

		if playercontrol == 5 and playercontrol ~= previouscontrol 
		or playercontrol == 2 and playercontrol ~= previouscontrol 
		or playercontrol == 6 and playercontrol ~= previouscontrol then
			return true, 15
			elseif playercontrol == 3 and ingamestate == 1 and ingamestate ~= previousstate
			or playercontrol == 7 and ingamestate == 1 and ingamestate ~= previousstate
			or playercontrol == 8 and ingamestate == 1 and ingamestate ~= previousstate then
			return true
			elseif ingamestate == 1 and ingamestate ~= previousstate and cutscene == 2 then
			return true
			else
			return false
		end
	end
end
local function resident_evil_2(gamemeta)
	return function(data)
		-- To avoid swapping when poisoned since poison does not inflict any sort of hit other than drain your health. We will use the address for when the player is in control.
		-- This address will also have unique values for what damages the player. A value of 2 is for typical hits, 5 is for when grabbed by zombies, crows or punched by MR.X. 3 is when you die normally & turns to 7 then to 0. 6 is when killed by zombies/birkinG3/FinalG/Dogs
		-- Deaths work a bit diffirent compared to RE1. Strike deaths go from 3 to 7 to 0. Grab deaths go to 6 then to 0. Zombies/Birkin/Dogs are value 6.
		-- MR.X instakill is a value of 5, rest is 3 to 7 to 0. Super Mr.X kill strike does 2 to 1 to 2 to 1 to 5. Final G is 6 but health is stuck at 12 and doesn't go above the health limit like the rest of the deaths.
		-- Crows when shaken off after they attack will drop to the floor. This causes the hit indicator to go from 5 to 2.
		-- Leon & Claire have their own address when it comes to hit indictors

		local playercontrolleon = gamemeta.hitleon()
		local previouscontrolleon = data.hitleon or 5
		data.hitleon = playercontrolleon

		local playercontrolclaire = gamemeta.hitclaire()
		local previouscontrolclaire = data.hitclaire or 5
		data.hitclaire = playercontrolclaire

		-- Addresses for Timer when it reaches 0 goes straight to a 65535 when it explodes then goes to 0 at main menu. Leon & Claire have their own timer addresses

		local timerleon = gamemeta.timeleon()
		local previoustimerleon = data.timeleon
		data.timeleon = timerleon

		local timerclaire = gamemeta.timeclaire()
		local previoustimerclaire = data.timeclaire
		data.timeclaire = timerclaire

		-- Because of a certain kill animation (Super Tyrant) that makes the hit indicator changes to values that would make it swap rapidly. We will use the health address to tell us when it happens and to avoid the swapping. And of course Leon & Claire have their own health addresses

		local healthleon = gamemeta.hpleon()
		local previoushealthleon = data.hpleon
		data.hpleon = healthleon

		local healthclaire = gamemeta.hpclaire()
		local previoushealthclaire = data.hpclaire
		data.hpclaire = healthclaire

		if playercontrolleon == 2 and playercontrolleon ~= previouscontrolleon and previouscontrolleon ~= 5 and previoushealthleon <= 200
		or playercontrolleon == 5 and playercontrolleon ~= previouscontrolleon and previoushealthleon <= 200
		or playercontrolleon == 6 and playercontrolleon ~= previouscontrolleon
		or playercontrolleon == 3 and playercontrolleon ~= previouscontrolleon
		or playercontrolclaire == 2 and playercontrolclaire ~= previouscontrolclaire and previouscontrolclaire ~= 5 and previoushealthclaire <= 200
		or playercontrolclaire == 5 and playercontrolclaire ~= previouscontrolclaire and previoushealthclaire <= 200
		or playercontrolclaire == 6 and playercontrolclaire ~= previouscontrolclaire
		or playercontrolclaire == 3 and playercontrolclaire ~= previouscontrolclaire then
			return true, 15
			elseif timerleon == 65535 and timerleon ~= previoustimerleon or timerclaire == 65535 and timerclaire ~= previoustimerclaire then
			return true
			else
			return false
		end
	end
end

local function resident_evil_3(gamemeta)
	return function(data)
		-- To avoid swapping when poisoned since poison does not inflict any sort of hit other than drain your health. We will use the address for when the player is in control.
		-- This address will also have unique values for what damages the player. A value of 2 is for typical hits, 5 is for when grabbed by zombies, crows, nemesis, leech. 3 is when you die normally & turns to 7 then to 0. 6 is when killed by zombies/Dogs/frog hunter/Chimera/nemesis with tentacle slam

		local playercontrol = gamemeta.hit()
		local previouscontrol = data.hit
		data.hit = playercontrol

		-- Addresses for Timer when it reaches 0 goes straight to a 65535 when it explodes then goes to 0 at main menu. With the gameover address. This seems kind of redundent to have for now

		--local timer = gamemeta.time()
		--local previoustimer = data.time
		--data.time = timer

		-- The Nuke Timer goes to 0 pretty early before the game over. This seems to go value 64 when game overed and I haven't noticed what else this address is for.'
		
		local gameovered = gamemeta.gameover()
		local previousgameovered = data.gameover
		data.gameover = gameovered

		if playercontrol == 2 and playercontrol ~= previouscontrol 
		or playercontrol == 3 and playercontrol ~= previouscontrol
		or playercontrol == 5 and playercontrol ~= previouscontrol
		or playercontrol == 6 and playercontrol ~= previouscontrol then
			return true, 15
			elseif gameovered == 64 and gameovered ~= previousgameovered then
			return true
			else
			return false
		end
	end
end

local function thps_swap(gamemeta)
    return function(data)
        local pointerOne = gamemeta.get_pointer_one() -- Pointer that is set to match pointer two when user presses confirm to enter gameplay; otherwise points to stale data
        local pointerTwo = gamemeta.get_pointer_two() -- Pointer that is set to 0 when not in gameplay, and updates to point to the game stats during level load
        if pointerTwo ~= 0x0 and pointerOne == pointerTwo then
            local bailsChanged, numBails, prevBails = update_prev("bails", gamemeta.get_bails())
            if bailsChanged and numBails > prevBails then -- User has bailed one more time this run than when last we checked
                return true
            end
        end
        return false
    end
end

local function TecmoSuperBowl_NES_swap(gamemeta)
	return function(data)
		-- swap function for Tecmo Super Bowl (NES), 1P ONLY
		-- OFFENSE swap conditions:
			-- giveaways
				-- opponent takes possession and p1 didn't score -> swap
				-- note that opponent already "possesses" ball when kickoff loads, including after a safety
			-- else, failure to get a first down
				-- p1 has possession and down goes up -> swap
		-- DEFENSE swap conditions:
			-- opponent scores
				-- 2p points go up by 3+ -> swap on kickoff loading
				-- require 3+ so that safeties (2 points, change of possession but need to mind the timing) and PATs (1 point) do not double-swap
			-- opponent starts with possession, calls a play, and gets a first down
				-- if play picker has appeared once before, check when play picker appears, and if down == 0 -> swap
		-- Track every frame:
			-- playbook appears (on going to playbook screen, check if we have seen it yet - if yes, then check down - if down off target, immediate swap)
			-- scores
			-- possession, including specifically tracking if 1p is kicking off
				-- p1 can lose possession in these ways:
					-- losing the coin toss, if opponent picks to return (registers as loss of possession, happens right away)
					-- mid-play (interception, fumble) - shuffle right away
					-- after play (punt returned, turnover on downs, missed FG) - shuffle on play picker loading
			-- is p2 kicking off? needed for proper swap timing
		-- NEED TO STORE FOR TIMED COMPARISONS:
			-- scores, on load and whenever p1 scores
			-- play picker exited since we swapped in, true/false
			-- down (changes on end of play, NOT on same frame that play picker pops up!)
			-- is p2 kicking off? need this for proper swap timing
		
		-- if two skipped teams are playing each other and we are watching the score, don't ever swap
		if not gamemeta.gmode() then
			return false
		end
		-- first, grab the current data
		local p1_possession_curr = gamemeta.get_p1_possession()
		local whatdown_curr = gamemeta.get_whatdown()
		local picking_play_curr = gamemeta.get_picking_play()
		local p1_points_curr = gamemeta.get_p1_points()
		local p2_points_curr = gamemeta.get_p2_points()
		local p1_kickoff_curr = gamemeta.get_p1_kickoff()
		local p2_kickoff_curr = gamemeta.get_p2_kickoff()
		local music_cue_curr = gamemeta.get_music_cue()
		
		-- now, retrieve previous data
		local p1_possession_prev = data.p1_possession_prev
		local whatdown_prev = data.whatdown_prev
		local picking_play_prev = data.picking_play_prev
		local p1_points_prev = data.p1_points_prev
		local p2_points_prev = data.p2_points_prev
		local p1_kickoff_prev = data.p1_kickoff_prev
		local p2_kickoff_prev = data.p2_kickoff_prev
		local music_cue_prev = data.music_cue_prev
		
		-- and store all the current values
		data.p1_possession_prev = p1_possession_curr
		data.picking_play_prev = picking_play_curr
		data.whatdown_prev = whatdown_curr
		data.p1_points_prev = p1_points_curr
		data.p2_points_prev = p2_points_curr
		data.p1_kickoff_prev = p1_kickoff_curr
		data.p2_kickoff_prev = p2_kickoff_curr
		data.music_cue_prev = music_cue_curr
		
		-- next, we need to store a few things away for later comparisons
		-- A - p1 score: store it away on load, and if it goes up, store it again
		if data.p1_score_on_load == nil then
			data.p1_score_on_load = p1_points_curr 
		end
		-- B - p2 score: only store on load, since we will swap any time this goes up by at least 3 points
		if data.p2_score_on_load == nil then
			data.p2_score_on_load = p2_points_curr
		end
		if data.p2_scored == nil then
			data.p2_scored = false
		end
		-- C - current down: store on load, update if plays go by without a swap
		if data.down_at_start_of_play == nil then
			data.down_at_start_of_play = whatdown_curr
		end
		-- D - play picker status: count the number of times we've seen the play picker
			-- if we haven't seen it at all, that means we came back mid-play to 2p with possession (interception, fumble recovery, onside kick recovered)
			-- don't shuffle if downs goes to 0, opponent has ball, AND we haven't seen the play picker, as that will be a double swap
		if data.play_picker_seen == nil then
			data.play_picker_seen = 0
		end
		if picking_play_curr == false and picking_play_prev == true then
			-- increment this on play picker disappearing
			data.play_picker_seen = data.play_picker_seen + 1
		end
		-- E - has the injured music been cued up?
		if data.p1_injured_music_cued == nil then
			data.p1_injured_music_cued = false
		end
		
		-- we need to implement a delay for certain swaps, so we will add a countdown here
		if data.delayCountdown ~= nil and data.delayCountdown > 0 then
			--console.log("delayCountdown: "..data.delayCountdown);
			data.delayCountdown = data.delayCountdown - 1
			if data.delayCountdown == 0 then
				--console.log("delayCountdown is 0; swapping");
				return true;
			end
			return false;
		end
		
		-- SWAPS
		-- first, swap on p2 scoring a TD or FG, after a 60-frame delay
		-- any time this happens, when you swap in, p2 will still have the ball
		if p2_points_prev and p2_points_curr > p2_points_prev + 2 then
			data.p2_scored = true
		end
		-- We will shuffle on p2 scores when it turns to kickoff, because they credit the FG INSTANTLY (it's decided before the cutscene even starts!)
		if data.p2_scored == true and 
			((p2_kickoff_curr == true and p2_kickoff_prev == false) or (p1_kickoff_curr == true and p1_kickoff_prev == false)) -- latter will handle kickoffs back to p2 after halftime if p2 to end 2Q and gets possession to start Q3
		then
			data.delayCountdown = 3
			data.p2_scored = false
		end
		-- We need to shuffle if p2 wins the game.
		if gamemeta.get_end_of_game() == true and p2_points_curr > p1_points_curr
		then
			data.delayCountdown = 169 -- wait for scoreboard
		end
		-- We need to shuffle if a p1 player gets injured. We'll know because the music (0x2B) played.
		-- conveniently, music and sound cues only last for one frame
		if music_cue_curr == 0x2B and p1_possession_curr == true then data.p1_injured_music_cued = true end
		-- When the cue goes through to silence the music (0x01), swap
		if music_cue_curr == 0x01 and data.p1_injured_music_cued == true
		then
			data.delayCountdown = 3
		end
		-- next, swap on possession losses by checking if possession changed to p2 ("p1 now has ball" is irrelevant here)
		if p1_possession_curr == false and p1_possession_prev == true then
			-- compare p1's score before and after the possession change (the only time we would not swap right away is if p1 scored and is kicking off)
			if p1_points_curr == data.p1_score_on_load then -- p1 gave up the ball and didn't score? swap now
				data.delayCountdown = 3
			else -- p1 is kicking off after a score? update that stored score, and reset "play picker seen" to 0 because it's about to be a new drive for p2
				data.p1_score_on_load = p1_points_curr
				data.play_picker_seen = 0
			end
		end
		-- now that we've handled possession changes, we need to check mid-drive failures (p1 doesn't get a first down, or p2 gets one)
		if picking_play_curr == true and picking_play_prev == false then -- down just changed if the playbook screen just came up
			if p1_possession_curr and whatdown_curr > data.down_at_start_of_play then -- did down just go up? oh, then you didn't get a first down, huh? swap now
				data.delayCountdown = 3
			-- next, we need to swap if the opponent has earned a first down - this would happen after the play picker has been seen at least once
			elseif p1_possession_curr == false and whatdown_curr == 0 and -- it's p2's ball and first down?
				picking_play_curr == true and picking_play_prev == false and data.play_picker_seen > 0 then -- and the play picker just showed up, and we've seen them pick a play already? swap now
				data.delayCountdown = 3
			-- and, if none of that is true, update the down we saw the last time the play picker came up
			else
				data.down_at_start_of_play = whatdown_curr
			end
		end
		
    end
end

local function PockyRocky2_SNES_swap(gamemeta)
	return function(data)
		-- Pocky can be in one of three armor states
		local pocky_states = {
			[0x1815] = 1,
			[0x0015] = 2, -- kimono; you revive in this state
			[0x6D29] = 3, -- kimono + armor item
			}
		-- If Pocky is not in a valid state, such as on loading screens, don't swap
		-- If timer is at 0, hold off on swaps until timer refills; this prevents double swaps (health gets drained, then life)
		-- this is pretty much our gmode or is_valid_gamestate
		if pocky_states[gamemeta.getpockystate()] == nil or gamemeta.gettimeup() == 0 then
			return false
		end
		-- the two players work VERY DIFFERENTLY from one another in this game
		-- P1, Pocky, is always a human player
		-- Damage type 1: drop in armor status
		-- Damage type 2: losing the bunny ears, which provide 1 extra HP
		-- Damage type 3: life lost
		local pockycurrhp   = pocky_states[gamemeta.getpockystate()]
		local pockycurrlc   = gamemeta.getlc()
		-- P2 can be Rocky or lots of other characters, and a human P2 can tag in/out between levels
		-- If P2 is human, track their HP (what SHOULD be a simple value from 0 to 4, but will be worse than that)
		local p2currhuman   = gamemeta.getp2ishuman()
		local p2currhp      = gamemeta.getp2hp()
		-- we need to track whether the two characters have "merged" using magic or are currently "merging/unmerging"
		-- as changes in HP during these situations should be processed but should not swap
		local currmerged    = gamemeta.getmerged()
		local currmerging   = gamemeta.getmerging()
		-- in Level 5, you ride a mount that has 3 HP, and if they lose HP, you should swap
		local currmounthp   = gamemeta.getmounthp()
		local currlevel     = gamemeta.getlevel()

		-- retrieve previous hp/lives/merging data before backup
		local pockyprevhp   = data.pockyprevhp
		local pockyprevlc   = data.pockyprevlc
		local p2prevhuman   = data.p2prevhuman
		local p2prevhp      = data.p2prevhp
		local prevmerged    = data.prevmerged
		local prevmerging   = data.prevmerging
		local prevmounthp   = data.prevmounthp
		local prevlevel     = data.prevlevel

		data.pockyprevhp    = pockycurrhp
		data.pockyprevlc    = pockycurrlc
		data.p2prevhuman    = p2currhuman
		data.p2prevhp       = p2currhp
		data.prevmerged     = currmerged
		data.prevmerging    = currmerging
		data.prevmounthp    = currmounthp
		data.prevlevel      = currlevel

		-- this delay ensures that when the game ticks away health for the end of a level,
		-- we can catch its purpose and hopefully not swap, since this isnt damage related
		if data.p1hpcountdown ~= nil and data.p1hpcountdown > 0 then
			data.p1hpcountdown = data.p1hpcountdown - 1
			if data.p1hpcountdown == 0 then
				return true
			end
		end

		if data.p2hpcountdown ~= nil and data.p2hpcountdown > 0 then
			data.p2hpcountdown = data.p2hpcountdown - 1
			if data.p2hpcountdown == 0 then
				return true
			end
		end

		if pockyprevhp ~= nil and pockycurrhp < pockyprevhp then
			data.p1hpcountdown = gamemeta.delay or 3
		end
		-- if the level 5 mount's health goes to 0, we will rely on the life count to tell us whether to swap
		-- constraining valid HP is especially important as we don't have the typical minhp or maxhp in this custom function
		if prevmounthp ~= nil and currmounthp < prevmounthp and currmounthp > 0 and currmounthp < 4  and currlevel == 0x04 then
			data.p1hpcountdown = gamemeta.delay or 3
		end
		-- Situations where we want to cue up a swap for P2's HP dropping:
			-- They're walking around unmerged AND player-controlled
			-- They're being controlled by P1 because they're in a merged state
		-- conversely, we want process P2's HP and NOT swap: 
			-- if they are merging/unmerging (there are false HP drops here!)
			-- this applies on the last frame of merges and unmerges as well
		if (currmerged or p2currhuman) and currmerging == 0 and prevmerging == 0 then
			if p2prevhp ~= nil and p2currhp < p2prevhp then
				data.p2hpcountdown = gamemeta.delay or 3
			end
		end

		-- check to see if the life count went down
		-- only Pocky has lives; P2 respawns as often as you want, after a delay
		if pockyprevlc ~= nil and pockycurrlc < pockyprevlc then
			return true
		end

		-- finally, you should swap on losing the ears
		-- for some reason, the ears value drops to 0 during the unmerging process, and it pops right back to normal when this is complete
		-- therefore, swap on losing ears ONLY if you're not in a merge/unmerge!
		local ears_changed, ears_curr = update_prev("ears", gamemeta.getears())
		if ears_changed == true and ears_curr == false and currmerged == false then
			data.p1hpcountdown = gamemeta.delay or 3
		end

		return false
	end
end

local function always_swap(gamemeta)
	return function(data)
		return true -- Always swap!
	end
end

-- Modified version of the gamedata for Mega Man games on NES.
-- Battletoads NES and BTDD each show 6 "boxes" that look like HP.
-- But, each toad actually has a max HP of 47. Each box is basically 8 HP.
-- If your health falls 40, you go from 6 boxes to 5. Anything from 41-47 will still show 6 boxes.
-- At 32, you have 4 boxes. At 24, 3 boxes. And so on - until a death at HP = 0.
-- We only want to shuffle when the # of HP on screen changes, because 'light' damage (say, of only 2 HP from a chop by one of the pigs at the beginning) gets partially refilled over time.
-- So, dividing the current HP value by 8, then rounding up, gives us the number of health boxes the toad has.
local gamedata = {
	['BT_NES']={ -- Battletoads NES
		func=twoplayers_withlives_swap,
		p1gethp=function() return math.ceil(memory.read_u8(0x051A, "RAM")/8) end,
		p2gethp=function() return math.ceil(memory.read_u8(0x051B, "RAM")/8) end,
		p1getlc=function() return memory.read_u8(0x0011, "RAM") end,
		p2getlc=function() return memory.read_u8(0x0012, "RAM") end,
		gettogglecheck=function() return memory.read_u8(0x0011, "RAM") == 255 or memory.read_u8(0x0011, "RAM") == 255 end, --did a toad just join or drop?
		maxhp=function() return 6 end,
	},
	['BT_NES_patched']={ -- Battletoads NES with bugfix patch
		func=twoplayers_withlives_swap,
		p1gethp=function() return math.ceil(memory.read_u8(0x051A, "RAM")/8) end,
		p2gethp=function() return math.ceil(memory.read_u8(0x051B, "RAM")/8) end,
		p1getlc=function() return memory.read_u8(0x0011, "RAM") end,
		p2getlc=function() return memory.read_u8(0x0012, "RAM") end,
		gettogglecheck=function() return memory.read_u8(0x0011, "RAM") == 255 or memory.read_u8(0x0011, "RAM") == 255 end, --did a toad just join or drop?
		maxhp=function() return 6 end,
	},
	['BTDD_NES']={ -- Battletoads Double Dragon NES
		func=twoplayers_withlives_swap,
		p1gethp=function() return math.ceil(memory.read_u8(0x051B, "RAM")/8) end,
		p2gethp=function() return math.ceil(memory.read_u8(0x051C, "RAM")/8) end,
		p1getlc=function() return memory.read_u8(0x0011, "RAM") end,
		p2getlc=function() return memory.read_u8(0x0012, "RAM") end,
		maxhp=function() return 6 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x0011 end,
		p2livesaddr=function() return 0x0012 end,
		maxlives=function() return 69 end,
		ActiveP1=function() return memory.read_u8(0x0011, "RAM") > 0 and memory.read_u8(0x0011, "RAM") < 255 end,
		ActiveP2=function() return memory.read_u8(0x0012, "RAM") > 0 and memory.read_u8(0x0012, "RAM") < 255 end,
		LivesWhichRAM=function() return "RAM" end,
	},
	['BT_SNES']={ -- Battletoads in Battlemaniacs for SNES
		func=twoplayers_withlives_swap,
		gmode=function() return memory.read_s8(0x000059, "WRAM") == 0x0F end, -- must be fully faded in to count hp and lives etc
		p1gethp=function() return memory.read_s8(0x000E5E, "WRAM") end,
		p2gethp=function() return memory.read_s8(0x000E60, "WRAM") end,
		p1getlc=function() return memory.read_s8(0x000028, "WRAM") end,
		p2getlc=function() return memory.read_s8(0x00002A, "WRAM") end,
		maxhp=function() return 16 end,
		swap_exceptions=function()
			-- do not swap on changing level
			-- on level change, HP drops to 0, then springs back up to max, this would otherwise cause a false swap
			local level_changed, level_curr = update_prev("level", memory.read_u8(0x00002C, "WRAM"))
			local p1nosprite_changed, p1nosprite_curr = update_prev("p1nosprite", memory.read_u8(0x000AEE, "WRAM") == 0)
			local p2nosprite_changed, p2nosprite_curr = update_prev("p2nosprite", memory.read_u8(0x000AF0, "WRAM") == 0)
			if level_changed then return true end
			-- BUG: double-swaps in Roller Coaster (6) happen because HP suddenly drops to 0, on the VERY LAST FRAME before going to black and on a different frame from lives
			-- however, sprites also disappear on that frame
			-- so, don't swap on that frame, and we're good
			if level_curr == 6 and 
				((p1nosprite_changed == true and p1nosprite_curr == true) or 
				(p2nosprite_changed == true and p2nosprite_curr == true))
			then 
				return true
			end
			return false
		end,
		other_swaps=function()
			-- do swap if the "hurt on the bowling pins/dominos" sprite gets called
			local p1hurtsprite_changed, p1_hurtsprite_curr = update_prev("p1hurtsprite", memory.read_u8(0x000AEE, "WRAM") == 128)
			local p2hurtsprite_changed, p2_hurtsprite_curr = update_prev("p2hurtsprite", memory.read_u8(0x000AF0, "WRAM") == 236)
			local level = memory.read_u8(0x00002C, "WRAM")
			if p1hurtsprite_changed == true and p1_hurtsprite_curr == true and (level == 2 or level == 8) then return true end
			if p2hurtsprite_changed == true and p2_hurtsprite_curr == true and (level == 2 or level == 8) then return true end
			return false
		end,
		-- note, BT_SNES currently uses a custom Infinite Lives function to allow for level skips to work
	},
	['BTDD_SNES']={ -- Battletoads Double Dragon SNES
		func=twoplayers_withlives_swap,
		p1gethp=function() return math.ceil(memory.read_u8(0x00003A, "WRAM")/8) end,
		p2gethp=function() return math.ceil(memory.read_u8(0x00003C, "WRAM")/8) end,
		p1getlc=function() return memory.read_u8(0x000026, "WRAM") end,
		p2getlc=function() return memory.read_u8(0x000028, "WRAM") end,
		maxhp=function() return 6 end,
		
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x000026 end,
		p2livesaddr=function() return 0x000028 end,
		maxlives=function() return 69 end,
		ActiveP1=function() return memory.read_u8(0x000026, "WRAM") > 0 and memory.read_u8(0x000026, "WRAM") < 255 end,
		ActiveP2=function() return memory.read_u8(0x000028, "WRAM") > 0 and memory.read_u8(0x000028, "WRAM") < 255 end,
		LivesWhichRAM=function() return "WRAM" end,
	},
	['BTDD_SNES_patched']={ -- Battletoads Double Dragon SNES
		func=twoplayers_withlives_swap,
		p1gethp=function() return math.ceil(memory.read_u8(0x00003A, "WRAM")/8) end,
		p2gethp=function() return math.ceil(memory.read_u8(0x00003C, "WRAM")/8) end,
		p1getlc=function() return memory.read_u8(0x000026, "WRAM") end,
		p2getlc=function() return memory.read_u8(0x000028, "WRAM") end,
		maxhp=function() return 6 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x000026 end,
		p2livesaddr=function() return 0x000028 end,
		maxlives=function() return 69 end,
		ActiveP1=function() return memory.read_u8(0x000026, "WRAM") > 0 and memory.read_u8(0x000026, "WRAM") < 255 end,
		ActiveP2=function() return memory.read_u8(0x000028, "WRAM") > 0 and memory.read_u8(0x000028, "WRAM") < 255 end,
		LivesWhichRAM=function() return "WRAM" end,
	},
	['CNDRR1_NES']={ -- Chip and Dale 1 (NES)
		func=twoplayers_withlives_swap,
		-- three addresses for hearts - if the heart is there, these == 24 (18 hex) , otherwise they == 248 (F8 hex).
		p1gethp=function()
			if memory.read_u8(0x0210, "RAM") == 24 then
				return 3
			elseif memory.read_u8(0x020C, "RAM") == 24 then
				return 2
			elseif memory.read_u8(0x0208, "RAM") == 24 then
				return 1
			else
				return 0
			end
		end,
		p2gethp=function()
			if memory.read_u8(0x0224, "RAM") == 24 then
				return 3
			elseif memory.read_u8(0x0220, "RAM") == 24 then
				return 2
			elseif memory.read_u8(0x021C, "RAM") == 24 then
				return 1
			else
				return 0
			end
		end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x05B6 end,
		p2livesaddr=function() return 0x05E6 end,
		maxlives=function() return 135 end, -- rescue rangers counts strangely
		p1getlc=function() return memory.read_u8(0x05B6, "RAM") end,
		p2getlc=function() return memory.read_u8(0x05E6, "RAM") end,
		ActiveP1=function() return memory.read_u8(0x05B6, "RAM") > 0 and memory.read_u8(0x05B6, "RAM") < 255 end,
		ActiveP2=function() return memory.read_u8(0x05E6, "RAM") > 0 and memory.read_u8(0x05E6, "RAM") < 255 end,
		maxhp=function() return 3 end,
	},
	['CNDRR2_NES']={ -- Chip and Dale 2 (NES)
		func=twoplayers_withlives_swap,
		p1gethp=function() return memory.read_u8(0x03D4, "RAM") end,
		p2gethp=function() return memory.read_u8(0x03D5, "RAM") end,
		p1getlc=function() return memory.read_u8(0x00A7, "RAM") end,
		p2getlc=function() return memory.read_u8(0x00A8, "RAM") end,
		maxhp=function() return 5 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x00A7 end,
		p2livesaddr=function() return 0x00A8 end,
		maxlives=function() return 70 end,
		ActiveP1=function() return memory.read_u8(0x00A7, "RAM") > 0 and memory.read_u8(0x00A7, "RAM") < 255 end,
		ActiveP2=function() return memory.read_u8(0x00A8, "RAM") > 0 and memory.read_u8(0x00A8, "RAM") < 255 end,
	},
	['SuperDodgeBall']={ -- Super Dodge Ball (NES)
		func=sdbnes_swap,
		gethowmanyplayers=function() return memory.read_u8(0x006F, "RAM") end,
		-- # humans, 1 or 2, use this to tell whether to swap if 2p team takes damage
		getmode=function() return memory.read_u8(0x06B1, "RAM") end,
		-- mode: 0 for 1p, 1 for 2p vs, 2 for bean ball
		p1gethp1=function() return memory.read_u8(0x058B, "RAM") end,
		p1gethp2=function() return memory.read_u8(0x0553, "RAM") end,
		p1gethp3=function() return memory.read_u8(0x051B, "RAM") end,
		p2gethp1=function() return memory.read_u8(0x043B, "RAM") end,
		p2gethp2=function() return memory.read_u8(0x0403, "RAM") end,
		p2gethp3=function() return memory.read_u8(0x03CB, "RAM") end,
		p1getbbplayer=function() return (1 + math.floor(memory.read_u8(0x0587, "RAM")/16) + 3*(memory.read_u8(0x0587, "RAM") % 16)) end,
		-- transforming from 0, 16, 32, 1, 17, 33 format
		p2getbbplayer=function() return (1 + math.floor(memory.read_u8(0x0588, "RAM")/16) + 3*(memory.read_u8(0x0588, "RAM") % 16)) end,
		-- transforming from 0, 16, 32, 1, 17, 33 format
		gmode=function() return (memory.read_u8(0x0070, "RAM")%2) == 0 end,
		-- several potential values, but if it's ever odd, we're not in-game.
		maxhp=function() return 60 end,
	},
	['CaptainNovolin']={ -- Captain Novolin SNES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x0BDA, "WRAM") end,
		p1getlc=function() return memory.read_u8(0x06C3, "WRAM") end,
		maxhp=function() return 4 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x06C3 end,
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 3 end,
		ActiveP1=function() return memory.read_u8(0x06C3, "WRAM") > 1 and memory.read_u8(0x06C3, "WRAM") < 3 end,
	},
	['Zelda_LTTP']={ -- The Legend of Zelda: A Link to the Past, SNES
		func=singleplayer_withlives_swap,
		p1gethp=function()
			if (memory.read_u8(0x0010, "WRAM") < 23 and memory.read_u8(0x0010, "WRAM") >5) then
				-- <=5 means we're on the title/menu, 23 means save/quit and >23 is credits, etc. Don't swap on those!
				return memory.read_u8(0xF36D, "WRAM")
			else
				return 0
			end
		end, -- single byte!
		maxhp=function() return 160 end, -- 8 hp per heart, 20 heart containers
		p1getlc=function()
			if memory.read_u8(0x0010, "WRAM") == 18 then
			-- this value is the "Link is in a death spiral" value - so it tells us Link hit 0 for real, not due to resets etc.
				return 1
			else
				return 2
			end
		end,
		grace=60,
	},
	['MetroidSuper']={ -- Super Metroid, SNES
		func=supermetroid_swap,
		getinvuln=function() return memory.read_u16_le(0x18A8, "WRAM") end,
		-- this value is 0 until i-frames are triggered
		getsamusstate=function() return memory.read_u8(0x0998, "WRAM") end,
		-- this value is the "game state" where the game is fading out after Samus dies.
		-- Tells us Samus hit 0 for real, not due to resets etc.
		gethp=function() return memory.read_u16_le(0x09C2, "WRAM") end,
		grace=60,
	},
	['SMZ3']={ -- Super Metroid x A Link to the Past Crossover Randomizer
		func=SMZ3_swap,
		getinvuln=function() return memory.read_u16_le(0x18A8, "WRAM") end,
		-- this value is 0 until i-frames are triggered
		getsamusstate=function() return memory.read_u8(0x0998, "WRAM") end,
		-- this value is the "game state" where the game is fading out after Samus dies.
		-- Tells us Samus hit 0 for real, not due to resets etc.
		getsamushp=function() return memory.read_u8(0x09C2, "WRAM") end,
		getlinkhp=function()
			if memory.read_u8(0x33FE, "CARTRAM") == 0 then
				if (memory.read_u8(0x0010, "WRAM") < 23 and memory.read_u8(0x0010, "WRAM") >5)  then
					return memory.read_u8(0xF36D, "WRAM") -- Link health
				else
					return 0
				end
			else
				return 0
			end
		end,
		maxhp=function() return 160 end,
		getlinklc=function()
			if memory.read_u8(0x33FE, "CARTRAM") == 0 -- LTTP
				and memory.read_u8(0x0010, "WRAM") == 18
				-- this value is the "Link is in a death spiral" value - so it tells us Link hit 0 for real, not due to resets etc.
			then
				return 1
			else
				return 2
			end
		end,
		getwhichgame=function() return memory.read_u8(0x33FE, "CARTRAM") end,
		grace=60,
	},
	['Anticipation']={ -- Anticipation NES
		func=antic_swap,
		getbotchedletter=function() return memory.read_u8(0x00C3, "RAM") end,
		getbuzzintime=function() return memory.read_u8(0x007F, "RAM") end,
		gettypetime=function() return memory.read_u8(0x0086, "RAM") end,
		getanswerright=function() return memory.read_u8(0x00A0, "RAM") end,
	},
	['SMK_SNES']={ -- Super Mario Kart
		func=smk_swap,
		getmode=function() return memory.read_u8(0x000036, "WRAM") end, -- if == 14 then in battle mode
		p1getbump=function() return memory.read_u8(0x00105E, "WRAM") end, -- if > 0 then p1 is bumping/crashing
		p2getbump=function() return memory.read_u8(0x00115E, "WRAM") end, -- if > 0 then p2 is bumping/crashing
		p1getshrink=function() return memory.read_u16_be(0x001084, "WRAM") end, -- if > 0 then you're small and it's counting down
		p2getshrink=function() return memory.read_u16_be(0x001184, "WRAM") end, -- if > 0 then you're small and it's counting down
		p1getfall=function() return memory.read_u8(0x0010A0, "WRAM") end, -- if > 2 falling into pit (4), lava (6), deep water (8)
		p2getfall=function() return memory.read_u8(0x0011A0, "WRAM") end, -- if > 2 falling into pit (4), lava (6), deep water (8)
		p1getcoins=function() return memory.read_u8(0x000E00, "WRAM") end,
		p2getcoins=function() return memory.read_u8(0x000E02, "WRAM") end,
		p1getspinout=function() return memory.read_u8(0x0010A6, "WRAM") end, -- 12, 14, 16, and 26 should mean you spin out
		p2getspinout=function() return memory.read_u8(0x0011A6, "WRAM") end, -- 12, 14, 16, and 26 should mean you spin out
		p1getmoled=function() return memory.read_u8(0x001061, "WRAM") end, -- >=152 means a mole jumped on
		p2getmoled=function() return memory.read_u8(0x001161, "WRAM") end, -- >=152 means a mole jumped on
		p1getshrink2=function() return memory.read_u8(0x001030, "WRAM") end, -- if ==128 then you're shrunk
		p2getshrink2=function() return memory.read_u8(0x001130, "WRAM") end, -- if ==128 then you're shrunk
		p1getfinished=function() return memory.read_u8(0x001010, "WRAM") end, -- finished racing if kart status == 120, so don't swap if this player gets hurt
		p2getfinished=function() return memory.read_u8(0x001110, "WRAM") end, -- finished racing if kart status == 120, so don't swap if this player gets hurt
		p2getIsActive=function() return memory.read_u8(0x0011D2, "WRAM") == 2 end, -- if 2, you are in 2p mode
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x000154 end,
		p2livesaddr=function() return 0x000156 end,
		maxlives=function() return 4 end,
		ActiveP1=function() return memory.read_u8(0x000154, "WRAM") > 0 and memory.read_u8(0x000154, "WRAM") < 4 end,
		ActiveP2=function() return memory.read_u8(0x000156, "WRAM") > 0 and memory.read_u8(0x000156, "WRAM") < 4 end,
		LivesWhichRAM=function() return "WRAM" end,
	},
	--MARIO BLOCK
	['SMB1_NES']={ -- SMB 1 NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x0756, "RAM") end,
		p1getlc=function() return
			memory.read_u8(0x075A, "RAM") % 255
			-- mario if 1p, luigi if 2p, 255 = they game overed
			+ memory.read_u8(0x0761, "RAM") % 255
			-- mario if 2p, 255 = they game overed, stays at 2 if in 1p
		end,
		p2getlc=function() return memory.read_u8(0x0761, "RAM") end,
		maxhp=function() return 2 end,
		minhp=-1,
		gmode=function() return memory.read_u8(0x0770, "RAM") == 1 end,
		-- demo == 0, end of world == 2, game over == 3
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x075A end,
		p2livesaddr=function() return 0x0761 end,
		maxlives=function() return 8 end,
		ActiveP1=function() return memory.read_u8(0x075A, "RAM") > 0 and memory.read_u8(0x075A, "RAM") < 255 end,
		ActiveP2=function() return memory.read_u8(0x0761, "RAM") > 0 and memory.read_u8(0x0761, "RAM") < 255 end,
		LivesWhichRAM=function() return "RAM" end,
	},
	['SMB2J_NES']={ -- SMB 2 JP, NES version (Lost Levels)
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x0756, "RAM") + 1 end,
		-- add 1 because 'base health' is 0 and won't swap unless lives counter goes down
		p1getlc=function() return memory.read_u8(0x075A, "RAM") end,
		maxhp=function() return 2 end,
		gmode=function() return memory.read_u8(0x0770, "RAM") == 1 end,
		-- demo == 0, end of world == 2, game over == 3
		gettogglecheck=function() return memory.read_u8(0x075A) == 255 end,
		-- not in the ending or world 9 where you get 1 life no matter what (so lives are bumped to 255 arbitrarily)
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x075A end,
		maxlives=function() return 8 end,
		p1getlc=function() return memory.read_u8(0x075A, "RAM") end,
		ActiveP1=function() return memory.read_u8(0x075A, "RAM") > 0 and memory.read_u8(0x075A, "RAM") < 255 end,
		LivesWhichRAM=function() return "RAM" end,
	},
	['SMB2_NES']={ -- SMB2 USA NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x04C2, "RAM") end,
		p1getlc=function() return memory.read_u8(0x04ED, "RAM") end,
		maxhp=function() return 63 end,
		gettogglecheck=function() return memory.read_u8(0x04C3, "RAM") end,
		-- this is the number of health bars - if it changes, as in goes back down to normal on slots
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x04ED end,
		maxlives=function() return 70 end,
		ActiveP1=function() return memory.read_u8(0x04ED, "RAM") > 0 and memory.read_u8(0x04ED, "RAM") < 255 end,
		LivesWhichRAM=function() return "RAM" end,
	},
	['MB_NES']={ -- Mario Bros. US NES
		func=twoplayers_withlives_swap,
		-- this game only uses lives
		p1gethp=function() return 0 end,
		p1getlc=function() return memory.read_u8(0x0048, "RAM") end,
		p2gethp=function() return 0 end,
		p2getlc=function() return memory.read_u8(0x004C, "RAM") end,
		maxhp=function() return 0 end,
	},
	['SOMARI']={ -- Somari (unlicensed) NES
		func=somari_swap,
		getsprite=function() return memory.read_u8(0x0016) end,
		getshield=function() return memory.read_u8(0x001A) == 2 or memory.read_u8(0x001A) == 6 end,
		CanHaveInfiniteLives=true,
		-- consider moving to on_frame version if can identify "dying" sprite
		p1livesaddr=function() return 0x033C end,
		maxlives=function() return 9 end,
		ActiveP1=function() return memory.read_u8(0x033C, "RAM") > 0 and memory.read_u8(0x033C, "RAM") < 255 end,
		LivesWhichRAM=function() return "RAM" end,
	},
	['SMB3_NES']={ -- SMB3 NES
		func=smb3_swap,
		getsmb3battling=function() return memory.read_u8(0x001D, "RAM") == 18 end,
		-- 2p battle true/false
		getinvuln=function() return memory.read_u8(0x0552, "RAM") end,
		-- invuln frames, 0 unless triggered, then counts down by 1 per frame
		getstatue=function() return memory.read_u8(0x057A, "RAM") end,
		-- 0 until you go into tanooki statue form, then counts down by 1 per frame
		getboot=function() return memory.read_u8(0x0577, "RAM") end,
		-- boot flag, 1 means we're in the boot!
		p1getlc=function() return memory.read_u8(0x0736, "RAM") end,
		p2getlc=function() return memory.read_u8(0x0737, "RAM") end,
		gmode=function() return memory.read_u8(0x072B, "RAM") ~= 0 end,
		-- this value == number of players, == 0 on the title screen menu when cutscene is playing.
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x0736 end,
		p2livesaddr=function() return 0x0737 end,
		maxlives=function() return 69 end,
		ActiveP1=function() return memory.read_u8(0x0736, "RAM") > 0 and memory.read_u8(0x0736, "RAM") < 255 end,
		ActiveP2=function() return memory.read_u8(0x0737, "RAM") > 0 and memory.read_u8(0x0737, "RAM") < 255 end,
		LivesWhichRAM=function() return "RAM" end,
	},
	['SMW_SNES']={ -- Super Mario World SNES
		func=singleplayer_withlives_swap,
		p1gethp=function()
			if memory.read_u8(0x000071, "WRAM") == 9 then
			-- dying, so we need to use the lives counter
				return 0
			elseif memory.read_u8(0x000019, "WRAM") == 2 or memory.read_u8(0x000019, "WRAM") == 3 then
				return 3 -- fire (3) or cape (2), don't shuffle if you just change powerups
			else
				return memory.read_u8(0x000019, "WRAM") + 1
				-- 1 for big, 0 for small, adding 1 to help with swap on small not relying on life lost
			end
		end,
		p1getlc=function() return memory.read_u8(0x000DBE, "WRAM") end,
		-- active player's lives
		maxhp=function() return 3 end,
		gettogglecheck=function() return memory.read_u8(0x000DB3, "WRAM") end,
		-- which player - if we swap players, then do not shuffle
		gmode=function() return
			memory.read_u8(0x000100, "WRAM") == 11
			-- game mode value for fading to overworld, this is when the lives counter changes on death
			-- the mario/luigi lives count swaps ON the overworld (12-14) so don't count that!
			or (memory.read_u8(0x000100, "WRAM") > 15 and memory.read_u8(0x000100, "WRAM") <= 23)
			-- in a level, for HP checks
		end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x000DBE end,
		maxlives=function() return 68 end,
		LivesWhichRAM=function() return "WRAM" end,
		ActiveP1=function() return memory.read_u8(0x000DBE) > 0 and memory.read_u8(0x000DBE) < 255 end,
	},
	['SMAS_SNES']={ -- Super Mario All Stars (SNES)
		-- to do, function to define "which game"
		-- though I don't think that can go in this block and likely needs to go in the swap function instead
		SMAS_which_game=function()
			if memory.read_u8(0x01FF00, "WRAM") == 2 then
				return "SMB1"
			end
			if memory.read_u8(0x01FF00, "WRAM") == 4 then
				return "SMB2J"
			end
			if memory.read_u8(0x01FF00, "WRAM") == 6 and memory.read_u8(0x000547, "WRAM") < 128 then
				return "SMB2U" -- >128 means slots or menu
			end
			if memory.read_u8(0x01FF00, "WRAM") == 10 then
				return "SMW"
			end
			if memory.read_u8(0x01FF00, "WRAM") == 8 then
				if memory.read_u8(0x00072B, "WRAM") == 3 then
					return "SMB3Battle"
				else
					return "SMB3"
				end
			end
			return false
		end,
		func=SMAS_swap,
		gmode=function()
			if ((memory.read_u8(0x01FF00, "WRAM") == 2 or memory.read_u8(0x01FF00, "WRAM") == 4)
				and memory.read_u8(0x000770, "WRAM") ~= 1) -- demo == 0, end of world == 2, game over == 3 false
			then
				return false
			else
				return true
			end
		end,
		getsmb2mode=function()
			return memory.read_u8(0x0004C4, "WRAM")
			-- number of health bars available, changes on entering slots and can cause false swaps
		end,
		gettogglecheck=function()
			if memory.read_u8(0x01FF00, "WRAM") == 10 then
				return memory.read_u8(0x000DB3, "WRAM")
				-- tells us active character in SMW, so we know if we are switching
			elseif memory.read_u8(0x01FF00, "WRAM") == 8 then
				return memory.read_u8(0x000577, "WRAM")
				-- tells us if we have the boot in SMB3, to not swap when we get/lose it
			else
				return nil
			end
		end,
		p1gethp=function()
			if memory.read_u8(0x01FF00, "WRAM") == 8 then -- SMB3
				if memory.read_u8(0x00072B, "WRAM") == 3 then
					-- we are in battle mode
					if memory.read_u8(0x001930, "WRAM") == 0 then
						-- actively battling, not in results screen countdown
						return memory.read_u8(0x019AB, "WRAM") + 1
						-- battle health, 0 = small so add 1
					else
						return 0
					end
				elseif memory.read_u8(0x0552, "WRAM") > 0 and memory.read_u8(0x057A, "WRAM") == 0 then
					return 1
				else
					return 2
					-- if invuln frames are activated, not due to tanooki suit statue timer counting down, then drop health from 2 to 1
				end
			elseif memory.read_u8(0x01FF00, "WRAM") == 6 then -- SMB2 USA
				return math.ceil(memory.read_u8(0x0004C3)/16)
			elseif memory.read_u8(0x01FF00, "WRAM") == 2 or memory.read_u8(0x01FF00, "WRAM") == 4 then -- SMB1 or SMB2j
				if memory.read_u8(0x0754, "WRAM") == 1 -- small
					and memory.read_u8(0x070B, "WRAM") == 1 -- animating a shrink/grow
				then
					return 1
				else
					return 2
				end
			elseif memory.read_u8(0x01FF00, "WRAM") == 10 then -- Super Mario World
				if memory.read_u8(0x000071, "WRAM") == 9 then
					-- dying, so we need to use the lives counter
					return 0
				elseif memory.read_u8(0x000019, "WRAM") == 2 or memory.read_u8(0x000019, "WRAM") == 3 then
					return 3 -- fire (3) or cape (2), don't shuffle if you just change powerups
				else
					return memory.read_u8(0x000019, "WRAM") + 1
					-- 1 for big, 0 for small, adding 1 to help with swap on small not relying on life lost
				end
			else
				return 0
			end
		end,
		p2gethp=function()
			if memory.read_u8(0x01FF00, "WRAM") == 8 then -- SMB3
				if memory.read_u8(0x00072B, "WRAM") == 3 then
					-- we are in battle mode
					if memory.read_u8(0x001930, "WRAM") == 0 then
						-- actively battling, not in results screen countdown
						return memory.read_u8(0x019AC, "WRAM") + 1
						-- battle health, 0 = small so add 1
					else
						return 0
					end
				elseif memory.read_u8(0x0552, "WRAM") > 0 and memory.read_u8(0x057A, "WRAM") == 0 then
					return 1
				else
					return 2
					-- if invuln frames are activated, and not a tanooki statue, then drop health from 2 to 1
				end
			elseif memory.read_u8(0x01FF00, "WRAM") == 6 then -- SMB2 USA
				return 0
			elseif memory.read_u8(0x01FF00, "WRAM") == 2 or memory.read_u8(0x01FF00, "WRAM") == 4 then -- SMB1 or SMB2j
				if memory.read_u8(0x0754, "WRAM") == 1 -- small
					and memory.read_u8(0x070B, "WRAM") == 1 -- animating a shrink/grow
				then
					return 1
				else
					return 2
				end
			elseif memory.read_u8(0x01FF00, "WRAM") == 10 then -- Super Mario World
				if memory.read_u8(0x000071, "WRAM") == 9 then
					-- dying, so we need to use the lives counter
					return 0
				elseif memory.read_u8(0x000019, "WRAM") == 2 or memory.read_u8(0x000019, "WRAM") == 3 then
					return 3 -- fire (3) or cape (2), don't shuffle if you just change powerups
				else
					return memory.read_u8(0x000019, "WRAM") + 1
					-- 1 for big, 0 for small, adding 1 to help with swap on small not relying on life lost
				end
			else
				return 0
			end
		end,
		maxhp=function()
			if memory.read_u8(0x01FF00, "WRAM") == 8 then -- SMB3
				return 3
			elseif memory.read_u8(0x01FF00, "WRAM") == 6 then -- SMB2 USA
				return 63
			elseif memory.read_u8(0x01FF00, "WRAM") == 2 or memory.read_u8(0x01FF00, "WRAM") == 4 then
				-- SMB1 or SMB2j
				return 2 -- add 1 because 'base health' is 0 and won't swap unless lives counter goes down
			elseif memory.read_u8(0x01FF00, "WRAM") == 10 then -- Super Mario World
				return 3
			else
				return 0
			end
		end,
		p1getlc=function()
			if memory.read_u8(0x01FF00, "WRAM") == 8 then -- SMB3
				if memory.read_u8(0x00072B, "WRAM") == 3 then
					-- we are in the battle mode-only game
					return 5 - memory.read_u8(0x0002DB, "WRAM")
					-- luigi's victory count
				elseif memory.read_u8(0x00001D, "WRAM") == 18 then
					return memory.read_u8(0x000736, "WRAM") + 1
					-- we are in 2p battle mode when this == 18.
					-- Let's simply tack on a life for each player in that mode, and 'lose' it when the battle is lost.
				else
					return memory.read_u8(0x000736, "WRAM")
				end
			elseif memory.read_u8(0x01FF00, "WRAM") == 6 then -- SMB2 USA
				return memory.read_u8(0x0004EE, "WRAM")
			elseif memory.read_u8(0x01FF00, "WRAM") == 2 or memory.read_u8(0x01FF00, "WRAM") == 4 then -- SMB1 or SMB2j
				return memory.read_u8(0x00075A, "WRAM") % 255 -- mario if 1p, luigi if 2p, 255 = they game overed
					+ memory.read_u8(0x000761, "WRAM") % 255 -- mario if 2p, 255 = they game overed, stays at 2 if in 1p
			elseif memory.read_u8(0x01FF00, "WRAM") == 10 then -- Super Mario World
				return memory.read_u8(0x000DBE, "WRAM") -- active player's lives
			else
				return 0
			end
		end,
		p2getlc=function()
			if memory.read_u8(0x01FF00, "WRAM") == 8 then -- SMB3
				if memory.read_u8(0x00072B, "WRAM") == 3 then
					-- we are in the battle mode-only game
					return 5 - memory.read_u8(0x0002DA, "WRAM")
					-- mario's victory count
				elseif memory.read_u8(0x00001D, "WRAM") == 18 then
					return memory.read_u8(0x000736, "WRAM") + 1
					-- we are in 2p battle mode when this == 18.
					-- Let's simply tack on a life for each player in that mode, and 'lose' it when the battle is lost.
				else
					return memory.read_u8(0x000737, "WRAM")
				end
			elseif memory.read_u8(0x01FF00, "WRAM") == 6 then -- SMB2 USA
				return 0
			elseif memory.read_u8(0x01FF00, "WRAM") == 2 or memory.read_u8(0x01FF00, "WRAM") == 4 then -- SMB1 or SMB2j
				return memory.read_u8(0x00075A, "WRAM") % 255 -- mario if 1p, luigi if 2p, 255 = they game overed
					+ memory.read_u8(0x000761, "WRAM") % 255 -- mario if 2p, 255 = they game overed, stays at 2 if in 1p
			elseif memory.read_u8(0x01FF00, "WRAM") == 10 then -- Super Mario World
				return memory.read_u8(0x000DBE, "WRAM") -- active player's lives
			else
				return 0
			end
		end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function()
			if memory.read_u8(0x01FF00, "WRAM") == 2 or memory.read_u8(0x01FF00, "WRAM") == 4 then
				return 68 -- SMB1, SMB2J
			elseif memory.read_u8(0x01FF00, "WRAM") == 6 then
				return 69 -- SMB2U
			elseif memory.read_u8(0x01FF00, "WRAM") == 8 then
				return 68 -- SMB3
			elseif memory.read_u8(0x01FF00, "WRAM") == 10 then
				return 68 -- SMW
			else
				return nil
			end
		end,
		p1livesaddr=function()
			if memory.read_u8(0x01FF00, "WRAM") == 2 or memory.read_u8(0x01FF00, "WRAM") == 4 then
				return 0x00075A -- SMB1, SMB2J
			elseif memory.read_u8(0x01FF00, "WRAM") == 6 then
				return 0x0004EE -- SMB2U
			elseif memory.read_u8(0x01FF00, "WRAM") == 8 then
				return 0x000736 -- SMB3
			elseif memory.read_u8(0x01FF00, "WRAM") == 10 then
				return 0x000DBE -- SMW
			else
				return nil
			end
		end,
		p2livesaddr=function()
			if memory.read_u8(0x01FF00, "WRAM") == 2 then
				return 0x000761 -- SMB1
			elseif memory.read_u8(0x01FF00, "WRAM") == 8 then
				return 0x000737 -- SMB3
			elseif memory.read_u8(0x01FF00, "WRAM") == 10 then
				return 0x000DB5 -- SMW
			else
				return nil
			end
		end,
		ActiveP1=function()
			if (memory.read_u8(0x01FF00, "WRAM") == 2 or memory.read_u8(0x01FF00, "WRAM") == 4) then
				return memory.read_u8(0x00075A, "WRAM") > 0 and memory.read_u8(0x00075A, "WRAM") < 255 -- SMB1, SMB2J
			elseif memory.read_u8(0x01FF00, "WRAM") == 6 then
				return memory.read_u8(0x0004EE, "WRAM") > 0 and memory.read_u8(0x0004EE, "WRAM") < 255 -- SMB2U
			elseif memory.read_u8(0x01FF00, "WRAM") == 8 then
				return memory.read_u8(0x000736, "WRAM") > 0 and memory.read_u8(0x000736, "WRAM") < 255 -- SMB3
			elseif memory.read_u8(0x01FF00, "WRAM") == 10 then
				return memory.read_u8(0x000DB4, "WRAM") > 0 and memory.read_u8(0x000DBE, "WRAM") < 255 -- SMW
			else
				return false
			end
		end,
		ActiveP2=function()
			if memory.read_u8(0x01FF00, "WRAM") == 2 then
				return memory.read_u8(0x000761, "WRAM") > 0 and memory.read_u8(0x000761, "WRAM") < 255 -- SMB1
			elseif memory.read_u8(0x01FF00, "WRAM") == 8 then
				return memory.read_u8(0x000737, "WRAM") > 0 and memory.read_u8(0x000737, "WRAM") < 255 -- SMB3
			elseif memory.read_u8(0x01FF00, "WRAM") == 10 then
				return memory.read_u8(0x000DB5, "WRAM") > 0 and memory.read_u8(0x000DB5, "WRAM") < 255 -- SMB3
			else
				return false
			end
		end,
	},
	['SML1_GB']={ -- Super Mario Land, including DX hack for Game Boy Color
		func=sml1_swap,
		getsmlsize=function() return memory.read_u8(0x19, "HRAM") end,
		getlives=function() return
			math.floor(memory.read_u8(0x1A15, "WRAM")/16)*10 +
			(memory.read_u8(0x1A15, "WRAM") % 16)
		end, -- this is actually a hex value that just skips A-F on screen. Transformed.
		getgameover=function() return memory.read_u8(0x00A4, "WRAM") end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x1A15 end,
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 106 end,
		ActiveP1=function() return memory.read_u8(0x1A15, "WRAM") > 0 and memory.read_u8(0x033C, "WRAM") < 255 end,
	},
	['SML2_GB']={ -- Super Mario Land 2: 6 Golden Coins, including DX hack for Game Boy Color
		func=singleplayer_withlives_swap,
		p1gethp = function()
			if memory.read_u8(0x0216, "CartRAM") < 4 and memory.read_u8(0x0216, "CartRAM") > 1 then
				-- bunny = 2, fire flower = 3
				return 3
			else
				return memory.read_u8(0x0216, "CartRAM") + 1
				-- 1 is Big Mario/Luigi, 0 is small, 4+ is junk data, adding 1 to help with swap on small not relying on life lost
			end
		end,
		p1getlc=function() return
			math.floor(memory.read_u8(0x022C, "CartRAM")/16)*10 +
			(memory.read_u8(0x022C, "CartRAM") % 16)
		end, -- this is actually a hex value that just skips A-F on screen. Transformed.
		maxhp=function() return 3 end,
		gettogglecheck=function() return memory.read_u8(0x0266, "CartRAM") == 192 end, -- did the "load the map" timer just kick in?
		-- If you died suddenly as >Small Mario, your health will drop to Small Mario. Don't double swap!
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x022C end,
		LivesWhichRAM=function() return "CartRAM" end,
		maxlives=function() return 105 end,
		ActiveP1=function() return memory.read_u8(0x022C, "CartRAM") > 0 and memory.read_u8(0x022C, "CartRAM") < 255 end,
	},
	['SMW2YI_SNES']={ -- Super Mario World 2: Yoshi's Island
		func=iframe_health_swap,
		is_valid_gamestate=function() return
			(memory.read_u16_le(0x0118, "WRAM") >= 15 and memory.read_u16_le(0x0118, "WRAM") <= 20 )
			-- actively in a level or on retry screen
			or (memory.read_u16_le(0x0118, "WRAM") == 48)
			-- in a mini battle
		end,
		get_iframes=function(settings)
			if memory.read_u8(0x0118, "WRAM") == 48 then
			-- in a mini battle
				if memory.read_u8(0x03A7, "WRAM") == 0 or 
					memory.read_u8(0x03A7, "WRAM") == 2 or 
					memory.read_u8(0x03A7, "WRAM") == 4 or 
					memory.read_u8(0x03A7, "WRAM") == 22
				-- throwing balloons (includes 22, for 2p)
				then
					if memory.read_u8(0x1166, "WRAM") == 0 then
					-- WRAM 0x1166 ticks down to 0 while Bandit completes combo to send over
					-- so, if this is ever >0, it's Bandit's mistake and should NOT shuffle
						return memory.read_u8(0x118A, "WRAM")
						-- if wrong answer or out of time (any player)
						-- this jumps up to 32 and counts down to 0 - this is basically iframes!
					end
				end
				if memory.read_u8(0x03A7, "WRAM") == 20 then
				-- 2p watermelon contest
					return memory.read_u8(0x01D6, "CARTRAM") + memory.read_u8(0x1B52, "CARTRAM")
				-- use actual 1p PLUS 2p iframes in 2p watermelon contest
				end
				return memory.read_u8(0x01D6, "CARTRAM")
				-- all other mini battles will use actual 1p iframes ONLY
				-- this applies to 8 gather coins, 10/12 popping balloons, 18 1p watermelon contest
				-- Bandit inherits 2p's iframes in other battles
				-- can we simplify this? 0x1166 never changes in other minigames
			end
			if memory.read_u8(0x00AE, "CARTRAM") == 0x000E then
			-- morphed into Ski Yoshi
				return memory.read_u8(0x0180, "CARTRAM")
				-- this value ticks up to 128 when Ski Yoshi hits an object
				-- and turns over to 0 when Ski Yoshi regains control
				-- don't use it elsewhere, it handles rotation for the helicopter, etc.
			end
			if memory.read_u8(0x00AE, "CARTRAM") > 0 then
			-- morphed into a different non-Yoshi form, including Powerful Mario
				return memory.read_u8(0x01D6, "CARTRAM")
				-- use actual iframes
			end
			return memory.read_u8(0x0CCC, "WRAM") end,
			-- technically this is the recoil timer and not iframes, but otherwise we'd shuffle twice from piranha plants
			-- actual iframes at 0x01D6 CARTRAM
			-- recoil frames at 0x0CCC WRAM
		other_swaps=function()
			-- touching a bandit changes baby state but not recoil or iframes
			-- getting eaten by a piranha plant changes baby state
			-- getting spat out by a piranha plant sets iframes but not recoil
			local baby_status = memory.read_u16_le(0x01B2, "CARTRAM")
			local cutscene_status = memory.read_u8(0x0387, "WRAM") 
			local _, incutscene_curr, incutscene_prev = update_prev("incutscene", cutscene_status == 1)
			-- 1 if in cutscene, 0 if not
			local _, baby_safe_curr, baby_safe_prev = update_prev("baby_safe", baby_status == 0x2000 or baby_status == 0x8000 or incutscene_curr == true)
			-- 0x0000 freefloating, 0x2000 super star, 0x4000 held by bandit/frog/etc, 0x8000 on yoshi's back
			-- if detached due to cutscene, such as goal ring, do not shuffle
			local inpiranha_changed, inpiranha_curr, inpiranha_prev = update_prev("inpiranha", memory.read_u8(0x00AC, "CARTRAM"))
			-- CARTRAM 0x00AC: 0x001A, or inpiranha here, actually corresponds to
			-- "Dying in pit / inside piranha plant / receiving boss key / shrinking during Prince Froggy"
			-- (thanks SMW Central)
			-- SO, if this address turns to 0x001A, shuffle. If it ALREADY is 0x001A, don't shuffle on baby detach!
			-- Prince Froggy deals cutscene damage 
			-- note: this is funny but not fun to shuffle on, so we make an exception for exiting a different "in-cutscene" status (address == 0x02) straight into "piranha'd"
			-- because in practice, you otherwise will never go straight from "in a cutscene" to "in a piranha plant" on the next frame
			if inpiranha_changed and inpiranha_curr == 0x1A and (inpiranha_prev ~= 0x1A and inpiranha_prev ~= 0x02) and not incutscene_curr then
				return true
			end
			if not baby_safe_curr and baby_safe_prev and not (inpiranha_curr == 0x1A) then
				return true
			end
			-- Dying in pit properly shuffles due to lives tracking
			-- Key get properly does NOT shuffle due to incutscene_curr == true
			local squished_changed, squished_curr, squished_prev = update_prev("squished", memory.read_u8(0x00AC, "CARTRAM") == 0x12)
			-- 0x12 when Yoshi has been crushed by a wall, which doesn't trigger iframes
			if squished_changed and squished_curr then
				return true
			end
			local WonAtThrow1p_status = memory.read_u8(0x10F8, "WRAM") 
			-- 0x10F8 goes to 1 if 1p beats CPU at throwing balloons, don't shuffle, that's a win
			local HumanLostMiniBattle_status = memory.read_u8(0x10F4, "WRAM") 
			-- 0x10F4 goes to 1 on mini battle ending, if a human loses outside that scenario
			local _, WonAtThrow1p_curr, WonAtThrow1p_prev = update_prev("WonAtThrow1p", WonAtThrow1p_status == 1)
			local _, HumanLostMiniBattle_curr, HumanLostMiniBattle_prev = update_prev("HumanLostMiniBattle", HumanLostMiniBattle_status == 1)
			if memory.read_u8(0x0118, "WRAM") == 48 
			-- we're in a mini battle, so let's shuffle when a human loses
				and not (memory.read_u8(0x03A7, "WRAM") == 18 or memory.read_u8(0x03A7, "WRAM") == 20)
				--for watermelon contest, iframes for the last hit will suffice, no need to double-swap on iframes + loss
				then
					if HumanLostMiniBattle_curr and not HumanLostMiniBattle_prev and not WonAtThrow1p_curr then
						return true
					end
			end
			local lives_changed, lives_curr, lives_prev = update_prev("lives", memory.read_u8(0x000379, "WRAM"))
			local _, bonus_id_curr = update_prev("bonus_id", memory.read_u8(0x0212, "WRAM"))
			local _, in_bonus_curr = update_prev("in_bonus", memory.read_u8(0x0118, "WRAM"))
			-- 0x2C == in bonus game, 0x30 == in mini battle
			return lives_changed and lives_curr < lives_prev and not (bonus_id_curr == 8 and in_bonus_curr == 0x2C)
			-- don't shuffle for gambling lives in roulette until we get a bonus challenge toggle going
		end,
		-- - bonus game notes, if i ever add shuffling on them
		-- WRAM 0x0212: bonus id
		-- 0 flip cards, 2 scratch and match, 4 drawing lots, 6 match cards, 8 roulette, 10 slot machine
		-- - flip cards
		-- WRAM 0x10F3: contents of latest card (10 = kamek), updated on button press
		-- WRAM 0x10F4: card flip animation, 65528 when done
		-- WRAM 0x1100: item count
		-- 0x10F3 == 10 and 0x10F4 == 65528 and 0x1100 > 0
		-- hit kamek with items in reserve
		-- - roulette
		-- WRAM 0x1179-0x117B: lives won (one byte per digit)
		-- WRAM 0x117F: end flag
		-- 0x1179 == 0, 0x117A == 0, 0x117B == 0, 0x117F == 1
		-- roulette ended with 0 lives
		-- need to disable lives check while in roulette
		-- - throwing balloons
		-- WRAM 0x1154: always 16 after losing?
		-- - dizzy shuffle?
		-- Per SMW Central, $701FE8, 2 bytes, Timer for fuzzy dizzy effect, starts at $400
		-- this would have to be a user option because i feel like it'll suck!
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x0379 end,
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- P1 is always active!
		DisableExtraSwaps=function() return (memory.read_u8(0x0118, "WRAM") == 48) end,
	},
	['SM64_N64']={ -- Super Mario 64
		func=singleplayer_withlives_swap,
		p1gethp=function()
			if memory.read_u16_be(0x33B17E, "RDRAM") == 6440 or
				memory.read_u16_be(0x33B17E, "RDRAM") == 6442 or
				memory.read_u16_be(0x33B17E, "RDRAM") == 6444
			then
				-- these RAM values for "mario state" apply when Mario's being thrown out of a painting after death
				-- Mario's health gets set to 1 if he dies from falling/quicksand, not 0,
				-- so there will be two swaps (hp lost + life lost) unless we account for that
				return 0
			else
				return memory.read_u8(0x33B21E, "RDRAM")
			end
		end,
		p1getlc=function() return memory.read_u8(0x33B21D, "RDRAM") end,
		maxhp=function() return 8 end,
		delay=10, -- handles health ticking down from big falls, hits for >1 hp, etc.
		gmode=function() return memory.read_u8(0x33B173, "RDRAM") > 0 end, -- "mario status" variable, 0 if game hasn't started
		gettogglecheck=function() return
			memory.read_u8(0x33B173, "RDRAM") > 0
			-- Mario is in water or haze
			and memory.read_u8(0x33B21F, "RDRAM") >= 252
			-- we just reset the air timer - this should ignore health drops on losing air
			-- (0->FF on losing health, x4 speed in haze, x3 in ice water).
		end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x33B21D end,
		LivesWhichRAM=function() return "RDRAM" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return memory.read_u8(0x33B173, "RDRAM") > 0 end,
	},
	['SM64NonStop_N64']={ -- Super Mario 64 (Better Non-Stop Hack)
		func=singleplayer_withlives_swap,
		p1gethp=function()
			if memory.read_u16_be(0x33B19E, "RDRAM") == 6440 or
				memory.read_u16_be(0x33B19E, "RDRAM") == 6442 or
				memory.read_u16_be(0x33B19E, "RDRAM") == 6444
			then
				-- these RAM values for "mario state" apply when Mario's being thrown out of a painting after death
				-- Mario's health gets set to 1 if he dies from falling/quicksand, not 0,
				-- so there will be two swaps (hp lost + life lost) unless we account for that
				return 0
			else
				return memory.read_u8(0x33B23E, "RDRAM")
			end
		end,
		p1getlc=function() return memory.read_u8(0x33B23D, "RDRAM") end,
		maxhp=function() return 8 end,
		delay=10, -- handles health ticking down from big falls, hits for >1 hp, etc.
		gmode=function() return memory.read_u8(0x33B193, "RDRAM") > 0 end, -- "mario status" variable, 0 if game hasn't started
		gettogglecheck=function() return
			memory.read_u8(0x33B193, "RDRAM") > 0
			-- Mario is in water or haze
			and memory.read_u8(0x33B23F, "RDRAM") >= 252
			-- we just reset the air timer - this should ignore health drops on losing air
			-- (0->FF on losing health, x4 speed in haze, x3 in ice water).
		end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x33B23D end,
		LivesWhichRAM=function() return "RDRAM" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return memory.read_u8(0x33B193, "RDRAM") > 0 end,
	},
	['NSMB_DS'] = { -- New Super Mario Bros (DS)
		func = mario_swap,
		get_lives = function() return memory.read_u8(0x08B364, "Main RAM") end,
		-- use this status value as it changes after death instead of before
		-- thus the gamestate check will filter the status change, but not the life change
		get_status = function() return memory.read_u8(0x1B7187, "Main RAM") end,
		-- shell -> big, fire -> big, big -> small
		damage_table = {[5] = 1, [2] = 1, [1] = 0},
		-- we're actually in a level
		is_valid_gamestate = function() return memory.read_u32_le(0x03BD34, "Main RAM") == 3 end,
		-- Infinite* Lives section
		CanHaveInfiniteLives = true,
		p1livesaddr = function() return 0x08B364 end,
		LivesWhichRAM = function() return "Main RAM" end,
		maxlives = function() return 69 end,
		ActiveP1 = function()
			local gamestate = memory.read_u32_le(0x03BD34, "Main RAM")
			-- lives can be set on the map screen as well
			return gamestate == 3 or gamestate == 9
		end,
		-- OTHER NOTES:
		-- 0x03BD34 fairly consistent game situation: 3 level, 9 map, 4 main menu, + others
		-- in-level status is stored at 0x1B7187 and also 0x1B7188
		-- different status location for on the world map, values get copied around
		-- status values are: 0 small, 1 big, 2 fire, 3 mega, 4 mini, 5 shell
		-- the only real damage you take in mini and mega form is a death so lives handle them
		-- 0x08B32C powerup stored: 0 none, 1 mush, 2 flower, 3 shell, 4 mini, 5 mega
		-- 5 lives on title, then lives loaded from save file on selection
		-- the two status values change at different times:
		-- on damage, 0x1B7187 records the change a frame before 0x1B7188
		-- on death, 0x1B7188 is set to zero first
		--   then 0x08B364 decreases and 0x1B718F goes 0 -> 1
		--   then 0x1B7187 is set to zero and 0x1B718F goes 1 -> 0
		-- on return to map, 0x1B7187 and 0x1B7188 both get zeroed out same frame. joy.
		-- requiring the 0x03BD34 value of 3 filters this nonsense thankfully
	},
	['FZERO_SNES']={ -- F-ZERO, SNES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_s16_le(0x00C9, "WRAM") end,
		p1getlc=function() return 1 end,
		-- health function will take care of lives.
		-- health drops to 0 on loading from losing a life (like when you go over a cliff).
		maxhp=function() return 2048 end,
		minhp=-40, -- F-ZERO health value can be negative, who knew...
		delay=30,
		-- because F-ZERO can drain health continuously on every frame,
		-- you want to build in some kind of sane delay before swapping.
		gmode=function() return
			memory.read_u8(0x0054, "WRAM") == 2 -- gamestate = "racing,"
			and memory.read_u8(0x0055, "WRAM") == 3 -- and the race has started
			and memory.read_u8(0x00C8, "WRAM") == 0 -- and invulnerability frames are done (0)
		end,
		gettogglecheck=function() return memory.read_u8(0x0054, "WRAM") end,
		-- if gamestate is being changed, sometimes health drops to 0, so don't swap on that frame
		grace=120, -- give 2 seconds for reorienting on returning from a swap, let's not go higher than this

		--FUTURE POSSIBLE REVISION
		--func=fzero_snes_swap,
		--gethittingwall=function() return memory.read_u8(0x00F5, "WRAM") end,
		--getinvuln=function() return memory.read_u8(0x00C8, "WRAM") end,
		--getbump=function() return memory.read_u8(0x00E0, "WRAM") end,
		--delay=30, -- because F-ZERO can drain health continuously on every frame, you want to build in some kind of sane delay before swapping. WILL REQUIRE IMPLEMENTING A COUNTDOWN
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "WRAM" end,
		p1livesaddr=function() return 0x0059 end,
		maxlives=function() return 8 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['CV1_NES']={ -- Castlevania I, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x0045, "RAM") end,
		p1getlc=function() return memory.read_u8(0x002A, "RAM") end,
		maxhp=function() return 64 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		MustDoInfiniteLivesOnFrame=function() return false end,
		p1livesaddr=function() return 0x002A end,
		maxlives=function() return 70 end,
		ActiveP1=function() return memory.read_u8(0x0045, "RAM") == 0 or memory.read_u8(0x0045, "RAM") == 64 end,
	},
	['CV1_deathcounter_NES']={ -- Castlevania I, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x0045, "RAM") end,
		p1getlc=function() 
			if memory.read_u8(0x002A, "RAM") > 0 then 
				return memory.read_u8(0x002A, "RAM") * -1
			end
			return -1
		end,
		-- a clever trick to get past the title screen starting you on 0 deaths and ticking you up to 1 on game start
		maxhp=function() return 64 end,
		CanHaveInfiniteLives=false, -- the lives count up, not down, so they are already infinite
	},
	['CV2_NES']={ -- Castlevania II, NES
		func=iframe_health_swap,
		is_valid_gamestate=function()
			local gamestate = memory.read_u8(0x0018, "RAM")
			return gamestate >= 5 and gamestate <= 7
			-- 5 main game, 6 one frame on death, 7 game over
		end,
		get_iframes=function() return memory.read_u8(0x04F8, "RAM") end,
		get_health = function() return memory.read_u8(0x0080, "RAM") end,
		other_swaps=function()
			local lives_changed, lives_curr, lives_prev = update_prev("lives", memory.read_u8(0x0031, "RAM"))
			-- for some reason, non-game over deaths from enemy damage tick lives down in gamestate 5,
			-- damage game overs tick lives down in gamestate 7, and pit deaths tick lives down in gamestate 6
			-- damage deaths shuffle already, so only shuffle on lives dropping from falling in a pit
			return lives_changed and lives_curr < lives_prev and memory.read_u8(0x0018, "RAM") == 6
		end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		MustDoInfiniteLivesOnFrame=function() return true end,
		p1livesaddr=function() return 0x0031 end,
		maxlives=function() return 9 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['CV3_NES']={ -- Castlevania III, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x003C, "RAM") end,
		p1getlc=function() return
			math.floor(memory.read_u8(0x0035, "RAM")/16)*10 +
			(memory.read_u8(0x0035, "RAM") % 16)
			-- this is actually a hex value that just skips A-F on screen. Transformed.
		end,
		maxhp=function() return 64 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x0035 end,
		maxlives=function() return 105 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['CV3_FAMI']={ -- Castlevania III, Famicom or NES-JP with English translation patch
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x004A, "RAM") end,
		p1getlc=function() return
			math.floor(memory.read_u8(0x0037, "RAM")/16)*10 +
			(memory.read_u8(0x0037, "RAM") % 16)
			-- this is actually a hex value that just skips A-F on screen. Transformed.
		end,
		maxhp=function() return 64 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x0037 end,
		maxlives=function() return 105 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['CV4_SNES']={ -- Super Castlevania IV, SNES
		func=singleplayer_withlives_swap,
		-- 0x0032: active gameplay == 4, demo == 2, password == 6
		-- most importantly, ending == 7, and HP drops to 0 during transitions there (sometimes lives do as well)
		gmode=function() return memory.read_u8(0x0032, "WRAM") == 4 end,
		p1gethp=function() return memory.read_u8(0x13F4, "WRAM") end,
		p1getlc=function() return memory.read_u8(0x007C, "WRAM") end,
		maxhp=function() return 16 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "WRAM" end,
		p1livesaddr=function() return 0x007C end,
		maxlives=function() return 106 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['BLOODLINES_GEN']={ -- Castlevania: Bloodlines, Genesis
		func=singleplayer_withlives_swap,
		-- 0x9002: active gameplay == 9, main menu == 4, options == 5
		-- other relevant values include 12 and 13 for ending, where HP drops to 1
		gmode=function() return memory.read_u16_be(0x9002, "68K RAM") == 9 end,
		p1gethp=function() return memory.read_u8(0x9C11, "68K RAM") end,
		p1getlc=function() return memory.read_u8(0xFB2F, "68K RAM") end,
		maxhp=function() return 80 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "68K RAM" end,
		p1livesaddr=function() return 0xFB2F end,
		maxlives=function() return 0x69 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['DRACULAX_SNES']={ -- Dracula X, SNES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u16_le(0x0000A8, "WRAM") end,
		p1getlc=function() return
			math.floor(memory.read_u8(0x00009E, "WRAM")/16)*10 +
			(memory.read_u8(0x00009E, "WRAM") % 16)
			-- this is actually a hex value that just skips A-F on screen. Transformed.
		end,
		maxhp=function() return 64 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "WRAM" end,
		p1livesaddr=function() return 0x00009E end,
		maxlives=function() return 105 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['RONDO_TG16']={ -- Rondo of Blood, TG16 CD
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x0098, "Main Memory") end,
		p1getlc=function() return memory.read_u8(0x008D, "Main Memory") end,
		maxhp=function() return 92 end,
		gmode=function() return memory.read_u8(0x0030, "Main Memory") == 5 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "Main Memory" end,
		p1livesaddr=function() return 0x008D end,
		maxlives=function() return 105 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['CV_AoS']={ -- Aria of Sorrow, GBA
		-- touching enemy during invincibility from final guard soul, julius backdash etc gives iframes despite not doing damage
		-- dryad seed and succubus grab are weird about iframes
		-- so forget the iframes
		-- dryad and succubus will shuffle you repeatedly but stop on their own over time
		func=health_swap,
		is_valid_gamestate=function()
			return memory.read_u8(0x000010, "EWRAM") == 4 -- in game
				and memory.read_u16_le(0x000E3C, "EWRAM") == 0 -- not paused, so eating rotten food won't swap
				-- there are multiple addresses that seem tied to pausing
				-- and memory.read_u16_le(0x00055C, "EWRAM") ~= 1 -- picking up heart/money gives 1 iframe, don't shuffle there
		end,
		-- get_iframes=function() return memory.read_u16_le(0x00055C, "EWRAM") end,
		get_health=function() return memory.read_u16_le(0x01327A, "EWRAM") end,
		other_swaps=function() return false end,
	},
	['CV_DoS']={ -- Dawn of Sorrow, DS
		-- checking for iframes to not swap on devil soul use etc
		func=iframe_health_swap,
		is_valid_gamestate=function() return memory.read_u8(0x0C07E8, "Main RAM") == 2 end,
			-- 0x0CA9F3: iframes
			-- 0x0CA9F4: also acts like iframes; noted on damage by Aguni (getting hit by downward dive, also some side movement)
			-- 0x0CAA24: pops up to 1 at times for using certain moves but also works like iframes for spikes
				-- with non-spike damage, can pop up to nearly the same number as 0x0CA9F3 (offset by 1) and count down simultaneously
		get_iframes=function() return memory.read_u8(0x0CA9F3, "Main RAM") -- "normal" iframes
			+ memory.read_u8(0x0CA9F4, "Main RAM") 
			+ memory.read_u8(0x0CAA24, "Main RAM")
		end,
		iframe_minimum=function() return 1 end,
		get_health=function() return memory.read_u16_le(0x0F7410, "Main RAM") end,
		other_swaps=function() return false end,
		grace=60,
	},
	['CV_PoR']={ -- Portrait of Ruin, DS
		func=jonathan_charlotte_swap,
		is_valid_gamestate=function() return memory.read_u8(0x0F6284, "Main RAM") == 2 end,
		-- hopefully this works for richter/sisters/etc too, bizhawk won't let me import saves for ds games
		is_jonathan=function() return memory.read_u8(0x1120E2, "Main RAM") == 1 end,
		get_jonathan_iframes=function() return memory.read_u8(0x0FCB45, "Main RAM") end,
		get_charlotte_iframes=function() return memory.read_u8(0x0FCCA5, "Main RAM") end,
		get_health=function() return memory.read_u16_le(0x11216C, "Main RAM") end,
		grace=60,
	},
	['CV_OoE']={ -- Order of Ecclesia, DS
		-- checking for iframes to not swap on dominus etc (except on death)
		func=iframe_health_swap,
		is_valid_gamestate=function() return memory.read_u8(0x12872A, "Main RAM") == 3 end,
		-- hopefully this works for albus/boss rush mode too, bizhawk won't let me import saves for ds games
		get_iframes=function() return memory.read_u8(0x1098E5, "Main RAM") end,
		get_health=function() return memory.read_u16_le(0x1002B4, "Main RAM") end,
		other_swaps=function() return false end,
		grace=60,
	},
	['MetroidNes']={ -- Metroid, NES
		-- bomb jumping sets iframes, so must check health too
		-- but health decreases one frame before iframes are set
		-- so only check health, and instead of iframes, consider lava/metroid states invalid
		-- update zero mission's nes mode if you change this
		func=health_swap,
		is_valid_gamestate=function()
			return memory.read_u8(0x001D, "RAM") == 0 -- in game
				and memory.read_u8(0x001E, "RAM") == 3 -- in game
				and ((memory.read_u8(0x0064, "RAM") == 0 -- not in lava/acid
						and memory.read_u8(0x0092, "RAM") == 0) -- not being drained by a metroid
					or memory.read_u16_le(0x0106, "RAM") == 0) -- 0 hp, want to shuffle on lava/metroid death
		end,
		-- get_iframes=function() return memory.read_u8(0x0070, "RAM") end,
		get_health=function() return memory.read_u16_le(0x0106, "RAM") end,
		-- technically this isn't your *actual* health, it's stored in decimal mode, but for our comparison purposes it works
		other_swaps=function()
			-- shuffle if escape timer runs out
			local time_up_changed, time_up_curr, _ = update_prev('time up', memory.read_u16_le(0x010A, "RAM") == 0xFF00)
			-- set to 0xFFFF when timer is off, counts down in decimal mode from 0x9999 while on, set to 0xFF00 when time runs out
			return time_up_changed and time_up_curr
		end,
		grace=60,
	},
	['Metroid2']={ -- Metroid II Return of Samus, GB
		func=iframe_health_swap,
		is_valid_gamestate=function() return memory.read_u8(0x1B, "HRAM") == 4 end,
		get_iframes=function() return memory.read_u8(0x104F, "WRAM") end,
		get_health=function() return memory.read_u16_le(0x1051, "WRAM") end,
		-- like nes metroid, health is stored in decimal mode
		other_swaps=function() return false end,
		-- no escape sequence this game
		grace=60,
	},
	['MetroidFusion']={ -- Metroid Fusion, GBA
		func=iframe_health_swap,
		is_valid_gamestate=function()
			return memory.read_u8(0x0BDE, "IWRAM") == 1
				-- don't shuffle on omega metroid forced hit
				and not (memory.read_u8(0x002C, "IWRAM") == 0 -- area id: main deck
					and memory.read_u8(0x002D, "IWRAM") == 63 -- room id: omega metroid room
					and memory.read_u16_le(0x1310, "IWRAM") == 1 -- hp: omega metroid forced hit takes hp to 1
					and memory.read_u8(0x1249, "IWRAM") == 48) -- iframes: you should still shuffle from time up while at 1 hp
		end,
		get_iframes=function() return memory.read_u8(0x1249, "IWRAM") end,
		get_health=function() return memory.read_u16_le(0x1310, "IWRAM") end,
		iframe_minimum=function() return 30 end,
		-- SRX amoebas, TRO leech boss, TRO plant boss flowers, electric water
		-- all do damage with short iframes (4) rather than skipping iframes entirely like lava/heat
		-- Ridley's grab does this too, repeatedly popping up to 29 iframes on hitting 0
		-- normal damage for shuffing triggers 48 iframes
		-- in other words, requiring iframes >=30 to swap should be fine here
		other_swaps=function()
			-- check if we ran out of time (sector 3, secret lab, ending)
			local time_up_changed, time_up_curr, _ = update_prev('time up', memory.read_u8(0x08D7, "IWRAM") == 2)
			-- 0: no timer, 1: timer on, 2: timer just ran out
			return time_up_changed and time_up_curr, 65
			-- add extra delay so you get the whiteout animation before shuffling
		end,
		grace=60,
	},
	['MetroidZero']={ -- Metroid Zero Mission, GBA
		func=iframe_health_swap,
		is_valid_gamestate=function()
			return memory.read_u8(0x0C70, "IWRAM") == 4 -- main game
				or memory.read_u8(0x0C70, "IWRAM") == 7 -- nes metroid
		end,
		get_iframes=function()
			if memory.read_u8(0x0C70, "IWRAM") == 7 then -- nes metroid
				return 0 -- don't use the main shuffle function in nes metroid
			end
			return memory.read_u8(0x13DA, "IWRAM")
		end,
		get_health=function()
			if memory.read_u8(0x0C70, "IWRAM") == 7 then -- nes metroid
				return 1 -- don't use the main shuffle function in nes metroid
			end
			return memory.read_u16_le(0x1536, "IWRAM")
		end,
		iframe_minimum=function() return 16 end,
		-- hp-draining purple bugs do 15 iframes, metroids do 3
		other_swaps=function()
			-- check if we ran out of time (mother brain, mecha-ridley)
			local time_up_changed, time_up_curr, _ = update_prev('time up', memory.read_u8(0x095C, "IWRAM") == 2)
			-- 0: no timer, 1: timer on, 2: timer just ran out
			if time_up_changed and time_up_curr then
				return true, 65
				-- add extra delay so you get the whiteout animation before shuffling
			end
			-- nes metroid shuffle, ram offsets are +0x7200 from nes version
			-- update nes metroid section if you change this
			--local nes_health_changed, nes_health_curr, nes_health_prev
			--local nes_time_up_changed, nes_time_up_curr
			if memory.read_u8(0x0C70, "IWRAM") == 7 then
				local nes_health_changed, nes_health_curr, nes_health_prev = update_prev('nes health', memory.read_u16_le(0x7306, "IWRAM"))
				local nes_time_up_changed, nes_time_up_curr, _ = update_prev('nes time up', memory.read_u16_le(0x730A, "IWRAM") == 0xFF00)
				return memory.read_u8(0x721D, "IWRAM") == 0 -- in game
					and memory.read_u8(0x721E, "IWRAM") == 3 -- in game
					and ((memory.read_u8(0x7264, "IWRAM") == 0 -- not in lava/acid
							and memory.read_u8(0x7292, "IWRAM") == 0) -- not being drained by a metroid
						or memory.read_u16_le(0x7306, "IWRAM") == 0) -- 0 hp, want to shuffle on lava/metroid death
					and ((nes_health_changed and nes_health_curr < nes_health_prev) -- hp dropped
						or (nes_time_up_changed and nes_time_up_curr)) -- escape timer ran out
			end
			return false
		end,
		grace=60,
	},
	['Zelda_1']={ -- The Legend of Zelda, NES
		func=iframe_health_swap,
		is_valid_gamestate=function()
			local gamestate = memory.read_u8(0x0012, "RAM")
			return gamestate == 5 or gamestate == 9 or gamestate == 17
			-- 5: main game, 9: side-scrolling, 17: dying (set same frame as health reaching 0)
		end,
		get_iframes=function() return memory.read_u8(0x04F0, "RAM") end,
		get_health=function()
			local fullHearts = memory.read_u8(0x066F, "RAM") & 0x0F
			-- other half of this byte tracks max health
			local partialHeart = memory.read_u8(0x0670, "RAM")
			return fullHearts * 0x100 + partialHeart
		end,
		other_swaps=function() return false end,
	},
	['Zelda_2']={ -- Zelda II The Adventure of Link, NES
		func=iframe_health_swap,
		is_valid_gamestate=function()
			local gamestate = memory.read_u8(0x0736, "RAM")
			return gamestate == 11 -- main game
				or gamestate == 4 -- lives reduced after death
		end,
		get_iframes=function() return memory.read_u8(0x050C, "RAM") end,
		get_health=function() return memory.read_u8(0x0774, "RAM") end,
		other_swaps=function()
			-- we shuffle on death from enemies bringing us to 0 health,
			-- but we need to shuffle on dying from pits too
			-- while zelda 2 has two addresses storing health values,
			-- one of which resets when lives decrease and the other when link respawns,
			-- zelda 2 redux removes the second one of these, so we must track what the value was last frame
			local lives_changed, lives_curr, lives_prev = update_prev('lives', memory.read_u8(0x0700, "RAM"))
			local _, _, health_prev = update_prev('health 2', memory.read_u8(0x0774, "RAM"))
			return lives_changed and lives_curr < lives_prev -- we have died
				and health_prev ~= 0 -- died from instant death
		end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x0700 end,
		maxlives=function() return 8 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['Zelda_LA']={ -- Link's Awakening (DX), GB/GBC
		-- instead of damage directly lowering health, it's put into a "damage buffer" that then lowers health per frame
		-- we can't rely on iframes alone, since walking into deep water without flippers sets iframes but does no damage
		-- so check that iframes are set and damage buffer increased
		func=damage_buffer_swap,
		is_valid_gamestate=function() return memory.read_u8(0x1B95, "WRAM") == 11 end,
		get_iframes=function() return memory.read_u8(0x1BC7, "WRAM") end,
		-- get_health=function() return memory.read_u8(0x1B5A, "WRAM") end,
		get_damage_buffer=function() return memory.read_u8(0x1B94, "WRAM") end,
		other_swaps=function() return false end,
	},
	['Zelda_Ocarina_10']={ -- Ocarina of Time, N64 (1.0)
		func=ocarina_swap,
		get_savefile=function() return memory.read_u8(0x11B927, "RDRAM") end,
		get_max_health=function() return memory.read_u16_be(0x11A5FE, "RDRAM") end,
		-- get_iframes=function() return memory.read_u8(0x1DB498, "RDRAM") end,
		get_health=function() return memory.read_u16_be(0x11A600, "RDRAM") end,
		-- is_link_grabbed=function() return (memory.read_u8(0x1DB0A3, "RDRAM") & 0x80) == 0x80 end,
		-- get_respawn_flag=function() return memory.read_u8(0x11B937, "RDRAM") end,
		get_text_id=function() return memory.read_u16_be(0x1D8870, "RDRAM") end,
		grace=50, -- enough frames to react to damage over time, ReDeads
	},
	['Zelda_Ocarina_11']={ -- Ocarina of Time, N64 (1.1)
		func=ocarina_swap,
		get_savefile=function() return memory.read_u8(0x11BAE7, "RDRAM") end,
		get_max_health=function() return memory.read_u16_be(0x11A7BE, "RDRAM") end,
		get_health=function() return memory.read_u16_be(0x11A7C0, "RDRAM") end,
		get_text_id=function() return memory.read_u16_be(0x1D8A30, "RDRAM") end,
		grace=50, -- enough frames to react to damage over time, ReDeads
	},
	['Zelda_Ocarina_12']={ -- Ocarina of Time, N64 (1.2)
		func=ocarina_swap,
		get_savefile=function() return memory.read_u8(0x11BFD7, "RDRAM") end,
		get_max_health=function() return memory.read_u16_be(0x11ACAE, "RDRAM") end,
		get_health=function() return memory.read_u16_be(0x11ACB0, "RDRAM") end,
		get_text_id=function() return memory.read_u16_be(0x1D9130, "RDRAM") end,
		grace=50, -- enough frames to react to damage over time, ReDeads
	},
	['Zelda_Ocarina_GC']={ -- Ocarina of Time, N64 (GameCube version)
		func=ocarina_swap,
		get_savefile=function() return memory.read_u8(0x11C49F, "RDRAM") end,
		get_max_health=function() return memory.read_u16_be(0x11B176, "RDRAM") end,
		get_health=function() return memory.read_u16_be(0x11B178, "RDRAM") end,
		get_text_id=function() return memory.read_u16_be(0x1D9A30, "RDRAM") end,
		grace=50, -- enough frames to react to damage over time, ReDeads
	},
	['Zelda_Ocarina_MQ']={ -- Ocarina of Time, N64 (Master Quest GameCube version)
		func=ocarina_swap,
		get_savefile=function() return memory.read_u8(0x11C47F, "RDRAM") end,
		get_max_health=function() return memory.read_u16_be(0x11B156, "RDRAM") end,
		get_health=function() return memory.read_u16_be(0x11B158, "RDRAM") end,
		get_text_id=function() return memory.read_u16_be(0x1D99F0, "RDRAM") end,
		grace=50, -- enough frames to react to damage over time, ReDeads
	},
	['Zelda_Majora']={
		-- big skulltulas now don't set iframes at all
		func=health_swap,
		is_valid_gamestate=function()
			local savefile = memory.read_u8(0x1F3313, "RDRAM")
			-- 0-1 for save files 1-2, 255 on title/file select/etc
			-- except! it's 0 on title if you save at an owl statue
			-- so we'll need something else to check!
			-- since memory is zero'd on reset, need to also check something that is not 0 during gameplay
			local max_hp_changed, _, _ = update_prev('max health', memory.read_u16_be(0x1EF6A4, "RDRAM"))
			-- poison water damages so fast as to be unplayable if it shuffles
			-- not entirely sure what else this address does, but it seems to consistently be 2 when in poison water
			local in_poison_water = memory.read_u8(0x74FF9B, "RDRAM") == 2
			return savefile <= 2 and not max_hp_changed and not in_poison_water
			-- title screen has 3 hearts current and max (so can't shuffle, since this lowering current hp would lower max hp)
			-- going from title to file select, the game stores file 1's hp for a frame, then file 2's until loading a file
			-- so if file 1 has 3 max hearts but not full hp, going from title to file select will shuffle
			-- if file 1 and 2 have the same max hp but 2 has lower current hp, going from title to file select will shuffle
			-- and if they have the same max hp but 1 has lower current hp, loading file 1 will shuffle
			-- if a file has less than full health on its hard save but full health on its owl save,
			-- this creates a whole new set of incorrect shuffles. nightmare
			-- please someone find a consistent "currently on file select" address/value and end this
			-- until then, just don't use owl saves during the shuffler i guess?
		end,
		get_health=function()
			local internal_health = memory.read_u16_be(0x1EF6A6, "RDRAM")
			-- 0x0: full heart
			-- 0x1-0x5: quarter heart
			-- 0x6-0xA: half heart
			-- 0xB-0xF: three quarter heart
			-- convert internal health to "quarter hearts displayed"
			-- to only shuffle when fire damage etc makes health visibly decrease
			local partialHeart = internal_health % 0x10
			local fullHearts = (internal_health - partialHeart) / 0x10
			if partialHeart == 0 then
				partialHeart = 0
			elseif partialHeart <= 5 then
				partialHeart = 1
			elseif partialHeart <= 10 then
				partialHeart = 2
			else
				partialHeart = 3
			end
			return fullHearts * 4 + partialHeart
		end,
		delay=15, -- 9 frames before damage is visible, plus extra
		other_swaps=function()
			local text_id_changed, text_id_curr, _ = update_prev('text id', memory.read_u16_be(0x3FD32C, "RDRAM"))
			-- similar to ocarina, check current textbox to determine things like minigame or stealth failure
			if text_id_changed and
				(text_id_curr == 0x27EC -- fell off deku scrub playground
				-- "Too bad. You're done!"
				or text_id_curr == 0x27EA -- took too long in deku scrub playground
				-- "Time's up. You're done!"
				or text_id_curr == 0x272E -- failed sword training
				-- "Your training is insufficient. You must jump more!"
				or text_id_curr == 0x2795 -- postman game close miss
				-- "Oh! Almost! That was a close one..."
				or text_id_curr == 0x2796 -- postman game big miss
				-- "See! I told you it's difficult!"
				or text_id_curr == 0x2797 -- postman game over 15 seconds
				-- "You're past 10 seconds!"
				or text_id_curr == 0x077D -- lost chest maze game
				-- "All right. Time's up!"
				or text_id_curr == 0x2885 -- honey and darling time up
				-- "All done."
				or text_id_curr == 0x2888 -- honey and darling fell off platform
				-- "Oh, that's why I told you..."
				or text_id_curr == 0x0833 -- caught by deku guard
				-- "Aha! An intruder!"
				or text_id_curr == 0x0A32 -- failed swamp shooting gallery
				-- "Well, looks like ya gotta try a beet hardah, mate!"
				or text_id_curr == 0x352D -- dog race lost
				-- "That was a bad choice!"
				or text_id_curr == 0x04B3 -- wrong answer in keaton quiz
				-- "Hee-hee-ho! Your training is insufficient! Come back and try again, child!"
				or text_id_curr == 0x0E93 -- lost goron race
				-- "...You're just a little stiff because winter was so long."
				or text_id_curr == 0x0E95 -- false start in goron race
				-- "Everyone, one entrant made a false start, so we must restart the race."
				or text_id_curr == 0x334B -- lost romani's horseback archery training
				-- "OK! Time's up!"
				or text_id_curr == 0x3476 -- lost gorman horse race on first/second day
				-- "Hyuh, hyuh! We win!!!"
				or text_id_curr == 0x3499 -- lost gorman horse race on final day
				-- "Heh, heh... We win!!! We're on fire!"
				or text_id_curr == 0x332F -- failed ranch defense, romani abducted
				-- "Aaiieee-Aaaaaahhh!!!"
				or text_id_curr == 0x1194 -- caught by pirate guard
				-- "Hey, you! Halt!!!"
				or text_id_curr == 0x11AE -- caught by pirate leader without stone mask
				-- "Halt! Everyone! A rat has snuck in!"
				or text_id_curr == 0x11AF -- caught by pirate leader with stone mask
				-- "Halt! Everyone! A rat wearing a strange mask has snuck in!"
				or text_id_curr == 0x10D7 -- ran out of time in beaver race
				-- "OK... Time's up!"
				or text_id_curr == 0x10DA -- cheated in beaver race (younger brother only)
				-- "You cheated, didn't you? You didn't get all the rings!"
				or text_id_curr == 0x10E9 -- cheated in beaver race (older brother present)
				-- "You cheated, didn't you? You didn't get all the rings!"
				or text_id_curr == 0x10A2 -- lost fisherman's jumping game
				-- "What do you think? It's harder than it seems, isn't it?"
				or text_id_curr == 0x146C -- failed sakon's hideout
				-- "Yesss! My security system is impenetrable"
				-- 0x087F shot koume too many times, not used since we shuffle on each hit
				-- "Hey! Hey! Hey! What are you aiming for, anyway? That's it! We're done!"
				-- there's also various "not enough targets" strings for this minigame
				-- 0x33C0 lost cremia's carriage defense, not used since we shuffle on each hit
				-- "My precious milk... It's a mess... I've failed as a ranch manager..."
				)
			then
				return true, 60
			end
			-- koume archery minigame: shuffle on hitting koume
			-- i think this address is a general 'minigame secondary score' value?
			local koume_changed, koume_curr, koume_prev = update_prev('koume hits', memory.read_u16_be(0x1F35AC, "RDRAM"))
			-- town shooting gallery: shuffle on losing time from hitting blue octorok
			local timer_changed, timer_curr, timer_prev = update_prev('minigame timer', memory.read_u16_be(0x1F345E, "RDRAM"))
			-- cremia carriage defense: shuffle on milk bottle damaged
			local milk_hp_changed, milk_hp_curr, milk_hp_prev = update_prev('milk hp',
				memory.read_u32_be(0x42E434, "RDRAM") + memory.read_u32_be(0x42E438, "RDRAM") + memory.read_u32_be(0x42E43C, "RDRAM"))
			local area_curr = memory.read_u16_be(0x3E6BC4, "RDRAM")
			if area_curr == 0 and -- 0 = southern swamp without poison
				koume_changed and koume_curr > koume_prev
			then
				return true, 15
			elseif area_curr == 0x20 and -- 0x20 = town shooting gallery
				timer_changed and timer_prev - timer_curr > 20 -- in centiseconds
				-- this won't shuffle if a blue octorok is hit in the last 0.2 seconds but how often is that happening
			then
				return true, 15
			elseif area_curr == 0x6A and -- 0x6A = gorman track
				milk_hp_changed and milk_hp_curr < milk_hp_prev and milk_hp_prev <= 12 and milk_hp_prev > 3
				-- the three milk bottles have 0 hp when not in minigame, 5 hp during the pre-minigame cutscene,
				-- start the minigame at 4 hp, and break at 1 hp
				-- this area of memory has unrelated values when not in gorman track
			then
				return true, 15
			end
			-- shuffle on moon falling
			local day_changed, day_curr, _ = update_prev('day', memory.read_u32_be(0x1EF688, "RDRAM"))
			if day_changed and day_curr == 4 then
				return true, 56*60 -- 56 seconds lets the moon fall cutscene play out and shuffles after majora's mask fades to black
			end
			return false
		end,
	},
	['Zelda_Seasons']={ -- Oracle of Seasons, GBC
		-- iframes are set one frame before health is decreased if hit by enemy
		-- HOWEVER, iframes are set the same frame health decreases if you fall in a hole
		-- and drowning sets iframes at start of drowning animation, but decreases health on respawn
		-- iframes are also set during various cutscenes for some reason
		-- so i guess we just hope there's no damage over time effects?
		func=health_swap,
		is_valid_gamestate=function()
			return memory.read_u8(0x02EE, "WRAM") == 2 -- main game
				and not (memory.read_u8(0x0C3A, "WRAM") == 1 -- maple present
					and memory.read_u8(0x0BEA, "WRAM") ~= 0) -- just bumped into maple
			-- don't want to shuffle on link's hearts being added to maple prize pool
		end,
		-- get_iframes=function() return memory.read_u8(0x102B, "WRAM") end,
		get_health=function() return memory.read_u8(0x06A2, "WRAM") end,
		other_swaps=function()
			local room_bank = memory.read_u8(0x0C49, "WRAM")
			local room_id = memory.read_u8(0x0C4C, "WRAM")
			-- shuffle on using revive potion
			local potion_curr = (memory.read_u8(0x0697, "WRAM") & 0x80) == 0x80
			local potion_changed, _, _ = update_prev('potion', potion_curr)
			if potion_changed and not potion_curr then
				return true
			end
			-- shuffle on dancing game failure because i think it's funny
			local lost_dance_changed, lost_dance_curr, _ = update_prev('lost dance', memory.read_u8(0x0FD0, "WRAM") == 0xFF)
			-- this address is used for different things depending on room, so check current room
			if room_bank == 3 and room_id == 0x95 -- in dance hall
				and lost_dance_changed and lost_dance_curr
			then
				return true, 70 -- enough time for the failure text to appear on max text speed
			end
			-- would like to shuffle on stealth segment failure but it's harder to detect than in Ages
			-- rosa after dungeon 1, brothers before dungeon 4
			-- rosa: 0x0308 == 0x26, 0x0309 == 1 (id of failure text)
			-- these addresses are in a general buffer area, cannot guarantee they won't be set in other contexts
			-- can't just check current room like for minigames since enemies or maple also show up in these rooms
			-- and may set these when not in stealth segment
			return false
		end,
	},
	['Zelda_Ages']={ -- Oracle of Ages, GBC
		-- same iframe weirdness as Seasons
		func=health_swap,
		is_valid_gamestate=function()
			return memory.read_u8(0x02EE, "WRAM") == 2 -- main game
				and not (memory.read_u8(0x0DDA, "WRAM") == 1 -- maple present
					and memory.read_u8(0x0BE9, "WRAM") ~= 0) -- just bumped into maple
			-- don't want to shuffle on link's hearts being added to maple prize pool
		end,
		-- get_iframes=function() return memory.read_u8(0x102B, "WRAM") end,
		get_health=function() return memory.read_u8(0x06AA, "WRAM") end,
		other_swaps=function()
			local room_bank = memory.read_u8(0x0C2D, "WRAM")
			local room_id = memory.read_u8(0x0C30, "WRAM")
			-- shuffle on using revive potion
			local potion_curr = (memory.read_u8(0x069F, "WRAM") & 0x80) == 0x80
			local potion_changed, _, _ = update_prev('potion', potion_curr)
			if potion_changed and not potion_curr
				and not (room_bank == 5 and room_id == 0xAD) -- king zora's throne room
				-- don't shuffle on giving potion to king zora
			then
				return true
			end
			-- got caught in ambi's palace stealth section
			if room_bank == 1 and room_id == 0x46 then -- outside ambi's palace
				local caught_curr = memory.read_u8(0x1004, "WRAM") == 15 -- link state, 15 when kicked out of palace
				-- i can't guarantee this link state is only used here, so that's why we check the room for safety
				local caught_changed, _, _ = update_prev('caught', caught_curr)
				return caught_changed and caught_curr
			end
			-- MINIGAME BLOCK
			-- what does and doesn't count for minigames is admittedly somewhat arbitrary
			-- general premise is that "score attack" games don't shuffle from just getting a low score,
			-- pass/fail games shuffle on failure, and games with "miss" states shuffle per miss
			if room_bank == 3 and room_id == 0x3E then -- big bang game room
				-- big bang game loss
				local bb_ended_curr = memory.read_u8(0x0DDB, "WRAM") == 0x80
				local bb_ended_changed, _, _ = update_prev('big bang', bb_ended_curr)
				local bb_won = memory.read_u8(0x0FC0, "WRAM") == 1
				return bb_ended_changed and bb_ended_curr and not bb_won, 80
			elseif room_bank == 2 and (room_id == 0xED or room_id == 0xEF) then -- goron dance present and past respectively
				-- goron dance miss
				local dance_changed, dance_curr, _ = update_prev('goron dance', memory.read_u8(0x0FD9, "WRAM") == 1)
				return dance_changed and dance_curr
			elseif room_bank == 5 and room_id == 0xE8 then -- patch's basement
				-- patch's crazy cart loss
				local patch_changed, patch_curr, _ = update_prev('patch', memory.read_u8(0x0FD5, "WRAM") == 1)
				return patch_changed and patch_curr, 120 -- fade to white before shuffle
			elseif (room_bank == 2 and room_id == 0xE9) -- lynna shooting gallery
				or (room_bank == 3 and room_id == 0xE7) -- goron shooting gallery
			then
				-- shooting gallery ball missed
				local round_end_curr = (memory.read_u8(0x0CD6, "WRAM") & 0x80) == 0x80
				local round_end_changed, _, _ = update_prev('round ended', round_end_curr)
				local strike = memory.read_u8(0x0FD6, "WRAM") == 1
				return round_end_changed and round_end_curr and strike, 60 -- let strike text show up before shuffle
			elseif room_bank == 2 and room_id == 0xDE then -- wild tokay room
				-- wild tokay loss
				local tokay_changed, tokay_curr, _ = update_prev('tokay', memory.read_u8(0x0FDE, "WRAM") == 0xFF)
				return tokay_changed and tokay_curr
			end
			return false
		end,
	},
	['Zelda_Minish'] = { -- Minish Cap, GBA
		func = health_swap, -- can use iframes if needed but this should work better
		-- health is zero on title screen, 'real' health is set per-savefile-selection too
		-- sword technique demonstrations can alter health (one-offs though) (main health only?)
		is_valid_gamestate = function() -- ingame, and health values match
			return memory.read_u8(0x1002, "IWRAM") == 2
				and memory.read_u8(0x11A5, "IWRAM") == memory.read_u8(0x2AEA, "EWRAM")
		end,
		get_health = function() return memory.read_u8(0x2AEA, "EWRAM") end,
		-- possibly if money is drained by an enemy if it doesn't also do damage?
		-- wallmaster-type grabs? (logic clashes and false positives may be an issue)
		-- the timed gameover at the very end (invisible timer, extra delay for clarity here)
		other_swaps = function() return memory.read_u16_le(0x2ECC, "EWRAM") == 1, 241 end,
		-- being grabbed by an enemy needs to allow mashing out before swapping
		suspend_updates = function() return memory.read_u8(0x3F9A, "IWRAM") & 128 ~= 0 end,
		grace = 30, -- give the default iframe period to react after swapping in
		-- OTHER NOTES:
		-- gamestate is 0x1002 IWRAM: 0 title, 1 savefiles, 2 game, 3 gameover, 4 credits
		-- display health is half other health values (4/heart vs 8/heart)
		-- health flows 0x2AEA -> 0xAF03 EWRAM (plus an 0x11A5 IWRAM copy)
		-- copy health should be updated on actual damage, will get re-set on area change
		-- max health is +1 offset from current health (0x2AEB/0xAF04/0x11A6)
		-- money is 0x2B00 -> 0xAF0E EWRAM, 2 bytes LE (0-999)
		-- iframes is 0x119D IWRAM if needed, 0x11A2 perhaps also related?
		-- 30 iframes on hit by default, 255 (or 254) while invulnerable (during text, etc)
		-- some hits do less, down to 12
		-- iframes from falling in water w/ no damage
		-- 0x3F9A IWRAM & 128 for being grabbed (allow breaking out without swaps)
		-- for enemy that grabs w/ damage: 12 iframes, max 4 hits, 40-56 frames between hits
		-- 0x3FB1 IWRAM & 1 is wallmaster? (minish eviction from boss too uhhh)
		-- for timed sequence, 0x2ECC EWRAM is set to 10800 frames (180s), gameover on hitting 0
		
		--get_iframes = function() return memory.read_u8(0x119D, "IWRAM") end,
		--iframe_minimum = function() return 15 end,
	},
	['MPAINT_DPAD_SNES']={ -- Gnat Attack in Mario Paint for SNES
		-- (I tested this with a version that can use the dpad for movement and face buttons for clicks)
		func=singleplayer_withlives_swap,
		p1gethp=function() return 0 end, -- we will always rely on lives, unless I need to do a sprite thing.
		p1getlc=function() return memory.read_u8(0x010018, "WRAM") end, -- hands remaining
		maxhp=function() return 6 end,
		gmode=function() return memory.read_u8(0x000206, "WRAM") == 0 end, -- 1 for painting, 0 for Gnat Attack
		CanHaveInfiniteLives=true, -- MAYBE THIS SHOULD BE AN OPTION
		LivesWhichRAM=function() return "WRAM" end,
		p1livesaddr=function() return 0x010018 end,
		maxlives=function() return 6 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['KIRBY_NES']={ -- Kirby's Adventure, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return (math.ceil((memory.read_u8(0x0597, "RAM")) % 255/8)) end,
		-- aside from 255 == death, HP is like Battletoads (7, 15, 23 ... 47)
		p1getlc=function() return memory.read_u8(0x0599, "RAM") end,
		maxhp=function() return 6 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x0599 end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['DemonsCrest']={ -- Demon's Crest (SNES)
		func=singleplayer_withlives_swap,
		gmode=function() return (memory.read_u8(0x01FFFC, "WRAM") ~= 37 and memory.read_u8(0x01FFFC, "WRAM") ~= 43) end, -- not the ending cutscenes, where hp mysteriously drops
		p1gethp=function() return (memory.read_u8(0x1062, "WRAM") * 2) + (memory.read_u8(0x1061, "WRAM") / 0x80) end,
		p1getlc=function() 
			local dead_changed, dead_curr, dead_prev = update_prev("dead", memory.read_u8(0x00E7, "WRAM"))
			if dead_changed == true and dead_curr == 45 and dead_prev == 1 then return 0
				else return 1
			end
		end,
		maxhp=function() return 40 end,
		CanHaveInfiniteLives=false -- you always have infinite lives in Demon's Crest, so "enabling" them does not apply
	},
	['FamilyFeud_SNES']={ -- Family Feud (SNES)
		func=FamilyFeud_SNES_swap,
		getstrike=function() return memory.read_u8(0x020E, "WRAM") end,
		getwhichplayer=function() return memory.read_u8(0x08DF, "WRAM") end,
		CanHaveInfiniteLives=false
	},
	['Monopoly_NES']={ -- Monopoly (NES)
		func=Monopoly_NES_swap,
		delay=120, -- higher than normal to help player process reason for swap!
		getInEditor=function() return memory.read_u8(0x0067, "RAM") end,
		-- if 1, we are editing the game before starting, so don't swap when money values change
		
		-- literally grabbing all the properties to know if they are owned/mortgaged/built up or not...
		-- I am sure there is a better, mathematical way to do this
		getSpace01=function() return memory.read_u8(0x039E, "RAM") end, -- Mediterranean Ave
		getSpace03=function() return memory.read_u8(0x03A0, "RAM") end, -- Baltic Ave
		getSpace05=function() return memory.read_u8(0x03A2, "RAM") end, -- Reading RR
		getSpace06=function() return memory.read_u8(0x03A3, "RAM") end, -- Oriental Ave
		getSpace08=function() return memory.read_u8(0x03A5, "RAM") end, -- Vermont Ave
		getSpace09=function() return memory.read_u8(0x03A6, "RAM") end, -- Connecticut Ave
		getSpace11=function() return memory.read_u8(0x03A8, "RAM") end, -- St. Charles Pl
		getSpace12=function() return memory.read_u8(0x03A9, "RAM") end, -- Electric Co
		getSpace13=function() return memory.read_u8(0x03AA, "RAM") end, -- States Ave
		getSpace14=function() return memory.read_u8(0x03AB, "RAM") end, -- Virginia Ave
		getSpace15=function() return memory.read_u8(0x03AC, "RAM") end, -- Pennsylvania RR
		getSpace16=function() return memory.read_u8(0x03AD, "RAM") end, -- St. James Pl
		getSpace18=function() return memory.read_u8(0x03AF, "RAM") end, -- Tennessee Ave
		getSpace19=function() return memory.read_u8(0x03B0, "RAM") end, -- New York Ave
		getSpace21=function() return memory.read_u8(0x03B2, "RAM") end, -- Kentucky Ave
		getSpace23=function() return memory.read_u8(0x03B4, "RAM") end, -- Indiana Ave
		getSpace24=function() return memory.read_u8(0x03B5, "RAM") end, -- Illinois Ave
		getSpace25=function() return memory.read_u8(0x03B6, "RAM") end, -- B&O RR
		getSpace26=function() return memory.read_u8(0x03B7, "RAM") end, -- Atlantic Ave
		getSpace27=function() return memory.read_u8(0x03B8, "RAM") end, -- Ventnor Ave
		getSpace28=function() return memory.read_u8(0x03B9, "RAM") end, -- Water Works
		getSpace29=function() return memory.read_u8(0x03BA, "RAM") end, -- Marvin Gardens
		getSpace31=function() return memory.read_u8(0x03BC, "RAM") end, -- Pacific Ave
		getSpace32=function() return memory.read_u8(0x03BD, "RAM") end, -- North Carolina Ave
		getSpace34=function() return memory.read_u8(0x03BF, "RAM") end, -- Pennsylvania Ave
		getSpace35=function() return memory.read_u8(0x03C0, "RAM") end, -- Short Line
		getSpace37=function() return memory.read_u8(0x03C2, "RAM") end, -- Park Place
		getSpace39=function() return memory.read_u8(0x03C4, "RAM") end, -- Boardwalk
		
		--DON'T SWAP ON ANY OF THESE
		--DEPRECATED
		--getUnowned=function() return memory.read_u8(0x005A, "RAM") end, -- if 21, player has rolled onto an unowned property.
		--getAuctioning=function() return memory.read_u8(0x04D2, "RAM") end, -- if 2, an auction is in progress.
		--getTradeAccepted=function() return memory.read_u8(0x0576, "RAM") + memory.read_u8(0x0577, "RAM") end, -- if 1 and 1, both have accepted the deal
		--getBuildingTimer=function() return memory.read_u8(0x0593, "RAM") end, -- if 1, someone bought houses/hotels and the building scene is about to happen
		
		-- PLAYER CASH TOTALS
		getp1Money=function() return memory.read_u8(0x03C5, "RAM")*10000 + memory.read_u8(0x03C6, "RAM")*1000 + memory.read_u8(0x03C7, "RAM")*100 + memory.read_u8(0x03C8, "RAM")*10 + memory.read_u8(0x03C9, "RAM") end,
		getp2Money=function() return memory.read_u8(0x03CA, "RAM")*10000 + memory.read_u8(0x03CB, "RAM")*1000 + memory.read_u8(0x03CC, "RAM")*100 + memory.read_u8(0x03CD, "RAM")*10 + memory.read_u8(0x03CE, "RAM") end,
		getp3Money=function() return memory.read_u8(0x03CF, "RAM")*10000 + memory.read_u8(0x03D0, "RAM")*1000 + memory.read_u8(0x03D1, "RAM")*100 + memory.read_u8(0x03D2, "RAM")*10 + memory.read_u8(0x03D3, "RAM") end,
		getp4Money=function() return memory.read_u8(0x03D4, "RAM")*10000 + memory.read_u8(0x03D5, "RAM")*1000 + memory.read_u8(0x03D6, "RAM")*100 + memory.read_u8(0x03D7, "RAM")*10 + memory.read_u8(0x03D8, "RAM") end,
		getp5Money=function() return memory.read_u8(0x03D9, "RAM")*10000 + memory.read_u8(0x03DA, "RAM")*1000 + memory.read_u8(0x03DB, "RAM")*100 + memory.read_u8(0x03DC, "RAM")*10 + memory.read_u8(0x03DD, "RAM") end,
		getp6Money=function() return memory.read_u8(0x03DE, "RAM")*10000 + memory.read_u8(0x03DF, "RAM")*1000 + memory.read_u8(0x03E0, "RAM")*100 + memory.read_u8(0x03E1, "RAM")*10 + memory.read_u8(0x03E2, "RAM") end,
		getp7Money=function() return memory.read_u8(0x03E3, "RAM")*10000 + memory.read_u8(0x03E4, "RAM")*1000 + memory.read_u8(0x03E5, "RAM")*100 + memory.read_u8(0x03E6, "RAM")*10 + memory.read_u8(0x03E7, "RAM") end,
		getp8Money=function() return memory.read_u8(0x03E8, "RAM")*10000 + memory.read_u8(0x03E9, "RAM")*1000 + memory.read_u8(0x03EA, "RAM")*100 + memory.read_u8(0x03EB, "RAM")*10 + memory.read_u8(0x03EC, "RAM") end,
		
		-- IS PLAYER HUMAN
		getp1Human=function() return memory.read_u8(0x033C, "RAM") end,
		getp2Human=function() return memory.read_u8(0x033D, "RAM") end,
		getp3Human=function() return memory.read_u8(0x033E, "RAM") end,
		getp4Human=function() return memory.read_u8(0x033F, "RAM") end,
		getp5Human=function() return memory.read_u8(0x0340, "RAM") end,
		getp6Human=function() return memory.read_u8(0x0341, "RAM") end,
		getp7Human=function() return memory.read_u8(0x0342, "RAM") end,
		getp8Human=function() return memory.read_u8(0x0343, "RAM") end,
		
		-- IS PLAYER IN JAIL - this goes up 1, 2, 3 for # turns in jail, 0 if you're out
		getp1InJail=function() return memory.read_u8(0x042C, "RAM") end,
		getp2InJail=function() return memory.read_u8(0x042D, "RAM") end,
		getp3InJail=function() return memory.read_u8(0x042E, "RAM") end,
		getp4InJail=function() return memory.read_u8(0x042F, "RAM") end,
		getp5InJail=function() return memory.read_u8(0x0430, "RAM") end,
		getp6InJail=function() return memory.read_u8(0x0431, "RAM") end,
		getp7InJail=function() return memory.read_u8(0x0432, "RAM") end,
		getp8InJail=function() return memory.read_u8(0x0433, "RAM") end,
		
		-- IS PLAYER BANKRUPT - 255 means player is out of the game, if it wasn't 255 to start with, they just went bankrupt
		getp1Bankrupt=function() return memory.read_u8(0x032C, "RAM") end,
		getp2Bankrupt=function() return memory.read_u8(0x032D, "RAM") end,
		getp3Bankrupt=function() return memory.read_u8(0x032E, "RAM") end,
		getp4Bankrupt=function() return memory.read_u8(0x032F, "RAM") end,
		getp5Bankrupt=function() return memory.read_u8(0x0330, "RAM") end,
		getp6Bankrupt=function() return memory.read_u8(0x0331, "RAM") end,
		getp7Bankrupt=function() return memory.read_u8(0x0332, "RAM") end,
		getp8Bankrupt=function() return memory.read_u8(0x0333, "RAM") end,
		
		CanHaveInfiniteLives=false
	},
	['BUBSY1_SNES']={ -- Bubsy in Claws Encounters of the Furred Kind, SNES
		func=singleplayer_withlives_swap,
		p1gethp=function() return 0 end ,
		p1getlc=function() return
			math.floor(memory.read_u8(0x020D, "WRAM")/16)*10 +
			(memory.read_u8(0x020D, "WRAM") % 16)
			-- this is actually a hex value that just skips A-F on screen. Transformed.
			end,
		maxhp=function() return 69 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "WRAM" end,
		p1livesaddr=function() return 0x020D end,
		maxlives=function() return 104 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['LAST_ALERT_TGCD']={ -- Last Alert, TG-CD
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x040A, "Main Memory") end,
		maxhp=function() return memory.read_u8(0x040B, "Main Memory") + 5 end, -- Technically player's rank + 5
		p1getlc=function()
			if memory.read_u8(0x0E8C, "Main Memory") > 0 -- Counts up as the screen fades out
				and memory.read_u8(0x040A, "Main Memory") == 0 -- but that's for ANY fade, so ensure it's for HP = 0
			then
				return 2
			else
				return 1
			end
		end,
	},
	['PEBBLE_BEACH_GOLF_LINKS_SAT']={ -- Pebble Beach Golf Links, Sega Saturn
		func=Pebble_Beach_Golf_Links_swap,
		getCurrentPlayer = function() return memory.read_bytes_as_array(0x03BA3C, 10, "Work Ram High") end,
		getPlayer1 = function() return memory.read_bytes_as_array(0x03ABA4, 10, "Work Ram High") end,
		getPlayer1Scores = function() return memory.read_bytes_as_array(0x03ABFA, 18, "Work Ram High") end,
		getHole = function() return memory.read_u8(0x00C003, "Work Ram Low") end,
		getGameMode = function() return memory.read_u16_be(0x00A988, "Work Ram Low") end,
		gmode = function() return memory.read_u16_be(0x00A988, "Work Ram Low") == 0x601 end,
		delay = 20,
	},
	['NBA_JAM_PS1']= { -- NBA Jam Tournament Edition, PS1
		func=NBA_Jam_swap,
		getOpposingTeamScore = function() return memory.read_s32_le(0x07D09C, "MainRAM") end,
		getTeamWithBall = function() return memory.read_s32_le(0x07D038, "MainRAM") end,
		getShotClock = function() return memory.read_s32_le(0x07D034, "MainRAM") end,
		getShotClockViolationMessageTimer = function() return memory.read_u16_le(0x7D012, "MainRAM") end,
		getQuarter = function() return memory.read_u16_le(0x07CF88, "MainRAM") end,
		delay = 120,
		gmode=function() return memory.read_u16_le(0x086560, "MainRAM") == 25932 end, -- This absolutely isn't the actual game mode variable, but it's consistently this value during a match, so, close enough for government work
	},
	['EINHANDER_PS1']={ -- Einhänder, PS1
		func=singleplayer_withlives_swap,
		p1gethp = function() return 0 end,
		maxhp = function() return 0 end,
		p1getlc = function() return memory.read_u8(0x0813C4, "MainRAM") end,
		CanHaveInfiniteLives=true,
		p1livesaddr = function() return 0x0813C4 end,
		LivesWhichRAM = function() return "MainRAM" end,
		maxlives = function() return 9 end,
		ActiveP1 = function() return true end,
		delay = 45,
	},
	['ROCKET_KNIGHT_ADVENTURES_GEN']={ -- Rocket Knight Adventures, Genesis
		func=Rocket_Knight_Adventures_swap,
		p1gethp=function() return memory.read_s16_be(0xC040, "68K RAM") end,
		maxhp=function() return 32767 end, -- Realistically this won't be above 63, but the game handles this value *somewhat* gracefully
		p1getlc = function()
			-- This is stored in decimal mode, meaning 0x69 is treated as 69 and
			-- not 105, so we need to convert it to a standard integer first so
			-- the "lives went down by 1" check passes gracefully
			local currLivesAsHex = memory.read_s16_be(0xFB0C, "68K RAM");
			local currLivesAsDecimal = (((currLivesAsHex & 0xF0) >> 4) * 10) + (currLivesAsHex & 0x0F);
			-- But also! You can keep playing at 0 lives! It's only when you DIE
			-- at 0 lives that a Game Over is executed. Fortunately, a specific
			-- memory address is set to a specific value when this happens, so
			-- check for it and treat it as -1 lives
			local gameOver = (memory.read_s16_be(0xB02C, "68K RAM") == 3);
			if (currLivesAsDecimal == 0 and gameOver) then
				return -1;
			else
				-- Otherwise, use the converted value for our purposes
				return currLivesAsDecimal;
			end
		end,
		-- Below: 0xC000 appears to be 1 during gameplay/0 during not-gameplay;
		-- at any rate, changes to 0 when life's set to 0 between cutscenes and
		-- stages, then changes back when life isn't 0 anymore.

		-- 0xB02C, meanwhile, is set to various values during fadeouts - 3 is
		-- the value for the continue/game over screen, and is basically the
		-- only way I can find to detect that the player's run out of lives,
		-- since 0 is a valid life value and it never goes negative (unlike HP).
		gmode = function()
			return memory.read_s16_be(0xC000, "68K RAM") == 1
				and memory.read_s16_be(0xB02C, "68K RAM") ~= 3
			end,
		-- Life Bonus, ticks down alongside health during stage clear screen
		gettogglecheck = function() return memory.read_u32_be(0xB174, "68K RAM") end,
		CanHaveInfiniteLives=true,
		p1livesaddr = function() return 0xFB0D end,
		LivesWhichRAM = function() return "68K RAM" end,
		maxlives = function() return 0x69 end,
		ActiveP1 = function() return true end,
	},
	['BANJO_KAZOOIE_NA_V10_N64']={ -- Banjo-Kazooie, North America v1.0, N64
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x385F83, "RDRAM") end,
		maxhp=function() return memory.read_u8(0x385F87, "RDRAM") end,
		gettogglecheck=function() return memory.read_u8(0x385F87, "RDRAM") end,
		-- The save selection screen changes the HP value, but it does it to
		-- match max HP, so just don't swap if both change at once. Max HP can't
		-- decrease in-game, and we wouldn't be swapping if HP changed because
		-- max HP was going UP...
		p1getlc=function() return memory.read_u8(0x385F8B, "RDRAM") end,
		CanHaveInfiniteLives=true,
		p1livesaddr = function() return 0x385F8B end,
		LivesWhichRAM = function() return "RDRAM" end,
		maxlives = function() return 9 end,
		ActiveP1 = function() return true end,
	},
	['BANJO_KAZOOIE_NA_V11_N64']={ -- Banjo-Kazooie, North America v1.1, N64
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x3851A3, "RDRAM") end,
		maxhp=function() return memory.read_u8(0x3851A7, "RDRAM") end,
		gettogglecheck=function() return memory.read_u8(0x3851A7, "RDRAM") end,
		-- The save selection screen changes the HP value, but it does it to
		-- match max HP, so just don't swap if both change at once. Max HP can't
		-- decrease in-game, and we wouldn't be swapping if HP changed because
		-- max HP was going UP...
		p1getlc=function() return memory.read_u8(0x3851AB, "RDRAM") end,
		CanHaveInfiniteLives=true,
		p1livesaddr = function() return 0x3851AB end,
		LivesWhichRAM = function() return "RDRAM" end,
		maxlives = function() return 9 end,
		ActiveP1 = function() return true end,
	},
	['BANJO_KAZOOIE_EUR_N64']={ -- Banjo-Kazooie, Europe, N64
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x386963, "RDRAM") end,
		maxhp=function() return memory.read_u8(0x386967, "RDRAM") end,
		gettogglecheck=function() return memory.read_u8(0x386967, "RDRAM") end,
		-- The save selection screen changes the HP value, but it does it to
		-- match max HP, so just don't swap if both change at once. Max HP can't
		-- decrease in-game, and we wouldn't be swapping if HP changed because
		-- max HP was going UP...
		p1getlc=function() return memory.read_u8(0x38696B, "RDRAM") end,
		CanHaveInfiniteLives=true,
		p1livesaddr = function() return 0x38696B end,
		LivesWhichRAM = function() return "RDRAM" end,
		maxlives = function() return 9 end,
		ActiveP1 = function() return true end,
	},
	['BANJO_KAZOOIE_JPN_N64']={ -- Banjo to Kazooie no Daibouken, Japan, N64
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x386AC3, "RDRAM") end,
		maxhp=function() return memory.read_u8(0x386AC7, "RDRAM") end,
		gettogglecheck=function() return memory.read_u8(0x386AC7, "RDRAM") end,
		-- The save selection screen changes the HP value, but it does it to
		-- match max HP, so just don't swap if both change at once. Max HP can't
		-- decrease in-game, and we wouldn't be swapping if HP changed because
		-- max HP was going UP...
		p1getlc=function() return memory.read_u8(0x386ACB, "RDRAM") end,
		CanHaveInfiniteLives=true,
		p1livesaddr = function() return 0x386ACB end,
		LivesWhichRAM = function() return "RDRAM" end,
		maxlives = function() return 9 end,
		ActiveP1 = function() return true end,
	},
	['SNAKE_RATTLE_N_ROLL_NES']={ -- Snake Rattle 'N' Roll, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x61, "RAM") + 1 end, -- offset because 0 is a valid health value and we still need to change on hitting it
		maxhp=function() return 17 end, -- I don't actually know the maximum length of the snake. I thought it was 4, but then it was 5. Seems to vary per level.
		gettogglecheck=function() return (
			memory.read_u8(0x48D, "RAM") -- this constantly increases during level exit
			| (math.max(memory.read_u8(0x409, "RAM")-1,0) << 8) -- this shoots up when stomped and decreases until death is logged. Offset down by 0 so the lives check still triggers.
		) end, -- bitwise OR them together in separate bytes, if either changes it'll be noted
		p1getlc=function() return memory.read_u8(0x3DF, "RAM") end,
		gmode=function() -- multiple values to accommodate the death animation
			return memory.read_u8(0xC, "RAM") == 0x04 -- normal gameplay
				or memory.read_u8(0xC, "RAM") == 0x48 -- one of the death states
				or memory.read_u8(0xC, "RAM") == 0xAF -- the other death state
				or memory.read_u8(0xC, "RAM") == 0xF8 -- set after death or level exit
		end,
		CanHaveInfiniteLives=true,
		p1livesaddr = function() return 0x3DF end,
		LivesWhichRAM = function() return "RAM" end,
		maxlives = function() return 9 end,
		ActiveP1 = function() return true end,
	},
	['ROCK_N_ROLL_RACING_SNES']={ -- Rock n' Roll Racing, SNES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0xEDF, "WRAM") end,
		maxhp=function() return 12 end,
		p1getlc=function()
			if memory.read_u8(0xEDF) == 0 then
				return 2
			else
				return 1
			end
		end,
		-- Below: lap counter. Goes up the same time health goes up for the
		-- first time, preventing a bogus shuffle. DOES mean getting hit the
		-- instant you finish a lap won't trigger a shuffle, though...
		gettogglecheck=function() return memory.read_u8(0xEF1, "WRAM") end,
	},
	['240P_NES']={
		func=StopWatch_swap,
		gmode=function() return memory.read_u8(0x01FB, "RAM") == 136 end, -- 136 is the stopwatch mode
	},
	['SOTN_PS1']={ -- Japan (1.0, 1.1) and North America releases
		func=sotn_swap,
		get_health=function() return memory.read_u32_le(0x97BA0, "MainRAM") end,
		max_health=function() return memory.read_u32_le(0x97BA4, "MainRAM") end,
		get_iframes=function() return memory.read_u16_le(0x72F1C, "MainRAM") end,
		get_player_state=function() return memory.read_u16_le(0x73404, "MainRAM") end,
		stone_state=11,
		game_over_check=function()
			local gamestate = memory.read_u32_le(0x3C734, "MainRAM")
			if gamestate == 3 and memory.read_u32_le(0x73060, "MainRAM") == 5 then -- Screen melt starting
				return true -- Game Over
			else
				return false -- Gameplay
			end
		end,
		is_valid_gamestate=function()
			local gamestate = memory.read_u32_le(0x3C734, "MainRAM")
			return gamestate == 2 -- Gameplay
				or gamestate == 3 -- Game Over
		end,
		grace=90,
	},
	['SOTN_PS1_2']={ -- Japan (1.2), Europe and Asia releases
		func=sotn_swap,
		get_health=function() return memory.read_u32_le(0x97BB0, "MainRAM") end,
		max_health=function() return memory.read_u32_le(0x97BB4, "MainRAM") end,
		get_iframes=function() return memory.read_u16_le(0x72F24, "MainRAM") end,
		get_player_state=function() return memory.read_u16_le(0x7340C, "MainRAM") end,
		stone_state=11,
		game_over_check=function()
			local gamestate = memory.read_u32_le(0x3C73C, "MainRAM")
			if gamestate == 3 and memory.read_u32_le(0x73068, "MainRAM") == 0 then -- Screen melt starting
				return true -- Game Over
			else
				return false -- Gameplay
			end
		end,
		is_valid_gamestate=function()
			local gamestate = memory.read_u32_le(0x3C73C, "MainRAM")
			return gamestate == 2 -- Gameplay
				or gamestate == 3 -- Game Over
		end,
		grace=90,
	},
	['SOTN_SATURN']={ -- Akumajou Dracula X: Gekka no Yasoukyoku (Saturn)
		func=sotn_swap,
		get_health=function() return memory.read_u16_be(0x5C942, "Work Ram High") end,
		max_health=function() return memory.read_u16_be(0x5C946, "Work Ram High") end,
		get_iframes=function() return memory.read_u16_be(0x5C524, "Work Ram High") end,
		get_player_state=function() return memory.read_u16_be(0x99824, "Work Ram High") end,
		stone_state=11,
		is_valid_gamestate=function()
			local gamestate = memory.read_u16_be(0x5CD72, "Work Ram High") -- May not be the actual gamestate addr, but works for our purpose
			return gamestate == 1 -- Gameplay
				or gamestate == 5 -- Game Over
		end,
		game_over_check=function()
			local gamestate = memory.read_u16_be(0x5CD72, "Work Ram High")
			if gamestate == 5 then -- Changes as soon as the fade-to-white starts
				return true -- Game Over
			else
				return false -- Gameplay
			end
		end,
		grace=90,
	},
	['CV64_JPN_N64']={
		func=castlevania_n64_swap,
		p1gethp=function() return memory.read_u16_be(0x389C3E, "RDRAM") end,
		maxhp=function() return 100 end,
		gamestate_ptr_addr=function() return 0x800A9AA0 end,
		gameplaymode=function() return 2 end,
		enteringgameovermode=function() return -3 end
	},
	['CV64_NA_V10_V11_N64']={
		func=castlevania_n64_swap,
		p1gethp=function() return memory.read_u16_be(0x389C3E, "RDRAM") end,
		maxhp=function() return 100 end,
		gamestate_ptr_addr=function() return 0x800A7820 end,
		gameplaymode=function() return 2 end,
		enteringgameovermode=function() return -3 end
	},
	['CV64_NA_V12_N64']={
		func=castlevania_n64_swap,
		p1gethp=function() return memory.read_u16_be(0x389C3E, "RDRAM") end,
		maxhp=function() return 100 end,
		gamestate_ptr_addr=function() return 0x800A7BC0 end,
		gameplaymode=function() return 2 end,
		enteringgameovermode=function() return -3 end
	},
	['CV64_EUR_N64']={
		func=castlevania_n64_swap,
		p1gethp=function() return memory.read_u16_be(0x389C42, "RDRAM") end,
		maxhp=function() return 100 end,
		gamestate_ptr_addr=function() return 0x800A82F0 end,
		gameplaymode=function() return 2 end,
		enteringgameovermode=function() return -3 end
	},
	['CVLOD_JPN_N64']={
		func=castlevania_n64_swap,
		p1gethp=function() return memory.read_u16_be(0x1CC4EA, "RDRAM") end,
		maxhp=function() return 10000 end,
		gamestate_ptr_addr=function() return 0x800C3CC0 end,
		gameplaymode=function() return 3 end,
		enteringgameovermode=function() return -11 end
	},
	['CVLOD_NA_N64']={
		func=castlevania_n64_swap,
		p1gethp=function() return memory.read_u16_be(0x1CAB3A, "RDRAM") end,
		maxhp=function() return 10000 end,
		gamestate_ptr_addr=function() return 0x800C1520 end,
		gameplaymode=function() return 3 end,
		enteringgameovermode=function() return -11 end
	},
	['CVLOD_EUR_N64']={
		func=castlevania_n64_swap,
		p1gethp=function() return memory.read_u16_be(0x1CC00A, "RDRAM") end,
		maxhp=function() return 10000 end,
		gamestate_ptr_addr=function() return 0x800C2800 end,
		gameplaymode=function() return 3 end,
		enteringgameovermode=function() return -11 end
	},
	['IceClimber_NES']={ -- Ice Climber NES
		func=twoplayers_withlives_swap,
		maxhp=function() return 2 end,
		-- we can implement a swap on failing the bonus game
		-- 0x0055 RAM is a sort of game mode, 0 title, 1 main level, 2 bonus, 3 and 4 bonus screen, 5 fly up to preview level
		-- 0x001E RAM is "got dactyl", 0 no, 1 1p, 2 2p
		-- so, if 0x0055 == 3 and 0x001E == 0, you just lost the bonus game
		p1gethp=function()
			if memory.read_u8(0x0055, "RAM") == 3 and
				memory.read_u8(0x001E, "RAM") == 0
				then return 1
			else return 2
			end
		end,
		p2gethp=function()
			if memory.read_u8(0x0055, "RAM") == 3 and
				memory.read_u8(0x001E, "RAM") == 0
				then return 1
			else return 2
			end
		end,
		p1getlc=function() return memory.read_u8(0x0020, "RAM") end,
		p2getlc=function() return memory.read_u8(0x0021, "RAM") end,
		gmode=function() return memory.read_u8(0x0053, "RAM") ~= 1 end, -- 1 == in demo
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x0020 end,
		p2livesaddr=function() return 0x0021 end,
		maxlives=function() return 69 end,
		ActiveP1=function() return memory.read_u8(0x0020, "RAM") ~= 252 end, -- 0 on start, 252 if player out of lives
		ActiveP2=function() return memory.read_u8(0x0021, "RAM") ~= 252 end, -- 0 on start, 252 if player out of lives
		DisableExtraSwaps=function() return 
			(memory.read_u8(0x0055, "RAM") == 3 and memory.read_u8(0x001E, "RAM") == 0) or -- p1 fails at bonus
			(memory.read_u8(0x0055, "RAM") == 3 and memory.read_u8(0x001E, "RAM") == 0) -- p2 fails at bonus
		end
	},
	['AssaultValken_SNES']={ -- Cybernator, SNES (USA)
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u16_le(0x0014CA, "WRAM") end,
		p1getlc=function() return memory.read_u8(0x0001FA, "WRAM") end,
		maxhp=function() return 256 end,
		gmode=function() return memory.read_u8(0x001B6C, "WRAM")==1 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x0001FA end,
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 9 end,
		ActiveP1=function() return true end, -- p1 is always active!
		grace=15,
	},
	['DarkwingDuck_NES']={ -- Darkwing Duck (NES)
		func=singleplayer_withlives_swap,
		maxhp=function() return 4 end,
		p1gethp=function()
		-- four addresses for heart pieces
			if memory.read_u8(0x05B4, "RAM") == 0x80 then
				return 4
			--first heart piece
			elseif memory.read_u8(0x05B8, "RAM") == 0x81 then
				return 3
			--second heart piece
			elseif memory.read_u8(0x05B6, "RAM") == 0x81 then
				return 2
			--third heart piece
			elseif memory.read_u8(0x05B2, "RAM") == 0x80 then
				return 1
			--last heart piece to go
			else
				return 0
			end
		end,
		p1getlc=function() return memory.read_u8(0x05E4, "RAM") * 10 + memory.read_u8(0x05E6, "RAM") end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x05E4 end,
		maxlives=function() return 0x76 end, 
		-- Darkwing Duck counts strangely, 0x05E4 is the tens diget and 0x0536 is the ones digit, and this byte reads as 0x7_ where the trailing digit is number of lives
		-- so we can't really give 69 lives this way without reworking the Infinite* Lives function
		-- so you get 60 + x lives instead.
		ActiveP1=function() return true end, -- P1 is always active!
	},
	['Contra_NES']={ -- Contra/Probotector (NES)
		func=twoplayers_withlives_swap,
		p1gethp=function() return 0 end,
		p2gethp=function() return 0 end,
		p1getlc=function() return memory.read_u8(0x0032, "RAM") end,
		p2getlc=function() return memory.read_u8(0x0033, "RAM") end,
		gettogglecheck=function()
			local p1gameover_changed, p1gameover_curr, p1gameover_prev = update_prev('p1gameover', memory.read_u8(0x0038, "RAM") == 1)
			local p2gameover_changed, p2gameover_curr, p2gameover_prev = update_prev('p2gameover', memory.read_u8(0x0039, "RAM") == 1)
			-- if a player steals a life to tag back in, "game over" flag will change on the same frame. This toggle prevents an extra swap.
			if p1gameover_changed == true or p2gameover_changed == true
			then
				return true
			end
			return false
		end,
		gmode=function() return memory.read_u8(0x001C, "RAM") == 0 end, -- if 1, then in demo
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x0032 end,
		p2livesaddr=function() return 0x0033 end,
		maxlives=function() return 69 end,
		ActiveP1=function() return memory.read_u8(0x0032, "RAM") > 0 end,
		ActiveP2=function() return memory.read_u8(0x0033, "RAM") > 0 end,
		maxhp=function() return 0 end,
	},
	['SuperC_NES']={ -- Super Contra/Probotector II (NES)
		func=twoplayers_withlives_swap,
		p1gethp=function() return 0 end,
		p2gethp=function() return 0 end,
		p1getlc=function() return memory.read_u8(0x0053, "RAM") end,
		p2getlc=function() return memory.read_u8(0x0054, "RAM") end,
		gettogglecheck=function()
			-- Super C loves doing things one frame at a time, not simultaneously, it seems. Here, lives and "game over state" change on consecutive frames!
			-- So we need a different toggle for this than for the first Contra.
			-- When a player steals a life to tag back in, their lives will go up from 0 to 1 AND the i-frames timer will start at 128.
			-- Let's track those two things for both players, and not swap when they both change this way.
			local p1lives_changed, p1lives_curr, p1lives_prev = update_prev('p1lives', memory.read_u8(0x0053, "RAM"))
			local _, p1tagin_started_curr, p1tagin_started_prev = update_prev('p1tagin_started', memory.read_u8(0x00C4, "RAM") == 128)
			local p2lives_changed, p2lives_curr, p2lives_prev = update_prev('p2lives', memory.read_u8(0x0054, "RAM"))
			local _, p2tagin_started_curr, p2tagin_started_prev = update_prev('p2tagin_started', memory.read_u8(0x00C5, "RAM") == 128)
			-- if a player steals a life to tag back in, the countdown on iframes starts on 128 and lasts 2 frames. This toggle prevents an extra swap.
			if (p1lives_curr == 1 and p1lives_prev == 0 and p1tagin_started_curr == true and p1tagin_started_prev == false) or 
				(p2lives_curr == 1 and p2lives_prev == 0 and p2tagin_started_curr == true and p2tagin_started_prev == false) 
			then
				return true
			end
			local p1respawn_frames_changed, p1respawn_frames_curr, p1respawn_frames_prev = update_prev('p1respawn_frames', memory.read_u8(0x00C0, "RAM"))
			local p2respawn_frames_changed, p2respawn_frames_curr, p2respawn_frames_prev = update_prev('p2respawn_frames', memory.read_u8(0x00C1, "RAM"))
			-- let's grab the countdown for spawning in, including stuff like the helicopter at the start of the game!
			-- if these are 0, the player is "live" and can be harmed.
			if (p1lives_changed == true and p1respawn_frames_changed == true and p1respawn_frames_curr > 0) or 
				(p2lives_changed == true and p2respawn_frames_changed == true and p2respawn_frames_curr > 0) 
			then
				return true
			end
			local levelstarted_changed, levelstarted_curr, levelstarted_prev = update_prev('levelstarted', memory.read_u8(0x0087, "RAM") == 1)
			if (levelstarted_changed == true and levelstarted_prev == false)
			-- on level start, Super C deducts a life from the stash! Why?! Anyway, don't swap on that.
			then
				return true
			end
			return false
		end,
		gmode=function() return memory.read_u8(0x001F, "RAM") == 0 end, -- actually in gameplay
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x0053 end,
		p2livesaddr=function() return 0x0054 end,
		maxlives=function() return 69 end,
		ActiveP1=function() return memory.read_u8(0x00C2, "RAM") ~= 1 end,
		ActiveP2=function() return memory.read_u8(0x00C3, "RAM") ~= 1 end,
		-- player is either inactive or in death sequence when these addresses == 1, lives go down the same frame that these addresses tick to 0
		maxhp=function() return 0 end,
	},
	['ContraIII_SNES']={ -- Contra III/Probotector (NES)
		func=twoplayers_withlives_swap,
		p1gethp=function() return 0 end,
		p2gethp=function() return 0 end,
		p1getlc=function() return memory.read_u8(0x1F8A, "WRAM") end,
		p2getlc=function() return memory.read_u8(0x1FCA, "WRAM") end,
		-- gmode=function() return memory.read_u8(0x001C, "RAM") == 0 end, -- if 1, then in demo
		gettogglecheck=function()
			local gameover_changed, gameover_curr, gameover_prev = update_prev('p1gameover', memory.read_u8(0x00A6, "WRAM") == 160)
			-- if a player steals a life to tag back in, "one player has game overed in 2p mode" flag will change to 160 (both alive) on the same frame. This toggle prevents an extra swap.
			if gameover_changed == true
			then
				return true
			end
			return false
		end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "WRAM" end,
		p1livesaddr=function() return 0x1F8A end,
		p2livesaddr=function() return 0x1FCA end,
		maxlives=function() return 70 end, -- sorry, Japan, yours shows 70 instead of 69
		ActiveP1=function() return memory.read_u8(0x1F8A, "WRAM") > 0 end,
		ActiveP2=function() return memory.read_u8(0x1FCA, "WRAM") > 0 end,
		maxhp=function() return 0 end,
	},
	['BladesofSteel_NES']={ -- Blades of Steel NES
		func=twoplayers_withlives_swap,
		gmode=function() return memory.read_u8(0x0019, "RAM") ~= 1 end, -- 1 == in demo
		maxhp=function() return 5 + 1 end,
		-- hp is going to cover fights and Gradius losses, and lives will cover goals
		p1gethp=function()
			-- HEY! change this to 1 if you want to shuffle every time a human player takes a punch!
			-- HEY HEY! You have to do this twice if you're playing with two players, look below!
			local BladesofSteel_NES_HowManyHPLostBeforeSwap = 5
			if memory.read_u8(0x0648, "RAM") > 5 and memory.read_u8(0x0648, "RAM") <= 40
				-- gradius cutscene ramps this up to 40 for some reason?? let's just drop the health until you get into a fight again
				-- and the health drop itself will cause you to swap on the ship exploding if you lose at Gradius!
				or (memory.read_u8(0x0080, "RAM") >=6 and memory.read_u8(0x0080, "RAM") <=8)
				-- this address marks out a game mode, and 6 through 8 apply to penalty shots to break a tie
				-- we need this because Blades of Steel has once again reused the fight health address! cool!
			then
				return 1
			elseif memory.read_u8(0x0648, "RAM") > 0 or memory.read_u8(0x0649, "RAM") > 0
				-- we are in a fight
			then
				return math.ceil(memory.read_u8(0x0648, "RAM")/BladesofSteel_NES_HowManyHPLostBeforeSwap) + 1
			else
				return 0
				-- outside of fights and Gradius, rely on goals
			end
		end,
		p2gethp=function()
			-- HEY! change this to 1 if you want to shuffle every time a human player takes a punch!
			-- HEY HEY! You have to do this twice if you're playing with two players, look above!
			local BladesofSteel_NES_HowManyHPLostBeforeSwap = 5
			if (memory.read_u8(0x0080, "RAM") >=6 and memory.read_u8(0x0080, "RAM") <=8)
				-- this address marks out a game mode, and 6 through 8 apply to penalty shots to break a tie
				-- we need this because Blades of Steel has once again reused the fight health address! cool!
			then
				return 1
			elseif memory.read_u8(0x0022, "RAM") == 1 and 
				(memory.read_u8(0x0648, "RAM") > 0 or memory.read_u8(0x0649, "RAM") > 0)
				-- we are in a 2p game AND a fight
			then 
				return math.ceil(memory.read_u8(0x0649, "RAM")/BladesofSteel_NES_HowManyHPLostBeforeSwap) + 1
			else
				return 0
				-- outside of fights, rely on goals
			end
		end,
		p1getlc=function()  
			return -1*(math.floor(memory.read_u8(0x07E9, "RAM")/16)*10 + (memory.read_u8(0x07E9, "RAM") % 16))
			-- second team's goals
			-- this is actually a hex value that just skips A-F on screen. Transformed and inverted so it counts down.
			-- TODO: subtract 1 for Gradius ship if it dies
		end,
		p2getlc=function() 
			if memory.read_u8(0x0022, "RAM") == 1
			-- we are in a 2p game
			then
				return -1*(math.floor(memory.read_u8(0x07E5, "RAM")/16)*10 + (memory.read_u8(0x07E5, "RAM") % 16))
			-- first team's goals
			-- this is actually a hex value that just skips A-F on screen. Transformed and inverted, so it counts down.
			else
				return 0
			end
		end,
		gettogglecheck=function()
			local _, p1hp_curr, p1hp_prev = update_prev('p1hp', memory.read_u8(0x0648, "RAM"))
			local _, p2hp_curr, p2hp_prev = update_prev('p2hp', memory.read_u8(0x0649, "RAM"))
			-- the winning fighter drops to 0 when transition from fight to normal gameplay happens, so let's prevent a double swap
			return p1hp_curr == 0 and p2hp_curr == 0
		end,
			-- if both fighters just dropped to 0, that's "end of battle"
			-- update_prev set up because there could be further exceptions identified later
		CanHaveInfiniteLives=false, -- Blades of Steel does not work this way.
	},
	['DoubleDragon1_NES']={ -- Double Dragon NES
		func=twoplayers_withlives_swap,
		-- objective: only swap on knockdowns, not every punch, and lives lost
		-- RAM 0x03C8 is a stun frame counter, sits at 0, pops to 32 on getting hit, then rolls down to 0
		-- RAM 0x03C4 is a hit counter, as you can get hit a few times before a knockdown, it goes back to 0 when knockdown activated
		-- if we only update hp on "hit counter == 0 and stun frames just hit 0," we can use this HP function
		-- amazingly, this works the same way in the fighting game!
		gmode=function() return memory.read_u8(0x00FE, "RAM") == 24 end,
		-- we are actually in gameplay this way! cool!
		p1gethp=function() 
			local p1hp_changed, p1hp_curr, p1hp_prev = update_prev('p1hp', memory.read_u8(0x03B4, "RAM"))
			local p1hitcounter_changed, p1hitcounter_curr, p1hitcounter_prev = update_prev('p1hitcounter', memory.read_u8(0x03C4, "RAM"))
			local p1stunframes_changed, p1stunframes_curr, p1stunframes_prev = update_prev('p1stunframes', memory.read_u8(0x03C8, "RAM"))
			if p1hp_curr == 0 then
				return 0
			end
			if p1hitcounter_curr == 0 and p1stunframes_changed and p1stunframes_curr == 31
				--we use 31 rather than 32 because you can get knocked down on a simultaneous hit that would have bumped up your hit counter
			then
				return 1
			end
			return 2 
		end,
		p2gethp=function()
		-- objective: only swap on knockdowns, not every punch, and lives lost
		-- RAM 0x03C9 is a stun frame counter, sits at 0, pops to 32 on getting hit, then rolls down to 0
		-- RAM 0x03C5 is a hit counter, as you can get hit a few times before a knockdown, it goes back to 0 when knockdown activated
		-- if we only update hp on "hit counter == 0 and stun frames just hit 0," we can use this HP function
		-- amazingly, this works the same way in the fighting game!
			local p2hp_changed, p2hp_curr, p2hp_prev = update_prev('p2hp', memory.read_u8(0x03B5, "RAM"))
			local p2hitcounter_changed, p2hitcounter_curr, p2hitcounter_prev = update_prev('p2hitcounter', memory.read_u8(0x03C5, "RAM"))
			local p2stunframes_changed, p2stunframes_curr, p2stunframes_prev = update_prev('p2stunframes', memory.read_u8(0x03C9, "RAM"))
			if memory.read_u8(0x0030, "RAM") == 2 and memory.read_u8(0x0032, "RAM") == 1 then
			-- the 2p addresses apply to enemies in 1p Mode A (side scroller), so we need to specify that we are actually in 2p fighting mode
				if p2hp_curr == 0 then
					return 0
				end
				if p2hitcounter_curr == 0 and p2stunframes_changed and p2stunframes_curr == 31
				then
					return 1
				end
			end
			return 2 
		end,
		maxhp=function() return 2 end,
		-- because of how we are calculating HP, the fighting game HP differences shouldn't matter
		p1getlc=function() return memory.read_u8(0x0043, "RAM") end,
		p2getlc=function() return memory.read_u8(0x0043, "RAM") end,
		gettogglecheck=function() return memory.read_u8(0x0031, "RAM") == 1 end,
		-- Did the current player change on this frame? If so, don't shuffle. That frame is when the stored number of lives gets loaded.
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function()
			if memory.read_u8(0x0031, "RAM") == 2 then
			-- side scroller, 2p is active, so fill in the saved number of lives for inactive p1
				return 0x06B1
			else
				return 0x0043
			-- otherwise, give the active player lives
			end
		end,
		p2livesaddr=function() return 0x06BD end,
		maxlives=function() return 9 end,
		ActiveP1=function() return true end, -- p1 is always active!
		ActiveP2=function() return true end, -- p2 is always active! the way the lives are stored, you just never swap in this player and their lives in 1p A mode
		delay=32,
		-- let players see the knockdown happen
	},
	['DoubleDragon2_NES']={ -- Double Dragon NES
		func=twoplayers_withlives_swap,
		-- objective: only swap on knockdowns, not every punch, and lives lost
		-- iframes won't work, because they only trigger on respawn.
		-- unlike DD1, one address appears to count frames both for stun frames and knockdowns the same way.
		-- it is not usable, even with a hit counter.
		-- RAM 0x0055 (p1) and 0x0056 hold some form of knockdown counter, however.
		-- on a knockdown specifically, this starts at 3, rolls down to 0, wraps around to 255, and eventually skips to 19 and further down.
		-- 19 does not activate on falling to your death.
		-- I suspect that the fourth bit of the byte is only activated on knockdown, because some other values (like high score) work similarly.
		-- Anyway, we're just looking for a 19 to be our HP!
		p1gethp=function() 
			local p1knockdown_changed, p1knockdown_curr, p1knockdown_prev = update_prev('p1knockdown', memory.read_u8(0x0055, "RAM"))
			if p1knockdown_changed and p1knockdown_curr == 19 then
				return 1
			end
			return 2 
		end,
		p2gethp=function() 
			local p2knockdown_changed, p2knockdown_curr, p2knockdown_prev = update_prev('p2knockdown', memory.read_u8(0x0056, "RAM"))
			if p2knockdown_changed and p2knockdown_curr == 19 then
				return 1
			end
			return 2 
		end,
		maxhp=function() return 2 end,
		-- this is clearly a hack to make "HP" out of a non-HP variable, but okay.
		p1getlc=function() return memory.read_u8(0x0432, "RAM") end,
		p2getlc=function() return memory.read_u8(0x0433, "RAM") end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x0432 end,
		p2livesaddr=function() return 0x0433 end,
		maxlives=function() return 9 end,
		ActiveP1=function() return memory.read_u8(0x0432, "RAM") > 0 end,
		ActiveP2=function() return memory.read_u8(0x0433, "RAM") > 0 end,
		delay=7,
		-- let players see the knockdown happen
	},
	['DKC1_SNES']={ -- Donkey Kong Country (SNES)
		func=iframe_health_swap,
		is_valid_gamestate=function() return memory.read_u8(0x000527, "WRAM") ~= 1 end,
		-- not on the map
		get_iframes=function() 
			if memory.read_u8(0x16D5, "WRAM") + memory.read_u8(0x16D7, "WRAM") > 20 then
				-- DK (0x16D5) and Diddy (0x16D7) get 108 iframes when the other is hit, so these won't be active at the same time
				return memory.read_u8(0x16D5, "WRAM") + memory.read_u8(0x16D7, "WRAM")
				-- and they get a tiny amount of iframes on stomping enemies, so return 0 if iframes are within that buffer
			end
			return 0
		end,
		other_swaps=function()
			local lives_changed, lives_curr, lives_prev = update_prev("lives", memory.read_u8(0x000575, "WRAM"))
			-- tracking deaths of the active player
			local activeplayer_changed, activeplayer_curr, activeplayer_prev = update_prev("activeplayer", memory.read_u8(0x000044, "WRAM"))
			-- 0 == p1, 1 == p2, this changes when active player's life count toggles between p1 and p2 on the 2p contest map
			-- it also changes in 2p team mode when DK/Diddy tags the other in, but lives won't change then! 
			return lives_changed and lives_curr < lives_prev and not activeplayer_changed
				and not (memory.read_u8(0x000527, "WRAM") == 1)
				-- not on map
		end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() 
			if memory.read_u8(0x000042, "WRAM") == 2 and memory.read_u8(0x000044, "WRAM") == 1 then
			-- 2p contest with 2p at the controls, so fill in the saved number of lives for inactive p1
				return 0x012343
			else
				return 0x000575
				-- otherwise, give the active player lives
			end
		end,
		p2livesaddr=function() return 0x012567 end, -- need to track 2p lives for 2p Contest mode, this changes nothing in 1p or 2p team modes
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- P1 is always active!
		ActiveP2=function() return memory.read_u8(0x000042, "WRAM") == 2 end, -- only applies when mode is 2p Contest
	},
	['DKC1_SFC']={ -- Super Donkey Kong (SFC)
		func=iframe_health_swap,
		is_valid_gamestate=function() return memory.read_u8(0x000527, "WRAM") ~= 1 end,
		-- not on the map
		get_iframes=function() 
			if memory.read_u8(0x16E7, "WRAM") + memory.read_u8(0x16E9, "WRAM") > 20 then
				-- DK (0x16E7) and Diddy (0x16E9) get 108 iframes when the other is hit, so these won't be active at the same time
				return memory.read_u8(0x16E7, "WRAM") + memory.read_u8(0x16E9, "WRAM")
				-- and they get a tiny amount of iframes on stomping enemies, so return 0 if iframes are within that buffer
			end
			return 0
		end,
		other_swaps=function()
			local lives_changed, lives_curr, lives_prev = update_prev("lives", memory.read_u8(0x000585, "WRAM"))
			-- tracking deaths of the active player
			local activeplayer_changed, activeplayer_curr, activeplayer_prev = update_prev("activeplayer", memory.read_u8(0x000044, "WRAM"))
			-- 0 == p1, 1 == p2, this changes when active player's life count toggles between p1 and p2 on the 2p contest map
			-- it also changes in 2p team mode when DK/Diddy tags the other in, but lives won't change then! 
			return lives_changed and lives_curr < lives_prev and not activeplayer_changed
				and not (memory.read_u8(0x000527, "WRAM") == 1)
				-- not on map
		end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() 
			if memory.read_u8(0x000042, "WRAM") == 2 and memory.read_u8(0x000044, "WRAM") == 1 then
			-- 2p contest with 2p at the controls, so fill in the saved number of lives for inactive p1
				return 0x012343
			else
				return 0x000585
				-- otherwise, give the active player lives
			end
		end,
		p2livesaddr=function() return 0x012569 end, -- need to track 2p lives for 2p Contest mode, this changes nothing in 1p or 2p team modes
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- P1 is always active!
		ActiveP2=function() return memory.read_u8(0x000042, "WRAM") == 2 end, -- only applies when mode is 2p Contest
		-- TODO: bonus game shuffles
		-- TODO: Can these versions be condensed?
	},
	['DKC2_SNES']={ -- Donkey Kong Country 2: Diddy's Kong Quest (SNES) / Super Donkey Kong 2 (SFC)
		func=iframe_health_swap,
		is_valid_gamestate=function() return memory.read_u8(0x00060D, "WRAM") <= 2 end,
		-- not in sound test or cheat entry mode
		get_iframes=function() 
			if memory.read_u8(0x16C6, "WRAM") + memory.read_u8(0x16EC, "WRAM") > 20 then
				-- Diddy (0x16C6) and Dixie (0x16EC) get 96 iframes when the other is hit, so these won't be active at the same time
				return memory.read_u8(0x16C6, "WRAM") + memory.read_u8(0x16EC, "WRAM")
				-- and they get a tiny amount of iframes on stomping enemies, so return 0 if iframes are within that buffer
			end
			return 0
		end,
		other_swaps=function()
			local lives_changed, lives_curr, lives_prev = update_prev("lives", memory.read_u8(0x0008BE, "WRAM"))
			-- tracking deaths of the active player
			local activeplayer_changed, activeplayer_curr, activeplayer_prev = update_prev("activeplayer", memory.read_u8(0x00060F, "WRAM"))
			-- 0 == p1, 1 == p2, this changes when active player's life count toggles between p1 and p2 on the 2p contest map
			-- it also changes in 2p team mode when DK/Diddy tags the other in, but lives won't change then! 
			return lives_changed and lives_curr < lives_prev and not activeplayer_changed
				and not (memory.read_u8(0x000DE5, "WRAM") == 1)
				-- not on map
		end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() 
			if memory.read_u8(0x00060D, "WRAM") == 2 and memory.read_u8(0x00060F, "WRAM") == 1 then
			-- 2p contest with 2p at the controls, so fill in the saved number of lives for inactive p1
				return 0x00527C
			else
				return 0x0008BE
				-- otherwise, give the active player lives
			end
		end,
		p2livesaddr=function() return 0x0055E1 end, -- need to track 2p lives for 2p Contest mode, this changes nothing in 1p or 2p team modes
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- P1 is always active!
		ActiveP2=function() return memory.read_u8(0x00060D, "WRAM") == 2 end, -- only applies when mode is 2p Contest
		-- TODO: doublecheck onmap address
		-- TODO: bonus game shuffles
		-- TODO: better behavior on a hard reset?
	},
	['DKC3_SNES_US']={ -- Donkey Kong Country 3: Dixie Kong's Double Trouble (SNES) (USA)
		func=iframe_health_swap,
		is_valid_gamestate=function() return memory.read_u8(0x0004C4, "WRAM") <= 2 end,
		-- not in any debug/sound test/cheat entry mode
		get_iframes=function() 
			if memory.read_u8(0x1494, "WRAM") + memory.read_u8(0x14E6, "WRAM") > 20 then
				-- Dixie (0x1494) and Kiddy (0x14E6) get 96 iframes when the other is hit, so these won't be active at the same time
				return memory.read_u8(0x1494, "WRAM") + memory.read_u8(0x14E6, "WRAM")
				-- and they get a tiny amount of iframes on stomping enemies, so return 0 if iframes are within that buffer
			end
			return 0
		end,
		other_swaps=function()
			local lives_changed, lives_curr, lives_prev = update_prev("lives", memory.read_u8(0x0005D5, "WRAM"))
			-- tracking deaths of the active player
			local activeplayer_changed, activeplayer_curr, activeplayer_prev = update_prev("activeplayer", memory.read_u8(0x0004C6, "WRAM"))
			-- 0 == p1, 1 == p2, this changes when active player's life count toggles between p1 and p2 on the 2p contest map
			-- it also changes in 2p team mode when DK/Diddy tags the other in, but lives won't change then! 
			if lives_changed and lives_curr < lives_prev and not activeplayer_changed
				and not (memory.read_u8(0x0006D8, "WRAM") == 1)
				-- not on map
			then
				return true
			end
			-- in the snowball fight level, iframes won't trigger a swap, they're stored somewhere else/differently
			-- you immediately get a DK barrel on entering that level
			-- so, on that level (0x21), we can use a different address to track whether we have two Kongs, and if that stops being true, we swap
			local _, bleak_two_kongs_curr, bleak_two_kongs_prev = update_prev("bleak_two_kongs", memory.read_u8(0x5B0, "WRAM") == 0x40)
			if memory.read_u8(0xC0) == 0x21 and bleak_two_kongs_curr == false and bleak_two_kongs_prev == true
			then
				return true, 10
			end
			return false
		end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() 
			if memory.read_u8(0x0004C4, "WRAM") == 2 and memory.read_u8(0x0004C6, "WRAM") == 1 then
			-- 2p contest with 2p at the controls, so fill in the saved number of lives for inactive p1
				return 0x00292C
			else
				return 0x0005D5
				-- otherwise, give the active player lives
			end
		end,
		p2livesaddr=function() return 0x002A26 end, -- need to track 2p lives for 2p Contest mode, this changes nothing in 1p or 2p team modes
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- P1 is always active!
		ActiveP2=function() return memory.read_u8(0x0004C4, "WRAM") == 2 end, -- only applies when mode is 2p Contest
		-- TODO: doublecheck onmap address
		-- TODO: bonus game shuffles
	},
	['DKC3_SNES_EU_JP']={ -- Donkey Kong Country 3: Dixie Kong's Double Trouble (SNES) (Europe)
		-- also, Super Donkey Kong 3: Nazo no Kremis-tou (Japan)
		func=iframe_health_swap,
		is_valid_gamestate=function() return memory.read_u8(0x0004C4, "WRAM") <= 2 end,
		-- not in any debug/sound test/cheat entry mode
		get_iframes=function() 
			if memory.read_u8(0x149A, "WRAM") + memory.read_u8(0x14EC, "WRAM") > 20 then
				-- Dixie (0x1494) and Kiddy (0x14E6) get 96 iframes when the other is hit, so these won't be active at the same time
				return memory.read_u8(0x149A, "WRAM") + memory.read_u8(0x14EC, "WRAM")
				-- and they get a tiny amount of iframes on stomping enemies, so return 0 if iframes are within that buffer
			end
			return 0
		end,
		other_swaps=function()
			local lives_changed, lives_curr, lives_prev = update_prev("lives", memory.read_u8(0x0005DB, "WRAM"))
			-- tracking deaths of the active player
			local activeplayer_changed, activeplayer_curr, activeplayer_prev = update_prev("activeplayer", memory.read_u8(0x0004C6, "WRAM"))
			-- 0 == p1, 1 == p2, this changes when active player's life count toggles between p1 and p2 on the 2p contest map
			-- it also changes in 2p team mode when DK/Diddy tags the other in, but lives won't change then! 
			if lives_changed and lives_curr < lives_prev and not activeplayer_changed
				and not (memory.read_u8(0x0006DE, "WRAM") == 1)
				-- not on map
			then
				return true
			end
			-- in the snowball fight level, iframes won't trigger a swap, they're stored somewhere else/differently
			-- you immediately get a DK barrel on entering that level
			-- so, on that level (0x21), we can use a different address to track whether we have two Kongs, and if that stops being true, we swap
			local _, bleak_two_kongs_curr, bleak_two_kongs_prev = update_prev("bleak_two_kongs", memory.read_u8(0x5B6, "WRAM") == 0x40)
			if memory.read_u8(0xC0) == 0x21 and bleak_two_kongs_curr == false and bleak_two_kongs_prev == true
			then
				return true
			end
			return false
		end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() 
			if memory.read_u8(0x0004C4, "WRAM") == 2 and memory.read_u8(0x0004C6, "WRAM") == 1 then
			-- 2p contest with 2p at the controls, so fill in the saved number of lives for inactive p1
				return 0x00292C
			else
				return 0x0005DB
				-- otherwise, give the active player lives
			end
		end,
		p2livesaddr=function() return 0x002A26 end, -- need to track 2p lives for 2p Contest mode, this changes nothing in 1p or 2p team modes
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- P1 is always active!
		ActiveP2=function() return memory.read_u8(0x0004C4, "WRAM") == 2 end, -- only applies when mode is 2p Contest
		-- TODO: doublecheck onmap address
		-- TODO: bonus game shuffles
	},
	['DKCxMARIO_SNES']={ -- DKC x Mario (SNES), version 1.107 tested
		func=iframe_health_swap,
		is_valid_gamestate=function() return memory.read_u8(0x000527, "WRAM") ~= 1 end,
		-- not on the map
		get_iframes=function()
			-- Big Mario took DK's spot, and Small Mario took Diddy's spot.
			if memory.read_u8(0x00056F, "WRAM") == 1 and memory.read_u8(0x16D5, "WRAM") > 60 and memory.read_u8(0x16D5, "WRAM") <= 112 then
				-- Big Mario, note that 60 iframes are awarded on powerups 
				-- a small amount of iframes are awarded on stomps, and 255 (!) iframes on successful spin stomps (which skips back to 0 shortly afterward)
				return memory.read_u8(0x16D5, "WRAM")
			elseif memory.read_u8(0x00056F, "WRAM") == 2 and memory.read_u8(0x16D7, "WRAM") > 60 and memory.read_u8(0x16D7, "WRAM") <= 112 then
				-- Small Mario
				return memory.read_u8(0x16D7, "WRAM")
			end
			-- return 0 if none of these apply
			return 0
		end,
		other_swaps=function()
			local lives_changed, lives_curr, lives_prev = update_prev("lives", memory.read_u8(0x000575, "WRAM"))
			if lives_changed and lives_curr < lives_prev and not (memory.read_u8(0x000527, "WRAM") == 1) then
				-- 1 == on map; this is simpler than DKC 1 as there's only one player!
				return true
			end
			local diedfromdamage_changed, diedfromdamage_curr, diedfromdamage_prev = update_prev("diedfromdamage", memory.read_u8(0x0D15, "WRAM") == 216)
			-- this appears to be the Mario dying sprite, which triggers when you die from damage
			-- triggering a fadeout and return to checkpoint
			local level_timer_changed = update_prev("level_timer", memory.read_u8(0x002A, "WRAM"))
			-- have to actively be in gameplay, which means that this timer should be ticking up 1 by every frame
			-- adding this condition will prevent cutscene shuffling, like at the ending
			if diedfromdamage_changed and diedfromdamage_curr == true and not (memory.read_u8(0x000527, "WRAM") == 1) and level_timer_changed then
				-- 1 == on map
				return true
			end
		end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x000575 end,
		-- active player's lives (1p only), lives do not get deducted on dying from damage as small Mario
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- P1 is always active!
	},
	['Jackal_NES']={ -- Jackal (NES)
		func=twoplayers_withlives_swap,
		p1gethp=function() return 0 end,
		p2gethp=function() return 0 end,
		p1getlc=function() return memory.read_u8(0x0031, "RAM") end,
		p2getlc=function() return memory.read_u8(0x0032, "RAM") end,
		gettogglecheck=function()
			local p1lives_changed, p1lives_curr, p1lives_prev = update_prev('p1lives', memory.read_u8(0x0031, "RAM"))
			local p2lives_changed, p2lives_curr, p2lives_prev = update_prev('p2lives', memory.read_u8(0x0032, "RAM"))
			-- if a player steals a life to tag back in, don't swap.
			if p1lives_changed == true and p1lives_prev == 0 
				or p2lives_changed == true and p2lives_prev == 0
			then
				return true
			end
			return false
		end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x0031 end,
		p2livesaddr=function() return 0x0032 end,
		maxlives=function() return 10 end, -- just one digit displays for extra lives in this game
		ActiveP1=function() return memory.read_u8(0x0031, "RAM") > 0 end,
		ActiveP2=function() return memory.read_u8(0x0032, "RAM") > 0 end,
		maxhp=function() return 0 end,
	},
	['StarFox64_N64']={ -- Star Fox 64 (N64)
		func=damage_buffer_swap,
		is_valid_gamestate=function() return 
			memory.read_u8(0x16D6A7, "RDRAM") == 7 and
			-- 2 == title, 3 == menu, 4 == map, 7 == in-game (includes vs and training)
			memory.read_u8(0x16D6C7, "RDRAM") == 2
			-- 0-2 == loading or in gameplay, 100 == paused (so you don't shuffle on choosing to restart a level)
		end,
		iframe_minimum=function() return 20 end,
		-- some combos pop you back up to 15, so don't re-shuffle on those
		get_iframes=function()
			if memory.read_u8(0x16DB08, "RDRAM") == 1 then
			-- in a space level - the planet levels have different addresses
				if memory.read_u8(0x16E627, "RDRAM") > 0 then
				-- VERSUS if number of VS players > 0 (0 if not in battle mode)
					return memory.read_u8(0x13AAB7, "RDRAM") +
					memory.read_u8(0x13AF97, "RDRAM") +
					memory.read_u8(0x13B477, "RDRAM") +
					memory.read_u8(0x13B957, "RDRAM")
					-- you can just add all the iframes together for all four players
					-- plus this tactic may help with damage combos (e.g., bombs) not immediately shuffling everyone
				else
					return memory.read_u8(0x13AAB7, "RDRAM") -- p1, in story mode
				end
			else -- planet levels
				if memory.read_u8(0x16E627, "RDRAM") > 0 then
					-- VERSUS, number of VS players, it's 0 if not in battle mode
					return memory.read_u8(0x137BD7, "RDRAM") +
					memory.read_u8(0x1380B7, "RDRAM") +
					memory.read_u8(0x138597, "RDRAM") +
					memory.read_u8(0x138AA7, "RDRAM")
				-- you can just add all the iframes together for all four players
				-- plus this tactic may help with damage combos (e.g., bombs) not immediately shuffling everyone
				else
					return memory.read_u8(0x137BD7, "RDRAM") -- p1 alone, in story mode
				end
			end
		end,
		get_damage_buffer=function()
			if memory.read_u8(0x16DB08, "RDRAM") == 1 then
			-- in a space level - the planet levels have different addresses
				if memory.read_u8(0x16E627, "RDRAM") > 0 then
				-- VERSUS if number of VS players > 0 (0 if not in battle mode)
					return memory.read_u8(0x13AB2B, "RDRAM") +
						memory.read_u8(0x13B00B, "RDRAM") +
						memory.read_u8(0x13B4EB, "RDRAM") +
						memory.read_u8(0x13B9CB, "RDRAM")
					-- you can just add all the damage buffers together for all four players
					-- plus this tactic may help with damage combos (e.g., bombs) not immediately shuffling everyone
				else
					return memory.read_u8(0x13AB2B, "RDRAM") -- p1 alone, space stage in story mode
				end
			else -- planet levels
				if memory.read_u8(0x16E627, "RDRAM") > 0 then
					-- VERSUS, number of VS players, it's 0 if not in battle mode
					return memory.read_u8(0x137C4B, "RDRAM") +
						memory.read_u8(0x13835B, "RDRAM") +
						memory.read_u8(0x13883B, "RDRAM") +
						memory.read_u8(0x138D1B, "RDRAM")
				-- you can just add all the damage buffers together for all four players
				-- plus this tactic may help with damage combos (e.g., bombs) not immediately shuffling everyone
				else
					return memory.read_u8(0x137C4B, "RDRAM") -- p1 alone, in story mode
				end
			end
		end,
		other_swaps=function() 
			local lives_changed, lives_curr, lives_prev = update_prev("lives", memory.read_u8(0x157911, "RDRAM"))
			if (lives_changed and lives_curr == lives_prev - 1) and -- lost a life
				(memory.read_u8(0x16D6A7, "RDRAM") ~= 7 or memory.read_u8(0x16D6C7, "RDRAM") == 100)
				-- not in gameplay, like on map or in pause menu, and choosing to retry level
			then
				return true
			end
			local wins_changed, wins_curr, wins_prev = update_prev("wins", memory.read_u8(0x16DC2B,"RDRAM") + 
				memory.read_u8(0x16DC2F,"RDRAM") + memory.read_u8(0x16DC33,"RDRAM") + memory.read_u8(0x16DC37,"RDRAM"))
			if memory.read_u8(0x16E627, "RDRAM") > 0 and -- in multiplayer 
				wins_changed and wins_curr > wins_prev -- wins go up because of a kill
			then 
				return true
			end
			
		end,
		grace=50, -- just make sure we don't combo on deaths (previously 20)
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x157911 end,
		-- importantly, we have to write just one byte
		LivesWhichRAM=function() return "RDRAM" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- P1 is always active! lives do not apply elsewhere
	},
	['LittleSamson_NES']={ -- Little Samson, NES
		func=singleplayer_withlives_swap,
		-- we'll track every character's hp and maxhp individually
		-- so that dying due to lost health shuffles when the life counter ticks down
		gmode=function() return memory.read_u8(0x0050, "RAM") <= 3 end,
		-- characters are numbered 0 to 3 at this address
		p1gethp=function()
			if memory.read_u8(0x0050, "RAM") == 3 then
				return memory.read_u8(0x009A, "RAM")
			elseif memory.read_u8(0x0050, "RAM") == 2 then
				return memory.read_u8(0x0099, "RAM")
			elseif memory.read_u8(0x0050, "RAM") == 1 then
				return memory.read_u8(0x0098, "RAM")
			else
				return memory.read_u8(0x0097, "RAM")
			end
		end,
		p1getlc=function() return memory.read_u8(0x0091, "RAM") end,
		-- lives are shared across characters!
		maxhp=function()
			if memory.read_u8(0x0050, "RAM") == 3 then
				return memory.read_u8(0x0096, "RAM")
			elseif memory.read_u8(0x0050, "RAM") == 2 then
				return memory.read_u8(0x0095, "RAM")
			elseif memory.read_u8(0x0050, "RAM") == 1 then
				return memory.read_u8(0x0094, "RAM")
			else
				return memory.read_u8(0x0093, "RAM")
			end
		end,
		swap_exceptions=function()
			local character_changed, character_curr, character_prev = update_prev("character", memory.read_u8(0x0050, "RAM"))
			local lives_changed = update_prev("lives", memory.read_u8(0x0091, "RAM"))
			-- characters have different max health.
			-- if active character swaps, health may go down as a result, don't swap on that
			-- however, character change can also happen on death (you might switch back to the kid if another char dies)
			if character_changed and not lives_changed then return true end
			return false
		end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x0091 end,
		LivesWhichRAM=function() return "RAM" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['WarioWare_GBA']={ -- WarioWare, Inc. / Made in Wario, GBA
		func=singleplayer_withlives_swap,
		p1getlc=function() return memory.read_u8(0x39D5, "IWRAM") end,
		-- consider tries remaining in microgames to be lives - this is the primary mechanism for swaps
		-- HP will apply only to specific game modes that don't tick down your 4 tries
		p1gethp=function()
			if memory.read_u8(0x3ADC, "IWRAM") == 0xD9 then
				-- boxing, you get three HP
				return memory.read_u8(0x5769, "IWRAM")
			elseif memory.read_u8(0x3ADC, "IWRAM") == 0xD7 then
				-- baseball
				-- 0x5831 == target to hit out of 10 balls, 11 - this == maxhp as you can miss that many balls before losing a life
				-- 0x57D9 == balls thrown, 0x57DA == balls hit, 0x57DB == balls missed; all change on same frame
				-- so, calculate 11 - maxhp - balls missed
				return 11 - memory.read_u8(0x5831, "IWRAM") - memory.read_u8(0x57DB, "IWRAM")
			elseif memory.read_u8(0x3ADC, "IWRAM") == 0xE4 then
				-- fly swatter
					return memory.read_s8(0x6366, "IWRAM") + 1
			else
				return 0
			end
		end,
		maxhp=function()
			if memory.read_u8(0x3ADC, "IWRAM") == 0xD9 then
				-- boxing, you get three HP
				return 3
			elseif memory.read_u8(0x3ADC, "IWRAM") == 0xD7 then
				-- 0x5831 == target to hit out of 10 balls, 11 - this == maxhp as you can miss that many balls before losing a life
				-- if it hasn't loaded yet, return 0
					if memory.read_u8(0x5831, "IWRAM") == 0 then
						return 0
					else
						return 11 - memory.read_u8(0x5831, "IWRAM")
					end
			elseif memory.read_u8(0x3ADC, "IWRAM") == 0xE4 and memory.read_u8(0x39D3, "IWRAM") == 1 then
				-- fly swatter: game won't drop extra hands if you have 6 banked, make sure you are in active mode
					return 7
			else
				return 0
			end
		end,
		gettogglecheck=function()
			local progress_changed, progress_curr, progress_prev = update_prev("progress", memory.read_u8(0x39DC, "IWRAM"))
			local lives_changed, lives_curr, lives_prev = update_prev("lives", memory.read_u8(0x39D5, "IWRAM"))
			local gameload_changed, gameload_curr, gameload_prev = update_prev("gameload", memory.read_u8(0x39D3, "IWRAM"))
			-- gameload: 00 when a microgame or bonus minigame is loading, 01 when active, 02 when resulting/closing
			return (progress_changed and not lives_changed) or 
				-- progress and lives change on the same frame. if you make progress, and you don't lose a life, you should never swap.
				-- creating this toggle will solve problems like HP for boxing/baseball resetting on the same frame if you progress to next round.
				(gameload_curr == 02 and gameload_prev == 01)
				-- on the same frame that you exit a bonus minigame from the title, the game deducts a life. I don't know why!
				-- actual lives are NOT deducted until the next game loads (on 00)
				-- so, if we just ticked over from 01 to 02, and lives drop, that is a fake life lost; don't swap!
		end,
		CanHaveInfiniteLives=false,
		-- may add a option for this in the future, but you don't lose *progress* in the story if you game over (similar to Mega Man)
		-- would also need to consider modes that don't use lives
	},
	['MagicalDoropie_NES']={ -- Magical Doropie / Krion Conquest, NES
		func=iframe_health_swap,
		get_health=function() return memory.read_u8(0x004C, "RAM") end,
		get_iframes=function() return memory.read_u8(0x03E0, "RAM") end,
		is_valid_gamestate=function()
			-- During gameplay, 004C is health and 004D is death indicator. Elsewhere, 004C..004D is a jump address
			-- So don't swap if 004D is non-zero, except in the case of 0001=zero health+dying
			return (memory.read_u8(0x004D, "RAM") == 0 or memory.read_u16_be(0x004C, "RAM") == 0x0001) and
				memory.read_u32_le(0x0030, "RAM") ~= 0 -- just random memory that's zeroed during reset and nonzero otherwise
		end,
		other_swaps=function() end,
		CanHaveInfiniteLives=true,
		ActiveP1=function()
			return (memory.read_u8(0x004D, "RAM") == 0 or memory.read_u16_be(0x004C, "RAM") == 0x0001) and
				memory.read_u32_le(0x0030, "RAM") ~= 0
		end,
		-- Strange, it's reading this as BCD for display, but otherwise treating this as a signed byte
		maxlives=function() return 3 end,
		p1livesaddr=function() return 0x0043 end,
		LivesWhichRAM=function() return "RAM" end,
	},
	['JUNKY_BALL_MR_GBA']={ -- Super Monkey Ball Jr., GBA
		func=singleplayer_withlives_swap,
		p1getlc=function() return memory.read_s8(0x2ADC, "EWRAM") end,
		p1gethp=function() return 1 end, -- No HP in this game
		maxhp=function() return 1 end, -- Again, no HP in this game
		gmode=function() return memory.read_u8(0x1CE, "EWRAM") == 85 end, -- Not 100% sure about this, but seems good
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x2ADC end,
		LivesWhichRAM=function() return "EWRAM" end,
		maxlives=function() return 69 end, -- 127+1 wraps around to -128, and
		-- you get 1ups for 50 bananas that doesn't account for that, so 99 is a
		-- safe compromise. 3 lives max drawn on HUD, but higher values do count
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['BATMAN_NES']={ -- Batman, NES
		func=singleplayer_withlives_swap,
		p1getlc=function() return memory.read_s8(0xBE, "RAM") end,
		p1gethp=function() return memory.read_u8(0xB7, "RAM") end,
		maxhp=function() return 8 end,
		gmode=function() return memory.read_u8(0x3D, "RAM") == 0 end, -- Confirmed with the disassembly of one "pwnskar"
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0xBE end,
		LivesWhichRAM=function() return "RAM" end,
		maxlives=function() return 9 end, -- Anything higher corrupts the pause menu graphics,
		-- but technically works; anything negative, however, immediately triggers a Game Over
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['Rollergames_NES']={ -- Rollergames, NES
		func=singleplayer_withlives_swap,
		p1getlc=function() return memory.read_u8(0x0032, "RAM") end,
		p1gethp=function() return memory.read_u8(0x04CE, "RAM") end,
		maxhp=function() return 12 end,
		gettogglecheck=function()
			-- when you transition to a new level, the game gives you an extra life, then takes it away the next frame
			-- you only actually lose a life if your hp is 0, this includes fall deaths
			-- DO NOT shuffle on lives changing if hp == 0
			local _, p1hp_curr = update_prev("p1hp", memory.read_u8(0x04CE, "RAM"))
			local lives_changed = update_prev("lives", memory.read_u8(0x0032, "RAM"))
			return lives_changed and p1hp_curr ~= 0
		end,
		delay=10,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x32 end,
		LivesWhichRAM=function() return "RAM" end,
		maxlives=function() return 0x6B end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['UNSquadron_SNES']={ -- U.N. Squadron, SNES
		func=singleplayer_withlives_swap,
		p1getlc=function() return memory.read_u8(0x00F4, "WRAM") end,
		p1gethp=function() return memory.read_u8(0x1008, "WRAM") end,
		maxhp=function() return 8 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x00F4 end,
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['ACTRAISER_SNES']={ -- ActRaiser, SNES
		func=singleplayer_withlives_swap,
		gmode=function()
			return (memory.read_u8(0x18, "WRAM") >= 0 -- Simulation mode (0), Platformer mode (1-7),
				and memory.read_u8(0x18, "WRAM") <= 8) -- or Game Over (8)
		end,
		p1getlc=function()
			if memory.read_u8(0x18, "WRAM") == 8 then -- Game Over
				return 0
			end
			if memory.read_u8(0x18, "WRAM") == 0 and memory.read_u8(0x286, "WRAM") == 0 then
				return -1
			end
			-- Need to convert binary-coded decimal hexadecimal value to just plain decimal
			local livesHex = memory.read_u8(0x1C, "WRAM")
			-- Get upper nybble, bit-shift right 4 bits
			local tens = (livesHex & 0xF0)>>4
			-- Just the lower nybble
			local ones = livesHex & 0x0F
			-- Merge 'em
			local lives = (tens * 10) + ones
			-- ActRaiser actually offsets lives by 1 for some reason - apparently the Japanese version doesn't but whatever - and 0x99 means 0
			return (lives+1)%100
		end,
		p1gethp=function()
			if (memory.read_u8(0x18, "WRAM") > 0
			and memory.read_u8(0x18, "WRAM") <= 8) then
				return memory.read_u8(0x1D, "WRAM") -- Platformer HP
			elseif memory.read_u8(0x18, "WRAM") == 0 then
				return memory.read_u8(0x286, "WRAM") -- Sim HP
			else
				return 0
			end
		end,
		maxhp=function()
			if (memory.read_u8(0x18, "WRAM") > 0
			and memory.read_u8(0x18, "WRAM") <= 8) then
				return memory.read_u8(0x1E, "WRAM") -- Platformer Max HP
			elseif memory.read_u8(0x18, "WRAM") == 0 then
				return memory.read_u8(0x287, "WRAM") -- Sim Max HP
			else
				return 0
			end
		end,
		CanHaveInfiniteLives=true,
		swap_exceptions=function() return memory.read_u8(0xF4, "WRAM") == 0 end,
		p1livesaddr=function() return 0x1C end,
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 0x03 end, -- 4 on screen will tell you it's working without counting down 69+ lives on level clear
		ActiveP1=function()
			local gameMode = memory.read_u8(0x18, "WRAM")
			return gameMode >= 1 and gameMode <= 8 -- p1 is always active, but don't set lives when in sim mode
		end,
		grace=60, -- Professional/Action Mode (Nintendo Super System only???? Must verify) can combo you too rapidly to recover
	},
	['PaRappa1_PS1']={ -- PaRappa the Rapper, PSX
		func=singleplayer_withlives_swap,
		gmode=function() return memory.read_u8(0x1C3670, "MainRAM") > 0 end, -- if no points yet, no shuffle, should help avoid shuffles between rounds and give leeway at the top of a round
		p1gethp=function() return 0 end, -- for now, we'll only shuffle on dropping a rank
		-- p1gethp=function() return memory.read_u8(0x1C3670, "MainRAM") end, -- use this to shuffle on losing points for ANY line, very unforgiving
		p1getlc=function() return memory.read_u8(0x1C368E, "MainRAM")*-1 end, -- u rappin cool (0)/good (1)/bad (2)/awful (3), inverted so worse is lower
		maxhp=function() return 999 end, -- 999 points is the max
		CanHaveInfiniteLives=false,
	},
	['Alundra1_PS1_1.0_USA']={ -- Alundra, PSX (USA, 1.0)
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x1AC4AC, "MainRAM") end,
		p1getlc=function() return 0 end, -- no lives in this game
		maxhp=function() return memory.read_u8(0x1AC4B0, "MainRAM") end, -- max hp in this game ranges from 10 to 50
		gmode=function() return memory.read_u8(0x1AC4B0, "MainRAM") > 0 end, -- max hp sometimes drops to 0 in loading zones, along with hp, processing should not be done then
	},
	['Alundra1_PS1_1.1_USA']={ -- Alundra, PSX (USA, 1.1)
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x1AC70C, "MainRAM") end,
		p1getlc=function() return 0 end, -- no lives in this game
		maxhp=function() return memory.read_u8(0x1AC710, "MainRAM") end, -- max hp in this game ranges from 10 to 50
		gmode=function() return memory.read_u8(0x1AC710, "MainRAM") > 0 end,  -- max hp sometimes drops to 0 in loading zones, along with hp, processing should not be done then
	},
	['Alundra1_PS1_JPN']={ -- Alundra, PSX (Japan)
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x1AE43C, "MainRAM") end,
		p1getlc=function() return 0 end, -- no lives in this game
		maxhp=function() return memory.read_u8(0x1AE440, "MainRAM") end, -- max hp in this game ranges from 10 to 50
		gmode=function() return memory.read_u8(0x1AE440, "MainRAM") > 0 end,  -- max hp sometimes drops to 0 in loading zones, along with hp, processing should not be done then
	},
	['NinjaGaiden1_NES']={ -- Ninja Gaiden, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x0065, "RAM") end,
		p1getlc=function() return memory.read_u8(0x0076, "RAM") end,
		maxhp=function() return 16 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x0076 end,
		LivesWhichRAM=function() return "RAM" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!
		grace=100, -- approx 60 frames from knockback/iframes until vulnerable again
	},
	['NinjaGaiden2_NES']={ -- Ninja Gaiden II, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x0080, "RAM") end,
		p1getlc=function() return memory.read_u8(0x00a5, "RAM") end,
		maxhp=function() return 16 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x00a5 end,
		LivesWhichRAM=function() return "RAM" end,
		maxlives=function() return 9 end,
		ActiveP1=function() return true end, -- p1 is always active!
		grace=100, -- approx 90 frames from knockback/iframes until vulnerable again
	},
	['NinjaGaiden3_NES']={ -- Ninja Gaiden III, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x00a7, "RAM") end,
		p1getlc=function() return memory.read_u8(0x00c4, "RAM") end,
		maxhp=function() return 16 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x00c4 end,
		LivesWhichRAM=function() return "RAM" end,
		maxlives=function() return 9 end,
		ActiveP1=function() return true end, -- p1 is always active!
		grace=100, -- approx 60 frames from knockback/iframes until vulnerable again
	},
	['BuckyOHare_NES']={ -- Bucky O'Hare, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x5a0, "RAM") end,
		p1getlc=function() return memory.read_u8(0x004C, "RAM") end,
		maxhp=function() return 255 end,
		grace=50, -- note, you appear to get 32 iframes with no recoil
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x004C end,
		maxlives=function() return 127 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['DynamiteHeaddy_GEN']={ -- Dynamite Headdy, Genesis
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0xd201, "68K RAM") end,
		p1getlc=function() return memory.read_u8(0xe8ed, "68K RAM") end,
		maxhp=function() return 80 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "68K RAM" end,
		p1livesaddr=function() return 0xe8ed end,
		maxlives=function() return 5 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['KabukiQuantumFighter_NES']={ -- Kabuki Quantum Fighter, NES
		func=singleplayer_withlives_swap,
		gmode=function()
			-- end of level, ticks down time to 000, then health
			-- in the ending, lives tick down but timer is also all zeroes
			-- if timer is all zeros, we are not in active gameplay
			-- side effect: on continuing after a time up, you'll be swapped on starting the timer for the level
			-- rather than right after dying
			-- this is acceptable
			if (memory.read_u8(0x691, "RAM") == 0 and memory.read_u8(0x692, "RAM") == 0 and
				memory.read_u8(0x693, "RAM")) then return false end
			return true
		end,
		p1gethp=function() return memory.read_s8(0x68c, "RAM") end,
		p1getlc=function() return memory.read_s8(0x6c0, "RAM") end,
		maxhp=function() return 15 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x6c0 end,
		maxlives=function() return 9 end,
		ActiveP1=function()
		-- p1 should only get lives refilled if we're in gameplay
		-- definitely not in the ending, where the lives count down
		-- lives will still refill if you get hit after a timeup, though HUD does not always update
			return (memory.read_u8(0x691, "RAM") == 0 and memory.read_u8(0x692, "RAM") == 0 and
				memory.read_u8(0x693, "RAM") == 0) == false
		end,
		swap_exceptions=function()
		-- if paused during boss fights, on the pause menu, you can trade hp and chips for each other
		-- this is intentional, not damage, so don't swap
			if (memory.read_u8(0x355, "RAM") == 0x80) then return true end
			return false
		end,
	},
	['GhostsnGoblins_NES']={ -- Ghosts n' Goblins, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x68c, "RAM") end,
		p1getlc=function() return memory.read_u8(0x715, "RAM") end,
		maxhp=function() return 255 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x715 end,
		maxlives=function() return 9 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['GhoulsnGhosts_GEN']={ -- Ghouls n' Ghosts, Genesis
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0xd201, "68K RAM") end,
		p1getlc=function() return memory.read_u8(0xb213, "68K RAM") end,
		maxhp=function() return 80 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "68K RAM" end,
		p1livesaddr=function() return 0xb213 end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['JackieChan_NES']={ -- Jackie Chan's Action Kung-Fu, NES
		func=health_swap,
		is_valid_gamestate=function() return true end,
		other_swaps=function() return false end,
		get_health=function() return memory.read_u8(0x702, "RAM") end,
		maxhp=function() return 6 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x701 end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!
		grace=30,
	},
	['Gimmick_NES']={ -- Gimmick!, NES
		func=singleplayer_withlives_swap,
		-- maxhp (at 0x002B) can change between stages if player has collected orange potions
		-- and, this means that you can drop from 3 or 4 hp to 2 between levels for non-damage reasons
		-- the value at this address unfortunately changes 1 frame before the hp drop; neither gmode nor a toggle check will do
		-- swap_exceptions option: 0x00E1 relates to player state; 0x53 is on map screen, which is where maxhp changes happen
		p1gethp=function() return memory.read_u8(0x346, "RAM") end,
		p1getlc=function() return memory.read_u8(0x104, "RAM") end,
		maxhp=function() return 4 end,
		swap_exceptions=function() 
			if memory.read_u8(0x00E1, "RAM") == 0x53 then return true end
			return false
		end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x104 end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['Shatterhand_NES']={ -- Shatterhand, NES
		func=singleplayer_withlives_swap,
		gmode=function() return memory.read_u8(0x0002, "RAM") == 0 end, -- in-stage only
		p1gethp=function() return memory.read_u8(0x5c5, "RAM") end,
		p1getlc=function() return memory.read_u8(0x71c, "RAM") end,
		maxhp=function() return 255 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x71c end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['MetalStorm_NES']={ -- Metal Storm, NES
		func=singleplayer_withlives_swap,
		-- armor: sets 0x05D0 to 0x80 in vanilla; in 3-hit hack, sets to 3 and counts down by 1 on each hit
		p1gethp=function() return memory.read_u8(0x05D0, "RAM") end,
		p1getlc=function() return memory.read_u8(0x0716, "RAM") end,
		maxhp=function() return 0x80 end,
		minhp=-1,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x716 end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['SuperGnG_SNES']={ -- Super Ghouls'n Ghosts, SNES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_s8(0x44A, "WRAM") end,
		p1getlc=function() return memory.read_s8(0x2A4, "WRAM") end,
		maxhp=function() return 1 end, -- Strictly speaking this CAN go higher and be handled as extra hit points, but the game itself won't do that
		minhp=-1,
		gmode=function()
			local mode = memory.read_s8(0x278, "WRAM")
			local demo = memory.read_s8(0x1FB9, "WRAM")
			return demo ~= 2 and (mode == 0x2 or mode == 0x4 or mode == 0x5) -- Modes are Map, Gameplay, or Game Over, respectively
		end,
		swap_exceptions=function(gamemeta)
			local lives_changed, lives_curr, lives_prev = update_prev("lives", gamemeta.p1getlc())
			local mode = memory.read_s8(0x278, "WRAM")
			if (mode == 0x2 and lives_curr ~= nil and lives_prev ~= nil and lives_curr >= lives_prev) then
				return true -- Do not shuffle on the map screen unless lives went down
			end
			return false
		end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x2A4 end,
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 9 end, -- Anything higher starts displaying letters or random graphic tiles
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['Castlevania2_GB']={ -- Castlevania II - Belmont's Revenge, GB
		func=singleplayer_withlives_swap,
		gmode=function() return memory.read_u8(0xC90, "WRAM") > 0 end, 
		-- if boss health > 0, we won't be counting down and ticking off health at the end of the level
		p1gethp=function() return memory.read_u8(0xc89, "WRAM") end,
		p1getlc=function() return memory.read_u8(0x8c5, "WRAM") end,
		maxhp=function() return 255 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "WRAM" end,
		p1livesaddr=function() return 0x8c5 end,
		maxlives=function() return 0x69 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['DonkeyKongLand_GB']={ -- Donkey Kong Land, GB
		func=singleplayer_withlives_swap,
		-- 0x064E: Which Kong on screen? 0 == DK, 1 == Diddy
		-- 0x065D: Have a spare Kong? 0 == no, 1 == yes (DK barrel in lower right)
		p1gethp=function() return memory.read_u8(0x65d, "WRAM") end,
		p1getlc=function() return memory.read_u8(0x66d, "WRAM") end,
		maxhp=function() return 1 end,
		minhp=-1,
		other_swaps=function()
			-- 0x066A: riding an Animal Buddy? 0 == no
			-- 0x613: iframes
			-- if you dismount and got iframes, you got bonked off your animal buddy, so swap
			local animal_buddy_changed, animal_buddy_curr = update_prev("animal_buddy", memory.read_u8(0x66A, "WRAM"))
			local iframes_changed, iframes_curr = update_prev("iframes", memory.read_u8(0x613, "WRAM"))
			if animal_buddy_changed and animal_buddy_curr == 0 and iframes_curr > 0 then return true end
			return false
		end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "WRAM" end,
		p1livesaddr=function() return 0x66d end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['GunstarHeroes_GEN']={ -- Gunstar Heroes, Genesis
		func=health_swap,
		is_valid_gamestate=function() return memory.read_u16_be(0xA284, "68K RAM") == 0x38 end,
		other_swaps=function() return false end,
		get_health=function() return memory.read_u16_be(0xA424, "68K RAM") end, -- note; health will not go above 999
		grace=60,
	},
	['ContraHardCorps_GEN']={ -- Contra - Hard Corps, Genesis
		func=twoplayers_withlives_swap,
		p1gethp=function() return memory.read_u8(0xFA0D, "68K RAM") end,
		p1getlc=function() return memory.read_u8(0xFA0C, "68K RAM") end,
		p2gethp=function() return memory.read_u8(0xFA2D, "68K RAM") end,
		p2getlc=function() return memory.read_u8(0xFA2C, "68K RAM") end,
		maxhp=function() return 3 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "68K RAM" end,
		p1livesaddr=function() return 0xFA0C end,
		p2livesaddr=function() return 0xFA2C end,
		maxlives=function() return 70 end,
		ActiveP1=function() return memory.read_u8(0xFA0C, "68K RAM") > 0 end,
		ActiveP2=function() return memory.read_u8(0xFA2C, "68K RAM") > 0 end,
		-- need to account for tag in
		swap_exceptions=function()
			local p1_lives_changed, p1_lives_curr, p1_lives_prev = update_prev("p1_lives", memory.read_u8(0xFA0C, "68K RAM"))
			local p2_lives_changed, p2_lives_curr, p2_lives_prev = update_prev("p2_lives", memory.read_u8(0xFA2C, "68K RAM"))
			if (p1_lives_changed and (p1_lives_curr == p1_lives_prev - 1) and p2_lives_prev == 0 and p2_lives_curr == 1) or
			   (p2_lives_changed and (p2_lives_curr == p2_lives_prev - 1) and p1_lives_prev == 0 and p1_lives_curr == 1)
			then
				return true
			end
			return false
		end,
	},
	['KurukuruKururin_GBA']={ -- KuruKuru Kururin, GBA
		func=health_swap,
		is_valid_gamestate=function() return true end,
		other_swaps=function() return false end,
		get_health=function() return memory.read_s8(0x4582, "IWRAM") end,
		maxhp=function() return 3 end,
		gmode=function() return memory.read_u8(0x1CE, "IWRAM") == 85 end, -- Not 100% sure about this, but seems good
		grace=45,
	},
	['KirbySuperStar_SNES']={ -- Kirby Super Star, (SNES)
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x00BB, "WRAM") end,
		p1getlc=function() return memory.read_u8(0x00B9, "WRAM") end,
		maxhp=function() return 56 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x00B9 end,
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['KirbyDreamland_GB']={ -- Kirby's Dream Land, GB
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x1086, "WRAM") end,
		p1getlc=function() return memory.read_u8(0x1089, "WRAM") end,
		maxhp=function() return 6 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "WRAM" end,
		p1livesaddr=function() return 0xd089 end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['KirbyMirror_GBA']={ -- Kirby and the Amazing Mirror, (GBA)
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_s8(0x020FE0, "EWRAM") end,
		p1getlc=function() return memory.read_s8(0x020FE2, "EWRAM") end,
		maxhp=function() return 56 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x020FE2 end,
		LivesWhichRAM=function() return "EWRAM" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!
	-- gmode=function() return memory.read_u8(0x1CE, "IWRAM") == 85 end, -- Not 100% sure about this, but seems good
	},
	['KirbyNightmareDreamland_GBA']={ -- Kirby - Nightmare in Dreamland, (GBA)
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_s8(0x5588, "EWRAM") end,
		p1getlc=function() return memory.read_s8(0x7D48, "EWRAM") end,
		maxhp=function() return 56 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x7D48 end,
		LivesWhichRAM=function() return "EWRAM" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!
		-- on loading a save, when the title card for the chapter disappears, you "spend" a life and go to max HP
		-- so don't shuffle whenever the title card transitions
		-- it sure looks like 0xAF04 only toggles up to 1 during a title card cutscene and is 0 otherwise!
		swap_exceptions=function() 
			local title_card_changed = update_prev("title_card", memory.read_u8(0xAF04, "EWRAM"))
			if title_card_changed then return true end
			return false
		end,
	},
	['AdvMagicKingdom_NES']={ -- Adventures in the Magic Kingdom, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x0030, "RAM") end,
		p1getlc=function() return memory.read_u8(0x06d8, "RAM") end,
		maxhp=function() return 255 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x06d8 end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!	
	},
	['Aladdin_GEN']={ -- Aladdin, Genesis
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0xeffa, "68K RAM") end,
		p1getlc=function() return memory.read_u8(0x7e3c, "68K RAM") end,
		maxhp=function() return 8 end,
		minhp=-1,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "68K RAM" end,
		p1livesaddr=function() return 0x7E3c end,
		maxlives=function() return 55 end,
		ActiveP1=function() return true end, -- p1 is always active!
		grace=45,
	},
	['Aladdin_SNES']={ -- Aladdin, SNES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x0367, "WRAM") end,
		p1getlc=function() return memory.read_u8(0x0364, "WRAM") end,
		maxhp=function() return 10 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x0364 end,
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 5 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['LionKing_SNES']={ -- The Lion King, SNES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x2004, "WRAM") end,
		p1getlc=function() return memory.read_u8(0x1ffaa, "WRAM") end,
		maxhp=function() return memory.read_s8(0x1FFAC, "WRAM") end, -- ignore garbage values like 0xFF
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x1ffaa end,
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 9 end,
		ActiveP1=function() return true end, -- p1 is always active!
		swap_exceptions=function() return memory.read_u8(0xA8B, "WRAM") == 0 end,
		-- addr is set to 0 if pausing is not permitted
		-- if allowed to pause, you are actually playing, otherwise ignore random HP/lives changes
	},
	['LionKing_NES']={ -- The Lion King, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x059a, "RAM") end,
		p1getlc=function() return memory.read_s8(0x059b, "RAM") end,
		maxhp=function() return 4 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x059b end,
		maxlives=function() return 5 end,
		ActiveP1=function() return true end, -- p1 is always active!
		grace=50,
	},
	['BubbleBobble_NES']={ -- Bubble Bobble, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return 1 end ,
		p1getlc=function() return memory.read_u8(0x002e, "RAM") end,
		maxhp=function() return 1 end,
		CanHaveInfiniteLives=false,
		p1livesaddr=function() return 0x002e end,
		LivesWhichRAM=function() return "RAM" end,
		maxlives=function() return 5 end,
		ActiveP1=function() return true end, -- p1 is always active!
		},
	['BugsBunnyBB_NES']={ -- Bugs Bunny: Birthday Blowout, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x0428, "RAM") end,
		p1getlc=function() return memory.read_u8(0x0429, "RAM") end,
		maxhp=function() return 255 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x0429 end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!	
	},
	['BugsBunnyCC_NES']={ -- Bugs Bunny: Crazy Castle, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return 1 end,
		p1getlc=function() return memory.read_u8(0x007c, "RAM") end,
		maxhp=function() return 1 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x007c end,
		LivesWhichRAM=function() return "RAM" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['DuckTales_NES']={ -- Ducktales, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return ((1 - memory.read_u8(0x0342, "RAM")) + (1 - memory.read_u8(0x0346, "RAM")) + (1 - memory.read_u8(0x034a, "RAM")) + ((1 - memory.read_u8(0x034c, "RAM")//192) * (1 - memory.read_u8(0x034e, "RAM"))) + ((1 - memory.read_u8(0x034c, "RAM")//192) * (1 - memory.read_u8(0x0350, "RAM")//192) * (1 - memory.read_u8(0x0352, "RAM")))) end, 
		p1getlc=function() return memory.read_u8(0x0361, "RAM") end,
		maxhp=function() return 5 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x0361 end,
		LivesWhichRAM=function() return "RAM" end,
		maxlives=function() return 9 end,
		ActiveP1=function() return true end, -- p1 is always active!
		gmode=function() return memory.read_u8(0x002b, "RAM") == 8 end, --game state is 8 in level. add " or memory.read_u8(0x002b,"RAM") == 4" if swapping needed in Gyro's secret area.
	},
	['DuckTales2_NES']={ -- Duck Tales 2, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x00CF, "RAM") end,
		p1getlc=function() return memory.read_u8(0x00CE, "RAM") end,
		maxhp=function() return 0x50 end, -- upper 4 bits are number of pips? not sure how this value works exactly
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x00CE end,
		maxlives=function() return 9 end,
		ActiveP1=function() return true end, -- p1 is always active!
	};	
	['JungleBook_GEN']={ -- Jungle Book, G
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0xf4da, "68K RAM") end,
		p1getlc=function() return memory.read_s8(0xfad4, "68K RAM") end,
		maxhp=function() return 7 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "68K RAM" end,
		p1livesaddr=function() return 0xfad4 end,
		maxlives=function() return 55 end,
		ActiveP1=function() return true end, -- p1 is always active!	
	},
	['JungleBook_NES']={ -- Jungle Book, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x0337, "RAM") end,
		p1getlc=function() return memory.read_s8(0x032f, "RAM") end,
		maxhp=function() return 13 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x032f end,
		maxlives=function() return 5 end,
		ActiveP1=function() return true end, -- p1 is always active!
		grace=30,
	},
	['JungleBook_SNES']={ -- Jungle Book, SNES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_s8(0x010b, "WRAM") end,
		p1getlc=function() return memory.read_s8(0x0104, "WRAM") end,
		maxhp=function() return 4 end,
		minhp=-1,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "WRAM" end,
		p1livesaddr=function() return 0x0104 end,
		maxlives=function() return 5 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['MendelPalace_NES']={ -- Mendel Palace, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return 1 end ,
		p1getlc=function() return memory.read_u8(0x012f, "RAM") end,
		maxhp=function() return 1 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x012f end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!	
	},
	['MsPacMan_NES']={ -- Ms. Pac-Man, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_s8(0x00d4, "RAM") end, -- lives remaining (minus one)
		p1getlc=function() return memory.read_s8(0x0122, "RAM") end, -- continues
		maxhp=function() return 5 end,
		minhp=-1, -- lives drop to -1 when you have 0 lives left
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x0122 end, -- continues
		-- if you run out of lives on levels 1-7, you can just select again from the menu (no continue needed)
		-- so, only refill continues, not lives
		maxlives=function() return 2 end,
		ActiveP1=function() return true end, -- p1 is always active!	
	},
	['HammerinHarry_NES']={ -- Hammerin' Harry, NES
		func=singleplayer_withlives_swap,
		-- add the hard hat flag (0/1) to health; hard hat gets spent if you would have lost your last HP
		p1gethp=function() return memory.read_s8(0x04fe, "RAM") + memory.read_s8(0x036c, "RAM") end,
		p1getlc=function() return memory.read_s8(0x036a, "RAM") end,
		maxhp=function() return 5 end, -- 4 + 1 for hard hat
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x036a end,
		maxlives=function() return 7 end, -- lives count down on clearing this game
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['HighSeasHavoc_GEN']={ -- High Seas Havoc, Genesis
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u16_be(0xdca4, "68K RAM") end,
		p1getlc=function() return memory.read_u16_be(0xdca0, "68K RAM") end,
		maxhp=function() return 0xFFFF end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "68K RAM" end,
		p1livesaddr=function() return 0xdca1 end, -- low byte of 16 bit BE word
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['MegaQBert_GEN']={ -- Mega Q*Bert (homebrew), Genesis
		func=singleplayer_withlives_swap,
		p1gethp=function() return 1 end,
		p1getlc=function() return memory.read_s8(0x08aa, "68K RAM") end,
		maxhp=function() return 1 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "68K RAM" end,
		p1livesaddr=function() return 0x08aa end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['PockyRocky_SNES']={ -- Pocky & Rocky, SNES
		func=twoplayers_withlives_swap,
		gmode=function() return memory.read_u8(0x0130, "WRAM") == 0 end, -- if > 0, tallying up end of level bonuses incl. health (ticks down)
		p1gethp=function() return memory.read_u8(0x0068, "WRAM") end,
		p2gethp=function() return memory.read_u8(0x0069, "WRAM") end,
		p1getlc=function() return memory.read_u8(0x006a, "WRAM") end,
		p2getlc=function() return memory.read_u8(0x006b, "WRAM") end,
		maxhp=function() return 16 end,
		swap_exceptions=function()
			local pocky_state_changed, pocky_state_curr, pocky_state_prev = update_prev("pocky_state", memory.read_u8(0x5A))
			local rocky_state_changed, rocky_state_curr, rocky_state_prev = update_prev("rocky_state", memory.read_u8(0x9A))
			-- don't swap if the player status just changed to "respawning" from "out but allowed to steal a life"
			if (pocky_state_changed and pocky_state_curr == 0x1D and pocky_state_prev == 0x16) or 
			   (rocky_state_changed and rocky_state_curr == 0x1D and rocky_state_prev == 0x16)
				then return true 
			end
			return false
		end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x006a end,
		p2livesaddr=function() return 0x006b end,
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 5 end,
		ActiveP1=function() return memory.read_u8(0x006a, "WRAM") > 0 end,
		ActiveP2=function() return memory.read_u8(0x006b, "WRAM") > 0 end,
		grace=60,
	},
 	['PockyRocky2_SNES']={ -- Pocky & Rocky 2, SNES
		func=PockyRocky2_SNES_swap,
		getpockystate=function() return memory.read_u16_le(0x2B88, "WRAM") end,
		gettimeup=function() return (memory.read_u16_le(0x05B4, "WRAM") == 0) end,
		getears=function() return memory.read_u8(0x1901, "WRAM") == 254 end,
		getlc=function() return memory.read_u8(0x19F4, "WRAM") end,
		getp2ishuman=function() return memory.read_u8(0x18CE, "WRAM") == 1 end,
		getp2hp=function() return memory.read_u8(0x05EA, "WRAM") end,
		getmerged=function() return memory.read_u8(0x19CE, "WRAM") >= 0x80 end,
		getmerging=function() return memory.read_u8(0x04B2, "WRAM") end,
		getmounthp=function() return memory.read_u8(0x19F2, "WRAM") end,
		getlevel=function() return memory.read_u8(0x0552, "WRAM") end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x19F4 end,
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 4 end,
		ActiveP1=function() return true end, -- p1 is always active! p2 doesn't need lives so don't specify anything for them!
		grace=50,
	},
	['RainbowIslands_NES']={ -- Rainbow Islands - The Story of Bubble Bobble 2, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return 1 end,
		p1getlc=function() return memory.read_s8(0x0022, "RAM") end,
		maxhp=function() return 1 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x0022 end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!	
	},
	['Ristar_GEN']={ -- Ristar, Genesis
		func=singleplayer_withlives_swap,
		gmode=function() return memory.read_u16_be(0xea02, "68K RAM") == 4 or memory.read_u16_be(0xea02, "68K RAM") == 5 end, -- level is loading from 0 to 3, controllable at 5
		p1gethp=function() return memory.read_u8(0xc038, "68K RAM") end,
		p1getlc=function() return memory.read_u8(0xe578, "68K RAM") end,
		maxhp=function() return 4 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "68K RAM" end,
		p1livesaddr=function() return 0xe578 end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['RubbleSaverII_GB']={ -- Rubble Saver II, GB
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x00b7, "WRAM") end, -- health
		p1getlc=function() return memory.read_u8(0x00b6, "WRAM") end,
		maxhp=function() return 3 end,
		other_swaps=function()
			-- swap if rocket used to get out of a pit 
			local rockets_changed, rockets_curr, rockets_prev = update_prev("rockets", memory.read_u8(0x00b8, "WRAM"))
			if rockets_changed and rockets_curr < rockets_prev then return true end
			return false
		end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "WRAM" end,
		p1livesaddr=function() return 0x00b6 end,
		maxlives=function() return 9 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['ShinobiIII_GEN']={ -- Shinobi III, Genesis
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x37e9, "68K RAM") end,
		p1getlc=function() return memory.read_u8(0x37e0, "68K RAM") end,
		maxhp=function() return 16 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "68K RAM" end,
		p1livesaddr=function() return 0x37e0 end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['SimpsonsBartvsWorld_NES']={ -- The Simpsons: Bart vs. the World, NES
		func=singleplayer_withlives_swap,
		gmode=function() return
			-- player has to be in control and not in a minigame like the sliding puzzle
			-- NOTE: if implementing swaps for bonus game fails, this will need adjustment!
			(memory.read_u8(0x0079, "RAM") == 0 -- sidescrolling Bart; this address is 0xFF in minigames, aside from skateboard
			or memory.read_u8(0x0425, "RAM") == 0x24) -- Bart on skateboard; 0x20 is walking, 0x22 is Bartman
		end,
		p1gethp=function() return memory.read_u8(0x06bc, "RAM") end,
		p1getlc=function() return memory.read_s8(0x06c1, "RAM") end,
		maxhp=function() return 5 end,
		minhp=-1,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x06c1 end,
		maxlives=function() return 5 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['Sparkster_SNES']={ -- Sparkster, SNES
		func=singleplayer_withlives_swap,
		-- gmode: 0x0158 > 0 marks being in cutscenes (1 == not in control, 2 == stage clear tally and level transition, where HP drops to 0, then refills)
		gmode=function() return memory.read_s8(0x0158, "WRAM") == 0 end, 
		p1gethp=function() return memory.read_s8(0x0691, "WRAM") end,
		p1getlc=function() return memory.read_s8(0x0168, "WRAM") end,
		maxhp=function() return 14 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "WRAM" end,
		p1livesaddr=function() return 0x0168 end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!
		delay=10, -- helps with health-draining situations, like the wringers in stage 2
	},
	['StarTropics_NES']={ -- StarTropics, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x0112, "RAM") end,
		p1getlc=function() return memory.read_s8(0x0117, "RAM") end,
		maxhp=function() 
		-- your default maxhp is heart containers times 2
		-- however, the pills in the final level overfill your health to the max value of 44 (22 hearts)
		-- and the effect gradually wears off, eventually bringing your hp back down to your max hearts
		-- you should NOT shuffle just because your maxhp decreased by 1 in this state
		-- so we need to check if HP is greater than maxhp but <= 44 and adjust maxhp on the fly accordingly
			local heartcontainers = memory.read_u8(0x0111, "RAM")
			if memory.read_u8(0x0112, "RAM") <= 44 and memory.read_u8(0x0112, "RAM") > heartcontainers*2
				then return memory.read_u8(0x0112, "RAM")
			else
				return heartcontainers*2
			end
		end,
		swap_exceptions=function()
		-- lives will get reset to 3 on completing dungeon areas, during loading
		-- so, if you have collected lives, these will drop and you will swap
		-- HP also gets set to the base of 6 (3 full hearts) on starting Chapter 4 
		-- (and possibly future chapters? there is no combat in Chapter 4)
		-- this hp reset would swap you if you have health > 6 on completing the prior chapter
		-- so, ignore lives/hp changes during loading screens (deaths get tallied slightly after loading)
		-- main area and sub-areas are on the first three addresses, and 0x80 and up means they are loading
			local loading_changed, loading_curr = update_prev("loading", memory.read_u8(0x0000, "RAM") >= 0x80 or memory.read_u8(0x0001, "RAM") >= 0x80 or memory.read_u8(0x0002, "RAM") >= 0x80)
			if loading_curr then return true end
		-- the HP changes between chapters happen while you are in overhead mode, not in a dungeon.
		-- no HP drops in overhead mode should swap you, but they need to be processed
			local overhead_mode_changed, overhead_mode_curr = update_prev("overhead_mode", memory.read_u8(0x0048, "RAM") >= 0x80)
			if overhead_mode_curr then return true end
			return false
		end,
		other_swaps=function()
		-- if your health is overcharged due to the pills in the final level, your health will gradually tick down, 1 hp at a time
		-- until you reach your actual maxhp (based on heart containers)
		-- you should shuffle if hp drops by > 1 in this state,
		-- as anything that can hit you at that point in the game will do more than 1 hp of damage
		-- also, check the frame after the damage is done, just to be sure that swaps occur if you drop down to at/below your usual maxhp (no longer overcharged)
			local is_hp_overcharged_changed, is_hp_overcharged_curr = update_prev("is_hp_overcharged", (memory.read_u8(0x0112, "RAM") > memory.read_u8(0x0111, "RAM")*2 and memory.read_u8(0x0112, "RAM") <= 44))
			if is_hp_overcharged_changed == true or is_hp_overcharged_curr == true then
				local overcharged_hp_changed, overcharged_hp_curr, overcharged_hp_prev = update_prev("overcharged_hp", memory.read_u8(0x0112, "RAM"))
				if overcharged_hp_changed == true and overcharged_hp_curr < overcharged_hp_prev - 1 then return true end
			end
			return false
		end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x0117 end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!	
	},
	['StreetFighter2010_NES']={ -- Street Fighter 2010: The Final Fight, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x00b1, "RAM") end,
		p1getlc=function() return memory.read_s8(0x00b5, "RAM") end,
		maxhp=function() return 10 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x00b5 end,
		maxlives=function() return 5 end,
		ActiveP1=function() return true end, -- p1 is always active!	
	},
	['StreetsOfRage2_GEN']={ -- Streets Of Rage II, Genesis
		func=twoplayers_withlives_swap,
		p1gethp=function() return memory.read_s8(0xEF81, "68K RAM") end,
		p1getlc=function() return memory.read_s8(0xEF83, "68K RAM") end,
		p2gethp=function() return memory.read_s8(0xF081, "68K RAM") end,
		p2getlc=function() 
			if memory.read_s8(0xFC19, "68K RAM") > 0 -- not in 1p mode
				then 
					return memory.read_s8(0xF083, "68K RAM")
				else
					return 0 -- don't shuffle because 2p lives dropped to -1 on starting 1p game
			end
		end,
		maxhp=function() return 104 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "68K RAM" end,
		p1livesaddr=function() return 0xEF83 end,
		p2livesaddr=function() return 0xF083 end,
		maxlives=function() return 9 end,
		ActiveP1=function() return true end, -- p1 is always active!
		ActiveP2=function() return (memory.read_u8(0xFC19, "68K RAM") == 1 -- 1 == 2p mode
		or memory.read_u8(0xFC19, "68K RAM") == 2) -- 2 == duel
		end,
		grace=60,
		swap_exceptions=function()
		-- special moves cost HP on their finishing frame (one requires landing a hit, one doesn't)
		-- so, if player status is "special," or goes back from special to normal, don't swap
		-- you do have to account for being able to be hit out of your special move, though
			local special_move_states = {
				[70] = true, -- standing special, left
				[71] = true, -- standing special, right
				[74] = true, -- moving special, left
				[75] = true, -- moving special, right
			}
			local hit_states = {
				[18] = true, -- recoiling, right
				[19] = true, -- recoiling, left
				[20] = true, -- falling, right
				[21] = true, -- falling, left
			}
			local game_mode = memory.read_u8(0xFC19, "68K RAM") -- 0 == 1p, 1 == 2p, 2 == duel
			local _, p1_move_curr, p1_move_prev = update_prev("p1_move", memory.read_u8(0xEF0F, "68K RAM"))
			local _, p2_move_curr, p2_move_prev = update_prev("p2_move", memory.read_u8(0xF00F, "68K RAM"))
			if 
				game_mode == 0 and -- 1p mode
				(special_move_states[p1_move_prev] and not hit_states[p1_move_curr])
			then
				return true
			elseif
				game_mode == 1 and -- 2p mode
				((special_move_states[p1_move_prev] and not hit_states[p1_move_curr]) or
				(special_move_states[p2_move_prev] and not hit_states[p2_move_curr]))
			then
				return true
			elseif
				game_mode == 2 and -- duel mode: if you use a special and it whiffs, don't shuffle - don't make exceptions for getting hit
				((special_move_states[p1_move_prev]) and not (hit_states[p2_move_curr]) or 
				(special_move_states[p2_move_prev]) and not (hit_states[p1_move_curr]))
			then
				return true
			end
		return false
		end,
	},
	['IndianaJonesLC_GEN']={ -- Indiana Jones & The Last Crusade, Genesis
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_s16_be(0x7F58, "68K RAM") end,
		-- Values are 8 (2 lives), 0 (1 life), -8 (0 lives), -16 (game over)... obviously.
		p1getlc=function() return memory.read_s16_be(0x7F5A, "68K RAM") / 8 end,
		minhp=-1,
		maxhp=function() return 32 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "68K RAM" end,
		-- This is not right (see above) but it'll probably work?
		-- This address does not affect the UI (hats) but it does prevent game overs
		p1livesaddr=function() return 0x7F5B end,
		maxlives=function() return 8 end,
		ActiveP1=function() return true end, -- p1 is always active!
		delay=33,
	},
	['GarfieldAWoG_NES']={ -- Garfield: A Week of Garfield, NES
		func=health_swap,
		is_valid_gamestate=function() return true end,
		other_swaps=function() return false end,
		get_health=function() return memory.read_u8(0x0318, "RAM") end,
		grace=45,
	},
	['BaoQingTian_NES']={ -- Bao Qing Tian (Ch), NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x006d, "RAM") end,
		p1getlc=function() return memory.read_s8(0x006e, "RAM") end,
		maxhp=function() return 255 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x006e end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!	
	},
	['CrashBandicoot4_NES']={ -- Crash Bandicoot 4 (Bootleg), NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x62a2, "IWRAM") end,
		p1getlc=function() return memory.read_u8(0x009a, "IWRAM") end,
		maxhp=function() return 255 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "IWRAM" end,
		p1livesaddr=function() return 0x009a end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!	
	},
	['Hercules2_GEN']={ -- Hercules II (Bootleg), Genesis
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0xe373, "68K RAM") end,
		p1getlc=function() return memory.read_u8(0xe371, "68K RAM") end,
		maxhp=function() return 40 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "68K RAM" end,
		p1livesaddr=function() return 0xe371 end,
		maxlives=function() return 5 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['LionKingI_NES']={ -- Lion King (Bootleg), NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x063c, "RAM") end,
		p1getlc=function() return memory.read_s8(0x063d, "RAM") end,
		maxhp=function() return 255 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x063d end,
		maxlives=function() return 7 end,
		ActiveP1=function() return true end, -- p1 is always active!	
	},
	['LionKingII_GEN']={ -- Lion King 2 (Bootleg), GEN
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x7217, "68K RAM") end,
		p1getlc=function() return memory.read_s8(0x7219, "68K RAM") end,
		maxhp=function() return 3 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "68K RAM" end,
		p1livesaddr=function() return 0x7219 end,
		maxlives=function() return 9 end,
		ActiveP1=function() return true end, -- p1 is always active!
		grace=60,
		other_swaps=function()
			-- track status of Simba at 0x7215, if you get a star it's like a mushroom and you become Super Simba/Mufasa/non-peewee Simba
			-- that usually sets this to 4, you can still be at 0 if you enter a new stage
			-- either way, getting hit in this state set this address to 5 without costing hp
			-- so, if this address just changed to 5, swap
			local super_simba_lost_changed, super_simba_lost_curr = update_prev("super_simba_lost", memory.read_u8(0x7215, "68K RAM") == 5)
			if super_simba_lost_changed and super_simba_lost_curr then return true end
			return false
		end,
	},
	['SonicJam6_GEN']={ -- Sonic Jam 6 (bootleg), Genesis
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x0061, "68K RAM") end,
		p1getlc=function() return memory.read_u8(0x0095, "68K RAM") end,
		maxhp=function() return 1 end,
		minhp=-1;
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "68K RAM" end,
		p1livesaddr=function() return 0x0095 end,
		maxlives=function() return 5 end,
		ActiveP1=function() return true end, -- p1 is always active!	
	},
	['SuperAladdin_NES']={ -- Super Aladdin (bootleg), NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_s8(0x063c, "RAM") end,
		p1getlc=function() return memory.read_u8(0x063d, "RAM") end,
		maxhp=function() return 8 end,
		minhp=-1,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x063d end,
		maxlives=function() return 5 end,
		ActiveP1=function() return true end, -- p1 is always active!	
	},
	['SuperContra7_NES']={ -- Super Contra 7 (bootleg), NES
		func=twoplayers_withlives_swap,
		gmode=function() return memory.read_s8(0x87, "RAM") == 1 -- only == 1 if actively playing, toggles on at same frame as lives "drop" on starting level
			and memory.read_s8(0x3b, "RAM") == 0 end, -- not in demo
		p1gethp=function() return 1 end, -- hp does not apply
		p1getlc=function() return memory.read_s8(0x53, "RAM") end,
		p2gethp=function() return 1 end, -- hp does not apply
		p2getlc=function() return memory.read_s8(0x54, "RAM") end,
		maxhp=function() return 1 end, -- hp does not apply
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x0053 end,
		p2livesaddr=function() return 0x0054 end,
		maxlives=function() return 68 end,
		ActiveP1=function() return true end, -- p1 is always active in this case!
		ActiveP2=function() return memory.read_u8(0xA1, "RAM") > 0 end, -- if 0, p2 is dead or not playing
	},
	['SuperMarioWorldSK_GEN']={ -- Super Mario Bros. (unl, w Squirrel King Mechanics), GEN
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_s8(0x715a, "68K RAM") end,
		p1getlc=function() return memory.read_s8(0x715b, "68K RAM") end,
		maxhp=function() return 5 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "68K RAM" end,
		p1livesaddr=function() return 0x715b end,
		maxlives=function() return 5 end,
		ActiveP1=function() return true end, -- p1 is always active!
		},
	['TarzanLOTJ_SNES']={ -- Tarzan: Lord of the Jungle (Unreleased), SNES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_s8(0x0264, "WRAM") end,
		p1getlc=function() return memory.read_s8(0x024C, "WRAM") end,
		maxhp=function() return 5 end,
		minhp=-1,
		swap_exceptions=function()
			-- 0x0104: appears to be level/map
			-- map screen == 15; when you go from 15 to a level, health drops to 0
			-- catch all scene transitions and disallow swapping on them
			local scene_changed = update_prev("scene", memory.read_u8(0x0104, "WRAM"))
			if scene_changed == true then return true end
			return false
		end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "WRAM" end,
		p1livesaddr=function() return 0x024C end,
		maxlives=function() return 5 end,
		ActiveP1=function() return true end, -- p1 is always active!
		grace=60, -- this also helps avoid a double-swap on a death from falling; if you fall, health drops to 0 about 33 frames later
	},
	['Titenic_NES']={ -- Titenic (bootleg), NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return 87 - memory.read_s8(0x0193, "RAM") end,
		p1getlc=function() return memory.read_s8(0x018d, "RAM") end,
		maxhp=function() return 87 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x018d end,
		maxlives=function() return 5 end,
		ActiveP1=function() return true end, -- p1 is always active!
		grace=30,
	},
	['TMNT_NES']={ -- Teenage Mutant Ninja Turtles (NES)
		func=singleplayer_withlives_swap,
		gmode=function() return memory.read_u8(0x0067, "RAM") <= 3 end,
		-- characters are numbered 0 to 3 at this address; 0=Leo, 1=Raph, 2=Mike, 3=Don
		p1gethp=function() return
			-- let's add all of the characters' HP together. Max HP per character == 128.
			memory.read_u8(0x0077, "RAM") + memory.read_u8(0x0078, "RAM") + memory.read_u8(0x0079, "RAM") + memory.read_u8(0x007a, "RAM") 
		end,
		p1getlc=function() return 
			-- if a character's HP hits 0, they are dead. Let's count that as "lives"
			math.ceil(memory.read_u8(0x0077, "RAM")/128) +
			math.ceil(memory.read_u8(0x0078, "RAM")/128) +
			math.ceil(memory.read_u8(0x0079, "RAM")/128) +
			math.ceil(memory.read_u8(0x007A, "RAM")/128)
		end,
		maxhp=function() return 512 end,
		CanHaveInfiniteLives=true, -- infinite continues are a better idea than infinite lives
		p1livesaddr=function() return 0x0046 end,
		LivesWhichRAM=function() return "RAM" end,
		maxlives=function() return 9 end,
		ActiveP1=function() return true end, -- p1 is always active!
		grace=60,
		delay=30,
	},
	['TMNT2_NES']={ -- Teenage Mutant Ninja Turtles II: The Arcade Game (NES)
		func=twoplayers_withlives_swap,
		p1gethp=function() return memory.read_u8(0x0568, "RAM") end,
		p2gethp=function() return memory.read_u8(0x056A, "RAM") end,
		p1getlc=function() return memory.read_u8(0x004D, "RAM") end,
		p2getlc=function() return memory.read_u8(0x004E, "RAM") end,
		gmode=function() return memory.read_u8(0x0018, "RAM") == 5 end, -- if 5, then in game, other values are demo, turtle select, etc
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x004D end,
		p2livesaddr=function() return 0x004E end,
		maxlives=function() return 9 end,
		ActiveP1=function() return true end, -- p1 is always active for infinite lives!
		ActiveP2=function() return memory.read_u8(0x0047, "RAM") == 1 end, -- 1 means 2p mode
		maxhp=function() return 60 end,
		grace=60,
		delay=30,
	},
	['TMNT3_NES']={ -- Teenage Mutant Ninja Turtles III: The Manhattan Project (NES)
		func=twoplayers_withlives_swap,
		p1gethp=function() return memory.read_u8(0x04F1, "RAM") end,
		p2gethp=function() return memory.read_u8(0x04F2, "RAM") end,
		p1getlc=function() return memory.read_u8(0x006A, "RAM") end,
		p2getlc=function() return memory.read_u8(0x006B, "RAM") end,
		gmode=function() return memory.read_u8(0x0027, "RAM") ~= 1 end, -- if 1, then in demo
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x006A end,
		p2livesaddr=function() return 0x006B end,
		maxlives=function() return 9 end,
		ActiveP1=function() return true end, -- p1 is always active for infinite lives!
		ActiveP2=function() return memory.read_u8(0x0028, "RAM") == 1 end, -- 1 means 2p mode
		maxhp=function() return 127 end,
		grace=60,
		delay=30,
		swap_exceptions=function()
			-- if both HP goes down and "doing a special/desperation move" is true, don't swap.
			local p1_special_changed, p1_special_curr = update_prev("p1_special", memory.read_u8(0x04E9, "RAM"))
			local p2_special_changed, p2_special_curr = update_prev("p2_special", memory.read_u8(0x04EA, "RAM"))
			return (p1_special_changed and p1_special_curr == 7) or 
				(p2_special_changed and p2_special_curr == 7)
		end,
	},
	['TMNT4_SNES']={ -- Teenage Mutant Ninja Turtles IV: Turtles in Time (SNES)
		func=twoplayers_withlives_swap,
		p1gethp=function() return memory.read_u8(0x044A, "WRAM") end,
		p2gethp=function() return memory.read_u8(0x04BA, "WRAM") end,
		p1getlc=function() return memory.read_u8(0x1AA0, "WRAM") end,
		p2getlc=function() return memory.read_u8(0x1AE0, "WRAM") end,
		gmode=function() return (memory.read_u8(0x0058, "WRAM") == 1 and memory.read_u8(0x0032, "WRAM") ~= 3) end, -- 1 == in game; 3 == demo
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "WRAM" end,
		p1livesaddr=function() return 0x1AA0 end,
		p2livesaddr=function() return 0x1AE0 end,
		maxlives=function() return 0x6A end,
		ActiveP1=function() return true end, -- p1 is always active for infinite lives!
		ActiveP2=function() return memory.read_u8(0x00A8, "WRAM") == 1 end, -- 1 means 2p mode
		maxhp=function() return 96 end,
		grace=60,
		delay=30,
		swap_exceptions=function()
		-- special moves cost HP if they hit, either during the special or on their finishing frame
		-- so, if turtle status is "special," or goes back from special to normal, don't swap
		local special_move_states = {
				[11] = true, -- raph's special
				[47] = true, -- leo's special
				[49] = true, -- mike's special
				[51] = true, -- don's special
			}
		local _, p1_turtle_status_curr, p1_turtle_status_prev = update_prev("p1_turtle_status", special_move_states[memory.read_u8(0x0416, "WRAM")] or false)
		local _, p2_turtle_status_curr, p2_turtle_status_prev = update_prev("p2_turtle_status", special_move_states[memory.read_u8(0x0486, "WRAM")] or false)
			if (p1_turtle_status_curr or p1_turtle_status_prev) or
					(p2_turtle_status_curr or p2_turtle_status_prev) or
					-- also, if both turtles have no "status," shuffling should not occur
					(memory.read_u8(0x0416, "WRAM") == 0 and memory.read_u8(0x0486, "WRAM")== 0)
			then
				return true
			end
		return false
		end,
	},
	['TaleSpin_NES']={ -- TaleSpin, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return 
			(memory.read_u8(0x05B2, "RAM") + 
			memory.read_u8(0x05B4, "RAM") + 
			memory.read_u8(0x05B6, "RAM") + 
			memory.read_u8(0x05B8, "RAM")) end,  --kind of like ducktales but with less nonsense. each memory address has a value of 96 if a heart is there, 0 otherwise. 
		p1getlc=function() return (((memory.read_u8(0x05D9, "RAM") - 112) * 10) + (memory.read_u8(0x05DB,"RAM") - 112)) end,  --lives stored as tens and ones in lower4 bits
		maxhp=function() return 384 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x05DB end,
		LivesWhichRAM=function() return "RAM" end,
		maxlives=function() return 121 end, --writing 9 to the ones place of the life count.
		ActiveP1=function() return true end, -- p1 is always active!
		gmode=function() return (memory.read_u8(0x0031, "RAM") < 8) end, --game state is between 0 and 7 for the levels of the game.
	},
	['AerotheAcrobat_SNES']={ -- Aero the Acro-Bat, SNES
		func=iframe_health_swap,
		is_valid_gamestate=function()
			local hp_changed, hp_curr, hp_prev = update_prev("hp", memory.read_u8(0x0CCA, "WRAM"))
			return (memory.read_u8(0x08C1, "WRAM") ~= 2 and 
			-- 2 for demo
			memory.read_u8(0x1B7E, "WRAM") ~= 255 and
			-- 255 when unable to control character (like during respawn, cutscenes)
			hp_curr > 0x67 and
			hp_curr < 0x6E and
			hp_prev ~= 0)
			-- why does the game LOAD IFRAMES TO 120 A SECOND OR SO AFTER STARTING THE GAME??
			-- well, it also loads in FROM an impossible health value, 0
			-- this game stores HP and lives in insane ways, hp is 0x69 ~ value and lives are value ~ 0x69
			-- at any rate, health can't dip below 0x68 or go above 0x6D
			-- so we'll just not shuffle if the previous or current health value is impossible.
			-- this will catch when it has those garbage values loaded in the title/loading screens, cool!
		end,
		swap_exceptions=function() return memory.read_u8(0x0CCA, "WRAM") == 0x69 end, -- prevent double swaps on no health
		other_swaps=function() return false end,
		get_iframes=function() return memory.read_u8(0x0C84, "WRAM") end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "WRAM" end,
		MustDoInfiniteLivesOnFrame=function() return true end,
		p1livesaddr=function() return 0x0C71 end,
		maxlives=function() return 9 ~ 0x69 end, -- setting the lives target to 9, transformed to how the game stores it; this will be relevant if infinite lives are reworked in the future
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['AdvOfGummiBear_GEN']={ -- Adventures of the Gummi Bears (bootleg), NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_s8(0x37c9, "68K RAM") end,
		p1getlc=function() return memory.read_s8(0x37d1, "68K RAM") end,
		maxhp=function() return 3 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "68K RAM" end,
		p1livesaddr=function() return 0x37d1 end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['ArkanoidDohItAgain_SNES']={ -- Arkanoid - Doh It Again, SNES
		func=singleplayer_withlives_swap,
		p1gethp=function() return 1 end,
		p1getlc=function() return memory.read_s8(0x0168, "WRAM") end,
		maxhp=function() return 1 end,
		swap_exceptions=function()
			-- when you beat Super Doh in level 99, lives count down and add to your score
			-- don't shuffle if you are on that level and Super Doh has no health left
			if memory.read_u8(0x0154, "WRAM") == 98 -- level 99
				-- HP of left arm, right arm, body
				and memory.read_u8(0x0C41, "WRAM") == 0 and memory.read_u8(0x0C43, "WRAM") == 0 and memory.read_u8(0x0C45, "WRAM") == 0
			then 
				return true
			end
			return false
		end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "WRAM" end,
		p1livesaddr=function() return 0x0168 end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['MinnesotaFatsPoolLegend_SAT']={ -- Minnesota Fats - Pool Legend (R) [Saturn]
		func=function() return 
		function()
			local gamestate_changed, gamestate_curr, gamestate_prev = update_prev("gamestate", memory.read_u8(0x0aa527, "Work Ram High"))
			local p2_turn_changed, p2_turn_curr, p2_turn_prev = update_prev("p2_turn", memory.read_u8(0x0aa53F, "Work Ram High") == 1)
			local lag_changed, lag_curr, lag_prev = update_prev("lag", memory.read_u8(0x0aa53B, "Work Ram High") == 6)
			local money_changed, money_curr, money_prev = update_prev("money", memory.read_u32_be(0x0aa56C, "Work Ram High")) -- how much money does Fats have in Story?
			-- in Story, if we lose, we will typically shuffle when the "you-lost" movie for a given opponent plays
			-- however, if we are in Story, and we lose to Junior after winning Game 1, we'll go down from $8,000,000 back to $4,000,000
			-- so, we have to make a special case of shuffling if we lose that specific game
			-- which we'll do by swapping if your money goes down specifically from that amount
			if money_changed and money_curr < money_prev and money_prev == 8000000 then return true end
			-- if we are in the middle of lag contest, do not swap, wait until lag ends
			if lag_curr then return false end
			-- if the game over movie just played, swap
			if gamestate_changed and gamestate_prev == 0x10 then return true end
			-- otherwise, we have to be playing, or we should never swap.
			if gamestate_curr ~= 0x08 then return false end
			-- we should shuffle if p1 loses their turn - that would be a miss, scratch, loss in lag, loss of game, anything
			if p2_turn_curr and (p2_turn_changed or (lag_changed and lag_prev)) then return true end
			-- otherwise, don't swap
			return false
			end
		end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "Work Ram High" end,
		p1livesaddr=function() return 0x061575 end, -- story continues
		maxlives=function() return 1 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['Sonic1_GEN']={ -- Sonic the Hedgehog (Genesis/Mega Drive)
		func=sonic_swap,
		gmode=function() return memory.read_u8(0xF600, "68K RAM") == 0xC end,
		get_rings=function() return memory.read_u16_be(0xFE20, "68K RAM") end,
		get_shield=function() return memory.read_u8(0xFE2C, "68K RAM") end,
		get_lives=function() return memory.read_u8(0xFE12, "68K RAM") end,
		get_iframes=function() return memory.read_u16_be(0xD030, "68K RAM") end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0xFE12 end,
		LivesWhichRAM=function() return "68K RAM" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['Sonic2_GEN']={ -- Sonic the Hedgehog 2/Knuckles in Sonic the Hedgehog 2 (Genesis/Mega Drive)
		func=sonic_swap,
		gmode=function() return memory.read_u8(0xF600, "68K RAM") == 0xC end,
		get_rings=function() return memory.read_u16_be(0xFE20, "68K RAM") end,
		get_shield=function() return memory.read_u8(0xB02B, "68K RAM") & 0x1 end,
		get_lives=function() return memory.read_u8(0xFE12, "68K RAM") end,
		get_iframes=function() return memory.read_u16_be(0xB030, "68K RAM") end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0xFE12 end,
		LivesWhichRAM=function() return "68K RAM" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['Sonic3K_GEN']={ -- Sonic the Hedgehog 3, Sonic & Knuckles, Sonic the Hedgehog 3 & Knuckles, Sonic 3 Complete (Genesis/Mega Drive)
		func=sonic_swap,
		gmode=function() return memory.read_u8(0xF600, "68K RAM") == 0xC end,
		get_rings=function() return memory.read_u16_be(0xFE20, "68K RAM") end,
		get_shield=function() return memory.read_u8(0xB02B, "68K RAM") & 0x1 end,
		get_lives=function() return memory.read_u8(0xFE12, "68K RAM") end,
		get_iframes=function() return memory.read_u8(0xB034, "68K RAM") end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0xFE12 end,
		LivesWhichRAM=function() return "68K RAM" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['SonicCD_SCD']={ -- Sonic the Hedgehog CD (Sega [Mega] CD)
		func=sonic_swap,
		gmode=function() return memory.read_u8(0x1957, "68K RAM") == 1 end,
		get_rings=function() return memory.read_u16_be(0x1512, "68K RAM") end,
		get_shield=function() return memory.read_u8(0x151E, "68K RAM") end,
		get_lives=function() return memory.read_u8(0x1508, "68K RAM") end,
		get_iframes=function() return memory.read_u8(0xD031, "68K RAM") end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x1508 end,
		LivesWhichRAM=function() return "68K RAM" end,
		maxlives=function() return 69 end, -- HUD caps at 9, but internally goes higher
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['Sonic3D_GEN']={ -- Sonic 3D Blast: Flickies' Island (Genesis/Mega Drive)
		func=sonic_swap,
		gmode=function()
			local mode = memory.read_u16_be(0x3FE, "68K RAM")
			return mode == 0x5F8 -- Gameplay
				or mode == 0x5A0 -- Stage loading; lives are subtracted the same time this mode is set, so we need to use it
		end,
		get_rings=function() return memory.read_u16_be(0xA5A, "68K RAM") end,
		get_shield=function() return memory.read_u8(0xAC2, "68K RAM") & 0x40 end,
		get_lives=function()
			local mode = memory.read_u16_be(0x3FE, "68K RAM")
			if mode == 0x91E or mode == 0x88C then -- Game Over or Continue; both are handled if you die with 0 lives, which is otherwise a valid life number
				return -1
			end
			return memory.read_u16_be(0x680, "68K RAM") -- Just return the actual lives counter
		end,
		get_iframes=function() return memory.read_u16_be(0xC224, "68K RAM") end,  -- Strictly speaking getting hit goes DOWN to -2, but debugging only displays if this goes UP
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x681 end,
		LivesWhichRAM=function() return "68K RAM" end,
		maxlives=function() return 9 end, --TODO: Check if 9 really is the maximum
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['Sonic3D_SAT']={ -- Sonic 3D Blast (Saturn)
		func=sonic_swap,
		gmode=function()
			local mode = memory.read_u8(0xFF06, "Work Ram High")
			return (mode >= 0x4 and mode <= 0x16) -- RA asserts this is gameplay, but it appears to be music tracks? Well, here's all the gameplay ones, at least
				or mode == 0x1D -- Loading? At any rate this mode accompanies a life loss
				or mode == 0x18 -- Continue
				or mode == 0x3 -- Game Over
		end,
		get_rings=function() return memory.read_u16_be(0x9800C, "Work Ram High") end,
		get_shield=function() return memory.read_u8(0x9807D, "Work Ram High") & 0x40 end,
		get_lives=function()
			local mode = memory.read_u8(0xFF06, "Work Ram High")
			if mode == 0x3 or mode == 0x18 then -- Game Over or Continue; both are handled if you die with 0 lives, which is otherwise a valid life number
				return -1
			end
			return memory.read_u16_be(0x97C2E, "Work Ram High") -- Just return the actual lives counter
		end,
		get_iframes=function() return memory.read_u16_be(0xA44AC, "Work Ram High") end, -- Strictly speaking getting hit goes DOWN to -2, but debugging only displays if this goes UP
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x97C2F end,
		LivesWhichRAM=function() return "Work Ram High" end,
		maxlives=function() return 9 end, --TODO: Check if 9 really is the maximum
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['SonicSpinball_GEN']={ -- Sonic the Hedgehog Spinball (Genesis)
		func=singleplayer_withlives_swap,
		p1gethp=function() return 0 end, -- Game does not have HP
		maxhp=function() return 0 end, -- Game does not have HP
		p1getlc=function()
			if memory.read_u16_be(0x3CA8, "68K RAM") == 1 then
				return memory.read_u8(0xF20D, "68K RAM") -- In bonus stage, read bonus lives
			elseif memory.read_u16_be(0x3CA8, "68K RAM") == 2 and memory.read_u16_be(0x547C, "68K RAM") ~= 1 then
				return -1 -- Bonus stage ending and the win flag isn't triggered, treat as a life loss
			end
			return memory.read_u8(0x579E, "68K RAM") -- Bonus not being relevant, use the normal life value
		end,
		gmode=function()
			local demomode = memory.read_u8(0x6, "68K RAM")
			local gamestate = memory.read_u16_be(0x3CB6, "68K RAM")
			local bonusstate = memory.read_u16_be(0x3CA8, "68K RAM")
			if demomode == 1 then
				return false -- In demo, ignore
			end
			if gamestate == 2 then
				return true -- In main game
			end
			if bonusstate == 1 or bonusstate == 2 then
				return true -- In a bonus stage, or one is just now ending
			end
			return false
		end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x579E end, -- Only bother with main lives, making bonus lives infinite would be too much hassle
		LivesWhichRAM=function() return "68K RAM" end,
		maxlives=function() return 9 end, -- Anything higher does not display
		ActiveP1=function() return true end, -- TODO: this actually supports 4P turn-taking...
	},
	['IQ_PS1_NA']={ -- I.Q.: Intelligent Qube, PS1 (TODO: PAL? Japan?)
		func=iq_swap,
		gmode=function()
			local gamemode = memory.read_u8(0x6C7F8, "MainRAM")
			return gamemode == 0x04 -- Gameplay
				or gamemode == 0x0A -- Gameplay? (RA says this can happen)
				or gamemode == 0x12 -- Death
				or gamemode == 0x13 -- Game Over
		end,
		get_gamemode=function() return memory.read_u8(0x6C7F8, "MainRAM") end,
		get_rows=function() return memory.read_u8(0x6C700, "MainRAM") end,
		get_cube_limit=function() return memory.read_u16_le(0x6C6F2, "MainRAM") end,
		get_squished=function() return memory.read_u16_le(0x6C6E4, "MainRAM") end,
		grace=180, -- 3 seconds is a lot, but it's better than rapid-fire damage-taking from multiple missed cubes
	},
	['Bubsy3D_PS1']={ -- Bubsy 3D: Furbitten Planet (PS1)
		func=singleplayer_withlives_swap,
		gmode=function()
			return memory.read_u32_le(0x1FFFD0, "MainRAM") == 0x801FFFD8
				and memory.read_u32_le(0x1FFFEC, "MainRAM") ~= 0x00000000 -- Need something to point to
		end,
		p1gethp=function()
			local statePtr = memory.read_u32_le(0x1FFFEC, "MainRAM")
			if (statePtr == 0x00000000) then
				return 0
			else
				statePtr = statePtr & 0x00FFFFFF -- BizHawk only cares about the lower 24 bits of the address, not the initial "0x80" in the MSB
			end
			return memory.read_s32_le(statePtr + 0x24, "MainRAM")
		end,
		maxhp=function() return 0x7FFFFFFF end, -- There is seemingly no actual cap, but the value is signed and the minus character is garbage data
		minhp=-1, -- You can live with 0 health
		p1getlc=function()
			local statePtr = memory.read_u32_le(0x1FFFEC, "MainRAM")
			if (statePtr == 0x00000000) then
				return 0
			else
				statePtr = statePtr & 0x00FFFFFF -- BizHawk only cares about the lower 24 bits of the address, not the initial "0x80" in the MSB
			end
			return memory.read_s32_le(statePtr + 0x20, "MainRAM")
		end,
		--[[gettogglecheck=function()
			return memory.read_s32_le(0xE02C, "MainRAM") == 0
		end,]]
		CanHaveInfiniteLives=true,
		p1livesaddr=function()
			local statePtr = memory.read_u32_le(0x1FFFEC, "MainRAM")
			if (statePtr == 0x00000000) then
				return nil -- Do not set lives this shuffle
			else
				statePtr = statePtr & 0x00FFFFFF -- BizHawk only cares about the lower 24 bits of the address, not the initial "0x80" in the MSB
			end
			return statePtr + 0x20
		end,
		LivesWhichRAM=function() return "MainRAM" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['BubsyFFT_JAG']={ -- Bubsy in Fractured Furry Tales (Atari Jaguar)
		func=singleplayer_withlives_swap,
		gmode=function() return memory.read_u16_be(0xF172A, "DRAM") == 3 end, -- Absent anything more obvious, this SEEMS reliable...
		p1gethp=function() return 0 end,
		maxhp=function() return 0 end,
		p1getlc=function()
			-- Need to convert binary-coded decimal hexadecimal value to just plain decimal
			local livesHex = memory.read_s16_be(0x2D162, "DRAM")
			if (livesHex == 0xFF99) then
				return 0 -- This is what this value displays as in-game, though you never get to see it
			end
			-- Get upper nybble, bit-shift right 4 bits
			local tens = (livesHex & 0xF0)>>4
			-- Just the lower nybble
			local ones = livesHex & 0x0F
			-- Merge 'em
			local lives = (tens * 10) + ones
			-- Bubsy actually offsets lives by 1 for some reason
			return lives+1
		end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "DRAM" end,
		p1livesaddr=function() return 0x2D163 end,
		maxlives=function() return 0x68 end, -- Will show as 69
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['PowerBlade_NES']={ -- Power Blade, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x04ab, "RAM")+memory.read_u8(0x009c, "RAM") end,
		p1getlc=function() return memory.read_s8(0x0027, "RAM") end,
		maxhp=function() return 19 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x0027 end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!
		grace=30,
	},
	['PowerBlade2_NES']={ -- Power Blade 2, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x049a, "RAM") end,
		p1getlc=function() return memory.read_u8(0x009f, "RAM") end,
		maxhp=function() return 16 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x009f end,
		maxlives=function() return 106 end,
		ActiveP1=function() return true end, -- p1 is always active!
		grace=30,
	}, 
	['ViceProjectDoom_NES']={ -- Vice: Project Doom, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x0280, "RAM") end,
		p1getlc=function() return memory.read_u8(0x0362, "RAM") end,
		maxhp=function() return 20 end,
		swap_exceptions=function()
			-- for the shooting gallery levels, there are no iframes at all
			-- you get 60 for platform levels and 127 for car levels
			-- so, in the two shooting galleries, we'll only shuffle on deaths, not for losing HP
			local level = memory.read_u8(0x0092, "RAM")
			if (level == 38 or level == 40) and memory.read_u8(0x0280, "RAM") > 0 then return true end
			return false
		end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x0362 end,
		maxlives=function() return 5 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['MarbleMadness_NES']={ -- Marble Madness, NES
		func=iframe_health_swap,
		is_valid_gamestate=function() return memory.read_u8(0x0003, "RAM") == 0x02 end,
		-- double check game states but 0x02 == playing, 0xFF == loading, 0x0E == name entry etc. 
		swap_exceptions=function() return false end,
		-- check if this is needed for out of time/game over
		get_iframes=function()
			-- dizzy timers are 0x005B (p1) and 0x005C (p2)
			-- respawn timers are 0x0410 (p1) and 0x0411 (p2)
			-- if we add these together, we should have proper support for dizzies and deaths for both characters
			-- HEY! if you want to get shuffled on dizzy, set this to true!
			local MarbleMadness_NES_ShuffleOnDizzy = false
			-- and leave the rest alone!
			local MarbleMadness_NES_DizzyTimers = memory.read_u8(0x005B, "RAM") + memory.read_u8(0x005C, "RAM")
			local MarbleMadness_NES_RespawnTimers = memory.read_u8(0x0410, "RAM") + memory.read_u8(0x0411, "RAM")
			-- this will update the dizzy timers if they are enabled
			-- TODO: integrate into a global BonusSwaps option
			if MarbleMadness_NES_ShuffleOnDizzy == true then
				return MarbleMadness_NES_DizzyTimers + MarbleMadness_NES_RespawnTimers
			else
				return MarbleMadness_NES_RespawnTimers
			end
		end,
		iframe_minimum=function() return 10 end,
		CanHaveInfiniteLives=false, -- already a feature of the game
		other_swaps=function()
		-- timers: 0x0044 (p1), 0x0045 (p2)
		local p1_timer_changed, p1_timer_curr, p1_timer_prev = update_prev("p1_timer", memory.read_u8(0x0044, "RAM"))
		local p2_timer_changed, p2_timer_curr, p2_timer_prev = update_prev("p2_timer", memory.read_u8(0x0045, "RAM"))
			if 
				(p1_timer_changed and p1_timer_curr == 0 and p1_timer_prev == 1) or
				(p2_timer_changed and p2_timer_curr == 0 and p2_timer_prev == 1)
			then 
				return true
			end
		return false
		end,
	},
	['ResidentEvil_PS1']={ -- Resident Evil [PS1 - NSTC]
		func=resident_evil_1,
		hit=function() return memory.read_u8(0x0C51A8, "MainRAM") end,
		state=function() return memory.read_u8(0x0C8454, "MainRAM") end,
		cut=function() return memory.read_u8(0x0CF63B, "MainRAM") end,
		delay=15
	},
	['ResidentEvil2_PS1']={ -- Resident Evil 2 [PS1 - NSTC]
		func=resident_evil_2,
		hitleon=function() return memory.read_u8(0x0C7D28, "MainRAM") end,
		hitclaire=function() return memory.read_u8(0x0C7AF0, "MainRAM") end,
		hpleon=function() return memory.read_u8(0x0C7E7A, "MainRAM") end,
		hpclaire=function() return memory.read_u8(0x0C7C42, "MainRAM") end,
		timeleon=function() return memory.read_u32_le(0x0CC95E, "MainRAM") end,
		timeclaire=function() return memory.read_u32_le(0x0CC726, "MainRAM") end,
		delay=15
	},
	['ResidentEvil2_PS1_Dualshock']={ -- Resident Evil 2 Dualshock Version [PS1 - NSTC]
		func=resident_evil_2,
		hitleon=function() return memory.read_u8(0x0CFBFC, "MainRAM") end,
		hitclaire=function() return memory.read_u8(0x0CFBB4, "MainRAM") end,
		hpleon=function() return memory.read_u8(0x0CFD4E, "MainRAM") end,
		hpclaire=function() return memory.read_u8(0x0CFD06, "MainRAM") end,
		timeleon=function() return memory.read_u32_le(0x0D4832, "MainRAM") end,
		timeclaire=function() return memory.read_u32_le(0x0D47EA, "MainRAM") end,
		delay=15
	},
	['ResidentEvil3_PS1']={ -- Resident Evil 3 [PS1 - NSTC]
		func=resident_evil_3,
		hit=function() return memory.read_u8(0x0CCBC8, "MainRAM") end,
		time=function() return memory.read_u16_le(0x0D1F98, "MainRAM") end,
		hp=function() return memory.read_u8(0x0D1F98, "MainRAM") end,
		gameover=function() return memory.read_u8(0x0CC858, "MainRAM") end,
		delay=15
	},
	['Pictionary_NES']={ -- Pictionary NES
		func=function()
			return function()
				-- Ignoring firefighter minigame because it's too RNG
				local firefighter = memory.read_u8(0x105, "RAM") == 0x10 -- color palette entry
				-- Pending 'damage' in minigames. This is also regularly incremented by 1 to tick down the timer
				local _, pending, prev_pending = update_prev("pending", memory.read_u8(0x87, "RAM"))
				if prev_pending and (pending - prev_pending) > 1 and not firefighter then return true end

				-- Address of last played sound effect data. Does not change until a different sound is played
				local sound_effect = memory.read_u16_le(0xF6, "RAM")
				-- Changes from 0 to 0xFF while sound is playing on that channel (?)
				local channel5_changed, channel5 = update_prev("channel5", memory.read_u8(0x7D7, "RAM") == 0xFF)
				-- Failure sound, wrong answer, out of time, or swear word
				-- This won't catch repeated failures while the sound effect is still playing, but that's probably not a real issue
				if channel5_changed and channel5 and sound_effect == 0xB75A then return true end

				-- "Not even a gu>ess!<" in the tilemap
				local no_guess_changed, no_guess = update_prev("no_guess", memory.read_u32_be(0x0715, "CIRAM (nametables)") == 0x0E1C1C24)
				if no_guess_changed and no_guess then return true end
			end
		end,
	},
	['TinyToonAdventures_NES']={ -- Tiny Toon Adventures, NES
		func=function()
			return function()
				-- 1 = normal; 2 = hitstun, caught by Elmyra, Hamton carrot exchange; 3 = dead
				local state_changed, state, prev_state = update_prev("state", memory.read_u8(0x066, "RAM"))
				local hamton_screen = memory.read_u32_be(0x6DD, "RAM") == 0x0F352025 -- part of color palette
				return state_changed and prev_state == 1 and (state > 1) and not hamton_screen
			end
		end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x7E0 end,
		maxlives=function() return 9 end,
		ActiveP1=function() return true end,
	},
	['JourneyToSilius_NES']={ -- Journey to Silius, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x00B0, "RAM") end,
		p1getlc=function() return memory.read_u8(0x0053, "RAM") end,
		maxhp=function() return 15 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x0053 end,
		LivesWhichRAM=function() return "RAM" end,
		maxlives=function() return 9 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['SunsetRiders_SNES']={ -- Sunset Riders, SNES
		func=singleplayer_withlives_swap,
		p1gethp=function() return 1 end,
		p1getlc=function() return memory.read_u8(0x1FBA, "WRAM") end,
		maxhp=function() return 1 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x1FBA end,
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 5 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['SunsetRiders_GEN']={ -- Sunset Riders, Genesis
		func=singleplayer_withlives_swap,
		p1gethp=function() return 1 end,
		p1getlc=function() return memory.read_u8(0xb099, "68K RAM") end,
		maxhp=function() return 1 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0xb099 end,
		LivesWhichRAM=function() return "68K RAM" end,
		maxlives=function() return 5 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['SunsetRiders_ARC'] = { -- Sunset Riders (Arcade)
		func=singleplayer_withlives_swap,
		p1gethp=function() return 1 end,
		p1getlc=function() return memory.read_u8(0x0200, "m68000 : ram : 0x104000-0x107FFF") end,
		maxhp=function() return 1 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x0200 end,
		LivesWhichRAM=function() return "m68000 : ram : 0x104000-0x107FFF" end,
		maxlives=function() return 70 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['MysticWarriors_ARC'] = { -- Mystic Warriors (Arcade)
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x0201, "m68000 : ram : 0x200000-0x20FFFF") end,
		p1getlc=function() return memory.read_u8(0x0200, "m68000 : ram : 0x200000-0x20FFFF") end,
		maxhp=function() return 5 end,
		CanHaveInfiniteLives=false,
		p1livesaddr=function() return 0x0200 end,
		LivesWhichRAM=function() return "m68000 : ram : 0x200000-0x20FFFF" end,
		maxlives=function() return 3 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['GoofTroop_SNES']={ -- Goof Troop, SNES
		func=function(gamemeta)
			return function()
				local p1hit_changed, p1hit, p1hit_prev = update_prev("p1hit", memory.read_u8(0x0100))
				local p2hit_changed, p2hit, p2hit_prev = update_prev("p2hit", memory.read_u8(0x0180))
				return (gamemeta.ActiveP1() and p1hit_changed and (p1hit == 3 or p1hit == 4) and (p1hit_prev == 2)) or
				       (gamemeta.ActiveP2() and p2hit_changed and (p2hit == 3 or p2hit == 4) and (p2hit_prev == 2))
			end
		end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "WRAM" end,
		p1livesaddr=function() return 0x0157 end,
		p2livesaddr=function() return 0x01D7 end,
		maxlives=function() return 10 end,
		ActiveP1=function() return memory.read_u8(0x00BD, "WRAM") & 1 ~= 0 end,
		ActiveP2=function() return memory.read_u8(0x00BD, "WRAM") & 2 ~= 0 end,
	},
	['SatNightSlamMasters_SNES']={ -- Saturday Night Slam Masters, SNES - 1p (for now)
		func=health_swap,
		get_health=function() return mainmemory.read_u8(0x879) end,
		is_valid_gamestate=function() return true end,
		suspend_updates=function() 
			-- 0xA89 : p1 grappled timer, 0xB5B : p1 grappled/squeezed flag
			-- if p1 is grappled, don't swap until the grapple is broken or the player loses
			-- leave options for this function in case tweaks needed (note: non-submission holds/combos don't trigger the flag or timer)
			local in_hold_changed, in_hold_curr, in_hold_prev = update_prev("in_hold", mainmemory.read_u8(0xB5B))
			return in_hold_curr == 1
		end,
		other_swaps=function()
			local singles_winner_changed, singles_winner_curr = update_prev("singles_winner", mainmemory.read_u8(0x1C8D))
			-- 0 if double countout, 1 if 1p, 2 if 2p
			local lost_royale_changed, lost_royale_curr, lost_royale_prev = update_prev("lost_royale", mainmemory.read_u8(0x1B78))
			-- 0x80 if active in battle royale, 0x01 if p1 is eliminated
			local countout_over_changed, countout_over_curr = update_prev("countdown_over", mainmemory.read_u8(0x1A62))
			-- 0 for false, 1 for true
			-- if 2p is declared the winner, OR a double countout happens, swap
			if (singles_winner_changed and singles_winner_curr == 2) or 
				(lost_royale_curr == 0x01 and lost_royale_prev == 0x80) or
				(countout_over_changed == true and countout_over_curr == 1 and singles_winner_curr == 0)
			then
				return true
			end
			-- add shuffling on iframes specifically with 0 health
			if mainmemory.read_u8(0x879) == 0 then
				local zerohp_iframes_changed, zerohp_iframes_curr, zerohp_iframes_prev = update_prev("zerohp_iframes", mainmemory.read_u8(0x8BB) > 0)
				if zerohp_iframes_changed == true and zerohp_iframes_curr == true then return true end
			end
			return false
		end,
		grace=80,
		delay=7,
	},
	['WildGuns_SNES']={ -- Wild Guns, SNES
		func=singleplayer_withlives_swap,
		-- only swap during gameplay, not for demo/options
		gmode=function() return memory.read_u8(0x0410, "WRAM") < 4 end,
		p1gethp=function() return 1 end,
		p1getlc=function() return memory.read_u8(0x1fb2, "WRAM") end,
		maxhp=function() return 1 end,
		swap_exceptions=function()
		-- if level complete or ending music has been called, don't swap
		-- this will prevent extra lives ticking down in final tally from swapping
			local _, bonus_ending_curr = update_prev("bonus_ending", (memory.read_u8(0x0120, "WRAM") == 0x0D or memory.read_u8(0x0120, "WRAM") == 0x10))
			if bonus_ending_curr == true then return true end
			return false
		end,
		other_swaps=function()
		-- when game over music is called, swap
		-- gmode will prevent this from happening just because you play it in the sound test
			local game_over_changed, game_over_curr = update_prev("game_over", memory.read_u8(0x0120, "WRAM") == 0x0F)
			if game_over_changed and game_over_curr == true then return true end
			return false
		end,
		-- Wild Guns has infinite continues; infinite lives has been set to false by default for difficulty purposes
		CanHaveInfiniteLives=false, 
		LivesWhichRAM=function() return "WRAM" end,
		p1livesaddr=function() return 0x1fb2 end,
		maxlives=function() return 5 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['SuperSmashTV_SNES']={ -- Super Smash T.V., SNES
		func=singleplayer_withlives_swap,
		p1gethp=function() return 1 end,
		p1getlc=function() return memory.read_u8(0x0531, "WRAM") end,
		maxhp=function() return 1 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "WRAM" end,
		p1livesaddr=function() return 0x0531 end,
		maxlives=function() return 5 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['Jaws_NES']={ -- Jaws, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x038a, "RAM") end, -- submarine
		p1getlc=function() return memory.read_u8(0x0387, "RAM") end,
		maxhp=function() return 1 end,
		minhp=-1,
		other_swaps=function()
			-- goal: shuffle if you fail to defeat Jaws in the final battle
			-- 0x0393 is the strobe counter, in case shuffling individual whiffs becomes possible
			-- The strobe fight transitions either to the ending or, if you fail, sailing in regular gameplay
			-- If you go from strobe fight to normal gameplay, swap
			local scene_changed, scene_curr, scene_prev = update_prev("scene", memory.read_u8(0x046F, "RAM"))
			if scene_changed and scene_curr == 1 and scene_prev == 4 then return true end
			return false
		end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x0387 end,
		maxlives=function() return 5 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['Wits_NES']={ -- Wit's, NES
		func=singleplayer_withlives_swap,
		p1gethp=function() return 1 end, -- let's do vehicle loss in other_swaps rather than here
		p1getlc=function() return memory.read_u8(0x0380, "RAM") end,
		maxhp=function() return 1 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "RAM" end,
		p1livesaddr=function() return 0x0380 end,
		maxlives=function() return 5 end,
		ActiveP1=function() return true end, -- p1 is always active!
		other_swaps=function()
			-- vehicle notes:
			-- 0x0400 is the byte for p1 status, all zeroes if the game hasn't started yet! 
			-- bits 2-5 hold the base value for each level, minus 1 (so, 0 through 5)
			-- bits 6-8 hold player status in a way that is relevant to us.
			-- if we take this address mod 8, we get:
			-- 3 default, 4 jump, 5 vehicle, 6 vehicle jump, 7 dying animation
			-- the relevant bit is, if you go from vehicle to a no-vehicle jump - as in, 5 to 4 - swap
			local vehicle_changed, vehicle_curr, vehicle_prev = update_prev("vehicle", (memory.read_u8(0x400, "RAM") % 8))
			if vehicle_changed and vehicle_curr == 4 and vehicle_prev == 5 then 
				return true
			end
			return false
		end,
	},
	['RohgaArmorForce_SAT']={ -- Wolf Fang SS - Kuuga 2001 (Japan)
		func=health_swap,
		is_valid_gamestate=function() return memory.read_u8(0x0557E1, "Work Ram High")==32 end,
		get_health=function() return memory.read_u8(0x060905, "Work Ram High") end,
		other_swaps=function()
			-- There are no actual lives, so instead shuffle when the continue screen appears.
			local _, continuescreen_cur, continuescreen_prev = update_prev('continuescreen', memory.read_u8(0x055730, "Work Ram High"))
			return continuescreen_cur == 64 and continuescreen_prev == 0
		end,
	},
	['MagicalQuestMickey1_SNES']={ -- The Magical Quest Starring Mickey Mouse (SNES)
		func=health_swap,
		get_health=function() return mainmemory.read_u8(0x2B1) end,
		is_valid_gamestate=function() return mainmemory.read_u8(0x2BF) == 1 and -- check that we are not in the demo (0)
			mainmemory.read_u8(0x360) > 0 and mainmemory.read_u8(0x360) <= 0x40 and -- check if the counter that ticks down seconds of in-game timer is running
			-- check if both in 6-4 and past the final Pete fight (where the timer freezes; HP changes to 1 when ending plays)
			not (mainmemory.read_u8(0x2AB) == 6 and mainmemory.read_u8(0x2AC) == 4 and mainmemory.read_u8(0x2AD) ~= 27) end,
		other_swaps=function() return false end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "WRAM" end,
		p1livesaddr=function() return 0x372 end,
		maxlives=function() return 9 end,
		ActiveP1=function() return true end,
	},
	['MagicalQuestMickey2_SNES']={ -- The Great Circus Mystery Starring Mickey & Minnie (SNES)
		func=twoplayers_withlives_swap,
		p1gethp=function() return mainmemory.read_u8(0x220) end,
		p2gethp=function() return mainmemory.read_u8(0x320) end,
		p1getlc=function() return mainmemory.read_u8(0x29F) end,
		p2getlc=function() return mainmemory.read_u8(0x39F) end,
		maxhp=function() return math.min(math.max(mainmemory.read_u8(0x27F), mainmemory.read_u8(0x37F)), 10) end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "WRAM" end,
		p1livesaddr=function() return 0x29F end,
		p2livesaddr=function() return 0x39F end,
		maxlives=function() return 10 end, -- one more than displayed
		ActiveP1=function() return mainmemory.read_u8(0x200) > 0 end,
		ActiveP2=function() return mainmemory.read_u8(0x300) > 0 end,
	},
	['MagicalQuestMickey3_SNES']={ -- Mickey to Donald - Magical Adventure 3 (SNES)
		func=twoplayers_withlives_swap,
		p1gethp=function() return mainmemory.read_u8(0x46F) end,
		p2gethp=function() return mainmemory.read_u8(0x56F) end,
		p1getlc=function() return mainmemory.read_u8(0x486) end,
		p2getlc=function() return mainmemory.read_u8(0x586) end,
		maxhp=function() return math.min(math.max(mainmemory.read_u8(0x483), mainmemory.read_u8(0x583)), 10) end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "WRAM" end,
		p1livesaddr=function() return 0x486 end,
		p2livesaddr=function() return 0x586 end,
		maxlives=function() return 10 end, -- one more than displayed
		ActiveP1=function() return mainmemory.read_u8(0x400) > 0 end,
		ActiveP2=function() return mainmemory.read_u8(0x500) > 0 end,
	},
	['TwistedMetal2_PSX']={ -- Twisted Metal 2, PSX
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x187D00, "MainRAM") end,
		p1getlc=function() return memory.read_u8(0x164770, "MainRAM") end,
		maxhp=function() return 150 end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "MainRAM" end,
		p1livesaddr=function() return 0x164770 end,
		maxlives=function() return 2 end,
		ActiveP1=function() return true end,
		swap_exceptions=function() 
			-- goal: create a damage threshold, so that only changes of >3 HP trigger HP swaps
			local hp_changed, hp_curr, hp_prev = update_prev("hp", memory.read_u8(0x187D00, "MainRAM"))
			if hp_changed and hp_curr + 3 >= hp_prev and hp_curr < hp_prev then return true end
			return false
		end,
		-- notes for potential future other_swaps: "on fire" flag at 0x187BC6 and 0x1FEF4C, 1 == on fire
		grace=60,
		delay=7,
	},
	['JamesBondJr_SNES']={ -- James Bond Jr., SNES
		func=twoplayers_withlives_swap, 
		-- it's a 1-player game, but we'll treat the kid and the vehicles as two players as their health/lives are stored separately
		p1gethp=function() return memory.read_u8(0x02e7, "WRAM") end,
		p1getlc=function() return memory.read_u8(0x02e6, "WRAM") end,
		p2gethp=function() return 0 end, -- vehicles die instantly
		p2getlc=function() return memory.read_u8(0x110C, "WRAM") end,
		maxhp=function() return 5 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x02e6 end,
		p2livesaddr=function() return 0x110C end,
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 5 end,
		ActiveP1=function() return true end, -- p1 is always active!
		ActiveP2=function() return true end, -- p2 is always active!
	},
	['MortalKombat1_GEN']={ -- Mortal Kombat, Genesis/Mega Drive
		-- possibly useful future notes:
		-- instead of damage directly lowering health, it's put into a "damage buffer" that then lowers health per frame
		-- when p1 is being damaged, 0xCB56 turns to 0x20 (blinks up to 0x21 and back to 0x20 on a throw)
		func=iframe_health_swap,
		is_valid_gamestate=function() return true end,
		get_iframes=function() return memory.read_u16_be(0xCABA, "68K RAM") end, -- todo: work out no shuffle on block
		other_swaps=function() return false end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "68K RAM" end,
		p1livesaddr=function() return 0xAB7B end, -- low byte of 16 bit BE word
		maxlives=function() return 9 end,
		ActiveP1=function() return true end, -- if infinite lives are on, p1 will always be active
		grace=60, -- this should help with punch combos
	},
	['MortalKombatII_SNES']={ -- Mortal Kombat II, SNES
		func=function()
			return function()
				-- what address is the game using to track p1's damage? it tracks how many hits of a combo have been done before resetting to 0
				local umk3_damaged_address_header = memory.read_u8(0x2EF7, "WRAM")
				-- the game picks from 0x01 to 0x0D for the first 4 bits and tacks on 0xA4 to the end to yield the desired address to track
				-- so, shuffle when it goes up, require that it starts at 0, and don't shuffle on blocks (damage <= 10)
				local umk3_p1_damaged_address = umk3_damaged_address_header*16*16 + 0xA4
				local p1_damage_changed, p1_damage_curr, p1_damage_prev = update_prev("p1_damage", memory.read_u8(umk3_p1_damaged_address, "WRAM"))
				-- throws do not increment the combo meter
				local p1hp_changed, p1hp_curr, p1hp_prev = update_prev("p1hp", memory.read_u8(0x2EFC, "WRAM"))
				-- tracking p2's wins for end-of-round shuffling
				local p2_wins_changed, p2_wins_curr, p2_wins_prev = update_prev("p2_wins", memory.read_u8(0x30B2, "WRAM"))
				-- don't shuffle on successful blocks
				-- first, tracking whether p1 is on ground; highest y-coord of "ground" is 175 (the pit) -- if airborne, blocking should not work
				local p1_ycoord_changed, p1_ycoord_curr, p1_ycoord_prev = update_prev("p1_ycoord", memory.read_u8(0x280C, "WRAM"))
				local p1_on_ground = (p1_ycoord_curr > 174 and p1_ycoord_changed == false)
				-- second, checking if block is pressed -- if 0x267A third bit is on, player is holding block
				local p1_blocking_changed, p1_blocking_curr = update_prev("p1_blocking", math.floor(memory.read_u8(0x2D7A, "WRAM")/32) % 2 == 1)
				-- SHUFFLE CONDITIONS:
				-- if we are on a screen where you cannot fight, for example, menus, don't swap - continue screen is fine
				if memory.read_u8(0x3256, "WRAM") ~= 1 then return false end
				-- if p2 just won round 1, or has 2 wins and the match rolls over to the continue screen, then swap
				-- but don't swap right on winning their second match, to avoid doubles
				if (p2_wins_curr == 2 and p2_wins_prev == 1) then return false end
				if (p2_wins_curr == 1 and p2_wins_prev == 0) or (p2_wins_curr == 0 and p2_wins_prev == 2) then return true, 8 end
				-- if the damage counter goes up from 0, swap; this will keep combos from repeatedly swapping
				-- if the player has 0 HP, don't swap; let round 1/match win handle that so you swap after fatality, friendship, etc.
				if p1_damage_changed and p1_damage_prev == 0 and not p2_wins_changed and p1hp_curr ~= 0 and
					-- don't shuffle on successful blocks
					not (p1_on_ground == true and p1_blocking_curr == true and p1hp_curr >= p1hp_prev - 10)
				then
					return true, 6
				end
				-- if the player is damaged above the threshold without incrementing the combo meter, as with a throw, swap
				if p1_damage_curr == 0 and p1hp_changed and p1hp_curr < p1hp_prev - 10 then return true, 15 end
				return false
			end
		end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "WRAM" end,
		p1livesaddr=function() return 0x30B8 end,
		maxlives=function() return 9 end,
		ActiveP1=function() return true end,
		grace=40,
	},
	['UltimateMortalKombat3_SNES']={ -- Ultimate Mortal Kombat 3, SNES
		func=function()
			return function()
				-- what address is the game using to track p1's damage? it tracks how much damage has been done in a combo before resetting to 0
				local umk3_damaged_address_header = memory.read_u8(0x36CF, "WRAM")
				-- the game picks from 0x01 to 0x0B for the first 4 bits and tacks on 0xAA to the end to yield the desired address to track
				-- so, shuffle when it goes up, require that it starts at 0, and don't shuffle on blocks (damage < 8)
				local umk3_p1_damaged_address = umk3_damaged_address_header*16*16 + 0xAA
				local p1_damage_changed, p1_damage_curr, p1_damage_prev = update_prev("p1_damage", memory.read_u8(umk3_p1_damaged_address, "WRAM"))
				-- tracking p2's wins for end-of-round shuffling
				local p1hp_changed, p1hp_curr, p1hp_prev = update_prev("p1hp", memory.read_u8(0x36D4, "WRAM"))
				-- tracking p2's wins for end-of-round shuffling
				local p2_wins_changed, p2_wins_curr, p2_wins_prev = update_prev("p2_wins", memory.read_u8(0x38A4, "WRAM"))
				-- SHUFFLE CONDITIONS:
				-- if we are on a screen where you cannot fight, for example, menus, don't swap - continue screen is fine
				if memory.read_u8(0x3A7E, "WRAM") > 0x09 and not (memory.read_u8(0x3A7E, "WRAM") == 0x0F) then return false end
				-- if p2 just won round 1, or has 2 wins and the match rolls over to the continue screen, then swap
				-- but don't swap right on winning their second match, to avoid doubles
				if (p2_wins_curr == 2 and p2_wins_prev == 1) then return false end
				if (p2_wins_curr == 1 and p2_wins_prev == 0) or (p2_wins_curr == 0 and p2_wins_prev == 2) then return true, 8 end
				-- if the damage counter goes up from 0, swap; this will keep combos from repeatedly swapping
				-- if the player has 0 HP, don't swap; let round 1/match win handle that so you swap after fatality, friendship, etc.
				if p1_damage_changed and p1_damage_curr >= 8 and p1_damage_prev == 0 and not p2_wins_changed and p1hp_curr ~= 0 then return true, 6 end
				-- if the player is thrown, damage won't change, but HP will drop by > 10, swap then
				if not p1_damage_changed and p1hp_prev and p1hp_curr ~= 0 and p1hp_curr < p1hp_prev - 10 then return true, 15 end
				return false
			end
		end,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "WRAM" end,
		p1livesaddr=function() return 0x38AA end,
		maxlives=function() return 9 end,
		ActiveP1=function() return true end,
		grace=40,
	},
	['THPS1_PS1']={ -- Tony Hawk's Pro Skater, PS1
		func=thps_swap,
		get_pointer_one=function() return memory.read_u32_le(0xD17C8, "MainRAM") end,
		get_pointer_two=function() return memory.read_u32_le(0xD19A4, "MainRAM") end,
		get_bails=function()
			local pointer = memory.read_u32_le(0xD19A4, "MainRAM") & 0xFFFFFF
			return memory.read_u16_le(pointer + 0x930, "MainRAM")
		end,
	},
	['THPS2_PS1']={ -- Tony Hawk's Pro Skater 2, PS1
		func=thps_swap,
		get_pointer_one=function() return memory.read_u32_le(0xD291C, "MainRAM") end,
		get_pointer_two=function() return memory.read_u32_le(0xD67E0, "MainRAM") end,
		get_bails=function()
			local pointer = memory.read_u32_le(0xD67E0, "MainRAM") & 0xFFFFFF
			return memory.read_u16_le(pointer + 0x170, "MainRAM")
		end,
	},
	['THPS3_PS1']={ -- Tony Hawk's Pro Skater 3, PS1
		func=thps_swap,
		get_pointer_one=function() return memory.read_u32_le(0xD2E00, "MainRAM") end,
		get_pointer_two=function() return memory.read_u32_le(0xD68C4, "MainRAM") end,
		get_bails=function()
			local pointer = memory.read_u32_le(0xD68C4, "MainRAM") & 0xFFFFFF
			return memory.read_u16_le(pointer + 0x170, "MainRAM")
		end,
	},
	['THPS4_PS1']={ -- Tony Hawk's Pro Skater 4, PS1
		func=thps_swap,
		get_pointer_one=function() return memory.read_u32_le(0xD532C, "MainRAM") end,
		get_pointer_two=function() return memory.read_u32_le(0xD8C58, "MainRAM") end,
		get_bails=function()
			local pointer = memory.read_u32_le(0xD8C58, "MainRAM") & 0xFFFFFF
			return memory.read_u16_le(pointer + 0x170, "MainRAM")
		end,
	},
	['TecmoSuperBowl_NES']={ -- Tecmo Super Bowl NES
		func=TecmoSuperBowl_NES_swap,
		-- do not shuffle if we are watching the scoreboard for skipped in-season games
		gmode=function() return memory.read_u8(0x0075, "RAM") ~= 0x33 and memory.read_u8(0x0070, "RAM") ~= 0xFF end,
		get_p1_possession=function() return memory.read_u8(0x0070, "RAM") < 0x80 end,
		get_whatdown=function() return memory.read_u8(0x0077, "RAM") end,
		get_picking_play=function() return memory.read_u8(0x030A, "RAM") == 0x22 or memory.read_u8(0x030A, "RAM") == 0x1E end,
		get_p1_points=function() return
			math.floor(memory.read_u8(0x0399, "RAM")/16)*10 +
			(memory.read_u8(0x0399, "RAM") % 16)
		end, -- this is actually a hex value that just skips A-F on screen. Transformed.
		get_p2_points=function() return
			math.floor(memory.read_u8(0x039E, "RAM")/16)*10 +
			(memory.read_u8(0x039E, "RAM") % 16)
		end, -- this is actually a hex value that just skips A-F on screen. Transformed.
		get_p1_kickoff=function() return memory.read_u8(0x0070, "RAM") == 0x8B end,
		get_p2_kickoff=function() return memory.read_u8(0x0070, "RAM") == 0x48 end,
		get_end_of_game=function()
			-- We will check the scoreboard at the end of the game, and if p2 points are greater than p1 points, swap
			-- I guess we won't swap on ties. Herm Edwards would not enjoy that but whatever
			local OT_or_Q4_ended_changed, OT_or_Q4_ended_curr = update_prev("OT_or_Q4_ended", (memory.read_u8(0x0076, "RAM") >= 3 and memory.read_u8(0x002D, "RAM") % 16 >= 0x8 and memory.read_u8(0x002D, "RAM") % 16 <=0xB))
			return OT_or_Q4_ended_changed and not OT_or_Q4_ended_curr -- wait until the scoreboard shows
		end,
		get_music_cue=function() 
			if memory.read_u8(0x0700, "RAM") == 0x2B or memory.read_u8(0x0700, "RAM") == 0x01 then
				return memory.read_u8(0x0700, "RAM") 
			else
				return 0
			end
		end,
	},
	['Powerslave_SAT']={ -- Powerslave, Saturn
		func=health_swap,
		get_health=function() return memory.read_s16_be(0x8608A, "Work Ram High") end,
		is_valid_gamestate=function()
			if memory.read_u8(0x90DF9, "Work Ram High") ~= 0x11 then
				return false
			end

			-- This would go better in swap_exceptions, but going by the current flow of health_swap, is_valid_gamestate is used the same way???
			-- Lava check
			-- Here's how this works internally, according to SRUINS.C:179 in the SlaveDriver source code @ https://github.com/Lobotomy-Software/SlaveDriver-Engine/:
			--
			-- When the player touches lava or slime, ltHurtTime is set to 30 (BizHawk shows it as 29 though?) and ltHurtAmount is set to how much damage the floor will do per frame.
			-- If you lack the Protective Anklet, this will be 20 HP per frame (and the player will almost certainly die, as there aren't enough health Ankhs before the Anklets to eat that damage).
			-- If you HAVE the Protective Anklet, this is 2 HP per frame for lava, and 0 HP per frame for slime. (Slime DOES hurt on PS1, but not on Saturn.)
			-- These values are set constantly as long as contact is maintained, but when contacct breaks, ltHurtTime is allowed to count down to 0.
			-- While ltHurtTime is above 0, the value of ltHurtAmount is done to player health. When it reaches 0, damage stops.
			-- The value of ltHurtAmount lingers at whatever the last value it was set to was.
			local hurtfloordrain_changed, hurtfloordrain_curr, hurtfloordrain_prev = update_prev("hurtfloor_drain_swapexceptions", memory.read_u16_be(0x4A58A, "Work Ram High"))
			if
				hurtfloordrain_curr ~= nil
				and hurtfloordrain_prev ~= nil
				and hurtfloordrain_curr >= 0
				and hurtfloordrain_prev > 0
				and memory.read_u16_be(0x4A586, "Work Ram High") ~= 0 -- Player isn't on slime while protected by anklets
			then
				return false -- Lava drain had already started and hasn't stopped, do not shuffle so the player has a chance to reorient themselves
			end

			-- Drowning check
			-- Here's how this works internally, according to SRUINS.C:1421 in the SlaveDriver source code @ https://github.com/Lobotomy-Software/SlaveDriver-Engine/:
			--
			-- 1. If the player is underwater, underCount goes up, apparently by two.
			-- 2. If underCount hits 220, airStatus is increased by 27.0. (It's technically a 32-bit 16.16 fixed-point variable, but it's only modified by integer values.)
			-- 3. If airStatus is above 270.0:
			--     * Player health is docked 30.
			--     * airStatus is set back to 270.0.
			--     * underCount is set to the value of drownStatus.
			--     * drownStatus is set to 180, so subsequent drowning loops will happen much faster.
			-- 4. Else, underCount continues going up until 240, when it's set back to 0.
			--     * drownStatus is also set to 0 in this instance, in preparation for the loop in step 3.
			-- 5. If the player surfaces:
			--     * underCount is set to -1.
			--     * airStatus is set to 0.0.
			--     * drownStatus is left at whatever value is was before - 0 or 180 - and thus can't be the sole indicator of fast drowning.
			-- Note that all of this presumes you have the Sobek Mask to prolong underwater breathing.
			-- If you don't, airStatus is immediately set to 270.0, and drownStatus is never reset from 180.
			local underCount_changed, underCount, underCount_prev = update_prev("underCount", memory.read_s16_be(0x4A5E6, "Work Ram High"))
			local drownStatus_changed, drownStatus, drownStatus_prev = update_prev("drownStatus", memory.read_s16_be(0x4A5CE, "Work Ram High"))
			local airStatus = memory.read_s16_be(0x4A5C8, "Work Ram High")
			if
				airStatus == 270 -- Drowning threshold reached
				and underCount_changed
				and underCount_prev > underCount -- underCount dropped from 220
				and drownStatus == 180
				--and not drownStatus_changed -- If this JUST shot up to 180, let the drowning initiation cause a shuffle anyway
			then
				return false -- Damage was caused by drowning, do not shuffle so the player has a chance to reorient themselves
			end

			-- Everything checks out
			return true
		end,
		grace=90,
	},
	['Exhumed_SAT']={ -- Exhumed (Powerslave PAL), Saturn
		func=health_swap,
		get_health=function() return memory.read_s16_be(0x85286, "Work Ram High") end,
		is_valid_gamestate=function()
			if memory.read_u8(0x8FFE5, "Work Ram High") ~= 0x11 then
				return false
			end

			-- This would go better in swap_exceptions, but going by the current flow of health_swap, is_valid_gamestate is used the same way???
			-- Lava check (see Powerslave for pseudocode breakdown)
			local hurtfloordrain_changed, hurtfloordrain_curr, hurtfloordrain_prev = update_prev("hurtfloor_drain_swapexceptions", memory.read_u16_be(0x498C2, "Work Ram High"))
			if
				hurtfloordrain_curr ~= nil
				and hurtfloordrain_prev ~= nil
				and hurtfloordrain_curr >= 0
				and hurtfloordrain_prev > 0
				and memory.read_u16_be(0x498BE, "Work Ram High") ~= 0 -- Player isn't on slime while protected by anklets
			then
				return false -- Lava drain had already started and hasn't stopped, do not shuffle so the player has a chance to reorient themselves
			end

			-- Drowning check (see Powerslave for pseudocode breakdown)
			local underCount_changed, underCount, underCount_prev = update_prev("underCount", memory.read_s16_be(0x4991E, "Work Ram High"))
			local drownStatus_changed, drownStatus, drownStatus_prev = update_prev("drownStatus", memory.read_s16_be(0x49906, "Work Ram High"))
			local airStatus = memory.read_s16_be(0x49900, "Work Ram High")
			if
				airStatus == 270 -- Drowning threshold reached
				and underCount_changed
				and underCount_prev > underCount -- underCount dropped from 220
				and drownStatus == 180
				--and not drownStatus_changed -- If this JUST shot up to 180, let the drowning initiation cause a shuffle anyway
			then
				return false -- Damage was caused by drowning, do not shuffle so the player has a chance to reorient themselves
			end

			-- Everything checks out
			return true
		end,
		grace=90,
	},
	['Seireki1999_SAT']={ -- Seireki 1999: Pharaoh no Fukkatsu (Powerslave NTSC-J), Saturn
		func=health_swap,
		get_health=function() return memory.read_s16_be(0x86B52, "Work Ram High") end,
		is_valid_gamestate=function()
			if memory.read_u8(0x918C1, "Work Ram High") ~= 0x11 then
				return false
			end

			-- This would go better in swap_exceptions, but going by the current flow of health_swap, is_valid_gamestate is used the same way???
			-- Lava check (see Powerslave for pseudocode breakdown)
			local hurtfloordrain_changed, hurtfloordrain_curr, hurtfloordrain_prev = update_prev("hurtfloor_drain_swapexceptions", memory.read_u16_be(0x4A822, "Work Ram High"))
			if
				hurtfloordrain_curr ~= nil
				and hurtfloordrain_prev ~= nil
				and hurtfloordrain_curr >= 0
				and hurtfloordrain_prev > 0
				and memory.read_u16_be(0x4A81E, "Work Ram High") ~= 0 -- Player isn't on slime while protected by anklets
			then
				return false -- Lava drain had already started and hasn't stopped, do not shuffle so the player has a chance to reorient themselves
			end

			-- Drowning check (see Powerslave for pseudocode breakdown)
			local underCount_changed, underCount, underCount_prev = update_prev("underCount", memory.read_s16_be(0x4A87E, "Work Ram High"))
			local drownStatus_changed, drownStatus, drownStatus_prev = update_prev("drownStatus", memory.read_s16_be(0x4A866, "Work Ram High"))
			local airStatus = memory.read_s16_be(0x4A860, "Work Ram High")
			if
				airStatus == 270 -- Drowning threshold reached
				and underCount_changed
				and underCount_prev > underCount -- underCount dropped from 220
				and drownStatus == 180
				--and not drownStatus_changed -- If this JUST shot up to 180, let the drowning initiation cause a shuffle anyway
			then
				return false -- Damage was caused by drowning, do not shuffle so the player has a chance to reorient themselves
			end

			-- Everything checks out
			return true
		end,
		grace=90,
	},
	['PsychoNicsOscar_ARC']={ -- Psycho-Nics Oscar (World revision 0)
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x0042, "hd6309 : ram : 0x0-0xEFF") end,
		p1getlc=function() return memory.read_u8(0x007D, "hd6309 : ram : 0x0-0xEFF") end,
		maxhp=function() return 5 end,
		gmode=function() return memory.read_u8(0x0015, "hd6309 : ram : 0x0-0xEFF")==128 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x007D end,
		LivesWhichRAM=function() return "RAM" end,
		maxlives=function() return 5 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['EarnestEvans_SCD']={ -- Earnest Evans, Mega CD
		func=singleplayer_withlives_swap,
		p1gethp=function() return math.max((64 * memory.read_s16_be(0xA4AE, "68K RAM")) + memory.read_u16_be(0xA4B0, "68K RAM"), -1) end,
		p1getlc=function()
			-- While there is technically a RAM address for continues, it
			-- makes more sense to shuffle on the continue screen appearing than
			-- it does the player using up a continue
			local gameOverState = memory.read_u16_be(0x1588, "68K RAM")
			if (gameOverState == 0x03 or gameOverState == 0x04) then
				return -1
			else
				return 0
			end
		end,
		maxhp=function() return 320 end,
		minhp=-1,
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "68K RAM" end,
		p1livesaddr=function() return 0xBF11 end, -- Technically continues
		maxlives=function() return 5 end, -- Tile used seems to be modulo 10, and only 0-5 show as numbers; an actual value of 0 on the Continue screen immediately triggers a Game Over, however
		ActiveP1=function() return true end, -- p1 is always active!
		grace=90, -- TODO: Find good value for health that drains with no I-frames
	},
	['SanrioWorldSmashBall_SNES']={ -- Sanrio World Smash Ball!, SNES
		-- infinite lives does not apply, you can always continue
		-- track the opponent's wins by treating them as reverse lives
		func=twoplayers_withlives_swap,
		p1gethp=function() return 0 end,
		p2gethp=function() return 0 end,
			-- p1 is always active and, outside of 2p mode, on the bottom
			-- so as long as the bottom player isn't inactive (0xFF), track their wins (inverted)
		p1getlc=function()
			if memory.read_u8(0x0061, "WRAM") ~= 0xFF then
				return memory.read_u8(0x005E, "WRAM") * -1
			else
				return 0
			end
		end,
			-- p2 is active if this address == 0 or == 2, if 0xFF then CPU controlled, so only track p1's wins if p2 is human
		p2getlc=function()
			if memory.read_u8(0x0063, "WRAM") ~= 0xFF then
				return memory.read_u8(0x005D, "WRAM") * -1
			else
				return 0
			end
		end,
		maxhp=function() return 0 end,
	},
	['ShaqFu_GEN']={ -- Shaq-Fu, Genesis
		func=singleplayer_withlives_swap,
		p1gethp=function() return mainmemory.read_u8(0x80C9) end,
		p1getlc=function() return mainmemory.read_u8(0xEA12) * -1 end, -- wins by p2, inverted
		-- notes for future 2p support: p2 will be active if we are in duel mode ONLY
		-- 0x9480 in duel mode: == 1 for 1p, == 2 for 2p
		maxhp=function() return mainmemory.read_u8(0x8FBB) end,
		swap_exceptions=function() 
		local maxhpval_changed = update_prev("maxhpval", mainmemory.read_u8(0x8FBB))
		return mainmemory.read_u8(0xEADB) == 0x01 or maxhpval_changed == true end, -- if 0x80, we are in demo, not in actual gameplay
		CanHaveInfiniteLives=true,
		LivesWhichRAM=function() return "68K RAM" end,
		p1livesaddr=function() return 0xEA07 end, -- continues
		maxlives=function() return 9 end, -- continues
		ActiveP1=function() return true end, -- p1 is always active!
		grace=60,
	},
	['NinjaWarriorsAgain_SNES']={ -- Ninjawarriors, SNES (USA)
		func=health_swap,
		is_valid_gamestate=function() return true end,
		get_health=function() return memory.read_u8(0x0018B2, "WRAM") end,
		other_swaps=function() return false end,
	},
	['Gremlins2_NES']={ -- Gremlins 2: The New Batch, NES (US)
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x00AD, "RAM") end,
		p1getlc=function() return memory.read_u8(0x057C, "RAM") end,
		maxhp=function() return 8 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x057C end,
		LivesWhichRAM=function() return "RAM" end,
		maxlives=function() return 9 end,
		ActiveP1=function() return true end, -- p1 is always active!
		other_swaps=function()
			-- Shuffle when a balloon is used to save from a pit even though there's no actual damage
			local balloon_changed, balloon_curr, balloon_prev = update_prev('balloon', memory.read_u8(0x050C, "RAM"))
			return balloon_changed and balloon_curr < balloon_prev end,
    },
	['GargoylesQuest2_NES']={ -- Gargoyle's Quest II, NES, (US)
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x0038, "RAM") end,
		p1getlc=function() return memory.read_u8(0x0039, "RAM") end,
		maxhp=function() return 9 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x0039 end,
		LivesWhichRAM=function() return "RAM" end,
		maxlives=function() return 9 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['PowerRangersMovie_SNES']={ -- Mighty Morphin Power Rangers - The Movie, SNES (USA)
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x000628, "WRAM") end,
		p1getlc=function() return memory.read_u8(0x000602, "WRAM") end, -- continues provided instead of lives since the game's a little easy and you're revived on the spot with lives
		maxhp=function() return 5 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x000602 end,
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 9 end,
		ActiveP1=function() return true end, -- p1 is always active!
		other_swaps=function() 
			-- shuffler also has to detect lost lives
			local MMPRlives_changed, MMPRlives_curr, MMPRlives_prev = update_prev('MMPRlives', memory.read_u8(0x00060A, "WRAM"))
			return MMPRlives_changed and MMPRlives_curr < MMPRlives_prev
			end,
	},
	['BonksAdventure_TG16']={ -- Bonk's Adventure, TG-16 (U)
		func=singleplayer_withlives_swap,
		gmode=function() return memory.read_u8(0x1A18, "Main Memory") == 1 end,
		p1gethp=function() return memory.read_u8(0x0DB4, "Main Memory") end,
		p1getlc=function() return memory.read_u8(0x0DB1, "Main Memory") end,
		maxhp=function() return 25 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x0DB1 end,
		LivesWhichRAM=function() return "Main Memory" end,
		maxlives=function() return 70 end,
		ActiveP1=function() return true end, -- p1 is always active!
		other_swaps=function()
			-- Swap if you lose your meat power up through damage, but not from the timer.
			local meatlevel_changed, meatlevel_cur, meatlevel_prev = update_prev('meatlevel', memory.read_u8(0x0DBA, "Main Memory"))
			local _, _, meatseconds_prev = update_prev('meatseconds', memory.read_u8(0x0DC2, "Main Memory"))
			local _, _, meatmillis_prev = update_prev('meatmillis', memory.read_u8(0x0DC1, "Main Memory"))
			return meatlevel_changed and meatlevel_cur < meatlevel_prev and (meatseconds_prev ~= 0 or meatmillis_prev ~= 1) end,
	},
	['Pepsiman_PSX']={ -- Pepsiman (Japan)
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x0958A8, "MainRAM") end,
		p1getlc=function() return memory.read_u8(0x095770, "MainRAM") end,
		maxhp=function() return 3 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x095770 end,
		LivesWhichRAM=function() return "MainRAM" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!
		other_swaps=function()
			-- Swap for "boss" levels where something chases you towards the screen.
			-- Damage seems to be in distance rather than health points or something like that, so the target value differs between stages and changes each frame after hit until the target.
			local chase_damage = memory.read_u8(0x0CEF78, "MainRAM")		
			
			-- i-frames are at a different address per stage, but always goes from 0 to 60 when hit.
			local stage1_iframes_changed, stage1_iframes_cur, stage1_iframes_prev = update_prev('stage1_iframes', memory.read_u8(0x0F80B0, "MainRAM"))
			local stage2_iframes_changed, stage2_iframes_cur, stage2_iframes_prev = update_prev('stage2_iframes', memory.read_u8(0x0F8004, "MainRAM"))
			local stage3_iframes_changed, stage3_iframes_cur, stage3_iframes_prev = update_prev('stage3_iframes', memory.read_u8(0x0F57DC, "MainRAM"))
			local stage4_iframes_changed, stage4_iframes_cur, stage4_iframes_prev = update_prev('stage4_iframes', memory.read_u8(0x0F4AD8, "MainRAM"))
			
			return
			(stage1_iframes_changed and stage1_iframes_cur == 60 and stage1_iframes_prev == 0 and chase_damage > 32) or
			(stage2_iframes_changed and stage2_iframes_cur == 60 and stage2_iframes_prev == 0 and chase_damage > 114) or
			(stage3_iframes_changed and stage3_iframes_cur == 60 and stage3_iframes_prev == 0 and chase_damage > 88) or
			(stage4_iframes_changed and stage4_iframes_cur == 60 and stage4_iframes_prev == 0 and chase_damage > 32)
			end,
	},
	['MarioKartSuperCircuit_GBA']={ -- Mario Kart: Super Circuit (GBA), 1p, GP mode
		func=singleplayer_withlives_swap,
		gmode=function() return memory.read_u8(0x3634, "IWRAM") > 0 -- how many racers? if 0, we aren't in a race
			end, 
		p1gethp=function() return memory.read_u8(0x3D10, "IWRAM") end, -- coins; we'll only swap if these drop on being bumped
		p1getlc=function() return 0 end, -- not swapping on using a continue; the timing of "losing a life" that way is not desirable
		maxhp=function() return 99 end,
		minhp=-1,
		-- TODO: squish
		swap_exceptions=function() 
			local bumpcount_changed, bumpcount_curr, bumpcount_prev = update_prev("bumpcount", memory.read_u8(0x3AE8, "IWRAM"))
			local coins_changed, coins_curr, coins_prev = update_prev("coins", memory.read_u8(0x3D10, "IWRAM"))
			local _, hits_curr, hits_prev = update_prev("hits", memory.read_u8(0x3AEA, "IWRAM"))
			return 
				(coins_changed and (coins_curr < coins_prev) 
					and not (bumpcount_curr > bumpcount_prev or hits_curr > hits_prev)) -- if coins dropped with no bump, like Lakitu's fee or Boo stealing them, don't swap
				or
				memory.read_u8(0x3A28, "IWRAM") ~= 7 -- 7 == in-race camera mode; prevents swaps after end of race/loading next race
			end, 
		other_swaps=function()
			local spinningout_changed, spinningout_curr = update_prev("spinningout", math.floor(memory.read_u8(0x3BF0, "IWRAM")/16) == 1)
			if (spinningout_changed == true and spinningout_curr == true) then return true end
			local fell_changed, fell_curr = update_prev("fell", memory.read_u8(0x3C10, "IWRAM") > 1)
			-- 0 on road, 1 jumping/skipping over water, 2-8 are in pits/rescued by lakitu
			if (fell_changed == true and fell_curr == true) then return true end
			local _, hits_curr, hits_prev = update_prev("hits", memory.read_u8(0x3AEA, "IWRAM"))
			-- counts being hit by items, including banana peels that otherwise wouldn't swap you
			if hits_prev and hits_curr > hits_prev then return true end
			return false
		end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x000C end,
		LivesWhichRAM=function() return "IWRAM" end,
		maxlives=function() return 3 end,
		ActiveP1=function() return true end, -- p1 is always active!
		delay=5, -- good to give a slightly higher delay to make the damage more readable to the player
	},

	['CrashBandicoot1_PS1_USA']={
		-- TODO: swap on death in bonus stages
		func=function(gamemeta)
			return function()
				local active = gamemeta.get_active()
				local _, deaths, prev_deaths = update_prev('deaths', gamemeta.get_deaths())
				local _, shield, prev_shield = update_prev('shield', active and value_in_range(gamemeta.get_shield(), 0, 3) or false)
				if not active or not shield then
					return false
				end
				return (prev_deaths and deaths > prev_deaths) or
				       (shield and prev_shield and shield < math.min(prev_shield, 2)) -- shield 3 is temp invincibility
			end
		end,
		get_shield=function()
			local addr = follow_psx_ptr(true, 0x0618CC, 0x189)
			return addr and mainmemory.read_u8(addr)
		end,
		get_deaths=function()
			return mainmemory.read_u24_le(0x0618A1)
		end,
		get_active=function()
			return mainmemory.read_u8(0x061994) == 0 and -- not on the map
			       mainmemory.read_u32_le(0x0566C0) == 3 and -- some kind of player state?
				   value_in_range(mainmemory.read_u32_le(0x056710), 0x03, 0x37) and -- valid stage
				   mainmemory.read_u32_le(0x061A30) == 0 -- not in demo
		end,
		CanHaveInfiniteLives = true,
		LivesWhichRAM = function() return "MainRAM" end,
		p1livesaddr=function()
			return mainmemory.read_u8(0x061994) == 0 and -- are we in a stage?
			       follow_psx_ptr(true, 0x80060DEC, 0x164+1) or -- stage-specific address
			       0x0618EC -- map address
		end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end,
	},
	['CrashBandicoot2_PS1_USA']={
		func=function(gamemeta)
			return function()
				local active = gamemeta.get_active()

				-- set to 4 by iframes and conveniently also upon death (pits, etc.)
				local invuln_addr = follow_psx_ptr(true, 0x06CB10, 0x108)
				local invuln_changed, invuln = update_prev("invuln", active and invuln_addr and mainmemory.read_u32_le(invuln_addr) or false)

				if not active or not invuln_addr then
					return false
				end

				--local stage = mainmemory.read_u8(0x06CB71)
				local stage = mainmemory.read_u16_be(0x06CB70)
				if stage == 0x07 then -- Cortex boss fight
					-- hit obstacle
					local collision_changed, collision = update_prev('collision', mainmemory.read_u32_le(0xACF2C) == 2 and mainmemory.read_u16_le(0xACF7C) == 2)
					if collision_changed and collision then
						return true, 8
					end
				end

				return invuln_changed and invuln == 4
			end
		end,
		get_active=function()
			local state = mainmemory.read_u8(0x06CB82)
			local stage = value_in_range(mainmemory.read_u16_be(0x06CB70), 0x03, 0x27)
			local demo = mainmemory.read_u32_le(0x06CD14) > 0
			return state == 1 and stage ~= nil and not demo
		end,
		CanHaveInfiniteLives = true,
		LivesWhichRAM = function() return "MainRAM" end,
		p1livesaddr=function()
			local stage = value_in_range(mainmemory.read_u8(0x06CB71), 0x02, 0x27)
			if stage == 0x02 then
				return 0x06CBD1 -- warp room
			elseif stage then
				return follow_psx_ptr(true, 0x06CB10, 0x145)
			end
		end,
		maxlives = function() return 69 end,
		ActiveP1=function() return true end,
	},
	['CrashBandicoot3_PS1_USA']={
		func=function(gamemeta)
			return function()
				local active = gamemeta.get_active()

				-- set to 4 by iframes and conveniently also upon death (pits, etc.)
				local invuln_addr = follow_psx_ptr(true, 0x068E98, 0x108)
				local invuln_changed, invuln = update_prev("invuln", active and invuln_addr and mainmemory.read_u32_le(invuln_addr) or false)

				if not active or not invuln_addr then
					return false
				end

				local stage = mainmemory.read_u16_be(0x068EF8)
				if stage == 0x14 or stage == 0x15 or stage == 0x20 or stage == 0x25 then -- Motorcycle stages
					local anim_changed, anim = gamemeta.update_animation()
					return anim_changed and (
						anim == 0x31 or -- crash into cop car
						anim == 0x34 or -- falling into pit
						anim == 0x35 or -- off the track
						anim == 0x36 -- lost race
					), 30
				elseif stage == 0x05 or stage == 0x13 or stage == 0x17 then -- N. Gin, Bye Bye Blimps, Mad Bombers (dogfights)
					local health_addr = follow_psx_ptr(true, 0x060A90, 0xE5)
					local _, health, prev_health = update_prev("plane_health", health_addr and
						value_in_range(mainmemory.read_u8(health_addr), 0, 100) or false)
					if health and prev_health and health < prev_health then
						start_countdown("plane_hit", 16, true)
					else
						return update_countdown("plane_hit")
					end
				elseif stage == 0x1F then -- Rings of Power (air race)
					local place = mainmemory.read_u32_le(0x0AF7F4)
					local anim_changed, anim = gamemeta.update_animation()
					if anim_changed and anim == 0x2B and place > 1 then -- race over, didn't come in first
						return true, 60
					end
				end

				return invuln_changed and invuln == 4
			end
		end,
		get_active=function()
			local state = mainmemory.read_u8(0x068F3D) -- stage transitions etc.
			local stage = value_in_range(mainmemory.read_u16_be(0x068EF8), 0x03, 0x26) -- regular stages excluding hub, intro, etc.
			local frame_counter = mainmemory.read_u32_le(0x068EEC)
			local demo = mainmemory.read_u16_le(0x06909C) > 0

			return state == 1 and
				   not demo and
				   frame_counter > 0 and
			       stage ~= nil
		end,
		update_animation=function()
			local anim_addr = follow_psx_ptr(true, 0x068E98, 0x1C)
			return update_prev("animation", anim_addr and mainmemory.read_u32_le(anim_addr) or false)
		end,
		CanHaveInfiniteLives = true,
		LivesWhichRAM = function() return "MainRAM" end,
		p1livesaddr=function()
			local stage = value_in_range(mainmemory.read_u16_be(0x068EF8), 0x02, 0x26)
			if stage == 0x02 then
				return 0x068F59 -- warp room
			elseif stage then
				return follow_psx_ptr(true, 0x068E98, 0x145)
			end
		end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end,
	},
	['AstroBoyOmegaFactor_GBA']={ -- Astro Boy - Omega Factor, GBA (USA)
		func=health_swap,
		is_valid_gamestate=function() return true end,
		get_health=function() return memory.read_u32_le(0x2802, "IWRAM") end,
		other_swaps=function() return false end,
	},
	['BangaiO_N64']={ -- Bakuretsu Muteki Bangaioh (Japan)
		func=health_swap,
		is_valid_gamestate=function() return memory.read_u8(0x0A6847, "RDRAM")==160 end,
		get_health=function()
			-- health is stored separately by level
			local currstage = memory.read_u8(0x147DEB, "RDRAM")
			if currstage == 1 then return memory.read_s8(0x1E4B39, "RDRAM")
				elseif currstage == 2 then return memory.read_s8(0x1E1DB9, "RDRAM")
				elseif currstage == 3 then return memory.read_s8(0x1E4D39, "RDRAM")
				elseif currstage == 4 then return memory.read_s8(0x1E11B9, "RDRAM")
				elseif currstage == 5 then return memory.read_s8(0x1E3639, "RDRAM")
				elseif currstage == 6 then return memory.read_s8(0x1E4EB9, "RDRAM")
				elseif currstage == 7 then return memory.read_s8(0x1E5D39, "RDRAM")
				elseif currstage == 8 then return memory.read_s8(0x1E2839, "RDRAM")
				elseif currstage == 9 then return memory.read_s8(0x1EB3B9, "RDRAM")
				elseif currstage == 10 then return memory.read_s8(0x1E5439, "RDRAM")
				elseif currstage == 11 then return memory.read_s8(0x1E1EB9, "RDRAM")
				elseif currstage == 12 then return memory.read_s8(0x1FA6B9, "RDRAM")
				elseif currstage == 13 then return memory.read_s8(0x1EAE39, "RDRAM")
				elseif currstage == 14 then return memory.read_s8(0x1E2EB9, "RDRAM")
				elseif currstage == 15 then return memory.read_s8(0x1E2739, "RDRAM")
				elseif currstage == 16 then return memory.read_s8(0x1E53B9, "RDRAM")
				elseif currstage == 17 then return memory.read_s8(0x1E2739, "RDRAM")
				elseif currstage == 18 then return memory.read_s8(0x1E1CB9, "RDRAM")
				elseif currstage == 19 then return memory.read_s8(0x1E4439, "RDRAM")
				elseif currstage == 20 then return memory.read_s8(0x1F7239, "RDRAM")
				elseif currstage == 21 then return memory.read_s8(0x1E49B9, "RDRAM")
				elseif currstage == 22 then return memory.read_s8(0x1E40B9, "RDRAM")
				elseif currstage == 23 then return memory.read_s8(0x1E9C39, "RDRAM")
				elseif currstage == 24 then return memory.read_s8(0x1E2939, "RDRAM")
				elseif currstage == 25 then return memory.read_s8(0x1E4D39, "RDRAM")
				elseif currstage == 26 then return memory.read_s8(0x1E7FB9, "RDRAM")
				elseif currstage == 27 then return memory.read_s8(0x1E2B39, "RDRAM")
				elseif currstage == 28 then return memory.read_s8(0x1E25B9, "RDRAM")
				elseif currstage == 29 then return memory.read_s8(0x1E1EB9, "RDRAM")
				elseif currstage == 30 then return memory.read_s8(0x1E38B9, "RDRAM")
				elseif currstage == 31 then return memory.read_s8(0x1F5639, "RDRAM")
				elseif currstage == 32 then return memory.read_s8(0x1E4239, "RDRAM")
				elseif currstage == 33 then return memory.read_s8(0x1E4EB9, "RDRAM")
				elseif currstage == 34 then return memory.read_s8(0x1E16B9, "RDRAM")
				elseif currstage == 35 then return memory.read_s8(0x1FABB9, "RDRAM")
				elseif currstage == 36 then return memory.read_s8(0x1EA739, "RDRAM")
				elseif currstage == 37 then return memory.read_s8(0x1FC639, "RDRAM")
				elseif currstage == 38 then return memory.read_s8(0x1EBCB9, "RDRAM")
				elseif currstage == 39 then return memory.read_s8(0x1F50B9, "RDRAM")
				elseif currstage == 40 then return memory.read_s8(0x1E2039, "RDRAM")
				elseif currstage == 41 then return memory.read_s8(0x1F02B9, "RDRAM")
				elseif currstage == 42 then return memory.read_s8(0x1FD7B9, "RDRAM")
				elseif currstage == 43 then return memory.read_s8(0x1E97B9, "RDRAM")
				elseif currstage == 44 then return memory.read_s8(0x1E4539, "RDRAM")
				end
			return -2 end, -- failsafe, shouldn't be used
		other_swaps=function() return false end,
		grace=20,
	},
	['JurassicPark1_SNES']={ -- Jurassic Park, SNES (USA)
		func=singleplayer_withlives_swap,
		p1gethp=function() return 240 - memory.read_u8(0x0002EB, "WRAM") end, -- value stored appears to be damage, not health, so it needs to be inverted
		p1getlc=function() return memory.read_u8(0x0002A3, "WRAM") end,
		maxhp=function() return 240 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x0002A3 end,
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 4 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['JimPower_SNES']={ -- Jim Power - The Lost Dimension in 3D, SNES (USA)
		func=singleplayer_withlives_swap,
		p1gethp=function() return 0 end,
		p1getlc=function() return memory.read_u8(0x00003F, "WRAM") end,
		maxhp=function() return 0 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x00003F end,
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 9 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['Battletoads_ARC']={ -- Battletoads, arcade
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x0004AC, "tms34020 : ram : 0x0-0x3FFFFF") end,
		p1getlc=function() return memory.read_u8(0x03410A, "tms34020 : ram : 0x0-0x3FFFFF") end, -- unlimited coins are given instead of lives to encourage player switching, lives at 0004C8
		maxhp=function() return 161 end,
		minhp=-1,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x03410A end,
		LivesWhichRAM=function() return "tms34020 : ram : 0x0-0x3FFFFF" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!
		grace=40,
	},
	['MajuuOu_SNES']={ -- Majuu Ou (Japan) / King of Demons
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x00009F, "WRAM") end,
		p1getlc=function() return memory.read_u8(0x0000A3, "WRAM") end,
		maxhp=function() return 112 end,
		gmode=function() return memory.read_u8(0x000209, "WRAM") == 0 end, -- might be not equal to 20?
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x0000A3 end,
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 9 end,
		ActiveP1=function() return true end, -- p1 is always active!
		other_swaps=function()
		-- if the player has his wife (the fairy), she revives him on death, so she's expended instead of a life. goes from 0 when disabled to 19 when enabled
		local wife_changed, wife_cur, wife_prev = update_prev('wife', memory.read_u8(0x0006A7, "WRAM"))
		return (wife_changed and wife_cur == 0 and wife_prev == 19) end,
	},
	['GundamSalamander_ARC']={ -- SD Gundam Psycho Salamander no Kyoui
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x216D, "m68000 : ram : 0x80000-0x8BFFF") end,
		p1getlc=function() return memory.read_u8(0x2192, "m68000 : ram : 0x80000-0x8BFFF") end,
		maxhp=function() return 32 end,
		gmode=function() return memory.read_u8(0x5CB9, "m68000 : ram : 0x80000-0x8BFFF")==4 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x2192 end,
		LivesWhichRAM=function() return "m68000 : ram : 0x80000-0x8BFFF" end,
		maxlives=function() return 69 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['GundamRainbow_ARC']={ -- SD Gundam Sangokushi Rainbow Tairiku Senki (Japan), arcade
		func=singleplayer_withlives_swap,
		p1gethp=function() return 0 end,
		p1getlc=function() return memory.read_u8(0x000653, "m68000 : ram : 0x108000-0x11FFFF") end,
		maxhp=function() return 0 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x000653 end,
		LivesWhichRAM=function() return "m68000 : ram : 0x108000-0x11FFFF" end,
		maxlives=function() return 2 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['MetalSlug1_ARC']={ -- Metal Slug - Super Vehicle-001, arcade (US)
		func=singleplayer_withlives_swap,
		-- 0xfdb6 and 0xfdb7 are P2 and P1 states: 0x00=Inactive, 0x01=Playing, 0x02=Continue, 0x03=Game Over
		gmode=function() 
			local p1state = memory.read_s8(0x00FDB7, "m68000 : ram : 0x100000-0x10FFFF")
			local p2state = memory.read_s8(0x00FDB6, "m68000 : ram : 0x100000-0x10FFFF")
			local level   = memory.read_s8(0x000281, "m68000 : ram : 0x100000-0x10FFFF")
			return level ~= -1 and ((p1state > 0 and p1state <= 3) or (p2state > 0 and p2state <= 3))
		end,
		p1gethp=function()
			-- 0x0005E7: slug health
			local swap_on_slug_damage = false -- if you want to swap when the slug (tank) is damaged, set this to true
			if swap_on_slug_damage ~= true then return 0 end
			return memory.read_s8(0x0005E7, "m68000 : ram : 0x100000-0x10FFFF")
		end, 
		p1getlc=function() return memory.read_s8(0x000377, "m68000 : ram : 0x100000-0x10FFFF") end,
		maxhp=function() return 48 end,
		minhp=-1;
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x000377 end,
		LivesWhichRAM=function() return "m68000 : ram : 0x100000-0x10FFFF" end,
		maxlives=function() return 71 end,
		ActiveP1=function() return true end, -- p1 is always active (until p2 support added!)
	},
	['TripWorld_GB']={ -- Trip World, GB, and Trip World DX, GBC
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x20, "HRAM") end,
		p1getlc=function() return memory.read_u8(0x00E1, "WRAM") end,
		maxhp=function() return 4 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x00E1 end,
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 9 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},	
	['VsIceClimber_ARC']={ -- Vs. Ice Climber, arcade (set IC4-4 B-1)
		func=singleplayer_withlives_swap,
		p1gethp=function() return 1 end, 
		p1getlc=function() return memory.read_u8(0x0020, "rp2a03 : ram : 0x0-0x7FF") end, -- if using coins instead of lives, use address 0797 at the same domain
		maxhp=function() return 1 end, 
		gmode=function() return memory.read_u8(0x0219, "rp2a03 : ram : 0x0-0x7FF") == 251 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x0020 end,
		LivesWhichRAM=function() return "rp2a03 : ram : 0x0-0x7FF" end,
		maxlives=function() return 8 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['MathBlaster_SNES']={ -- Math Blaster - Episode 1, SNES (USA)
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_s8(0x0009A4, "WRAM") end,
		p1getlc=function() return memory.read_s8(0x0009A3, "WRAM") end,
		maxhp=function() return 8 end,
		minhp=-1,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x0009A3 end,
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 9 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['DoReMiFantasy_SNES']={ -- Do-Re-Mi Fantasy - Milon no Dokidoki Daibouken, SNES (Japan)
		func=singleplayer_withlives_swap,
		p1gethp=function() return memory.read_u8(0x000E5B, "WRAM") end,
		p1getlc=function() return memory.read_u8(0x0000F1, "WRAM") end,
		maxhp=function() return 2 end,
		minhp=-1,
		gmode=function() return memory.read_u8(0x00000A, "WRAM") == 82 end,
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x0000F1 end,
		LivesWhichRAM=function() return "WRAM" end,
		maxlives=function() return 9 end,
		ActiveP1=function() return true end, -- p1 is always active!
	},
	['Windjammers_ARC']={ -- Windjammers / Flying Power Disc
		func=function() 
			return function()
				local p2_points_changed, p2_points_curr, p2_points_prev = update_prev("p2_points", memory.read_u8(0x0008F3, "m68000 : ram : 0x100000-0x10FFFF")) -- max points == 0x15 (approximated)
				local p1_sets_changed, p1_sets_curr, p1_sets_prev = update_prev("p1_sets", memory.read_u8(0x000872, "m68000 : ram : 0x100000-0x10FFFF")) -- max sets == 2
				local p2_sets_changed, p2_sets_curr, p2_sets_prev = update_prev("p2_sets", memory.read_u8(0x0008F2, "m68000 : ram : 0x100000-0x10FFFF")) -- max sets == 2
				-- gmode, no shuffling outside of gameplay
				if memory.read_u8(0x00008A, "m68000 : ram : 0x100000-0x10FFFF")~=120 then return false end
				-- shuffle occurs when opponent gets points
				if p2_points_changed and p2_points_curr > p2_points_prev then return true, 30 end
				-- shuffle occurs when opponent wins a set
				if p2_sets_changed and p2_sets_curr > p2_sets_prev then
					-- ties count as a win for both players, so suppress shuffle for tie when player 1 also wins a set
					-- specifically: if score goes to 1-1 or 2-2 (leading to sudden death), don't swap
					-- if a tie set leads to opponent winning (this would be 2 sets to 1), then DO swap
					if p1_sets_changed and p1_sets_curr > p1_sets_prev and not (p1_sets_curr == 1 and p2_sets_curr == 2) then return false end 
					return true, 150
					end
			return false
			end
		end,
		grace=150, -- avoid double-swaps on giving up points at the end of sets
		-- infinite lives does not apply
	},
	['DickTracy_NES']={ -- Dick Tracy, NES
		func=health_swap,
		is_valid_gamestate=function() return true end,
		get_health=function() return memory.read_u8(0x0663, "RAM") end,
		other_swaps=function() 
			-- 0x002C: screen type; 10 == game over, 3 == office, 2 == safe cracking to continue
			local game_over_changed, game_over_curr = update_prev("game_over", memory.read_u8(0x002C, "RAM") == 10)
			if game_over_changed and game_over_curr == true then return true end
			return false 
		end,
		grace=90, -- you get about 16 iframes total, sometimes a couple more. It's easy to get shot repeatedly on swapping in
		-- Infinite lives: there are no lives in this game
		-- but this function can be used to refill health (Smight's preference!) or first aid kits
		-- TODO: per-game setting
		CanHaveInfiniteLives=true,
		p1livesaddr=function() return 0x0663 end, -- this is for infinite health
		-- alternatively, use 0x06B9: first aid kits
		LivesWhichRAM=function() return "RAM" end,
		maxlives=function() return 8 end,
		-- alternatively, use 2, for max first aid kits
		ActiveP1=function() return true end, -- p1 is always active!
	},
}

local backupchecks = {
}

local function get_game_tag()
	-- try to just match the rom hash first
	local tag = get_tag_from_hash_db(gameinfo.getromhash(), 'plugins/chaos-shuffler-hashes.dat')
	if tag ~= nil and gamedata[tag] ~= nil then
		return tag
	end

	-- check to see if any of the rom name samples match
	local name = gameinfo.getromname()
	for _,check in pairs(backupchecks) do
		if check.test() then
			return check.tag
		end
	end

	return nil
end

local function BT_NES_Zitz_Override()
	if tag == "BT_NES" -- unpatched Battletoads NES
		and memory.read_u8(0x000D, "RAM") == 11 -- in Clinger-Winger
		and memory.read_u8(0x0011, "RAM") ~= 255 -- Rash is alive
	then
		return true -- if all of those are true, then don't give Zitz all those lives, it'll more or less softlock you!
	end
	
	return false
end

function plugin.on_game_load(data, settings)
	prevdata = {}
	debug_timer = 0
	swap_scheduled = false
	shouldSwap = function() return false end

	prev_framecount = emu.framecount()
	
	tag = tags[gameinfo.getromhash()] or get_game_tag()
	tags[gameinfo.getromhash()] = tag or NO_MATCH
	
	---------------
	-- For Battletoads games to do level skip/select based on filename
	----

	-- Which level to patch into on game load?
	-- Grab the first two characters of the filename, turned into a number.
	local which_level_filename = string.sub((tostring(config.current_game)),1,2)
	local which_level = which_level_filename

	-- if file name starts with a number outside of the expected range, reset the level to 1
	-- TODO: recode to accommodate different min and max levels (Battletoads SNES requires 00-08)
	-- consider moving function elsewhere if needed

	if type(tonumber(which_level)) == "number" then
		which_level = tonumber(which_level)
		-- BT_NES
		if tag == "BT_NES" or tag == "BT_NES_patched" then
			if which_level >13 or which_level <1 or which_level == nil then
				which_level = 1
			end
		end
		-- BT_SNES
		if tag == "BT_SNES" then
			if which_level >8 or which_level <1 then
				which_level = 1
			end
		end
		-- BTDD (both)
		if tag == "BTDD_NES"
			or tag == "BTDD_SNES"
			or tag == "BTDD_SNES_patched"
		then
			if which_level >14 or which_level <1 then
				which_level = 1
			end
		end
	else
		which_level = 1
	end

	-- ONLY APPLY THESE TO RECOGNIZED GAMES
	-- ONLY APPLY THESE TO RECOGNIZED GAMES
	-- ONLY APPLY THESE TO RECOGNIZED GAMES
	
	-- TODO: set min and max level variable by game
	
	-- BATTLETOADS NES
	if tag == "BT_NES" or tag == "BT_NES_patched" then
		-- enable Infinite* Lives for Rash (p1) if checked
		if settings.InfiniteLives == true -- is Infinite* Lives enabled?
			and memory.read_u8(0x0011, "RAM") > 0 and memory.read_u8(0x0011, "RAM") < 255 -- is Rash on?
		then
			memory.write_u8(0x0011, 69, "RAM") -- if so, set lives to 69. Nice.
		end
	
		-- enable Infinite* Lives for Zitz (p2) if checked
		-- DOES NOT APPLY IF LEVEL = 11 AND ROM IS UNPATCHED
		if settings.InfiniteLives == true -- is Infinite* Lives enabled?
			and memory.read_u8(0x0012, "RAM") > 0 and memory.read_u8(0x0012, "RAM") < 255 -- is Zitz on?
		then
			if
				BT_NES_Zitz_Override() == false -- are we outside of the 2P/unpatched/on level 11 scenario?
			then -- if so, set lives to 69. Nice.
				memory.write_u8(0x0012, 127, "RAM")	
			elseif memory.read_u8(0x000D, "RAM") == 11 then
				memory.write_u8(0x0012, 0, "RAM") -- Otherwise, get Zitz to 0 lives immediately if you arrived at Clinger-Winger
			end
		end
	end
	
	if tag == "BT_NES" or tag == "BT_NES_patched" then
		-- if game was just loaded, these two addresses will = 255
		-- after starting or continuing, they get set to 40 or 0, respectively, and stay that way
		-- we now set these on game load, to let the player press start without sitting through the intro every time
		if memory.read_u8(0x00FD, "RAM") == 255 then
			memory.write_u8(0x00FD, 40, "RAM")
		end
		if memory.read_u8(0x00FE, "RAM") == 255 then
			memory.write_u8(0x00FE, 0, "RAM")
		end
	end
	
	-- Battletoads in Battlemaniacs (SNES)
	if tag == "BT_SNES" then
		-- enable Infinite* Lives for P1 (Pimple) if checked
		if settings.InfiniteLives == true -- is Infinite* Lives enabled?
			and memory.read_u8(0x000028, "WRAM") > 0 and memory.read_u8(0x000028, "WRAM") < 255 -- have we started playing?
		then
			memory.write_u8(0x000028, 69, "WRAM") -- if so, set lives to 69. Nice.
		end
		-- enable Infinite* Lives for P2 (Rash) if checked
		if settings.InfiniteLives == true -- is Infinite* Lives enabled?
			and memory.read_u8(0x00002A, "WRAM") > 0 and memory.read_u8(0x00002A, "WRAM") < 255 -- have we started playing?
		then
			memory.write_u8(0x00002A, 69, "WRAM") -- if so, set lives to 69. Nice.
		end
	end
	
	-- Little Samson (NES)
	-- goal: if you lose an ally, detect that and resurrect them on swapping in
	if tag == "LittleSamson_NES" then
		local LittleSamson_NES_ReviveAllies = true -- turn this to false if you don't want this upgrade to Infinite Lives
		if settings.InfiniteLives == true -- is Infinite Lives enabled?
			and LittleSamson_NES_ReviveAllies == true
		-- check if level is high enough to have all the teammates (not 0 through 3) and if "all teammates selectable" is set
			and memory.read_u8(0x003F, "RAM") > 3 and memory.read_u8(0x0090, "RAM") % 16 == 0xF
		then
		-- if ally has 0 health, they died; set ally's hp to their own max hp to revive them
			if memory.read_u8(0x0098, "RAM") == 0 -- D
			then memory.write_u8(0x0098, memory.read_u8(0x0094, "RAM"), "RAM")
			end 
			if memory.read_u8(0x0099, "RAM") == 0 -- G
			then memory.write_u8(0x0099, memory.read_u8(0x0095, "RAM"), "RAM")
			end 
			if memory.read_u8(0x009A, "RAM") == 0 -- M
			then memory.write_u8(0x009A, memory.read_u8(0x0096, "RAM"), "RAM")
			end 
		end
	end
	
	-- Teenage Mutant Ninja Turtles (NES)
	-- goal: if you lose an ally, detect that and resurrect them on swapping in
	if tag == "TMNT_NES" then
		local TMNT_NES_ReviveAllies = true -- turn this to false if you don't want this upgrade to Infinite Lives
		if settings.InfiniteLives == true -- is Infinite Lives enabled?
			and TMNT_NES_ReviveAllies == true
		then
		-- if ally has 0 health, they died; set their hp to max to revive them
			if memory.read_u8(0x0077, "RAM") == 0 -- Leo
			then memory.write_u8(0x0077, 128, "RAM")
			end 
			if memory.read_u8(0x0078, "RAM") == 0 -- Raph
			then memory.write_u8(0x0078, 128, "RAM")
			end 
			if memory.read_u8(0x0079, "RAM") == 0 -- Mike
			then memory.write_u8(0x0079, 128, "RAM")
			end 
			if memory.read_u8(0x007A, "RAM") == 0 -- Don
			then memory.write_u8(0x007A, 128, "RAM")
			end 
		end
	end
	

	-- first time through with a bad match, tag will be nil
	-- can use this to print a debug message only the first time
	
	if tag ~= nil and tag ~= NO_MATCH then
		gamemeta = gamedata[tag]
		local func = gamemeta.func
		shouldSwap = func(gamemeta)
		
		-- Infinite* Lives - set lives to max on game load
		local CanHaveInfiniteLives = gamemeta.CanHaveInfiniteLives
		
		if settings.InfiniteLives == true -- is infinite lives enabled?
			and CanHaveInfiniteLives == true -- can this game can do infinite lives?
		then
			-- returns the number of games left in the shuffler
			-- this will be key for how infinite lives are handled at the end!
			gamesleft = #(get_games_list())

			local ActiveP1 = false
			if gamemeta.ActiveP1 then
				ActiveP1 = gamemeta.ActiveP1()
			end
			local ActiveP2 = false
			if gamemeta.ActiveP2 then
				ActiveP2 = gamemeta.ActiveP2()
			end
			local p1livesaddr = nil
			if gamemeta.p1livesaddr then
				p1livesaddr = gamemeta.p1livesaddr()
			end
			local p2livesaddr = nil
			if gamemeta.p2livesaddr then
				p2livesaddr = gamemeta.p2livesaddr()
			end
			local maxlives = nil
			if gamemeta.maxlives then
				maxlives = gamemeta.maxlives()
			end
			local LivesWhichRAM = nil
			if gamemeta.LivesWhichRAM then
				LivesWhichRAM = gamemeta.LivesWhichRAM()
			end
			
			-- enable Infinite* Lives for p1 if checked and able
			if ActiveP1 == true -- is p1 on?
				and p1livesaddr ~= nil -- is an address specified for p1?
			then -- if so, set lives to max specified
				if LivesWhichRAM ~= nil then
					memory.writebyte(p1livesaddr, maxlives, LivesWhichRAM)
				end
			end
			
			-- enable Infinite* Lives for p2 if checked and able
			if ActiveP2 == true -- is p1 on?
				and p2livesaddr ~= nil -- is an address specified for p1?
			then -- if so, set lives to max specified
				if LivesWhichRAM ~= nil then
					memory.writebyte(p2livesaddr, maxlives, LivesWhichRAM)
				end
			end
		end
	else
		gamemeta = nil
	end

	-- log stuff
	if tag == "BT_NES" or tag == "BT_NES_patched" then
		if tonumber(which_level_filename) == nil or which_level ~= tonumber(which_level_filename) then
			if settings.SuppressLog ~= true and (which_level > 13 or which_level == 1) then
				log_console(string.format('Battletoads (NES) - no level specified (' .. string.format(tag) .. ')'))
			end
		else
			log_console('Battletoads (NES) Level ' .. tostring(which_level) .. ': ' ..  bt_nes_level_names[which_level])
		end
	elseif tag == "BTDD_NES" or tag == "BTDD_SNES" or tag == "BTDD_SNES_patched" then
		if tonumber(which_level_filename) == nil or which_level ~= tonumber(which_level_filename) then
			if settings.SuppressLog ~= true and (which_level > 14 or which_level == 1) then
				log_console(string.format('Battletoads Double Dragon - no level specified (' .. string.format(tag) .. ')'))
			end
		else
			log_console('Battletoads Double Dragon Level ' .. btdd_level_names[which_level])
		end
	elseif tag == "BT_SNES" then
		if tonumber(bt_snes_level_recoder[tonumber(which_level_filename)]) == nil then
			if tonumber(which_level_filename) == nil or tonumber(which_level_filename) > 8 then 
				log_console(string.format('Battletoads in Battlemaniacs - no level specified (' .. string.format(tag) .. ')'))
			end
		else
			log_console('Battletoads in Battlemaniacs Level ' .. tostring(which_level) .. ': ' ..  bt_snes_level_names[which_level] .. ' (' .. tag .. ')')
		end
	elseif tag ~= nil then 
		log_console('Chaos Shuffler: recognized as ' .. string.format(tag))
	elseif tag == nil or tag == NO_MATCH then
		if settings.SuppressLog ~= true then
			log_console(string.format('Chaos Shuffler: unrecognized - do you have chaos-shuffler-hashes.dat? %s (%s)',
			gameinfo.getromname(), gameinfo.getromhash())) end
	end
end

function plugin.on_frame(data, settings)
	-- Detect resets, savestate load or rewind (or turbo if "Run lua scripts when turboing" is disabled)
	local inputs = joypad.get()
	local new_framecount = emu.framecount()
	if inputs.Reset or inputs.Power or new_framecount ~= prev_framecount + 1 then
		prevdata = {} -- reset prevdata to avoid swaps
	end
	prev_framecount = new_framecount

	-- Which level to patch into on game load?
	-- Grab the first two characters of the filename, turned into a number.
	local which_level_filename = string.sub((tostring(config.current_game)),1,2)
	local which_level = tonumber(which_level_filename)

if type(tonumber(which_level)) == "number" then 
	which_level = tonumber(which_level)
	--BT_NES
		if tag == "BT_NES" or tag == "BT_NES_patched" then 
		if which_level >13 or which_level <1 or which_level == nil then which_level = 1 end
		end
	--BT_SNES
		if tag == "BT_SNES" then 
		if which_level >8 or which_level <1 then which_level = 1 end
		end
	--BTDD (both)
		if tag == "BTDD_NES" or tag == "BTDD_SNES" or tag == "BTDD_SNES_patched" then 
		if which_level >14 or which_level <1 then which_level = 1 end
		end
	else 
	which_level = 1
	end
	-- TODO: CAN WE MAKE THIS A FUNCTION AND CALL IT WHEN WE NEED IT
	
	-- avoiding super short swaps (<10) as a precaution
	local grace = math.max(gamemeta and gamemeta.grace or 0, settings.grace, 10)
	
	if settings.DebugSingleGame and swap_scheduled then
		debug_timer = debug_timer + 1
		-- rearm the shuffler even though no on_load happened to reset things
		if debug_timer > grace then
			prevdata = {}
			debug_timer = 0
			swap_scheduled = false
		end
	end
	
	-- run the check method for each individual game
	
	if not swap_scheduled then
	
		-- PROCESS "DON'T SWAP" SETTINGS HERE
		-- A function like this should be generalizable for other games in the future to make exceptions 
		-- so that users can turn off specific swap conditions
		-- laid out by a DisableExtraSwaps function
		
		-- Yoshi's Island (SNES)
		if tag == "SMW2YI_SNES" and settings.SMW2YI_MiniBonusSwaps ~= true then
		-- can add "or this game+setting, that game+setting, etc." in the future
			if gamemeta.DisableExtraSwaps() == true then 
				return 
				-- don't swap
			end
		end
		
		-- Ice Climber (NES)
		if tag == "IceClimber_NES" and settings.IceClimberBonusSwaps ~= true then
		-- can add "or this game+setting, that game+setting, etc." in the future
			if gamemeta.DisableExtraSwaps() == true then 
				return 
				-- don't swap
			end
		end
		
		-- AND NOW WE SWAP
		local schedule_swap, delay = shouldSwap(prevdata)
		if schedule_swap and frames_since_restart > grace then
			delay = delay or 3
			debug_timer = -delay
			swap_game_delay(delay)
			swap_scheduled = true
			if not settings.SuppressLog or settings.DebugSingleGame then
				log_console('Chaos Shuffler: swap scheduled for %s (frame: %d, delay: %d)', tag, frames_since_restart, delay)
			end
			if PAUSE_ON_SWAP then client.pause() end
		end
	end
	
	if gamemeta then
		-- Infinite* Lives ON FRAME - set lives to max on frame when we are either on the last game or in a game that requires it
		local MustDoInfiniteLivesOnFrame = false
		if gamemeta.MustDoInfiniteLivesOnFrame then MustDoInfiniteLivesOnFrame = gamemeta.MustDoInfiniteLivesOnFrame() end
		
		if settings.InfiniteLives == true -- is infinite lives enabled?
			and gamemeta.CanHaveInfiniteLives == true -- can this game can do infinite lives?
			and
				(MustDoInfiniteLivesOnFrame == true -- can this game can do infinite lives only on frame?
				or gamesleft == 1) -- are we in the last game left in the shuffler?
		then
			local ActiveP1 = false
			if gamemeta.ActiveP1 then
				ActiveP1 = gamemeta.ActiveP1()
			end
			local ActiveP2 = false
			if gamemeta.ActiveP2 then
				ActiveP2 = gamemeta.ActiveP2()
			end
			local p1livesaddr = nil
			if gamemeta.p1livesaddr then
				p1livesaddr = gamemeta.p1livesaddr()
			end
			local p2livesaddr = nil
			if gamemeta.p2livesaddr then
				p2livesaddr = gamemeta.p2livesaddr()
			end
			local maxlives = nil
			if gamemeta.maxlives then
				maxlives = gamemeta.maxlives()
			end
			local LivesWhichRAM = nil
			if gamemeta.LivesWhichRAM then
				LivesWhichRAM = gamemeta.LivesWhichRAM()
			end
		
			-- enable Infinite* Lives for p1 if checked and able
			if ActiveP1 == true -- is p1 on?
				and p1livesaddr ~= nil -- is an address specified for p1?
			then -- if so, let's figure out whether to set lives to max specified
				if LivesWhichRAM ~= nil then
					if memory.readbyte(p1livesaddr, LivesWhichRAM) < maxlives
						and not
						(memory.readbyte(p1livesaddr, LivesWhichRAM) ~= (maxlives - 1) and swap_scheduled == true)
						-- let 1 frame with lives < maxlives slip through so we swap on deaths
					then
						memory.writebyte(p1livesaddr, maxlives, LivesWhichRAM)
					end
				end
			end
	
			-- enable Infinite* Lives for p2 if checked and able
			if ActiveP2 == true -- is p1 on?
				and p2livesaddr ~= nil -- is an address specified for p1?
			then -- if so, let's figure out whether to set lives to max specified
				if LivesWhichRAM ~= nil then
					if memory.readbyte(p2livesaddr, LivesWhichRAM) < maxlives
						and not memory.readbyte(p2livesaddr, LivesWhichRAM) ~= (maxlives - 1)
						-- let 1 frame with lives < maxlives slip through so we swap on deaths
					then
						memory.writebyte(p2livesaddr, maxlives, LivesWhichRAM)
					end
				end
			end
		end

		-- Battletoads NES
		
		-- CLINGER-WINGER SPEED
		-- This enables the Game Genie code for always moving at max speed in Clinger Winger.
		-- The bugfix makes this not work! This will only work on an unpatched ROM. The proper, non-patched tag handles this.
		if tag == "BT_NES" then
			if settings.ClingerSpeed == true and memory.read_u8(0x000D, "RAM") == 11 and memory.read_u8(0xA706, "System Bus") == 5 then
				memory.write_u8(0xA706, 0, "System Bus")
			end
		end
		
		-- Set the memory value that represents the starting stage to the number specified by the file name.
		if tag == "BT_NES" or tag == "BT_NES_patched" then
			if which_level ~= nil and memory.read_u8(0x8320, "System Bus") ~= which_level then
				-- double check that less than/equal to gets desired effect
				memory.write_u8(0x8320, which_level, "System Bus")
			end
		end
		
		-- Battletoads Double Dragon NES
		
		-- Set the memory value that represents the starting stage to the number specified by the file name.
		if tag == "BTDD_NES" then
			if which_level ~= nil -- just started the game!
			then
				if memory.read_u8(0x0017, "RAM") == 0 then
					gui.drawText(0, 0, "Level select enabled, select " .. btdd_level_names[which_level] .. "!")
					-- give the level instruction
				end
				memory.write_u8(0x0017, 10, "RAM") -- then set Level Cheat Code to ON
			end
		end
		
		--Battletoads Double Dragon SNES
		
		if tag == "BTDD_SNES_patched" then
			if memory.read_u8(0x00002C, "WRAM") == 80 -- just started the game!
				and which_level ~= nil 
			then
				gui.drawText(0, 0, "Pick " .. btdd_level_names[which_level] .. "!")
			end
		end

		if tag == "BTDD_SNES" then
			if memory.read_u8(0x00002C, "WRAM") == 80 -- just started the game!
				and which_level ~= nil
			then 
				gui.drawText(0, 0, "Up Down Down Up X B Y A on char select (flash = ON)")
				gui.drawText(0, 20, "Pick " .. btdd_level_names[which_level] .. "!")
			end
		end
		
		--Battletoads in Battlemaniacs (SNES)
		
		-- Setting the level variable only works on a continue. Stupid but true! You'll just enter a glitched first level otherwise.
		-- So, time for Pimple to die ASAP if you chose a level other than the first one.
		
		if tag == "BT_SNES" then
			-- if current level < which_level, then
			-- set lives to 0
			-- set health to (if >1, 1, else don't touch)
			-- once a continue is used, set level to which_level
			
			-- set the value for level properly
			local BT_SNES_level_for_memory = bt_snes_level_recoder[which_level]
			
			if (which_level ~= nil and which_level > 1) or settings.BTSNESRash == true then
				-- if level specified and not the first level, or we want to play as Rash
				if memory.read_u8(0x00002C, "WRAM") == 0 then
					-- we are on the first level
					if memory.read_u8(0x000E5E, "WRAM") > 16 then
						gui.drawText(0, 0, "Take a death and continue to go to " .. bt_snes_level_names[which_level] .. "!")
						-- write message only when Pimple hasn't yet game-overed, so there is a garbage number for health
					end
					if memory.read_u8(0x00002E, "WRAM") == 1 then
						-- Pimple just lost a continue
						memory.write_u8(0x00002C, BT_SNES_level_for_memory, "WRAM")
						-- overwrite level, and you're good to go.
						memory.write_u8(0x00002E, 3, "WRAM")
						-- bump the continue count above 2 to avoid an extra swap
					elseif memory.read_u8(0x00002E, "WRAM") == 2 then
						-- otherwise, if we just started the game and did specify a different level in the filename,
						memory.write_u8(0x000028, 0, "WRAM")
						-- set Pimple's lives to 0
						if memory.read_u8(0x000E5E, "WRAM") > 1 then
							memory.write_u8(0x000E5E, 0, "WRAM")
							-- set Pimple's health to 0
							swap_scheduled = false
							-- override the swap being scheduled for a health drop
						end
					end
				end
				
				if memory.read_u8(0x00002C, "WRAM") > 0
					and memory.read_u8(0x00002C, "WRAM") == BT_SNES_level_for_memory
					and memory.read_u8(0x00002E, "WRAM") > 2
				then
					memory.write_u8(0x00002E, 2, "WRAM")
					-- fix Pimple's continue count once you get into the correct level.
				end
			end
		end
		
		if tag == "MPAINT_DPAD_SNES" and memory.read_u8(0x000206) == 1 then
			-- give the player some Gnat Attack instructions!
			gui.drawText(0,0,"GNAT ATTACK! Dpad moves, face buttons click, hold one/both of L/R to go fast", "green")
		end
	end
end

-- #TO_OVERRIDE_INFINITE_LIVES
-- Typically, if a game can give you infinite lives, CanHaveInfiniteLives will be set to true.
-- You can override this for as many individual games as you want.
-- To turn off infinite lives in a game, use its tag here (in this example, Ninja Gaiden 1) like so, but without the double hyphens that comment these out:

-- gamedata['NinjaGaiden1_NES'].CanHaveInfiniteLives = false

-- Some games can handle infinite lives but will have them turned off by default, for balance/difficulty purposes.
-- Example: Wild Guns (SNES)
-- To override this, write a line like so, without the double hyphens:

-- gamedata['WildGuns_SNES'].CanHaveInfiniteLives = true

-- You can simply un-comment the above line (remove the double hyphens) for Wild Guns specifically.
-- Note that, if a game is not programmed to give infinite lives, setting its CanHaveInfiniteLives to true here won't do anything.

-- FINAL NOTE: BEFORE UPDATING YOUR PLUGIN, COPY-PASTE THE LINES YOU ADD HERE TO SOMEWHERE SAFE, SO YOU CAN RE-ADD THEM
-- this concludes #TO_OVERRIDE_INFINITE_LIVES

return plugin