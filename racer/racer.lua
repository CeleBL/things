--This script will attempt to run X number of Sagolii Road Chocobo Races.
--It will use Super Sprint at the start of the race, then hug the left-side of the track.
--It will then use any race items and Choco Cure III, every 5 seconds, until the end of the race.
--See (https://exd.camora.dev/sheet/ChocoboRaceAbility) for a full list of Chocobo Race Abilities.

--The idea of this script is to make it slightly more successful at winning races rather than just
--using other plugins that simply queue for 20 races.
--It's not going to win every race.

--This script relies on the plugin YesAlready to exit the dialog at the end of the race to return.
--'YesAlready' > 'Bothers' > 'Minigames and Special Events' > 'RaceChocoboResult'
--'YesAlready' Repo (https://github.com/PunishXIV/YesAlready)

--To Do:
---Add in checks to end the script if the user cancels the queue.

yield("/echo Chocobo Racing Script Starting...")


racenum = 0
NumOfRaces = 20 --Change this if you want to do less than 20.

for loops = NumOfRaces, 1, -1 do
	racenum = racenum+1
	yield("/echo Attempting to queue for Race Number:"..racenum)

	if Addons.GetAddon("JournalDetail").Ready==false then yield("/dutyfinder") end
		yield("/waitaddon JournalDetail")
		yield("/pcall ContentsFinder true 1 9")
		yield("/pcall ContentsFinder true 12 1")
		yield("/pcall ContentsFinder true 3 11")
		yield("/pcall ContentsFinder true 12 0 <wait.1>")
	if Addons.GetAddon("ContentsFinderConfirm").Ready then yield("/click duty_commence") end
		--yield("/echo Queueing for Race Number:"..racenum)
	
	repeat
		local zone = tostring(Svc.ClientState.TerritoryType)
		yield("/wait 5")
	until zone == "390"

	--yield("/echo Race successfully loaded.")

	repeat
		supersprinting = false
		--yield("/echo Attempting to Super Sprint.")
		Actions.ExecuteAction(58, ActionType.ChocoboRaceAbility)
		yield("/wait 0.1")
		for i = 0, 29 do
			local status = Svc.ClientState.LocalPlayer.StatusList[i]
			if status.StatusId == 1058 then
				supersprinting = true
				--yield("/echo Super Sprint Active.")
			end
		end
	until supersprinting == true

	--yield("/echo Hugging the left-side of the track.")
	yield("/hold A")
	yield("/wait 5")
	yield("/release A")
	--yield("/echo Waiting 10 Seconds then using Choco Cure III.")
	yield("/wait 10")
	Actions.ExecuteAction(6, ActionType.ChocoboRaceAbility) --6 = Choco Cure III

	--yield("/echo Now attempting to use any Race Items, and Choco Cure III, every 5 seconds.")
	repeat
		for i = 1, 11 do
			Actions.ExecuteAction(i, luanet.enum(ActionType, 'ChocoboRaceItem')) -- Cycles through all items.
			Actions.ExecuteAction(6, ActionType.ChocoboRaceAbility) --6 = Choco Cure III, (If we get a Choco Aether item).
		end
		yield("/wait 5")
		local zone = tostring(Svc.ClientState.TerritoryType)
	until zone ~= "390"

	repeat
		--yield("/echo Waiting till the player is available again...")
		yield("/wait 2")
	until Player.Available

	yield("/echo Race Complete.")

end
