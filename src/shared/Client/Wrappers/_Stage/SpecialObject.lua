--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--// Assets
local _Stages = script.Parent

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Client = ReplicatedStorage:WaitForChild("Client")

--// Imports
local Wrapper = require(Packages.Wrapper)

--// Constants
local TRAITS = {
    rotatablePlatform = require(_Stages.RotatablePlatform);
    movablePlatform = require(_Stages.MovablePlatform)
}

--// Vars
local player = Players.LocalPlayer
local shallows = setmetatable({}, { __mode = "v" })

--// Wrapper
local SpecialObject = {}

local function disableAppearance(object: BasePart)

    for _, object in object:GetChildren() do
        disableAppearance(object)
    end

    if object:IsA("BasePart") then
        object.Transparency = 1
        object.CanQuery = false
        object.CanTouch = false
        object.CanCollide = false

        return
    end

    if object:IsA("Texture") then
        object.Transparency = 1
    end
end

function SpecialObject.wrap(object: BasePart, kinds: {string})

    --// Shallow creator
    local shallow = object:Clone()
    shallow.Parent = workspace.SpecialObjects.Shallow

    task.defer(function()
        disableAppearance(object)

        object.ChildAdded:Connect(function(child)
            local clone = child:Clone()
            clone.Parent = shallow

            disableAppearance(child)
        end)
    end)

    --// Wrapper
    local self = Wrapper(shallow)
    self.playerRange = self.playerRange or 11.8

    local params = OverlapParams.new()
    params.FilterDescendantsInstances = setmetatable(
        { Players.LocalPlayer.Character },
        { __mode = "v" }
    )
    params.FilterType = Enum.RaycastFilterType.Include
    params.MaxParts = 1

    local hitboxSize = object.Size * Vector3.new(1.01, 1.01, 1.01)

    function self:setCFrame(newCFrame: CFrame)

        local lastCFrame = shallow.CFrame
        
        shallow:PivotTo(newCFrame)
        
        if params.FilterDescendantsInstances[1] then
            local playerOffset = lastCFrame:ToObjectSpace(player.Character:GetPivot())
            
            if workspace:GetPartBoundsInBox(lastCFrame, hitboxSize, params)[1] then
                player.Character:PivotTo(shallow.CFrame * playerOffset)
            end
        end
    end
    function self:bindRenderStep(callback: (number) -> any)

        local id = tostring(callback)

        RunService:BindToRenderStep(id, 1, callback)

        local function unbindRenderStep()
            RunService:UnbindFromRenderStep(id)
        end

        local cancelCleaner = self:cleaner(unbindRenderStep)

        --// Unbind
        return function()
           return cancelCleaner(), unbindRenderStep()
        end
    end
    function self:trait(kind: string)

        if not TRAITS[kind] then return end

        TRAITS[kind](self)
    end

    --// Loader
    for _,kind in kinds do self:trait(kind) end

    shallows[object] = shallow
end

function SpecialObject.findShallow(object: BasePart)

    return shallows[object]
end

return SpecialObject