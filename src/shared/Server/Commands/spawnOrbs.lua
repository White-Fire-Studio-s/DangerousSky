local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoundContainer = ReplicatedStorage:WaitForChild("Round")
local Wrappers = ReplicatedStorage.Server.Wrappers
local Player = require(Wrappers.Player)

local Round = require(Wrappers.Round).get()

local function canExecute(player)
    return player.isDeveloper 
end

return function(rbxPlayer: Player, arguments: {any})
    local player = Player.get(rbxPlayer)
    local amount = tonumber(arguments[1])

    if not canExecute(player) then
        return 
    end

    if not amount then
        return
    end
    
    Round:spawnOrbs(amount)
end