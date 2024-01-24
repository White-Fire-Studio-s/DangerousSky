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
local Inventory = require(Wrappers._Player.Inventory)

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

    local roundStart

    self.timePerStage =  self.defaultTime / self.stageAmount

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
        roundStart = os.clock()
    end
    function self:restart()

        local roundEnded = os.clock()

        self.timer = self.timePerStage * self.stagesAmount
        self.timeDecrease = 1

        for _, stage in self.stages do
            stage:Destroy()
        end

        self.stages = table.create(self.stagesAmount)

        table.move(
            stageSelector.unavailable.common,
            1,
            #stageSelector.unavailable.common,
            #stageSelector.available.common + 1,
            stageSelector.available.common
        )

        table.move(
            stageSelector.unavailable.secret,
            1,
            #stageSelector.unavailable.secret,
            #stageSelector.available.secret + 1,
            stageSelector.available.secret
        )

        table.clear(stageSelector.unavailable.common)
        table.clear(stageSelector.unavailable.secret)

        table.clear(self.winners)
        self.winnersCount = 0

        self:resetPlayers()
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
        local lastStageTemplate

        for index = stagesLength + 1, stagesLength + amountToAdd do

            local isSecretStage = math.random() <= self.secretStagesRatio
            local stageBehavior = if isSecretStage 
                then StageBehavior.Secret
                else StageBehavior.Common

            local sample = stageSelector.available[stageBehavior]
            local unavailableStages = stageSelector.unavailable[stageBehavior]
            local hasSample = #sample > 0

            if not hasSample then
                table.move(unavailableStages, 1, #unavailableStages, 1, sample)
                table.clear(unavailableStages)
            end

            local randomNumber = math.random(1, #sample)
            local stageTemplate = sample[randomNumber]

            local stage = stageTemplate:Clone() :: Model
            stage:PivotTo(stageStart)

            stage:SetAttribute("name", stage.Name)
            stage:SetAttribute("start", stage.Start.Position)
            stage:SetAttribute("end", stage.End.Position)

            stage.ModelStreamingMode = Enum.ModelStreamingMode.Nonatomic

            stage.Name = index

            stage:AddTag("stage")
    
            stage.Parent = Stages
            
            self.stages[index] = stage

            table.insert(unavailableStages, stageTemplate)
            table.remove(sample, randomNumber)

            lastStage = stage
            stageStart = stage.End.CFrame
        end

        Stages:SetAttribute("start", self.stages[1].Start.Position)
        Stages:SetAttribute("end", lastStage.End.Position)
        Stages:SetAttribute("amount", #self.stages)

        Workspace.Finish:PivotTo(lastStage.End.CFrame)
    end
    function self:removeStages(amount: number)
        for _ = 1, amount do
            table.remove(self.stages):Destroy()
        end

        local lastStage = self.stages[#self.stages]
        Workspace.Finish:PivotTo(lastStage.End.CFrame)

        Stages:SetAttribute("end", lastStage.End.Position)
        Stages:SetAttribute("amount", #self.stages)
    end
    function self:resetPlayers(players: {Players}?)
        players = players or Players:GetPlayers()

        for _,rbxPlayer in players do
            local playerInventory = Inventory.get(rbxPlayer)
            local item = rbxPlayer.Character:FindFirstChildOfClass("Tool")
            if item then
                playerInventory:unequipItem(item)
            end

            rbxPlayer:LoadCharacter()
        end
    end
    function self:winner(rbxPlayer: Player)
        if self.winners[rbxPlayer] then
            return
        end
        local playerProfile = Profile.get(rbxPlayer)
        playerProfile.Clouds += 100
        playerProfile.Statistics.Wins += 1

        self.winners[rbxPlayer] = true
        self.winnersCount += 1

        local completionTime = os.clock() - roundStart

        if playerProfile.Statistics.BestTime > completionTime  then
            playerProfile.Statistics.BestTime = completionTime
        end

        self.timeDecrease = 2 ^ self.winnersCount
        self:resetPlayers({ rbxPlayer })
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