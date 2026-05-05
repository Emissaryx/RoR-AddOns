namespace WorldServer.World.Scripting.Dungeons.LostVale;

using Common.Enums.GameData;
using WorldServer.World.Objects;

[GeneralScript(CreatureEntry = 6841)]
internal class Horgulul : BasicCreatureScript
{
    public Horgulul(Unit unit)
        : base(unit)
    {
        _creature.Enrage.EnableRangeUnits = 1620;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(ClearImmunities, 900, 0);

        _unit.AddCrowdControlImmunity(CrowdControlTypes.All);
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc((int)GetTerrorCreature());
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        if (_stageNum < 0 && !_unit.IsDead)
        {
            _stageNum = 0; // Setting control value to 0
        }

        if (_unit.Health.Value < _unit.Health.Total * 0.25 && _stageNum < 4 && !_unit.IsDead)
        {
            DoStuff();

            _stageNum = 4;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.5 && _stageNum < 3 && !_unit.IsDead)
        {
            DoStuff();

            _stageNum = 3;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.75 && _stageNum < 2 && !_unit.IsDead)
        {
            DoStuff();

            _stageNum = 2;
        }
        else if (_unit.Health.Value < _unit.Health.Total && _stageNum < 1 && !_unit.IsDead)
        {
            _stageNum = 1;
        }
    }

    public void DoStuff()
    {
        _unit.Abilities.AddAbility(4386, _unit, _unit.EffectiveLevel);

        _unit.Abilities.EndTargetAbilities((ushort)4400);

        _adds.SpawnCreaturesAroundPos(6831, _unit.WorldPosition, 300, 6);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        ClearStuff();

        base.OnLeaveCombat(owner);
    }

    public override void OnDie(Unit obj)
    {
        ClearStuff();

        base.OnDie(obj);
    }

    public void ClearStuff()
    {
        _unit.Tasks.RemoveTask(DoStuff);

        _unit.Abilities.EndTargetAbilities((ushort)4386);

        foreach (WorldObject? o in _unit.Region.Objects)
        {
            if (o is Creature crea && crea.Entry == 6831)
            {
                crea.Destroy();
            }
        }
    }
}
