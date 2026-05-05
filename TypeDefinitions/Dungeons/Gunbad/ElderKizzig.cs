namespace Game.Scripts.Dungeons.Gunbad;

using Common.Enums.GameData;
using Common.Enums.SystemData;
using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 36612)]
internal class ElderKizzig : BasicScript
{
    public ElderKizzig(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        if (_unit is not Creature c)
        {
            return;
        }

        c.DormantInfo &= ~DormantFlags.CannotBeTargeted & ~DormantFlags.CannotBeAttacked;
        _stageNum = -1;

        // Spawn Chipfang
        _adds.SpawnCreaturesAroundPos(36598, _unit.WorldPosition, 300);

        c.Tasks.AddTask(SpawnSnotlings, 200, 1);

        c.Tasks.AddTask(SpawnSnotlings, 60 * 1000, 0);

        c.Say("Com 'er Chipfang, we 'l show 'em!", ChatLogFilter.MonsterSay);

        c.Abilities.EndTargetAbilities(4398); // Removing rage
    }

    public override void OnLeaveCombat(Unit owner)
    {
        base.OnLeaveCombat(owner);

        owner.Abilities.EndTargetAbilities(4398); // Removing rage

        owner.Tasks.RemoveTask(SpawnSnotlings);
    }

    public override void OnDie(Unit obj)
    {
        base.OnDie(obj);

        obj.Abilities.EndTargetAbilities(4398); // Removing rage

        obj.Tasks.RemoveTask(SpawnSnotlings);

        DestroyWall();
        SpawnGoldChest(510); // This is Gunbad loot chest

        EndPublicQuest(507);

        AddInfluenceToAllPlayersInRegion(64, 65, 800);
    }

    public void DestroyWall()
    {
        foreach (WorldObject? o in _unit.Region.Objects)
        {
            if (o is GameObject go && go.Entry == 100007)
            {
                go.Destroy();
            }
        }
    }

    public void SpawnSnotlings()
    {
        _adds.SpawnCreaturesAroundPos(2000903, _unit.WorldPosition, 240, 5);
    }
}

[GeneralScript(CreatureEntry = 36598)]
internal class ChipfangKizzig : BasicScript
{
    public ChipfangKizzig(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.PlayEffect(2185);

        obj.Tasks.AddTask(SetRandomTarget, 200, 1);
    }

    public override void OnDie(Unit obj)
    {
        _stageNum = -1;
        foreach (WorldObject objInRange in obj.ObjectsInRange)
        {
            if (objInRange is Creature creature && creature.Entry == 36612)
            {
                // creature.AbtInterface.StartCast(creature, 13155, 1);
                DelayedBuff(creature, 4398, "No, it cannot be... Nau DIE!"); // Rage
            }
        }
    }

    public override void SetRandomTarget()
    {
        if (_unit is Creature c && c.PlayersInRange.Count > 0)
        {
            bool haveTarget = false;
            int playersInRange = c.PlayersInRange.Count;
            Player? player;
            byte i = 0;
            while (!haveTarget && i < 15)
            {
                int rndmPlr = Random.Shared.Next(1, playersInRange + 1);
                WorldObject obj = c.PlayersInRange.ElementAt(rndmPlr - 1);
                player = obj as Player;
                if (
                    player is not null
                    && !player.IsDead
                    && !player.DormantInfo.HasFlag(DormantFlags.CannotBeTargeted)
                    && !player.DormantInfo.HasFlag(DormantFlags.CannotBeAttacked)
                )
                {
                    haveTarget = true;
                    c.Movement.TurnTo(player);
                    c.Movement.Follow(player, 60, 120);
                    break;
                }

                i++;
            }
        }
    }
}

[GeneralScript(CreatureEntry = 2000903)]
internal class FalseSnotlingKizzig : BasicScript
{
    public FalseSnotlingKizzig(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(SetRandomTarget, 200, 1);

        obj.Tasks.AddTask(SayStuff, Random.Shared.Next(1, 6) * 1000, 1);
        obj.Tasks.AddTask(SayStuff, Random.Shared.Next(1, 4) * 5 * 1000, 0);
    }

    public override void OnEnterWorld(WorldObject obj)
    {
        base.OnEnterWorld(obj);

        obj.PlayEffect(2185);

        SetRandomTarget();
    }

    public new void SayStuff()
    {
        if (
            _unit is Creature c
            && !c.IsDead
            && c.Targets.Get(TargetTypes.TARGETTYPES_TARGET_ENEMY) is Player plr
            && !plr.IsDead
        )
        {
            switch (Random.Shared.Next(1, 3))
            {
                case 1:
                    c.Say($"In da jingles {plr.Name}!", ChatLogFilter.MonsterSay);
                    break;
                case 2:
                    c.Say($"In yar face {plr.Name}!", ChatLogFilter.MonsterSay);
                    break;
            }
        }
    }

    public override void OnDie(Unit obj)
    {
        obj.Tasks.RemoveTask(SayStuff);
        obj.Tasks.RemoveTask(SayStuff);
    }

    public override void SetRandomTarget()
    {
        if (_unit is Creature c && c.PlayersInRange.Count > 0)
        {
            bool haveTarget = false;
            int playersInRange = c.PlayersInRange.Count;
            Player? player;
            byte i = 0;
            while (!haveTarget && i < 15)
            {
                int rndmPlr = Random.Shared.Next(1, playersInRange + 1);
                WorldObject obj = c.PlayersInRange.ElementAt(rndmPlr - 1);
                player = obj as Player;
                if (
                    player is not null
                    && !player.IsDead
                    && !player.DormantInfo.HasFlag(DormantFlags.CannotBeTargeted)
                    && !player.DormantInfo.HasFlag(DormantFlags.CannotBeAttacked)
                )
                {
                    haveTarget = true;
                    c.Movement.TurnTo(player);
                    c.Movement.Follow(player, 60, 120);
                    break;
                }

                i++;
            }
        }
    }
}
