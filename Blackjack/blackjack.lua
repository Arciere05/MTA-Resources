local deck = {}
local playerHand = {}
local dealerHand = {}
local DGS = exports.dgs
gameInProgress = false

function startBlackjackGame(betAmount)
    if gameInProgress then
        outputChatBox("Game already in progress!")
        return
    end

    if betAmount == 0 then
        outputChatBox("You must place a bet to start the game!")
        return
    end

    gameInProgress = true
    deck = createDeck()
    playerHand = {}
    dealerHand = {}

    table.insert(playerHand, table.remove(deck))
    table.insert(playerHand, table.remove(deck))
    table.insert(dealerHand, table.remove(deck))

    displayCards(playerHand, dealerHand)
end

function hit()
    if not gameInProgress then
        return
    end

    table.insert(playerHand, table.remove(deck))
    displayCards(playerHand, dealerHand)

    if calculateHandValue(playerHand) > 21 then
        displayGameResult("Bust", betAmount)
        resetGame()
    elseif calculateHandValue(playerHand) == 21 then 
        stand()
    end
end

function stand()
    if not gameInProgress then
        return
    end

    while calculateHandValue(dealerHand) < 17 do
        table.insert(dealerHand, table.remove(deck))
        displayCards(playerHand, dealerHand)
    end

    local playerValue = calculateHandValue(playerHand)
    local dealerValue = calculateHandValue(dealerHand)

    if dealerValue > 21 or playerValue > dealerValue then
        betAmount = betAmount * 2
        displayGameResult("Win", betAmount)
    elseif playerValue < dealerValue then
        displayGameResult("Bust", betAmount)
    else
        displayGameResult("Push", betAmount)
    end

    resetGame()
end

function createDeck()
    local suits = {"Hearts", "Diamonds", "Clubs", "Spades"}
    local values = {"2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"}
    local newDeck = {}
    
    for _, suit in ipairs(suits) do
        for _, value in ipairs(values) do
            table.insert(newDeck, {suit = suit, value = value})
        end
    end

    math.randomseed(getTickCount())
    for i = #newDeck, 2, -1 do
        local j = math.random(i)
        newDeck[i], newDeck[j] = newDeck[j], newDeck[i]
    end

    return newDeck
end

function calculateHandValue(hand)
    local value, aces = 0, 0
    for _, card in ipairs(hand) do
        if card.value == "A" then
            aces = aces + 1
            value = value + 11
        elseif card.value == "K" or card.value == "Q" or card.value == "J" then
            value = value + 10
        else
            value = value + tonumber(card.value)
        end
    end

    while value > 21 and aces > 0 do
        value = value - 10
        aces = aces - 1
    end

    return value
end