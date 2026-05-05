namespace Game.Scripts.Dungeons.AltdorfSewers;

using Common.Enums.GameData;
using Common.Enums.SystemData;
using Game.World.Objects;

// This assigns script AltdorfSewersWing3Boss to creature with ID 33401
[GeneralScript(CreatureEntry = 33401)]
public class AltdorfSewersWing3Boss : CreatureScript
{
    private readonly int _addsSpawnTimer = 3000; // When `The Creator` summons his adds this variable is used - after this many milliseconds adds will be spawned
    private readonly AddsTracker _adds;
    private int _stage = -1; // This is variable that controls combat Stage

    public AltdorfSewersWing3Boss(Creature creature)
        : base(creature)
    {
        _adds = new(creature) { ClearOnDeath = true };
    }

    public override void OnKill(Unit obj, Unit victim)
    {
        if (victim is Player pKilled)
        {
            obj.Say($"Hahaha {pKilled.Name} I killed you!", ChatLogFilter.MonsterSay); // Boss will say this
        }
    }

    // Words for final stage
    public void FinalWords()
    {
        _creature.Say("Noo! You should work!", ChatLogFilter.MonsterSay);
        _creature.Say("Nevermind, I will destroy you myself!", ChatLogFilter.MonsterSay);
    }

    // Possible banter here
    public void SayStuff()
    {
        _creature.Say("Noo! You should work!", ChatLogFilter.MonsterSay);
        _creature.Say("Never mind, I will destroy you myself!", ChatLogFilter.MonsterSay);
    }

    // This checks the current HP of boss
    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        if (_stage < 0 && !_creature.IsDead)
        {
            AddWall(); // First time he is damaged he spawns a wall to block exit
            _stage = 0; // Setting control value to 0
            _creature.Say("Fools! How dare you disturb my experiments!", ChatLogFilter.MonsterSay); // Banter
        }

        // At 20% HP he fails to summon anything
        if (_creature.Health.Value < _creature.Health.Total * 0.2 && _stage < 4 && !_creature.IsDead)
        {
            // c.SetImmovable(true); // Boss immovable when walking to table
            _creature.DormantInfo |= DormantFlags.CannotBeTargeted | DormantFlags.CannotBeAttacked; // Boss invulnerable when walking to table
            _creature.Say("Watch this!", ChatLogFilter.MonsterSay);

            _creature.Movement.Move(38761, 33364, 11103); // Move to some coordinates

            _creature.Tasks.AddTask(FinalWords, 5000, 1); // Banter
            _creature.Tasks.AddTask(RemoveBuffs, 5000, 1); // We are removing is immovability and invulnerability

            _stage = 4;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.4 && _stage < 3 && !_creature.IsDead)
        {
            // c.SetImmovable(true);
            _creature.DormantInfo |= DormantFlags.CannotBeTargeted | DormantFlags.CannotBeAttacked;
            _creature.Say("This isn't even my final form yet!", ChatLogFilter.MonsterSay);

            _creature.Movement.Move(38761, 33364, 11103);

            _creature.Tasks.AddTask(SpawnMaggots, _addsSpawnTimer, 1); // We are spawnning some adds
            _creature.Tasks.AddTask(RemoveBuffs, 5000, 1);

            _stage = 3;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.6 && _stage < 2 && !_creature.IsDead)
        {
            // c.SetImmovable(true);
            _creature.DormantInfo |= DormantFlags.CannotBeTargeted | DormantFlags.CannotBeAttacked;
            _creature.Say("Tremble at my illogical glory!", ChatLogFilter.MonsterSay);

            _creature.Movement.Move(38761, 33364, 11103);

            _creature.Tasks.AddTask(SpawnSpiders, _addsSpawnTimer, 1);
            _creature.Tasks.AddTask(RemoveBuffs, 5000, 1);

            _stage = 2;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.8 && _stage < 1 && !_creature.IsDead)
        {
            // c.SetImmovable(true);
            _creature.DormantInfo |= DormantFlags.CannotBeTargeted | DormantFlags.CannotBeAttacked;
            _creature.Say("You are just Nurgling bait!", ChatLogFilter.MonsterSay);

            _creature.Movement.Move(38761, 33364, 11103);

            _creature.Tasks.AddTask(SpawnNurglings, _addsSpawnTimer, 1);
            _creature.Tasks.AddTask(RemoveBuffs, 5000, 1);

            _stage = 1;
        }
    }

    // Removal of immovability and invulnerability
    public void RemoveBuffs()
    {
        _creature.DormantInfo &= ~DormantFlags.CannotBeTargeted & ~DormantFlags.CannotBeAttacked;
    }

    // Make RoR Great Again - adding wall
    public void AddWall()
    {
        _adds.SpawnGameObject(2000441, new(137348, 524446, 11128), 2008);
    }

    public void SpawnNurglings() // Spawning nurgling adds
    {
        _adds.SpawnCreaturesAroundPos(1002073, new(137065, 524884, 11103), 180, 6);
    }

    public void SpawnSpiders()
    {
        _adds.SpawnCreaturesAroundPos(1002072, new(137065, 524884, 11103), 180, 6);
    }

    public void SpawnMaggots()
    {
        _adds.SpawnCreaturesAroundPos(1002072, new(1002074, 524884, 11103), 180, 6);
    }
}
