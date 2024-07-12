local RunService = game:GetService("RunService")

type Conveyor = {
    velocity: number;
    roblox: BasePart & { Finish: BasePart };
    _host: (self: any, any) -> (any);
    listenChange: (self: any, string) -> any
}

local function waitForChildOfClass(object: Instance, class: string)

    local running = coroutine.running()

    local connection; 
    connection = object.ChildAdded:Connect(function(child)
        if child:IsA(class) then
            connection:Disconnect()

            task.spawn(running, child)
        end
    end)

    return coroutine.yield()
end

local function getChildOfClassAsync(object: Instance, class: string)

    return object:FindFirstChildOfClass(class) 
        or waitForChildOfClass(object, class)
end

local function trait(self: Conveyor)

    self.velocity = self.velocity or 5

    local texture = getChildOfClassAsync(self.roblox, "Texture")
    local rbxConveyor = self.roblox

    assert(texture)

    self:_host(RunService.RenderStepped:Connect(function()
        texture.OffsetStudsV = -(os.clock() * self.velocity) 
            % texture.StudsPerTileV
    end))

    rbxConveyor.AssemblyLinearVelocity = rbxConveyor.CFrame.LookVector * self.velocity

    self:_host(self:listenChange("velocity"):connect(function()
        rbxConveyor.AssemblyLinearVelocity = rbxConveyor.CFrame.LookVector * self.velocity
    end))
end

return trait