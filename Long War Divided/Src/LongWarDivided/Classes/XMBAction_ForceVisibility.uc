//---------------------------------------------------------------------------------------
//  FILE:    XMBAction_ForceVisibility.uc
//  AUTHOR:  xylthixlm
//
//  This visualization action simply sets a unit to be visible until its visibility
//  is next updated.
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
class XMBAction_ForceVisibility extends X2Action;

var bool bEnableOutline;

simulated state Executing
{
Begin:
	Unit.SetForceVisibility(bEnableOutline ? eForceVisible : eForceNone);
	UnitPawn.UpdatePawnVisibility();

	CompleteAction();
}