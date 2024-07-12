local RunService = game:GetService("RunService")

if RunService:IsClient() then
    return require(script.Client)
end

return require(script.Server)