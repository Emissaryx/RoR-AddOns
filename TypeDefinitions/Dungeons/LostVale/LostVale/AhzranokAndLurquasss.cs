namespace WorldServer.World.Scripting.Dungeons.LostVale;

using Common.Enums.GameData;
using Common.Positions;
using WorldServer.World.Objects;

[GeneralScript(CreatureEntry = 59211)]
internal class Ahzranok : BasicCreatureScript
{
    public Ahzranok(Unit unit)
        : base(unit)
    {
        _creature.Enrage.EnableRangeUnits = 1080;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(ClearImmunities, 900, 0);

        _unit.AddCrowdControlImmunity(CrowdControlTypes.All);
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc(20779);
        SetRandomTargetToNpc(20778);
        SetRandomTargetToNpc(6830);
    }

    public void SayStuff1()
    {
        SendOnscreenMessageToAllPlayers("A large wave is approaching on the horizon!");
    }

    public void SayStuff2()
    {
        SendOnscreenMessageToAllPlayers("Lurquasss is near!");
    }

    public void SpawnLurquasss()
    {
        _adds.SpawnCreature(20779, new Point3D(1393568, 1584082, 5800), 2624);

        SendOnscreenMessageToAllPlayers("Lurquasss has arrived!");
    }

    public void SpawnEggs()
    {
        _unit.Tasks.AddTask(() => _adds.SpawnGameObject(100481, new Point3D(1393725, 1582041, 5798), 0), Random.Next(1, 11) * 100, 1);
        _unit.Tasks.AddTask(() => _adds.SpawnGameObject(100481, new Point3D(1394689, 1583233, 5800), 0), Random.Next(1, 11) * 100, 1);
        _unit.Tasks.AddTask(() => _adds.SpawnGameObject(100481, new Point3D(1394688, 1581509, 5808), 0), Random.Next(1, 11) * 100, 1);
        _unit.Tasks.AddTask(() => _adds.SpawnGameObject(100481, new Point3D(1395395, 1583750, 5800), 0), Random.Next(1, 11) * 100, 1);
        _unit.Tasks.AddTask(() => _adds.SpawnGameObject(100481, new Point3D(1394830, 1583999, 5800), 0), Random.Next(1, 11) * 100, 1);
        _unit.Tasks.AddTask(() => _adds.SpawnGameObject(100481, new Point3D(1394226, 1584388, 5800), 0), Random.Next(1, 11) * 100, 1);
        _unit.Tasks.AddTask(() => _adds.SpawnGameObject(100481, new Point3D(1395471, 1583617, 5800), 0), Random.Next(1, 11) * 100, 1);
        _unit.Tasks.AddTask(() => _adds.SpawnGameObject(100481, new Point3D(1394207, 1584497, 5800), 0), Random.Next(1, 11) * 100, 1);
        _unit.Tasks.AddTask(() => _adds.SpawnGameObject(100481, new Point3D(1394471, 1582606, 5785), 0), Random.Next(1, 11) * 100, 1);
        _unit.Tasks.AddTask(() => _adds.SpawnGameObject(100481, new Point3D(1395572, 1583008, 5800), 0), Random.Next(1, 11) * 100, 1);
        _unit.Tasks.AddTask(() => _adds.SpawnGameObject(100481, new Point3D(1395235, 1582711, 5800), 0), Random.Next(1, 11) * 100, 1);
        _unit.Tasks.AddTask(() => _adds.SpawnGameObject(100481, new Point3D(1394293, 1583679, 5800), 0), Random.Next(1, 11) * 100, 1);
        _unit.Tasks.AddTask(() => _adds.SpawnGameObject(100481, new Point3D(1393632, 1583182, 5806), 0), Random.Next(1, 11) * 100, 1);
        _unit.Tasks.AddTask(() => _adds.SpawnGameObject(100481, new Point3D(1393530, 1582814, 5808), 0), Random.Next(1, 11) * 100, 1);
        _unit.Tasks.AddTask(() => _adds.SpawnGameObject(100481, new Point3D(1394052, 1582784, 5799), 0), Random.Next(1, 11) * 100, 1);
        _unit.Tasks.AddTask(() => _adds.SpawnGameObject(100481, new Point3D(1394507, 1582856, 5794), 0), Random.Next(1, 11) * 100, 1);
        _unit.Tasks.AddTask(() => _adds.SpawnGameObject(100481, new Point3D(1394761, 1582870, 5800), 0), Random.Next(1, 11) * 100, 1);
        _unit.Tasks.AddTask(() => _adds.SpawnGameObject(100481, new Point3D(1394611, 1583708, 5800), 0), Random.Next(1, 11) * 100, 1);
        _unit.Tasks.AddTask(() => _adds.SpawnGameObject(100481, new Point3D(1395087, 1583456, 5800), 0), Random.Next(1, 11) * 100, 1);
        _unit.Tasks.AddTask(() => _adds.SpawnGameObject(100481, new Point3D(1395989, 1583189, 5800), 0), Random.Next(1, 11) * 100, 1);
    }

    public void CastBuff()
    {
        _unit.Abilities.AddAbility(4196, _unit, _unit.EffectiveLevel);

        SendOnscreenMessageToAllPlayers(_unit.Name + " skin hardens!");
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        _unit.Tasks.AddTask(CastBuff, 20 * 1000, 0);
        _unit.Tasks.AddTask(SayStuff1, 180 * 1000, 1);
        _unit.Tasks.AddTask(SayStuff2, 210 * 1000, 1);
        _unit.Tasks.AddTask(SpawnLurquasss, 240 * 1000, 1);

        SpawnEggs();

        _unit.Abilities.EndTargetAbilities((ushort)4196);

        base.OnEnterCombat(owner, attacker);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        ClearStuff();

        foreach (WorldObject? o in _unit.Region.Objects)
        {
            if (o is GameObject go && go.Entry == 100481)
            {
                go.Destroy();
                continue;
            }

            if (o is Creature c && (c.Entry == 6830 || c.Entry == 20778 || c.Entry == 20779))
            {
                c.Destroy();
            }
        }

        base.OnLeaveCombat(owner);
    }

    public override void OnDie(Unit obj)
    {
        ClearStuff();

        base.OnDie(obj);
    }

    public void ClearStuff()
    {
        _unit.Abilities.EndTargetAbilities((ushort)4196);
    }
}

[GeneralScript(CreatureEntry = 20779)]
internal class Lurquasss : BasicScript
{
    public Lurquasss(Unit unit)
        : base(unit)
    {
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        _unit.AddCrowdControlImmunity(CrowdControlTypes.All);

        base.OnObjectLoad(obj);
    }

    public override void OnEnterWorld(WorldObject obj)
    {
        GoToMommy(16078); // Here is mommy...
    }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public override void OnDie(Unit obj)
    {
        ClearStuff();

        base.OnDie(obj);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        ClearStuff();

        base.OnLeaveCombat(owner);
    }

    public void SpawnNpCs()
    {
        _adds.SpawnCreaturesAroundPos(20778, _unit.WorldSpawnPoint, 180, 4);
    }

    public void ClearStuff()
    {
        _unit.Tasks.RemoveTask(SpawnNpCs);
        _unit.Tasks.RemoveTask(SpawnNpCs);
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc(20778);
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        _unit.Tasks.AddTask(SpawnNpCs, 3000, 1);
        _unit.Tasks.AddTask(SpawnNpCs, 40 * 1000, 0);

        base.OnEnterCombat(owner, attacker);
    }
}

[GeneralScript(GameObjectEntry = 100481)]
internal class Egg : BasicScript
{
    public Egg(Unit unit)
        : base(unit)
    {
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        _unit.Tasks.AddTask(() => _adds.SpawnCreature(6830, _unit.WorldSpawnPoint, _unit.Heading), "SpawnAdd", 120 * 1000, 1);
        _unit.Tasks.AddTask(_unit.Destroy, 120 * 1000 + 100, 1);

        base.OnObjectLoad(obj);
    }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        Player? plr = null;

        if (_unit.Health.Value < 1)
        {
            if (attacker is Pet pet)
            {
                plr = pet.Owner as Player;
            }
            else if (attacker is Player)
            {
                plr = attacker as Player;
            }

            if (plr is not null)
            {
                Creature? boss = GetCreatureFromRegion(59211);

                if (boss is not null)
                {
                    boss.Aggro.Reset();
                    boss.Aggro.AddHatred(plr, 8000);
                    SendOnscreenMessageToAllPlayers($"Ahzranok cries in agony at the destruction of one of her eggs. She focuses her wrath on {plr.Name}!");
                }
            }
        }
    }
}

[GeneralScript(CreatureEntry = 6830)]
internal class EggNpc : BasicCreatureScript
{
    public EggNpc(Unit unit)
        : base(unit)
    {
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        _creature.Aggro.SendAggroUpdate = false;

        obj.Tasks.AddTask(ChangeSpawn, 300, 1);

        base.OnObjectLoad(obj);
    }

    public override void OnEnterWorld(WorldObject obj)
    {
        GoToMommy(59211); // Here is mommy...
    }

    public void ChangeSpawn()
    {
        Creature? boss = GetCreatureFromRegion(59211);
        if (boss is not null)
        {
            _creature.WorldSpawnPoint.X = boss.WorldSpawnPoint.X;
            _creature.WorldSpawnPoint.Y = boss.WorldSpawnPoint.Y;
            _creature.WorldSpawnPoint.Z = boss.WorldSpawnPoint.Z;
        }
    }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public override void OnDie(Unit obj)
    {
        ClearStuff();

        base.OnDie(obj);
    }

    public void ClearStuff()
    {
        _unit.Tasks.RemoveTask(ChangeSpawn);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        base.OnLeaveCombat(owner);
    }
}
