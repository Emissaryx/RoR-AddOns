namespace Game.Scripts.Dungeons.Gunbad;

using Common.Enums.GameData;
using Common.Enums.SystemData;
using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 36615)]
internal class MastaWranglaGlix : BasicScript
{
    public MastaWranglaGlix(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        if (_unit is not Creature c)
        {
            return;
        }

        c.DormantInfo &= ~DormantFlags.CannotBeTargeted & ~DormantFlags.CannotBeAttacked;
        _stageNum = -1;

        _unit.Tasks.AddTask(SpawnTrolls, 100, 1);
        _unit.Tasks.AddTask(SpawnTrolls, 45 * 1000, 0);
    }

    public void SpawnTrolls()
    {
        if (_unit is not Creature c)
        {
            return;
        }

        if (!c.IsDead)
        {
            // Young Trolls
            _adds.SpawnCreaturesAroundPos(2000881, _unit.WorldPosition, 360, 4);
        }
        else
        {
            // c.ScdInterface.RemoveTask(MatureTrolls);
            c.Tasks.RemoveTask(SpawnTrolls);
        }
    }

    public void SpawnAdultTrolls()
    {
        if (_unit is not Creature c)
        {
            return;
        }

        if (!c.IsDead)
        {
            // Adult Trolls
            _adds.SpawnCreaturesAroundPos(2000882, _unit.WorldPosition, 360, 4);
        }
        else
        {
            // c.ScdInterface.RemoveTask(MatureTrolls);
            c.Tasks.RemoveTask(SpawnAdultTrolls);
        }
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        if (_stageNum < 0 && !_unit.IsDead)
        {
            _stageNum = 0; // Setting control value to 0
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.20 && _stageNum < 4 && !_unit.IsDead)
        {
            ClearCommonEvents();
            _unit.Tasks.RemoveTask(SpawnTrolls);
            _unit.Tasks.RemoveTask(SayStuff);

            SayStuff();

            _unit.Tasks.AddTask(SpawnAdultTrolls, 100, 1);

            _unit.Tasks.AddTask(SpawnAdultTrolls, 50 * 1000, 0);

            _unit.Tasks.AddTask(SayStuff, 25 * 1000, 0);

            _stageNum = 4;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.4 && _stageNum < 3 && !_unit.IsDead)
        {
            ClearCommonEvents();
            _unit.Tasks.RemoveTask(SpawnTrolls);

            _unit.Tasks.RemoveTask(SayStuff);

            SayStuff();

            _unit.Tasks.AddTask(SpawnTrolls, 100, 1);

            _unit.Tasks.AddTask(SpawnTrolls, 30 * 1000, 0);

            _unit.Tasks.AddTask(SayStuff, 35 * 1000, 0);

            _stageNum = 3;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.6 && _stageNum < 2 && !_unit.IsDead)
        {
            ClearCommonEvents();
            _unit.Tasks.RemoveTask(SpawnTrolls);
            _unit.Tasks.RemoveTask(SayStuff);

            // Young Trolls
            _adds.SpawnCreaturesAroundPos(2000881, _unit.WorldPosition, 360, 2);

            /*SayStuff();

            c.ScdInterface.AddTask(SpawnTrolls, 100, 1);

            c.ScdInterface.AddTask(SpawnTrolls, 35 * 1000, 0);

            c.ScdInterface.AddTask(SayStuff, 35 * 1000, 0);*/

            _stageNum = 2;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.8 && _stageNum < 1 && !_unit.IsDead)
        {
            ClearCommonEvents();
            _unit.Tasks.RemoveTask(SpawnTrolls);

            _adds.SpawnCreaturesAroundPos(2000881, _unit.WorldPosition, 360); // Young Troll

            /*SayStuff();

            c.ScdInterface.AddTask(SpawnTrolls, 100, 1);

            c.ScdInterface.AddTask(SpawnTrolls, 40 * 1000, 0);
            c.ScdInterface.AddTask(SayStuff, 40 * 1000, 0);*/

            _stageNum = 1;
        }
    }

    public new void SayStuff()
    {
        if (_unit is not Creature c)
        {
            return;
        }

        if (!c.IsDead)
        {
            switch (Random.Shared.Next(1, 4))
            {
                case 1:
                    c.Say("Git 'ere! Take 'em! Eat 'em!", ChatLogFilter.MonsterSay);
                    break;
                case 2:
                    c.Say("Dose gits ain't nuffink! Get 'em, trolls!", ChatLogFilter.MonsterSay);
                    break;
                case 3:
                    c.Say("Now youse jus' makin' me mad!", ChatLogFilter.MonsterSay);
                    break;
            }
        }
    }

    public override void OnLeaveCombat(Unit owner)
    {
        base.OnLeaveCombat(owner);

        owner.Tasks.RemoveTask(SpawnTrolls);
        owner.Tasks.RemoveTask(SpawnAdultTrolls);

        foreach (WorldObject obj in owner.ObjectsInRange)
        {
            Creature? creature = obj as Creature;
            if (creature is not null && creature.Entry == 2000881)
            {
                creature.Destroy();
            }

            if (creature is not null && creature.Entry == 2000882)
            {
                creature.Destroy();
            }
        }
    }

    public override void OnDie(Unit obj)
    {
        base.OnDie(obj);

        obj.Say("Youse... kilt... me... but da Mixa make short work of youse! Unnghhh!", ChatLogFilter.MonsterSay);

        // Obj.ScdInterface.RemoveTask(MatureTrolls);
        obj.Tasks.RemoveTask(SpawnTrolls);

        obj.Tasks.RemoveTask(SpawnAdultTrolls);

        DestroyWall();
        SpawnGoldChest(510); // This is Gunbad loot chest

        EndPublicQuest(508); // pq ID

        AddInfluenceToAllPlayersInRegion(64, 65, 800);
    }

    public void DestroyWall()
    {
        if (_unit.Region is null)
        {
            return;
        }

        foreach (WorldObject? o in _unit.Region.Objects)
        {
            if (o is GameObject go && go.Entry == 100006)
            {
                go.Destroy();
            }
        }
    }
}

[GeneralScript(CreatureEntry = 2000881)]
internal class GlixYoungTroll : BasicScript
{
    public GlixYoungTroll(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnEnterWorld(WorldObject obj)
    {
        SetRandomTarget();
    }

    public void MatureTroll()
    {
        if (_unit is Creature c && !c.IsDead)
        {
            _adds.SpawnCreature(2000882, c.WorldPosition, c.Heading); // Adult Troll
            c.PlayEffect(2185);
            c.Tasks.AddTask(c.Destroy, 1500, 1);
        }
    }
}

[GeneralScript(CreatureEntry = 2000882)]
internal class GlixAdultTroll : BasicScript
{
    public GlixAdultTroll(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnEnterWorld(WorldObject obj)
    {
        SetRandomTarget();
    }
}
