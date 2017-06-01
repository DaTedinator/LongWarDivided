//---------------------------------------------------------------------------------------
//  FILE:    XMBCondition_CoverType.uc
//  AUTHOR:  xylthixlm
//
//  A condition that restricts the possible cover types the target of an ability can
//  have relative to the shooter.
//
//  USAGE
//
//  XMBAbility provides default instances of this class for common cases:
//
//  default.FullCoverCondition		The target is in full cover
//  default.HalfCoverCondition		The target is in half cover
//  default.NoCoverCondition		The target is not in cover
//  default.FlankedCondition		The target is not in cover and can be flanked
//
//  EXAMPLES
//
//  The following examples in Examples.uc use this class:
//
//  AbsolutelyCritical
//  Assassin
//
//  INSTALLATION
//
//  Install the XModBase core as described in readme.txt. Copy this file, and any files 
//  listed as dependencies, into your mod's Classes/ folder. You may edit this file.
//
//  DEPENDENCIES
//
//  None.
//---------------------------------------------------------------------------------------
class XMBCondition_CoverType extends X2Condition;

var array<ECoverType> AllowedCoverTypes;
var bool bRequireCanTakeCover;

event name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource)
{
	local GameRulesCache_VisibilityInfo VisInfo;
	local XComGameState_Unit TargetUnit;
	local int HistoryIndex;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;
	HistoryIndex = History.GetCurrentHistoryIndex();

	TargetUnit = XComGameState_Unit(kTarget);
	if (TargetUnit != none && !TargetUnit.IsAlive())
	{
		kTarget = History.GetPreviousGameStateForObject(kTarget);
		HistoryIndex = kTarget.GetParentGameState().HistoryIndex;
		TargetUnit = XComGameState_Unit(kTarget);
	}

	if (AllowedCoverTypes.Length > 0)
	{
		if (kTarget == none)
			return 'AA_NoTargets';
		if (!`TACTICALRULES.VisibilityMgr.GetVisibilityInfo(kSource.ObjectID, kTarget.ObjectID, VisInfo, HistoryIndex))
			return 'AA_NotInRange';
		if (AllowedCoverTypes.Find(VisInfo.TargetCover) == INDEX_NONE)
			return 'AA_InvalidTargetCoverType';
	}

	if (bRequireCanTakeCover)
	{
		if (TargetUnit == none)
			return 'AA_NotAUnit';
		if (!TargetUnit.GetMyTemplate().bCanTakeCover)
			return 'AA_InvalidTargetCoverType';
	}
	
	return 'AA_Success';
}