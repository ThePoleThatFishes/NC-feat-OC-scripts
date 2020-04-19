c = require("component")
t = require("term")
fisr = c.nc_fission_reactor

local x = fisr.getLengthX()
local y = fisr.getLengthY()
local z = fisr.getLengthZ()
local size = string.format("%s*%s*%s", x, y, z)
local max_rf = fisr.getMaxEnergyStored()
local max_hu = fisr.getMaxHeatLevel()
local mult_rf = fisr.getEfficiency() .. "%"
local mult_hu = fisr.getHeatMultiplier() .. "%"
local no_cells = fisr.getNumberOfCells()

local fuel = fisr.getFissionFuelName()
local fuel_base = string.format("%s RF/t - %s HU/t", fisr.getFissionFuelPower(), fisr.getFissionFuelHeat())	
local rf_t = fisr.getReactorProcessPower() .. " RF/t"
local net_hu = fisr.getReactorProcessHeat() .. " HU/t"

function currentProcess()
	rf = fisr.getEnergyStored()
	hu = fisr.getHeatLevel()
	rf_lvl = string.format("%s/%s RF", rf, max_rf)
	hu_lvl = string.format("%s/%s HU", hu, max_hu)
	timeleft = (fisr.getReactorProcessTime() - fisr.getCurrentProcessTime()/no_cells)/20
end

function reactorControl()
	if rf/max_rf > 0.4 or hu/max_hu > 0.2 then
		fisr.deactivate()
	else
		fisr.activate()
	end
end

function reactorStatus()
	if fisr.isProcessing() then
		stat = "Active"
	else
		if hu/max_hu > 0.2 then
			stat = "Inactive - Cooling"
		elseif rf/max_rf > 0.4 then
			stat = "Inactive - Discharging"
		else
			stat = "Inactive - " .. fisr.getProblem()
		end
	end
end

function infoOutput()
	fisrStatsNames = {"Size: ", "Cells: ", "Eff. Mult.: ", "Heat Mult.: ", "Energy: ", "Heat Level: ", "Status: "}
	fisrStats = {size, no_cells, mult_rf, mult_hu, rf_lvl, hu_lvl, stat}
	fuelInfoNames = {"Fuel: ", "Base Power-Heat: ", "Energy Gen: ", "Net Heat: ", "Time Left: "}
	fuelInfo = {fuel, fuel_base, rf_t, net_hu, timeleft .. " sec"}
end

function fisrInit()
	fuelStats()
	currentProcess()
	reactorControl()
	reactorStatus()
	infoOutput()
	print("Reactor Info")
	for i = 1, 7 do
		print(fisrStatsNames[i] .. fisrStats[i])
	end
	print("Fuel Info")
	for i = 1, 5
		print(fuelInfoNames[i] .. fuelInfo[i])	
	end
end

function fisrRun()
	while timeleft > 0 do
		currentProcess()
		reactorControl()
		reactorStatus()
		infoOutput()
		local clearLines = {6, 7, 8, 14}
		for i = 1, 4 do
			t.setCursor(1, clearLines[i])
			t.clearLine()
			if i ~= 4 then
				print(fisrStatsNames[i+4] .. fisrStats[i+4])
			else
				print(fuelInfoNames[i+1] .. fuelInfo[i+1])
			end
		end
		os.sleep(0.7)
	end
end

t.clear()
fisrInit()
fisrRun()
		
