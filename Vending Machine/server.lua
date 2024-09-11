addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), 
function()
	stringtoboolean={ ["true"]=true, ["false"]=false }
	local xml = xmlLoadFile("vendingMachines.xml")
	local messageNodes = xmlNodeGetChildren(xml)
	machines = {}
	for i, node in ipairs(messageNodes) do
		local machineID = xmlNodeGetAttribute(node, "object")
		local x = xmlNodeGetAttribute(node, "objectX")
		local y = xmlNodeGetAttribute(node, "objectY")
		local z = xmlNodeGetAttribute(node, "objectZ")
		local rx = xmlNodeGetAttribute(node, "rx")
		local ry = xmlNodeGetAttribute(node, "ry")
		local rz = xmlNodeGetAttribute(node, "rz")
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
		
		local machines = createObject(machineID, x , y , z)
		setElementRotation(machines, rx , ry , rz)
		setElementInterior(machines, interior)
		setElementDimension(machines, dimension)

		local markers = createMarker(0 , 0 , 0, markerType, markerSize, r, g, b, alpha)
		setElementInterior(markers, interior)
		setElementDimension(markers, dimension)
		setElementVisibleTo(markers, getRootElement(), stringtoboolean[marker])
		attachElements(markers, machines, 0, -1.3, markerZ)

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

function colHit (hitElement, matchingDimension)
	if isElement(hitElement) and getElementType(hitElement) == "player" then 
		local x, y , z = getElementPosition(source)
		local rx, ry , rz = unpack(getElementData(source, "colRotation"))
		setElementPosition(hitElement, x , y ,z + 2 )
		setElementRotation(hitElement, rx, ry , rz)
		setCameraTarget(hitElement, hitElement)
		triggerClientEvent(hitElement, "showVendingMachineWindow", hitElement)
	end
end

function colLeave (leftElement, matchingDimension)
	if isElement(leftElement) and getElementType(leftElement) == "player" then
		triggerClientEvent(leftElement, "closeVendingMachineWindow", leftElement)
	end
end

function purchaseDrinks (player, price, hp, name)
	if isElement(player) then 
		if getPlayerMoney(player) >= tonumber(price) then 
			setElementHealth(player, getElementHealth(player) + hp)
			takePlayerMoney(player, price)
			outputChatBox("[#00ff00Vending Machine#ffffff] You have bought #00ff00"..name.." #fffffffor #00ff00$"..price.."", hitElement, 255,255,255,true)
			setPedAnimation(player, "vending", "vend_use", 2, false, false, true, true)
			triggerClientEvent(player, "closeVendingMachineWindow", player)
			setTimer(function()
				setPedAnimation(player, "vending", "vend_drink2_p", 2, false, false, true, true)
			end, 2000, 1)
		else
			outputChatBox("[#00ff00Vending Machine#ffffff] #ff0000You don't have enough money" , hitElement, 255,255,255,true)
		end
	end
end
addEvent("onVendingMachinePurchase", true)
addEventHandler("onVendingMachinePurchase", getRootElement(), purchaseDrinks)

function playerWasted () -- Close window on player wasted
	if isElement(source) then 
		triggerClientEvent(source, "closeVendingMachineWindow", source)
	end
end
addEventHandler("onPlayerWasted", getRootElement(), playerWasted)

function playerQuit () -- Close window on player quit
	if isElement(source) then 
		triggerClientEvent(source, "closeVendingMachineWindow", source)
	end
end
addEventHandler("onPlayerQuit", getRootElement(), playerWasted)
