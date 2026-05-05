namespace WorldServer.World.Scripting.Dungeons.WarpbladeTunnels;

using Common.Enums.GameData;
using Common.Enums.SystemData;
using WorldServer.World.Objects;

[GeneralScript(CreatureEntry = 1000269)]
internal class Skiv : BasicCreatureScript
{
    public Skiv(Unit unit)
        : base(unit)
    {
        _creature.Enrage.EnableRangeUnits = 1620;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(ClearImmunities, 100, 0);

        _unit.AddCrowdControlImmunity(CrowdControlTypes.All);
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc((int)GetTerrorCreature());
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        if (Random.Shared.Next(0, 100) < 10)
        {
            switch (Random.Shared.Next(0, 5))
            {
                case 0:
                    _unit.Say("Smash-smash!", ChatLogFilter.MonsterSay);
                    ApplyBuffToRandomPlayer(13939);
                    break;
                case 1:
                    _unit.Say("Kill-kill!", ChatLogFilter.MonsterSay);
                    ApplyBuffToRandomPlayer(13940);
                    break;
                case 2:
                    _unit.Say("Die-die!", ChatLogFilter.MonsterSay);
                    ApplyBuffToRandomPlayer(13941);
                    break;
                case 3:
                    _unit.Say("Da clan, da clan!", ChatLogFilter.MonsterSay);
                    ApplyBuffToRandomPlayer(13942);
                    break;
                case 4:
                    _unit.Say("Eat-eat!", ChatLogFilter.MonsterSay);
                    ApplyBuffToRandomPlayer(13943);
                    break;
            }
        }
    }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public override void OnDie(Unit obj)
    {
        DestroyGameObjectInRegion(2000788);

        DespawnCityDungeonWalls();

        base.OnDie(obj);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        DespawnCityDungeonWalls();

        base.OnLeaveCombat(owner);
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        base.OnEnterCombat(owner, attacker);

        SpawnWarpblade2Walls();
    }
}
