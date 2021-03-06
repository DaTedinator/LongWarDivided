//---------------------------------------------------------------------------------------
//  FILE:    X2Effect_BonusRocketCharges[LW]
//  AUTHOR:  Amineri (Pavonis Interactive)
//  PURPOSE: General effect for granting extra uses of rocket-type items -- technical class only
//	
//	Ripped almost entirely from LW_Overhaul because I can't get dependencies to work
//	The only edits I made were to avoid having to copy other things (like X2MultiWeaponTemplate)
//--------------------------------------------------------------------------------------- 

class X2Effect_BonusRocketChargesLW extends X2Effect_Persistent;

var int BonusUses;
var EInventorySlot SlotType;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameStateHistory		History;
	local XComGameState_Unit		UnitState; 
	local XComGameState_Item		ItemState, UpdatedItemState;
	//local X2MultiWeaponTemplate		WeaponTemplate;
	local X2WeaponTemplate		WeaponTemplate;
	local int						Idx, BonusAmmo;

	History = `XCOMHISTORY;

	UnitState = XComGameState_Unit(kNewTargetState);
	if (UnitState == none)
		return;

	for (Idx = 0; Idx < UnitState.InventoryItems.Length; ++Idx)
	{
		ItemState = XComGameState_Item(History.GetGameStateForObjectID(UnitState.InventoryItems[Idx].ObjectID));
		if (ItemState != none && !ItemState.bMergedOut)
		{
			//only works for the technical multiweapon
			//WeaponTemplate = X2MultiWeaponTemplate(ItemState.GetMyTemplate());
			WeaponTemplate = X2WeaponTemplate(ItemState.GetMyTemplate());
			if(WeaponTemplate != none)
			{
				BonusAmmo = 0;
				if (WeaponTemplate != none && WeaponTemplate.bMergeAmmo)
				{
					if (ItemState.InventorySlot == SlotType)
						BonusAmmo += BonusUses;
				}
				if(BonusAmmo > 0)
				{
					UpdatedItemState = XComGameState_Item(NewGameState.CreateStateObject(class'XComGameState_Item', ItemState.ObjectID));
					UpdatedItemState.Ammo += BonusAmmo;
					NewGameState.AddStateObject(UpdatedItemState);
				}
			}
		}
	}

	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}

defaultProperties
{
	DuplicateResponse=eDupe_Allow
	bInfiniteDuration = true;
}