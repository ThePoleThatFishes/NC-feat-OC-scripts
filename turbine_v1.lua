local c = require("component")
local t = require("term")
local event = require("event")
local turb = c.nc_turbine

print("Welcome to Turbine Controller v3 - by ThePoleThatFishes")
print("Hotkey Help: Q = Quit, U = Force Update, A = Eco Mode")
print("Eco Mode stops the turbine at 75% RF buffer and turns it back on at 5%. (Off by default)")
os.sleep(1)
print("This message will self destruct in 5 seconds.")
print("After the self-destruction, the script will begin.")
os.sleep(5)
t.clear()

local x = turb.getLengthX()
local y = turb.getLengthY()
local z = turb.getLengthZ()
local size = string.format("%s*%s*%s", x, y, z)
local coilEff = turb.getCoilConductivity()
local ex = turb.getTotalExpansionLevel()
local optEx = turb.getIdealTotalExpansionLevel()
local maxRF = turb.getEnergyCapacity()
local eco = "Off"

local function process()
	steamIn = turb.getInputRate()
	rfT = turb.getPower()
	rf = turb.getEnergyStored()
	if eco == "On" then
		if rf/maxRF > 0.75 then
			turb.deactivate()
		elseif rf/maxRF < 0.05 then
			turb.activate()
		end
	else
		turb.activate()
	end
	statsNames = {"Size: ", "Expansion: ", "Coil Efficiency: ", "Energy Stored: ", "Energy Gen: ", "Steam Input: ", "Eco Mode: "}
	stats = {size, string.format("x%.3f/x%.3f", ex, optEx), string.format("%.3f", coilEff), string.format("%s/%s RF", rf, maxRF)
	, rfT .. " RF/t", steamIn .. " mb/t", eco}
end

process()

print("Turbine Stats")
for i = 1, 3 do
	print(statsNames[i] .. stats[i])
end

while true do
	local ev, ad, chr, code, player = event.pull(0.1)
	if ev == "key_down" and chr == 113 then
		print("Quitting...")
		break
	end
	if ev == "key_down" and chr == 117 then
		process()
		for i = 4, 7 do
			t.setCursor(1,i+1)
			t.clearLine()
			print(statsNames[i] .. stats[i])
		end
	end
	if ev == "key_down" and chr = 97 then
		if eco == "On" then
			eco = "Off"
		else
			eco = "On"
		end
	end
	process()
	for i = 4, 7 do
		t.setCursor(1,i+1)
		t.clearLine()
		print(statsNames[i] .. stats[i])
	end
end