class X2Ability_LWD_RaiderAbilitySet extends TeddyXMBAbility
	config(LWD_SoldierSkills);

var config int ReaveConventionalBonus, ReaveMagneticBonus, ReaveBeamBonus;
var config int BattleFocusDamageBonus;
var config int BattleFuryShred;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Onslaught('LWD_Onslaught', "img:///UILibrary_LWD.ability_Onslaught"));
	Templates.AddItem(Reave('LWD_Reave', "img:///UILibrary_LWD.ability_Reave"));
	Templates.AddItem(BattleFocus('LWD_BattleFocus', "img:///UILibrary_LWD.ability_BattleFocus"));
	Templates.AddItem(BattleFury('LWD_BattleFury', "img:///UILibrary_LWD.ability_BattleFury"));
	//Templates.AddItem(CombatStance('LWD_CombatStance', "img:///UILibrary_LWD.ability_CombatStance"));
	//Templates.AddItem(Ravager('LWD_Ravager', "img:///UILibrary_LWD.ability_Ravager"));
	//Templates.AddItem(Reaver('LWD_Reaver', "img:///UILibrary_LWD.ability_Reaver"));
	//Templates.AddItem(Berserker('LWD_Berserker', "img:///UILibrary_LWD.ability_Berserker"));
	//Templates.AddItem(SwitchHitter('LWD_SwitchHitter', "img:///UILibrary_LWD.ability_SwitchHitter"));
	//Templates.AddItem(Warlord('LWD_Warlord', "img:///UILibrary_LWD.ability_Warlord"));
	//Templates.AddItem(('LWD_', "img:///UILibrary_LWD.ability_"));

	return Templates;
}

	
static function X2AbilityTemplate Onslaught(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2AbilityCharges Charges;
	local X2AbilityCost_ChargesOptional ChargeCost;
	local XMBEffect_AddOnslaughtCharges BonusChargesEffect;
	local X2Effect_GrantActionPoints BonusMoveEffect;
	local X2Condition_UnitValue ChargedCondition;

	Template = Attack(TemplateName, ImageIcon, true, none, class'UIUtilities_Tactical'.const.STANDARD_SHOT_PRIORITY, eCost_None, 1);

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 0;
	ActionPointCost.bAddWeaponTypicalCost = true;
	ActionPointCost.bConsumeAllPoints = true;
	ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem('LWD_BattleFocus');
	Template.AbilityCosts.AddItem(ActionPointCost);

	Charges = new class 'X2AbilityCharges';
	Charges.InitialCharges = 0;
	Template.AbilityCharges = Charges;

	ChargeCost = new class'X2AbilityCost_ChargesOptional';
	ChargeCost.MinCharges = 0;
	ChargeCost.UnitValueName = 'OnslaughtChargesSpent';
	ChargeCost.OnlyOnHitAbilities.AddItem('LWD_Warlord');
	Template.AbilityCosts.AddItem(ChargeCost);

	BonusChargesEffect = new class'XMBEffect_AddOnslaughtCharges';
	BonusChargesEffect.AbilityNames.AddItem('LWD_Reave');
	BonusChargesEffect.BonusCharges = 1;
	BonusChargesEffect.MaxCharges = 1;
	BonusChargesEffect.MaxIncreaseAbilities.AddItem('LWD_Warlord');
	Template.AddShooterEffect(BonusChargesEffect);

	Template.OverrideAbilities.AddItem('StandardShot');

	ChargedCondition = new class'X2Condition_UnitValue';
	ChargedCondition.AddCheckValue('OnslaughtChargesSpent', 0, eCheck_GreaterThan);

	BonusMoveEffect = new class'X2Effect_GrantActionPoints';
	BonusMoveEffect.NumActionPoints = 1;
	BonusMoveEffect.PointType = class'X2CharacterTemplateManager'.default.MoveActionPoint;
	BonusMoveEffect.TargetConditions.AddItem(ChargedCondition);

	return Template;
}
	
static function X2AbilityTemplate Reave(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local X2AbilityCharges Charges;
	local X2AbilityCost_ChargesOptional ChargeCost;
	local XMBEffect_AddOnslaughtCharges BonusChargesEffect;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2Condition_UnitValue ChargedCondition;
	
	Template = LimitedMeleeAttack(TemplateName, ImageIcon, true, none, class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY, eCost_None, true);
	
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem('LWD_BattleFury');
	Template.AbilityCosts.AddItem(ActionPointCost);

	Charges = new class 'X2AbilityCharges';
	Charges.InitialCharges = 0;
	Template.AbilityCharges = Charges;

	ChargeCost = new class'X2AbilityCost_ChargesOptional';
	ChargeCost.MinCharges = 0;
	ChargeCost.UnitValueName = 'ReaveChargesSpent';
	ChargeCost.OnlyOnHitAbilities.AddItem('LWD_Warlord');
	Template.AbilityCosts.AddItem(ChargeCost);

	BonusChargesEffect = new class'XMBEffect_AddOnslaughtCharges';
	BonusChargesEffect.AbilityNames.AddItem('LWD_Onslaught');
	BonusChargesEffect.BonusCharges = 1;
	BonusChargesEffect.MaxCharges = 1;
	BonusChargesEffect.MaxIncreaseAbilities.AddItem('LWD_Warlord');
	Template.AddShooterEffect(BonusChargesEffect);

	Template.OverrideAbilities.AddItem('StandardShot');

	ChargedCondition = new class'X2Condition_UnitValue';
	ChargedCondition.AddCheckValue('ReaveChargesSpent', 0, eCheck_GreaterThan);

	AddSecondaryAbility(Template, ReaveBonuses('LWD_ReaveBonuses', ImageIcon));

	return Template;
}
	
static function X2AbilityTemplate ReaveBonuses(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalBonus Effect;
	local XMBValue_UnitValue Value;

	Value = new class'XMBValue_UnitValue';
	Value.UnitValueName = 'ReaveChargesSpent';

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.EffectName = 'ChargedReaveBonus';
	Effect.AddDamageModifier(default.ReaveConventionalBonus, eHit_Success, 'conventional');
	Effect.AddDamageModifier(default.ReaveMagneticBonus, eHit_Success, 'magnetic');
	Effect.AddDamageModifier(default.ReaveBeamBonus, eHit_Success, 'beam');
	Effect.ScaleValue = Value;
	Effect.ScaleMax = 1;

	// Create the template
	Template = Passive(TemplateName, ImageIcon, false, Effect);

	// Hide the icon for the passive damage effect
	HidePerkIcon(Template);

	return Template;
}
	
static function X2AbilityTemplate BattleFocus(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalBonus Effect;
	local XMBValue_UnitValue Value;

	Value = new class'XMBValue_UnitValue';
	Value.UnitValueName = 'ReaveChargesSpent';

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.EffectName = 'ChargedReaveBonus';
	Effect.AddDamageModifier(default.BattleFocusDamageBonus, eHit_Crit, 'conventional');
	Effect.AddDamageModifier(default.BattleFocusDamageBonus, eHit_Crit, 'laser_lw');
	Effect.AddDamageModifier(default.BattleFocusDamageBonus + 1, eHit_Crit, 'magnetic');
	Effect.AddDamageModifier(default.BattleFocusDamageBonus + 1, eHit_Crit, 'coilgun_lw');
	Effect.AddDamageModifier(default.BattleFocusDamageBonus + 2, eHit_Crit, 'beam');
	Effect.ScaleValue = Value;
	Effect.ScaleMax = 1;

	// Create the template
	Template = Passive(TemplateName, ImageIcon, false, Effect);

	return Template;
}
	
static function X2AbilityTemplate BattleFury(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalBonus Effect;
	local XMBValue_UnitValue Value;

	Value = new class'XMBValue_UnitValue';
	Value.UnitValueName = 'ReaveChargesSpent';

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.EffectName = 'ChargedReaveBonus';
	Effect.AddShredModifier(default.BattleFuryShred);
	Effect.ScaleValue = Value;
	Effect.ScaleMax = 1;

	// Create the template
	Template = Passive(TemplateName, ImageIcon, false, Effect);

	return Template;
}
	
//static function X2AbilityTemplate CombatStance(name TemplateName, string ImageIcon)
//{
//	
//}
	
//static function X2AbilityTemplate (name TemplateName, string ImageIcon)
//{
//	
//}
	
//static function X2AbilityTemplate (name TemplateName, string ImageIcon)
//{
//	
//}
	
//static function X2AbilityTemplate (name TemplateName, string ImageIcon)
//{
//	
//}
	
//static function X2AbilityTemplate (name TemplateName, string ImageIcon)
//{
//	
//}
	
//static function X2AbilityTemplate (name TemplateName, string ImageIcon)
//{
//	
//}
	
//static function X2AbilityTemplate (name TemplateName, string ImageIcon)
//{
//	
//}