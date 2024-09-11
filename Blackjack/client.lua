DGS = exports.dgs
x, y = DGS:dgsGetScreenSize()
resw, resh = 1920, 1080

isWindowOpen = false
selectedAmount, betAmount = nil, 0
cardImage, playerCardElements, dealerCardElements = {}, {}, {}
maxBet = 5000000

local Ammounts = {
    {name = "500$", value = 500},
    {name = "1.000$", value = 1000},
    {name = "5.000$", value = 5000},
    {name = "20.000$", value = 20000},
    {name = "50.000$", value = 50000},
    {name = "500.000$", value = 500000},
}

local titleImage = DGS:dgsCreateRoundRect(5, false, tocolor(1, 50, 32, 200))
local windowImage = DGS:dgsCreateRoundRect(5, false, tocolor(0, 0, 0, 0))
local buttonImage = DGS:dgsCreateRoundRect(25, false, tocolor(0, 0, 0, 0))
local buttonsImage = DGS:dgsCreateRoundRect(15, false, tocolor(21, 21, 21, 255))
local backgroundImage = DGS:dgsCreateRoundRect(0, false, tocolor(0, 0, 0, 155))
local hitImage = DGS:dgsCreateRoundRect(10, false, tocolor(0, 128, 0, 255))
local hoverHitImage = DGS:dgsCreateRoundRect(10, false, tocolor(0, 100, 0, 255))
local standImage = DGS:dgsCreateRoundRect(10, false, tocolor(255, 0, 0, 255))
local hoverStandImage = DGS:dgsCreateRoundRect(10, false, tocolor(150, 0, 0, 255))

function onRadioButtonSelect(value)
    selectedAmount = value
end

function createRadioButtons(window)
    local startY, incrementY = 0.04, 0.04

    for i, amount in ipairs(Ammounts) do
        local radioButton = DGS:dgsCreateRadioButton(0.02, startY + (i - 1) * incrementY, 0.1, 0.04, amount.name, true, window)
        addEventHandler("onDgsMouseClickUp", radioButton, function()
            if not gameInProgress and DGS:dgsRadioButtonGetSelected(radioButton) then
                onRadioButtonSelect(amount.value)
            end
        end)
    end
end

function CreateWindow()
    if not isElement(window) and not isWindowOpen then 
        isWindowOpen = true
        window = DGS:dgsCreateWindow(0, 0, x * 0.6, y * 0.6, "BlackJack", false, _, 30, titleImage, _, windowImage)
        winX, winY = DGS:dgsGetSize(window, false)
        local background = DGS:dgsCreateImage(0, 0, x * 0.6, y * 0.6, "images/background.png", false, window)
        DGS:dgsSetEnabled(background, false)
        DGS:dgsCenterElement(window)

        createRadioButtons(window)
        
        betBtn = DGS:dgsCreateButton(winX / 2 - x * 0.0145, winY / 2 + y * 0.08, x * 0.031, y * 0.055, "Place your bets", false, window, _, 0.9, 0.9, buttonImage, buttonImage, buttonImage)
        DGS:dgsSetProperty(betBtn, "shadow", {1, 1, tocolor(0, 0, 0, 255), true})
        DGS:dgsSetProperty(betBtn, "font", "Pricedown")

        dealBtn = DGS:dgsCreateButton(winX / 2 - x * 0.035, winY / 2 + y * 0.2, x * 0.07, y * 0.07, "Deal", false, window, _, _, _, buttonsImage, buttonsImage, buttonsImage)
        DGS:dgsSetProperty(dealBtn, "font", "Default-bold")
        DGS:dgsSetVisible(dealBtn, false)
        
        image = DGS:dgsCreateImage(winX / 2 - (winX * 0.15), winY / 2 - (winY * 0.15), winX * 0.3, winY * 0.15, backgroundImage, false, window)
        local imgX, imgY = DGS:dgsGetSize(image, false)
        hitBtn = DGS:dgsCreateButton(imgX * 0.05, imgY / 2 - (winY * 0.05), winX * 0.1, winY * 0.1, "HIT", false, image, _, _, _, hitImage, hoverHitImage, hitImage)
        standBtn = DGS:dgsCreateButton(imgX * 0.62, imgY / 2 - (winY * 0.05), winX * 0.1, winY * 0.1, "STAND", false, image, _, _, _, standImage, hoverStandImage, standImage)
        DGS:dgsSetVisible(image, false)
        showCursor(true)
        addEventHandler("onDgsWindowClose",window,windowClosed)
    end
end
addEvent("blackjack:showBlackjackWindow", true)
addEventHandler("blackjack:showBlackjackWindow", getRootElement(), CreateWindow)

function onBetBtn(button, state)
    if isElement(window) and button == "left" and state == "up" and source == betBtn then
        if not gameInProgress and selectedAmount then
            local playerMoney = getPlayerMoney()
            if playerMoney >= betAmount + selectedAmount then
                if (betAmount + selectedAmount) <= maxBet then
                    betAmount = betAmount + selectedAmount
                    DGS:dgsSetText(betBtn, "$" .. comma_value(betAmount))
                end
                if betAmount > 0 then
                    DGS:dgsSetVisible(dealBtn, true)
                end
            end
        end
    end
end
addEventHandler("onDgsMouseClick", getRootElement(), onBetBtn)

function onDealBtn(button, state)
    if button == "left" and state == "up" and source == dealBtn then
        startBlackjackGame(betAmount)
        DGS:dgsSetVisible(dealBtn, false)
        DGS:dgsSetVisible(image, true)
        triggerServerEvent("blackjack:takePlayerMoney", localPlayer, localPlayer, betAmount)
    end
end
addEventHandler("onDgsMouseClick", getRootElement(), onDealBtn)

function createCardImage(card, cx, cy)
    local relativeWidth = 80 / resw
    local relativeHeight = 116 / resh
    width, height = x * relativeWidth, y * relativeHeight
    local imagePath = "images/" .. card.value .. "_" .. card.suit .. ".png"
    return DGS:dgsCreateImage(cx, cy, width, height, imagePath, false, window)
end

function displayCards(playerHand, dealerHand)
    if isElement(playerHandLabel) then
        destroyElement(playerHandLabel)
    end
    if isElement(dealerHandLabel) then
        destroyElement(dealerHandLabel)
    end

    local cardSpacing = 1
    local cardWidth = (x * 0.0469) / 2
    local totalPlayerWidth = (#playerHand - 1) * cardSpacing + (#playerHand * cardWidth)
    local playerStartX = (winX - totalPlayerWidth) / 2

    for i, card in ipairs(playerHand) do
        if not playerCardElements[i] then
            local cardImage = createCardImage(card, playerStartX + (i-1) * (cardWidth + cardSpacing), y * 0.44)
            DGS:dgsSetEnabled(cardImage, false)
            table.insert(playerCardElements, cardImage)
        else
            local cardImage = playerCardElements[i]
            local cardX, cardY = DGS:dgsGetPosition(cardImage, false)
            DGS:dgsSetPosition(cardImage, playerStartX + (i-1) * (cardWidth + cardSpacing), cardY, false)
        end
    end
    playerHandLabel = DGS:dgsCreateLabel(
        playerStartX + cardWidth/2, 
        y * 0.44 + height, 
        totalPlayerWidth, 
        y * 0.03, 
        calculateHandValue(playerHand), 
        false, 
        window, 
        tocolor(255, 215, 0, 255)
    )
    DGS:dgsSetProperty(playerHandLabel, "shadow", {1, 1, tocolor(0, 0, 0, 255), true})
    DGS:dgsSetProperty(playerHandLabel, "alignment", {"center", "top"})
    DGS:dgsSetProperty(playerHandLabel, "font", "pricedown")

    local totalDealerWidth = (#dealerHand - 1) * cardSpacing + (#dealerHand * cardWidth)
    local dealerStartX = (winX - totalDealerWidth) / 2

    for i, card in ipairs(dealerHand) do
        if not dealerCardElements[i] then
            local cardImage = createCardImage(card, dealerStartX + (i-1) * (cardWidth + cardSpacing), y * 0.01)
            DGS:dgsSetEnabled(cardImage, false)
            table.insert(dealerCardElements, cardImage)
        else
            local cardImage = dealerCardElements[i]
            local cardX, cardY = DGS:dgsGetPosition(cardImage, false)
            DGS:dgsSetPosition(cardImage, dealerStartX + (i-1) * (cardWidth + cardSpacing), cardY, false)
        end
    end
    dealerHandLabel = DGS:dgsCreateLabel(
        dealerStartX + cardWidth/2, 
        y * 0.01 + height, 
        totalDealerWidth, 
        y * 0.03, 
        calculateHandValue(dealerHand), 
        false, 
        window, 
        tocolor(255, 215, 0, 255)
    )
    DGS:dgsSetProperty(dealerHandLabel, "shadow", {1, 1, tocolor(0, 0, 0, 255), true})
    DGS:dgsSetProperty(dealerHandLabel, "alignment", {"center", "top"})
    DGS:dgsSetProperty(dealerHandLabel, "font", "pricedown")
end

function onDecisionMade (button, state)
    if button == "left" and state == "up" then
        if source == hitBtn then
            hit()
        elseif source == standBtn then
            stand()
        end
    end
end
addEventHandler("onDgsMouseClick", getRootElement(), onDecisionMade)

function displayGameResult (status, betAmount)
    if isElement(resultImage) then
        destroyElement(resultImage)
    end

    local resultTopLabelHeight = y*0.1
    local rect = DGS:dgsCreateRoundRect(0, false, tocolor(0, 0, 0, 155), _, _, _, true, 1, 0)
    resultImage = DGS:dgsCreateImage(winX / 2 - (x * 0.075), winY / 2 - (y * 0.1), x * 0.15, y * 0.1, rect, false, window)

    if status ~= "Bust" then
        resultTopLabelHeight = y*0.05
        local resultBotLabel = DGS:dgsCreateLabel(0, y * 0.05, x * 0.15, y * 0.05, "$ " .. comma_value(betAmount), false, resultImage, tocolor(255, 215, 0, 255))
        DGS:dgsSetProperty(resultBotLabel, "font", "Pricedown")
        DGS:dgsSetProperty(resultBotLabel, "shadow", {1, 1, tocolor(0, 0, 0, 255), true})
        DGS:dgsSetProperty(resultBotLabel, "alignment", {"center", "center"})
    end

    local resultTopLabel = DGS:dgsCreateLabel(0, 0, x * 0.15, resultTopLabelHeight, status, false, resultImage, tocolor(255, 215, 0, 255))
    DGS:dgsSetProperty(resultTopLabel, "font", "Pricedown")
    DGS:dgsSetProperty(resultTopLabel, "shadow", {1, 1, tocolor(0, 0, 0, 255), true})
    DGS:dgsSetProperty(resultTopLabel, "alignment", {"center", "center"})

    local textColor
    if status == "Bust" then
        textColor = tocolor(255, 0, 0, 255)
    elseif status == "Win" then
        textColor = tocolor(0, 255, 0, 255)
        triggerServerEvent("blackjack:givePlayerMoney", localPlayer, localPlayer, betAmount)
    else
        textColor = tocolor(255, 255, 255, 255)
        triggerServerEvent("blackjack:givePlayerMoney", localPlayer, localPlayer, betAmount)
    end
    DGS:dgsSetProperty(resultTopLabel, "textColor", textColor)
end

function destroyCards()
    for _, element in ipairs(playerCardElements) do
        if isElement(element) then destroyElement(element) end
    end
    for _, element in ipairs(dealerCardElements) do
        if isElement(element) then destroyElement(element) end
    end
    if isElement(playerHandLabel) then
        destroyElement(playerHandLabel)
    end
    if isElement(dealerHandLabel) then
        destroyElement(dealerHandLabel)
    end
    playerCardElements = {}
    dealerCardElements = {}
end

function resetGame()
    if isElement(image) then 
        DGS:dgsSetVisible(image, false)
    end
    setTimer(function()
        betAmount = 0
        if isElement(dealBtn) and isElement(betBtn) then 
            DGS:dgsSetVisible(dealBtn, false)
            DGS:dgsSetText(betBtn, "Place your bets")
        end
        if isElement(resultImage) then 
            destroyElement(resultImage)
        end
        destroyCards()
        gameInProgress = false
    end, 2000, 1)
end

function windowClosed()
    cancelEvent() 
    if isElement(window) then 
        DGS:dgsAlphaTo(window, 0, "OutQuad", 1000)
    end
    showCursor(false)
    resetGame()

    setTimer(function() 
        if isElement(window) then 
            destroyElement(window)
            isWindowOpen = false
        end
    end, 1000, 1) 
end

addEvent("blackjack:closeWindow", true)
addEventHandler("blackjack:closeWindow", getRootElement(), windowClosed)


function comma_value(amount)
    local formatted = amount
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    return formatted
end