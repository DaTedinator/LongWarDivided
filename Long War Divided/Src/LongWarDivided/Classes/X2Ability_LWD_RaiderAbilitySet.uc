class X2Ability_LWD_RaiderAbilitySet extends TeddyXMBAbility
	config(LWD_SoldierSkills);

var config int ReaveBonus;
var config int BattleFocusDamageBonus;
var config int BattleFuryShred;
var config int CombatStanceOverwatchBonus, CombatStanceCounterattackDodgeAmount;
var config int WarlordDodge, WarlordMobility, WarlordCritChance;
var config int VikingOnslaughtBonus, VikingReaveBonus;
var config int ReaverHitBonus, ReaverCritBonus;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(SwitchHitter('LWD_SwitchHitter', "img:///UILibrary_LWD.ability_SwitchHitter"));

	Templates.AddItem(Onslaught('LWD_Onslaught', "img:///UILibrary_LWD.ability_Onslaught", false));
	Templates.AddItem(Onslaught('LWD_ChargedOnslaught', "img:///UILibrary_LWD.ability_ChargedOnslaught", true));
	Templates.AddItem(OnslaughtBonusMove('LWD_OnslaughtBonusMove', "img:///UILibrary_LWD.ability_ChargedOnslaught"));

	Templates.AddItem(Reave('LWD_Reave', "img:///UILibrary_LWD.ability_Reave", false));
	Templates.AddItem(Reave('LWD_ChargedReave', "img:///UILibrary_LWD.ability_ChargedReave", true));
	Templates.AddItem(ReaveBonuses('LWD_ReaveBonuses', "img:///UILibrary_LWD.ability_ChargedReave"));

	Templates.AddItem(BattleFocus('LWD_BattleFocus', "img:///UILibrary_LWD.ability_Meditate"));
	Templates.AddItem(BattleFury('LWD_BattleFury', "img:///UILibrary_LWD.ability_BattleFury"));
	
	Templates.AddItem(CombatStance('LWD_CombatStance', "img:///UILibrary_LWD.ability_CombatStance"));
	Templates.AddItem(CombatStanceAttack('LWD_CombatStanceAttack', "img:///UILibrary_LWD.ability_CombatStance"));
	Templates.AddItem(CombatStancePreparationAbility('LWD_CombatStancePreparation'));
	Templates.AddItem(CombatStanceCounterattackAbility('LWD_CombatStanceCounterattack', "img:///UILibrary_LWD.ability_CombatStance"));
	
	Templates.AddItem(Warlord('LWD_Warlord', "img:///UILibrary_LWD.ability_Warlord"));
	Templates.AddItem(Berserker('LWD_Berserker', "img:///UILibrary_LWD.ability_Berserker"));
	Templates.AddItem(Viking('LWD_Viking', "img:///UILibrary_LWD.ability_Viking"));
	Templates.AddItem(Ravager('LWD_Ravager', "img:///UILibrary_LWD.ability_Ravager"));
	Templates.AddItem(Reaver('LWD_Reaver', "img:///UILibrary_LWD.ability_Reaver"));
	//Templates.AddItem(('LWD_', "img:///UILibrary_LWD.ability_"));

	return Templates;
}


static function X2AbilityTemplate SwitchHitter(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;

	Template = PurePassive(TemplateName, ImageIcon);

	//Template.AdditionalAbilities.AddItem('LWD_Onslaught');
	//Template.AdditionalAbilities.AddItem('LWD_ChargedOnslaught');
	//Template.AdditionalAbilities.AddItem('LWD_OnslaughtBonusMove');

	Template.AdditionalAbilities.AddItem('LWD_Reave');
	Template.AdditionalAbilities.AddItem('LWD_ChargedReave');
	Template.AdditionalAbilities.AddItem('LWD_ReaveBonuses');

	return Template;
}//Switch-Hitter
	
static function X2AbilityTemplate Onslaught(name TemplateName, string ImageIcon, bool bCharged)
{
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2AbilityCost_Ammo AmmoCost;
	local X2Condition_UnitValue ChargedCondition;
	local X2Effect_SetUnitValue OnslaughtChargeEffect;
	local X2Effect_SetUnitValue ReaveChargeEffect;

	Template = Attack(TemplateName, ImageIcon, true, none, class'UIUtilities_Tactical'.const.STANDARD_SHOT_PRIORITY, eCost_None, 0);

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 0;
	ActionPointCost.bAddWeaponTypicalCost = true;
	ActionPointCost.bConsumeAllPoints = true;
	ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem('LWD_BattleFocus');
	Template.AbilityCosts.AddItem(ActionPointCost);
	
	AmmoCost = new class'X2AbilityCost_Ammo';	
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);

	ReaveChargeEffect = new class'X2Effect_SetUnitValue';
	ReaveChargeEffect.UnitName = 'ReaveCharged';
	ReaveChargeEffect.NewValueToSet = 1;
	ReaveChargeEffect.CleanupType = eCleanup_BeginTactical;
	Template.AddShooterEffect(ReaveChargeEffect);

	Template.OverrideAbilities.AddItem('StandardShot');

	if (bCharged)
	{
		ChargedCondition = new class'X2Condition_UnitValue';
		ChargedCondition.AddCheckValue('OnslaughtCharged', 1, eCheck_Exact,,,'AA_NotCharged');
		Template.AbilityShooterConditions.AddItem(ChargedCondition);
		Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideSpecificErrors;
		Template.HideErrors.AddItem('AA_NotCharged');
	}
	else
	{
		Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideIfOtherAvailable;
		Template.HideIfAvailable.AddItem( 'LWD_ChargedOnslaught' );

		Template.AdditionalAbilities.AddItem('LWD_ChargedOnslaught');
		Template.AdditionalAbilities.AddItem('LWD_OnslaughtBonusMove');

	}

	OnslaughtChargeEffect = new class'X2Effect_SetUnitValue';
	OnslaughtChargeEffect.UnitName = 'OnslaughtCharged';
	OnslaughtChargeEffect.NewValueToSet = 0;
	ReaveChargeEffect.bApplyOnMiss = true;
	Template.AddShooterEffect(OnslaughtChargeEffect);

	return Template;
}//Onslaught

static function X2AbilityTemplate OnslaughtBonusMove(name TemplateName, string ImageIcon)
{
	local X2Effect_GrantActionPoints Effect;
	local X2AbilityTemplate Template;
	local XMBCondition_AbilityName NameCondition;

	Effect = new class'X2Effect_GrantActionPoints';
	Effect.NumActionPoints = 1;
	Effect.PointType = class'X2CharacterTemplateManager'.default.MoveActionPoint;

	Template = SelfTargetTrigger(TemplateName, ImageIcon, false, Effect, 'AbilityActivated');

	NameCondition = new class'XMBCondition_AbilityName';
	NameCondition.IncludeAbilityNames.AddItem('LWD_ChargedOnslaught');
	AddTriggerTargetCondition(Template, NameCondition);

	Template.bShowActivation = true;

	return Template;
}
	
static function X2AbilityTemplate Reave(name TemplateName, string ImageIcon, bool bCharged)
{
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2Condition_UnitValue ChargedCondition;
	local X2Effect_SetUnitValue OnslaughtChargeEffect;
	local X2Effect_SetUnitValue ReaveChargeEffect;
	
	Template = LimitedMeleeAttack(TemplateName, ImageIcon, true, none, class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY, eCost_None, true);
	
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem('LWD_BattleFury');
	Template.AbilityCosts.AddItem(ActionPointCost);

	OnslaughtChargeEffect = new class'X2Effect_SetUnitValue';
	OnslaughtChargeEffect.UnitName = 'OnslaughtCharged';
	OnslaughtChargeEffect.NewValueToSet = 1;
	OnslaughtChargeEffect.CleanupType = eCleanup_BeginTactical;
	Template.AddShooterEffect(OnslaughtChargeEffect);

	if (bCharged)
	{
		ChargedCondition = new class'X2Condition_UnitValue';
		ChargedCondition.AddCheckValue('ReaveCharged', 1, eCheck_Exact,,,'AA_NotCharged');
		Template.AbilityShooterConditions.AddItem(ChargedCondition);
		Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideSpecificErrors;
		Template.HideErrors.AddItem('AA_NotCharged');
	}
	else
	{
		Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_HideIfOtherAvailable;
		Template.HideIfAvailable.AddItem( 'LWD_ChargedReave' );
	}

	ReaveChargeEffect = new class'X2Effect_SetUnitValue';
	ReaveChargeEffect.UnitName = 'ReaveCharged';
	ReaveChargeEffect.NewValueToSet = 0;
	ReaveChargeEffect.bApplyOnMiss = true;
	Template.AddShooterEffect(ReaveChargeEffect);

	return Template;
}//Reave
	
static function X2AbilityTemplate ReaveBonuses(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalBonus Effect;
	local XMBCondition_AbilityName Condition;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.EffectName = 'ChargedReaveBonus';
	Effect.AddDamageModifier(default.ReaveBonus, eHit_Success);

	Condition = new class'XMBCondition_AbilityName';
	Condition.IncludeAbilityNames.AddItem('LWD_ChargedReave');
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
	local XMBCondition_AbilityName Condition;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.EffectName = 'ChargedReaveBonus';
	Effect.AddDamageModifier(default.BattleFocusDamageBonus, eHit_Crit, 'conventional');
	Effect.AddDamageModifier(default.BattleFocusDamageBonus, eHit_Crit, 'laser_lw');
	Effect.AddDamageModifier(default.BattleFocusDamageBonus + 1, eHit_Crit, 'magnetic');
	Effect.AddDamageModifier(default.BattleFocusDamageBonus + 1, eHit_Crit, 'coilgun_lw');
	Effect.AddDamageModifier(default.BattleFocusDamageBonus + 2, eHit_Crit, 'beam');

	Condition = new class'XMBCondition_AbilityName';
	Condition.IncludeAbilityNames.AddItem('LWD_ChargedOnslaught');
	Effect.AbilityTargetConditions.AddItem(Condition);

	// Create the template
	Template = Passive(TemplateName, ImageIcon, false, Effect);

	return Template;
}//Battle Focus
	
static function X2AbilityTemplate BattleFury(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalBonus Effect;
	local XMBCondition_AbilityName Condition;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.EffectName = 'ChargedReaveBonus';
	Effect.AddShredModifier(default.BattleFuryShred);

	Condition = new class'XMBCondition_AbilityName';
	Condition.IncludeAbilityNames.AddItem('LWD_ChargedReave');
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
	local XMBValue_UnitValue					Value;

	Value = new class'XMBValue_UnitValue';
	Value.UnitValueName = 'OnslaughtCharged';

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddToHitModifier(default.CombatStanceOverwatchBonus);
	Effect.ScaleValue = Value;
	Effect.ScaleMax = 1;
	Effect.AbilityTargetConditions.AddItem(default.ReactionFireCondition);

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
	local X2Condition_UnitValue Condition;

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

	Condition = new class'X2Condition_UnitValue';
	Condition.AddCheckValue('ReaveCharged', 0, eCheck_GreaterThan);
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

static function X2AbilityTemplate Warlord(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local X2Effect_PersistentStatChange Effect;

	Effect = new class'X2Effect_PersistentStatChange';
	Effect.EffectName = 'Warlord';
	Effect.AddPersistentStatChange(eStat_Dodge, default.WarlordDodge);
	Effect.AddPersistentStatChange(eStat_Mobility, default.WarlordMobility);
	Effect.AddPersistentStatChange(eStat_CritChance, default.WarlordCritChance);
	Effect.DuplicateResponse = eDupe_Ignore;
	Effect.BuildPersistentEffect(1, false, false, false, eGameRule_PlayerTurnBegin);

	Template = SelfTargetActivated(TemplateName, ImageIcon, true, Effect, class'UIUtilities_Tactical'.const.CLASS_MAJOR_PRIORITY, eCost_Free);

	Template.bShowActivation = true;

	AddCharges(Template, 1);

	AddSecondaryAbility(Template, WarlordTrigger('LWD_WarlordTrigger', ImageIcon));

	return Template;
}//Warlord

static function X2AbilityTemplate WarlordTrigger(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local XMBEffect_AddAbilityCharges Effect;
	
	Effect = new class'XMBEffect_AddAbilityCharges';
	Effect.AbilityNames.AddItem('LWD_Warlord');
	Effect.BonusCharges = 1;
	Effect.MaxCharges = 1;

	Template = SelfTargetTrigger(TemplateName, ImageIcon, false, Effect, 'KillMail');

	return Template;
}//WarlordTrigger
	
static function X2AbilityTemplate Berserker(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local X2Effect_SetUnitValue Effect1;
	local X2Effect_SetUnitValue Effect2;

	Template = SelfTargetTrigger(TemplateName, ImageIcon, false, none, 'UnitTakeEffectDamage');

	Effect1 = new class'X2Effect_SetUnitValue';
	Effect1.UnitName = 'OnslaughtCharged';
	Effect1.NewValueToSet = 1;
	Effect1.CleanupType = eCleanup_BeginTactical;
	AddSecondaryEffect(Template, Effect1);

	Effect2 = new class'X2Effect_SetUnitValue';
	Effect2.UnitName = 'ReaveCharged';
	Effect2.NewValueToSet = 1;
	Effect2.CleanupType = eCleanup_BeginTactical;
	AddSecondaryEffect(Template, Effect2);

	AddIconPassive(Template);

	return Template;
}//Berserker
	
static function X2AbilityTemplate Viking(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalBonus ReaveEffect;
	local XMBCondition_AbilityName ReaveCondition;
	local XMBEffect_ConditionalBonus OnslaughtEffect;
	local XMBCondition_AbilityName OnslaughtCondition;

	Template = Passive(TemplateName, ImageIcon, false, none);

	ReaveEffect = new class'XMBEffect_ConditionalBonus';
	ReaveEffect.EffectName = 'VikingReaveBonus';
	ReaveEffect.AddDamageModifier(default.VikingReaveBonus, eHit_Success);

	ReaveCondition = new class'XMBCondition_AbilityName';
	ReaveCondition.IncludeAbilityNames.AddItem('LWD_ChargedReave');
	ReaveEffect.AbilityTargetConditions.AddItem(ReaveCondition);

	AddSecondaryEffect(Template, ReaveEffect);

	OnslaughtEffect = new class'XMBEffect_ConditionalBonus';
	OnslaughtEffect.EffectName = 'VikingOnslaughtBonus';
	OnslaughtEffect.AddToHitModifier(default.VikingOnslaughtBonus, eHit_Success);

	OnslaughtCondition = new class'XMBCondition_AbilityName';
	OnslaughtCondition.IncludeAbilityNames.AddItem('LWD_ChargedOnslaught');
	OnslaughtEffect.AbilityTargetConditions.AddItem(OnslaughtCondition);

	AddSecondaryEffect(Template, OnslaughtEffect);

	return Template;
}//Viking

static function X2AbilityTemplate Ravager(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local XMBEffect_AbilityCostRefund Effect;
	local XMBCondition_AbilityName AbilityNameCondition;

	Effect = new class'XMBEffect_AbilityCostRefund';
	Effect.EffectName = 'Ravager';
	Effect.TriggeredEvent = 'Ravager';
	Effect.CountValueName = 'RavagerShots';
	Effect.MaxRefundsPerTurn = 1;

	AbilityNameCondition = new class'XMBCondition_AbilityName';
	AbilityNameCondition.IncludeAbilityNames.AddItem('LWD_ChargedOnslaught');
	Effect.AbilityTargetConditions.AddItem(AbilityNameCondition);

	Effect.AbilityTargetConditions.AddItem(default.CritCondition);

	Template = Passive(TemplateName, ImageIcon, false, Effect);

	return Template;
}//Ravager
	
static function X2AbilityTemplate Reaver(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalBonus Effect;
	local TeddyXMBValue_Health Value;
	local XMBCondition_AbilityName AbilityCondition;

	Value = new class'TeddyXMBValue_Health';
	Value.bTarget = true;
	Value.bInvert = true;
	Value.fMult = 50.0;

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddToHitModifier(default.ReaverHitBonus);
	Effect.AddToHitModifier(default.ReaverCritBonus, eHit_Crit);

	Effect.ScaleValue = Value;
	Effect.ScaleMax = 50.0;

	AbilityCondition = new class'XMBCondition_AbilityName';
	AbilityCondition.IncludeAbilityNames.AddItem('LWD_ChargedReave');
	Effect.AbilityTargetConditions.AddItem(AbilityCondition);

	Template = Passive(TemplateName, ImageIcon, false, Effect);

	return Template;
}//Reaver
	
//static function X2AbilityTemplate (name TemplateName, string ImageIcon)
//{
//	
//}//