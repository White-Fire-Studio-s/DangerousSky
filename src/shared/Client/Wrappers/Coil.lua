--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

--// Assets
local Packages = ReplicatedStorage:WaitForChild("Packages")
--// Imports
local wrapper = require(Packages.Wrapper)

--// Vars
local rbxPlayer = Players.LocalPlayer
--// Module
local Coil = {}

--// Cache
local coils = setmetatable({}, { __mode = "k"} )

function Coil.wrap(item: Tool)
    if not item:IsDescendantOf(rbxPlayer) then
        return
    end
    local self = wrapper(item)

    local defaultJumpPower = StarterPlayer.CharacterJumpPower
    local defaultGravity = workspace.Gravity
    local defaultSpeed = StarterPlayer.CharacterWalkSpeed

    local usedJumps = 0
    local lastJumpRequestTime = 0

    local humanoidStateConnection: RBXScriptConnection
    local jumpRequestConnection: RBXScriptConnection

    function self:enable()

        local jumpIncrease = self.JumpIncrease
        local speedIncrease = self.SpeedIncrease
        local gravityDecrease = 51.4 * jumpIncrease / self.MaxJumpIncrease

        local rbxHumanoid =  rbxPlayer.Character.Humanoid

        --// Setters
        rbxHumanoid.JumpPower = defaultJumpPower + jumpIncrease
        rbxHumanoid.WalkSpeed = defaultSpeed + speedIncrease
        Workspace.Gravity = defaultGravity - gravityDecrease

        --// Listeners
        if self.MaxJumps > 0 then
            humanoidStateConnection = rbxHumanoid.StateChanged:Connect(function(_, newState)
                if newState == Enum.HumanoidStateType.Landed then
                    usedJumps = 0
                end
            end)
    
            jumpRequestConnection = UserInputService.JumpRequest:Connect(function()
                self:requestJump()
            end)
    
            self:_host(humanoidStateConnection)
            self:_host(jumpRequestConnection)
        end
    end
    function self:disable()

        local rbxHumanoid =  rbxPlayer.Character.Humanoid

        rbxHumanoid.JumpPower = defaultJumpPower 
        rbxHumanoid.WalkSpeed = defaultSpeed 
        Workspace.Gravity = defaultGravity 

        if self.MaxJumps > 0 then
            humanoidStateConnection:Disconnect()
            jumpRequestConnection:Disconnect()

            humanoidStateConnection = nil
            jumpRequestConnection = nil
        end
    end
    function self:requestJump()
        local rbxHumanoid =  rbxPlayer.Character.Humanoid

        local currentTime = os.clock()
        local elapsedTime = currentTime - lastJumpRequestTime
        if elapsedTime < 0.1 then return end

        if rbxHumanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
            return
        end

        if usedJumps == self.MaxJumps then return end

        rbxHumanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        lastJumpRequestTime = os.clock()
        usedJumps += 1
    end
    function self:isEquipped()

        local rbxCharacter = rbxPlayer.Character

        return item:IsDescendantOf(rbxCharacter) 
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