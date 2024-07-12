opt server_output = "shared/Zap/Server.luau"
opt client_output = "shared/Zap/Client.luau"

opt casing = "camelCase"

event Teste = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		id: u8(2..10),
		name: string(3..20),
	},
}

event CollectOrb = {
	from: Client,
	type: Reliable,
	call: SingleAsync,
	data: struct {
		orb: Instance(Model),
		lifetime: u16(..500)
	}
}

event StorePurchase = {
	from: Client,
	type: Reliable,
	call: SingleAsync,
	data: struct {
		itemName: string(1..20),
		type: string(1..20)
	}
}

event DisplayMessage = {
	from: Server,
	type: Unreliable,
	call: SingleAsync,
	data: struct {
		Text: string(..50),
		Font: string(..20),
		Color: string(..6),
		FontSize: string(..2)
	}
}

event UnequipTools = {
	from: Client,
	type: Reliable,
	call: SingleAsync,
	data: struct {}
}

event JoinServer = {
	from: Client,
	type: Unreliable,
	call: SingleAsync,
	data: string(..5)
}