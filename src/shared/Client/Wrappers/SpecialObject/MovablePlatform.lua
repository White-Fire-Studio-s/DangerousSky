type Method<args...> = (args...) -> any
type MovablePlatform = {
    setCFrame: (self: any, newCFrame: CFrame) -> any;
    bindRenderStep: (self: any, callback: (deltaTime: number) -> any) -> () -> any;

    delay: number;
    time: number;

    roblox: BasePart & { Finish: BasePart };
}

local serverStartTime = workspace.Server:GetAttribute("startTime")

local function getCurrentFade(time, delay)
	
    local elapsedTime = os.time() - serverStartTime

	local cycleTime = 2 * (time + delay)
	local reaminingTime = elapsedTime % cycleTime
    local remainingDelay 
	
	local fade, inverse
	if reaminingTime <= delay then
		fade = 0
		inverse = reaminingTime < 0

        remainingDelay = delay - reaminingTime
	elseif reaminingTime < time + delay then
		fade = (reaminingTime - delay) / time
		inverse = false
    elseif reaminingTime >= time + delay and reaminingTime <= time + 2 * delay then
        fade = 1
		inverse = true

        remainingDelay = time + 2 * delay - reaminingTime
	else
		fade = (reaminingTime - cycleTime) / -time
		inverse = true
	end
	
	return fade, inverse, remainingDelay
end

local function trait(self: MovablePlatform)

    self.delay = self.delay or 2
    self.time = self.time or 5
    
    local start: CFrame = self.roblox.CFrame
    local finish: CFrame = self.roblox:WaitForChild("Finish").CFrame

    local fade, inverse, remainingDelay = getCurrentFade(self.time, self.delay)

    self.roblox.Finish:Destroy()

    local function unbind() 
    end
    local function setCFrame(deltaTime: number) 

        if self.time < 0 then return end

        fade = if inverse
            then math.max(fade - deltaTime/self.time, 0)
            else math.min(fade + deltaTime/self.time, 1) 

        self:setCFrame(finish:Lerp(start, fade))
    end
    local function updateMovement(deltaTime: number)

        if fade == 0 or fade == 1 then
            unbind()

            task.wait(remainingDelay or self.delay)

            inverse = not inverse

            fade = if inverse
                then fade - deltaTime/self.time
                else fade + deltaTime/self.time

            unbind = self:bindRenderStep(updateMovement)

            remainingDelay = nil

            return
        end

        setCFrame(deltaTime)
    end

    unbind = self:bindRenderStep(updateMovement)
end

return trait