if myHero.charName ~= "Taric" then return end

local LevelSequence = {_E,_W,_Q,_W,_W,_R,_W,_Q,_W,_Q,_R,_Q,_Q,_E,_E,_R,_E,_E} -- order to level abilities
local TaricLevel = 0
local Recall = false
local qrange, wrange, erange, rrange, aurarange = 750, 200, 625, 190, 500


		
function OnLoad()
 player = GetMyHero()
	-- Config Menu
	Config = scriptConfig("Taric Slacker", "Taric")	
	Config:addParam("heal", "Heal Allys", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("combo", "Combo", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("harass", "Harass enemys", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("ultimate", "Ultimate enemies", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("healthperc","% of Health before healing",4,0.7,0,1,2)
	end

function OnTick()
if Recalling then return end
Checks()
if player.level > TaricLevel then
		LevelSpell(LevelSequence[player.level])
		TaricLevel = player.level
	end
	if Config.combo then
		Combo()
	end
	if Config.harass then
		harass()
		shatter()
	end
	if Config.ultimate then
		ultimate()
	end
	if Config.heal then
		CastQ()
	end
--print(tostring(Config.heal))
--print(tostring(Config.healthperc))
--print(tostring(GetLowestAlly(qrange)))
--print(tostring(QREADY))
--print("")
end


function shatter()
	for i=1, heroManager.iCount do
	local enemy = heroManager:getHero(i)
		if ValidTarget(enemy, wrange) then
			CastSpell(_W)
			UseItems()
		end
	end
end

function ultimate()
	for i=1, heroManager.iCount do -- Scan all champions in the game
		local enemy = heroManager:getHero(i) -- Assign a local variable for the champions.
		local damage = getDmg("R", enemy, myHero) -- Calculate the Q damage
			if ValidTarget(enemy, rrange) and enemy.health/enemy.maxHealth<=.5 then
				CastSpell(_R)
			end

	end
	if CountEnemyHeroInRange(1200) >= 3 then CastSpell(_R) end
	end
		
function CountEnemyHeroInRange(range)
local enemyInRange = 0
	for i = 1, heroManager.iCount, 1 do
	local enemyheros = heroManager:getHero(i)
		if enemyheros.valid and enemyheros.visible and enemyheros.dead == false and enemyheros.team ~= myHero.team and GetDistance(enemyheros) <= range then
			enemyInRange = enemyInRange + 1
		end
	end
 return enemyInRange
end
 

function Combo()
	for i=1, heroManager.iCount do -- Scan all champions in the game
		local enemy = heroManager:getHero(i) -- Assign a local variable for the champions.
			if ValidTarget(enemy, 750) and enemy.health/enemy.maxHealth<=.6 then
			harass()
			ultimate()
			shatter()
			CastQ()
			end
		end
	end

			
function CastQ()
if Config.heal and QREADY and GetLowestAlly(qrange).health/GetLowestAlly(qrange).maxHealth <= Config.healthperc then
	CastSpell(_Q, GetLowestAlly(qrange))
end
end

function GetLowestAlly(range) --[[Tested function.. I love it! Always returns the lowest % ally in range.]]
	assert(range, "GetLowestAlly: Range returned nil. Cannot check valid ally in nil range")
	LowestAlly = nil
	for a = 1, heroManager.iCount do
		Ally = heroManager:GetHero(a)
		if Ally.team == myHero.team and not Ally.dead and GetDistance(myHero,Ally) <= range then
			if LowestAlly == nil then
				LowestAlly = Ally
			elseif not LowestAlly.dead and (Ally.health/Ally.maxHealth) < (LowestAlly.health/LowestAlly.maxHealth) then
				LowestAlly = Ally
			end
		end
	end
	return LowestAlly
end

	
	

function harass()
	for i=1, heroManager.iCount do -- Scan all champions in the game
		local enemy = heroManager:getHero(i) -- Assign a local variable for the champions.
		UseItems(enemy)
        if ValidTarget(enemy, erange) and not Recall then
			CastSpell(_E, enemy)
		end
	end
end



function OnCreateObj(object)
	if object.name == "TeleportHome.troy" then
		if GetDistance(object, myHero) <= 70 then
			Recall = true
		end
	end
end
 
function OnDeleteObj(object)
	if object.name == "TeleportHome.troy" then
		Recall = false
	end
end

	function Checks()
        BRKSlot, DFGSlot, HXGSlot, BWCSlot, TMTSlot, RAHSlot, RNDSlot, YGBSlot = GetInventorySlotItem(3153), GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144), GetInventorySlotItem(3077), GetInventorySlotItem(3074),  GetInventorySlotItem(3143), GetInventorySlotItem(3142)
        QREADY = (myHero:CanUseSpell(_Q) == READY)
        WREADY = (myHero:CanUseSpell(_W) == READY)
        EREADY = (myHero:CanUseSpell(_E) == READY)
        RREADY = (myHero:CanUseSpell(_R) == READY)
        DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
        HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
        BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
        BRKREADY = (BRKSlot ~= nil and myHero:CanUseSpell(BRKSlot) == READY)
        TMTREADY = (TMTSlot ~= nil and myHero:CanUseSpell(TMTSlot) == READY)
        RAHREADY = (RAHSlot ~= nil and myHero:CanUseSpell(RAHSlot) == READY)
        RNDREADY = (RNDSlot ~= nil and myHero:CanUseSpell(RNDSlot) == READY)
        YGBREADY = (YGBSlot ~= nil and myHero:CanUseSpell(YGBSlot) == READY)
        IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
        end

function UseItems(enemy)
        if GetDistance(enemy) < 550 then
                if DFGREADY then CastSpell(DFGSlot, enemy) end
                if HXGREADY then CastSpell(HXGSlot, enemy) end
                if BWCREADY then CastSpell(BWCSlot, enemy) end
                if BRKREADY then CastSpell(BRKSlot, enemy) end
                if YGBREADY then CastSpell(YGBSlot, enemy) end
                if TMTREADY and GetDistance(enemy) < 275 then CastSpell(TMTSlot) end
                if RAHREADY and GetDistance(enemy) < 275 then CastSpell(RAHSlot) end
                if RNDREADY and GetDistance(enemy) < 275 then CastSpell(RNDSlot) end
        end
end

