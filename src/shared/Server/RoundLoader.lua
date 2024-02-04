local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Round = require(script.Parent.Wrappers.Round)
local RoundSettings = require(ReplicatedStorage.Configuration.Round)

local roundContainer = Instance.new("Configuration", ReplicatedStorage)
    roundContainer.Name = "Round"
    
local round = Round.wrap(roundContainer, RoundSettings)
round:start()

while true do
    round.timerEnded:await()
    round:restart()
end