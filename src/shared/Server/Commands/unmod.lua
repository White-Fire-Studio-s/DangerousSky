local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoundContainer = ReplicatedStorage:WaitForChild("Round")

local Wrappers = ReplicatedStorage.Server.Wrappers
local Player = require(Wrappers.Player)

local function canExecute(player)
    return player.isDeveloper 
        or player.isPrivateServerOwner 
        or player.isOwner
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

    if not targetRbxPlayer then
        return 
    end

    --// Mod
    local targetPlayer = Player.get(targetRbxPlayer)
    targetPlayer:turnModerator(false)

    return { TargetName = targetRbxPlayer.Name }
end