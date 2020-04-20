c = require("component")
t = require("term")
fisr = c.nc_fission_reactor

function reactorStats()
	x = fisr.getLengthX()
	y = fisr.getLengthY()
	z = fisr.getLengthZ()
	max_rf = fisr.getMaxEnergyStored()
	max_hu = fisr.getMaxHeatLevel()
	mult_rf = fisr.getEfficiency()
	mult_hu = fisr.getHeatMultiplier()
	no_cells = fisr.getNumberOfCells()
	return x, y, z, max_rf, max_hu, mult_rf, mult_hu, no_cells
end

function fuelStats()
	fuel = fisr.getFissionFuelName()
	fuel_rf_t = fisr.getFissionFuelPower()
	fuel_hu_t = fisr.getFissionFuelHeat()
	rf_t = fisr.getReactorProcessPower()
	net_hu = fisr.getReactorProcessHeat()
	return fuel, fuel_rf_t, fuel_hu_t, rf_t, net_hu
end

function currentProcess()
	rf = fisr.getEnergyStored()
	hu = fisr.getHeatLevel()
	timeleft = fisr.getReactorProcessTime() - fisr.getCurrentProcessTime()/no_cells	
	return rf, hu, timeleft
end

function reactorControl()
	if rf/max_rf > 0.4 or hu/max_hu > 0.2 then
		fisr.deactivate()
	else
		fisr.activate()
	end
end

function reactorStatus()
	status = fisr.isProcessing()
	if status then
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
	return stat
end

function infoOutput()
	fisrStatsNames = {"Size: ", "Cells: ", "Eff. Mult.: ", "Heat Mult.: ", "Energy: ", "Heat: ", "Status: "}
	fisrStats = {}
	fisrStats["Size: "] = x .. "*" .. y .. "*" .. z
	fisrStats["Cells: "] = no_cells
	fisrStats["Eff. Mult.: "] = mult_rf .. "%"
	fisrStats["Heat Mult.: "] = mult_hu .. "%"
	fisrStats["Energy: "] = rf .. "/" .. max_rf .. " RF " .. "(+" .. rf_t .. " RF/t)"
	fisrStats["Heat: "] = hu .. "/" .. max_hu .. " HU " .. "(" .. net_hu .. " HU/t)"
	fisrStats["Status: "] = stat
	fuelInfoNames = {"Fuel: ", "Base Power-Heat: ", "Time Left: "}
	fuelInfo = {}
	fuelInfo["Fuel: "] = fuel
	fuelInfo["Base Power-Heat: "] = fuel_rf_t .. " RF/t - " .. fuel_hu_t .. " HU/t"
	fuelInfo["Time Left: "] = timeleft/20 .. " sec"
end

function fisrInit()
	reactorStats()
	fuelStats()
	currentProcess()
	reactorControl()
	reactorStatus()
	print("Reactor Info")
	for k1, v1 in ipairs(fisrStatsNames) do
		print(v1 .. fisrStats[v1])
	end
	print("Fuel Info")
	for k2, v2 in ipairs(fuelInfoNames) do
		print(v2 .. fuelInfo[v2])
	end
end

function fisrRun()
	while timeleft > 0 do
		currentProcess()
		reactorControl()
		reactorStatus()
		infoOutput()
		clearLines = {6, 7, 8, 12}
		for k3, v3 in ipairs(clearLines) do
			t.setCursor(1, v3)
			t.clearLine()
			if v3 ~= 12 then
				print(fisrStatsNames[v3-1] .. fisrStats[fisrStatsNames[v3-1]])
			else
				print(fuelInfoNames[v3-9] .. fuelInfo[fuelInfoNames[v3-9]])
			end
		end
		os.sleep(0.7)
	end
end

t.clear()
fisrInit()
fisrRun()
		
		
	
