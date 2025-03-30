SRC=.

unix: $(SRC)/upn.lua
	sudo cp upn.lua /usr/bin/upn
	sudo chmod o+x /usr/bin/upn

mac: $(SRC)/upn.lua
	sudo cp upn.lua /usr/local/bin/upn
	sudo chmod o+x /usr/local/bin/upn