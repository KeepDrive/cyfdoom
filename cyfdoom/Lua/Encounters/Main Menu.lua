wavetimer = math.huge -- Makes the wave effectively infinte
enemies   = {"emptyMonster"}
nextwaves = {"cyfdoomWADChoice"}

function EncounterStarting()
    NewAudio.Stop("src")
    State("DEFENDING") -- Makes the wave start immediately
end