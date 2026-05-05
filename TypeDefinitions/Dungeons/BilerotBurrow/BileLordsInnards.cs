namespace Game.Scripts.Dungeons.BilerotBurrow;

using Common.Enums.GameData;
using Common.Enums.SystemData;
using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 2000725)]
internal class BileLordsInnards : BasicCreatureScript
{
    public BileLordsInnards(
        Creature creature,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository
    )
        : base(creature, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(ClearImmunities, 900, 0);

        _creature.AddCrowdControlImmunity(CrowdControlTypes.All);

        _creature.Aggro.SendAggroUpdate = true;
    }

    public override void OnDie(Unit obj)
    {
        _unit.AbilityCast.StartCast(13936, 0);

        int i = 0;
        foreach (Player plr in _unit.PlayersInRange)
        {
#if DEBUG
            plr.SendClientMessage("Attempting to teleport player to bile lord", ChatLogFilter.CSRTellReceive);
#endif

            _creature.Tasks.AddTask(
                () =>
                {
                    plr.IntraRegionTeleport(
                        1500978 + (uint)Random.Shared.Next(50, 500),
                        1048689 + (uint)Random.Shared.Next(50, 500),
                        11410,
                        2992
                    );
                },
                ++i * 500,
                1
            );
        }

        if (obj.Region?.Objects.FirstOrDefault(o => o is Creature c && c.Entry == 52594) is Creature bileLord)
        {
            bileLord.Tasks.AddTask(RemoveStunFromBileLord, 3000, 1);
            bileLord.Tasks.AddTask(RemoveStunFromBileLord, 3000, 1);
            bileLord.Tasks.AddTask(RemoveStunFromBileLord, 4000, 1);
            bileLord.Tasks.AddTask(RemoveStunFromBileLord, 5000, 1);
            bileLord.Tasks.AddTask(RemoveStunFromBileLord, 6000, 1);
        }

        base.OnDie(obj);
    }

    public void RemoveStunFromBileLord()
    {
        if (_unit.Region is null)
        {
            return;
        }

        foreach (WorldObject? o in _unit.Region.Objects)
        {
            if (o is Creature c && c.Entry == 52594)
            {
                c.Speed.SetBaseSpeed(100);
#if DEBUG
                c.Say("Setting speed to 100...");
#endif
                break;
            }
        }
    }
}
