--// Packages
local MarketplaceService = game:GetService('MarketplaceService')
local HttpService = game:GetService('HttpService')
local Players = game:GetService('Players')

local wrapper = require(game.ReplicatedStorage.Packages.Wrapper)
local Cache = require(game.ReplicatedStorage.Packages.Cache)

local Promise = require(game.ReplicatedStorage.Packages.Promise)
type Promise<data... = ()> = any

local Replicator = require(game.ServerStorage.Packages.Replicator)

--// Module
local Product = {}
local products = Cache.new(-1, 'k')

--// Data

--// Factory
function Product.new(player: Player, productId: number, _container)

	local data = {
        queuedProcessIds = {},
	    purchaseIds = {},
	    receipts = {} :: {receipt},
    }
	local queuedProcessIds = data.queuedProcessIds
	local purchaseIds = data.purchaseIds
	local pendingPromise, pendingParams

	local container = Instance.new("Folder", _container)
	local self = wrapper(container, 'Product')

	--// Properties
	self.receipts = data.receipts
	self.id = productId

	self.purchased = self:_signal('purchased')
	self.process = function() error(`any processor setted for product {self.name}(#{self.id}) of player {player}`) end

	--// Product Info
	self.infoPromise = Promise.retry(MarketplaceService.GetProductInfo, -1,
		MarketplaceService, productId, Enum.InfoType.Product)
		:andThen(function(info)

			container.Name = info.Name

			self.minimunMembershipLevel = info.MinimunMembershipLevel
			self.iconId = info.IconImageAssetId
			self.description = info.Description
			self.isPublic = info.IsPublicDomain
			self.price = info.PriceInRobux
			self.name = info.Name
		end)

	--// Methods
	function self:bind(process: (params: { [string]: any }, receipt: Receipt) -> ())

		self.process = function(params, receipt)
			
			if params and params.targetId and params.targetId ~= player.UserId then
				
				local targetPlayer = game.Players:GetPlayerByUserId(params.targetId) or error(`target is offline`)
				local targetProduct = products:find(targetPlayer, productId) or error(`target market didnt loaded yet`)
				
				targetProduct:_awaitSaveReceipt(receipt)
			else
				
				process(params, receipt)
			end
		end
		for _,receiptId in queuedProcessIds do

			local receipt = self.receipts[receiptId]
			if not receipt then continue end

			self:processAsync(receipt)
		end
	end

	function self:complete(receipt: Receipt)

		local index = table.find(queuedProcessIds, receipt.id)
		if index then table.remove(queuedProcessIds, index) end

		receipt.processedTimestamp = os.time()
		return receipt
	end
	function self:processAsync(receipt: Receipt): Promise

		return Promise.try(self.process, receipt.params, receipt)
			:tap(function() self:complete(receipt) end)
			:catch(warn)
	end

	function self:_awaitSaveReceipt(receipt: Receipt)

		if self.receipts[receipt.id] then return end

		if not table.find(queuedProcessIds, receipt.id) then table.insert(queuedProcessIds, receipt.id) end
		self.receipts[receipt.id] = receipt
		
		--profile:Save() -- i think it doesnt save the data
		self:processAsync(receipt)
	end
	function self:awaitSavePurchase(rawReceipt)

		local promise = pendingPromise
		local purchaseReceiptId = purchaseIds[rawReceipt.PurchaseId] or HttpService:GenerateGUID()
		
		local receipt = self.receipts[purchaseReceiptId] or {
			placeId = rawReceipt.PlaceId or game.PlaceId,
			jobId = rawReceipt.JobId or game.JobId,
			currency = rawReceipt.CurrencyType.Name,
			purchaseId = rawReceipt.PurchaseId,
			productId = rawReceipt.ProductId,
			spent = rawReceipt.CurrencySpent,
			purchasedTimestamp = os.time(),
			purchaserId = player.UserId,
			processedTimestamp = nil,
			params = pendingParams,
			id = purchaseReceiptId,
		}
		purchaseIds[rawReceipt.PurchaseId] = receipt.id

		local success, error = pcall(function() self:_awaitSaveReceipt(receipt) end)
		
		if not promise then return end
		if success then promise:_resolve(receipt) else promise:_reject(error) end
	end

	function self:promptAsync(params: { [string]: any }): Promise<Receipt>

		assert(not pendingPromise, `a prompt already pending`)

		params = params or {}
		params.fromClient = params.fromClient or false
		params.promptTimestamp = os.time()

		local promise = Promise.try(MarketplaceService.PromptProductPurchase, MarketplaceService, player, productId)
			:andThen(coroutine.yield)

		pendingPromise = promise
		pendingParams = params
		promise:finally(function()

			pendingPromise = nil
			pendingParams = nil
		end)
		return promise
	end
	function self:getPendingPrompt(): Promise<Receipt>?

		return pendingPromise
	end

	--// Remotes
	local client = Replicator.get(container)
	function client.Prompt(player, params)

		assert(#game.HttpService:JSONEncode(params) < 1024, `data size limit reached (1kB)`)

		params.fromClient = true
		return self:promptAsync(params):expect()
	end

	--// End
	products:set(self, player, productId)
	return self
end
export type Product = typeof(Product.new(Instance.new("Player"), 0))

--// Functions
local isProcessing = {}
function MarketplaceService.ProcessReceipt(rawReceipt)

	if isProcessing[rawReceipt.PurchaseId] then return end
	isProcessing[rawReceipt.PurchaseId] = true

	local player = Players:GetPlayerByUserId(rawReceipt.PlayerId) or error(`player offline`)
	local playerProduct = products:find(player, rawReceipt.ProductId) or error(`product doesnt exists`)

	playerProduct:awaitSavePurchase(rawReceipt)
	isProcessing[rawReceipt.PurchaseId] = nil

	table.insert(_G.Purchases, `**{player.Name}** bought {playerProduct.name} (Product) **[{os.date("%X")}]**`)
	
	warn(_G.Purchases)

	return Enum.ProductPurchaseDecision.PurchaseGranted
end
MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId, productId, wasPurchased)

	if wasPurchased then return end

	local player = Players:GetPlayerByUserId(userId)
	if not player then return end

	local product = products:find(player, productId)
	if not product then return end

	local promise = product:getPendingPrompt()
	if promise then promise:cancel('prompt cancelled') end
end)

--// Types
export type receipt = {
	params: { promptTimestamp: number, fromClient: boolean } & { [string]: any },
	purchasedTimestamp: number,
	processedTimestamp: number,
	purchaseId: number,
	productId: number,
	currency: string,
	placeId: number,
	spent: number,
	id: string,
}
export type Receipt = receipt & {
	processAsync: (Receipt) -> Promise,
	complete: (Receipt) -> (),
}

--// End
return Product