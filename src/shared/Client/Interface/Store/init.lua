local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StoreDisplay = require(script.StoreDisplay)
local StoreItem = require(script.StoreItem)

local StoreItemModel = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("StoreItem")

local GAMEPASSES = {
    --[729919308] = "rbxassetid://17687203106";
   -- [731024315] = "rbxassetid://17687207637";
   -- [730826338] = "rbxassetid://17687211315";
   -- [731206303] = "rbxassetid://17687214797";
    --[767864718] = "rbxassetid://17687218010";
}

local function createGamepassesStoreItem()

    for gamepassId, image in GAMEPASSES do

        local storeItem = StoreItemModel:Clone() :: TextButton

        local productInfo = MarketplaceService:GetProductInfo(gamepassId, Enum.InfoType.GamePass)

        storeItem:SetAttribute("DisplayName", productInfo.Name)
        storeItem:SetAttribute("DisplayPrice", productInfo.PriceInRobux);
        storeItem:SetAttribute("Type", "Gamepass")
        storeItem:SetAttribute("GamepassId", gamepassId)

        storeItem.ImageLabel.Image = image

        storeItem.Parent = Players.LocalPlayer.PlayerGui.Main.Store.Main.Gamepasses

        storeItem:AddTag("storeItem")
    end
end


return function ()

    task.spawn(createGamepassesStoreItem)

    for _, item in CollectionService:GetTagged("storeItem") do
        StoreItem(item)
    end

    CollectionService:GetInstanceAddedSignal("storeItem"):Connect(StoreItem)
end