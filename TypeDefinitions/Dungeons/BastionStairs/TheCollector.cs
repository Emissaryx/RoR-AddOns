namespace Game.Scripts.Dungeons.BastionStairs;

using Common.Enums.GameData;
using Common.Enums.SystemData;
using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript]
internal class TheCollector : BasicCreatureScript
{
    public TheCollector(Creature creature, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(creature, pQuestRepository, gameObjectRepository)
    {
        _creature.Enrage.EnableRangeUnits = 1620;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(SlayPlayersWithoutCompletedInfluence, 1000, 0);

        _unit.IsActive = false;
        _unit.SendMeTo();
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc((int)GetTerrorCreature());
    }

    public void SlayPlayersWithoutCompletedInfluence()
    {
        if (_unit.IsActive && !_unit.IsDead && _unit.CombatFlag.IsInCombat)
        {
            foreach (Player plr in _unit.Region.Players)
            {
                if (!plr.Influence.IsInfluenceTrackCompleted(128) && plr.Influence.IsInfluenceTrackCompleted(129))
                {
                    plr.SendClientMessage("Collector slayed you for your impertinence.");
                    plr.Terminate();
                }
            }
        }
    }
}

[GeneralScript]
internal class TheCollectorSpawnGo : BasicGameObjectScript
{
    public TheCollectorSpawnGo(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        _go.CaptureDuration = TimeSpan.FromSeconds(5);
    }

    public override void NotifyInteractionComplete(WorldObject obj, Player target)
    {
        if (target.Influence.IsInfluenceTrackCompleted(128) || target.Influence.IsInfluenceTrackCompleted(129))
        {
            foreach (Player plr in obj.Region.Players)
            {
                if (
                    plr.DormantInfo.HasFlag(DormantFlags.CannotBeTargeted)
                    || plr.DormantInfo.HasFlag(DormantFlags.CannotBeAttacked)
                    || plr.Stealth.IsInStealth
                )
                {
                    continue;
                }

                if (plr.Influence.IsInfluenceTrackCompleted(128) || plr.Influence.IsInfluenceTrackCompleted(129))
                {
                    continue;
                }

                target.SendClientMessage(
                    plr.Name
                        + " didn't complete Bastion Stairs influence tracker and therefore you are unable to summon The Collector.",
                    ChatLogFilter.CSRTellReceive
                );

                return;
            }

            Creature? c = GetCreatureFromRegion(0);
            c.IsActive = true;
            c.SendMeTo();
        }
        else
        {
            target.SendClientMessage(
                "You need to complete Bastion Stairs influence tracker to summon The Collector.",
                ChatLogFilter.CSRTellReceive
            );
        }
    }
}
