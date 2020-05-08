local c = require("component")
local t = require("term")
local event = require("event")
local fisr = c.nc_fission_reactor

print("Welcome to Fission Controller v4 - by ThePoleThatFishes")
print("Hold Q to quit, U to force an update. (If stats are looking wrong!)")
print("This message will self destruct in 5 seconds.")
print("After the self-destruction, the script will begin.")
os.sleep(5)

local size = string.format("%s*%s*%s", fisr.getLengthX(), fisr.getLengthY(), fisr.getLengthZ())
local maxRF = fisr.getMaxEnergyStored()
local maxHU = fisr.getMaxHeatLevel()
local xRF = fisr.getEfficiency()
local xHU = fisr.getHeatMultiplier() 
local cells = fisr.getNumberOfCells()

local function fuelStats()
	fuel = string.format("%s (%s RF/t - %s HU/t)", fisr.getFissionFuelName(), fisr.getFissionFuelPower(), fisr.getFissionFuelHeat())
	rfT = fisr.getReactorProcessPower()
	netHU = fisr.getReactorProcessHeat()
end

local function currentProcess()
	rf = fisr.getEnergyStored()
	hu = fisr.getHeatLevel()
	lvlRF = string.format("%s/%s RF", rf, maxRF)
	lvlHU = string.format("%s/%s HU", hu, maxHU)
	fuelLeft = (fisr.getReactorProcessTime() - fisr.getCurrentProcessTime()/cells)/20
	if rf/maxRF > 0.4 or hu/maxHU > 0 then
		fisr.deactivate()
	else
		fisr.activate()
	end
	if fisr.isProcessing() then
		stat = "Active"
	else
		if hu/maxHU > 0 then
			stat = "Cooling"
		elseif rf/maxRF > 0.4 then
			stat = "Discharging"
		elseif string.find(fuel, "No Fuel") then
			stat = "No Fuel"
		end
	end
	statKeys = {"Size: ", "Cells: ", "Efficiency: ", "Heat Mult.: ", "Energy: ", "Heat Level: ", "Status: ",
	"Fuel: ", "Energy Gen: ", "Net Heat: ", "Fuel Left: "}
	statVal = {size, cells, xRF .. "%", xHU .. "%", lvlRF, lvlHU, stat, fuel,
	string.format("%.0f RF/t", rfT), string.format("%.0f HU/t", netHU), string.format("%.1f sec", fuelLeft)}
end

function fisrInit()
	fuelStats()
	currentProcess()
	print("-- Solid Fission Reactor Info -- ")
	for i = 1, 11 do
		print(statKeys[i] .. statVal[i])
	end
end

function fisrRun()
	while true do
		local ev, ad, chr, code, player = event.pull(0.1)
		if ev == "key_down" and chr == 113 then
			print("Quitting...")
			break
		end
		if ev == "key_down" and chr == 117 then
			t.clear()
			fisrInit()
		end
		currentProcess()
		clearLines = {5, 6, 7, 11}
		for i = 1, 4 do
			t.setCursor(1, clearLines[i]+1)
			t.clearLine()
			print(statKeys[clearLines[i]] .. statVal[clearLines[i]])
		end
	end
end

t.clear()
fisrInit()
fisrRun()
	