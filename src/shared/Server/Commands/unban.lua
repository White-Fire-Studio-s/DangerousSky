local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoundContainer = ReplicatedStorage:WaitForChild("Round")

local Wrappers = ReplicatedStorage.Server.Wrappers
local Player = require(Wrappers.Player)

local function canExecute(player)
    return player.isDeveloper 
        or player.isPrivateServerOwner 
end

return function(rbxPlayer: Player, arguments: {any})
    local player = Player.get(rbxPlayer)

    if not arguments[1] then
        return
    end

    if not canExecute(player) then
        return 
    end

    local userId = tonumber(arguments[1])
    if not userId then return end

    Player.removeBlacklist(userId)  
end