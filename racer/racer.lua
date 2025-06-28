yield("/echo Chocobo Racing Script Starting.")
racenum = 0

for loops = 20, 1, -1 do
	racenum = racenum+1
	yield("/echo Attempting to queue for Race Number:"..racenum)

	if Addons.GetAddon("JournalDetail").Ready==false then yield("/dutyfinder") end
		yield("/waitaddon JournalDetail")
		yield("/pcall ContentsFinder true 1 9")
		yield("/pcall ContentsFinder true 12 1")
		yield("/pcall ContentsFinder true 3 11")
		yield("/pcall ContentsFinder true 12 0 <wait.1>")
	if Addons.GetAddon("ContentsFinderConfirm").Ready then yield("/click duty_commence") end
		yield("/echo Queueing for Race Number:"..racenum)
	
	repeat
		local zone = tostring(Svc.ClientState.TerritoryType)
		yield("/wait 5")
		yield("/echo Queuing / Race loading...")
	until zone == "390"

	yield("/echo Race successfully loaded.")

	repeat
		supersprinting = false
		yield("/echo Attempting to Super Sprint.")
		Actions.ExecuteAction(58, ActionType.ChocoboRaceAbility)
		yield("/wait 0.1")
		for i = 0, 29 do
			local status = Svc.ClientState.LocalPlayer.StatusList[i]
			if status.StatusId == 1058 then
				supersprinting = true
				yield("/echo Super Sprint Active.")
			end
		end
	until supersprinting == true

	yield("/echo Controlling the Chocobo...")
	yield("/echo Holding Left.")
	yield("/hold A")
	yield("/echo Waiting 5 Seconds.")
	yield("/wait 5")
	yield("/echo Releasing Left.")
	yield("/release A")
	yield("/echo Waiting 10 Seconds.")
	yield("/wait 10")
	yield("/echo Using Choco Cure III.")
	Actions.ExecuteAction(6, ActionType.ChocoboRaceAbility)

	repeat
		yield("/echo Attempting to use any Race Items (and Choco Cure III) every 5 seconds.")
		for i = 1, 11 do
			Actions.ExecuteAction(i, luanet.enum(ActionType, 'ChocoboRaceItem'))
			Actions.ExecuteAction(6, ActionType.ChocoboRaceAbility) 
		end
		yield("/wait 5")
		local zone = tostring(Svc.ClientState.TerritoryType)
	until zone ~= "390"

	repeat
		yield("/echo Waiting till the player is available again...")
		yield("/wait 2")
	until Player.Available

	yield("/echo Race Complete.")

end
