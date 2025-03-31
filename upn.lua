#!/usr/bin/env lua

--[[
-- Unified Package Manager
-- by alexfdev0
-- Licensed under GNU GPL 3.0
-- NOTE: All packages are user-submitted: if a package is malicious, it is not my fault.
--]]--

local upn_ascii = [[
====================================================================================================
====================================================================================================
====================================================================================================
====================================================================================================
====================================================================================================
====================================================================================================
================================================================================+@@@@@@@@#==========
================================================================================+@@@@@@@@#==========
================================================================================+@@@@@@@@#==========
================================================================================+@@@@@@@@#==========
================================================================================+@@@@@@@@#==========
====================================================================================================
====================================================================================================
====================================================================================================
====================================================================================================
====================================================================================================
====================================================================================================
===================================+++=======================++=====================================
==*%+======%#+============+%@+===*@%%*+@%+===================*@+====================================
==#@+======@%+=============+++==+@#====++====================*@+====================================
==#@+======@%+=+**+#%%#+===*#==*#@%##+=#*+==++#%%#++===+*%%%**@+====================================
==#@+======@%+=+%@#+=+%%+==%@==++@#+++=@%+=+%%+==+%%+=+@%+=+#@@+====================================
==#@+======@%+=+%%====*@+==%@===+@#====@%+=*@+====+@*=%%+====#@+====================================
==#@+======@%+=+%#====*@+==%@===+@#====@%+=#@%%%%%%%*=%%+====*@+====================================
==*@#+====*@#==+%#====*@+==%@===+@#====@%+=+@*====+++=#@+====%@+====================================
===+@@###@@*+==+%#====*@+==%@===+@#====@%+==*@%#*%@#+=+#@%*#@#@+====================================
====================================================================================================
====================================================================================================
====================================================================================================
====================================================================================================
==================================+++===============================================================
==#@@@@@@@#+======================*@*===============================================================
==#@+====+%@*=====================*@*===============================================================
==#@+=====+@#=+#%%%%*====+#%%%#+==*@*===##+=+*%%%%#+===+#%%%#*%+===*%%%%#+==========================
==#@+====+%@*+%++==+@#==*@#+=+#@+=*@*=*@%+=+**+==+#@+=+%%+==+@@*=+%@+==+#@+=========================
==#@@@@@@@*====+++*#@@=+@%========*@*%@+======+++*%@*=*@+====*@*=*@++++++%%=========================
==#@+========+%%#*++%@=+@%========*@@#%@+==+#@#*+++@*=#@+====*@*=*@#######*=========================
==#@+========%@+===+@@==#@+===+#+=*@*==#@*=+@*====#@*=+@#===+%@*=+%#====+*+=========================
==#@+========*@@##%%@@===#@%#%@#==*@*===*@*+%@%#%@#@*==+%@@@@*@+==+@@%#%@#+=========================
=============================================================*@+====================================
======================================================+#%*++#@#=====================================
========================================================+*##+=======================================
====================================================================================================
==================================================================++================================
==#@@+=====%%+=============*#+====================================#@================================
==#@%%+====%%+=============*@*====================================#@================================
==#@*#@+===%%+==+#%@%@%+=+%@@@@%+%#+==*@#+==*%*=+#@@@@%+==+###@@@=#@===+%#+=========================
==#@+=%@+==%%+=+%%====*@+==*@*===#@+==%%@*=+#@=+%%====#@+=+%@*====#@=+#@#===========================
==#@+==#@*=%%+=*@*++++*%%==*@*===+%#=*@+##++@#=*@+====+%%=+%%=====#@*@@+============================
==#@+==+#@+%%+=*@*******+==*@*====#@+#%=*@+*%+=*@+====+%%=+%%=====#@@*%@+===========================
==#@+====#@%%+=+%#====+*+==*@*====+@#%*=+%#@#==+%#====*@*=+%%=====#@===%@*==========================
==#@+=====#@%+==+%@%%%@#+==+#@@%===#@%+==*@@+===+%@%%@%*==+%#=====#@====#@*=========================
====================================================================================================
====================================================================================================
====================================================================================================
]]

local upn_ascii_chars = {}

for i = 1, #upn_ascii do
	table.insert(upn_ascii_chars, string.sub(upn_ascii, i, i))
end

for i = 1, #upn_ascii_chars do
	if upn_ascii_chars[i] == "=" then
		upn_ascii_chars[i] = string.gsub(upn_ascii_chars[i], "=", string.format("\27[38;2;%d;%d;%dm", 69, 162, 248) .. "=\27[0m")
	end
end

local upn_ascii_real = ""

for i = 1, #upn_ascii_chars do
	upn_ascii_real = upn_ascii_real .. upn_ascii_chars[i]
end


local cjson = require("cjson")
local action = arg[1]

if not action then
	print("Usage: upn [install/remove] <package> / about")
	os.exit(1)
end

local function invoke(command)
	local process = io.popen(command)
	local result = process:read("*a")
	process:close()
	return result
end

if tonumber(os.execute('test -f "/var/upn"')) == 1 then
	os.execute("sudo mkdir /var/upn")
end

if tonumber(os.execute('test -f "/var/upn/default-repository"')) == 1 then
	os.execute("sudo touch /var/upn/default-repository")
end

if action == "install" then
	local pkg = arg[2]
	if pkg == nil then
		print("\27[31mError:\27[0m No package name supplied.")
		os.exit(1)
	end
	print("Installing package " .. pkg)
	print("Checking for package...")
	local result = invoke("curl -s https://alexflax.xyz/api/upn/index.php\\?method\\=get\\&name\\=" .. pkg)
	print(result)
	local res_json = cjson.decode(result)
	if res_json.location == "PKG_NOT_FOUND" then
		print("\27[31mError:\27[0m Package '" .. pkg .. "' was not found in the UPN database.")
		os.exit(1)
	end
	io.write("\n")
	print("Package '" .. pkg .. "' was found in the UPN database.")
	print("Package will be installed from: " .. res_json.location)
	print("Package will be installed to the following directory: " .. res_json.install_location)

	local pkg_install_name = string.match(res_json.location, "/([^/]+)$")

	if res_json.postinstall ~= "" then
		print("Package will run the following post install commands:")
		print(res_json.postinstall)
	end

	io.write("Are you sure you want to install '" .. pkg .. "'? (y/n) ")
	local yn = io.read("*l")
	if string.lower(yn) ~= "y" then
		os.exit(0)
	end

	print("Downloading using cURL...")
	local result = os.execute("curl -o " .. res_json.install_location .. pkg_install_name .. " " .. res_json.location)

	os.execute("chmod o+x " .. res_json.install_location .. pkg_install_name)
	if res_json.postinstall ~= "" then
		print("Running post install commands...")
		os.execute(res_json.postinstall)
	end

	os.execute("touch /var/upn/" .. pkg .. ".rmv")

	local file = io.open("/var/upn/" .. pkg .. ".rmv", "w")
	file:write(res_json.remove)
	file:close()
	
	print("Package '" .. pkg .. "' successfully installed.")
elseif action == "remove" then
	local pkg = arg[2]
	if pkg == nil then
		print("\27[31mError:\27[0m No package name supplied.")
		os.exit(1)
	end

	local file = io.open("/var/upn/" .. pkg .. ".rmv")
	if file == nil then
		print("\27[31mError:\27[0m Package '" .. pkg .. "' not installed.")
		os.exit(1)
	end
	local command = file:read("*a")
	file:close()

	print("Package will run the following command to uninstall:")
	print(command)

	io.write("Are you sure you want to uninstall package '" .. pkg .. "'? (y/n) ")
	local yn = io.read("*l")

	if string.lower(yn) ~= "y" then
		os.exit(0)
	end

	print("Uninstalling package '" .. pkg .. "'")

	os.execute(command)

	os.execute("rm /var/upn/" .. pkg .. ".rmv")

	print("Successfully uninstalled package '" .. pkg .. "'")
elseif action == "about" then
	print(upn_ascii_real)
	print("The Unified Package Network is a simple package manager written in Lua made for Linux, MacOS, and Windows.")
	print("Created by alexfdev0 at https://github.com/alexfdev0")
elseif action == "add-repository" then
	local link = arg[2]
	local name = arg[3]
	if not link or not name then
		print("\27[31mError:\27[0m Missing arguments.")
	end

	print("Adding repository '" .. name .. "' with the URL '" .. link .. "'")

	if tonumber(os.execute("test -f /var/upn/repositories")) == 1 then
		os.execute("sudo touch /var/upn/repositories")
	end

	os.execute("sudo echo '" .. name .. "' >> /var/upn/repositories")
	os.execute("sudo touch /var/upn/" .. name .. ".rep")
	os.execute("sudo echo '" .. link .. "' > /var/upn/" .. name .. ".rep")
	print("Successfully added repository '" .. name .. "'")
elseif action == "make-default" then
	local name = arg[1]
	if not name then
		print("\27[31mError:\27[0m Missing name.")
		os.exit(1)
	end

	if tonumber(os.execute("test -f '/var/upn/" .. name .. ".rep'")) == 1 then
		print("\27[31mError:\27[0m Repository '" .. name .. "' does not exist on your system.")
		os.exit(1)
	end

	os.execute("sudo echo '" .. name .. "' > /var/upn/default-repository")
else
	print("\27[31mError:\27[0m Invalid action '" .. action .. "'")
end
