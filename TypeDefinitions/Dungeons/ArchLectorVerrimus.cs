namespace WorldServer.World.Scripting.Dungeons.SigmarsCrypt;

using Common.Enums.GameData;
using Common.Enums.SystemData;
using Common.Positions;
using WorldServer.Repositories.World;
using WorldServer.World.Objects;

[GeneralScript(CreatureEntry = 2001355)]
internal class ArchLectorVerrimus : BasicCreatureScript
{
    private const uint ArchLectorZakarai = 2001354;

    public ArchLectorVerrimus(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
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

        _unit.Tasks.AddTask(CheckHealthAndCast, 5 * 1000, 0);

        _unit.Say("Come, brother Zakarai! Let's show them some sylvanian hospitality!", ChatLogFilter.MonsterSay);

        _unit.Tasks.AddTask(SayStuff, 20 * 1000, 0);

        if (GetCreatureCountFromRegion(ArchLectorZakarai) < 1)
        {
            _adds.SpawnCreature(ArchLectorZakarai, new Point3D(1499280, 216524, 8630), _unit.Heading); // Arch Lector Zahari
        }

        _unit.Tasks.AddTask(TerminateSoloPlayers, 1000, 0);

        SpawnSigmarsCryptWalls();
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

        DespawnCityDungeonWalls();

        base.OnLeaveCombat(owner);
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        GetCreatureFromRegion(ArchLectorZakarai)?.CombatFlag.RefreshCombatTimer(attacker);
    }

    public override void OnDie(Unit obj)
    {
        obj.Tasks.RemoveTask(CheckHealthAndCast);

        obj.Abilities.EndTargetAbilities(13635);
        obj.Abilities.EndTargetAbilities(13636);

        foreach (WorldObject objInRange in obj.ObjectsInRange)
        {
            if (objInRange is Creature creature && creature.Entry == ArchLectorZakarai)
            {
                DelayedBuff(creature, 13636, "You will pay for this!"); // Rage
                DelayedBuff(creature, 13315);
            }

            if (objInRange is Player p)
            {
                obj.Abilities.AddAbility(13314, p, obj.EffectiveLevel);
            }
        }

        DespawnCityDungeonWalls();

        base.OnDie(obj);
    }

    /// <summary>
    /// This is wrapper for event.
    /// </summary>
    private void CheckHealthAndCast()
    {
        CheckFriendHealthAndHandleBuff(13636, ArchLectorZakarai, 10, true, "Our unity gives us strength!");
        CheckFriendHealthAndHandleBuff(13635, ArchLectorZakarai, 10, true);
    }
}
