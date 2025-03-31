![UPN](https://alexflax.xyz/api/upn/images/upn.png)
# Unified Package Network
UPN is a simple package manager for Linux, MacOS, FreeBSD, and other Unix-like systems that is written in Lua.<br><br>
# Dependencies
* Lua 5.1 or newer<br>
* `luarocks` package manager<br>
* `lua-cjson` from luarocks<br>
* `cURL`<br>
* `make`<br><br>
# Quick Start
To install UPN, run `git clone https://github.com/alexfdev0/upn.git` to clone the repository.<br>
After it's done, go into the `upn` folder and run `make unix` on non-MacOS systems, or `make mac` on MacOS.<br><br>
# Installing packages
Run `sudo upn install <package> <optional repositories>` to install a package from the database to your system.<br>
Run `sudo upn remove <package>` to remove a package from your system.<br><br>
# Managing repositories
By default, the repository installed points to `https://alexflax.xyz/api/upn/`, however, you can add another one to change this.<br>
To add a repository, run `sudo upn add-repository <URL to JSON delivery page> <name>`.<br>
To make it the default, run `sudo upn make-default <name>`<br>
To remove the repository, run `sudo upn remove-repository <name>`<br><br>
# Repository requirements
To make a repository, it must return the following JSON for UPN to work properly:<br><br>

`"location"`: The URL location of where the package executable is stored.<br>
`"postinstall"`: The commands to run after downloading is completed (can be blank for no commands but still present in JSON.)<br>
`"install_location"`: Where the executable will be installed to on the user's system.<br>
`"remove"`: The commands that will be ran to uninstall the package if the user runs `sudo upn remove <name>`.
