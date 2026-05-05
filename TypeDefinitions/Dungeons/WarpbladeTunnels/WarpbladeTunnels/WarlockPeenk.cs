namespace WorldServer.World.Scripting.Dungeons.WarpbladeTunnels;

using Common.Enums.GameData;
using Common.Positions;
using WorldServer.World.Objects;

[GeneralScript(CreatureEntry = 2001375)]
internal class WarlockPeenk : BasicCreatureScript
{
    public WarlockPeenk(Unit unit)
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

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        _stageNum = -1;

        SpawnBomb(2001381, 1597215, 212417, 8363, 3180); // Bomb

        SpawnBomb(2001381, 1598203, 211262, 8387, 2164); // Bomb

        SpawnBomb(2001381, 1598357, 211939, 8372, 3372); // Bomb

        SpawnBomb(2001381, 1598025, 211032, 8638, 3062); // Bomb

        SpawnBomb(2001381, 1597754, 211055, 8607, 2198); // Bomb

        SpawnBomb(2001381, 1597032, 212132, 8321, 3492); // Bomb

        SpawnBomb(2001381, 1597436, 211159, 8340, 2154); // Bomb

        SpawnBomb(2001381, 1596697, 211946, 8356, 2154); // Bomb

        SpawnBomb(2001381, 1596696, 211438, 8377, 2154); // Bomb

        SpawnBomb(2001381, 1597090, 211019, 8360, 2154); // Bomb

        _adds.SpawnGameObject(2000798, new Point3D(1596692, 211206, 8389), 1368); // Door

        SpawnWarpblade2Walls();

        _unit.Tasks.AddTask(TerminateSoloPlayers, 1000, 0);
    }

    public virtual Creature? SpawnBomb(uint entry, uint x, uint y, ushort z, ushort o)
    {
        return _adds.SpawnCreature(entry, new Point3D(x, y, z), o);
    }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public override void OnDie(Unit obj)
    {
        DestroyCreatureInRegion(2001381);
        DestroyGameObjectInRegion(2000798);

        AddInfluenceToAllPlayersInRegion(206, 1000);
        AddInfluenceToAllPlayersInRegion(207, 1000);

        DespawnCityDungeonWalls();

        base.OnDie(obj);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        DestroyCreatureInRegion(2001381);
        DestroyGameObjectInRegion(2000798);

        DespawnCityDungeonWalls();

        base.OnLeaveCombat(owner);
    }
}
