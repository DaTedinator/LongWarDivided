class XMBEffect_AddOnslaughtCharges extends XMBEffect_AddAbilityCharges;

var Array<name> MaxIncreaseAbilities;				//	List of ability template names that increase max charges
var int MaxIncreasePerAbility;						//	Amount each MaxIncreaseAbility increases the charge cap

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit NewUnit;
	local XComGameState_Ability AbilityState;
	local XComGameStateHistory History;
	local StateObjectReference ObjRef;
	local name MaxIncreaseAbilityName;
	local StateObjectReference MaxIncreaseAbilityRef;
	local int Charges;
	local XComGameState_Unit UnitState;
	local name UnitValueName;
	
	NewUnit = XComGameState_Unit(kNewTargetState);
	if (NewUnit == none)
		return;

	History = `XCOMHISTORY;
	UnitState = XComGameState_Unit(kNewTargetState);

	if (class'XMBEffectUtilities'.static.SkipForDirectMissionTransfer(ApplyEffectParameters))
		return;

	if (MaxIncreaseAbilities.Length > 0)
	{
		foreach MaxIncreaseAbilities(MaxIncreaseAbilityName)
		{
			MaxIncreaseAbilityRef = UnitState.FindAbility(MaxIncreaseAbilityName);
			if (MaxIncreaseAbilityRef.ObjectID > 0)
			{
				MaxCharges += MaxIncreasePerAbility;
			}
		}
	}

	foreach NewUnit.Abilities(ObjRef)
	{
		AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(ObjRef.ObjectID));
		if (AbilityNames.Find(AbilityState.GetMyTemplateName()) != INDEX_NONE)
		{
			Charges = bAllowUseAmmoAsCharges ? AbilityState.GetCharges() : AbilityState.iCharges;
			UnitValueName = name(AbilityState.GetMyTemplateName() $ "_Charges");
			if (MaxCharges < 0 || Charges < MaxCharges)
			{
				Charges += BonusCharges;
				if (MaxCharges >= 0 && Charges > MaxCharges)
					Charges = MaxCharges;

				SetCharges(AbilityState, Charges, NewGameState);
				NewUnit.SetUnitFloatValue(UnitValueName, Charges, eCleanup_BeginTactical);
			}
		}
	}
}

defaultproperties
{
	MaxIncreasePerAbility = 1
	MaxCharges = 1
}