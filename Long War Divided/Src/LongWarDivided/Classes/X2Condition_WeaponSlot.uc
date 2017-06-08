class X2Condition_WeaponSlot extends X2Condition;

var EInventorySlot DesiredSlot;
var name WeaponCategory;		//	for Utility slot weapons

event name CallAbilityMeetsCondition(XComGameState_Ability kAbility, XComGameState_BaseObject kTarget)
{
	local XComGameState_Item SourceWeapon;

	SourceWeapon = kAbility.GetSourceWeapon();
	if (SourceWeapon != none)
	{
		if ( SourceWeapon.InventorySlot == DesiredSlot )
		{
			if ( WeaponCategory == '' || WeaponCategory == SourceWeapon.GetWeaponCategory() )
			{
				return 'AA_Success';
			}
		}
	}
	return 'AA_WeaponIncompatible';
}