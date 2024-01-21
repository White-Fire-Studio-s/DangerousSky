local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoundContainer = ReplicatedStorage:WaitForChild("Round")
local Wrappers = ReplicatedStorage.Server.Wrappers
local Player = require(Wrappers.Player)

local function canExecute(player)
    return player.isDeveloper 
        or player.isPrivateServerOwner 
        or player.isPrivateServerMod
end

return function(rbxPlayer: Player, arguments: {any})
    local player = Player.get(rbxPlayer)

    if not canExecute(player) then
        return 
    end

    RoundContainer:SetAttribute("timer", 0)
end