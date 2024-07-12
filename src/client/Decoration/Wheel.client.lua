local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Wrapper = require(ReplicatedStorage.Packages.Wrapper)

local VELOCITY = 0.5

local function wrap(wheel: Model)
    
    if not wheel then return end

    local self = Wrapper(wheel)
    local PIVOT = wheel:GetPivot()

    local angle = 0

    self:_host(RunService.RenderStepped:Connect(function(deltaTime)

        angle += deltaTime
        wheel:PivotTo(PIVOT * CFrame.Angles(angle * VELOCITY, 0, 0))
    end))
end

wrap(CollectionService:GetTagged("HouseWheel")[1])
CollectionService:GetInstanceAddedSignal("HouseWheel"):Connect(wrap)