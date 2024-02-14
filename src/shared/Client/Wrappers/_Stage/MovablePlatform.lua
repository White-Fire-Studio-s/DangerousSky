

type Method<args...> = (args...) -> any
type MovablePlatform = {
    setCFrame: (self: any, newCFrame: CFrame) -> any;
    bindRenderStep: (self: any, callback: (deltaTime: number) -> any) -> () -> any;
    trait: (self: any, kind: string) -> any;

    delay: number;
    time: number;
    playerRange: number;

    roblox: BasePart & { Finish: BasePart };
}

local function trait(self: MovablePlatform)

    self.delay = self.delay or 2
    self.time = self.time or 5
    
    self.playerRange = 8

    local fade = 0
    local inverse = true
    local start: CFrame = self.roblox.CFrame
    local finish: CFrame = self.roblox:GetPivot()
 
    local function unbind() 
    end
    local function setCFrame(deltaTime: number) 

        if self.time < 0 then return end

        fade = if inverse
            then math.max(fade - deltaTime/self.time, 0)
            else math.min(fade + deltaTime/self.time, 1) 

        self:setCFrame(finish:Lerp(start, -fade))
    end
    local function updateMovement(deltaTime: number)

        if fade == 0 or fade == 1 then
            unbind()

            task.wait(self.delay)
            local isWrapped = pcall(function() return self.time end)
            if not isWrapped then return end

            inverse = not inverse

            fade = if inverse
                then fade - deltaTime/self.time
                else fade + deltaTime/self.time

            unbind = self:bindRenderStep(updateMovement)

            return
        end

        setCFrame(deltaTime)
    end

    unbind = self:bindRenderStep(updateMovement)
end

return trait