DGS = exports.dgs
local x, y = DGS:dgsGetScreenSize()

local drinks = {
	{name = "Coke", price = 5, hp = 10},
	{name = "Water Bottle", price = 1, hp = 10},
	{name = "Sprunk", price = 10, hp = 15},
	{name = "Iced Tea", price = 5, hp = 5},
	{name = "RedBull", price = 20, hp = 20},
}

local rows = {}

local isWindowOpen = false
local row = 1

local titleImage = DGS:dgsCreateRoundRect(5, false, tocolor(0,255,0, 100))
local windowImage = DGS:dgsCreateRoundRect(5, false, tocolor(0,0,0,100))
local columnImage = DGS:dgsCreateRoundRect(5, false, tocolor(0,0,0,200))
local normalRowImage = DGS:dgsCreateRoundRect(0, false, tocolor(0,0,0,0))
local hoverRowImage = DGS:dgsCreateRoundRect(0, false, tocolor(255,255,255,255))  

function mainMenu ()
	row = 1
	isWindowOpen = true
	window = DGS:dgsCreateWindow(x * 0.01, y * 0.05, x * 0.15 , y * 0.2, "Vending Machine", false, _, 30, titleImage, _, windowImage)
	DGS:dgsWindowSetMovable(window, false)
    DGS:dgsWindowSetSizable(window, false)
	DGS:dgsWindowSetCloseButtonEnabled(window, false)
	guiSetInputMode("no_binds")
	
	gridlist = DGS:dgsCreateGridList(0,0, x * 0.15, y * 0.17, false, window, 25, _, _, _, _, _, _, windowImage, columnImage, normalRowImage, hoverRowImage, hoverRowImage)
    DGS:dgsSetProperty(gridlist,"scrollBarThick",2)
    
	
	column = DGS:dgsGridListAddColumn( gridlist, "This machine accept cash only", 0.7 ) 
    column2 = DGS:dgsGridListAddColumn( gridlist, row.." / "..#drinks, 0.3 , _, "center")
	
	DGS:dgsGridListSetAutoSortEnabled(gridlist, false)
	DGS:dgsGridListSetColumnFont(gridlist, 1, "default-bold")
	DGS:dgsGridListSetColumnFont(gridlist, 2, "default-bold")
	
	for i, v in ipairs(drinks) do 
        rows[i] = DGS:dgsGridListAddRow ( gridlist )
        DGS:dgsSetProperty(gridlist,"rowHeight", 30)
        DGS:dgsGridListSetItemText (gridlist, rows[i], column, v["name"])
        DGS:dgsGridListSetItemText (gridlist, rows[i], column2, "$ "..v["price"])
        DGS:dgsGridListSetItemData(gridlist, rows[i], column, {v["hp"],v["price"]})
		DGS:dgsGridListSetItemColor(gridlist, rows[i], column2, tocolor(0,255,0,255))
		DGS:dgsGridListSetRowHoverable(gridlist, rows[i], false)
		DGS:dgsGridListSetRowSelectable(gridlist, rows[i], false)
		DGS:dgsGridListSetRowSelectable(gridlist, rows[i], false)
    end
	
	DGS:dgsGridListSetSelectedItem(gridlist, 1)
	changeColorOnHover(#drinks, 1)
	
	showChat(false)
end
addEvent("showVendingMachineWindow", true)
addEventHandler("showVendingMachineWindow", getRootElement(), mainMenu)

function rowSelect (button, press)
	if isElement(window) and isWindowOpen then 
		if (button == "arrow_d") and press then 
			local selectedRow, selectedColumn = DGS:dgsGridListGetSelectedItem(gridlist)
			playSoundFrontEnd(0)
			if selectedRow > 0 and selectedRow < #drinks then 
				local rowIndex = selectedRow + 1
				row = rowIndex
				DGS:dgsGridListSetSelectedItem(gridlist, rowIndex)
				DGS:dgsGridListSetColumnTitle(gridlist, 2, row.." / "..#drinks)
				changeColorOnHover(selectedRow, rowIndex)
			else 
				DGS:dgsGridListSetSelectedItem(gridlist, 1)
				DGS:dgsGridListSetColumnTitle(gridlist, 2, "1 / "..#drinks)
				changeColorOnHover(#drinks, 1)
			end
		elseif (button == "arrow_u") and press then
			playSoundFrontEnd(0)
			local selectedRow, selectedColumn = DGS:dgsGridListGetSelectedItem(gridlist)
			if selectedRow > 1 and selectedRow < #drinks + 1 then
				local rowIndex = selectedRow - 1
				row = rowIndex
				DGS:dgsGridListSetSelectedItem(gridlist, rowIndex)
				DGS:dgsGridListSetColumnTitle(gridlist, 2, row.." / "..#drinks)
				changeColorOnHover(selectedRow, rowIndex)
			else
				DGS:dgsGridListSetSelectedItem(gridlist, #drinks)
				DGS:dgsGridListSetColumnTitle(gridlist, 2, #drinks.." / "..#drinks)
				changeColorOnHover(1, #drinks)
			end
		end
	end
end
addEventHandler("onClientKey", getRootElement(), rowSelect)

function changeColorOnHover(previousRow, currentRow)
	for row = 1,2 do 
		DGS:dgsGridListSetItemFont(gridlist, currentRow, row, "default-bold")
		DGS:dgsGridListSetItemFont(gridlist, previousRow, row, "default")
		DGS:dgsGridListSetItemFont(gridlist, currentRow, row, "default-bold")
		DGS:dgsGridListSetItemFont(gridlist, previousRow, row, "default")
	end
	
	DGS:dgsGridListSetItemColor(gridlist, previousRow, 1, tocolor(255,255,255,255))
	DGS:dgsGridListSetItemColor(gridlist, currentRow, 1, tocolor(0,0,0,255))

	DGS:dgsGridListScrollTo(gridlist, currentRow, 1)
end

function purchaseItem (button , press)
	if isElement(window) and isWindowOpen then 
		if (button == "enter") and press then 
			local selectedRow, selectedColumn = DGS:dgsGridListGetSelectedItem ( gridlist )
			if selectedRow > 0 and selectedColumn then 
				local itemData = DGS:dgsGridListGetItemData(gridlist, selectedRow, selectedColumn)
				local itemHp, itemPrice = itemData[1], itemData[2]
				local itemText = DGS:dgsGridListGetItemText(gridlist, selectedRow, selectedColumn)
				if itemPrice and itemHp then 
					if getPlayerMoney() >= tonumber(itemPrice) then 
						playSoundFrontEnd(1)
						triggerServerEvent("onVendingMachinePurchase", localPlayer, localPlayer, itemPrice, itemHp, itemText)
					end
				end
			end
		end
	end
end
addEventHandler("onClientKey", getRootElement(), purchaseItem)

function closeWindow (button , press)
	if isElement(window) and isWindowOpen then 
		if (button == "backspace") and press then
			onClose()
		end
	end
end
addEventHandler("onClientKey", getRootElement(), closeWindow)

function onClose ()
	if isWindowOpen and isElement(window) then 
		isWindowOpen = false
		destroyElement(window)
		showChat(true)
		guiSetInputMode("allow_binds")
	end
end
addEvent("closeVendingMachineWindow", true)
addEventHandler("closeVendingMachineWindow", getRootElement(), onClose)

setDevelopmentMode(true)
