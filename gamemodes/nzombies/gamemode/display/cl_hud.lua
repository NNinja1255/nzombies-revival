-- 
nzDisplay = nzDisplay or AddNZModule("Display")

local bloodline_points = Material("bloodline_score2.png", "unlitgeneric smooth")
local bloodline_gun = Material("cod_hud.png", "unlitgeneric smooth")

local drawhud = cvars.Bool("cl_drawhud")
cvars.AddChangeCallback( "cl_drawhud", function(cvar, old, new) drawhud = tobool(new) end )

--[[local bloodDecals = {
	Material("decals/blood1"),
	Material("decals/blood2"),
	Material("decals/blood3"),
	Material("decals/blood4"),
	Material("decals/blood5"),
	Material("decals/blood6"),
	Material("decals/blood7"),
	Material("decals/blood8"),
	nil
}]]

if GetConVar("nz_hud_points_show_names") == nil then
	CreateClientConVar( "nz_hud_points_show_names", "1", true, false )
end

if GetConVar("nz_hud_show_health") == nil then
	CreateClientConVar( "nz_hud_show_health", "1", true, false )
end

if GetConVar("nz_hud_show_health_mp") == nil then
	CreateClientConVar( "nz_hud_show_health_mp", "0", true, false )
end

local function StatesHud()
	if !drawhud then return end
	
	local text = ""
	local font = "nz.display.hud.main"
	local w = ScrW() / 2
	if nzRound:InState( ROUND_WAITING ) then
		text = "Waiting for players. Type /ready to ready up."
		font = "nz.display.hud.small"
	elseif nzRound:InState( ROUND_CREATE ) then
		text = "Creative Mode"
	elseif nzRound:InState( ROUND_GO ) then
		text = "Game Over"
	end
	draw.SimpleText(text, font, w, ScrH() * 0.85, Color(200, 0, 0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local tbl = {Entity(3), Entity(1), Entity(3), Entity(4), Entity(5)}

local function ScoreHud()
	if !drawhud then return end
	if !nzRound:InProgress() then return end
	
	local scale = (ScrW() / 1920 + 1) / 2
	local offset = 0

	for k,v in ipairs(player.GetAll()) do
		local hp = v:Health()
		local maxhp = v:GetMaxHealth()
		local hpscale = math.Clamp(hp / maxhp, 0, 1)
		--if hp == 0 then hp = "Dead" elseif nzRevive.Players[v:EntIndex()] then hp = "Downed" else hp = hp .. " HP"  end
		if v:GetPoints() >= 0 then

			local text = ""
			local nameoffset = 0
			if GetConVar("nz_hud_points_show_names"):GetBool() then
				local nick
				if #v:Nick() >= 20 then
					nick = string.sub(v:Nick(), 1, 20)  -- limit name to 20 chars
				else
					nick = v:Nick()
				end
				text = nick
				nameoffset = 10
			end

			local font = "nz.display.hud.small"

			surface.SetFont(font)

			local textW, textH = surface.GetTextSize(text)

			if LocalPlayer() == v then
				offset = offset + textH + 5 -- change this if you change the size of nz.display.hud.medium
			else
				offset = offset + textH
			end

			--surface.SetDrawColor(200,200,200)
			local index = v:EntIndex()
			local color = player.GetColorByIndex(v:EntIndex())
			local blood = player.GetBloodByIndex(v:EntIndex())
			--for i = 0, 8 do
				--surface.SetMaterial(bloodDecals[((index + i - 1) % #bloodDecals) + 1 ])
				surface.SetMaterial(blood)
				if GetConVar("nz_hud_show_health"):GetBool() and (GetConVar("nz_hud_show_health_mp"):GetBool() or LocalPlayer() == v) then
					if hp == 0 or nzRevive.Players[v:EntIndex()] then
						surface.SetDrawColor(0,0,0)
					else
						surface.SetDrawColor(100,100,100)
					end
					surface.DrawTexturedRect(ScrW() - textW - 180, ScrH() - 275 * scale - offset, textW + 150, 45)
					if hp ~= 0 then
						if nzRevive.Players[v:EntIndex()] then
							surface.SetDrawColor(100,100,100)
						else
							surface.SetDrawColor(200,200,200)
						end
						surface.DrawTexturedRectUV(ScrW() - textW - 180, ScrH() - 275 * scale - offset, (textW + 150)*hpscale, 45, 0, 0, hpscale, 1)
					end
				else
					surface.SetDrawColor(200,200,200)
					surface.DrawTexturedRect(ScrW() - textW - 180, ScrH() - 275 * scale - offset, textW + 150, 45)
				end
			--end
			--surface.DrawTexturedRect(ScrW() - 325*scale - numname * 10, ScrH() - 285*scale - (30*k), 250 + numname*10, 35)
			if text then draw.SimpleText(text, font, ScrW() - textW - 60, ScrH() - 255 * scale - offset, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end
			if LocalPlayer() == v then
				font = "nz.display.hud.medium"
			end
			draw.SimpleText(v:GetPoints(), font, ScrW() - textW - 60 - nameoffset, ScrH() - 255 * scale - offset, color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			v.PointsSpawnPosition = {x = ScrW() - textW - 170, y = ScrH() - 255 * scale - offset}
		end
	end
end

local function GunHud()
	if !drawhud then return end
	if LocalPlayer():IsNZMenuOpen() then return end
	local wep = LocalPlayer():GetActiveWeapon()
	local w,h = ScrW(), ScrH()
	local scale = ((w/1920)+1)/2

	surface.SetMaterial(bloodline_gun)
	surface.SetDrawColor(200,200,200)
	surface.DrawTexturedRect(w - 630*scale, h - 225*scale, 600*scale, 225*scale)
	
	if IsValid(wep) then
		if wep:GetClass() == "nz_multi_tool" then
			draw.SimpleTextOutlined(nzTools.ToolData[wep.ToolMode].displayname or wep.ToolMode, "nz.display.hud.small", w - 240*scale, h - 125*scale, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, color_black)
			draw.SimpleTextOutlined(nzTools.ToolData[wep.ToolMode].desc or "", "nz.display.hud.smaller", w - 240*scale, h - 90*scale, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 2, color_black)
		else
			local name = wep:GetPrintName()					
			local x = 250
			local y = 165
			if wep:GetPrimaryAmmoType() != -1 then
				local clip
				if wep.Primary.ClipSize and wep.Primary.ClipSize != -1 then
					draw.SimpleTextOutlined("/"..wep:Ammo1(), "nz.display.hud.ammo2", ScrW() - 310*scale, ScrH() - 120*scale, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 2, color_black)
					clip = wep:Clip1()
					x = 315
					y = 155
				else
					clip = wep:Ammo1()
				end
				draw.SimpleTextOutlined(clip, "nz.display.hud.ammo", ScrW() - x*scale, ScrH() - 115*scale, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, color_black)
				x = x + 80
			end
			
			draw.SimpleTextOutlined(name, "nz.display.hud.small", ScrW() - x*scale, ScrH() - 120*scale, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, color_black)
			
			x = 270
			if wep:GetSecondaryAmmoType() != -1 then
				local clip
				if wep.Secondary.ClipSize and wep.Secondary.ClipSize != -1 then
					draw.SimpleTextOutlined("/"..wep:Ammo2(), "nz.display.hud.ammo4", ScrW() - x*scale, ScrH() - y*scale, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 2, color_black)
					clip = wep:Clip2()
					x = x + 3
				else
					clip = wep:Ammo2()
				end
				draw.SimpleTextOutlined(clip, "nz.display.hud.ammo3", ScrW() - x*scale, ScrH() - y*scale, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, color_black)
				x = x + 80
			end
			
			--[[if clip >= 0 then
				draw.SimpleTextOutlined(name, "nz.display.hud.small", ScrW() - 390*scale, ScrH() - 120*scale, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0))
				draw.SimpleTextOutlined(clip, "nz.display.hud.ammo", ScrW() - 315*scale, ScrH() - 115*scale, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0))
				draw.SimpleTextOutlined("/"..wep:Ammo1(), "nz.display.hud.ammo2", ScrW() - 310*scale, ScrH() - 120*scale, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0))
			else
				draw.SimpleTextOutlined(name, "nz.display.hud.small", ScrW() - 250*scale, ScrH() - 120*scale, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, color_black)
			end]]
		end
	end
end

local powerupicons = {
	["dp"] = Material("powerups/powerup_double_points.png", "unlitgeneric smooth"),
	["insta"] = Material("powerups/powerup_insta_kill.png", "unlitgeneric smooth"),
	["firesale"] = Material("powerups/powerup_firesale.png", "unlitgeneric smooth"),
	["papfiresale"] = Material("powerups/powerup_pap_firesale.png", "unlitgeneric smooth"),
	["death_machine"] = Material("powerups/powerup_death_machine.png", "unlitgeneric smooth"),
	["zombie_blood"] = Material("powerups/powerup_zombie_blood.png", "unlitgeneric smooth")
}
local powerdownicons = {
	["insta"] = Material("powerups/powerup_insta_kill.png", "unlitgeneric smooth"),
	["pricegouge"] = Material("powerups/powerup_firesale.png", "unlitgeneric smooth"),
	["pappricegouge"] = Material("powerups/powerup_pap_firesale.png", "unlitgeneric smooth")
}
local function PowerUpsHud()
	if nzRound:InProgress() or nzRound:InState(ROUND_CREATE) then
		----------timer-------------
		local font = "nz.display.hud.main"
		local text_w = 745
		---------icon--------------
		if !nzPowerUps.ActivePlayerPowerUps[LocalPlayer()] then nzPowerUps.ActivePlayerPowerUps[LocalPlayer()] = {} end
		
		local centerw = ScrW()/2
		local posy = ScrH() - 98
		local posy2 = ScrH() - 120
		local size = 64
		local scale = ScrW()/1920
		local gap = 16
		local iconstodraw = table.Count(nzPowerUps.ActivePowerUps) + table.Count(nzPowerUps.ActivePlayerPowerUps[LocalPlayer()])
		
		local iconsdrawn = 0
		for k,v in pairs(nzPowerUps.ActivePowerUps) do
			if !powerupicons[k] then continue end
			surface.SetMaterial(powerupicons[k])
			surface.SetDrawColor(255,255,255)
			local posw = centerw - (size+gap)*iconstodraw/2 + (size+gap)*iconsdrawn
			surface.DrawTexturedRect( posw, posy, size*scale, size*scale )
			draw.SimpleText(math.Round(v - CurTime()), font, posw + size*scale/2, posy2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			iconsdrawn = iconsdrawn + 1
		end
		for k,v in pairs(nzPowerUps.ActivePlayerPowerUps[LocalPlayer()]) do
			if !powerupicons[k] then continue end
			surface.SetMaterial(powerupicons[k])
			surface.SetDrawColor(255,255,255)
			local posw = centerw - (size+gap)*iconstodraw/2 + (size+gap)*iconsdrawn
			surface.DrawTexturedRect( posw, posy, size*scale, size*scale )
			draw.SimpleText(math.Round(v - CurTime()), font, posw + size*scale/2, posy2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			iconsdrawn = iconsdrawn + 1
		end
		
		----------powerdowns----------
		if nzPowerDowns then
			local posy3 = ScrH() - 200
			local posy4 = ScrH() - 222
			local scale = ScrW()/1920
			local iconstodraw2 = table.Count(nzPowerDowns.ActivePowerDowns)
			
			local iconsdrawn2 = 0
			for k,v in pairs(nzPowerDowns.ActivePowerDowns) do
				if !powerdownicons[k] then continue end
				surface.SetMaterial(powerdownicons[k])
				surface.SetDrawColor(255,127,127)
				local posw = centerw - (size+gap)*iconstodraw2/2 + (size+gap)*iconsdrawn2
				surface.DrawTexturedRect( posw, posy3, size*scale, size*scale )
				draw.SimpleText(math.Round(v - CurTime()), font, posw + size*scale/2, posy4, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				iconsdrawn = iconsdrawn + 1
			end
		end
	end
end

local Laser = Material( "cable/redlaser" )
function nzDisplay.DrawLinks( ent, link )

	local tbl = {}
	-- Check for zombie spawns
	for k, v in pairs(ents.GetAll()) do
		if v:IsBuyableProp()  then
			if nzDoors.PropDoors[k] != nil then
				if v.link == link then
					table.insert(tbl, Entity(k))
				end
			end
		elseif v:IsDoor() then
			if nzDoors.MapDoors[v:doorIndex()] != nil then
				if nzDoors.MapDoors[v:doorIndex()].link == link then
					table.insert(tbl, v)
				end
			end
		elseif v:GetClass() == "nz_spawn_zombie_normal" then
			if v:GetLink() == link then
				table.insert(tbl, v)
			end
		end
	end


	--  Draw
	if tbl[1] != nil then
		for k,v in pairs(tbl) do
			render.SetMaterial( Laser )
			render.DrawBeam( ent:GetPos(), v:GetPos(), 20, 1, 1, color_white )
		end
	end
end

local PointsNotifications = {}
local function PointsNotification(ply, amount)
	if !IsValid(ply) then return end
	local data = {ply = ply, amount = amount, diry = math.random(-20, 20), time = CurTime()}
	table.insert(PointsNotifications, data)
	--PrintTable(data)
end

net.Receive("nz_points_notification", function()
	local amount = net.ReadInt(20)
	local ply = net.ReadEntity()

	PointsNotification(ply, amount)
end)

local function DrawPointsNotification()

	if GetConVar("nz_point_notification_clientside"):GetBool() then
		for k,v in pairs(player.GetAll()) do
			if v:GetPoints() >= 0 then
				if !v.LastPoints then v.LastPoints = 0 end
				if v:GetPoints() != v.LastPoints then
					PointsNotification(v, v:GetPoints() - v.LastPoints)
					v.LastPoints = v:GetPoints()
				end
			end
		end
	end

	local font = "nz.display.hud.points"

	for k,v in pairs(PointsNotifications) do
		local fade = math.Clamp((CurTime()-v.time), 0, 1)
		if !v.ply.PointsSpawnPosition then return end
		if v.amount >= 0 then
			draw.SimpleText(v.amount, font, v.ply.PointsSpawnPosition.x - 50*fade, v.ply.PointsSpawnPosition.y + v.diry*fade, Color(255,255,0,255-255*fade), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText(v.amount, font, v.ply.PointsSpawnPosition.x - 50*fade, v.ply.PointsSpawnPosition.y + v.diry*fade, Color(255,0,0,255-255*fade), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		end
		if fade >= 1 then
			table.remove(PointsNotifications, k)
		end
	end
end

local function PerksHud()
	local scale = (ScrW()/1920 + 1)/1.75
	local w = 175
	local size = 45
	local rank = -58
	local rank_check = 0
	local rank_mult = 0
	for k,v in pairs(LocalPlayer():GetPerks()) do
		surface.SetMaterial(nzPerks:Get(v).icon)
		surface.SetDrawColor(255,255,255)
		surface.DrawTexturedRect(w + k*(size*scale + 1), ScrH() - 75 + rank*rank_mult, size*scale, size*scale)
		rank_check = rank_check + 1
		if rank_check == 7 then
			rank_mult = rank_mult + 1
			w = w - k*(size*scale + 1)
		end
	end
end

local vulture_textures = {
	["wall_buys"] = Material("vulture_icons/wall_buys.png", "smooth unlitgeneric"),
	["random_box"] = Material("vulture_icons/random_box.png", "smooth unlitgeneric"),
	["wunderfizz_machine"] = Material("vulture_icons/wunderfizz.png", "smooth unlitgeneric"),
}



local function VultureVision()
	if !LocalPlayer():HasPerk("vulture") then return end
	local scale = (ScrW()/1920 + 1.5)/1.75

	for k,v in pairs(ents.FindInSphere(LocalPlayer():GetPos(), 700)) do
		local target = v:GetClass()
		if vulture_textures[target] then
			local data = v:WorldSpaceCenter():ToScreen()
			if data.visible then
				surface.SetMaterial(vulture_textures[target])
				surface.SetDrawColor(255,255,255,150)
				surface.DrawTexturedRect(data.x - 15*scale, data.y - 15*scale, 30*scale, 30*scale)
			end
		elseif target == "perk_machine" then
			local data = v:WorldSpaceCenter():ToScreen()
			if data.visible then
				local icon = nzPerks:Get(v:GetPerkID()).icon
				if icon then
					surface.SetMaterial(icon)
					surface.SetDrawColor(255,255,255,150)
					surface.DrawTexturedRect(data.x - 15*scale, data.y - 15*scale, 30*scale, 30*scale)
				end
			end
		end
	end
end

local round_white = 0
local round_alpha = 255
local round_num = 0
local infmat = Material("materials/round_-1.png", "smooth")
local function RoundHud()

	local text = ""
	local font = "nz.display.hud.rounds"
	local w = 35
	local h = ScrH() - 15
	local round = round_num
	local col = Color(200 + round_white*55, round_white, round_white,round_alpha)
	if round == -1 then
		--text = "∞"
		surface.SetMaterial(infmat)
		surface.SetDrawColor(col.r,round_white,round_white,round_alpha)
		surface.DrawTexturedRect(w - 25, h - 100, 200, 100)
		return
	elseif round < 6 then
		for i = 1, round do
			if i == 5 or i == 6 then
				text = text.." "
			else
				text = text.."i"
			end
		end
		if round >= 5 then
			draw.TextRotatedScaled( "i", w + 111, h - 180, col, font, 60, 1, 1.45 )
		end
		--if round >= 10 then
		--	draw.TextRotatedScaled( "i", w + 220, h - 150, col, font, 60, 1, 1.7 )
		--end
	else
		text = round
	end
	draw.SimpleText(text, font, w, h, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

end

local roundchangeending = false
local prevroundspecial = false
local function StartChangeRound()

	print(nzRound:GetNumber(), nzRound:IsSpecial())
	
	local lastround = nzRound:GetNumber()

	if lastround >= 1 then
		if prevroundspecial then
			surface.PlaySound("#nzu/round/specialround_end.wav")
		else
			surface.PlaySound("#nz/round/round_end.mp3")
		end
	elseif lastround == -2 then
		surface.PlaySound("#nz/round/round_-1_prepare.mp3")
	else
		round_num = 0
	end

	roundchangeending = false
	round_white = 0
	local round_charger = 0.25
	local alphafading = false
	local haschanged = false
	hook.Add("HUDPaint", "nz_roundnumWhiteFade", function()
		if !alphafading then
			round_white = math.Approach(round_white, round_charger > 0 and 255 or 0, round_charger*350*FrameTime())
			if round_white >= 255 and !roundchangeending then
				alphafading = true
				round_charger = -1
			elseif round_white <= 0 and roundchangeending then
				hook.Remove("HUDPaint", "nz_roundnumWhiteFade")
			end
		else
			round_alpha = math.Approach(round_alpha, round_charger > 0 and 255 or 0, round_charger*350*FrameTime())
			if round_alpha >= 255 then
				if haschanged then
					round_charger = -0.25
					alphafading = false
				else
					round_charger = -1
				end
			elseif round_alpha <= 0 then
				if roundchangeending then
					round_num = nzRound:GetNumber()
					round_charger = 0.5
					if round_num == -1 then
						--surface.PlaySound("nz/easteregg/motd_round-03.wav")
					elseif nzRound:IsSpecial() then
						surface.PlaySound("#nzu/round/specialround_start.wav")
						prevroundspecial = true
					else
						surface.PlaySound("#nz/round/round_start.mp3")
						prevroundspecial = false
					end
					haschanged = true
				else
					round_charger = 1
				end
			end
		end
	end)

end

local function EndChangeRound()
	roundchangeending = true
end

local grenade_icon = Material("grenade-256.png", "unlitgeneric smooth")
local specialgrenade_icon = Material("grenade-256.png", "unlitgeneric smooth")

local function DrawGrenadeHud()
	if !drawhud then return end
	
	local num = LocalPlayer():GetAmmoCount(GetNZAmmoID("grenade") or -1)
	local numspecial = LocalPlayer():GetAmmoCount(GetNZAmmoID("specialgrenade") or -1)
	local scale = (ScrW()/1920 + 1)/2

	surface.SetDrawColor(255,255,255)
	
	
	local gren = LocalPlayer():GetSpecialWeaponFromCategory( "grenade" )
	if num > 0 and IsValid(gren) then
		surface.SetMaterial(gren.NZHudIcon or grenade_icon)
		
		for i = num, 1, -1 do
			surface.DrawTexturedRect(ScrW() - 275*scale - i*15*scale, ScrH() - 90*scale, 40*scale, 40*scale)
		end
	end
	
	local specialgren = LocalPlayer():GetSpecialWeaponFromCategory( "specialgrenade" )
	if num > 0 and IsValid(specialgren) then
		if specialgren.NZHudIcon then
			surface.SetMaterial(specialgren.NZHudIcon)
		else
			surface.SetMaterial(specialgrenade_icon)
			surface.SetDrawColor(255,127,127)
		end
		
		for i = numspecial, 1, -1 do
			surface.DrawTexturedRect(ScrW() - 380*scale - i*15*scale, ScrH() - 90*scale, 40*scale, 40*scale)
		end
	end
	
end

local shield_icon = Material("icon16/shield.png", "unlitgeneric smooth")

local function DrawShieldHud()
	if !drawhud then return end
	
	local shield = LocalPlayer():GetSpecialWeaponFromCategory( "shield" )
	if !IsValid(shield) then return end
	
	local scale = (ScrW()/1920 + 1)/2

	surface.SetDrawColor(255,255,255)
	surface.SetMaterial(shield.NZHudIcon or shield_icon)
	surface.DrawTexturedRect(ScrW() - 180*scale, ScrH() - 200*scale, 40*scale, 40*scale)
	
	local font = "nz.display.hud.small"
	draw.SimpleText("["..input.GetKeyName(nzSpecialWeapons.Keys.shield).."]", font, ScrW() - 160*scale, ScrH() - 160*scale, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end

local afsymbol = Material("vgui/afterlife_blue")
local afsymbolwhite = Material("vgui/afterlife_white")
local function AfterlifeHud()
	if !nzAfterlife.Enabled then return end
	
	if LocalPlayer():GetNW2Bool("IsInAfterlife") then
		surface.SetMaterial(afsymbolwhite)
		surface.SetDrawColor(128,128,128)
		surface.DrawTexturedRect(ScrW()/2 - 64, ScrH() - 128, 128, 64)
		
		--(CurTime() - v.DownTime)*(150/GetConVar("nz_downtime"):GetFloat())
		local clone = LocalPlayer():GetNW2Entity("AfterlifeClone")
		
		if !IsValid(clone) then return end
		if nzRevive.Players[clone:EntIndex()] == nil then return end
		
		local downtime = (CurTime() - nzRevive.Players[clone:EntIndex()].DownTime)
		
		local remap = math.Remap(downtime, 0, GetConVar("nz_downtime"):GetFloat(), 0, 1)
		
		surface.SetMaterial(afsymbol)
		surface.SetDrawColor(255,255,255)
		surface.DrawTexturedRectUV( ScrW()/2 - 64, ScrH() - 128, 128 - remap*128, 64, 0, 0, 1-remap, 1 )
		return
	end




	local font = "nz.display.hud.main"
	
	local w = (ScrW()*0.9)
	surface.SetDrawColor(255,255,255)
	surface.SetMaterial(afsymbol)
	surface.DrawTexturedRect(w, ScrH() - 256, 100, 50)
	draw.SimpleText(tostring(LocalPlayer():GetNW2Int("Afterlives")), font, w+72, ScrH() - 192, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
end

-- Hooks
hook.Add("HUDPaint", "pointsNotifcationHUD", DrawPointsNotification )
hook.Add("HUDPaint", "roundHUD", StatesHud )
hook.Add("HUDPaint", "scoreHUD", ScoreHud )
hook.Add("HUDPaint", "gunHUD", function() 
	GunHud()
	DrawShieldHud()
	DrawGrenadeHud()
end)
hook.Add("HUDPaint", "powerupHUD", PowerUpsHud )
hook.Add("HUDPaint", "perksHUD", PerksHud )
hook.Add("HUDPaint", "vultureVision", VultureVision )
hook.Add("HUDPaint", "roundnumHUD", RoundHud )
--hook.Add("HUDPaint", "grenadeHUD", DrawGrenadeHud )
--hook.Add("HUDPaint", "shieldHUD", DrawShieldHud )
if nzAfterlife then hook.Add("HUDPaint", "afterlifeHUD", AfterlifeHud ) end

hook.Add("OnRoundPreparation", "BeginRoundHUDChange", StartChangeRound)
hook.Add("OnRoundStart", "EndRoundHUDChange", EndChangeRound)

local blockedweps = {
	["nz_revive_morphine"] = true,
	["nz_packapunch_arms"] = true,
	["nz_chalk_arms"] = true,
	["nz_perk_bottle"] = true,
	["weapon_afterlife"] = true
}

function GM:HUDWeaponPickedUp( wep )

	if ( !IsValid( LocalPlayer() ) || !LocalPlayer():Alive() ) then return end
	if ( !IsValid( wep ) ) then return end
	if ( !isfunction( wep.GetPrintName ) ) then return end
	if blockedweps[wep:GetClass()] then return end

	local pickup = {}
	pickup.time			= CurTime()
	pickup.name			= wep:GetPrintName()
	pickup.holdtime		= 5
	pickup.font			= "DermaDefaultBold"
	pickup.fadein		= 0.04
	pickup.fadeout		= 0.3
	pickup.color		= Color( 255, 200, 50, 255 )

	surface.SetFont( pickup.font )
	local w, h = surface.GetTextSize( pickup.name )
	pickup.height		= h
	pickup.width		= w

	if ( self.PickupHistoryLast >= pickup.time ) then
		pickup.time = self.PickupHistoryLast + 0.05
	end

	table.insert( self.PickupHistory, pickup )
	self.PickupHistoryLast = pickup.time
	
	if wep.NearWallEnabled then wep.NearWallEnabled = false end
	if wep:IsFAS2() then wep.NoNearWall = true end

end

local function ParseAmmoName(str)
	local pattern = "nz_weapon_ammo_(%d)"
	local slot = tonumber(string.match(str, pattern))
	if slot then
		for k,v in pairs(LocalPlayer():GetWeapons()) do
			if v:GetNWInt("SwitchSlot", -1) == slot then
				if v.Primary and v.Primary.OldAmmo then
					return "#"..v.Primary.OldAmmo.."_ammo"
				end
				local wep = weapons.Get(v:GetClass())
				if wep and wep.Primary and wep.Primary.Ammo then
					return "#"..wep.Primary.Ammo.."_ammo"
				end
				return v:GetPrintName() .. " Ammo"
			end
		end
	end
	return str
end

function GM:HUDAmmoPickedUp( itemname, amount )
	if ( !IsValid( LocalPlayer() ) || !LocalPlayer():Alive() ) then return end
	
	itemname = ParseAmmoName(itemname)
	
	-- Try to tack it onto an exisiting ammo pickup
	if ( self.PickupHistory ) then
		for k, v in pairs( self.PickupHistory ) do
			if ( v.name == itemname ) then
				v.amount = tostring( tonumber( v.amount ) + amount )
				v.time = CurTime() - v.fadein
				return
			end
		end
	end
	
	local pickup = {}
	pickup.time			= CurTime()
	pickup.name			= itemname
	pickup.holdtime		= 5
	pickup.font			= "DermaDefaultBold"
	pickup.fadein		= 0.04
	pickup.fadeout		= 0.3
	pickup.color		= Color( 180, 200, 255, 255 )
	pickup.amount		= tostring( amount )
	
	surface.SetFont( pickup.font )
	local w, h = surface.GetTextSize( pickup.name )
	pickup.height	= h
	pickup.width	= w
	
	local w, h = surface.GetTextSize( pickup.amount )
	pickup.xwidth	= w
	pickup.width	= pickup.width + w + 16

	if ( self.PickupHistoryLast >= pickup.time ) then
		pickup.time = self.PickupHistoryLast + 0.05
	end
	
	table.insert( self.PickupHistory, pickup )
	self.PickupHistoryLast = pickup.time
end

local roundendmusic = {
    "nz/round/round_end.mp3",
    "nz/round/round_end2.mp3",
	"nz/round/round_end3.mp3"
}

local roundstartmusic = {
    "nz/round/round_start.mp3",
    "nz/round/round_start2.mp3",
    "nz/round/round_start3.mp3"
}
