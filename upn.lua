#!/usr/bin/env lua

--[[
-- Universal Package Manager
-- by alexfdev0
-- Licensed under GNU GPL 3.0
-- NOTE: All packages are user-submitted: if a package is malicious, it is not my fault.
--]]--


local cjson = require("cjson")
local action = arg[1]

if not action then
	print("Please supply an action to do.")
	os.exit(1)
end

local function invoke(command)
	local process = io.popen(command)
	local result = process:read("*a")
	process:close()
	return result
end

if action == "install" then
	local pkg = arg[2]
	if pkg == nil then
		print("No package name supplied.")
		os.exit(1)
	end
	print("Installing package " .. pkg)
	print("Checking for package...")
	local result = invoke("curl -s https://alexflax.xyz/api/upn/index.php\\?method\\=get\\&name\\=" .. pkg)
	print(result)
	local res_json = cjson.decode(result)
	if res_json.location == "PKG_NOT_FOUND" then
		print("Error installing package: Package '" .. pkg .. "' was not found in the UPN database.")
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
	print("Package '" .. pkg .. "' successfully installed.")
else
	print("Invalid action '" .. action .. "'")
end
