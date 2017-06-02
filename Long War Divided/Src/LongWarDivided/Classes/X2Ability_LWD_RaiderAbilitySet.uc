class X2Ability_LWD_RaiderAbilitySet extends XMBAbility
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
	local X2Condition_Visibility VisibilityCondition;
	local X2AbilityCharges Charges;
	local X2AbilityCost_ChargesOptional ChargeCost;
	local XMBEffect_AddOnslaughtCharges BonusChargesEffect;
	local X2Effect_GrantActionPoints BonusMoveEffect;
	local X2Condition_UnitValue ChargedCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);

	Template.bDontDisplayInAbilitySummary = true;
	Template.IconImage = ImageIcon;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STANDARD_SHOT_PRIORITY;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.DisplayTargetHitChance = true;
	Template.AbilitySourceName = 'eAbilitySource_Perk'; 

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.AddShooterEffectExclusions();

	VisibilityCondition = new class'X2Condition_Visibility';
	VisibilityCondition.bRequireGameplayVisible = true;
	VisibilityCondition.bAllowSquadsight = true;

	Template.AbilityTargetConditions.AddItem(VisibilityCondition);
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	Template.AddShooterEffectExclusions();

	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem('LWD_BattleFocus');
	Template.AbilityCosts.AddItem(ActionPointCost);

	AddAmmoCost(Template, 1);
	
	Template.bAllowAmmoEffects = true;
	Template.bAllowBonusWeaponEffects = true;

	Template.bAllowFreeFireWeaponUpgrade = true;

	//  Put holo target effect first because if the target dies from this shot, it will be too late to notify the effect.
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
	//  Various Soldier ability specific effects - effects check for the ability before applying	
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect());
	Template.AddTargetEffect(default.WeaponUpgradeMissDamage);
	
	Template.AbilityToHitCalc = default.SimpleStandardAim;
	Template.AbilityToHitOwnerOnMissCalc = default.SimpleStandardAim;
		
	Template.TargetingMethod = class'X2TargetingMethod_OverTheShoulder';
	Template.bUsesFiringCamera = true;
	Template.CinescriptCameraType = "StandardGunFiring";	

	Template.AssociatedPassives.AddItem('HoloTargeting');

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;	
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	//Template.bDisplayInUITooltip = false;
	//Template.bDisplayInUITacticalText = false;

	Template.bCrossClassEligible = false;

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
	
	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.CinescriptCameraType = "Ranger_Reaper";
	Template.IconImage = ImageIcon;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem('LWD_BattleFury');
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.AbilityToHitCalc = new class'X2AbilityToHitCalc_StandardMelee';

	Template.AbilityTargetStyle = new class'X2AbilityTarget_MovingMelee';
	Template.TargetingMethod = class'X2TargetingMethod_MeleePath';

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_EndOfMove');

	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	Template.AbilityTargetConditions.AddItem(default.MeleeVisibilityCondition);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	// Don't allow the ability to be used while the unit is disoriented, burning, unconscious, etc.
	Template.AddShooterEffectExclusions();

	Template.AddTargetEffect(new class'X2Effect_ApplyWeaponDamage');
	
	Template.bAllowBonusWeaponEffects = true;
	Template.bSkipMoveStop = true;
	
	// Voice events
	//
	Template.SourceMissSpeech = 'SwordMiss';

	Template.BuildNewGameStateFn = TypicalMoveEndAbility_BuildGameState;
	Template.BuildInterruptGameStateFn = TypicalMoveEndAbility_BuildInterruptGameState;

	Template.bCrossClassEligible = false;

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