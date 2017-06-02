class TeddyXMBCondition_MeleeMovement extends X2Condition;

var int MaxMovementRange;		//	Maximum distance in tiles that the unit is allowed to move. Overridden by bBlueMove.
var bool bBlueMove;				//	If true, MaxMovementRange = unit's mobility in tiles.
var float BlueMoveScale;		//	Multiply your mobility by this amount for the purposes of bBlueMove.

event name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource)
{ 
	local XComGameState_Unit SourceState, TargetState;
	local TTile SourceTile, TargetTile;
	local array<TTile> PathArray;

	SourceState = XComGameState_Unit(kSource);
	TargetState = XComGameState_Unit(kTarget);

	if( (SourceState == none) || (TargetState == none) )
	{
		return 'AA_NotAUnit';
	}

	SourceState.GetKeystoneVisibilityLocation(SourceTile);
	TargetState.GetKeystoneVisibilityLocation(TargetTile);

	class'X2PathSolver'.static.BuildPath(SourceState, SourceTile, TargetTile, PathArray);

	if (bBlueMove)
	{
		MaxMovementRange = `METERSTOTILES(SourceState.GetCurrentStat(eStat_Mobility) * BlueMoveScale);
	}

	if ( MaxMovementRange > -1 && PathArray.Length > MaxMovementRange )
	{
		return 'AA_OutOfRange';
	}

	return 'AA_Success'; 
}

defaultproperties
{
	MaxMovementRange = -1
	bBlueMove = false
	BlueMoveScale = 1.0
}