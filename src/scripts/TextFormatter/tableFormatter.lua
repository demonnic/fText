--- Easy formatting for text tables
-- @module demonnic.TableMaker

demonnic.TableMaker = {
  headCharacter = "*",
  footCharacter = "*",
  edgeCharacter = "*",
  rowSeparator = "-",
  separator = "|",
  colorReset = "<reset>",
  formatType = "c",
  printHeaders = true,
  autoEcho = false,
}

function demonnic.TableMaker:checkPosition(position, func)
  if position == nil then position = 0 end
  if type(position) ~= "number" then
    if tonumber(position) then
      position = tonumber(position)
    else
      error(func .. ": Argument error: position expected as number, got " .. type(position))
    end
  end
  return position
end

function demonnic.TableMaker:insert(tbl, pos, item)
  if pos ~= 0 then
    table.insert(tbl, pos, item)
  else
    table.insert(tbl, item)
  end
end

function demonnic.TableMaker:addColumn(options, position)
  if options == nil then options = {} end
  if not type(options) == "table" then error("demonnic.TableMaker:addColumn(options, position): Argument error: options expected as table, got " .. type(options)) end
  local options = table.deepcopy(options)
  position = self:checkPosition(position, "demonnic.TableMaker:addColumn(options, position)")
  options.width = options.width or 20
  options.name = options.name or ""
  local formatter = demonnic.TextFormatter:new(options)
  self:insert(self.columns, position, formatter)
end

function demonnic.TableMaker:deleteColumn(position)
  if position == nil then error("demonnic.TableMaker:deleteColumn(position): Argument Error: position as number expected, got nil") end
  position = self:checkPosition(position)
  local maxColumn = #self.columns
  if position > maxColumn then error("demonnic.TableMaker:deleteColumn(position): Argument Error: position provided was larger than number of columns in the table. Number of columns: " .. #self.columns) end
  table.remove(self.columns, position)
end

function demonnic.TableMaker:replaceColumn(options, position)
  if position == nil then
    error("demonnic.TableMaker:replaceColumn(options, position): Argument error: position as number expected, got nil")
  end
  position = self:checkPosition(position)
  if type(options) ~= "table" then error("demonnic.TableMaker:replaceColumn(options, position): Argument error: options as table expected, got " .. type(options)) end
  if #self.columns < position then error("demonnic.TableMaker:replaceColumn(options, position): you cannot specify a position higher than the number of columns currently in the TableMaker. You sent:" .. position .. " and there are: " .. #self.columns .. "columns in the TableMaker") end
  options.width = options.width or 20
  options.name = options.name or ""
  local formatter = demonnic.TextFormatter:new(options)
  self.columns[position] = formatter
end

function demonnic.TableMaker:addRow(columnEntries, position)
  local columnEntriesType = type(columnEntries)
  if columnEntriesType ~= "table" then
    error("demonnic.TableMaker:addRow(columnEntries, position): Argument error, columnEntries expected as table, got " .. columnEntriesType)
  end
  for _,entry in ipairs(columnEntries) do
    local entryCheck = self:checkEntry(entry)
    if entryCheck == 0 then
      if type(entry) == "function" then
        error("demonnic.TableMaker:addRow(columnEntries, position): Argument Error, you provided a function for a columnEntry but it does not return a string. We need a string. It was entry number " .. _ .. "in columnEntries")
      else
        error("demonnic.TableMaker:addRow(columnEntries, position): Argument error, columnEntries items expected as string, got:" .. type(entry)) 
      end
    end
  end
  position = self:checkPosition(position, "demonnic.TableMaker:addRow(columnEntries, position)")
  self:insert(self.rows, position, columnEntries)
end

function demonnic.TableMaker:deleteRow(position)
  if position == nil then error("demonnic.TableMaker:deleteRow(position): Argument Error: position as number expected, got nil") end
  position = self:checkPosition(position, "demonnic.TableMaker:deleteRow(position)")
  local maxRow = #self.rows
  if position > maxRow then error("demonnic.TableMaker:deleteRow(position): Argument Error: position given was > the number of rows we have # of rows is:" .. maxRow) end
  table.remove(self.rows, position)
end

function demonnic.TableMaker:replaceRow(columnEntries, position)
  if position == nil then
    error("demonnic.TableMaker:replaceRow(columnEntries, position): ArgumentError: position expected as number, received nil")
  end
  position = self:checkPosition(position, "demonnic.TableMaker:replaceRow(columnEntries, position)")
  if #self.rows < position then
    error("demonnic.TableMaker:replaceRow(columnEntries, position): position cannot be greater than the number of rows already in the tablemaker. You provided: " .. position .. " and there are " .. #self.rows .. "rows in the TableMaker")
  end
  for _,entry in ipairs(columnEntries) do
    local entryCheck = self:checkEntry(entry)
    if entryCheck == 0 then
      if type(entry) == "function" then
        error("demonnic.TableMaker:replaceRow(columnEntries, position): Argument Error: you provided a function for a columnEntry but it does not return a string. We need a string. It was entry number " .. _ .. "in columnEntries")
      else
        error("demonnic.TableMaker:replaceRow(columnEntries, position): Argument error: columnEntries items expected as string, got:" .. type(entry))
      end
    end
  end
  self.rows[position] = columnEntries
end

function demonnic.TableMaker:checkEntry(entry)
  if self.allowPopups then
    local entryType = type(entry)
    if entryType == "function" then
      local entryReturnType = type(entry())
      if entryReturnType ~= "string" and entryReturnType ~= "table" then
        entry = 0
      end
    elseif entryType ~= "string" and entryType ~= "table" then
      entry = 0
    end
    return entry
  else
    if type(entry) ~= "string" then
      if type(entry) == "function" then
        local entryReturn = entry()
        if type(entryReturn) ~= "string" and not tostring(entryReturn) then entry = 0 end
      elseif not tostring(entry) then
        entry = 0
      end
    end
    return entry
  end
end

function demonnic.TableMaker:checkNumber(num)
  if num == nil then num = 0 end
  if not tonumber(num) then num = 0 end
  return tonumber(num)
end

function demonnic.TableMaker:setCell(row, column, entry)
  local maxRow = #self.rows
  local maxColumn = #self.columns
  local ae = "demonnic.TableMaker:setCell(row, column, entry): Argument Error:"
  row = self:checkNumber(row)
  if row == 0 then error(ae .. " row must be a number, you provided " .. type(row)) end
  column = self:checkNumber(column)
  if column == 0 then error(ae .. " column must be a number, you provided " .. type(column)) end
  if row > maxRow then error(ae .. " row is higher than the number of rows in the table. Highest row:" .. maxRow) end
  if column > maxColumn then error(ae .. " column is higher than the number of columns in the table. Highest column:" .. maxColumn) end
  local entryType = type(entry)
  entry = self:checkEntry(entry)
  if entry == 0 then
    if type(entry) == "function" then 
      error(ae .. " entry was provided as a function, but does not return a string. We need a string in the end")
    else 
      error("demonnic.TableMaker:setCell(row, column, entry): Argument Error: entry must be a string, or a function which returns a string. You provided a " .. entryType)
    end
  end
  self.rows[row][column] = entry
end

function demonnic.TableMaker:totalWidth()
  local width = 0
  local numberOfColumns = #self.columns
  local separatorWidth = string.len(self.separator)
  local edgeWidth = string.len(self.edgeCharacter) * 2
  for _,column in ipairs(self.columns) do
    width = width + column.options.width
  end
  separatorWidth = separatorWidth * (numberOfColumns - 1)
  width = width + edgeWidth + separatorWidth
  return width
end

function demonnic.TableMaker:getType()
  local dec = {"d", "decimal", "dec"}
  local hex = {"h", "hexidecimal", "hex"}
  local col = {"c", "color", "colour", "col", "name"}
  if table.contains(dec, self.formatType) then
    return 'd'
  elseif table.contains(hex, self.formatType) then
    return 'h'
  elseif table.contains(col, self.formatType) then
    return 'c'
  else
    return ''
  end
end

function demonnic.TableMaker:echo(message, echoType, ...)
  local fType = self:getType()
  local consoleType = type(self.autoEchoConsole)
  local console = ""
  if echoType == nil then echoType = "" end
  if consoleType == "string" then
    console = self.autoEchoConsole
  else
    console = self.autoEchoConsole.name
  end
  local functionName = string.format("%secho%s", fType, echoType)
  local func = _G[functionName]
  if fType == "" then formatted = false end
  if echoType == "" then
    func(console, message)
  else
    func(console, message, ...)
  end
end

function demonnic.TableMaker:scanRow(rowToScan)
  local row = table.deepcopy(rowToScan)
  local rowEntries = #row
  local numberOfColumns = #self.columns
  local columns = {}
  local linesInRow = 0
  local rowText = ""
  local ec = self.frameColor .. self.edgeCharacter .. self.colorReset
  local sep = self.separatorColor .. self.separator .. self.colorReset

  if rowEntries < numberOfColumns then
    entriesNeeded = numberOfColumns - rowEntries
    for i = 1,entriesNeeded do
      table.insert(row, "")
    end
  end
  for index,formatter in ipairs(self.columns) do
    local str = row[index]
    local column = ""
    if type(str) == "function" then str = str() end
    column = formatter:format(str)
    table.insert(columns, column:split("\n"))
  end
  for _,rowLines in ipairs(columns) do
    if linesInRow < #rowLines then linesInRow = #rowLines end
  end
  for index,rowLines in ipairs(columns) do
    if #rowLines < linesInRow then
      local neededLines = linesInRow - #rowLines
      for i=1,neededLines do
        table.insert(rowLines, self.columns[index]:format(""))
      end
    end
  end
  for i= 1,linesInRow do
    local thisLine = ec
    for index,column in ipairs(columns) do
      if index == 1 then
        thisLine = string.format("%s%s", thisLine, column[i])
      else
        thisLine = string.format("%s%s%s", thisLine, sep, column[i])
      end
    end
    thisLine = string.format("%s%s", thisLine, ec)
    if rowText == "" then
      rowText = thisLine
    else
      rowText = string.format("%s\n%s", rowText, thisLine)
    end
  end
  return rowText
end

function demonnic.TableMaker:echoRow(rowToScan)
  local row = table.deepcopy(rowToScan)
  local rowEntries = #row
  local numberOfColumns = #self.columns
  local columns = {}
  local linesInRow = 0
  local ec = self.frameColor .. self.edgeCharacter .. self.colorReset
  local sep = self.separatorColor .. self.separator .. self.colorReset
  if rowEntries < numberOfColumns then
    entriesNeeded = numberOfColumns - rowEntries
    for i = 1,entriesNeeded do
      table.insert(row, "")
    end
  end
  for index,formatter in ipairs(self.columns) do
    local str = row[index]
    local column = ""
    if type(str) == "function" then str = str() end
    if type(str) == "table" then 
      str = str[1]
    end
    column = formatter:format(str)
    table.insert(columns, column:split("\n"))
  end
  for _,rowLines in ipairs(columns) do
    if linesInRow < #rowLines then linesInRow = #rowLines end
  end
  for index,rowLines in ipairs(columns) do
    if #rowLines < linesInRow then
      local neededLines = linesInRow - #rowLines
      for i=1,neededLines do
        table.insert(rowLines, self.columns[index]:format(""))
      end
    end
  end
  for i= 1,linesInRow do
    self:echo(ec)
    for index,column in ipairs(columns) do
      local message = column[i]
      if index ~= 1 then 
        self:echo(sep)
      end
      if type(row[index]) == "string" then
        self:echo(message)
      elseif type(row[index]) == "table" then
        local rowEntry = row[index]
        local echoType = ""
        if type(rowEntry[2]) == "string" then
          echoType = "Link"
        elseif type(rowEntry[2]) == "table" then
          echoType = "Popup"
        end
        self:echo(message, echoType, rowEntry[2], rowEntry[3], rowEntry[4] or true)
      end
    end
    self:echo(ec)
    if i ~= linesInRow then
      self:echo("\n")
    end
  end
end

function demonnic.TableMaker:makeHeader()
  local totalWidth = self:totalWidth()
  local ec = self.frameColor .. self.edgeCharacter .. self.colorReset
  local sep = self.separatorColor .. self.separator .. self.colorReset
  local header = self.frameColor .. string.rep(self.headCharacter, totalWidth) .. self.colorReset
  local columnHeaders = ""
  if self.printHeaders then
    local columnEntries = {}
    for _,v in ipairs(self.columns) do
      table.insert(columnEntries, v:format(v.options.name))
    end
    local divWithNewlines = string.format("\n%s", self:createRowDivider())
    columnHeaders = string.format("\n%s%s%s%s", ec, table.concat(columnEntries, sep), ec, divWithNewlines)
  end
  header = string.format("%s%s", header, columnHeaders)
  return header
end

function demonnic.TableMaker:createRowDivider()
  local columnPieces = {}
  for _,v in ipairs(self.columns) do
    local piece = string.format("%s%s%s", self.separatorColor, string.rep(self.rowSeparator, v.options.width), self.colorReset)
    table.insert(columnPieces, piece)
  end
  local ec = self.frameColor .. self.edgeCharacter .. self.colorReset
  local sep = self.separatorColor .. self.separator .. self.colorReset
  return string.format("%s%s%s", ec, table.concat(columnPieces, sep), ec)
end

function demonnic.TableMaker:enablePopups()
  local funcName = "demonnic.TableMaker:enablePopups()"
  if not self.autoEchoConsole then
    error(funcName .. ": Cannot enable popups when autoEchoConsole is not set. please run :setAutoEchoConsole(console) before enabling popups")
  else
    self.allowPopups = true
  end
end

function demonnic.TableMaker:enableAutoEcho()
  self.autoEcho = true
end

function demonnic.TableMaker:disableAutoEcho()
  self.autoEcho = false
end

function demonnic.TableMaker:setAutoEchoConsole(console)
  local funcName = "demonnic.TableMaker:setAutoEchoConsole(console)"
  if console == nil then 
    console = "main" 
  end
  local consoleType = type(console)
  if consoleType ~= "string" and consoleType ~= "table" then
    error(funcName .. " ArgumentError: console as string or Geyser.MiniConsole expected, got " .. consoleType)
  elseif consoleType == "table" and console.type ~= "miniConsole" then
    error(funcName .. " ArgumentError: console received was a table and may be a Geyser object, but console.type is not miniConsole, it is " .. console.type)
  end
  self.autoEchoConsole = console
end

function demonnic.TableMaker:assemble()
  if self.allowPopups and self.autoEcho then
    self:popupAssemble()
  else
    return self:textAssemble()
  end
end

function demonnic.TableMaker:popupAssemble()
  if self.autoClear then
    local console = self.autoEchoConsole
    if console and console ~= "main" then
      if type(console) == "table" then
        console = console.name
      end
      clearWindow(console)
    end
  end
  local divWithNewLines = string.format("\n%s\n", self:createRowDivider())
  local header = self:makeHeader() .. "\n"
  local footer = string.format("\n%s%s%s\n", self.frameColor, string.rep(self.footCharacter, self:totalWidth()), self.colorReset)
  self:echo(header)
  for _,row in ipairs(self.rows) do
    if _ ~= 1 then
      self:echo(divWithNewLines)
    end
    self:echoRow(row)
  end
  self:echo(footer)
end

function demonnic.TableMaker:textAssemble()
  local sheet = ""
  local rows = {}
  for _,row in ipairs(self.rows) do
    table.insert(rows, self:scanRow(row))
  end
  local divWithNewlines = string.format("\n%s\n", self:createRowDivider())
  local footer = string.format("%s%s%s", self.frameColor, string.rep(self.footCharacter, self:totalWidth()), self.colorReset)
  sheet = string.format("%s\n%s\n%s\n", self:makeHeader(), table.concat(rows, divWithNewlines), footer)
  if self.autoEcho then
    local console = self.autoEchoConsole or "main"
    if type(console) == "table" then console = console.name end
    if self.autoClear and console ~= "main" then
      clearWindow(console)
    end
    self:echo(sheet)
  end
  return sheet
end


function demonnic.TableMaker:new(options)
  local funcName = "emonnic.TableMaker:new(options)"
  local me = {}
  setmetatable(me, self)
  self.__index = self
  if options == nil then options = {} end
  if type(options) ~= "table" then
    error("demonnic.TableMaker:new(options): ArgumentError: options expected as table, got " .. type(options))
  end
  local options = table.deepcopy(options)
  if options.allowPopups == true then
    options.autoEcho = true
  else
    options.allowPopups = false
  end
  local columns = false
  if options.columns then
    if type(options.columns) ~= "table" then error("demonnic.TableMaker:new(options): option error: You provided an options.columns entry of type " .. type(options.columns) .. " and columns must a table with entries suitable for demonnic.TableFormatter:addColumn().") end
    columns = table.deepcopy(options.columns)
    options.columns = nil
  end
  local rows = false
  if options.rows then
    if type(options.rows) ~= "table" then error("demonnic.tableMaker:new(options): option error: You provided an options.rows entry of type " .. type(options.rows) .. " and rows must be a table with entrys suitable for demonnic.TableFormatter:addRow()") end
    rows = table.deepcopy(options.rows)
    options.rows = nil
  end
  for option, value in pairs(options) do
    me[option] = value
  end
  local dec = {"d", "decimal", "dec"}
  local hex = {"h", "hexidecimal", "hex"}
  local col = {"c", "color", "colour", "col", "name"}
  if table.contains(dec, me.formatType) then
    me.frameColor = me.frameColor or "<255,255,255>"
    me.separatorColor = me.separatorColor or me.frameColor
    me.colorReset = "<r>"
  elseif table.contains(hex, me.formatType) then
    me.frameColor = me.frameColor or "#ffffff"
    me.separatorColor = me.separatorColor or me.frameColor
    me.colorReset = "#r"
  elseif table.contains(col, me.formatType) then
    me.frameColor = me.frameColor or "<white>"
    me.separatorColor = me.separatorColor or me.frameColor
    me.colorReset = "<reset>"
  else
    me.frameColor = ""
    me.separatorColor = ""
    me.colorReset = ""
  end
  me.columns = {}
  me.rows = {}
  if columns then
    for _,column in ipairs(columns) do
      me:addColumn(column)
    end
  end
  if rows then
    for _,row in ipairs(rows) do
      me:addRow(row)
    end
  end
  return me
end