class X2Ability_LWD_CowboyAbilitySet extends TeddyXMBAbility
	config(LWD_SoldierSkills);

var config int CoachGunAPCost, CoachGunDiameter, CoachGunLength;
var config int ShootistAim, ShootistCrit;
var config int BattleMomentumAimBonus, BattleMomentumCritBonus, BattleMomentumBonusCap;
var config int HighNoonDuration, HighNoonCooldown;
var config int TrueGritArmorBonus;
var config int HangEmHighPistolDamage, HangEmHighRifleDamage, HangEmHighShotgunDamage;
var config int UnforgivenBonus;
var config int HadItComingBonus;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(CoachGun('LWD_CoachGun', "img:///UILibrary_LWD.ability_CoachGun"));
	Templates.AddItem(Shootist('LWD_Shootist', "img:///UILibrary_LWD.ability_Shootist"));
	Templates.AddItem(LeadDealer('LWD_LeadDealer', "img:///UILibrary_LWD.ability_LeadDealer"));
	Templates.AddItem(StoppingPower('LWD_StoppingPower', "img:///UILibrary_LWD.ability_StoppingPower"));
	Templates.AddItem(TrickShot('LWD_TrickShot', "img:///UILibrary_LWD.ability_TrickShot"));
	Templates.AddItem(QuickHands('LWD_QuickHands', "img:///UILibrary_LWD.ability_QuickHands"));
	Templates.AddItem(BattleMomentum('LWD_BattleMomentum', "img:///UILibrary_LWD.ability_BattleMomentum"));
	Templates.AddItem(SpareShells('LWD_SpareShells', "img:///UILibrary_LWD.ability_SpareShells"));
	Templates.AddItem(HighNoon('LWD_HighNoon', "img:///UILibrary_LWD.ability_HighNoon"));
	Templates.AddItem(SixShooter('LWD_SixShooter', "img:///UILibrary_LWD.ability_SixShooter"));
	Templates.AddItem(TrueGrit('LWD_TrueGrit', "img:///UILibrary_LWD.ability_TrueGrit"));
	Templates.AddItem(HangEmHigh('LWD_HangEmHigh', "img:///UILibrary_LWD.ability_HangEmHigh"));
	Templates.AddItem(Unforgiven('LWD_Unforgiven', "img:///UILibrary_LWD.ability_Unforgiven"));
	Templates.AddItem(HadItComing('LWD_HadItComing', "img:///UILibrary_LWD.ability_HadItComing"));
	//Templates.AddItem(('LWD_', "img:///UILibrary_LWD.ability_"));

	return Templates;
}


static function X2AbilityTemplate CoachGun(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local X2AbilityTarget_Cursor            CursorTarget;
	local X2AbilityMultiTarget_Cone         ConeMultiTarget;
	local X2Condition_UnitProperty          UnitPropertyCondition;
	local X2AbilityToHitCalc_StandardAim    StandardAim;
	local X2Effect_Shredder					WeaponDamageEffect;
	local X2Condition_UnitEffects			SuppressedCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);

	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.IconImage = ImageIcon;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.CinescriptCameraType = "StandardGunFiring";
	Template.bCrossClassEligible = false;
	Template.Hostility = eHostility_Offensive;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.TargetingMethod = class'X2TargetingMethod_Cone';

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityTargetConditions.AddItem(default.LivingTargetUnitOnlyProperty);
	
	Template.bAllowAmmoEffects = true;

	ActionPointCost = new class 'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = default.CoachGunAPCost;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	AmmoCost = new class'X2AbilityCost_Ammo';	
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);
	Template.bUseAmmoAsChargesForHUD = true;

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.ExcludeFriendlyToSource = false;
	Template.AbilityShooterConditions.AddItem(UnitPropertyCondition);
	Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);

	Template.AddShooterEffectExclusions();
	
	SuppressedCondition = new class'X2Condition_UnitEffects';
	SuppressedCondition.AddExcludeEffect(class'X2Effect_Suppression'.default.EffectName, 'AA_UnitIsSuppressed');
	Template.AbilityShooterConditions.AddItem(SuppressedCondition);

	StandardAim = new class'X2AbilityToHitCalc_StandardAim';
	StandardAim.bMultiTargetOnly = false; 
	StandardAim.bGuaranteedHit = false;
	StandardAim.bOnlyMultiHitWithSuccess = false;
	StandardAim.bAllowCrit = true;
	Template.AbilityToHitCalc = StandardAim;
	Template.bOverrideAim = false;

	CursorTarget = new class'X2AbilityTarget_Cursor';
	Template.AbilityTargetStyle = CursorTarget;	

	WeaponDamageEffect = new class'X2Effect_Shredder';
	Template.AddTargetEffect(WeaponDamageEffect);
	Template.AddMultiTargetEffect(WeaponDamageEffect);
	Template.bFragileDamageOnly = true;
	Template.bCheckCollision = true;

	ConeMultiTarget = new class'X2AbilityMultiTarget_Cone';
	ConeMultiTarget.bExcludeSelfAsTargetIfWithinRadius = true;
	ConeMultiTarget.ConeEndDiameter = default.CoachGunDiameter * class'XComWorldData'.const.WORLD_StepSize;
	ConeMultiTarget.bUseWeaponRangeForLength = false;
	ConeMultiTarget.ConeLength=default.CoachGunLength * class'XComWorldData'.const.WORLD_StepSize;
	ConeMultiTarget.fTargetRadius = 99;     //  large number to handle weapon range - targets will get filtered according to cone constraints
	ConeMultiTarget.bIgnoreBlockingCover = false;
	// Loose Choke isn't implemented yet, but just in case I ever do:
	ConeMultiTarget.AddBonusConeSize('LWD_LooseChoke', default.CoachGunDiameter * 2.0, default.CoachGunLength * 0.5);
	Template.AbilityMultiTargetStyle = ConeMultiTarget;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	return Template;
}//Coach Gun

static function X2AbilityTemplate Shootist(name TemplateName, string ImageIcon)
{
	local XMBEffect_ConditionalBonus Effect;

	// Create an effect that adds +10 to hit and +1 damage
	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddToHitModifier(default.ShootistAim);
	Effect.AddToHitModifier(default.ShootistCrit, eHit_Crit);

	// Restrict to the weapon matching this ability
	Effect.AbilityTargetConditions.AddItem(default.MatchingWeaponCondition);

	return Passive(TemplateName, ImageIcon, false, Effect);
}//Shootist

static function X2AbilityTemplate LeadDealer(name TemplateName, string ImageIcon)
{
	local XMBEffect_ChangeHitResultForAttacker Effect;
	local X2AbilityTemplate Template;

	// Create an effect that will change attack hit results
	Effect = new class'XMBEffect_ChangeHitResultForAttacker';
	Effect.EffectName = 'LeadDealer';

	// Only change the hit result if it would have been a graze
	Effect.IncludeHitResults.AddItem(eHit_Graze);

	// Change the hit result to a hit
	Effect.NewResult = eHit_Success;

	// Create the template using a helper function
	Template = Passive(TemplateName, ImageIcon, true, Effect);

	return Template;
}//Lead Dealer

static function X2AbilityTemplate StoppingPower(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate		Template;
	local X2Effect				Effect;

	Effect = class'X2StatusEffects'.static.CreateDisorientedStatusEffect();

	Template = OnHitDebuff(TemplateName, ImageIcon, false, Effect, class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY, eHit_Success);

	AddTriggerTargetCondition(Template, default.MatchingWeaponCondition);

	AddIconPassive(Template);

	return Template;
}//Stopping Power

static function X2AbilityTemplate TrickShot(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate			Template;
	local X2Effect_DisableWeapon	Effect;

	Effect = new class'X2Effect_DisableWeapon';

	Template = OnHitDebuff(TemplateName, ImageIcon, false, Effect, class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY, eHit_Crit);

	AddTriggerTargetCondition(Template, default.MatchingWeaponCondition);

	AddIconPassive(Template);

	return Template;
}//Trick Shot

static function X2AbilityTemplate QuickHands(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local XMBEffect_DoNotConsumeAllPoints Effect;

	Effect = new class'XMBEffect_DoNotConsumeAllPoints';
	Effect.AbilityNames.AddItem('PointBlank');
	Effect.AbilityNames.AddItem('BothBarrels');

	Template = Passive(TemplateName, ImageIcon, false, Effect);

	AddSecondaryAbility(Template, QuickHandsRefund('LWD_QuickHandsRefund', ImageIcon));

	return Template;
}//Quick Hands

static function X2AbilityTemplate QuickHandsRefund(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate				Template;
	local XMBEffect_AbilityCostRefund	Effect;
	local XMBCondition_AbilityName		AbilityNameCondition;
	
	// Create an effect that will refund the cost of attacks
	Effect = new class'XMBEffect_AbilityCostRefund';
	Effect.EffectName = 'QuickHands';
	Effect.TriggeredEvent = 'QuickHands';
	Effect.bShowFlyOver = true;

	// Only refund once per turn
	Effect.CountValueName = 'QuickHandsReloads';
	Effect.MaxRefundsPerTurn = 1;

	// The bonus only applies to reloads
	AbilityNameCondition = new class'XMBCondition_AbilityName';
	AbilityNameCondition.IncludeAbilityNames.AddItem('Reload');
	AbilityNameCondition.IncludeAbilityNames.AddItem('LWD_SpareShells');
	Effect.AbilityTargetConditions.AddItem(AbilityNameCondition);

	// Create the template using a helper function
	Template = Passive(TemplateName, ImageIcon, true, Effect);

	HidePerkIcon(Template);

	return Template;
}//QuickHandsRefund

static function X2AbilityTemplate BattleMomentum(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalBonus Effect;
	local XMBValue_UnitValue Value;
	local XMBCondition_AbilityProperty Condition;

	// Create a condition that checks something about another ability.
	Condition = new class'XMBCondition_AbilityProperty';

	// The condition requires that the ability is an activated attack.
	Condition.bRequireActivated = true;
	Condition.IncludeHostility.AddItem(eHostility_Offensive);

	// Create a conditional bonus effect
	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.EffectName = 'BattleMomentum';

	// The effect adds +0 Aim and +10 Crit per hit 
	Effect.AddToHitModifier(default.BattleMomentumAimBonus, eHit_Success);
	Effect.AddToHitModifier(default.BattleMomentumCritBonus, eHit_Crit);

	// The effect scales with the number of consecutive hits
	Value = new class'XMBValue_UnitValue';
	Value.UnitValueName = 'BattleMomentumHits';
	Effect.ScaleValue = Value;
	Effect.ScaleMax = default.BattleMomentumBonusCap;

	Effect.AbilityTargetConditions.AddItem(Condition);
	Effect.AbilityTargetConditions.AddItem(default.MatchingWeaponCondition);

	// Create the template using a helper function
	Template = Passive(TemplateName, ImageIcon, true, Effect);

	AddSecondaryAbility(Template, BattleMomentumCrit());
	AddSecondaryAbility(Template, BattleMomentumHit());

	return Template;
}//Battle Momentum

static function X2AbilityTemplate BattleMomentumCrit()
{
	local X2AbilityTemplate Template;
	local X2Effect_SetUnitValue Effect;
	local XMBCondition_AbilityProperty Condition;

	// Create an effect that will increment the unit value
	Effect = new class'X2Effect_SetUnitValue';

	// Affect the ConsecutiveMisses unit value. I didn't name this property.
	Effect.UnitName = 'BattleMomentumHits';

	// Set the value to 0
	// We set the value to -1 because this still counts as a hit,
	// so BattleMomentumHit is going to trigger after us and bring
	// us up to 0.
	Effect.NewValueToSet = -1;

	// The count should be reset to 0 at the beginning of each mission.
	Effect.CleanupType = eCleanup_BeginTactical;

	// Create the template using a helper function
	Template = SelfTargetTrigger('LWD_BattleMomentumCrit', "img:///UILibrary_PerkIcons.UIPerk_command", false, Effect, 'AbilityActivated');

	// Create a condition that checks something about another ability.
	Condition = new class'XMBCondition_AbilityProperty';

	// The condition requires that the ability is an activated attack.
	Condition.bRequireActivated = true;
	Condition.IncludeHostility.AddItem(eHostility_Offensive);

	AddTriggerTargetCondition(Template, Condition);
	AddTriggerTargetCondition(Template, default.MatchingWeaponCondition);

	// Only count crits
	AddTriggerTargetCondition(Template, default.CritCondition);

	HidePerkIcon(Template);

	return Template;
}//BattleMomentumCrit

static function X2AbilityTemplate BattleMomentumHit()
{
	local X2AbilityTemplate Template;
	local X2Effect_IncrementUnitValue Effect;
	local XMBCondition_AbilityProperty Condition;

	// Create an effect that will increment the unit value
	Effect = new class'X2Effect_IncrementUnitValue';

	// Create an effect that will increment the unit value
	Effect.UnitName = 'BattleMomentumHits';

	// Increase the value by 1
	Effect.NewValueToSet = 1;

	// The count should be reset to 0 at the beginning of each mission.
	Effect.CleanupType = eCleanup_BeginTactical;

	// Create the template using a helper function
	Template = SelfTargetTrigger('LWD_BattleMomentumHit', "img:///UILibrary_PerkIcons.UIPerk_command", false, Effect, 'AbilityActivated');

	// Create a condition that checks something about another ability.
	Condition = new class'XMBCondition_AbilityProperty';

	// The condition requires that the ability is an activated attack.
	Condition.bRequireActivated = true;
	Condition.IncludeHostility.AddItem(eHostility_Offensive);

	AddTriggerTargetCondition(Template, Condition);
	AddTriggerTargetCondition(Template, default.MatchingWeaponCondition);

	// Only count hits
	AddTriggerTargetCondition(Template, default.HitCondition);

	HidePerkIcon(Template);

	return Template;
}//BattleMomentumHit

static function X2AbilityTemplate SpareShells(name TemplateName, string ImageIcon)
{
	local X2AbilityCost_SpareShells AmmoCost;
	local X2AbilityTemplate Template;

	Template = SelfTargetActivated(TemplateName, ImageIcon, false, none, class'UIUtilities_Tactical'.const.PISTOL_OVERWATCH_PRIORITY, eCost_Single);

	// We have a hacky way of doing this: negative ammo cost with a tweaked cost script
	AmmoCost = new class'X2AbilityCost_SpareShells';
	AmmoCost.iAmmo = -1;
	Template.AbilityCosts.AddItem(AmmoCost);

	Template.ActivationSpeech = 'Reloading';

	return Template;
}//Spare Shells

static function X2AbilityTemplate HighNoon(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local X2Effect_Persistent PersistentEffect;
	local X2Effect_HighNoonAdjustRange RangeEffect;

	PersistentEffect = new class'X2Effect_Persistent';
	PersistentEffect.EffectName = 'HighNoonMark';
	PersistentEffect.DuplicateResponse = eDupe_Allow;
	PersistentEffect.BuildPersistentEffect(default.HighNoonDuration, false, true, false, eGameRule_PlayerTurnEnd);
	PersistentEffect.bApplyOnHit = true;
	PersistentEffect.bApplyOnMiss = true;

	Template = TargetedDebuff(TemplateName, ImageIcon, true, PersistentEffect, class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY, eCost_Free);

	RangeEffect = new class'X2Effect_HighNoonAdjustRange';
	RangeEffect.BuildPersistentEffect(default.HighNoonDuration, false, true, false, eGameRule_PlayerTurnBegin);
	RangeEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true, , Template.AbilitySourceName);
	Template.AddShooterEffect(RangeEffect);

	AddCooldown(Template, default.HighNoonCooldown);

	return Template;

}//High Noon

static function X2AbilityTemplate SixShooter(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local X2Effect_SetUnitValue Effect;

	Effect = new class'X2Effect_SetUnitValue';
	Effect.UnitName = 'SixShooterActive';
	Effect.CleanupType = eCleanup_BeginTurn;
	Effect.NewValueToSet = 1;

	Template = SelfTargetActivated(TemplateName, ImageIcon, false, Effect, class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY, eCost_DoubleConsumeAll);

	AddSecondaryAbility(Template, SixShooterShot('LWD_SixShooterShot', ImageIcon));

	AddCharges(Template, 1);

	return Template;
}//Six Shooter

static function X2AbilityTemplate SixShooterShot(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local X2Condition_UnitValue Condition;

	Template = Attack(TemplateName, ImageIcon, false, none, 50, eCost_None, 0);

	Condition = new class'X2Condition_UnitValue';
	Condition.AddCheckValue('SixShooterActive', 0, eCheck_GreaterThan);
	Template.AbilityShooterConditions.AddItem(Condition);

	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;

	AddCharges(Template, 6);

	return Template;
}//SixShooterShot

static function X2AbilityTemplate TrueGrit(name TemplateName, string ImageIcon)
{
	local X2Effect_PersistentStatChange Effect;
	local X2AbilityTemplate Template;

	Effect = new class'X2Effect_PersistentStatChange';
	Effect.EffectName = 'TrueGrit';
	Effect.DuplicateResponse = eDupe_Allow;
	Effect.AddPersistentStatChange(eStat_ArmorMitigation, default.TrueGritArmorBonus);
	Effect.BuildPersistentEffect(1, false, false, false, eGameRule_PlayerTurnBegin);

	Template = SelfTargetTrigger(TemplateName, ImageIcon, true, Effect, 'UnitTakeEffectDamage');

	return Template;
}//True Grit

static function X2AbilityTemplate HangEmHigh(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalBonus PistolEffect;
	local X2Condition_UnitInventory PistolCondition;
	local XMBEffect_ConditionalBonus RifleEffect;
	local X2Condition_UnitInventory RifleCondition;
	local XMBEffect_ConditionalBonus ShotgunEffect;
	local X2Condition_UnitInventory ShotgunCondition;

	Template = Passive(TemplateName, ImageIcon, false, none);

	PistolEffect = new class'XMBEffect_ConditionalBonus';
	PistolEffect.AddDamageModifier(default.HangEmHighPistolDamage);
	PistolCondition = new class'X2Condition_UnitInventory';
	PistolCondition.RelevantSlot = eInvSlot_Utility;
	PistolCondition.RequireWeaponCategory = "pistol";
	PistolEffect.AbilityTargetConditions.AddItem(PistolCondition);
	AddSecondaryEffect(Template, PistolEffect);

	RifleEffect = new class'XMBEffect_ConditionalBonus';
	RifleEffect.AddDamageModifier(default.HangEmHighRifleDamage);
	RifleCondition = new class'X2Condition_UnitInventory';
	RifleCondition.RelevantSlot = eInvSlot_PrimaryWeapon;
	RifleEffect.AbilityTargetConditions.AddItem(RifleCondition);
	AddSecondaryEffect(Template, RifleEffect);

	ShotgunEffect = new class'XMBEffect_ConditionalBonus';
	ShotgunEffect.AddDamageModifier(default.HangEmHighShotgunDamage);
	ShotgunCondition = new class'X2Condition_UnitInventory';
	ShotgunCondition.RelevantSlot = eInvSlot_SecondaryWeapon;
	ShotgunEffect.AbilityTargetConditions.AddItem(ShotgunCondition);
	AddSecondaryEffect(Template, ShotgunEffect);

	return Template;
}//Hang 'Em High

static function X2AbilityTemplate Unforgiven(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalBonus BonusEffect;
	local X2Condition_Unforgiven Condition;

	Condition = new class'X2Condition_Unforgiven';

	BonusEffect = new class'XMBEffect_ConditionalBonus';
	BonusEffect.AddToHitModifier(default.UnforgivenBonus);
	BonusEffect.AbilityTargetConditions.AddItem(default.MatchingWeaponCondition);
	BonusEffect.AbilityTargetConditions.AddItem(Condition);

	Template = Passive(TemplateName, ImageIcon, false, BonusEffect);

	return Template;
}//Unforgiven

static function X2AbilityTemplate HadItComing(name TemplateName, string ImageIcon)
{
	local XMBEffect_ConditionalBonus Effect;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddToHitModifier(default.HadItComingBonus, eHit_Crit);
	Effect.AbilityTargetConditions.AddItem(default.FlankedCondition);
	Effect.AbilityTargetConditions.AddItem(default.MatchingWeaponCondition);

	return Passive(TemplateName, ImageIcon, false, Effect);
}//Had It Coming

//static function X2AbilityTemplate (name TemplateName, string ImageIcon)
//{
//	
//}