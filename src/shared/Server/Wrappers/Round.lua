--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

--// Assets
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Stages = workspace:WaitForChild("Stages")
local StagesStorage = ServerStorage:WaitForChild("StagesStorage")

--// Imports
local Wrapper = require(Packages.Wrapper)
local Signal = require(Packages.Signal)

--// Constants
local STAGES_START_CFRAME = workspace:WaitForChild("StagesStart").CFrame
local DEFAULT_STAGE_AMOUNT = 10
local DEFAULT_TIME = 8 * 60

local REASON = DEFAULT_TIME / DEFAULT_STAGE_AMOUNT

return function(container: Configuration, data)
    local self = Wrapper(container)

    self.stagesAmount = data.stagesAmount or 10
    self.secretStagesRatio = data.secretStagesRatio or 1/100
    self.stages = table.create(self.stagesAmount)
    self.timeDecrease = 1

    local maxTimer = REASON * self.stagesAmount 
    self.timer = maxTimer

    --// Signals
    self.timerEnded = Signal.new("timerEnded")

    --// Methods
    function self:start()

        self:addStages()
        self:startCountdown()
    end
    function self:restart()

        self.timer = REASON *self.stagesAmount
        self.stages = table.create(self.stagesAmount)
        self.timeDecrease = 1

        self:resetPlayers()
        Stages:ClearAllChildren()

        self:start()
    end
    function self:startCountdown()

        self:_host(task.spawn(function()
            while self.timer > 0 do
                task.wait(1)
        
                self.timer = math.max(0, self.timer - self.timeDecrease)
            end

            self.timerEnded:_tryEmit()
        end))
    end
    function self:addStages(amount: number?)

        amount = amount or self.stagesAmount

        local stagesLength = #self.stages
    
        local stageStart = if stagesLength > 0 
            then self.stages[stagesLength].End.CFrame
            else STAGES_START_CFRAME

            
        for index = stagesLength + 1, stagesLength + amount do
            local isSecretStage = math.random() <= self.secretStagesRatio
            local stagesFolder = if isSecretStage 
                then StagesStorage.Secrets 
                else StagesStorage.Common
    
            local stage = stagesFolder:GetChildren()[math.random(#stagesFolder:GetChildren())]:Clone()
            stage.Parent = Stages
            stage:PivotTo(stageStart)
    
            self.stages[index] = stage
            stageStart = stage.End.CFrame
        end
    end
    function self:removeStages(amount: number)
        for _ = 1, amount do
            table.remove(self.stages):Destroy()
        end
    end

    function self:resetPlayers()
        for _,rbxPlayer in Players:GetPlayers() do
            rbxPlayer:LoadCharacter()
        end
    end

    self:listenChange("stagesAmount"):connect(function(newValue: number, lastValue: number)
        if lastValue > newValue then
            self:removeStages(lastValue - newValue)
        else
            self:addStages(newValue - lastValue)
        end

        self.timer = math.floor(self.timer / maxTimer * REASON * self.stagesAmount)
        maxTimer =  REASON * self.stagesAmount 
    end)

    return self
end