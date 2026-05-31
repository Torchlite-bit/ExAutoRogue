ExAutoRogue = {
    ver = "1.3",
    Loaded = false,
    RiposteExpiry = 0,
}

-- Register Slash Command globally
SLASH_EXAUTOROGUE1 = "/AutoRogue"
SlashCmdList["EXAUTOROGUE"] = function(msg) ExAutoRogue:EvalCommand(msg) end

-- Create an invisible frame to listen to the combat log
local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES")
f:SetScript("OnEvent", function() 
    if event == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES" then
        if arg1 and string.find(string.lower(arg1), "parry") then
            ExAutoRogue.RiposteExpiry = GetTime() + 5.5
        end
    end
end)

function ExAutoRogue:OnLoad()
    local _, class = UnitClass("player")
    if class ~= "ROGUE" then return end
    
    if not ExAutoRogue.Loaded then
        DEFAULT_CHAT_FRAME:AddMessage("ExAutoRogue v" .. ExAutoRogue.ver .. " Loaded. (No-SnD Support Added)", 1, 0.8, 0.0)
        ExAutoRogue.Loaded = true
    end
end

-- Function to check for buffs on the player
function ExAutoRogue:HasBuff(buffName)
    for i=1,16 do 
        local b = UnitBuff("player", i)
        if b and string.find(string.lower(b), string.lower(buffName)) then 
            return true 
        end 
    end
    return false
end

-- Function to check for debuffs on the target by texture name
function ExAutoRogue:HasDebuff(textureName)
    for i=1,16 do 
        local d = UnitDebuff("target", i)
        if d and string.find(string.lower(d), string.lower(textureName)) then 
            return true 
        end 
    end
    return false
end

-- The main evaluation logic
function ExAutoRogue:EvalCommand(msg)
    -- Default settings
    local cpSnd = 2
    local cpEvis = 4
    local builder = "Sinister Strike"
    local popCDs = false
    local useExpose = false
    local useSnd = true

    -- Read macro arguments
    msg = string.lower(msg or "")
    if string.find(msg, "snd1") then cpSnd = 1 end
    if string.find(msg, "snd2") then cpSnd = 2 end
    if string.find(msg, "nosnd") then useSnd = false end
    if string.find(msg, "evis4") then cpEvis = 4 end
    if string.find(msg, "evis5") then cpEvis = 5 end
    if string.find(msg, "hemo") then builder = "Hemorrhage" end
    if string.find(msg, "expose") then useExpose = true end
    
    -- Target Classification
    local isElite = false
    local classification = UnitClassification("target")
    if classification == "worldboss" or classification == "elite" or classification == "rareelite" then
        isElite = true
    end

    -- Cooldown triggers
    if string.find(msg, "cds") then 
        popCDs = true 
    end
    if string.find(msg, "autocd") and isElite then
        popCDs = true
    end

    -- 1. Auto Target
    if not UnitExists("target") or UnitIsDead("target") then 
        TargetNearestEnemy() 
    end
    
    if not UnitCanAttack("player", "target") then return end

    -- 2. Pop Cooldowns (If triggered)
    if popCDs then
        CastSpellByName("Adrenaline Rush")
        CastSpellByName("Blade Flurry")
    end

    -- Gather current state
    local cp = GetComboPoints("player", "target")
    local timeNow = GetTime()

    -- 3. Priority 1: Riposte
    if timeNow < ExAutoRogue.RiposteExpiry then
        CastSpellByName("Riposte")

    -- 4. Priority 2: Slice and Dice
    elseif useSnd and cp >= cpSnd and not ExAutoRogue:HasBuff("SliceDice") then
        CastSpellByName("Slice and Dice")
    
    -- 5. Priority 3: Expose Armor
    elseif useExpose and isElite and cp == 5 and not ExAutoRogue:HasDebuff("ability_warrior_riposte") then
        CastSpellByName("Expose Armor")

    -- 6. Priority 4: Eviscerate
    elseif cp >= cpEvis then
        CastSpellByName("Eviscerate")
    
    -- 7. Priority 5: Combo Builder
    else
        CastSpellByName(builder)
    end
    
    -- Clear the red text instantly
    UIErrorsFrame:Clear()
end

-- Fire the loader
ExAutoRogue:OnLoad()
