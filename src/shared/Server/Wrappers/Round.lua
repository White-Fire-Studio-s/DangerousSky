--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

--// Assets
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Wrappers = ReplicatedStorage.Server:WaitForChild("Wrappers")
local Stages = workspace:WaitForChild("Stages")
local StagesStorage = ServerStorage:WaitForChild("StagesStorage")

--// Imports
local Wrapper = require(Packages.Wrapper)
local Signal = require(Packages.Signal)
local Profile = require(Wrappers._Player.Profile)

--// Constants
local STAGES_START_CFRAME = workspace:WaitForChild("StagesStart").CFrame


local StageBehavior = table.freeze {
    Common = "common";
    Secret = "secret";
}

return function(container: Configuration, data)
    local self = Wrapper(container)
        :_applyAttributes(data)

    local stageSelector = {
        available = {
            common = StagesStorage.Common:GetChildren();
            secret = StagesStorage.Secrets:GetChildren();
        },
        unavailable = {
            common = {};
            secret = {};
        }
    }

    self.timePerStage =  self.defaultTime / self.stageAmount
    warn(self.timePerStage)

    self.stages = table.create(self.stagesAmount)
    self.timeDecrease = 1
    self.winnersCount = 0
    self.roundsCount = 0
    self.winners = setmetatable({}, { __mode = "k "})

    local maxTimer = self.timePerStage * self.stagesAmount
    self.timer = maxTimer

    --// Signals
    self.timerEnded = Signal.new("timerEnded")

    --// Methods
    function self:start()
        self:addStages()
        self:startCountdown()

        self.roundsCount += 1
    end
    function self:restart()

        self.timer = self.timePerStage * self.stagesAmount
        self.timeDecrease = 1

        self:resetPlayers()
        for _, stage in self.stages do
            stage:Destroy()
        end

        self.stages = table.create(self.stagesAmount)

        --[[table.move(
            stageSelector.unavailable.common,
            1,
            #stageSelector.unavailable.common,
            #stageSelector.available.common + 1,
            stageSelector.available.common
        )
        ]]
        table.move(
            stageSelector.unavailable.secret,
            1,
            #stageSelector.unavailable.secret,
            #stageSelector.available.secret + 1,
            stageSelector.available.secret
        )

        table.clear(self.winners)
        self.winnersCount = 0

        self:start()
    end
    function self:startCountdown()

        self:_host(task.spawn(function()
            while self.timer > 0 do
                task.wait(1/self.timeDecrease)
        
                self.timer = math.max(0, self.timer - 1)
            end

            self.timerEnded:_tryEmit()
        end))
    end
    function self:addStages(amountToAdd: number?)

        amountToAdd = amountToAdd or self.stagesAmount

        local stagesLength = #self.stages

        local stageStart = if stagesLength > 0 
            then self.stages[stagesLength].End.CFrame
            else STAGES_START_CFRAME
        
        local lastStage

        for index = stagesLength + 1, stagesLength + amountToAdd do

            local isSecretStage = math.random() <= self.secretStagesRatio
            local stageBehavior = if isSecretStage 
                then StageBehavior.Secret
                else StageBehavior.Common

            local sample = stageSelector.available[stageBehavior]
            local unavailableStages = stageSelector.unavailable[stageBehavior]

            if #sample == 0 then
                table.move(unavailableStages, 1, #unavailableStages, #sample + 1, sample)
                table.clear(unavailableStages)
            end

            local randomNumber = math.random(1, #sample)
            local stageTemplate = sample[randomNumber]

            local stage = stageTemplate:Clone()
            stage.Parent = Stages
            stage:PivotTo(stageStart)
            stage.Name = index
    
            self.stages[index] = stage

            table.insert(unavailableStages, stageTemplate)
            table.remove(sample, randomNumber)

            lastStage = stage
            stageStart = stage.End.CFrame
        end

        Stages.firstStage.Value = self.stages[1]
        Stages.lastStage.Value = lastStage

        Workspace.Finish:PivotTo(lastStage.End.CFrame)
    end
    function self:removeStages(amount: number)
        for _ = 1, amount do
            table.remove(self.stages):Destroy()
        end

        local lastStage = self.stages[#self.stages]
        Workspace.Finish:PivotTo(lastStage.End.CFrame)
        Workspace.Stages.lastStage.Value = lastStage
    end
    function self:resetPlayers()

        for _,rbxPlayer in Players:GetPlayers() do
            rbxPlayer:LoadCharacter()
        end
    end
    function self:winner(rbxPlayer: Player)
        if self.winners[rbxPlayer] then
            return
        end
        local playerProfile = Profile.get(rbxPlayer)
        playerProfile.Clouds += 100

        self.winners[rbxPlayer] = true
        self.winnersCount += 1

        self.timeDecrease = 2 ^ self.winnersCount
        rbxPlayer:LoadCharacter()
    end

    self:listenChange("stagesAmount"):connect(function(newValue: number, lastValue: number)
        if lastValue > newValue then
            self:removeStages(lastValue - newValue)
        else
            self:addStages(newValue - lastValue)
        end

        self.timer = math.floor(self.timer / maxTimer * self.timePerStage * self.stagesAmount)
        maxTimer =  self.timePerStage * self.stagesAmount 
    end)

    local prompt = Workspace.Finish:FindFirstChild("ProximityPrompt", true)
    prompt.Triggered:Connect(function(rbxPlayer: Players)
        self:winner(rbxPlayer)
    end)

    return self
end