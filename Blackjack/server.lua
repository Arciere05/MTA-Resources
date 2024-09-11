markers = {}

addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), 
function()
	stringtoboolean={ ["true"]=true, ["false"]=false }
	local xml = xmlLoadFile("blackjackMarkers.xml")
	local messageNodes = xmlNodeGetChildren(xml)
	
	for i, node in ipairs(messageNodes) do
		local markerX = xmlNodeGetAttribute(node, "markerX")
		local markerY = xmlNodeGetAttribute(node, "markerY")
		local markerZ = xmlNodeGetAttribute(node, "markerZ")
		local markerSize = xmlNodeGetAttribute(node, "markerSize")
		local markerType = xmlNodeGetAttribute(node, "markerType")
		local r = xmlNodeGetAttribute(node, "markerColorR")
		local g = xmlNodeGetAttribute(node, "markerColorG")
		local b = xmlNodeGetAttribute(node, "markerColorB")
		local alpha = xmlNodeGetAttribute(node, "markerAlpha")
		local marker = xmlNodeGetAttribute(node, "markerVisible")
		local interior = xmlNodeGetAttribute(node, "interior")
		local dimension = xmlNodeGetAttribute(node, "dimension")

		local markers = createMarker(markerX , markerY , markerZ, markerType, markerSize, r, g, b, alpha)
		setElementInterior(markers, interior)
		setElementDimension(markers, dimension)
		setElementVisibleTo(markers, getRootElement(), stringtoboolean[marker])
		local mx, my, mz = getElementPosition(markers)

		local colShape = createColTube(0,0,0,1,2.13)
		setElementInterior(colShape, interior)
		setElementDimension(colShape, dimension)
		setElementData(colShape, "colRotation", {rx, ry, rz})
		attachElements(colShape, markers, 0, 0, 0)
		addEventHandler("onColShapeHit", colShape, colHit)
		addEventHandler("onColShapeLeave", colShape, colLeave)
		
	end
	xmlUnloadFile(xml)
end)

function giveMoney (player, ammount)
    if isElement(player) then  
        givePlayerMoney(player, ammount)
    end
end
addEvent("blackjack:givePlayerMoney", true)
addEventHandler("blackjack:givePlayerMoney", getRootElement(), giveMoney)

function takeMoney (player, ammount)
    if isElement(player) then 
        takePlayerMoney(player, ammount)
    end
end
addEvent("blackjack:takePlayerMoney", true)
addEventHandler("blackjack:takePlayerMoney", getRootElement(), takeMoney)

function colHit (hitElement, matchingDimension)
	if isElement(hitElement) and getElementType(hitElement) == "player" then 
		triggerClientEvent(hitElement, "blackjack:showBlackjackWindow", hitElement)
	end
end

function colLeave (leftElement, matchingDimension)
	if isElement(leftElement) and getElementType(leftElement) == "player" then
		triggerClientEvent(leftElement, "blackjack:closeWindow", leftElement)
	end
end

function playerWasted () 
	if isElement(source) then 
		triggerClientEvent(source, "blackjack:closeWindow", source)
	end
end
addEventHandler("onPlayerWasted", getRootElement(), playerWasted)

function playerQuit () 
	if isElement(source) then 
		triggerClientEvent(source, "blackjack:closeWindow", source)
	end
end
addEventHandler("onPlayerQuit", getRootElement(), playerWasted)