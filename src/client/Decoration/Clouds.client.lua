local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
--// Services

--// Constants
local SPAWN_RADIUS = 256;
local LIFETIME = 4 * 60;
local MAX_INCREASE = 256

--// Functions
local function createCloud(center: Vector3)

    local random = Random.new()

    local sizeX = math.random(30, 55)
	local sizeY = math.random(6, 12)
	local sizeZ = math.random(15, 25)

    local positionX = center.X + random:NextNumber(-SPAWN_RADIUS, SPAWN_RADIUS)
    local positionY = 85;
    local positionZ = center.Z + random:NextNumber(-SPAWN_RADIUS, SPAWN_RADIUS)

    local rbxCloud = Instance.new("Part")
    rbxCloud.CanCollide = false
    rbxCloud.CanQuery = false
    rbxCloud.CanTouch = false
    rbxCloud.Name = "Cloud"
    rbxCloud.Color = Color3.fromRGB(255, 255, 255)
    rbxCloud.Material = Enum.Material.SmoothPlastic
    rbxCloud.Transparency = 0.2
    rbxCloud.Anchored = true
    rbxCloud.Size = Vector3.new(sizeX, sizeY, sizeZ)
    rbxCloud.CFrame = CFrame.new(positionX, positionY, positionZ)

    rbxCloud.Parent = workspace

    --// Move
    local fade = 0
    local start = rbxCloud.CFrame
    local goal = start * CFrame.new(0, 0, -MAX_INCREASE)
    local tween;
    local lastUnit;

    task.delay(math.random(), function()
        RunService.RenderStepped:Connect(function(deltaTime)

            fade = math.min(fade + deltaTime/LIFETIME, 1)
    
            local characterCFrame = Players.LocalPlayer.Character:GetPivot()
            local relativeCenter = CFrame.new(center.X, positionY, characterCFrame.Z)
            local position = start:Lerp(goal, fade)
    
            local offset = position:ToObjectSpace(center)
            
            rbxCloud:PivotTo(position)

            if fade == 1 then
                fade = 0
            end
        end)
    end)
end

for i = 1, 50 do
    createCloud(workspace:WaitForChild("CloudStart"):GetPivot())
end