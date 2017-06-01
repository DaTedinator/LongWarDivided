class X2AbilityToHitCalc_Hotwire extends X2AbilityToHitCalc_StatCheck_UnitVsUnit;

var int ConvBonus, LaserBonus, MagBonus, CoilBonus, BeamBonus;

protected function int GetHitChance(XComGameState_Ability kAbility, AvailableTarget kTarget, optional bool bDebugLog=false)
{
	local int AttackVal, DefendVal, TargetRoll, Bonus;
	local ShotBreakdown EmptyShotBreakdown;
	local XComGameState_Item SourceWeapon;
	local X2WeaponTemplate WeaponTemplate;

	SourceWeapon = kAbility.GetSourceWeapon();
	Bonus = 0;
	if(SourceWeapon != none)
		WeaponTemplate = X2WeaponTemplate(SourceWeapon.GetMyTemplate());
	if(WeaponTemplate != none)
	{
		switch (WeaponTemplate.WeaponTech)
		{		
			case 'Conventional':	Bonus = ConvBonus; break;
			case 'laser_lw':		Bonus = LaserBonus; break;
			case 'Magnetic':		Bonus = MagBonus; break;
			case 'coil_lw':			Bonus = CoilBonus; break;
			case 'Beam':			Bonus = BeamBonus; break;
			default: break;
		}
	}

	//reset shot breakdown
	m_ShotBreakdown = EmptyShotBreakdown;

	AttackVal = GetAttackValue(kAbility, kTarget.PrimaryTarget) + Bonus;
	DefendVal = GetDefendValue(kAbility, kTarget.PrimaryTarget);
	TargetRoll = BaseValue + AttackVal - DefendVal;
	AddModifier(BaseValue, GetBaseString());
	AddModifier(AttackVal, GetAttackString());
	AddModifier(-DefendVal, GetDefendString());
	m_ShotBreakdown.FinalHitChance = TargetRoll;
	return TargetRoll;
}

DefaultProperties
{
	AttackerStat = eStat_Hacking
	DefenderStat = eStat_HackDefense
	ConvBonus = 0
	LaserBonus = 10
	MagBonus = 20
	CoilBonus = 30
	BeamBonus = 40
}