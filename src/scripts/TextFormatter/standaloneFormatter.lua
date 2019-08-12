demonnic = demonnic or {}
demonnic.text = {}

function demonnic:wordWrap(str, limit, indent, indent1)
  -- pulled from http://lua-users.org/wiki/StringRecipes
  indent = indent or ""
  indent1 = indent1 or indent
  limit = limit or 72
  local here = 1-#indent1
  local function check(sp, st, word, fi)
    if fi - here > limit then
      here = st - #indent
      return "\n"..indent..word
    end
  end
  return indent1..str:gsub("(%s+)()(%S+)()", check)
end

function demonnic:fText(str, opts)
  local options = demonnic:fixFormatOptions(str, opts)  
  if options.wrap and (options.strLen > options.effWidth) then
    local wrapped = demonnic:wordWrap(str, options.effWidth)
    local lines = wrapped:split("\n")
    local formatted = {}
		options.fixed = false
    for _,line in ipairs(lines) do
      table.insert(formatted, demonnic:fLine(line, options))
    end
    return table.concat(formatted, "\n")
  else
    return demonnic:fLine(str, options)
  end
end

function demonnic:fixFormatOptions(str, opts)
  if opts.fixed then return table.deepcopy(opts) end
  --Set up all the things we might call the different echo types
  local dec = {"d", "decimal", "dec"}
  local hex = {"h", "hexidecimal", "hex"}
  local col = {"c", "color", "colour", "col", "name"}
  if opts == nil then opts = {} end -- don't overwrite options if they passed them
  --but if they passed something other than a table as the options than oopsie!
  if type(opts) ~= "table" then 
    error("Improper argument: options expected to be passed as table") 
  end
  --now we make a copy of the table, so we don't edit the original during all this
  local options = table.deepcopy(opts)
  if options.wrap == nil then options.wrap = true end --wrap by default.
  options.formatType = options.formatType or "" --by default, no color formatting.
  options.width = options.width or 80 --default 80 width
  options.cap = options.cap or "" --no cap by default
  options.spacer = options.spacer or " " --default spacer is the space character
  options.alignment = options.alignment or "center" --default alignment is centered
  if options.nogap == nil then options.nogap = false end
  if options.inside == nil then options.inside = false end --by default, we don't put the spacer inside
  if not options.mirror == false then options.mirror = options.mirror or true end--by default, we do want to use mirroring for the caps
  --setup default options for colors based on the color formatting type
  if table.contains(dec, options.formatType) then
    options.capColor = options.capColor or "<255,255,255>"
    options.spacerColor = options.spacerColor or "<255,255,255>"
    options.textColor = options.textColor or "<255,255,255>"
    options.colorReset = "<r>"
    options.colorPattern = "<%d+,%d+,%d+:?%d*,?%d*,?%d*>"
  elseif table.contains(hex, options.formatType) then
    options.capColor = options.capColor or "#FFFFFF"
    options.spacerColor = options.spacerColor or "#FFFFFF"
    options.textColor = options.textColor or "#FFFFFF"
    options.colorReset = "#r"
    options.colorPattern = 'c|%d%d%d%d%d%d'
  elseif table.contains(col, options.formatType) then
    options.capColor = options.capColor or "<white>"
    options.spacerColor = options.spacerColor or "<white>"
    options.textColor = options.textColor or "<white>"
    options.colorReset = "<reset>"
    options.colorPattern = "<%w*_?%w*:?%w*_?%w*>"
  else
    options.capColor = ""
    options.spacerColor = ""
    options.textColor = ""
    options.colorReset = ""
    options.colorPattern = ""
  end
  options.originalString = str
  options.strippedString = str:gsub(options.colorPattern, "")
  options.strLen = string.len(options.strippedString)
  options.leftCap = options.cap
	options.rightCap = options.cap
  options.leftPadLen = math.floor((options.width - options.strLen)/2,1) - 1
  options.rightPadLen = options.leftPadLen + ((options.width - options.strLen)%2)
  options.maxPad = 0
  options.capLen = string.len(options.cap)
  options.effWidth = options.width - ((options.capLen * 2) + 2)
  if options.capLen > options.leftPadLen then
    options.cap = options.cap:sub(1, leftPadLen)
    options.capLen = string.len(options.cap)
  end
  options.fixed = true
  return options
end

function demonnic:fLine(str,opts)
  local options = demonnic:fixFormatOptions(str,opts)
  local strippedString = options.strippedString
  local strLen = options.strLen
  local leftCap = options.leftCap
  local rightCap = options.rightCap
  local leftPadLen = options.leftPadLen
  local rightPadLen = options.rightPadLen
  local maxPad = options.maxPad
  local capLen = options.capLen

  if options.alignment == "center" then --we're going to center something
    if options.mirror then --if we're reversing the left cap and the right cap (IE {{[[ turns into ]]}} )
      rightCap = string.gsub(rightCap, "<", ">")
      rightCap = string.gsub(rightCap, "%[", "%]")
      rightCap = string.gsub(rightCap, "{", "}")
      rightCap = string.gsub(rightCap, "%(", "%)")
      rightCap = string.reverse(rightCap)
    end --otherwise, they'll be the same, so don't do anything
    if not options.nogap then str = string.format(" %s ", str) end
    
  elseif options.alignment == "right" then --we'll right-align the text
    leftPadLen = leftPadLen + rightPadLen
    rightPadLen = 0
    rightCap = ""
    if not options.nogap then str = string.format(" %s", str) end
    
  else --Ok, so if it's not center or right, we assume it's left. We don't do justified. Sorry.
    rightPadLen = rightPadLen + leftPadLen
    leftPadLen = 0
    leftCap = ""
    if not options.nogap then str = string.format("%s ", str) end
  end--that's it, took care of both left, right, and center formattings, now to output the durn thing. 
  local fullLeftCap = string.format("%s%s%s", options.capColor, leftCap, options.colorReset)
  local fullLeftSpacer = string.format("%s%s%s", options.spacerColor, string.rep(options.spacer, (leftPadLen - capLen)), options.colorReset)
  local fullText = string.format("%s%s%s", options.textColor, str, options.colorReset)
  local fullRightSpacer = string.format("%s%s%s", options.spacerColor, string.rep(options.spacer, (rightPadLen - capLen)), options.colorReset)
  local fullRightCap = string.format("%s%s%s", options.capColor, rightCap, options.colorReset)

  if options.inside then 
  -- "endcap===== some text =====endcap"
  -- "endcap===== some text =====pacdne" 
  -- "endcap================= some text" 
  -- "some text =================endcap"
    local finalString = string.format("%s%s%s%s%s", fullLeftCap, fullLeftSpacer, fullText, fullRightSpacer, fullRightCap)
    return finalString
  else 
  --"=====endcap some text endcap=====" 
  --"=====endcap some text pacdne====="
  --"=================endcap some text" 
  --"some text endcap================="

    local finalString = string.format("%s%s%s%s%s", fullLeftSpacer, fullLeftCap, fullText, fullRightCap, fullRightSpacer)
    return finalString
  end
end

function demonnic:align(str, opts)
  local options = {}
  if opts == nil then
    opts = {}
  end
  if type(opts) == "table" then
    options = table.deepcopy(opts)
    options.formatType = ""
		options.wrap = false
  else
    error("Improper argument: options expected to be passed as table") 
  end
  options = demonnic:fixFormatOptions(str, options)
  return demonnic:fLine(str, options)
end

function demonnic:dalign(str, opts)
  local options = {}
  if opts == nil then
    opts = {}
  end
  if type(opts) == "table" then
    options = table.deepcopy(opts)
    options.formatType = "d"
    options.wrap = false
  else
    error("Improper argument: options expected to be passed as table") 
  end
  options = demonnic:fixFormatOptions(str, options)
  return demonnic:fLine(str, options)
end

function demonnic:calign(str, opts)
  local options = {}
  if opts == nil then
    opts = {}
  end
  if type(opts) == "table" then
    options = table.deepcopy(opts)
    options.formatType = "c"
    options.wrap = false
  else
    error("Improper argument: options expected to be passed as table") 
  end
  options = demonnic:fixFormatOptions(str, options)
  return demonnic:fLine(str, options)
end

function demonnic:halign(str, opts)
  local options = {}
  if opts == nil then
    opts = {}
  end
  if type(opts) == "table" then
    options = table.deepcopy(opts)
    options.formatType = "h"
    options.wrap = false
  else
    error("Improper argument: options expected to be passed as table") 
  end
  options = demonnic:fixFormatOptions(str, options)
  return demonnic:fLine(str, options)
end

function demonnic:cfText(str, opts)
  local options = {}
  if opts == nil then opts = {} end
  if type(opts) == "table" then
    options = table.deepcopy(opts)
    options.formatType = "c"
  else
    error("Improper argument: options expected to be passed as table") 
  end
  options = demonnic:fixFormatOptions(str, options)
  return demonnic:fText(str, options)
end

function demonnic:dfText(str, opts)
  local options = {}
  if opts == nil then opts = {} end
  if type(opts) == "table" then
    options = table.deepcopy(opts)
    options.formatType = "d"
  else
    error("Improper argument: options expected to be passed as table") 
  end
  options = demonnic:fixFormatOptions(str, options)
  return demonnic:fText(str, options)
end

function demonnic:hfText(str, opts)
  local options = {}
  if opts == nil then opts = {} end
  if type(opts) == "table" then
    options = table.deepcopy(opts)
    options.formatType = "h"
  else
    error("Improper argument: options expected to be passed as table") 
  end
  options = demonnic:fixFormatOptions(str, options)
  return demonnic:fText(str, options)
end

function demonnic:test_ftext()
  local testString = "This is a test of the emergency broadcast system. This is only a test. If this had been a real emergency, we would have given you more sensible information after this. But this was only a test."
  
  local nTable = {width = 40, cap = "(CAP)", inside = true, alignment = 'center'}
  local cTable = table.deepcopy(nTable)
    cTable.formatType="c"
    cTable.capColor = "<red:black>"
    cTable.spacerColor = "<purple:green>"
    cTable.textColor = "<purple:green>"
  
  local dTable = table.deepcopy(nTable)
    dTable.formatType="d"
    dTable.capColor = "<0,0,182>"
    dTable.spacerColor = "<0,182,0>"
    dTable.textColor = "<182,0,0>"
  
  local hTable = table.deepcopy(nTable)
    hTable.formatType="h"
    hTable.capColor = "#FF0000"
    hTable.spacerColor = "#00FF00"
    hTable.textColor = "#0000FF"
  echo(string.rep("\n", 5))
  echo("With word wrap:\n")
  echo(demonnic:fText(testString, nTable) .. "\n")
  cecho(demonnic:fText(testString, cTable) .. "\n")
  decho(demonnic:fText(testString, dTable) .. "\n")
  hecho(demonnic:fText(testString, hTable) .. "\n")

  echo("\n\nWithout word wrap:\n")
  echo(demonnic:align(testString, nTable) .. "\n")
  decho(demonnic:dalign(testString, dTable) .. "\n")
  cecho(demonnic:calign(testString, cTable) .. "\n")
  hecho(demonnic:halign(testString, hTable) .. "\n")
end