demonnic = demonnic or {}
if not demonnic.fText then
	local path = package.path
	local home_dir = getMudletHomeDir() .. "/@PKGNAME@"
	local lua_dir = string.format( "%s/%s", home_dir, [[?.lua]] )
	local init_dir = string.format( "%s/%s", home_dir, [[?/init.lua]] )
	package.path = string.format( "%s;%s;%s", path, lua_dir, init_dir )

	local okay, content = pcall( require, "ftext" )
	if okay then
    for key,value in pairs(content) do
      demonnic[key] = value
    end
	else
		debugc(string.format("fText: Error loading module: %s\n", content))
  end
  okay, content = pcall( require, "textformatter")
  if okay then
    demonnic.TextFormatter = content
  else
    debugc(string.format("TextFormatter: Error loading module: %s\n",content))
  end
  okay, content = pcall( require, "tablemaker")
  if okay then
    demonnic.TableMaker = content
  else
    debugc(string.format("TableMaker: Error loading module: %s\n",content))
  end
end
