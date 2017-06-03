class X2Condition_AbilityCharges extends X2Condition;

var name AbilityName;			//	The ability that needs to meet the minimum charges
var int MinCharges;				//	Minimum charges

event name CallMeetsCondition(XComGameState_BaseObject kTarget) 
{ 
	local XComGameState_Unit		NewUnit;
	local XComGameState_Ability		AbilityState;
	local int Charges;
	local bool FoundAbility;

	FoundAbility = false;

	NewUnit = XComGameState_Unit(kTarget);
	if (NewUnit == none)
		return 'AA_NotAUnit';
	
	foreach NewUnit.Abilities(ObjRef)
	{
		AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(ObjRef.ObjectID));
		if ( AbilityName == AbilityState.GetMyTemplateName() )
		{
			FoundAbility = true;
			Charges = bAllowUseAmmoAsCharges ? AbilityState.GetCharges() : AbilityState.iCharges;
			if ( Charges < MinCharges )
			{
				return 'AA_InsufficientCharges';
			}
		}
	}
	if (!FoundAbility)
	{
		return 'AA_MissingAbility';
	}

	return 'AA_Success'; 
}

defaultproperties
{
	MinCharges = 1
}