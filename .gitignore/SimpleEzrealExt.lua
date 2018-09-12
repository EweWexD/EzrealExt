-- [[ Lib ]]
if FileExist(COMMON_PATH .. "MapPositionGOS.lua") then
	require 'MapPositionGOS'
else
	PrintChat("MapPositionGOS.lua missing!")
end
if FileExist(COMMON_PATH .. "TPred.lua") then
	require 'TPred'
else
	PrintChat("TPred.lua missing!")
end

-- [[ Champion ]]
if myHero.charName ~= "Ezreal" then return end

-- [[ Menu ]]
function Ezreal:Menu()
	self.EzrealMenu = MenuElement({type = Menu, id = Ezreal = "[Simple] Ezreal"})
	-- [[ Combo ]]
	self.EzrealMenu:MenuElement({id = "Combo", name = "Combo Settings", type = MENU})
	self.EzrealMenu.Combo:MenuElement({id = "Q", name = "Use Q", value = true})
	self.EzrealMenu.Combo:MenuElement({id = "W", name = "Use W", value = true})
	self.EzrealMenu.Combo:MenuElement({id = "E", name = "Use E", value = false})
	self.EzrealMenu.Combo:MenuElement({id = "R", name = "Use R", value = false})
	-- [[ Harass ]]
	self.EzrealMenu:MenuElement({id = "Harass", name = "Harass Settings", type = MENU})
	self.EzrealMenu.Harass:MenuElement({id = "Q", name = "Use Q", value = true})
	self.EzrealMenu.Harass:MenuElement({id = "W", name = "Use W", value = true})
	-- [[ Lane Clear ]]
	self.EzrealMenu:MenuElement({id = "Farm", name = "Farm Settings", type = MENU})
	self.EzrealMEnu.Farm:MenuElement({id = "Q", name = "Use Q", value = true})
	-- [[ HitChance ]]
	self.EzrealMenu:MenuElement({id ="HitChance", name = "HitChance Settings", type = MENU})
	self.EzrealMenu.HitChance:MenuElement({id = "PredChance", name = "HitChance", value = 4, min = 1, max = 5, step = 1})
	-- [[ Draw ]]
	self.EzrealMenu:MenuElement({id = "Draw", name = "Range Draw Settings", type = MENU})
	self.EzrealMenu.Draw:MenuElement({id = "Q", name = "Draw Q", value = true})
	self.EzrealMenu.Draw:MenuElement({id = "W", name = "Draw W", value = true})
	self.EzrealMenu.Draw:MenuElement({id = "E", name = "Draw E", value = true})
	self.EzrealMenu.Draw:MenuElement({id = "R", name = "Draw R", value = true})
end

-- [[ Spells ]]
function Ezreal:Spells()
	EzrealQ = {range = 1150, speed = 2000, width = 60, delay = 0.25, collision = true, aoe = false, type = "line"}
	EzrealW = {range = 1000, speed = 1600, width = 80, delay = 0.25, collision = false, aoe = true, type = "line"}
	EzrealE = {range = 475}
	EzrealR = {range = 5000, speed = 2000, width = 160, delay = 1, collision = false, aoe = true, type = "line"}
end

-- [[ Tick ]]
function Ezreal:Tick()
	if myHero.dead or Game.IsChatOpen() == true then return end
	if Mode() == "Combo" then 
		self:Combo()
	elseif Mode() == "Harass" then 
		self:Harass()
	elseif Mode() == "Clear" then 
		self:Farm()
	end
end

-- [[ Draw]]
function Ezreal:Draw()
	if myHero.dead then return end
	if self.EzrealMenu.Draw.Q:Value() then Draw.Circle(myHero.pos, EzrealQ.range, 1, Draw.Color(255, 255, 255, 0)) end
	if self.EzrealMenu.Draw.W:Value() then Draw.Circle(myHero.pos, EzrealW.range, 1, Draw.Color(255, 26, 255, 0)) end
	if self.EzrealMenu.Draw.E:Value() then Draw.Circle(myHero.pos, EzrealE.range, 1, Draw.Color(255, 199, 60, 60)) end
	if self.EzrealMenu.Draw.R:Value() then Draw.Circle(myHero.pos, EzrealR.range, 1, Draw.Color(255, 60, 102, 199)) end
end

-- [[ Init ]]
function Ezreal:_init()
	self:Menu()
	self:Spells()
	Callback.add("Tick", function() self:Tick() end)
	Callback.add("Draw", function() self:Draw() end)
end

-- [[ Ezreal Q ]]
function Ezreal:QUse(target)
	local castpos, Hitchance, pos = TPred:GetBestCastPosition(target, EzrealQ.dealy, EzrealQ.range, EzrealQ.width, EzrealQ.speed, myHero.pos, EzrealQ.collision, EzrealQ.type)
	if (HitChance >= self.EzrealMenu.HitChance.PredChance:Value()) then
		control.CastSpell(HK_Q, castpos)
	end
end
-- [[ Ezreal W ]]
function Ezreal:WUse(target)
	local castpos, Hitchance, pos = TPred:GetBestCastPosition(target, EzrealW.dealy, EzrealW.range, EzrealW.width, EzrealW.speed, myHero.pos, EzrealW.collision, EzrealW.type)
	if (HitChance >= self.EzrealMenu.HitChance.PredChance:Value()) then
		control.CastSpell(HK_W, castpos)
	end
end
-- [[ Ezreal R ]]
function Ezreal:RUse(target)
	local castpos, Hitchance, pos = TPred:GetBestCastPosition(target, EzrealR.dealy, EzrealR.range, EzrealR.width, EzrealR.speed, myHero.pos, EzrealR.collision, EzrealR.type)
	if (HitChance >= self.EzrealMenu.HitChance.PredChance:Value()) then
		local RCastPos = myHero.pos-myHero.pos-castpos):Normalized()*300
		CastSpell(HK:R, RCastPos, 300, EzrealR.delay*1000)
	end
end

-- [[ Combo ]]
function Ezreal:Combo()
	if target == nil then return end
	-- [[ Q Use ]]
	if self.EzrealMenu.Combo.Q:Value() then 
		if IsReady(_Q) and myHero.attackData.state ~= STATE_WINUP then 
			if ValidTarget(target, EzrealQ.range) then 
				self:QUse(target)
			end
		end
	end
	-- [[ W Use ]]
	if self.EzrealMenu.Combo.W:Value() then 
		if IsReady(_W) and myHero.attackData.state ~= STATE_WINUP then 
			if ValidTarget(target, EzrealW.range) then 
				self:QUse(target)
			end
		end
	end
	-- [[ E Use ]]
	if self.EzrealMenu.Combo.E:Value() then 
		if IsReady(_E) then 
			if ValidTarget(target, EzrealR.range+myHero.range) then 
				Control.CastSpell(HK_E, mousePos)
			end
		end
	end
	-- [[ R Use ]]
	if self.EzrealMenu.Combo.R:Value() then 
		if IsReady(_R) then 
			if ValidTarget(target, EzrealR.range) then 
				self:RUse(target)
			end
		end
	end
end

-- [[ Harass ]]
function Ezreal:Harass()
	if target == nil then return end
	-- [[ Q Use ]]
	if self.EzrealMenu.Harass.Q:Value() then 
		self:QUse()
	end
	-- [[ W Use ]]
	if self.EzrealMenu.Harass.W:Value() then 
		self:WUse()
	end
end

-- [[ LaneClear ]]
function Ezreal:Farm()
	if self.EzrealMenu.Farm.Q:Value() then 
		for i = 1, Game.MinionCount() do
			local minion = Game.Minion(i)
			if minion and minion.isEnemy then 
				if ValidTarget(minion, EzrealQ.range) then 
					Control.CastSpell(HK_Q, minion)
				end
			end
		end
	end
end



PrintChat("Simple Ezreal Ext beta")
PrintChat("Made by EweEwe")
