DGS = exports.dgs
local screenWidth, screenHeight = guiGetScreenSize()

local peds = {}
local startMoney = 100
local reward = startMoney * 2
local startText = "[#00ff00E#ffffff] play Dice for #00ff00$"..startMoney.."#ffffff"
local startBlock, startAnim = "dealer", "dealer_idle"
local playBlock, playAnim = "casino", "cards_win"
local isPedPlaying = false

function createNPC(coordinates, heading, skin)
    local npc = createPed(skin, coordinates.x, coordinates.y, coordinates.z, heading)
    setPedAnimation(npc, startBlock, startAnim, -1, true, false, false, false)
    setElementFrozen(npc, true)
    addEventHandler ("onClientPedDamage", npc, cancelPedDamage )
    Text = create3DText(startText,coordinates, tocolor(255,255,255,255), 10, npc, 1)
    table.insert(peds, npc)  
end

function create3DText(text,coordinates, color, distance, NPC, height)
    local text = DGS:dgsCreate3DText(coordinates.x, coordinates.y, coordinates.z + 1, text, color, "default-bold", 0.3, 0.3, distance, true)
    DGS:dgsSetProperty(text,"canBeBlocked",true)
    DGS:dgsSetProperty(text,"shadow",{0.3,0.3,tocolor(0,0,0,255),false})
    DGS:dgs3DTextAttachToElement(text, NPC,0, 0, height)
    return text
end

function createProgressBar ()
    local progressBar = DGS:dgsCreateProgressBar((screenWidth*0.5) - (screenWidth * 0.05), (screenHeight*0.7) - (screenHeight*0.015), (screenWidth * 0.1), (screenHeight*0.03), false) 
    local progressLabel = DGS:dgsCreateLabel(0,0, (screenWidth * 0.1), (screenHeight*0.03), "Rolling Dice ...", false, progressBar, _, _,_, _, _,_, "center", "center")
    return progressBar, progressLabel
end

function destroyProgressBar (progressBar, timer)
    if progressBar then 
        destroyElement(progressBar)
        if isTimer(timer) then 
            killTimer(timer)
        end
    end
end

addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), 
function()
    local configFile = xmlLoadFile(":playDice/config.xml", true)
    
    if not configFile then
        outputDebugString("Failed to load config.xml")
    else
        local npcNode = xmlFindChild(configFile, "npcConfig", 0)
        if not npcNode then
            outputDebugString("NPC configuration node not found in config.xml")
        else
            local children = xmlNodeGetChildren(npcNode)
            for i, child in ipairs(children) do
                if xmlNodeGetName(child) == "location" then
                    local x = tonumber(xmlNodeGetAttribute(child, "x"))
                    local y = tonumber(xmlNodeGetAttribute(child, "y"))
                    local z = tonumber(xmlNodeGetAttribute(child, "z"))
                    local heading = tonumber(xmlNodeGetAttribute(child, "heading"))
                    local skin = tonumber(xmlNodeGetAttribute(child, "skin"))

                    createNPC(Vector3(x, y, z), heading, skin)
                end
            end
        end
        xmlUnloadFile(configFile)
    end
end)

function gameDiceMessages()
    local playerResult = math.random(1, 6)
    local pedResult = math.random(1, 6)

    outputChatBox("You rolled a #00ff00"..playerResult, 255,255,255,true)
    outputChatBox("Ped rolled a #00ff00"..pedResult, 255,255,255,true)

    if playerResult > pedResult then
        outputChatBox("You #00ff00win", 255,255,255,true)
        triggerServerEvent("playDice:givePlayerMoney", getRootElement(), getLocalPlayer(), 100)
    elseif playerResult < pedResult then
        outputChatBox("You #ff0000lose", 255,255,255,true)
        triggerServerEvent("playDice:takePlayerMoney", getRootElement(), getLocalPlayer(), 100)
    else
        outputChatBox("It's a #ffff00tie", 255,255,255,true)
    end
end

function playDiceGame(ped)
    progressBar, progressBarLabel = createProgressBar()
    isPlaying = true
    number = 0

    local progressTimer = setTimer(function()
        number = number + 1
        DGS:dgsProgressBarSetProgress(progressBar,number)
        if number == 100 then
            if isElement(progressBar) then 
                if checkPedProximity(ped, 2) then 
                    isPlaying = false
                    gameDiceMessages()
                    destroyProgressBar(progressBar, progressTimer)
                    setPedAnimation(ped, startBlock, startAnim, -1, true, false, false, false)
                else 
                    isPlaying = false
                    outputChatBox("You left the game", 255,0,0)
                    destroyProgressBar(progressBar, progressTimer)
                    setPedAnimation(ped, startBlock, startAnim, -1, true, false, false, false)
                end
            end
        end
    end, 20, 100)
end

function checkPedProximity(ped, maxDistance)
    local px, py, pz = getElementPosition(localPlayer)
    local cx, cy, cz = getElementPosition(ped)

    local distance = getDistanceBetweenPoints3D(px, py, pz, cx, cy, cz)

    return distance <= maxDistance
end

function onClientKeyPress(key, press)
    if key == "e" and press then
        if not isPlaying and isPedOnGround(getLocalPlayer()) and not isPedDead(getLocalPlayer()) then 
            for _, ped in ipairs(peds) do
                if checkPedProximity(ped, 2) then
                    local playerMoney = getPlayerMoney()
                    if playerMoney >= startMoney then 
                        cancelEvent()
                        setPedAnimation(ped, "casino", "cards_win", -1, false, false, false)
                        playDiceGame(ped)
                        break 
                    else 
                        outputChatBox("You have no money", 255,0,0)
                    end
                end
            end
        end
    end
end
addEventHandler("onClientKey", root, onClientKeyPress)

function cancelPedDamage ( attacker )
	cancelEvent()
end
