local function trait(self)

    self.velocity = self.velocity or 5

    local center = self.roblox:GetPivot()
    local angle = 0

    self:bindRenderStep(function(deltaTime: number)
        
        angle += deltaTime

        self:setCFrame(center * CFrame.Angles(0, angle * self.velocity/5, 0))
    end)
end

return trait