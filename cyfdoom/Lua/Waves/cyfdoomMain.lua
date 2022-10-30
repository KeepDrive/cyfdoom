local wadFileName = Encounter.GetVar("wadFileName")

readers = require "reader"

lumps = readers.wad(wadFileName)

lumps = nil

function Update()
end