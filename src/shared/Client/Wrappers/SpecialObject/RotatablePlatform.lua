local function trait(self)

    self.velocity = self.velocity or 5

    local center = if self.roblox:FindFirstChild("Center")
        then self.roblox.Center.CFrame
        else self.roblox:GetPivot()
        
    local angle = workspace.DistributedGameTime

    self:bindRenderStep(function(deltaTime: number)
        angle += deltaTime

        self:setCFrame(center * CFrame.Angles(0, angle  * self.velocity/5, 0))
    end)
end

return trait