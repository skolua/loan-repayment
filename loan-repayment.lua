require("iuplua")

-- DEFAULTS ===================================================================
iup.SetGlobal("DEFAULTFONT", "Segoe UI, 12")
iup.SetGlobal("DLGBGCOLOR", "#0000FF")
iup.SetGlobal("DLGFGCOLOR", "#FFFFFF")
iup.SetGlobal("TXTBGCOLOR", "#FFFFFF")
iup.SetGlobal("TXTFGCOLOR", "#000000")

-- ELEMENTS ===================================================================
local s = "50x"
local p = "10x"

local P_Label = iup.label{title="Loan amount ($)", padding=p}
local P = iup.text{value="500000", size=s, padding=p, mask=iup.MASK_UINT}

local I_Label = iup.label{title="Interest rate (% p.a.)", padding=p}
local I = iup.text{value="5.0", size=s, padding=p, mask=iup.MASK_UFLOAT}

local T_Label = iup.label{title="Term (years)", padding=p}
local T = iup.text{value="20", size=s, padding=p, mask=iup.MASK_UINT}

local MR_Label = iup.label{title="Monthly repayment ($)", padding=p}
local MR = iup.text{value="NA", readonly="yes", size=s, padding=p}

-- ELEMENT COMPOSITION ========================================================
local P_ = iup.hbox{P_Label, P}
local I_ = iup.hbox{I_Label, I}
local T_ = iup.hbox{T_Label, T}
local MR_ = iup.hbox{MR_Label, MR}

-- FUNCTIONS ==================================================================
local function Repayment(P,I,T)
    local i = I/100
    local M = (P*i/12)/(1-math.pow((1+(i/12)),(-12*T)))
    return string.format("%.0f", M)
end

local function Calculate()
    local P, I, T = tonumber(P.value), tonumber(I.value), tonumber(T.value)
    if P and I and T then
        local M = Repayment(P,I,T)
        if M:match("nan") or M:match("inf") then
            MR.value = "NA"
        else
            MR.value = M
        end
    else
        MR.value = "NA"
    end
end

-- CALLBACKS ==================================================================
function P:valuechanged_cb() Calculate() end
function I:valuechanged_cb() Calculate() end
function T:valuechanged_cb() Calculate() end

-- MAIN WINDOW ================================================================
local WIN = iup.dialog{title="Loan Repayment", resize="no"}
WIN:append(iup.vbox{P_, I_, T_, MR_, alignment="aright", margin="10x5"})

Calculate()  -- initialise with default values
WIN:show()

iup.MainLoop()
iup.Close()
