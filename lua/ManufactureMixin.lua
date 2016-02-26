// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// lua\ManufactureMixin.lua    
//    
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

ManufactureMixin = CreateMixin(ManufactureMixin)
ManufactureMixin.type = "Manufacture"

ManufactureMixin.networkVars =
{
}

ManufactureMixin.expectedMixins =
{
    TechAction = "Required to display buttons."
}

ManufactureMixin.expectedCallbacks = 
{
}

ManufactureMixin.optionalCallbacks = 
{
}

function ManufactureMixin:__initmixin()

end