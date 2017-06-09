//---------------------------------------------------------------------------------------
//  FILE:    X2AbilityCost_ChargesOptional.uc
//  PURPOSE: Like X2AbilityCost_Charges, but it doesn't
//			 require any charges. 
//
//---------------------------------------------------------------------------------------
class X2AbilityCost_ChargesOptional extends X2AbilityCost_Charges;

var int MinCharges;						//	The minimum number of charges needed to activate
//var name UnitValueName;					//	The unit value to set to the number of charges spent
var array<name> OnlyOnHitAbilities;		//	Ability names that make bOnlyOnHit true

simulated function name CanAfford(XComGameState_Ability kAbility, XComGameState_Unit ActivatingUnit)
{
	if (kAbility.GetCharges() >= MinCharges)
		return 'AA_Success';

	return 'AA_CannotAfford_Charges';
}

simulated function ApplyCost(XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_BaseObject AffectState, XComGameState_Item AffectWeapon, XComGameState NewGameState)
{
	local name OnlyOnHitAbilityName, SharedAbilityName;
	local StateObjectReference OnlyOnHitAbilityRef;
	local StateObjectReference SharedAbilityRef;
	local XComGameState_Unit UnitState;
	local XComGameStateHistory History;
	local XComGameState_Ability SharedAbilityState;
	local int ChargesSpent;

	History = `XCOMHISTORY;
	UnitState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(kAbility.OwnerStateObject.ObjectID));
	if (UnitState == None)
		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(kAbility.OwnerStateObject.ObjectID));

	if (OnlyOnHitAbilities.Length > 0)
	{
		foreach OnlyOnHitAbilities(OnlyOnHitAbilityName)
		{
			OnlyOnHitAbilityRef = UnitState.FindAbility(OnlyOnHitAbilityName);
			if (OnlyOnHitAbilityRef.ObjectID > 0)
			{
				bOnlyOnHit = true;
			}
		}
	}

	if (bOnlyOnHit && AbilityContext.IsResultContextMiss())
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
	//UnitState.SetUnitFloatValue(UnitValueName, ChargesSpent, eCleanup_BeginTurn);

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

DefaultProperties
{
	MinCharges = 0
}