local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local RoundContainer = ReplicatedStorage:WaitForChild("Round")

local PlayerGui = Players.LocalPlayer.PlayerGui
local MainScreen = PlayerGui:WaitForChild("Main")
local Top = MainScreen:WaitForChild("Top")
local StageProgess = Top:WaitForChild("StageProgress")

local Stages = Workspace.Stages

local frames = {}

local function updateColors()
    for frame in frames do
        frame:Destroy()
        frames[frame] = nil
    end

    local stagesAmount = RoundContainer:GetAttribute("stagesAmount")

    if Stages.lastStage.Value.Name ~= tostring(stagesAmount) then
        Stages.lastStage.Changed:Wait()
    end

    local firstStage = Stages.firstStage.Value
    local lastStage = Stages.lastStage.Value

    local start: Vector3 = firstStage:WaitForChild("Start").Position
    local finish: Vector3 = lastStage:WaitForChild("End").Position
    local totalDistance: number = (finish - start).Magnitude

    local function getSize(stage)
        local start = stage:WaitForChild("Start")
        local _end = stage:WaitForChild("End")

        local distance = (_end.Position - start.Position).Magnitude

        return UDim2.fromScale(distance / totalDistance, 1)
    end

    for index = 1, stagesAmount do
        local stage = Stages:WaitForChild(tostring(index)) :: Model
        local stageColor = stage:GetAttribute("baseColor")

        local frame = Instance.new("Frame")
        frame.LayoutOrder = index
        frame.BackgroundColor3 = stageColor
        frame.BorderSizePixel = 0
        frame.Parent = StageProgess
        frame.Size = getSize(stage)
        frames[frame] = true
    end
end

local function insertPlayer(rbxPlayer: Player)
    local template = StageProgess.Players.Template:Clone()

    local playerImage = Players:GetUserThumbnailAsync(rbxPlayer.UserId,
        Enum.ThumbnailType.HeadShot,
        Enum.ThumbnailSize.Size180x180
    )

    template.Parent = StageProgess.Players
    template.Background.Player.Image = playerImage
    template.Visible = true

    local connection;
    connection = RunService.Stepped:Connect(function()
        if not (rbxPlayer.Parent or rbxPlayer:IsDescendantOf(Players)) then
            template:Destroy()
            connection:Disconnect()

            return
        end 

        local rbxCharacter = rbxPlayer.Character
        if not rbxCharacter then return  end
        if not rbxPlayer.PrimaryPart then return end

        local firstStage = Stages.firstStage.Value
        local lastStage = Stages.lastStage.Value

        if not lastStage:FindFirstChild("Start") then
            return
        end

        if not lastStage:FindFirstChild("End") then
            return
        end

        local start: Vector3 = firstStage.Start.Position
        local finish: Vector3 = lastStage.End.Position

        local totalDistance: number = (finish - start).Magnitude

        local position = rbxCharacter.PrimaryPart.Position
        local distance = (position - finish).Magnitude
        local percent = math.clamp(distance/totalDistance, 0, 1)

        if position.Z <= finish.Z then
            percent = 0
        end
        
        template.Position = UDim2.fromScale(1-percent, 0)
    end)
end

return function () --// Init
    updateColors()

    RoundContainer:GetAttributeChangedSignal("stagesAmount"):Connect(updateColors)
    RoundContainer:GetAttributeChangedSignal("roundsCount"):Connect(updateColors)

    for _, rbxPlayer in Players:GetPlayers() do
        insertPlayer(rbxPlayer)
    end

    Players.PlayerAdded:Connect(insertPlayer)
end