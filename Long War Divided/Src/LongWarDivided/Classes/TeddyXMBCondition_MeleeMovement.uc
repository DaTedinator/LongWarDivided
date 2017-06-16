class TeddyXMBCondition_MeleeMovement extends X2Condition;

var int MaxMovementRange;		//	Maximum distance in tiles that the unit is allowed to move. Overridden by bBlueMove.
var bool bBlueMove;				//	If true, MaxMovementRange = unit's mobility in tiles.
var float BlueMoveScale;		//	Multiply your mobility by this amount for the purposes of bBlueMove.

var XComGameState_Unit SourceState;

event name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource)
{
	SourceState = XComGameState_Unit(kSource);

	return 'AA_Success';
}

event name CallAbilityMeetsCondition(XComGameState_Ability kAbility, XComGameState_BaseObject kTarget)
{ 
	local XComGameState_Unit TargetState;
	local XGUnit UnitVisualizer;
	local TTile SourceTile, TargetTile;
	local array<TTile> PathArray, DestinationTiles;
	local int Distance, MaxDistance;

	UnitVisualizer = XGUnit(SourceState.GetVisualizer());
	TargetState = XComGameState_Unit(kTarget);

	if( (SourceState == none) || (TargetState == none) )
	{
		return 'AA_NotAUnit';
	}

//	Distance = SourceState.TileDistanceBetween(TargetState);

	SourceTile = SourceState.TileLocation;
	TargetTile = TargetState.TileLocation;	
	
	class'X2AbilityTarget_MovingMelee'.static.SelectAttackTile(SourceState, kTarget, kAbility.GetMyTemplate(), DestinationTiles);

	PathArray.Length = 0;
	//class'X2PathSolver'.static.BuildPath(SourceState, SourceTile, TargetTile, PathArray);
	UnitVisualizer.m_kReachableTilesCache.BuildPathToTile(DestinationTiles[0], PathArray);
	if ( PathArray.Length == 0 )
	{
		return 'AA_NoPath';
	}

	MaxDistance = MaxMovementRange;
	if (bBlueMove)
	{
		MaxDistance = `METERSTOTILES(SourceState.GetCurrentStat(eStat_Mobility)) * BlueMoveScale;
	}

	if ( MaxDistance > -1 && PathArray.Length > MaxDistance )
//	if ( Distance > MaxDistance )
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