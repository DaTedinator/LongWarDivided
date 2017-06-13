class X2Condition_WeaponSlot extends X2Condition;

var EInventorySlot DesiredSlot;
var name WeaponCategory;

event name CallAbilityMeetsCondition(XComGameState_Ability kAbility, XComGameState_BaseObject kTarget)
{
	local XComGameState_Item SourceWeapon;
	local X2WeaponTemplate WeaponTemplate;

	SourceWeapon = kAbility.GetSourceWeapon();
	WeaponTemplate = X2WeaponTemplate(SourceWeapon.GetMyTemplate());
	if (SourceWeapon != none)
	{
		if ( WeaponTemplate.InventorySlot == DesiredSlot )
		{
			if ( WeaponCategory == '' || WeaponCategory == WeaponTemplate.WeaponCat )
			{
				return 'AA_Success';
			}
		}
	}
	return 'AA_WeaponIncompatible';
}