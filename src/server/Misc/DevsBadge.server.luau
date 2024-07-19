local BadgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")

local DEVS_BADGE = {
    ["LeoNidio_Jose"] = 4296938240461224;
    ["0xHaphy"] = 3438926931234883; 
}

local function trait(rbxPlayer: Player)

    local devsInGame = 0

    if DEVS_BADGE[rbxPlayer.Name] then
        for _,rbxPlayer2 in Players:GetPlayers() do
            if rbxPlayer2 == rbxPlayer then continue end

            trait(rbxPlayer2)
        end
    end

    for devName, badgeId in DEVS_BADGE do
        if not Players:FindFirstChild(devName) then
            continue
        end

        devsInGame += 1

        pcall(BadgeService.AwardBadge, BadgeService, rbxPlayer.UserId, badgeId)
    end

    if devsInGame == 2 then
        pcall(BadgeService.AwardBadge, BadgeService, rbxPlayer.UserId, 1642727754121972)
    end
end

for _,rbxPlayer in Players:GetPlayers() do
    trait(rbxPlayer)
end

Players.PlayerAdded:Connect(trait)