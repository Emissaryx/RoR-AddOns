namespace Game.Scripts.Dungeons.BastionStairs;

using Common.Enums.GameData;
using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 46330)]
internal class Kaarn : BasicScript
{
    public const ushort BloodPool = 5068;
    public const ushort RageOfKhorne = 5064;
    public const ushort Bloodrage = 5353;
    public const ushort ThroatBite = 20679;
    public const ushort Armored = 24679;

    public Kaarn(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc((int)GetTerrorCreature());
    }

    public void CastBuff()
    {
        _unit.Abilities.AddAbility(RageOfKhorne, _unit, _unit.EffectiveLevel);
        SendOnscreenMessageToAllPlayers("Kaarn boils with rage!");
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        ClearStuff();

        _unit.Tasks.AddTask(ZCheck, 1000, 0);

        _adds.SpawnGameObject(2000916, new(1012586, 999071, 10565), 32);

        _unit.Tasks.AddTask(CastBuff, 90 * 1000, 0);

        base.OnEnterCombat(owner, attacker);
    }

    private void ZCheck()
    {
        if (_unit.WorldPosition.Z < 9390 || _unit.WorldPosition.Z > 9460)
        {
            if (!_unit.Abilities.HasBuffById(Armored))
            {
                _unit.Abilities.AddAbility(Armored, _unit, _unit.EffectiveLevel);
                SendOnscreenMessageToAllPlayers("Kaarn skin turns to iron as he leaves the podium!");
            }
        }
        else
        {
            if (_unit.Abilities.HasBuffById(Armored))
            {
                _unit.Abilities.EndTargetAbilities(Armored);
                SendOnscreenMessageToAllPlayers("Kaarn skin turns back to cursed flesh!");
            }
        }
    }

    public override void OnLeaveCombat(Unit owner)
    {
        _unit.Tasks.RemoveTask(ZCheck);

        base.OnLeaveCombat(owner);
        ClearStuff();
    }

    public override void OnDie(Unit obj)
    {
        obj.Tasks.RemoveTask(ZCheck);

        ClearStuff();

        //AddInfluenceToAllPlayersInRegion(128, 2000);
        //AddInfluenceToAllPlayersInRegion(129, 2000);

        base.OnDie(obj);
    }

    public void ClearStuff()
    {
        if (_unit.Region is null)
        {
            return;
        }

        foreach (WorldObject? o in _unit.Region.Objects)
        {
            if (o is GameObject go && go.Entry is 2000916 or 2000896 or 2000897 or 2000898)
            {
                go.Destroy();
            }

            if (o is Creature crea && crea.Entry == 2001621)
            {
                crea.Destroy();
            }
        }

        foreach (Player plr in _unit.PlayersInRange)
        {
            plr.Abilities.EndTargetAbilities(BloodPool);
        }

        _unit.Abilities.EndTargetAbilities(RageOfKhorne);
        _unit.Abilities.EndTargetAbilities(Bloodrage);
        _unit.Abilities.EndTargetAbilities(ThroatBite);

        _unit.Tasks.RemoveTask(CastBuff);
        _unit.Tasks.RemoveTask(CastBuff);
    }
}

[GeneralScript(GameObjectEntry = 2000916)]
internal class KaarnGo : BasicGameObjectScript
{
    public KaarnGo(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(SpawnRandomGameObject, 45 * 1000, 1);

        _go.NoRespawn = true;
    }

    private void SpawnRandomGameObject()
    {
        uint protoEntry = Random.Shared.Next(0, 3) switch
        {
            0 => 2000896,
            1 => 2000897,
            2 => 2000898,
            _ => 2000896,
        };

        Creature? c = GetCreatureFromRegion(46330);
        if (c is not null && !c.IsDead && c.CombatFlag.IsInCombat)
        {
            _unit.Region?.CreateGameObject(protoEntry, _unit.WorldPosition, _unit.Heading);
        }

        _unit.Destroy();
    }
}

[GeneralScript(GameObjectEntry = 2000896)]
internal class KaarnGo1 : BasicGameObjectScript
{
    public KaarnGo1(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(HalfHate, 100, 1);
        obj.Tasks.AddTask(HalfHate, 20 * 1000, 0);

        _go.NoRespawn = true;

        SendOnscreenMessageToAllPlayers($"{_go.Name} corrupting influence is spreading!");

        GameObject? gameobject = GetAliveGameObjectFromRegion(2000916);

        if (gameobject is not null)
        {
            gameobject.Destroy();
        }
    }

    public override void OnDie(Unit obj)
    {
        Creature? c = GetCreatureFromRegion(46330);

        if (c is not null && !c.IsDead && c.CombatFlag.IsInCombat)
        {
            obj.Region?.CreateGameObject(2000916, obj.WorldPosition, obj.Heading);
        }

        obj.Destroy();

        obj.Tasks.RemoveTask(HalfHate);
    }

    private void HalfHate()
    {
        if (_unit is not GameObject go || go.IsDead)
        {
            return;
        }

        Creature? c = GetCreatureFromRegion(46330);
        if (c is null || c.IsDead || !c.CombatFlag.IsInCombat)
        {
            return;
        }

        Unit? target = c.Targets.Get(TargetTypes.TARGETTYPES_TARGET_ENEMY);
        if (target is null || target.IsDead)
        {
            return;
        }

        long hatred = (long)(c.Aggro.GetAggro(target.Oid).GetValueOrDefault().Hatred * 0.6);
        hatred *= -1;
        c.Aggro.AddHatred(target, hatred);
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        Creature? boss = GetCreatureFromRegion(46330);

        if (boss is not null && obj is Player plr)
        {
            boss.Aggro.RemoveHatred(plr);
        }
    }
}

[GeneralScript(GameObjectEntry = 2000897)]
internal class KaarnGo2 : BasicGameObjectScript
{
    public KaarnGo2(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(CastBuff, 100, 1);
        obj.Tasks.AddTask(CastBuff, 4 * 1000, 0);

        _go.NoRespawn = true;

        SendOnscreenMessageToAllPlayers($"{_go.Name} corrupting influence is spreading!");

        GameObject? gameobject = GetAliveGameObjectFromRegion(2000916);

        if (gameobject is not null)
        {
            gameobject.Destroy();
        }
    }

    public override void OnDie(Unit obj)
    {
        Creature? c = GetCreatureFromRegion(46330);
        if (c is not null)
        {
            if (!c.IsDead && c.CombatFlag.IsInCombat)
            {
                obj.Region?.CreateGameObject(2000916, obj.WorldPosition, obj.Heading);
            }

            c.Abilities.EndTargetAbilities(Kaarn.Bloodrage);
        }

        obj.Tasks.RemoveTask(CastBuff);
        obj.Tasks.RemoveTask(CastBuff);

        base.OnDie(obj);
        obj.Destroy();
    }

    private void CastBuff()
    {
        if (_unit is not GameObject go || go.IsDead)
        {
            return;
        }

        Creature? c = GetCreatureFromRegion(46330);
        if (c is null || c.IsDead || !c.CombatFlag.IsInCombat)
        {
            return;
        }

        if (!c.Abilities.HasBuffById(Kaarn.Bloodrage))
        {
            c.Abilities.AddAbility(Kaarn.Bloodrage, c, c.EffectiveLevel);
        }
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        Creature? boss = GetCreatureFromRegion(46330);

        if (boss is not null && obj is Player plr)
        {
            boss.Aggro.RemoveHatred(plr);
        }
    }
}

[GeneralScript(GameObjectEntry = 2000898)]
internal class KaarnGo3 : BasicGameObjectScript
{
    public KaarnGo3(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(CastBuff, 100, 1);
        obj.Tasks.AddTask(CastBuff, 15 * 1000, 0);

        _go.NoRespawn = true;

        SendOnscreenMessageToAllPlayers($"{_go.Name} corrupting influence is spreading!");

        GameObject? gameobject = GetAliveGameObjectFromRegion(2000916);

        if (gameobject is not null)
        {
            gameobject.Destroy();
        }
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        Creature? boss = GetCreatureFromRegion(46330);

        if (boss is not null && obj is Player plr)
        {
            boss.Aggro.RemoveHatred(plr);
        }
    }

    public override void OnDie(Unit obj)
    {
        Creature? c = GetCreatureFromRegion(46330);
        if (c is not null)
        {
            if (!c.IsDead && c.CombatFlag.IsInCombat)
            {
                obj.Region?.CreateGameObject(2000916, obj.WorldPosition, obj.Heading);
            }

            foreach (Player plr in c.PlayersInRange)
            {
                plr.Abilities.EndTargetAbilities(Kaarn.BloodPool);
            }
        }

        obj.Tasks.RemoveTask(CastBuff);

        base.OnDie(obj);
        obj.Destroy();
    }

    private void CastBuff()
    {
        if (_unit.IsDead)
        {
            return;
        }

        Creature? c = GetCreatureFromRegion(46330);
        if (c is null || c.IsDead || !c.CombatFlag.IsInCombat)
        {
            return;
        }

        Unit? target = c.Targets.Get(TargetTypes.TARGETTYPES_TARGET_ENEMY);

        if (target is null)
        {
            return;
        }

        c.Abilities.AddAbility(Kaarn.BloodPool, target, c.EffectiveLevel);
    }
}
