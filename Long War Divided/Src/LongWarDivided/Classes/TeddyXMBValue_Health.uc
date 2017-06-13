//---------------------------------------------------------------------------------------
//  FILE:    TeddyXMBValue_Health.uc
//
//---------------------------------------------------------------------------------------
class TeddyXMBValue_Health extends XMBValue;

var bool bTarget;	//	If true, the value should be based on the target rather than the source.
var bool bInvert;	//	If true, the value should be higher the more damaged the target is.
var float fExpo;	//	Defaults to 1.0. The value is brought to this power.
var float fMult;	//	Defaults to 1.0. The value is multiplied by this

simulated function int GetHealthPercentOfUnit(XComGameState_Unit UnitState)
{
	local float HealthPercent;

	HealthPercent = UnitState.GetCurrentStat(eStat_HP) / UnitState.GetMaxStat(eStat_HP);
	if(bInvert) HealthPercent = 1.0 - HealthPercent;

	return (HealthPercent ** fExpo) * fMult;
}

function float GetValue(XComGameState_Effect EffectState, XComGameState_Unit UnitState, XComGameState_Unit TargetState, XComGameState_Ability AbilityState)
{
	if (bTarget)
	{
		return GetHealthPercentOfUnit(TargetState);
	}
	else
	{
		return GetHealthPercentOfUnit(UnitState);
	}
}

defaultproperties
{
	bTarget = false
	bInvert = false
	fExpo = 1.0
	fMult = 1.0
}