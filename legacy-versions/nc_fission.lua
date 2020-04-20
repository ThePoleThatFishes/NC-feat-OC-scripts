c = require("component")
t = require("term")
fisr = c.nc_fission_reactor

function permReactorStats()
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

function reactorStats()
	rf = fisr.getEnergyStored()
	hu = fisr.getHeatLevel()
	timeleft = fisr.getReactorProcessTime() - fisr.getCurrentProcessTime()	
	return rf, hu, timeleft
end

function fuelStats()
	fuel = fisr.getFissionFuelName()
	fuel_rf_t = fisr.getFissionFuelPower()
	fuel_hu_t = fisr.getFissionFuelHeat()
	rf_t = fisr.getReactorProcessPower()
	net_hu = fisr.getReactorProcessHeat()
	return fuel, fuel_rf_t, fuel_hu_t, rf_t, net_hu
end

function reactorControl()
	if rf/max_rf > 0.8 or hu/max_hu > 0.2 then
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
			stat = "Cooling"
		elseif rf/max_rf > 0.8 then
			stat = "Discharging"
		else
			stat = fisr.getProblem()
		end
	end
	return stat
end
function info()
	print("Reactor Info")
	fisrStats = {}
	fisrStats["Size:"] = x .. "*" .. y .. "*" .. z
	fisrStats["Cells:"] = no_cells
	fisrStats["Energy:"] = rf .. "/" .. max_rf .. " RF"
	fisrStats["Heat:"] = hu .. "/" .. max_hu
	fisrStats["Eff. Mult.:"] = mult_rf .. "%"
	fisrStats["Heat Mult.:"] = mult_hu .. "%"
	fisrStats["Status:"] = stat
	print("Size: " .. fisrStats["Size:"])
  	print("Cells: " .. fisrStats["Cells:"])
  	print("Eff. Mult.: " .. fisrStats["Eff. Mult.:"])
  	print("Heat Mult.: " .. fisrStats["Heat Mult.:"])
  	print("Energy: " .. fisrStats["Energy:"])
  	print("Heat: " .. fisrStats["Heat:"])
  	print("Status: " .. fisrStats["Status:"] .. \n)
	print("Fuel Info")
	fuelInfo = {}
	fuelInfo["Fuel:"] = fuel
	fuelInfo["Base Power:"] = fuel_rf_t .. "RF/t"
	fuelInfo["Base Heat:"] = fuel_hu_t .. "HU/t"
	fuelInfo["Energy Produced:"] = rf_t .. "RF/t"
	fuelInfo["Net Heating:"] = net_hu .. "HU/t"
	fuelInfo["Time Left:"] = timeleft/20 .. "sec"
	print("Fuel: " .. fuelInfo["Fuel:"])
  	print("Base Power/Heat: " .. fuelInfo["Base Power:"] .. "-" .. fuelInfo["Base Heat:"])
  	print("Energy Produced: " .. fuelInfo["Energy Produced:"])
  	print("Net Heating: " .. fuelInfo["Net Heating:"])
  	print("Time Left: " .. fuelInfo["Time Left:"])  
end


function runReactor()
	while True do
		permReactorStats()
                fuelStats()
		reactorStats()
    		reactorControl()
		reactorStatus()
		info()		
		os.sleep(3)
		t.clear()
		runscript = runscript - 1
		if runscript == 0 then
			break
		end
	end
end

runscript = 50
runReactor()
		
