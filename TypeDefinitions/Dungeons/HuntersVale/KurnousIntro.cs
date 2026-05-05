namespace Game.Scripts.Dungeons.HuntersVale;

using Game.World.Objects;

/*
 * Kurnous Intro Script
 *
 * When you go near the great stag he transforms into kuronos
 * says something and plays the audio, then transforms back
 * into a stag, runs off and disappears.
 */

[GeneralScript(CreatureSpawn = "96eb2112-a0bd-44a4-98db-707852af5e45")]
internal class KurnousIntro : CreatureScript
{
    public KurnousIntro(Creature creature)
        : base(creature)
    {
        _creature.Tasks.AddTask(CheckActivationRange, 5000, 0);
    }

    private void CheckActivationRange()
    {
        foreach (Player plr in _creature.PlayersInRange)
        {
            if (plr.IsDead || plr.Stealth.IsInGameMasterStealth || !_creature.IsWithin3DRadiusUnits(plr, 1200))
            {
                continue;
            }

            _creature.Tasks.RemoveTask(CheckActivationRange);
            Start();
            break;
        }
    }

    private void Start()
    {
        _creature.PlayEffect(3085); // BOSS_WHUNT_Transform
        _creature.Tasks.AddTask(Speech, 1000, 1);
    }

    private void Speech()
    {
        _creature.Name = "Spirit of Kurnous";
        _creature.Model = 1783;
        _creature.Say("Welcome, mortals, to the Hunter's Vale. Here, I reign supreme ... and you die in droves.");
        _creature.PlaySound(1451); // s_Kurnous_VO_PQ_07
        _creature.Tasks.AddTask(
            () =>
            {
                _creature.SendAnimation2(172);
            },
            2000,
            1
        );

        _creature.Tasks.AddTask(
            () =>
            {
                _creature.SendAnimation2(125);
            },
            4000,
            1
        );

        _creature.Tasks.AddTask(Transform1, 8000, 1);
    }

    private void Transform1()
    {
        _creature.PlayEffect(3085); // BOSS_WHUNT_Transform
        _creature.Tasks.AddTask(Transform2, 1000, 1);
    }

    private void Transform2()
    {
        _creature.Name = "Great Stag";
        _creature.Model = 1777;
        _creature.Tasks.AddTask(Move, 3000, 1);
    }

    private void Move()
    {
        _creature.Movement.Move(318748, 527045, 4395);
        _creature.Tasks.AddTask(_creature.Destroy, 5000, 1);
    }
}

[GeneralScript(CreatureSpawn = "a579b2fd-59e4-11eb-83d8-000c29d63948")]
internal class KurnousIntro2 : CreatureScript
{
    public KurnousIntro2(Creature creature)
        : base(creature)
    {
        _creature.Tasks.AddTask(CheckActivationRange, 5000, 0);
    }

    private void CheckActivationRange()
    {
        foreach (Player plr in _creature.PlayersInRange)
        {
            if (plr.IsDead || plr.Stealth.IsInGameMasterStealth || !_creature.IsWithin3DRadiusUnits(plr, 1200))
            {
                continue;
            }

            _creature.Tasks.RemoveTask(CheckActivationRange);
            Start();
            break;
        }
    }

    private void Start()
    {
        _creature.AiInterface.AddWaypoint(
            new()
            {
                X = 328374,
                Y = 526482,
                Z = 3634,
                Speed = 200,
            }
        );
        _creature.AiInterface.AddWaypoint(
            new()
            {
                X = 327757,
                Y = 526627,
                Z = 3686,
                Speed = 200,
            }
        );
    }

    public override void OnFinishedWaypoints()
    {
        _creature.Destroy();
    }
}

[GeneralScript(CreatureSpawn = "a579723f-59e4-11eb-83d8-000c29d63948")]
internal class KurnousIntro3 : CreatureScript
{
    public KurnousIntro3(Creature creature)
        : base(creature)
    {
        _creature.Tasks.AddTask(CheckActivationRange, 5000, 0);
    }

    private void CheckActivationRange()
    {
        foreach (Player plr in _creature.PlayersInRange)
        {
            if (plr.IsDead || plr.Stealth.IsInGameMasterStealth || !_creature.IsWithin3DRadiusUnits(plr, 1200))
            {
                continue;
            }

            _creature.Tasks.RemoveTask(CheckActivationRange);
            Start();
            break;
        }
    }

    private void Start()
    {
        _creature.AiInterface.AddWaypoint(
            new()
            {
                X = 322283,
                Y = 519807,
                Z = 5000,
                Speed = 200,
            }
        );
    }

    public override void OnFinishedWaypoints()
    {
        _creature.Destroy();
    }
}
