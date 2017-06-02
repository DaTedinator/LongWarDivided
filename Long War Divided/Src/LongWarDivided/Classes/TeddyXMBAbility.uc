// Just a collection of my additional helper functions
class TeddyXMBAbility extends XMBAbility;

// Helper function for creating an ability that targets a visible enemy you've targeted with another ability
static function X2AbilityTemplate OnHitDebuff(name DataName, string IconImage, optional bool bCrossClassEligible = false, optional X2Effect Effect = none, optional int ShotHUDPriority = default.AUTO_PRIORITY, optional EAbilityHitResult HitResult = eHit_Success)
{
	local X2AbilityTemplate                 Template;	
	local X2Condition_UnitProperty			TargetCondition;
	local XMBAbilityTrigger_EventListener	EventListener;
	local XMBCondition_AbilityName			Condition;

	`CREATE_X2ABILITY_TEMPLATE(Template, DataName);

	Template.ShotHUDPriority = ShotHUDPriority;
	Template.IconImage = IconImage;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.Hostility = eHostility_Offensive;

	TargetCondition = new class'X2Condition_UnitProperty';
	TargetCondition.ExcludeDead = false;
	TargetCondition.ExcludeFriendlyToSource = true;
	Template.AbilityTargetConditions.AddItem(TargetCondition);

	// 100% chance to hit
	Template.AbilityToHitCalc = default.DeadEye;

	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	EventListener = new class'XMBAbilityTrigger_EventListener';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.EventID = 'AbilityActivated';
	EventListener.ListenerData.Filter = eFilter_Unit;
	switch ( HitResult )
	{
		case eHit_Success: 
			EventListener.AbilityTargetConditions.AddItem(default.HitCondition);
			break;
		case eHit_Miss: 
			EventListener.AbilityTargetConditions.AddItem(default.MissCondition);
			break;
		case eHit_Crit: 
			EventListener.AbilityTargetConditions.AddItem(default.CritCondition);
			break;
		case eHit_Graze: 
			EventListener.AbilityTargetConditions.AddItem(default.GrazeCondition);
			break;
		default:
			break;
	}
	Template.AbilityTriggers.AddItem(EventListener);

	if (Effect != none)
	{
		if (X2Effect_Persistent(Effect) != none)
			X2Effect_Persistent(Effect).SetDisplayInfo(ePerkBuff_Penalty, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true, , Template.AbilitySourceName);

		Template.AddTargetEffect(Effect);
	}

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.bSkipFireAction = true;
	Template.SourceMissSpeech = '';
	Template.SourceHitSpeech = '';
	
	Template.bCrossClassEligible = bCrossClassEligible;

	Condition = new class'XMBCondition_AbilityName';
	Condition.ExcludeAbilityNames.AddItem(DataName);
	AddTriggerTargetCondition(Template, Condition);

	return Template;
}

// As MeleeAttack in XMBAbility, but with some extra arguments to check MovementRangeAdjustment and limit max range.
static function X2AbilityTemplate LimitedMeleeAttack(name DataName, string IconImage, optional bool bCrossClassEligible = false, optional X2Effect Effect = none, optional int ShotHUDPriority = default.AUTO_PRIORITY, optional EActionPointCost Cost = eCost_SingleConsumeAll,
														optional bool BlueMove = false,
														optional int MaxDistanceTravelled = -1,
														optional int MovementRangeAdj = 0)
{
	local X2AbilityTemplate							Template;
	local X2AbilityTarget_MovingMelee				TargetStyle;
	local TeddyXMBCondition_MeleeMovement			Condition;

	`CREATE_X2ABILITY_TEMPLATE(Template, DataName);

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.CinescriptCameraType = "Ranger_Reaper";
	Template.IconImage = IconImage;
	Template.ShotHUDPriority = ShotHUDPriority;

	if (Cost != eCost_None)
	{
		Template.AbilityCosts.AddItem(ActionPointCost(Cost));	
	}

	Template.AbilityToHitCalc = new class'X2AbilityToHitCalc_StandardMelee';

	TargetStyle = new class'X2AbilityTarget_MovingMelee';
	TargetStyle.MovementRangeAdjustment = MovementRangeAdj;
	Template.AbilityTargetStyle = TargetStyle;

	Condition = new class'TeddyXMBCondition_MeleeMovement';
	Condition.bBlueMove = BlueMove;
	Condition.MaxMovementRange = MaxDistanceTravelled;
	Template.AbilityTargetConditions.AddItem(Condition);

	Template.TargetingMethod = class'X2TargetingMethod_MeleePath';

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_EndOfMove');

	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	Template.AbilityTargetConditions.AddItem(default.MeleeVisibilityCondition);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	// Don't allow the ability to be used while the unit is disoriented, burning, unconscious, etc.
	Template.AddShooterEffectExclusions();

	if (Effect != none)
	{
		Template.AddTargetEffect(Effect);
	}
	else
	{
		Template.AddTargetEffect(new class'X2Effect_ApplyWeaponDamage');
	}

	Template.bAllowBonusWeaponEffects = true;
	Template.bSkipMoveStop = true;
	
	// Voice events
	//
	Template.SourceMissSpeech = 'SwordMiss';

	Template.BuildNewGameStateFn = TypicalMoveEndAbility_BuildGameState;
	Template.BuildInterruptGameStateFn = TypicalMoveEndAbility_BuildInterruptGameState;

	Template.bCrossClassEligible = bCrossClassEligible;

	return Template;
}