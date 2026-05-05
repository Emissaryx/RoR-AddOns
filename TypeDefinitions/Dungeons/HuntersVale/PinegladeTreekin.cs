namespace Game.Scripts.Dungeons.HuntersVale;

using Common.Enums.GameData;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 97457)]
internal class PinegladeTreekin : CreatureScript
{
    public PinegladeTreekin(Creature creature)
        : base(creature) { }

    private bool _triggered;

    public override void OnObjectLoad(WorldObject obj)
    {
        _creature.DormantInfo |= DormantFlags.CannotBeTargeted | DormantFlags.CannotBeAttacked;

        // Event to check players
        obj.Tasks.AddTask(CheckPlayers, 5000, 0);
    }

    private void CheckPlayers()
    {
        if (_triggered)
        {
            return;
        }

        if (_creature.IsDead)
        {
            return;
        }

        foreach (Player p in _creature.PlayersInRange)
        {
            if (!p.IsDead && p.Abilities.HasBuffById(23576))
            {
                _triggered = true;
                _creature.DormantInfo &= ~DormantFlags.CannotBeTargeted & ~DormantFlags.CannotBeAttacked;
                _creature.AiInterface.ProcessCombatStart(p);
                break;
            }
        }
    }

    public override void OnDie(Unit obj)
    {
        foreach (Player p in _creature.PlayersInRange)
        {
            p.Abilities.EndTargetAbilities(23576);
        }
    }
}

[GeneralScript(ScriptName = "HuntersValeAnimal")]
internal class HuntersValeAnimal : CreatureScript
{
    public HuntersValeAnimal(Creature creature)
        : base(creature) { }

    public override void OnDie(Unit obj)
    {
        obj.PlaySound(1469); // "A Curse on you, defiler!"
        foreach (Player p in obj.PlayersInRange)
        {
            p.Abilities.AddAbility(23576, p);
        }
    }
}
