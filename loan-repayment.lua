-- PATH & REQUIRE =============================================================
local LUA_DIR = {[[C:\LuaJIT\lua\?.lua;]], [[C:\LuaJIT\lua\?\?.lua;]]}
local DLL_DIR = {[[C:\LuaJIT\?.dll;]], [[C:\LuaJIT\?51.dll;]]}

for i = 1,#LUA_DIR do package.path = LUA_DIR[i]..package.path end
for i = 1,#DLL_DIR do package.cpath = DLL_DIR[i]..package.cpath end

require("iuplua")

-- DEFAULTS ===================================================================
iup.SetGlobal("DEFAULTFONT", "Segoe UI, 12")
iup.SetGlobal("DLGBGCOLOR", "#0000FF")
iup.SetGlobal("DLGFGCOLOR", "#FFFFFF")
iup.SetGlobal("TXTBGCOLOR", "#FFFFFF")
iup.SetGlobal("TXTFGCOLOR", "#000000")

-- ELEMENTS ===================================================================
local s = "50x"
local p = "10x0"

local P_Label = iup.label{title="Loan amount ($)", padding=p}
local P = iup.text{value="500000", size=s, padding=p}

local I_Label = iup.label{title="Interest rate (% p.a.)", padding=p}
local I = iup.text{value="5.0", size=s, padding=p}

local T_Label = iup.label{title="Term (years)", padding=p}
local T = iup.text{value="20", size=s, padding=p}

local MR_Label = iup.label{title="Monthly repayment ($)", padding=p}
local MR = iup.text{value="NA", readonly="yes", size=s, padding=p}

P.mask = "/d+"                -- uint
I.mask = "(/d+/.?/d*|/./d+)"  -- ufloat
T.mask = "/d+"                -- uint

-- ELEMENT COMPOSITION ========================================================
local P_box = iup.hbox{P_Label, P}
local I_box = iup.hbox{I_Label, I}
local T_box = iup.hbox{T_Label, T}
local MR_box = iup.hbox{MR_Label, MR}

-- FUNCTIONS ==================================================================
local function Repayment(P,I,T)
  local i = I/100  -- %
  local M = (P*i/12)/(1-math.pow((1+(i/12)),(-12*T)))
  return string.format("%.0f", M)
end

local function Reset(M)
  MR.value = M
end

local function Calculate()
  local P, I, T = tonumber(P.value), tonumber(I.value), tonumber(T.value)
  if P and I and T then
    local M = Repayment(P,I,T)
    if M:match("nan") or M:match("inf") then
      Reset("NA")
    else
      Reset(M)
    end
  else
    Reset("NA")
  end
end

-- CALLBACKS ==================================================================
function P:valuechanged_cb() Calculate() end
function I:valuechanged_cb() Calculate() end
function T:valuechanged_cb() Calculate() end

-- MAIN WINDOW ================================================================
local WIN = iup.dialog{title="Loan Repayment"}
WIN:append(iup.vbox{P_box, I_box, T_box, MR_box, alignment="ARIGHT", margin="10x5"})
WIN.resize = "no"

Calculate()  -- initialise with default values
WIN:show()

iup.MainLoop()
iup.Close()
