namespace WorldServer.World.Scripting.Dungeons.WarpbladeTunnels;

using Common.Enums.GameData;
using WorldServer.World.Objects;

[GeneralScript(CreatureEntry = 2001369)]
internal class MasterMoulderSkrot : BasicCreatureScript
{
    public MasterMoulderSkrot(Unit unit)
        : base(unit)
    {
        _adds.ClearOnDeath = false;
        _creature.Enrage.EnableRangeUnits = 1620;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(ClearImmunities, 900, 0);

        _unit.AddCrowdControlImmunity(CrowdControlTypes.All);
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        _stageNum = -1;

        _adds.SpawnCreature(2001370, _unit.WorldSpawnPoint, _unit.Heading); // Rat Ogre

        SpawnWarpblade1Walls();
    }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public override void OnDie(Unit obj)
    {
        DestroyGameObjectInRegion(2000789);

        DespawnCityDungeonWalls();

        base.OnDie(obj);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        DespawnCityDungeonWalls();

        base.OnLeaveCombat(owner);
    }
}
