//---------------------------------------------------------------------------------------
//  FILE:    X2Condition_Concealed.uc
//  PURPOSE: Checks if the unit is currently concealed
//           
//---------------------------------------------------------------------------------------
class X2Condition_Concealed extends X2Condition;

event name CallMeetsCondition(XComGameState_BaseObject kTarget) 
{ 
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(kTarget);

	if (UnitState == none)
		return 'AA_NotAUnit';

	if (!UnitState.IsConcealed())
		return 'AA_UnitIsRevealed';

	return 'AA_Success'; 
}