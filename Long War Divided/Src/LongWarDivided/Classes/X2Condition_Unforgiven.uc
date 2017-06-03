//Complete copy/paste of Xylth's X2Condition_FirstStrike
class X2Condition_Unforgiven extends X2Condition;

event name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource)
{
	local XComGameState_Unit SourceUnit, TargetUnit;
	local GameRulesCache_VisibilityInfo VisInfo;

	TargetUnit = XComGameState_Unit(kTarget);
	if (TargetUnit == none)
		return 'AA_NotAUnit';

	SourceUnit = XComGameState_Unit(kSource);
	if (SourceUnit == none)
		return 'AA_NotAUnit';

	if (SourceUnit.IsConcealed())
		return 'AA_Success';

	if (`TACTICALRULES.VisibilityMgr.GetVisibilityInfo(SourceUnit.ObjectID, TargetUnit.ObjectID, VisInfo))
	{	
		if (SourceUnit.CanFlank() && TargetUnit.GetMyTemplate().bCanTakeCover && VisInfo.TargetCover == CT_None)
			return 'AA_Success';
	}

	return 'AA_UnitAlreadySpotted';
}