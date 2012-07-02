--[[
Copyright (C) 2012 Thomas Farr a.k.a tomass1996 [farr.thomas@gmail.com]

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
copies of the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

-The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-Visible credit is given to the original author.
-The software is distributed in a non-profit way.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

--
-- Created by IntelliJ IDEA.
-- User: Thomas Farr, tomass1996
-- Date: 2/07/12
-- Time: 6:38 PM
--

local inFile
local look = ""
local _VARS = {}
local _STACK = { n = 0 }

local function pop()
    local x = _STACK[_STACK.n]
    _STACK[_STACK.n] = nil
    _STACK.n = _STACK.n - 1
    return x
end

local function push(x)
    _STACK.n = _STACK.n + 1
    _STACK[_STACK.n] = x
end

local _FUNCS = {
    ["PRINT"] = {
        nArgs = 1,
        call = function(bReturn)
            print(pop())
        end
    },
    ["SIN"] = {
        nArgs = 1,
        call = function(bReturn)
            if bReturn then
                push(math.sin(pop()))
            end
        end
    },
    ["COS"] = {
        nArgs = 1,
        call = function(bReturn)
            if bReturn then
                push(math.cos(pop()))
            end
        end
    },
    ["TAN"] = {
        nArgs = 1,
        call = function(bReturn)
            if bReturn then
                push(math.tan(pop()))
            end
        end
    },
    ["DEG"] = {
        nArgs = 1,
        call = function(bReturn)
            if bReturn then
                push(math.deg(pop()))
            end
        end
    },
    ["RAD"] = {
        nArgs = 1,
        call = function(bReturn)
            if bReturn then
                push(math.rad(pop()))
            end
        end
    },
    ["ABS"] = {
        nArgs = 1,
        call = function(bReturn)
            if bReturn then
                push(math.abs(pop()))
            end
        end
    },
    ["CEIL"] = {
        nArgs = 1,
        call = function(bReturn)
            if bReturn then
                push(math.ceil(pop()))
            end
        end
    },
    ["FLOOR"] = {
        nArgs = 1,
        call = function(bReturn)
            if bReturn then
                push(math.floor(pop()))
            end
        end
    },
    ["MIN"] = {
        nArgs = 2,
        call = function(bReturn)
            if bReturn then
                push(math.min(pop(), pop()))
            end
        end
    },
    ["MAX"] = {
        nArgs = 2,
        call = function(bReturn)
            if bReturn then
                push(math.max(pop(), pop()))
            end
        end
    },
    ["SQRT"] = {
        nArgs = 1,
        call = function(bReturn)
            if bReturn then
                push(math.sqrt(pop()))
            end
        end
    },
    ["RAND"] = {
        nArgs = 2,
        call = function(bReturn)
            if bReturn then
                local v2 = pop()
                push(math.random(pop(), v2))
            end
        end
    },
    ["RANDSEED"] = {
        nArgs = 1,
        call = function(bReturn)
            math.randomseed(pop())
        end
    }
}

local function getChar()
    look = inFile:read(1)
end

local function reportError(s)
    print()
    print("Error: ", s .. ".")
end

local function abort(s)
    reportError(s)
    os.exit(1)
end

local function expected(s)
    abort(s .. " Expected")
end

local function newLine()
    while look == "\n" do
        getChar()
    end
end

local function isAlpha(c)
    if not c then return false end
    return string.match(string.upper(c), "%u")
end

local function isDigit(c)
    if not c then return false end
    return string.match(c, "%d")
end

local function isAddop(c)
    return (c == "+") or (c == "-")
end

local function isMulop(c)
    return (c == "*") or (c == "/") or (c == "%")
end

local function isAlNum(c)
    return isAlpha(c) or isDigit(c)
end

local function isWhite(c)
    return (c == " ") or (c == "\t")
end

local function skipWhite()
    while isWhite(look) do
        getChar()
    end
end

local function match(c)
    if look ~= c then
        expected(c)
    else
        getChar()
        skipWhite()
    end
end

local function getName()
    local token = ""
    if not isAlpha(look) then expected("Name") end
    while isAlNum(look) do
        token = token .. string.upper(look)
        getChar()
    end
    skipWhite()
    return token
end

local function getNum()
    local sVal = ""
    if not isDigit(look) then expected("Integer") end
    while isDigit(look) do
        sVal = sVal .. look
        getChar()
    end
    skipWhite()
    return tonumber(sVal)
end

local function init()
    getChar()
    skipWhite()
end

local expression = function() end

local function varOrFunc()
    local name = getName()
    if look == "(" then
        match("(")
        if not _FUNCS[name] then expected("Valid Function Name") end
        local nArgs = _FUNCS[name].nArgs
        for n = 1, nArgs do
            expression()
            if n ~= nArgs then
                match(",")
            end
        end
        match(")")
        _FUNCS[name].call(true)
    elseif name == "PI" then
        push(math.pi)
    else
        push(_VARS[name] or 0)
    end
end

local function factor()
    if look == "(" then
        match("(")
        expression()
        match(")")
    elseif isAlpha(look) then
        varOrFunc()
    elseif look == "?" then
        match("?")
        io.write(">: ")
        local v = io.read("*number")
        if not tonumber(v) then expected("Number Input") end
        push(tonumber(v))
    else
        push(getNum())
    end
end

local function exponent()
    factor()
    while look == "^" do
        if look == "^" then
            match("^")
            factor()
            local v2 = pop()
            push(pop() ^ v2)
        else
            expected("Exponent")
        end
    end
end

local function term()
    exponent()
    while isMulop(look) do
        if look == "*" then
            match("*")
            exponent()
            push(pop() * pop())
        elseif look == "/" then
            match("/")
            exponent()
            local v2 = pop()
            push(pop() / v2)
        elseif look == "%" then
            match("%")
            exponent()
            local v2 = pop()
            push(pop() % v2)
        else
            expected("Mulop")
        end
    end
end

expression = function()
    if isAddop(look) then
        push(0)
    else
        term()
    end
    while isAddop(look) do
        if look == "+" then
            match("+")
            term()
            push(pop() + pop())
        elseif look == "-" then
            match("-")
            term()
            push(-(pop() - pop()))
        else
            expected("Addop")
        end
    end
end

local function line()
    local name = getName()
    if look == "(" then
        match("(")
        if not _FUNCS[name] then expected("Valid Function Name") end
        local nArgs = _FUNCS[name].nArgs
        for n = 1, nArgs do
            expression()
            if n ~= nArgs then
                match(",")
            end
        end
        match(")")
        _FUNCS[name].call(false)
    elseif look == "=" then
        match("=")
        expression()
        _VARS[name] = pop() or 0
    else
        expected("Assignment or Function Call")
    end
end

local function main(fileToInterpret)
    inFile = io.open(fileToInterpret, "r")
    init()
    repeat
        line()
        newLine()
    until look == nil
    inFile:close()
end
