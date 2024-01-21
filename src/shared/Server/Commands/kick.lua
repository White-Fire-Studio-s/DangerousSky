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

    --// Finder
    local targetName = arguments[1]:lower()
    local targetRbxPlayer

    for _,rbxPlayer in Players:GetPlayers() do

        if rbxPlayer.Name:lower():find(targetName) then
            targetRbxPlayer = rbxPlayer
            break
        end
    end

    local targetPlayer = Player.find(targetRbxPlayer)
    if not targetPlayer or targetPlayer.isPrivateServerOwner then
        return 
    end

    targetRbxPlayer:Kick("A private server moderator kicked you out")
end