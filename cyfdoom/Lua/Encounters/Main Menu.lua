wavetimer = math.huge
enemies   = {"emptyMonster"}
nextwaves = {"menuWave"}

function EncounterStarting()
    NewAudio.Stop("src")
    State("DEFENDING")
end