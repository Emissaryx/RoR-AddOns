namespace Game.Scripts.Dungeons.Gunbad;

using Common.Enums.GameData;
using Common.Enums.SystemData;
using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 37967)]
internal class MastaMixa : BasicCreatureScript
{
    public MastaMixa(Creature crea, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(crea, pQuestRepository, gameObjectRepository) { }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        _creature.DormantInfo &= ~DormantFlags.CannotBeTargeted & ~DormantFlags.CannotBeAttacked;
        _stageNum = -1;

        SpawnDaStaff();

        _creature.Tasks.AddTask(SpawnDaStaff, (60 + Random.Shared.Next(1, 31)) * 1000, 0); // Spawns staff

        // Masta Mixa Fanatic
        _creature.Tasks.AddTask(
            () => _adds.SpawnCreature(2000899, new(977879, 994054, 26299), _creature.Heading),
            "SpawnAdd",
            30 * 1000,
            0
        );
        _creature.Tasks.AddTask(
            () => _adds.SpawnCreature(2000899, new(977127, 995380, 26307), _creature.Heading),
            "SpawnAdd",
            30 * 1000,
            0
        );

        _creature.Tasks.AddTask(CastFistOfGork, 30 * 1000, 0);

        _creature.Tasks.AddTask(TerminateSoloPlayers, 1000, 0);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        base.OnLeaveCombat(owner);

        foreach (WorldObject obj in _creature.ObjectsInRange)
        {
            if (obj is Creature creature && creature.Entry == 2000851)
            {
                creature.Destroy();
            }
        }

        _creature.Tasks.RemoveTask(SpawnDaStaff);

        _creature.Tasks.RemoveTask(CastFistOfGork);

        // for (int i = 0; i < 20; i++)
        // Obj.ScdInterface.RemoveTask(CheckPositionAndMove);
    }

    public override void OnDie(Unit obj)
    {
        base.OnDie(obj);

        obj.Tasks.RemoveTask(SpawnDaStaff);

        obj.Tasks.RemoveTask(CastFistOfGork);

        obj.Tasks.AddTask(DelayCreateExitPortal, 1000, 1);

        SpawnGoldChest(2002);
        EndPublicQuest(2002);

        AddInfluenceToAllPlayersInRegion(64, 65, 800);

        // for (int i = 0; i < 20; i++)
        // Obj.ScdInterface.RemoveTask(CheckPositionAndMove);
    }

    private void SpawnDaStaff()
    {
        if (!_creature.IsDead)
        {
            bool staffActive = false;

            foreach (WorldObject obj in _creature.ObjectsInRange)
            {
                if (obj is Creature creature && creature.Entry == 2000851 && !creature.IsDead)
                {
                    staffActive = true;
                    break;
                }
            }

            if (!staffActive)
            {
                _creature.Say("Where 'z my stick?!", ChatLogFilter.MonsterSay);

                // Gitzappa da Stick
                _adds.SpawnCreature(2000851, _creature.WorldPosition, _creature.Heading);
            }
        }
    }

    private void CastFistOfGork()
    {
        if (_creature.PlayersInRange.Count > 0)
        {
            bool haveTarget = false;
            int playersInRange = _creature.PlayersInRange.Count;
            byte i = 0;
            while (!haveTarget && i < 15)
            {
                int rndmPlr = Random.Shared.Next(1, playersInRange + 1);
                Player player = _creature.PlayersInRange.ElementAt(rndmPlr - 1);

                if (
                    !player.IsDead
                    && !player.DormantInfo.HasFlag(DormantFlags.CannotBeTargeted)
                    && !player.DormantInfo.HasFlag(DormantFlags.CannotBeAttacked)
                )
                {
                    if (!player.Abilities.HasBuffById(5239))
                    {
                        haveTarget = true;

                        _creature.Say("Gork will smash' ya! Or Mork?!", ChatLogFilter.MonsterSay);

                        // Fist of Gork
                        _adds.SpawnCreature(2000902, player.WorldPosition, _creature.Heading);

                        break;
                    }
                }

                i++;
            }
        }
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        if (_stageNum < 0 && !_creature.IsDead)
        {
            _stageNum = 0; // Setting control value to 0
        }
        else if (_creature.Health.Value < _creature.Health.Total && _stageNum < 1 && !_creature.IsDead)
        {
            _stageNum = 1;
        }
    }
}

[GeneralScript(CreatureEntry = 2000851)]
internal class DaStaffMastaMixa : BasicCreatureScript
{
    public DaStaffMastaMixa(Creature crea, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(crea, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);
        _creature.Aggro.SendAggroUpdate = false;

        obj.Tasks.AddTask(TerminateCurrentTarget, 59700, 1);
        obj.Tasks.AddTask(SayStuff, 59990, 1);
        obj.Tasks.AddTask(_creature.Destroy, 59999, 1);
    }

    public override void OnEnterWorld(WorldObject obj)
    {
        SetRandomTarget();
    }

    public override void SayStuff()
    {
        if (!_creature.IsDead)
        {
            _creature.Say("Masta Mixa summoned back his staff!", ChatLogFilter.MonsterEmote);
        }
    }

    private void TerminateCurrentTarget()
    {
        if (
            !_creature.IsDead
            && _creature.Targets.Get(TargetTypes.TARGETTYPES_TARGET_ENEMY) is Player plr
            && !plr.IsDead
        )
        {
            SendOnscreenMessageToAllPlayers($"Power of Waaagh overwhelmed {plr.Name}!");

            plr.SendClientMessage("Power of Waaagh overwhelmed you!", ChatLogFilter.CSRTellReceive);
            plr.Terminate();
        }
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        _stageNum = -1;
    }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public override void OnDie(Unit obj)
    {
        base.OnDie(obj);

        // Obj.ScdInterface.RemoveTask(DisablePlayer);
        if (obj.Region is not null)
        {
            foreach (Player player in obj.Region.Players)
            {
                player.Abilities.EndTargetAbilities(5240); // Removing Disable

                // NewBuff newBuff = player.BuffInterface.GetBuff(5240, null);
                // if (newBuff is not null)
                // newBuff.RemoveBuff();
                player.Abilities.EndTargetAbilities(5239); // Removing Disable

                // newBuff = player.BuffInterface.GetBuff(5239, null);
                // if (newBuff is not null)
                // newBuff.RemoveBuff();
            }
        }

        obj.Tasks.RemoveTask(TerminateCurrentTarget);
        obj.Tasks.RemoveTask(SayStuff);
        obj.Tasks.RemoveTask(_creature.Destroy);

        obj.Tasks.AddTask(obj.Destroy, 100, 1);
    }

    public override void SetRandomTarget()
    {
        Creature? fist = GetCreatureFromRegion(2000902);
        Unit? fistCurrentTarget = null;
        if (fist is not null)
        {
            fistCurrentTarget = fist.Targets.Get(TargetTypes.TARGETTYPES_TARGET_ENEMY);
        }

        if (_creature.PlayersInRange.Count > 0)
        {
            bool haveTarget = false;
            int playersInRange = _creature.PlayersInRange.Count;
            byte i = 0;
            while (!haveTarget && i < 15)
            {
                int rndmPlr = Random.Shared.Next(1, playersInRange + 1);
                Player player = _creature.PlayersInRange.ElementAt(rndmPlr - 1);
                if (
                    !player.IsDead
                    && !player.DormantInfo.HasFlag(DormantFlags.CannotBeTargeted)
                    && !player.DormantInfo.HasFlag(DormantFlags.CannotBeAttacked)
                    && !player.Stealth.IsInGameMasterStealth
                    && (fist is null || (fist is not null && fistCurrentTarget != player))
                )
                {
                    haveTarget = true;
                    _creature.Movement.TurnTo(player);
                    _creature.Speed.SetBaseSpeed(110);
                    _creature.Movement.Follow(player, 60, 120);
                    _creature.Aggro.AddHatred(player, 500000);
                    break;
                }

                i++;
            }
        }
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        if (_stageNum < 0 && !_unit.IsDead)
        {
            _stageNum = 0; // Setting control value to 0
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.05 && _stageNum < 1 && !_unit.IsDead)
        {
            foreach (Player player in _unit.PlayersInRange)
            {
                if (player is not null)
                {
                    player.Abilities.EndTargetAbilities(5240); // Removing Disable

                    // NewBuff newBuff = player.BuffInterface.GetBuff(5240, null);
                    // if (newBuff is not null)
                    // newBuff.RemoveBuff();
                    player.Abilities.EndTargetAbilities(5239); // Removing Disable

                    // newBuff = player.BuffInterface.GetBuff(5239, null);
                    // if (newBuff is not null)
                    // newBuff.RemoveBuff();
                }
            }

            _stageNum = 1;
        }
    }
}

[GeneralScript(CreatureEntry = 2000899)]
internal class MixaFanatics : BasicScript
{
    public MixaFanatics(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(SetRandomTarget, 200, 1);
    }
}

[GeneralScript(CreatureEntry = 2000902)]
internal class MixaFistOfGork : BasicCreatureScript
{
    public MixaFistOfGork(Creature crea, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(crea, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(DispellFistOfGork, 30 * 1000, 1);

        _creature.Aggro.SendAggroUpdate = false;
    }

    public override void OnEnterWorld(WorldObject obj)
    {
        PlayVfx();
        obj.Tasks.AddTask(PlayVfx, 1500, 0);

        SetRandomTarget();

        DelayedBuff(_creature, 4388); // Taunt Immunity
    }

    private void PlayVfx()
    {
        // Fist of Gork
        _unit.PlayEffect(239);
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker) { }

    public override void OnDie(Unit obj)
    {
        base.OnDie(obj);
        obj.Tasks.RemoveTask(PlayVfx);
    }

    public override void SetRandomTarget()
    {
        Creature? staff = GetCreatureFromRegion(2000851);
        Unit? staffCurrentTarget = null;
        if (staff is not null)
        {
            staffCurrentTarget = staff.Targets.Get(TargetTypes.TARGETTYPES_TARGET_ENEMY);
        }

        if (_creature.PlayersInRange.Count > 0)
        {
            bool haveTarget = false;
            int playersInRange = _creature.PlayersInRange.Count;
            byte i = 0;
            while (!haveTarget && i < 15)
            {
                int rndmPlr = Random.Shared.Next(1, playersInRange + 1);
                Player player = _creature.PlayersInRange.ElementAt(rndmPlr - 1);
                if (
                    !player.IsDead
                    && !player.DormantInfo.HasFlag(DormantFlags.CannotBeTargeted)
                    && !player.DormantInfo.HasFlag(DormantFlags.CannotBeAttacked)
                    && !player.Stealth.IsInGameMasterStealth
                    && (staff is null || (staff is not null && staffCurrentTarget != player))
                )
                {
                    haveTarget = true;
                    _creature.Movement.TurnTo(player);
                    _creature.Speed.SetBaseSpeed(110);
                    _creature.Movement.Follow(player, 60, 120);
                    _creature.Aggro.AddHatred(player, 500000);
                    break;
                }

                i++;
            }
        }
    }

    private void DispellFistOfGork()
    {
        _creature.Tasks.RemoveTask(PlayVfx);
        _creature.Destroy();
    }
}
