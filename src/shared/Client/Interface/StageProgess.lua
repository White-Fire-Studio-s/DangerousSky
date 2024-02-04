local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local RoundContainer = ReplicatedStorage:WaitForChild("Round")

local PlayerGui = Players.LocalPlayer.PlayerGui
local MainScreen = PlayerGui:WaitForChild("Main")
local Top = MainScreen:WaitForChild("Top")
local StageProgess = Top:WaitForChild("StageProgress")
local StageProgessPlayers = Top:WaitForChild("StageProgressPlayers")

local Stages = Workspace.Stages

local frames = {}

local oldStageAmount = RoundContainer:GetAttribute("stagesAmount")

local function updateColors()
    local stagesAmount = RoundContainer:GetAttribute("stagesAmount")
    if stagesAmount < oldStageAmount then
        for _ = 1, oldStageAmount - stagesAmount do
            table.remove(frames):Destroy()
        end
    end

    if Stages:GetAttribute("amount") ~= stagesAmount then
        Stages:GetAttributeChangedSignal("amount"):Wait()
    end

    local start: Vector3 = Stages:GetAttribute("start")
    local finish: Vector3 = Stages:GetAttribute("end")

    local totalDistance: number = (finish - start).Magnitude

    local function getSize(stage)
        local start = stage:GetAttribute("start")
        local _end = stage:GetAttribute("end")

        local distance = (_end - start).Magnitude

        return UDim2.fromScale(distance / totalDistance, 1)
    end

    for index = 1, stagesAmount do
        local stage = Stages:WaitForChild(tostring(index)) :: Model
        local stageColor = stage:GetAttribute("baseColor")

        local frame = frames[index] or Instance.new("Frame")
        frame.LayoutOrder = index
        frame.BackgroundColor3 = stageColor
        frame.BorderSizePixel = 0
        frame.Size = getSize(stage)
        frame.Parent = StageProgess
        
        frames[index] = frame
    end


    oldStageAmount = stagesAmount
end

local function insertPlayer(rbxPlayer: Player)
    local template = StageProgessPlayers.Template:Clone()

    local playerImage = Players:GetUserThumbnailAsync(rbxPlayer.UserId,
        Enum.ThumbnailType.HeadShot,
        Enum.ThumbnailSize.Size180x180
    )

    template.Parent = StageProgessPlayers
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
        if not rbxCharacter.PrimaryPart then return end

        local start: Vector3 = Stages:GetAttribute("start")
        local finish: Vector3 = Stages:GetAttribute("end")

        if not (start or finish) then
            return
        end

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