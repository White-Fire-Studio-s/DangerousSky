--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Variables
local Round = require(ReplicatedStorage.Server.Wrappers.Round).get()

local function trait()
    Round.timer += 1.5 * 60
end

return trait