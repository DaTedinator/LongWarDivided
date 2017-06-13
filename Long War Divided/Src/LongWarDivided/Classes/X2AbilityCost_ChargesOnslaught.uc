//---------------------------------------------------------------------------------------
//  FILE:    X2AbilityCost_ChargesOnslaught.uc
//
//---------------------------------------------------------------------------------------
class X2AbilityCost_ChargesOnslaught extends X2AbilityCost_ChargesOptional;

simulated function ApplyCost(XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_BaseObject AffectState, XComGameState_Item AffectWeapon, XComGameState NewGameState)
{
	local name OnlyOnHitAbilityName, SharedAbilityName;
	local StateObjectReference OnlyOnHitAbilityRef;
	local StateObjectReference SharedAbilityRef;
	local XComGameState_Unit UnitState;
	local XComGameStateHistory History;
	local XComGameState_Ability SharedAbilityState;
	local int ChargesSpent;
	local name UnitValueName;
	local UnitValue UnitVal;
	local bool _bOnlyOnHit;

	History = `XCOMHISTORY;
	UnitState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(kAbility.OwnerStateObject.ObjectID));
	if (UnitState == None)
		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(kAbility.OwnerStateObject.ObjectID));
	UnitValueName = name(kAbility.GetMyTemplateName() $ "_Charges");
	UnitState.GetUnitValue(UnitValueName, UnitVal);

	_bOnlyOnHit = bOnlyOnHit;
	if (OnlyOnHitAbilities.Length > 0)
	{
		foreach OnlyOnHitAbilities(OnlyOnHitAbilityName)
		{
			OnlyOnHitAbilityRef = UnitState.FindAbility(OnlyOnHitAbilityName);
			if (OnlyOnHitAbilityRef.ObjectID > 0)
			{
				_bOnlyOnHit = true;
			}
		}
	}

	if (_bOnlyOnHit && AbilityContext.IsResultContextMiss())
	{
		return;
	}

	if ( kAbility.iCharges < NumCharges )
	{
		ChargesSpent = kAbility.iCharges;
	}
	else
	{
		ChargesSpent = NumCharges;
	}
	kAbility.iCharges -= ChargesSpent;
	UnitState.SetUnitFloatValue(UnitValueName, UnitVal.fValue - ChargesSpent, eCleanup_BeginTactical);

	if (SharedAbilityCharges.Length > 0)
	{
		foreach SharedAbilityCharges(SharedAbilityName)
		{
			if (SharedAbilityName != kAbility.GetMyTemplateName())
			{
				SharedAbilityRef = UnitState.FindAbility(SharedAbilityName);
				if (SharedAbilityRef.ObjectID > 0)
				{
					SharedAbilityState = XComGameState_Ability(NewGameState.CreateStateObject(class'XComGameState_Ability', SharedAbilityRef.ObjectID));
					SharedAbilityState.iCharges -= ChargesSpent;
					NewGameState.AddStateObject(SharedAbilityState);
				}
			}
		}
	}
}