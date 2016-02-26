// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Mixins\BiomassMixin.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

BiomassMixin = CreateMixin( BiomassMixin )
BiomassMixin.type = "Biomass"

BiomassMixin.networkVars =
{
}

BiomassMixin.expectedCallbacks =
{
    GetBioMassLevel = ""
}


function BiomassMixin:__initmixin()
end
