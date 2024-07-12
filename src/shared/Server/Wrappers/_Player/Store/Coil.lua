--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Assets
local Assets = ReplicatedStorage:WaitForChild("Assets")
local Wrappers = ReplicatedStorage:WaitForChild("Server")
    :WaitForChild("Wrappers")

--// Imports
local Inventory = require(Wrappers._Player.Inventory)
local Coil = require(Wrappers.Coil)
local CoilsConfiguration = require(ReplicatedStorage.Configuration.Coils)

local Round = require(Wrappers.Round).get()

return function (rbxPlayer: Player, coilName: string)

    local inventory = Inventory.get(rbxPlayer)

    if inventory:hasItem(coilName) then
        return
    end

    local coilContainer = Assets.Coils[coilName]:Clone() 

    CoilsConfiguration[coilName].Level = CoilsConfiguration[coilName].MaxLevel
    coilContainer.Parent = rbxPlayer.Backpack

    inventory:addItem(coilContainer)

    Coil.wrap(coilContainer, CoilsConfiguration[coilName])

    Round.timerEnded:once(function()
        task.defer(coilContainer.Destroy, coilContainer)
    end)

    return true
end