namespace Game.Scripts.Dungeons.SigmarsCrypt;

using Common.Enums.GameData;
using Common.Enums.SystemData;
using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 2001354)]
internal class ArchLectorZakarai : BasicCreatureScript
{
    private const uint ArchLectorVerriums = 2001355;

    public ArchLectorZakarai(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository)
    {
        // Cover entire room, enrage on stairs only
        _creature.Enrage.EnableRangeUnits = 2450;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(ClearImmunities, 900, 0);

        _unit.AddCrowdControlImmunity(CrowdControlTypes.Disabled);
        _unit.AddCrowdControlImmunity(CrowdControlTypes.Disarm);
        _unit.AddCrowdControlImmunity(CrowdControlTypes.Knockdown);
        _unit.AddCrowdControlImmunity(CrowdControlTypes.Root);
        _unit.AddCrowdControlImmunity(CrowdControlTypes.Silence);
        _unit.AddCrowdControlImmunity(CrowdControlTypes.Stagger);
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        base.OnEnterCombat(owner, attacker);

        _unit.Tasks.AddTask(SayStuff, 20 * 1000, 0);

        _unit.Tasks.AddTask(CheckHealthAndCast, 5 * 1000, 0);
    }

    public override void SayStuff()
    {
        _unit.Say("We grow weary of this exchange!", ChatLogFilter.MonsterSay);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        _unit.Tasks.RemoveTask(CheckHealthAndCast);

        _unit.Abilities.EndTargetAbilities(13635);
        _unit.Abilities.EndTargetAbilities(13636);

        ClearBuffOnPlayers(13314);

        base.OnLeaveCombat(owner);
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        GetCreatureFromRegion(ArchLectorVerriums)?.CombatFlag.RefreshCombatTimer(attacker);
    }

    public override void OnDie(Unit obj)
    {
        _unit.Tasks.RemoveTask(CheckHealthAndCast);

        _unit.Abilities.EndTargetAbilities(13635);
        _unit.Abilities.EndTargetAbilities(13636);

        foreach (WorldObject objInRange in obj.ObjectsInRange)
        {
            if (objInRange is Creature creature && creature.Entry == ArchLectorVerriums)
            {
                DelayedBuff(creature, 13636, "You will pay for this!"); // Rage
            }
        }

        ClearBuffOnPlayers(13314);

        base.OnDie(obj);
    }

    // <summary>

    /// This is wrapper for event
    /// </summary>
    private void CheckHealthAndCast()
    {
        CheckFriendHealthAndHandleBuff(13636, ArchLectorVerriums, 10, true, "Our unity gives us strength!");
        CheckFriendHealthAndHandleBuff(13635, ArchLectorVerriums, 10, true);
    }
}
