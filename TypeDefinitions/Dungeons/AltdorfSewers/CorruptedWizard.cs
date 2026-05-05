namespace Game.Scripts.Dungeons.AltdorfSewers;

using Game.World.Objects;

[GeneralScript(CreatureEntry = 33395)]
internal class CorruptedWizard : CreatureScript
{
    private const uint TwistedSpectre = 2000853;
    private readonly AddsTracker _adds;

    public CorruptedWizard(Creature creature)
        : base(creature)
    {
        creature.NpcAllowedToResetAggro = false;
        creature.RespectLoS = false;
        _adds = new(creature);
    }

    public override void OnEnterCombat(Unit obj, Unit? attacker)
    {
        SpawnAdds();
        _unit.Tasks.AddTask(SpawnAdds, TimeSpan.FromSeconds(15), 0);
    }

    private void SpawnAdds()
    {
        _adds.SpawnCreaturesAroundPos(TwistedSpectre, _unit.WorldPosition, 300);
    }

    public override void OnDie(Unit obj)
    {
        _unit.Tasks.RemoveTask(SpawnAdds);
    }

    public override void OnLeaveCombat(Unit obj)
    {
        _unit.Tasks.RemoveTask(SpawnAdds);
    }
}
