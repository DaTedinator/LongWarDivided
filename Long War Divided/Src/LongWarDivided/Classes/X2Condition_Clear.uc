class X2Condition_Clear extends X2Condition;

event name CallMeetsCondition(XComGameState_BaseObject kTarget)
{
	local XComGameState_Unit TargetUnit;

	TargetUnit = XComGameState_Unit(kTarget);
	if (TargetUnit == none)
		return 'AA_NotAUnit';

	if (!TargetUnit.GetMyTemplate().bCanBeRevived)
		return 'AA_UnitIsImmune';

	if (TargetUnit.IsBleedingOut())
		return 'AA_Success';

	return 'AA_UnitIsNotDowned'; // Nonstandard AA Code
}

event name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource)
{
	local XComGameState_Unit SourceUnit, TargetUnit;

	SourceUnit = XComGameState_Unit(kSource);
	TargetUnit = XComGameState_Unit(kTarget);

	if (SourceUnit == none || TargetUnit == none)
		return 'AA_NotAUnit';

	if (SourceUnit.ControllingPlayer == TargetUnit.ControllingPlayer)
		return 'AA_Success';

	return 'AA_UnitIsHostile';
}