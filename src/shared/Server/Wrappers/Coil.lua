--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Assets
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Wrappers = ReplicatedStorage:WaitForChild("Server")
    :WaitForChild("Wrappers")

--// Imports
local wrapper = require(Packages.Wrapper)
--// Module
local Coil = {}

--// Cache
local coils = setmetatable({}, { __mode = "k"} )

function Coil.wrap(item: Tool, data)

    local rbxPlayer = item:FindFirstAncestorOfClass("Player")
        :: Player
    assert(rbxPlayer, `Coil need has a player as ancestor`)

    local self = wrapper(item, "Coil")
        :_applyAttributes(data)

    local levelRatio: number = self.Level / self.MaxLevel
    local healingThread: thread?

    self.SpeedIncrease = levelRatio * self.MaxSpeedIncrease
    self.JumpIncrease = levelRatio * self.MaxJumpIncrease
    self.HealIncrease = levelRatio * self.MaxHealIncrease

    function self:enable()
        local rbxHumanoid = rbxPlayer.Character:WaitForChild("Humanoid")
        self:startHealing()

        rbxHumanoid.HealthChanged:Connect(function() self:startHealing() end)
    end

    function self:disable()
        if healingThread then
            task.cancel(healingThread)
            healingThread = nil
        end
    end

    function self:isEquipped()
        local rbxCharacter = rbxPlayer.Character

        return item:IsDescendantOf(rbxCharacter) 
    end
    function self:startHealing()

        if healingThread or self.HealIncrease == 0 then
            return     
        end

        local holderHumanoid = rbxPlayer.Character:WaitForChild("Humanoid")

        healingThread = task.spawn(function()
            while 
                holderHumanoid.Health < holderHumanoid.MaxHealth and 
                self:isEquipped() 
            do
                 holderHumanoid.Health += self.HealIncrease
     
                 task.wait(1)
             end
     
             healingThread = nil
        end)

        self:_host(healingThread)
    end

    --// Listeners
    item.Equipped:Connect(function() self:enable() end)
    item.Unequipped:Connect(function() self:disable() end)

    --// Cache
    coils[item] = self

end
function Coil.find(item: Tool)

    return coils[item]
end
function Coil.get(item: Tool)

   return Coil.find(item) or Coil.wrap(item) 
end
function Coil.await(item)

    while not Coil.find(item) do task.wait() end

    return Coil.find(item)
end

return Coil