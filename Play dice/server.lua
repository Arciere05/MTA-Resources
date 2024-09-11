function giveMoney (player, ammount)
    local playerMoney = getPlayerMoney(player)
    if tonumber(ammount) then 
        givePlayerMoney(player, tonumber(ammount))
    end
end
addEvent("playDice:givePlayerMoney", true)
addEventHandler("playDice:givePlayerMoney", getRootElement(), giveMoney)

function takeMoney (player, ammount)
    local playerMoney = getPlayerMoney(player)
    if tonumber(ammount) then 
        if playerMoney >= ammount then 
            takePlayerMoney(player, tonumber(ammount))
        end
    end
end
addEvent("playDice:takePlayerMoney", true)
addEventHandler("playDice:takePlayerMoney", getRootElement(), takeMoney)

