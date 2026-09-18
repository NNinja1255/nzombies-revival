AddCSLuaFile( )

ENT.Type = "anim"

ENT.PrintName		= "random_box"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Open" )

end

function ENT:Initialize()

	self:SetModel( "models/hoff/props/mysterybox/box.mdl" )
	self:PhysicsInit( SOLID_NONE )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )

	--[[local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end]]

	self:DrawShadow( false )
	--self:AddEffects( EF_ITEM_BLINK )
	self:SetOpen(false)
	self.Moving = false
	self:Activate()
	if SERVER then
		self:SetUseType( SIMPLE_USE )
	end
	
	if CLIENT then
		self.Light = ClientsideModel("models/effects/vol_light128x512.mdl")
		local ang = self:GetAngles()
		self.Light:SetAngles(Angle(0, ang[2], 180))
		self.Light:SetPos(self:GetPos() - Vector(0,0,50))
		--self.Light:SetParent(self)
		self.Light:SetColor(Color(150,200,255))
		self.Light:DrawShadow(false)
		local min, max = self.Light:GetRenderBounds()
		self.Light:SetRenderBounds(Vector(min.x, min.y, min.z), Vector(max.x, max.y, max.z*10))
		
		local scale = Vector( 1, 1, 5 )
		local mat = Matrix()
		mat:Scale( scale )
		self.Light:EnableMatrix( "RenderMultiply", mat )
		
		self.Light:Spawn()
	end
end

function ENT:Use( activator, caller )
	if self.Moving then return end
	if self:GetOpen() == true then
		self.WindupEnt:Use(activator, caller)
		return
	end
	self:BuyWeapon(activator)
	-- timer.Simple(5,function() self:MoveAway() end)
end

function ENT:BuyWeapon(ply)
	ply:Buy(nzPowerUps:IsPowerupActive("firesale") and 10 or 950, self, function()
        local class = nzRandomBox.DecideWep(ply)
        if class != nil then
      		--ply:TakePoints(nzPowerUps:IsPowerupActive("firesale") and 10 or 950)
      		self:Open()
      		local wep = self:SpawnWeapon( ply, class )
			wep.Buyer = ply
			return true
        else
            ply:PrintMessage( HUD_PRINTTALK, "No available weapons left!")
			return false
        end
	end)
end


function ENT:Open()
	local sequence = self:LookupSequence("open")
	self:ResetSequence(sequence)
	--self:RemoveEffects( EF_ITEM_BLINK )
	
	self:EmitSound("nzu/mysterybox/open.wav")

	self:SetOpen(true)
end

function ENT:Close()
	local sequence = self:LookupSequence("close")
	self:ResetSequence(sequence)
	--self:AddEffects( EF_ITEM_BLINK )
	
	self:EmitSound("nzu/mysterybox/close.wav")

	self:SetOpen(false)
end

function ENT:SpawnWeapon(activator, class)
	local wep = ents.Create("random_box_windup")
	wep:SetAngles( self:GetAngles() )
	wep:SetPos( self:GetPos() + self:GetUp()*8 )
	wep:SetWepClass(class)
	wep:Spawn()
	wep.Buyer = activator
	--wep:SetParent( self )
	wep.Box = self
	self.WindupEnt = wep
	--wep:SetAngles( self:GetAngles() )
	self:EmitSound("nzu/mysterybox/music_box.wav")

	return wep
end

function ENT:Think()
	self:NextThink(CurTime())
	
	if self.MarkedForRemoval and !self:GetOpen() then
		self:Remove()
	end
	
	return true
end

function ENT:MoveAway()
	nzNotifications:PlaySound("nz/randombox/Announcer_Teddy_Zombies.wav", 0)
	self.Moving = true
	self:SetSolid(SOLID_NONE)
	local s = 0
	local ang = self:GetAngles()
	
	local sequence = self:LookupSequence("leave")
	self:ResetSequence(sequence)
	self:SetNotSolid(true)
	self:CollisionRulesChanged()
	timer.Simple(self:SequenceDuration(), function()
		self.Moving = false
		self.SpawnPoint.Box = nil
		self:MoveToNewSpot(self.SpawnPoint)
		self:EmitSound("nz/randombox/poof.wav")
		self:Remove()
	end)
	
end

function ENT:MoveToNewSpot(oldspot)
	-- Calls mapping function excluding the current spot
	nzRandomBox.Spawn(oldspot)
end

function ENT:MarkForRemoval()
	self.MarkedForRemoval = true
	--[[if !self:GetOpen() then
		self:Remove()
	else
		hook.Add("Think", "RemoveBox"..self:EntIndex(), function()
			if !IsValid(self) or !self:GetOpen() then
				hook.Remove("Think", "RemoveBox"..self:EntIndex())
				self:Remove()
			end
		end)
	end]]
end

function ENT:UpdateTransmitState()
	return self.Moving and TRANSMIT_PVS or TRANSMIT_ALWAYS
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end

	--[[hook.Add( "PostDrawOpaqueRenderables", "random_box_beam", function()
		for k,v in pairs(ents.FindByClass("random_box")) do
			if ( LocalPlayer():GetPos():Distance( v:GetPos() ) ) > 750 then
				local Vector1 = v:GetPos() + Vector( 0, 0, -200 )
				local Vector2 = v:GetPos() + Vector( 0, 0, 5000 )
				render.SetMaterial( Material( "cable/redlaser" ) )
				render.DrawBeam( Vector1, Vector2, 300, 1, 1, Color( 255, 255, 255, 255 ) )
			end
		end
	end )]]

end

function ENT:OnRemove()
	if CLIENT then
		if IsValid(self.Light) then
			self.Light:Remove()
		end
	else
		if IsValid(self.SpawnPoint) then
			--self.SpawnPoint.Box = nil
			self.SpawnPoint:SetBodygroup(1,0)
		end
	end
end
