--[[

********************************************************************************
*                         Wondrous Tails: Version x1.5.7                       *
********************************************************************************

This script is an updated fork of the lua script Wondrous Tails by pot0to.
It is recommended to check the original script for updates that may make this 
fork version obsolete:
https://github.com/pot0to/pot0to-SND-Scripts/blob/main/Weeklies/WondrousTails.lua

 - Is it safe to use the script?
 - Nothing safe when you use automation. It has risk.

********************************************************************************
*                             Wondrous Tails Doer                              *
*                                Version 0.2.2                                 *
********************************************************************************
Git Original Author: https://github.com/pot0to
Git Original Repo: https://github.com/pot0to/pot0to-SND-Scripts
Git Original Script: https://github.com/pot0to/pot0to-SND-Scripts/blob/main/Weeklies/WondrousTails.lua
Git Original Comparison: https://github.com/pot0to/pot0to-SND-Scripts/compare/0cf4146..main?diff=unified

Created by: pot0to (https://ko-fi.com/pot0to)
Description: Picks up a Wondrous Tails journal from Khloe, then attempts each duty.

For dungeons:
- Attempts dungeon Unsynced if duty is at least 20 levels below you
- Attempts dungeon with Duty Support if duty is within 20 levels of you and Duty
Support is available

For EX Trials:
- Attempts any duty unsynced if it is 20 levels below you and skips any that are
within 20 levels
- Note: Not all EX trials have BossMod support, but this script will attempt
each one once anyways
- Some EX trials are blacklisted due to mechanics that cannot be done solo
(Byakko tank buster, Tsukuyomi meteors, etc.)

Alliance Raids/PVP/Treasure Maps/Palace of the Dead
- Skips them all

The script will also help you turn in journal when 9 are completed this week.

********************************************************************************
*                               Required Plugins                               *
********************************************************************************

Plugins that are needed for it to work:

    -> Something Need Doing [Expanded Edition]: Main Plugin for everything to work
        Repo: https://puni.sh/api/repository/croizat
        Git: https://github.com/Jaksuhn/SomethingNeedDoing
    -> VNavmesh: For Pathing/Moving
        Tip: It's better to use a Chinese fork than an outdated original: https://github.com/awgil/ffxiv_navmesh/compare/master...AtmoOmen:ffxiv_navmesh-cn:master#files_bucket
        Repo: https://raw.githubusercontent.com/AtmoOmen/DalamudPlugins/main/pluginmaster.json
        Git: https://github.com/AtmoOmen/ffxiv_navmesh-cn
    -> Better Mount Roulette: Allows for a more granular approach to selecting the mounts you want included in your mount roulette
        Main Repo Dalamud: https://kamori.goats.dev/Plugin/PluginMaster
        Git: https://github.com/CMDRNuffin/BetterMountRoulette
    -> Lifestream: For inn/home/fc/apt/island and Teleporting to Idyllshire if you're not already in that zone
        Repo: https://github.com/NightmareXIV/MyDalamudPlugins/raw/main/pluginmaster.json
        Git: https://github.com/NightmareXIV/Lifestream
    -> AutoDuty: For auto duty
        Repo: https://puni.sh/api/repository/herc
        Git: https://github.com/ffxivcode/AutoDuty
    -> Deliveroo: For auto GC turnin
        Repo: https://plugins.carvel.li
        Git: https://git.carvel.li/liza/Deliveroo
    -> Daily Routines:
        Repo: https://raw.githubusercontent.com/AtmoOmen/DalamudPlugins/main/pluginmaster.json
        Git: https://github.com/Dalamud-DailyRoutines

Replacing the functionality of the Daily Routines plugin with other plugins:

    -> UI Anti Afk Kick: For preventing being auto-kicked from FFXIV due to inactivity
        Repo: https://raw.githubusercontent.com/KangasZ/DalamudPluginRepository/main/plugin_repository.json
        Git: https://github.com/KangasZ/UIAntiAfkKick

********************************************************************************
*                               Configuration                                  *
********************************************************************************
]]

local SelectedJobForFarm = "Warrior"  -- Job from ClassList; -- set it to "" if you don't want to use it

local RepairThreshold = 99    -- the threshold it needs to drop before Repairing (set it to 0 if you don't want it to repair)

local GC_Turnin_Free_Slots = 0 -- the amount of free inventory slots when needed to Turnin in GC the end of script (set it to 0 if you don't want it to Turnin GC)

local chat_command_between_loops = "/ad goto Barracks" -- set it to "" if you don't want to use it
    -- Better to use /ad commands, as movement using Lifestream is poorly implemented and can get stuck with low fps:
    -- /ad goto Barracks - go to barracks
    -- /ad goto Inn - go to inn
    -- /ad goto Apartment - go to apartment
    -- /ad goto PersonalHome - go to personal home
    -- /ad goto FCEstate - go to free company estate

    -- /li inn|hinn - go to inn or home world inn
    -- /li home|house|private - go to your private estate
    -- /li fc|free|company|free company - go to your free company estate
    -- /li apartment|apt - go to your apartment
    -- /li island - go to island sanctuary

local ClassList =
{
    --["Custom your gear set Name"] = { classId = id_of_the_job, },

    -- Tank Jobs                             Classes
    ["Paladin"]     = { classId = 19 },     ["Gladiator"]   = { classId = 1 },
    ["Warrior"]     = { classId = 21 },     ["Marauder"]    = { classId = 3 },
    ["Dark Knight"] = { classId = 32 },
    ["Gunbreaker"]  = { classId = 37 },

    -- Healer Jobs                           Classes
    ["White Mage"]  = { classId = 24 },     ["Conjurer"]    = { classId = 6 },
    ["Scholar"]     = { classId = 28 },
    ["Astrologian"] = { classId = 33 },
    ["Sage"]        = { classId = 40 },

    -- Melee DPS Jobs                        Classes
    ["Monk"]        = { classId = 20 },     ["Pugilist"]    = { classId = 2 },
    ["Dragoon"]     = { classId = 22 },     ["Lancer"]      = { classId = 4 },
    ["Ninja"]       = { classId = 30 },     ["Rogue"]       = { classId = 29 },
    ["Samurai"]     = { classId = 34 },
    ["Reaper"]      = { classId = 39 },
    ["Viper"]       = { classId = 41 },

    -- Ranged Physical DPS Jobs              Classes
    ["Bard"]        = { classId = 23 },     ["Archer"]      = { classId = 5 },
    ["Machinist"]   = { classId = 31 },
    ["Dancer"]      = { classId = 38 },

    -- Ranged Magical DPS Jobs               Classes
    ["Black Mage"]  = { classId = 25 },     ["Thaumaturge"] = { classId = 7 },
    ["Summoner"]    = { classId = 27 },     ["Arcanist"]    = { classId = 26 },
    ["Red Mage"]    = { classId = 35 },
    ["Pictomancer"] = { classId = 42 },
    ["Blue Mage"]   = { classId = 36 },
}

local PluginCommands = {
    NotUse = true,
    RotationSolver = {
        NotUse = true,
        enable = "/rotation auto",
        disable = "/rotation off"
    },
    WrathCombo = {
        NotUse = false,
        enable = "/wrath auto on",
        disable = "/wrath auto off"
    },
    BossMod = {
        NotUse = true,
        set_preset_without_rotation = "/vbm ar set AutoDuty",
        set_preset_with_rotation = "/vbm ar set AutoDuty Passive"
    },
    BossModReborn = {
        NotUse = false,
        set_preset_without_rotation = "/bmr ar set AutoDuty",
        set_preset_with_rotation = "/bmr ar set AutoDuty Passive"
    }
}

--[[
********************************************************************************
*                        Global Constants & Services                           *
********************************************************************************
]]

local ConditionFlag = {
    None = 0,
    NormalConditions = 1,
    Unconscious = 2,
    Emoting = 3,
    Mounted = 4,
    Crafting = 5,
    Gathering = 6,
    MeldingMateria = 7,
    OperatingSiegeMachine = 8,
    CarryingObject = 9,
    Mounted2 = 10,
    InThatPosition = 11,
    ChocoboRacing = 12,
    PlayingMiniGame = 13,
    PlayingLordOfVerminion = 14,
    ParticipatingInCustomMatch = 15,
    Performing = 16,
    -- Unknown17 = 17,
    -- Unknown18 = 18,
    -- Unknown19 = 19,
    -- Unknown20 = 20,
    -- Unknown21 = 21,
    -- Unknown22 = 22,
    -- Unknown23 = 23,
    -- Unknown24 = 24,
    Occupied = 25,
    InCombat = 26,
    Casting = 27,
    SufferingStatusAffliction = 28,
    SufferingStatusAffliction2 = 29,
    Occupied30 = 30,
    OccupiedInEvent = 31,
    OccupiedInQuestEvent = 32,
    Occupied33 = 33,
    BoundByDuty = 34,
    OccupiedInCutSceneEvent = 35,
    InDuelingArea = 36,
    TradeOpen = 37,
    Occupied38 = 38,
    Occupied39 = 39, -- Observed during Materialize (Desynthesis, Materia Extraction, Aetherial Reduction) and Repair.
    ExecutingCraftingAction = 40,
    PreparingToCraft = 41,
    ExecutingGatheringAction = 42,
    Fishing = 43,
    -- Unknown44 = 44,
    BetweenAreas = 45,
    Stealthed = 46,
    -- Unknown47 = 47,
    Jumping = 48,
    AutorunActive = 49, -- UsingChocoboTaxi
    OccupiedSummoningBell = 50,
    BetweenAreas51 = 51,
    SystemError = 52,
    LoggingOut = 53,
    ConditionLocation = 54,
    WaitingForDuty = 55,
    BoundByDuty56 = 56,
    MountOrOrnamentTransition = 57,
    WatchingCutscene = 58,
    WaitingForDutyFinder = 59,
    CreatingCharacter = 60,
    Jumping61 = 61,
    PvPDisplayActive = 62,
    SufferingStatusAffliction63 = 63,
    Mounting = 64,
    CarryingItem = 65,
    UsingPartyFinder = 66,
    UsingHousingFunctions = 67,
    Transformed = 68,
    OnFreeTrial = 69,
    BeingMoved = 70,
    Mounting71 = 71, -- Observed in Cosmic Exploration while using the actions Astrodrill (only briefly) and Solar Flarethrower.
    SufferingStatusAffliction72 = 72,
    SufferingStatusAffliction73 = 73,
    RegisteringForRaceOrMatch = 74,
    WaitingForRaceOrMatch = 75,
    WaitingForTripleTriadMatch = 76,
    InFlight = 77,
    WatchingCutscene78 = 78,
    InDeepDungeon = 79,
    Swimming = 80,
    Diving = 81,
    RegisteringForTripleTriadMatch = 82,
    WaitingForTripleTriadMatch83 = 83,
    ParticipatingInCrossWorldPartyOrAlliance = 84,
    Unknown85 = 85, -- Observed in Cosmic Exploration while gathering during a stellar mission.
    DutyRecorderPlayback = 86,
    Casting87 = 87,
    InThisState88 = 88,
    InThisState89 = 89,
    RolePlaying = 90,
    InDutyQueue = 91,
    ReadyingVisitOtherWorld = 92,
    WaitingToVisitOtherWorld = 93,
    UsingFashionAccessory = 94,
    BoundByDuty95 = 95,
    Unknown96 = 96, -- Observed in Cosmic Exploration while participating in MechaEvent.
    Disguised = 97,
    RecruitingWorldOnly = 98,
    Unknown99 = 99, -- Command unavailable in this location.
    EditingPortrait = 100,
    Unknown101 = 101, -- Observed in Cosmic Exploration, in mech flying to FATE or during Cosmoliner use. Maybe ClientPath related.
    PilotingMech = 102,
    -- Unknown103 = 103,
}

local Svc = {}

Svc.ClientState = {
    LocalPlayer = {
        Get = function()
            if not ClientState then return nil end
            return ClientState.LocalPlayer
        end,
        
        Name = function()
            if not ClientState or not ClientState.LocalPlayer then return nil end
            return ClientState.LocalPlayer.Name
        end,
    },

    IsLoggedIn = function()
        if not ClientState then return nil end
        return ClientState.IsLoggedIn
    end,
}

Svc.Objects = {
    ObjectHelper = {
        GetObjectByDataId = function(dataId)
            if not Objects then return nil end
            for i = 0, Objects.Length - 1 do
                local obj = Objects[i]
                if obj and obj.DataId == dataId then
                    return obj
                end
            end
            return nil
        end,
    },

    Object = {
        IsTargetable = function(obj)
            if not obj then return nil end
            return obj.IsTargetable
        end,
    },
}

Svc.DutyState = {
    IsDutyStarted = function()
        if not DutyState then return nil end
        return DutyState.IsDutyStarted
    end,
}

--[[
********************************************************************************
*                               Utility Functions                              *
********************************************************************************
]]

local function ZoneLoad(skipChecks)
    local conditions = {
        {id = "null",   fn = function() return not Svc.ClientState.LocalPlayer.Get() or not Svc.ClientState.LocalPlayer.Name() end, msg = "Waiting for local player to be available..."},
        {id = "li",     fn = function() return LifestreamIsBusy() end, msg = "Waiting for lifestream to be ended..."},
        {id = "cast",   fn = function() return Condition[ConditionFlag.Casting] end, msg = "Waiting for player to finish casting..."},
        {id = "zone",   fn = function() return Condition[ConditionFlag.BetweenAreas] or Condition[ConditionFlag.BetweenAreas51] end, msg = "Waiting for zone load..."},
        {id = "player", fn = function() return not IsPlayerAvailable() or IsPlayerOccupied() end, msg = "Waiting for player to be available..."},
        {id = "vnav",   fn = function() return not NavIsReady() end, msg = "Waiting for navmesh to be ready..."}
    }
    for i = 1, #conditions do if not ((skipChecks or {})[1] and ("," .. table.concat(skipChecks or {}, ",") .. ","):find("," .. conditions[i].id .. ",")) and conditions[i].fn() then 
        repeat while conditions[i].fn() do LogInfo("[WondrousTails] " .. conditions[i].msg) yield("/wait 1") end yield("/wait 1") until not conditions[i].fn() i = 0 end end
end

local movementStartTime = 0
local isCurrentlyMoving = false
local MOVEMENT_DURATION_THRESHOLD = math.random() * (1.5 - 1.15) + 1.15
local function AutoSprint()
    if not IsMoving() or not IsPlayerAvailable() 
        or Condition[ConditionFlag.Casting] or Condition[ConditionFlag.MountOrOrnamentTransition] 
        or Condition[ConditionFlag.Mounted] or Condition[ConditionFlag.InFlight] then isCurrentlyMoving = false
    elseif not isCurrentlyMoving then movementStartTime = os.clock() isCurrentlyMoving = true
    elseif not HasStatusId(50) and math.floor(GetSpellCooldown(3)) == 0 and os.clock() - movementStartTime >= MOVEMENT_DURATION_THRESHOLD then
        yield(string.format("/wait %.4f", math.random() * (0.75 - 0.15) + 0.15)) ExecuteAction(3)
    elseif HasStatusId(50) or not math.floor(GetSpellCooldown(3)) == 0 then isCurrentlyMoving = false end
end

local lastPosition = { x = 0, y = 0, z = 0 }
local lastCheckTime = 0
local STUCK_CHECK_INTERVAL = 3.0
local NORMAL_CHECK_INTERVAL = 15.0 -- 1.0 -- 0.7 -- 0.5 -- 0.2
local MIN_MOVEMENT_DISTANCE = 1.5 -- 2.0
local consecutiveStuckCount = 0
local MAX_CONSECUTIVE_STUCKS = 3
local function AntiStuckCheck()
    if GetCharacterName() == "null" or not IsPlayerAvailable() then return end
    -- if not (PathfindInProgress() or PathIsRunning()) then
    if GetCharacterCondition(26) or GetCharacterCondition(35) then
        consecutiveStuckCount = 0
        return
    end

    local currentTime = os.clock()
    local checkInterval = consecutiveStuckCount > 0 and STUCK_CHECK_INTERVAL or NORMAL_CHECK_INTERVAL
    if currentTime - lastCheckTime < checkInterval then
        return
    end

    local currentX, currentY, currentZ = GetPlayerRawXPos(), GetPlayerRawYPos(), GetPlayerRawZPos()

    if lastCheckTime > 0 then
        local distance = math.sqrt(
            (currentX - lastPosition.x) * (currentX - lastPosition.x) +
            (currentY - lastPosition.y) * (currentY - lastPosition.y) +
            (currentZ - lastPosition.z) * (currentZ - lastPosition.z)
        )

        if distance < MIN_MOVEMENT_DISTANCE then
            consecutiveStuckCount = consecutiveStuckCount + 1
            
            PathStop()
            yield("/vnav stop")
            yield("/automove off")
            
            LogInfo(string.format("[AntiStuck] Character appears to be stuck (attempt %d/%d), stopping navigation", 
                consecutiveStuckCount, MAX_CONSECUTIVE_STUCKS))
            yield("/echo [AntiStuck] Character appears to be stuck, stopping navigation")

            if consecutiveStuckCount >= MAX_CONSECUTIVE_STUCKS and IsMoving() and distance > MIN_MOVEMENT_DISTANCE then
                consecutiveStuckCount = 0
            end
            if consecutiveStuckCount >= MAX_CONSECUTIVE_STUCKS then
                LogInfo("[AntiStuck] Too many consecutive stuck attempts, leaving duty")
                yield("/echo [AntiStuck] Too many consecutive stuck attempts, leaving duty")
                if not IPC.AutoDuty.IsStopped() then IPC.AutoDuty.Stop() end
                LeaveDuty()
                consecutiveStuckCount = 0
                return
            end
        else
            consecutiveStuckCount = 0
        end
    end

    lastPosition.x, lastPosition.y, lastPosition.z = currentX, currentY, currentZ
    lastCheckTime = currentTime
end

local function IsPointInPolygon(polygon, px, pz)
    local crossings, n = 0, #polygon
    if n < 3 then return false end

    for i = 1, n do
        local p1 = polygon[i]
        local p2 = polygon[i % n + 1]

        if (p1.z <= pz and p2.z > pz) or (p1.z > pz and p2.z <= pz) then
            local vt = (pz - p1.z) / (p2.z - p1.z)
            local intersect_x = p1.x + vt * (p2.x - p1.x)
            if px < intersect_x then
                crossings = crossings + 1
            end
        end
    end
    return crossings % 2 == 1
end

local function GetRandomPointInPolygon(polygon, defaultPosition)
    if not polygon or #polygon < 3 then
        yield("/echo [WondrousTails] Invalid polygon...")
        return { x = defaultPosition.x, y = defaultPosition.y, z = defaultPosition.z }
    end

    local min_x, max_x = polygon[1].x, polygon[1].x
    local min_z, max_z = polygon[1].z, polygon[1].z
    for i = 2, #polygon do
        min_x = math.min(min_x, polygon[i].x)
        max_x = math.max(max_x, polygon[i].x)
        min_z = math.min(min_z, polygon[i].z)
        max_z = math.max(max_z, polygon[i].z)
    end

    local attempts, max_attempts = 0, 33
    while attempts < max_attempts do
        local rand_x = min_x + math.random() * (max_x - min_x)
        local rand_z = min_z + math.random() * (max_z - min_z)

        if IsPointInPolygon(polygon, rand_x, rand_z) then return { x = rand_x, y = defaultPosition.y, z = rand_z } end

        attempts = attempts + 1
    end

    yield("/echo [WondrousTails] Failed to find a point in the polygon after " .. max_attempts .. " attempts. Using NPC position.")
    return { x = defaultPosition.x, y = defaultPosition.y, z = defaultPosition.z }
end

--[[
********************************************************************************
*                               State Machine                                  *
********************************************************************************
]]

local CharacterStates = {}
local State = nil
local StopFlag = false

local i = 0
local duty
local WasInteracted = false
local WasPaused, HasBossModOnly = false, false
local WasGCTurnin = false
local lastTargetTime = 0
local Khloe = {
    DataId = 1017653,
    Position = { x = -17.990417, y = 211, z = -1.4801636 },
    Area_Polygon = {        -- yield(string.format("/echo \n{ x = %.4f, z = %.4f },", GetPlayerRawXPos(), GetPlayerRawZPos()))
        { x = -15.7007, z = 4.3411 },
        { x = -18.8683, z = 0.5754 },
        { x = -19.6451, z = 3.0334 },
        { x = -17.2024, z = 4.9097 },
    }
}
local currentRandomDestination = nil
local npcInteractionDistance = 6.75
local arrivalThreshold = 0.45

local lastCombatPosition = { x = 0, y = 0, z = 0 }
local lastCombatCheckTime = 0
local COMBAT_STUCK_CHECK_INTERVAL = 60.0
local MIN_COMBAT_MOVEMENT_DISTANCE = 0.1

local WondrousTailsDuties = {
    {   -- type 0: extreme trials
        { instanceId=20010, dutyId=297, dutyName="The Howling Eye (Extreme)", minLevel=50 },
        { instanceId=20009, dutyId=296, dutyName="The Navel (Extreme)", minLevel=50 },
        { instanceId=20008, dutyId=295, dutyName="The Bowl of Embers (Extreme)", minLevel=50 },
        { instanceId=20012, dutyId=364, dutyName="Thornmarch (Extreme)", minLevel=50 },
        { instanceId=20018, dutyId=359, dutyName="The Whorleater (Extreme)", minLevel=50 },
        { instanceId=20023, dutyId=375, dutyName="The Striking Tree (Extreme)", minLevel=50 },
        { instanceId=20025, dutyId=378, dutyName="The Akh Afah Amphitheatre (Extreme)", minLevel=50 },
        { instanceId=20013, dutyId=348, dutyName="The Minstrel's Ballad: Ultima's Bane", minLevel=50 },
        { instanceId=20034, dutyId=447, dutyName="The Limitless Blue (Extreme)", minLevel=60 },
        { instanceId=20032, dutyId=446, dutyName="Thok ast Thok (Extreme)", minLevel=60 },
        { instanceId=20036, dutyId=448, dutyName="The Minstrel's Ballad: Thordan's Reign", minLevel=60 },
        { instanceId=20038, dutyId=524, dutyName="Containment Bay S1T7 (Extreme)", minLevel=60 },
        { instanceId=20040, dutyId=566, dutyName="The Minstrel's Ballad: Nidhogg's Rage", minLevel=60 },
        { instanceId=20042, dutyId=577, dutyName="Containment Bay P1T6 (Extreme)", minLevel=60 },
        { instanceId=20044, dutyId=638, dutyName="Containment Bay Z1T9 (Extreme)", minLevel=60 },
        { instanceId=20049, dutyId=720, dutyName="Emanation (Extreme)", minLevel=70 },
        { instanceId=20056, dutyId=779, dutyName="The Minstrel's Ballad: Tsukuyomi's Pain", minLevel=70 },
        { instanceId=20058, dutyId=811, dutyName="Hells' Kier (Extreme)", minLevel=70 },
        { instanceId=20054, dutyId=762, dutyName="The Great Hunt (Extreme)", minLevel=70 },
        { instanceId=20061, dutyId=825, dutyName="The Wreath of Snakes (Extreme)", minLevel=70 },
        { instanceId=20063, dutyId=858, dutyName="The Dancing Plague (Extreme)", minLevel=80 },
        { instanceId=20065, dutyId=848, dutyName="The Crown of the Immaculate (Extreme)", minLevel=80 },
        { instanceId=20067, dutyId=885, dutyName="The Minstrel's Ballad: Hades's Elegy", minLevel=80 },
        { instanceId=20069, dutyId=912, dutyName="Cinder Drift (Extreme)", minLevel=80 },
        { instanceId=20070, dutyId=913, dutyName="Memoria Misera (Extreme)", minLevel=80 },
        { instanceId=20072, dutyId=923, dutyName="The Seat of Sacrifice (Extreme)", minLevel=80 },
        { instanceId=20074, dutyId=935, dutyName="Castrum Marinum (Extreme)", minLevel=80 },
        { instanceId=20076, dutyId=951, dutyName="The Cloud Deck (Extreme)", minLevel=80 },
        { instanceId=20078, dutyId=996, dutyName="The Minstrel's Ballad: Hydaelyn's Call", minLevel=90 },
        { instanceId=20081, dutyId=993, dutyName="The Minstrel's Ballad: Zodiark's Fall", minLevel=90 },
        { instanceId=20083, dutyId=998, dutyName="The Minstrel's Ballad: Endsinger's Aria", minLevel=90 },
        { instanceId=20085, dutyId=1072, dutyName="Storm's Crown (Extreme)", minLevel=90 },
        { instanceId=20087, dutyId=1096, dutyName="Mount Ordeals (Extreme)", minLevel=90 },
        { instanceId=20090, dutyId=1141, dutyName="The Voidcast Dais (Extreme)", minLevel=90 },
        { instanceId=20092, dutyId=1169, dutyName="The Abyssal Fracture (Extreme)", minLevel=90 }
    },
    {   -- type 1: expansion cap dungeons
        { dutyName="Dungeons (Lv. 100)", dutyId=1199, minLevel=100 } --Alexandria
        -- { dutyName="Dungeons (Lv. 100)", dutyId=1266, minLevel=100 } --Underkeep
    },
    2,
    3,
    {   -- type 4: normal raids
        { dutyName="Binding Coil of Bahamut", dutyId=241, minLevel=50 },
        { dutyName="Second Coil of Bahamut", dutyId=355, minLevel=50 },
        { dutyName="Final Coil of Bahamut", dutyId=196, minLevel=50 },
        { dutyName="Alexander: Gordias", dutyId=442, minLevel=60 },
        { dutyName="Alexander: Midas", dutyId=520, minLevel=60 },
        { dutyName="Alexander: The Creator", dutyId=580, minLevel=60 },
        { dutyName="Omega: Deltascape", dutyId=693, minLevel=70 },
        { dutyName="Omega: Sigmascape", dutyId=748, minLevel=70 },
        { dutyName="Omega: Alphascape", dutyId=798, minLevel=70 },
        { dutyName="Eden's Gate", dutyId=849, minLevel=80 },
        { dutyName="Eden's Verse", dutyId=903, minLevel=80 },
        { dutyName="Eden's Promise", dutyId=942, minLevel=80 },
        -- { dutyName="AAC Light-heavyweight M1 or M2", dutyId=1225, minLevel=100 },
        -- { dutyName="AAC Light-heavyweight M3 or M4", dutyId=1229, minLevel=100 }
    },
    {   -- type 5: leveling dungeons
        { dutyName="Leveling Dungeons (Lv. 1-49)", dutyId=172, minLevel=15 }, --The Aurum Vale
        { dutyName="Leveling Dungeons (Lv. 51-59/61-69/71-79)", dutyId=434, minLevel=51 }, --The Dusk Vigil
        { dutyName="Leveling Dungeons (Lv. 81-89/91-99)", dutyId=952, minLevel=81 }, --The Tower of Zot
    },
    {   -- type 6: expansion cap dungeons
        { dutyName="High-level Dungeons (Lv. 50 & 60)", dutyId=362, minLevel=50 }, --Brayflox Longstop (Hard)
        { dutyName="High-level Dungeons (Lv. 70 & 80)", dutyId=1146, minLevel=70 }, --Ala Mhigo
        { dutyName="High-level Dungeons (Lv. 90)", dutyId=973, minLevel=90 }, --The Dead Ends
        
    },
    {   -- type 7: ex trials
        {
            { instanceId=20008, dutyId=295, dutyName="Trials (Lv. 50-60)", minLevel=50 }, -- Bowl of Embers
            { instanceId=20049, dutyId=720, dutyName="Trials (Lv. 70-100)", minLevel=70 }
        }
    },
    {   -- type 8: alliance raids

    },
    {   -- type 9: normal raids
        { dutyName="Normal Raids (Lv. 50-60)", dutyId=241, minLevel=50 },
        { dutyName="Normal Raids (Lv. 70-80)", dutyId=693, minLevel=70 },
    },
    Blacklisted= {
        {   -- 0
            { instanceId=20052, dutyId=758, dutyName="The Jade Stoa (Extreme)", minLevel=70 }, -- cannot solo double tankbuster vuln
            { instanceId=20047, dutyId=677, dutyName="The Pool of Tribute (Extreme)", minLevel=70 }, -- cannot solo active time maneuver
            { instanceId=20056, dutyId=779, dutyName="The Minstrel's Ballad: Tsukuyomi's Pain", minLevel=70 } -- cannot solo meteors
        },
        {}, -- 1
        {}, -- 2
        { -- 3
            { dutyName="Treasure Dungeons" }
        },
        {   -- 4
            { dutyName="Alliance Raids (A Realm Reborn)", dutyId=174 },
            { dutyName="Alliance Raids (Heavensward)", dutyId=508 },
            { dutyName="Alliance Raids (Stormblood)", dutyId=734 },
            { dutyName="Alliance Raids (Shadowbringers)", dutyId=882 },
            { dutyName="Alliance Raids (Endwalker)", dutyId=1054 },
            { dutyName="Asphodelos= First to Fourth Circles", dutyId=1002 },
            { dutyName="Abyssos= Fifth to Eighth Circles", dutyId=1081 },
            { dutyName="Anabaseios= Ninth to Twelfth Circles", dutyId=1147 }
        }
    }
}

local command_type, rest_of_command = string.match(chat_command_between_loops, "^/(%w+)%s+(.+)$")
if not command_type or not rest_of_command then
    yield("/echo [WondrousTails] Invalid command format")
    return
end
local command_value
if command_type == "ad" then
    local action, location = string.match(rest_of_command, "^(%w+)%s+(.+)$")
    if action == "goto" then
        command_value = location
    else
        command_value = rest_of_command
    end
else
    command_value = rest_of_command
end
command_value = string.lower(command_value)

CharacterStates.start = function()
    if (not Svc.ClientState.LocalPlayer.Get() or not Svc.ClientState.LocalPlayer.Name() or not IsPlayerAvailable() or IsPlayerOccupied()) 
        and not Condition[ConditionFlag.Occupied39] then
        yield("/echo [WondrousTails] Player not available or occupied") yield("/wait 5")
        return
    elseif Svc.ClientState.LocalPlayer.Get() and Svc.ClientState.LocalPlayer.Name() and (IsPlayerAvailable() or Condition[ConditionFlag.Occupied39]) 
        and not Condition[ConditionFlag.BoundByDuty] and not Condition[ConditionFlag.BoundByDuty56] and IPC.AutoDuty.IsStopped() then
        local target_zone_id = nil
        if command_value == "barracks" then
            target_zone_id = {[534]=1,[535]=1,[536]=1}
        elseif command_value == "inn" or command_value == "hinn" then
            target_zone_id = {[177]=1,[179]=1,[178]=1,[429]=1,[629]=1,[843]=1,[990]=1,[1205]=1}
        elseif command_value == "home" or command_value == "house" or command_value == "private" or command_value == "personalhome" then
            target_zone_id = {[282]=1,[283]=1,[284]=1,[342]=1,[343]=1,[344]=1,[345]=1,[346]=1,[347]=1,[649]=1,[650]=1,[651]=1,[980]=1,[981]=1,[982]=1}
        elseif command_value == "fc" or command_value == "free" or command_value == "company" or command_value == "free company" or command_value == "fcestate" then
            target_zone_id = {[282]=1,[283]=1,[284]=1,[342]=1,[343]=1,[344]=1,[345]=1,[346]=1,[347]=1,[649]=1,[650]=1,[651]=1,[980]=1,[981]=1,[982]=1}
        elseif command_value == "apartment" or command_value == "apt" then
            target_zone_id = {[608]=1,[609]=1,[610]=1,[655]=1,[999]=1}
        elseif command_value == "island" then
            target_zone_id = {[1055]=1}
        end

        if not HasWeeklyBingoJournal() or IsWeeklyBingoExpired() or WeeklyBingoNumPlacedStickers() == 9 then
            if not IsInZone(478) then
                if not LifestreamIsBusy() and not Condition[ConditionFlag.Casting] 
                    and IsPlayerAvailable() and not IsPlayerOccupied() 
                    and not Condition[ConditionFlag.InCombat] 
                    then LifestreamTeleport(75, 0) yield("/wait 1") end
                ZoneLoad()
            else
                State = CharacterStates.goToKhloe
            end
            return
        elseif SelectedJobForFarm ~= "" and GetClassJobId() ~= ClassList[SelectedJobForFarm].classId then
            yield("/echo [WondrousTails] Changing job from " .. GetClassJobId() .. " to " .. SelectedJobForFarm .. " (" .. ClassList[SelectedJobForFarm].classId .. ")")
            yield("/gs change " .. SelectedJobForFarm) yield("/wait 0.5")
            return
        elseif RepairThreshold > 0 and NeedsRepair(RepairThreshold - 1) then
            if Condition[ConditionFlag.Occupied39] then
                yield("/echo [WondrousTails] Repairing...")
            elseif  IPC.AutoDuty.GetConfig("AutoRepair") == "False" then
                yield("/echo [WondrousTails] AutoRepair is disabled, enabling it...")
                IPC.AutoDuty.SetConfig("AutoRepair", "True")
            elseif  IPC.AutoDuty.GetConfig("AutoRepairPct") ~= tostring(RepairThreshold) then
                yield("/echo [WondrousTails] AutoRepairPct is not set to " .. RepairThreshold .. ", setting it...")
                IPC.AutoDuty.SetConfig("AutoRepairPct", tostring(RepairThreshold))
            else
                yield("/autoduty repair") yield("/echo [WondrousTails] Try Repairing...")
            end
            yield("/wait 1")
            return
        elseif CanExtractMateria(100) and GetInventoryFreeSlotCount() > 1 then
            if Condition[ConditionFlag.Occupied39] then
                yield("/echo [WondrousTails] Extracting...")
            else
                yield("/autoduty extract") yield("/echo [WondrousTails] Try Extracting...")
            end
            yield("/wait 1")
            return
        elseif chat_command_between_loops ~= "" and target_zone_id and not target_zone_id[GetZoneID()] and i <= 12 then
            yield("/echo [WondrousTails] Trying to reach destination")

            local max_attempts, attempts = 30, 0
            while attempts < max_attempts do
                if target_zone_id[GetZoneID()] then return end

                if not LifestreamIsBusy() and not Condition[ConditionFlag.Casting] 
                    and IsPlayerAvailable() and not IsPlayerOccupied() 
                    and not PathIsRunning() and not PathfindInProgress() 
                    and not Condition[ConditionFlag.InCombat] then
                    if command_type == "li" then
                        yield("/li " .. command_value)
                    elseif command_type == "ad" or command_type == "autoduty" then
                        yield("/ad goto " .. command_value)
                    end
                    yield("/wait 1")
                else
                    yield("/wait 5")
                end

                AntiStuckCheck()
                attempts = attempts + 1
            end
            if attempts >= max_attempts then
                yield("/echo [WondrousTails] Failed to reach destination after multiple attempts")
                State = CharacterStates.endState
                return
            end
            return
        elseif i <= 12 then
            local function SearchWonderousTailsTable(type, data, text)
                if type == 0 then -- ex trials are indexed by instance#
                    for _, duty in ipairs(WondrousTailsDuties[type+1]) do
                        if duty.instanceId == data then
                            return duty
                        end
                    end
                elseif type == 1 or type == 5 or type == 6 or type == 7 then -- dungeons, level range ex trials
                    for _, duty in ipairs(WondrousTailsDuties[type+1]) do
                        if duty.dutyName == text then
                            return duty
                        end
                    end
                elseif type == 4 or type == 8 then -- normal raids
                    for _, duty in ipairs(WondrousTailsDuties[type+1]) do
                        if duty.dutyName == text then
                            return duty
                        end
                    end
                end
            end

            -- skip 13: Shadowbringers raids (not doable solo unsynced)
            -- skip 14: Endwalker raids (not doable solo unsynced)
            -- skip 15: PVP
            if GetWeeklyBingoTaskStatus(i) == 0 then
                local key = GetWeeklyBingoOrderDataKey(i)
                local type = GetWeeklyBingoOrderDataType(key)
                local data = GetWeeklyBingoOrderDataData(key)
                local text = GetWeeklyBingoOrderDataText(key)
                LogInfo("[WondrousTails] Wondrous Tails #"..(i+1).." Key: "..key)
                LogInfo("[WondrousTails] Wondrous Tails #"..(i+1).." Type: "..type)
                LogInfo("[WondrousTails] Wondrous Tails #"..(i+1).." Data: "..data)
                LogInfo("[WondrousTails] Wondrous Tails #"..(i+1).." Text: "..text)

                duty = SearchWonderousTailsTable(type, data, text)
                if duty == nil then yield("/echo [WondrousTails] Duty not valid for script: " .. text) end

                local dutyMode = "Support"
                if duty ~= nil then
                    if GetLevel() < duty.minLevel then
                        yield("/echo [WondrousTails] Cannot queue for "..duty.dutyName.." as level is too low.")
                        duty.dutyId = nil
                    elseif type == 0 then -- trials
                        dutyMode = "Trial"
                    elseif type == 4 then -- raids
                        dutyMode = "Raid"
                    elseif GetLevel() - duty.minLevel < 20 then
                        -- yield("/autoduty cfg dutyModeEnum 1") -- TODO: test this when it gets released
                        yield("/autoduty cfg Unsynced false")
                        dutyMode = "Support"
                    else
                        -- yield("/autoduty cfg dutyModeEnum 8")
                        dutyMode = "Regular"
                    end

                    if duty.dutyId ~= nil and (dutyMode == "Trial" or dutyMode == "Raid" or dutyMode == "Regular") and  IPC.AutoDuty.GetConfig("Unsynced") == "False" then
                        yield("/echo [WondrousTails] Unsynced is disabled, enabling it...")
                        IPC.AutoDuty.SetConfig("Unsynced", "True")
                    end

                    if duty.dutyId ~= nil then
                        --[[        -- broken
                        if not IPC.AutoDuty.ContentHasPath(duty.dutyId) then
                            yield("/echo [WondrousTails] Duty "..duty.dutyName.." does not have a path in AutoDuty, skipping...")
                        else
                        ]]
                        yield("/echo [WondrousTails] Queuing duty TerritoryId#"..duty.dutyId.." for Wondrous Tails #"..(i+1))

                        yield("/autoduty run "..dutyMode.." "..duty.dutyId.." 1 true")
                        yield("/wait 5") ZoneLoad()
                    else
                        if duty.dutyName ~= nil then
                            yield("/echo [WondrousTails] Wondrous Tails Script does not support Wondrous Tails entry #"..(i+1).." "..duty.dutyName)
                            LogInfo("[WondrousTails] Wondrous Tails Script does not support Wondrous Tails entry #"..(i+1).." "..duty.dutyName)
                        else
                            yield("/echo [WondrousTails] Wondrous Tails Script does not support Wondrous Tails entry #"..(i+1))
                            LogInfo("[WondrousTails] Wondrous Tails Script does not support Wondrous Tails entry #"..(i+1))
                        end
                    end
                end
            end
            i = i + 1
        else
            yield("/echo [WondrousTails] Completed all Wondrous Tails entries it is capable of...")
            State = CharacterStates.endState
        end
        return
    elseif IsInZone(duty.dutyId) and Svc.DutyState.IsDutyStarted() 
        and (Condition[ConditionFlag.BoundByDuty] or Condition[ConditionFlag.BoundByDuty56]) 
        and IsPlayerAvailable() and IPC.AutoDuty.IsLooping() then
        LogInfo("[WondrousTails] Duty Dungeon")
        State = CharacterStates.dutyDungeon
        return
    end

    yield("/wait 10")
end

CharacterStates.goToKhloe = function()
    local npc = Svc.Objects.ObjectHelper.GetObjectByDataId(Khloe.DataId)

    if IsAddonVisible("SelectString") then
        if not HasWeeklyBingoJournal() then
            yield("/callback SelectString true 0")
        elseif IsWeeklyBingoExpired() then
            yield("/callback SelectString true 1")
        elseif WeeklyBingoNumPlacedStickers() == 9 then
            yield("/callback SelectString true 0")
            yield("/echo [WondrousTails] Wondrous Tails finished this week and has been turned...")
            State = CharacterStates.endState
            return
        end
    elseif IsAddonVisible("SelectYesno") then
        yield("/callback SelectYesno true 0")
    elseif IsAddonVisible("Talk") then
        yield("/click Talk Click")
    elseif WasInteracted and IsPlayerAvailable() then
        State = CharacterStates.start
        currentRandomDestination = nil
    elseif currentRandomDestination == nil then
        currentRandomDestination = GetRandomPointInPolygon(Khloe.Area_Polygon, Khloe.Position)
    elseif GetDistanceToPoint(Khloe.Position.x, Khloe.Position.y, Khloe.Position.z) > 35 
        and not Condition[ConditionFlag.Mounted] and not (Condition[ConditionFlag.Casting] or Condition[ConditionFlag.MountOrOrnamentTransition]) 
        and (TerritorySupportsMounting() or IsInZone(478)) then  -- 'TerritorySupportsMounting' broken in one day???
        ExecuteGeneralAction(9)
    elseif npc == nil or not Svc.Objects.Object.IsTargetable(npc) or GetDistanceToPoint(currentRandomDestination.x, currentRandomDestination.y, currentRandomDestination.z) > arrivalThreshold then
        if not PathIsRunning() and not PathfindInProgress() then PathfindAndMoveTo(currentRandomDestination.x, currentRandomDestination.y, currentRandomDestination.z) end
        if not (Condition[ConditionFlag.Casting] or Condition[ConditionFlag.MountOrOrnamentTransition]) then AutoSprint() end
    elseif Svc.Objects.Object.IsTargetable(npc) and GetDistanceToPoint(currentRandomDestination.x, currentRandomDestination.y, currentRandomDestination.z) <= arrivalThreshold then
        if PathIsRunning() or PathfindInProgress() then
            yield("/vnav stop")
        elseif not (Targets.Target and Targets.Target.DataId == npc.DataId) and Svc.Objects.Object.IsTargetable(npc) then
            Targets.Target = npc
        elseif IsPlayerAvailable() and (Targets.Target and Targets.Target.DataId == npc.DataId) then
            if GetDistanceToTarget() <= npcInteractionDistance then
                yield("/interact")
                WasInteracted = true
            else
                currentRandomDestination = nil
                yield("/wait 1")
            end
        end
    end
end

CharacterStates.dutyDungeon = function()
    local function ManageCombatPlugins(enable)
        if PluginCommands.NotUse then return end
        local hasRotation = false
        local hasWrath = true
        local hasBM = false
        local hasBMR = true
        
        if not (hasRotation and hasWrath) then
            if hasRotation and not PluginCommands.RotationSolver.NotUse then
                yield(PluginCommands.RotationSolver[enable and "enable" or "disable"])
            elseif hasWrath and not PluginCommands.WrathCombo.NotUse then
                yield(PluginCommands.WrathCombo[enable and "enable" or "disable"])
            end
            HasBossModOnly = false
        end
        
        if not (hasBM and hasBMR) and not hasRotation and not hasWrath then
            if hasBM and not PluginCommands.BossMod.NotUse then
                if enable then
                    yield(PluginCommands.BossMod.set_preset_without_rotation) HasBossModOnly = true
                else
                    yield("/vbm ar set Deactive")
                end
            elseif hasBMR and not PluginCommands.BossModReborn.NotUse then
                if enable then
                    yield(PluginCommands.BossModReborn.set_preset_without_rotation) HasBossModOnly = true
                else
                    yield("/bmr ar set Deactive")
                end
            end
        elseif not (hasBM and hasBMR) and (hasRotation and not PluginCommands.RotationSolver.NotUse or hasWrath and not PluginCommands.WrathCombo.NotUse) then
            if hasBM and not PluginCommands.BossMod.NotUse then
                if enable then
                    yield(PluginCommands.BossMod.set_preset_with_rotation) HasBossModOnly = true
                else
                    yield("/vbm ar set Deactive")
                end
            elseif hasBMR and not PluginCommands.BossModReborn.NotUse then
                if enable then
                    yield(PluginCommands.BossModReborn.set_preset_with_rotation) HasBossModOnly = true
                else
                    yield("/bmr ar set Deactive")
                end
            end
        end
    end

    -- if IPC.AutoDuty.IsNavigating() and IPC.AutoDuty.IsLooping() then
    if IsInZone(duty.dutyId) and Svc.DutyState.IsDutyStarted() 
        and (Condition[ConditionFlag.BoundByDuty] or Condition[ConditionFlag.BoundByDuty56]) 
        and IsPlayerAvailable() and IPC.AutoDuty.IsLooping() then
        if WasPaused then
            yield("/wait 5")
            yield("/autoduty resume")
            WasPaused = false
        end

        if Condition[ConditionFlag.InCombat] then
            if HasTarget() then
                local currentX, currentY, currentZ = GetPlayerRawXPos(), GetPlayerRawYPos(), GetPlayerRawZPos()

                if lastCombatCheckTime == 0 then
                    lastCombatCheckTime = os.clock()
                    lastCombatPosition.x, lastCombatPosition.y, lastCombatPosition.z = currentX, currentY, currentZ
                elseif os.clock() - lastCombatCheckTime >= COMBAT_STUCK_CHECK_INTERVAL then
                    local distance = math.sqrt(
                        (currentX - lastCombatPosition.x) * (currentX - lastCombatPosition.x) +
                        (currentY - lastCombatPosition.y) * (currentY - lastCombatPosition.y) +
                        (currentZ - lastCombatPosition.z) * (currentZ - lastCombatPosition.z)
                    )

                    if distance < MIN_COMBAT_MOVEMENT_DISTANCE then
                        yield("/echo [WondrousTails] Character stuck in combat, moving to target...")
                        ManageCombatPlugins(false) yield("/autoduty pause") WasPaused = true yield("/wait 1")
                        if not PathIsRunning() and not PathfindInProgress() then PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos()) yield("/wait 5") end
                        if PathIsRunning() or PathfindInProgress() then yield("/vnav stop") end
                    end
                    lastCombatCheckTime = os.clock()
                    lastCombatPosition.x, lastCombatPosition.y, lastCombatPosition.z = currentX, currentY, currentZ
                end
            end

            if not HasTarget() then
                if lastTargetTime == 0 then
                    lastTargetTime = os.clock()
                elseif os.clock() - lastTargetTime >= 5 then
                    if IsAddonVisible("_EnemyList") then
                        yield("/callback _EnemyList true 12 0 0")
                    else
                        yield("/targetenemy") -- yield("/battletarget")
                    end
                    lastTargetTime = 0
                end
            else
                lastTargetTime = 0
            end
        elseif not Condition[ConditionFlag.InCombat] then
            lastCombatPosition = { x = 0, y = 0, z = 0 }
            lastCombatCheckTime = 0
        end
        ManageCombatPlugins(true)
    elseif not IsInZone(duty.dutyId) and not Condition[ConditionFlag.BoundByDuty] and not Condition[ConditionFlag.BoundByDuty56] and IsPlayerAvailable() then
        if not IPC.AutoDuty.IsStopped() then IPC.AutoDuty.Stop() end
        ManageCombatPlugins(false)
        lastCombatPosition = { x = 0, y = 0, z = 0 }
        lastCombatCheckTime = 0
        State = CharacterStates.start
        return
    -- elseif not WasPaused and not IsPlayerAvailable() and not IsPlayerOccupied() and (not GetCharacterCondition(34) or not GetCharacterCondition(56)) then
    elseif GetCharacterName() == "null" then
        LogInfo("[WondrousTails] Duty paused")
        yield("/autoduty pause")
        WasPaused = true
    end

    AntiStuckCheck()

    if not HasBossModOnly then yield("/wait 5") else yield("/wait 1.5") end
end

CharacterStates.endState = function()
    if GetInventoryFreeSlotCount() <= GC_Turnin_Free_Slots and GC_Turnin_Free_Slots > 0 and i > 12 or DeliverooIsTurnInRunning() then
        if DeliverooIsTurnInRunning() then
            GC_Turnin_Free_Slots = 0
            yield("/echo [WondrousTails] Deliveroo is Turnin Running...")
        elseif GetInventoryFreeSlotCount() <= GC_Turnin_Free_Slots and not WasGCTurnin then
            yield("/autoduty turnin") yield("/echo [WondrousTails] Try Turnin...")
            WasGCTurnin = true
        end
        yield("/wait 5")
        return
    else
        StopFlag = true
    end
end

--[[
********************************************************************************
*                                Main Loop                                     *
********************************************************************************
]]

local SavedSettings = {}
local AutoDutySettings = {
    "EnablePreLoopActions",
    "EnableBetweenLoopActions",
    "EnableTerminationActions"
}
for _, setting in ipairs(AutoDutySettings) do
    SavedSettings[setting] =  IPC.AutoDuty.GetConfig(setting) == "True"
    if SavedSettings[setting] then yield("/echo [WondrousTails] Disabling " .. setting .. ": enabled") IPC.AutoDuty.SetConfig(setting, "False") end
end


math.randomseed(os.time())
State = CharacterStates.start
while not StopFlag do
    if Svc.ClientState.IsLoggedIn() then
        State()
        yield("/wait 0.1")
    else
        yield("/wait 1")
    end
end


for setting, wasEnabled in pairs(SavedSettings) do
    if wasEnabled then yield("/echo [WondrousTails] Restoring " .. setting .. " to enabled") IPC.AutoDuty.SetConfig(setting, "True") end
end
