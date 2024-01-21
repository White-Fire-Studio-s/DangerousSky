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
    local timer = tonumber(arguments[1])

    if not canExecute(player) then
        return 
    end

    if not timer then
        return
    end

    local currentTime = RoundContainer:GetAttribute("timer")
    RoundContainer:SetAttribute("timer", math.max(currentTime + timer, 0))
end