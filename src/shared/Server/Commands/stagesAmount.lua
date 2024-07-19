local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoundContainer = ReplicatedStorage:WaitForChild("Round")
local Wrappers = ReplicatedStorage.Server.Wrappers
local Player = require(Wrappers.Player)

local function canExecute(player)
    return player.isDeveloper 
        or player.isPrivateServerOwner 
        or player.isPrivateServerMod
        or player.isOwner
end

return function(rbxPlayer: Player, arguments: {any})
    local player = Player.get(rbxPlayer)
    local stagesAmount = tonumber(arguments[1])

    if not canExecute(player) then
        return 
    end

    if not stagesAmount then
        return
    end
    if stagesAmount <= 0 or stagesAmount > 1000 then
        return
    end

    RoundContainer:SetAttribute("stagesAmount", math.ceil(stagesAmount))

    return {}
end