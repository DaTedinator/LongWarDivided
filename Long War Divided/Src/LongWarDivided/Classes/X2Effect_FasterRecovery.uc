///---------------------------------------------------------------------------------------
//  FILE:    X2Effect_FasterRecovery
//			 Based on X2Effect_FieldSurgeon
//
//---------------------------------------------------------------------------------------
class X2Effect_FasterRecovery extends X2Effect_Persistent config(LWD2_Abilities);

function UnitEndedTacticalPlay(XComGameState_Effect EffectState, XComGameState_Unit UnitState)
{
	local XComGameStateHistory		History;
	local XComGameState_Unit		SourceUnitState;

	History = `XCOMHISTORY;
	SourceUnitState = XComGameState_Unit(History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	if(!FasterRecoveryEffectIsValidForSource(SourceUnitState)) { return; }

	if(UnitState == none) { return; }
	if(UnitState.IsDead()) { return; }
	if(UnitState.IsBleedingOut()) { return; }
	if(!CanBeHealed(UnitState)) { return; }

	UnitState.LowestHP += 1;

	// Armor HP may have already been removed, apparently healing the unit since we have not yet
	// executed EndTacticalHealthMod. We may only appear injured here for large injuries (or little
	// armor HP). Current HP is used in the EndTacticalHealthMod adjustment, so we should increase it
	// if it's less than the max, but don't exceed the max HP.
	if (UnitState.GetCurrentStat(eStat_HP) < UnitState.GetMaxStat(eStat_HP))
	{
		UnitState.ModifyCurrentStat(eStat_HP, 1);
	}

	super.UnitEndedTacticalPlay(EffectState, UnitState);
}

function bool CanBeHealed(XComGameState_Unit UnitState)
{
	// Note: Only test lowest/highest HP here: CurrentHP cannot be trusted in UnitEndedTacticalPlay because
	// armor HP may have already been removed, but we have not yet invoked the EndTacticalHealthMod adjustment.
	 return (UnitState.LowestHP < UnitState.HighestHP);
}

function bool FasterRecoveryEffectIsValidForSource(XComGameState_Unit SourceUnit)
{
	if(SourceUnit == none) { return false; }
	if(SourceUnit.IsDead()) { return false; }
	//if(SourceUnit.IsBleedingOut()) { return false; }
	if(SourceUnit.bCaptured) { return false; }
	//if(SourceUnit.LowestHP == 0) { return false; }
	//if(SourceUnit.IsUnconscious()) { return false; }
	return true;
}

DefaultProperties
{
	DuplicateResponse=eDupe_Allow
}