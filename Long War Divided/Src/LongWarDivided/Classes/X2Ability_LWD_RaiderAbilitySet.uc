class X2Ability_LWD_RaiderAbilitySet extends TeddyXMBAbility
	config(LWD_SoldierSkills);

var config int ReaveBonus;
var config int BattleFocusDamageBonus;
var config int BattleFuryShred;
var config int ReaverHitBonus, ReaverCritBonus;
var config int CombatStanceOverwatchBonus, CombatStanceCounterattackDodgeAmount;
var config int VikingOnslaughtBonus, VikingReaveBonus;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Onslaught('LWD_Onslaught', "img:///UILibrary_LWD.ability_Onslaught"));
	Templates.AddItem(Reave('LWD_Reave', "img:///UILibrary_LWD.ability_Reave"));
	Templates.AddItem(BattleFocus('LWD_BattleFocus', "img:///UILibrary_LWD.ability_Meditate"));
	Templates.AddItem(BattleFury('LWD_BattleFury', "img:///UILibrary_LWD.ability_BattleFury"));
	
	Templates.AddItem(CombatStance('LWD_CombatStance', "img:///UILibrary_LWD.ability_CombatStance"));
	Templates.AddItem(CombatStanceAttack('LWD_CombatStanceAttack', "img:///UILibrary_LWD.ability_CombatStance"));
	Templates.AddItem(CombatStancePreparationAbility('LWD_CombatStancePreparation'));
	Templates.AddItem(CombatStanceCounterattackAbility('LWD_CombatStanceCounterattack', "img:///UILibrary_LWD.ability_CombatStance"));
	
	Templates.AddItem(Ravager('LWD_Ravager', "img:///UILibrary_LWD.ability_Ravager"));
	Templates.AddItem(Reaver('LWD_Reaver', "img:///UILibrary_LWD.ability_Reaver"));
	Templates.AddItem(Berserker('LWD_Berserker', "img:///UILibrary_LWD.ability_Berserker"));
	Templates.AddItem(Viking('LWD_Viking', "img:///UILibrary_LWD.ability_Viking"));
	Templates.AddItem(PurePassive('LWD_Warlord', "img:///UILibrary_LWD.ability_Warlord"));
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

	Template.AddShooterEffect(BonusMoveEffect);

	return Template;
}//Onslaught
	
static function X2AbilityTemplate Reave(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local X2AbilityCharges Charges;
	local X2AbilityCost_ChargesOptional ChargeCost;
	local XMBEffect_AddOnslaughtCharges BonusChargesEffect;
	local X2AbilityCost_ActionPoints ActionPointCost;
	
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

	AddSecondaryAbility(Template, ReaveBonuses('LWD_ReaveBonuses', ImageIcon));

	return Template;
}//Reave
	
static function X2AbilityTemplate ReaveBonuses(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalBonus Effect;
	local XMBValue_UnitValue Value;
	local XMBCondition_AbilityName Condition;

	Value = new class'XMBValue_UnitValue';
	Value.UnitValueName = 'ReaveChargesSpent';

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.EffectName = 'ChargedReaveBonus';
	Effect.AddDamageModifier(default.ReaveBonus, eHit_Success);
	Effect.ScaleValue = Value;
	Effect.ScaleMax = 1;

	Condition = new class'XMBCondition_AbilityName';
	Condition.IncludeAbilityNames.AddItem('LWD_Reave');
	Effect.AbilityTargetConditions.AddItem(Condition);

	// Create the template
	Template = Passive(TemplateName, ImageIcon, false, Effect);

	// Hide the icon for the passive damage effect
	HidePerkIcon(Template);

	return Template;
}//Reave Bonuses
	
static function X2AbilityTemplate BattleFocus(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalBonus Effect;
	local XMBValue_UnitValue Value;
	local XMBCondition_AbilityName Condition;

	Value = new class'XMBValue_UnitValue';
	Value.UnitValueName = 'OnslaughtChargesSpent';

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.EffectName = 'ChargedReaveBonus';
	Effect.AddDamageModifier(default.BattleFocusDamageBonus, eHit_Crit, 'conventional');
	Effect.AddDamageModifier(default.BattleFocusDamageBonus, eHit_Crit, 'laser_lw');
	Effect.AddDamageModifier(default.BattleFocusDamageBonus + 1, eHit_Crit, 'magnetic');
	Effect.AddDamageModifier(default.BattleFocusDamageBonus + 1, eHit_Crit, 'coilgun_lw');
	Effect.AddDamageModifier(default.BattleFocusDamageBonus + 2, eHit_Crit, 'beam');
	Effect.ScaleValue = Value;
	Effect.ScaleMax = 1;

	Condition = new class'XMBCondition_AbilityName';
	Condition.IncludeAbilityNames.AddItem('LWD_Onslaught');
	Effect.AbilityTargetConditions.AddItem(Condition);

	// Create the template
	Template = Passive(TemplateName, ImageIcon, false, Effect);

	return Template;
}//Battle Focus
	
static function X2AbilityTemplate BattleFury(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalBonus Effect;
	local XMBValue_UnitValue Value;
	local XMBCondition_AbilityName Condition;

	Value = new class'XMBValue_UnitValue';
	Value.UnitValueName = 'ReaveChargesSpent';

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.EffectName = 'ChargedReaveBonus';
	Effect.AddShredModifier(default.BattleFuryShred);
	Effect.ScaleValue = Value;
	Effect.ScaleMax = 1;

	Condition = new class'XMBCondition_AbilityName';
	Condition.IncludeAbilityNames.AddItem('LWD_Reave');
	Effect.AbilityTargetConditions.AddItem(Condition);

	// Create the template
	Template = Passive(TemplateName, ImageIcon, false, Effect);

	return Template;
}//Battle Fury
	
static function X2AbilityTemplate CombatStance(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate						Template;
	local X2Effect_AdditionalAnimSets			AnimSetEffect;
	local XMBEffect_ConditionalBonus			Effect;
	local X2Condition_AbilityCharges			Condition;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddToHitModifier(default.CombatStanceOverwatchBonus);
	Effect.AbilityTargetConditions.AddItem(default.ReactionFireCondition);
	
	Condition = new class'X2Condition_AbilityCharges';
	Condition.AbilityName = 'LWD_Onslaught';
	Effect.AbilityTargetConditions.AddItem(Condition);

	Template = Passive(TemplateName, ImageIcon, false, Effect);

	AnimSetEffect = new class'X2Effect_AdditionalAnimSets';
	AnimSetEffect.AddAnimSetWithPath("LWCombatKnife.Anims.AS_CombatKnife"); //???
	Template.AddTargetEffect(AnimSetEffect);

	Template.AdditionalAbilities.AddItem('LWD_CombatStanceAttack');
	Template.AdditionalAbilities.AddiTEm('LWD_CombatStancePreparation');
	Template.AdditionalAbilities.AddItem('LWD_CombatStanceCounterattack');
	return Template;
}//Combat Stance

static function X2AbilityTemplate CombatStanceAttack(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2AbilityToHitCalc_StandardMelee MeleeHitCalc;
	local X2Effect_ApplyWeaponDamage PhysicalDamageEffect;
	local X2Effect_SetUnitValue SetUnitValEffect;
	local X2Effect_RemoveEffects RemoveEffects;

	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);
	Template.IconImage = ImageIcon;

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.Hostility = eHostility_Offensive;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;

	ActionPointCost.AllowedTypes.AddItem(class'X2CharacterTemplateManager'.default.CounterattackActionPoint);
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.bDontDisplayInAbilitySummary = true;

	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	MeleeHitCalc = new class'X2AbilityToHitCalc_StandardMelee';
	Template.AbilityToHitCalc = MeleeHitCalc;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);

	// Damage Effect
	PhysicalDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	Template.AddTargetEffect(PhysicalDamageEffect);

	// The Unit gets to counterattack once
	SetUnitValEffect = new class'X2Effect_SetUnitValue';
	SetUnitValEffect.UnitName = class'X2Ability'.default.CounterattackDodgeEffectName;
	SetUnitValEffect.NewValueToSet = 0;
	SetUnitValEffect.CleanupType = eCleanup_BeginTurn;
	SetUnitValEffect.bApplyOnHit = true;
	SetUnitValEffect.bApplyOnMiss = true;
	Template.AddShooterEffect(SetUnitValEffect);

	// Remove the dodge increase (happens with a counter attack, which is one time per turn)
	RemoveEffects = new class'X2Effect_RemoveEffects';
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2Ability'.default.CounterattackDodgeEffectName);
	RemoveEffects.bApplyOnHit = true;
	RemoveEffects.bApplyOnMiss = true;
	Template.AddShooterEffect(RemoveEffects);

	Template.AbilityTargetStyle = default.SimpleSingleMeleeTarget;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.CinescriptCameraType = "Ranger_Reaper";

	return Template;
}//CombatStanceAttack

static function X2AbilityTemplate CombatStancePreparationAbility(name TemplateName)
{
	local X2AbilityTemplate Template;
	local X2AbilityTrigger_EventListener Trigger;
	local X2Effect_ToHitModifier DodgeEffect;
	local X2Effect_SetUnitValue SetUnitValEffect;
	local X2Condition_AbilityCharges Condition;

	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);

	Template.bDontDisplayInAbilitySummary = true;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'PlayerTurnEnded';
	Trigger.ListenerData.Filter = eFilter_Player;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(Trigger);
	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_UnitPostBeginPlay');

	// During the Enemy player's turn, the Unit gets a dodge increase
	DodgeEffect = new class'X2Effect_ToHitModifier';
	DodgeEffect.EffectName = class'X2Ability'.default.CounterattackDodgeEffectName;
	DodgeEffect.BuildPersistentEffect(1, false, false, false, eGameRule_PlayerTurnBegin);
	DodgeEffect.SetDisplayInfo(ePerkBuff_Bonus, "Combat Stance", "", Template.IconImage);
	DodgeEffect.AddEffectHitModifier(eHit_Graze, default.CombatStanceCounterattackDodgeAmount, "Combat Stance", class'X2AbilityToHitCalc_StandardMelee', true, false, true, true, , false);
	DodgeEffect.bApplyAsTarget = true;

	Condition = new class'X2Condition_AbilityCharges';
	Condition.AbilityName = 'LWD_Reave';
	DodgeEffect.TargetConditions.AddItem(Condition);

	Template.AddShooterEffect(DodgeEffect);

	// The Unit gets to counterattack once
	SetUnitValEffect = new class'X2Effect_SetUnitValue';
	SetUnitValEffect.UnitName = class'X2Ability'.default.CounterattackDodgeEffectName;
	SetUnitValEffect.NewValueToSet = class'X2Ability'.default.CounterattackDodgeUnitValue;
	SetUnitValEffect.CleanupType = eCleanup_BeginTurn;
	SetUnitValEffect.TargetConditions.AddItem(Condition);
	Template.AddTargetEffect(SetUnitValEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	
	return Template;
}//CombatStancePreparationAbility

static function X2AbilityTemplate CombatStanceCounterattackAbility(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local X2AbilityTrigger_EventListener EventListener;
	
	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);
	Template.IconImage = ImageIcon;

	Template.bDontDisplayInAbilitySummary = true;
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Offensive;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.EventID = 'AbilityActivated';
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.MeleeCounterattackListener;  // this probably has to change
	Template.AbilityTriggers.AddItem(EventListener);

	// Add dead eye to guarantee the explosion occurs
	Template.AbilityToHitCalc = default.DeadEye;

	Template.AbilityTargetStyle = default.SelfTarget;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.CinescriptCameraType = "Muton_Counterattack";  // might need to change this to ranger or stun lancer ...

	return Template;
}//CombatStanceCounterattackAbility
	
static function X2AbilityTemplate Ravager(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local XMBEffect_AbilityCostRefund Effect;
	local XMBCondition_AbilityName AbilityNameCondition;
	local X2Condition_UnitValue Condition;

	Effect = new class'XMBEffect_AbilityCostRefund';
	Effect.EffectName = 'Ravager';
	Effect.TriggeredEvent = 'Ravager';
	Effect.CountValueName = 'RavagerShots';
	Effect.MaxRefundsPerTurn = 1;

	AbilityNameCondition = new class'XMBCondition_AbilityName';
	AbilityNameCondition.IncludeAbilityNames.AddItem('LWD_Onslaught');
	Effect.AbilityTargetConditions.AddItem(AbilityNameCondition);

	Effect.AbilityTargetConditions.AddItem(default.CritCondition);

	Condition = new class'X2Condition_UnitValue';
	Condition.AddCheckValue('OnslaughtChargesSpent', 0, eCheck_GreaterThan);
	Effect.TargetConditions.AddItem(Condition);

	Template = Passive(TemplateName, ImageIcon, false, Effect);

	return Template;
}//Ravager
	
static function X2AbilityTemplate Reaver(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalBonus Effect;
	local TeddyXMBValue_Health Value;
	local X2Condition_UnitValue ChargedCondition;
	local XMBCondition_AbilityName AbilityCondition;

	Value = new class'TeddyXMBValue_Health';
	Value.bTarget = true;
	Value.bInvert = true;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddToHitModifier(default.ReaverHitBonus);
	Effect.AddToHitModifier(default.ReaverCritBonus, eHit_Crit);

	Effect.ScaleValue = Value;
	Effect.ScaleMax = 0.9;

	AbilityCondition = new class'XMBCondition_AbilityName';
	AbilityCondition.IncludeAbilityNames.AddItem('LWD_Reave');
	Effect.AbilityTargetConditions.AddItem(AbilityCondition);

	Template = Passive(TemplateName, ImageIcon, False, Effect);

	ChargedCondition = new class'X2Condition_UnitValue';
	ChargedCondition.AddCheckValue('ReaveChargesSpent', 0, eCheck_GreaterThan);
	Template.AbilityTargetConditions.AddItem(ChargedCondition);

	// Create the template using a helper function
	return Template;
}//Reaver
	
static function X2AbilityTemplate Berserker(name TemplateName, string ImageIcon)
{
	local XMBEffect_AddOnslaughtCharges Effect;

	Effect = new class'XMBEffect_AddOnslaughtCharges';
	Effect.AbilityNames.AddItem('LWD_Reave');
	Effect.AbilityNames.AddItem('LWD_Onslaught');
	Effect.BonusCharges = 1;
	Effect.MaxCharges = 1;
	Effect.MaxIncreaseAbilities.AddItem('LWD_Warlord');

	return SelfTargetTrigger(TemplateName, ImageIcon, false, Effect, 'UnitTakeEffectDamage');
}//Berserker
	
static function X2AbilityTemplate Viking(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalBonus ReaveEffect;
	local XMBValue_UnitValue ReaveValue;
	local XMBCondition_AbilityName ReaveCondition;
	local XMBEffect_ConditionalBonus OnslaughtEffect;
	local XMBValue_UnitValue OnslaughtValue;
	local XMBCondition_AbilityName OnslaughtCondition;

	Template = Passive(TemplateName, ImageIcon, false, none);

	ReaveValue = new class'XMBValue_UnitValue';
	ReaveValue.UnitValueName = 'ReaveChargesSpent';

	ReaveEffect = new class'XMBEffect_ConditionalBonus';
	ReaveEffect.EffectName = 'VikingReaveBonus';
	ReaveEffect.AddDamageModifier(default.VikingReaveBonus, eHit_Success);
	ReaveEffect.ScaleValue = ReaveValue;
	ReaveEffect.ScaleMax = 1;

	ReaveCondition = new class'XMBCondition_AbilityName';
	ReaveCondition.IncludeAbilityNames.AddItem('LWD_Reave');
	ReaveEffect.AbilityTargetConditions.AddItem(ReaveCondition);

	AddSecondaryEffect(Template, ReaveEffect);

	OnslaughtValue = new class'XMBValue_UnitValue';
	OnslaughtValue.UnitValueName = 'OnslaughtChargesSpent';

	OnslaughtEffect = new class'XMBEffect_ConditionalBonus';
	OnslaughtEffect.EffectName = 'VikingOnslaughtBonus';
	OnslaughtEffect.AddToHitModifier(default.VikingOnslaughtBonus, eHit_Success);
	OnslaughtEffect.ScaleValue = OnslaughtValue;
	OnslaughtEffect.ScaleMax = 1;

	OnslaughtCondition = new class'XMBCondition_AbilityName';
	OnslaughtCondition.IncludeAbilityNames.AddItem('LWD_Onslaught');
	OnslaughtEffect.AbilityTargetConditions.AddItem(OnslaughtCondition);

	AddSecondaryEffect(Template, OnslaughtEffect);

	return Template;
}//Viking
	
//static function X2AbilityTemplate (name TemplateName, string ImageIcon)
//{
//	
//}//