namespace Game.Scripts.Dungeons.Gunbad;

using Common.Enums.GameData;
using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 38234)]
internal class GarrolathThePoxbearer : BasicCreatureScript
{
    public GarrolathThePoxbearer(
        Unit unit,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository
    )
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnDie(Unit obj)
    {
        base.OnDie(obj);

        obj.Tasks.RemoveTask(SpawnNurglings);

        DestroyWall();
        SpawnGoldChest(510); // This is Gunbad loot chest

        EndPublicQuest(513);

        AddInfluenceToAllPlayersInRegion(64, 65, 800);
    }

    public void DestroyWall()
    {
        foreach (WorldObject? o in _unit.Region.Objects)
        {
            if (o is GameObject go && go.Entry == 100004)
            {
                go.Destroy();
            }
        }
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        owner.DormantInfo &= ~DormantFlags.CannotBeTargeted & ~DormantFlags.CannotBeAttacked;
        _stageNum = -1;

        owner.Tasks.AddTask(SpawnNurglings, 20 * 1000, 0);

        // prms = new List<object>() { 2000890, 863682, 855249, 26237, Obj.Heading }; // Spikestabbin'Squigs
        // c.ScdInterface.AddTask(SpawnAdds, 30 * 1000, 0, prms);
    }

    public void SpawnNurglings()
    {
        switch (Random.Shared.Next(1, 5))
        {
            case 1:
                _adds.SpawnCreature(2000890, new(863573, 855069, 26216), _unit.Heading); // Nurgling
                break;
            case 2:
                _adds.SpawnCreature(2000890, new(864337, 856140, 26128), _unit.Heading); // Nurgling
                break;
            case 3:
                _adds.SpawnCreature(2000890, new(863241, 854360, 26170), _unit.Heading); // Nurgling
                break;
            case 4:
                _adds.SpawnCreature(2000890, new(865081, 855663, 26252), _unit.Heading); // Nurgling
                break;
        }
    }

    public override void OnLeaveCombat(Unit owner)
    {
        base.OnLeaveCombat(owner);

        _unit.Tasks.RemoveTask(SpawnNurglings);
    }

    public override void OnRemoveObject(WorldObject obj)
    {
        base.OnRemoveObject(obj);

        obj.Tasks.RemoveTask(SpawnNurglings);
    }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        base.OnRemoveFromWorld(obj);

        obj.Tasks.RemoveTask(SpawnNurglings);
    }
}

[GeneralScript(CreatureEntry = 2000890)]
internal class NurglingGarrolath : BasicScript
{
    public NurglingGarrolath(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnEnterWorld(WorldObject obj)
    {
        GoToMommy(38234); // Here is mommy...
    }
}
