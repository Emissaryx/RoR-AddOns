namespace Game.Scripts.Dungeons.Gunbad;

using Common.Enums.GameData;
using Common.Enums.SystemData;
using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 42207)]
internal class WightLordSolithex : BasicScript
{
    public WightLordSolithex(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        _unit.Say("Come, mortals, and bathe in my Power!", ChatLogFilter.MonsterSay);

        _unit.Abilities.EndTargetAbilities(14891); // Removing Iron Body

        _unit.Abilities.EndTargetAbilities(5430); // Removing Rage

        _unit.SetDormantFlag(DormantFlags.CannotBeTargeted | DormantFlags.CannotBeAttacked, false);

        _stageNum = -1;

        _adds.SpawnGameObject(100523, new(1110218, 1118213, 19460), _unit.Heading); // Solithex Soulstone

        _adds.SpawnGameObject(100524, new(1110226, 1118211, 19459), _unit.Heading); // Solithex Barrier

        _unit.Tasks.AddTask(TerminateSoloPlayers, 1000, 0);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        base.OnLeaveCombat(owner);

        _unit.Abilities.EndTargetAbilities(14891); // Removing Iron Body

        _unit.Abilities.EndTargetAbilities(5430); // Removing Rage

        _unit.ObjectState.RemoveEffect(ObjectEffectState.OBJECTEFFECTSTATE_BERSERK); // State 1 Champ, State 7 Super Champ
        _unit.ObjectState.RemoveEffect(ObjectEffectState.OBJECTEFFECTSTATE_SCALE_UP); // State 1 Champ, State 7 Super Champ
    }

    public override void OnDie(Unit obj)
    {
        base.OnDie(obj);

        /*foreach (Object obj in Obj.ObjectsInRange.ToList())
        {
            GameObject go = obj as GameObject;
            if (go is not null && go.Entry == 100523)
            {
                go.Health = 0;

                go.States.Add(3); // Death State

                Packet Out = GameClient.PrepareOutMythicWorldTCP((byte)Opcodes.F_OBJECT_DEATH);
                Out.WriteUInt16(go.Oid);
                Out.WriteByte(1);
                Out.WriteByte(0);
                Out.WriteUInt16(0);
                Out.Fill(0, 6);
                go.DispatchPacket(Out, true);
                break;
            }
        }*/

        _unit.ObjectState.RemoveEffect(ObjectEffectState.OBJECTEFFECTSTATE_BERSERK); // State 1 Champ, State 7 Super Champ
        _unit.ObjectState.RemoveEffect(ObjectEffectState.OBJECTEFFECTSTATE_SCALE_UP); // State 1 Champ, State 7 Super Champ

        obj.Tasks.AddTask(DelayCreateExitPortal, 1000, 1);

        SpawnGoldChest(2003);
        EndPublicQuest(2003);

        AddInfluenceToAllPlayersInRegion(64, 65, 800);
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        if (_stageNum < 0 && !_unit.IsDead)
        {
            _stageNum = 0; // Setting control value to 0
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.2 && _stageNum < 4 && !_unit.IsDead)
        {
            DelayedBuff(
                _unit,
                14891,
                "This battle may be yours but my will persists. If we meet again, it is you that will return to the soil and eternally serve the Mourkain!"
            ); // Iron Body
            DelayedBuff(_unit, 5430); // Rage

            _unit.Speed.SetBaseSpeed(110);

            foreach (WorldObject o in _unit.ObjectsInRange)
            {
                if (o is not GameObject go)
                {
                    continue;
                }

                if (go.Entry == 100524)
                {
                    go.Say(
                        "*** Magical barrier collaps and the gem is in your reach... ***",
                        ChatLogFilter.MonsterEmote
                    );
                    go.Destroy();
                }

                if (go.Entry == 100523)
                {
                    _unit.SetDormantFlag(DormantFlags.CannotBeTargeted | DormantFlags.CannotBeAttacked, false);
                    go.Health.Value = go.Health.Total;

                    // go.Say("*** Cracks start to show upon surface of the gem... ***", ChatLogFilters.CHATLOGFILTERS_MONSTER_EMOTE);
                    foreach (Player plr in go.PlayersInRange)
                    {
                        _unit.Abilities.AddAbility(13058, plr, _unit.EffectiveLevel); // Killer dot

                        go.SendMeTo(plr);
                    }
                }
            }

            _stageNum = 4;

            _unit.ObjectState.AddEffect(ObjectEffectState.OBJECTEFFECTSTATE_SCALE_UP); // State 1 Champ, State 7 Super Champ
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.4 && _stageNum < 3 && !_unit.IsDead)
        {
            _adds.SpawnGameObject(2000561, new(1109983, 1119476, 19138), _unit.Heading); // Deathshadow Drudge

            _adds.SpawnGameObject(2000561, new(1110752, 1119141, 19134), _unit.Heading); // Deathshadow Drudge

            _adds.SpawnGameObject(2000561, new(1111016, 1119874, 19145), _unit.Heading); // Deathshadow Drudge

            _adds.SpawnGameObject(2000561, new(1110467, 1120222, 19146), _unit.Heading); // Deathshadow Drudge

            _unit.Say("Arise, my servants, for it is time the Mourkain retake this world!", ChatLogFilter.MonsterSay);

            // c.DormantInfo |= DoromantFlags.Untargetable;

            // c.ScdInterface.AddTask(RemoveBuffs, 30000, 1);
            _stageNum = 3;

            // c.Say("Stage 2");
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.7 && _stageNum < 2 && !_unit.IsDead)
        {
            _adds.SpawnCreature(2000876, new(1109983, 1119476, 19138), _unit.Heading); // Deathshadow Construct

            _adds.SpawnCreature(2000876, new(1110752, 1119141, 19134), _unit.Heading); // Deathshadow Construct

            _adds.SpawnCreature(2000876, new(1111016, 1119874, 19145), _unit.Heading); // Deathshadow Construct

            _adds.SpawnCreature(2000876, new(1110467, 1120222, 19146), _unit.Heading); // Deathshadow Construct

            _unit.Say("Arise, my servants, for it is time the Mourkain retake this world!", ChatLogFilter.MonsterSay);

            // c.DormantInfo |= DoromantFlags.Untargetable;

            // c.ScdInterface.AddTask(RemoveBuffs, 30000, 1);
            _stageNum = 2;

            _unit.ObjectState.AddEffect(ObjectEffectState.OBJECTEFFECTSTATE_BERSERK); // State 1 Champ, State 7 Super Champ

            // c.Say("Stage 1");
        }
        else if (_unit.Health.Value < _unit.Health.Total && _stageNum < 1 && !_unit.IsDead)
        {
            _stageNum = 1;
        }
    }

    public void RemoveBuffs()
    {
        _unit.Say("Feel my wrath!", ChatLogFilter.MonsterSay);
        _unit.DormantInfo &= ~DormantFlags.CannotBeTargeted & ~DormantFlags.CannotBeAttacked;
        _unit.SendMeTo();
    }
}

[GeneralScript(GameObjectEntry = 100523)]
internal class SolithexArtifact : BasicGameObjectScript
{
    public SolithexArtifact(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        _stageNum = -1;

        _go.NoRespawn = true;
        _go.DormantInfo |= DormantFlags.CannotBeTargeted | DormantFlags.CannotBeAttacked;

        /*foreach (Player plr in go.PlayersInRange)
        {
            go.SendMeTo(plr);
        }*/
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        if (_stageNum < 0 && !_go.IsDead)
        {
            _stageNum = 0; // Setting control value to 0
        }

        if (_go.Health.Value < _go.Health.Total * 0.1)
        {
            _go.PlayEffect(2185);

            _go.Say("*** The cursed gem breaks into milion pieces! ***", ChatLogFilter.MonsterEmote);

            foreach (WorldObject o in _go.ObjectsInRange)
            {
                if (o is Player plr)
                {
                    plr.Abilities.EndTargetAbilities(13058); // Removing killer dot

                    plr.SendClientMessage(
                        "The sinister force that consumed your soul is lifted from you!",
                        ChatLogFilter.MonsterEmote
                    );
                }

                if (o is Creature c && c.Entry == 42207)
                {
                    c.Abilities.EndTargetAbilities(14891); // Removing Iron Body

                    c.Abilities.EndTargetAbilities(5430); // Removing Rage

                    c.ObjectState.RemoveEffect(ObjectEffectState.OBJECTEFFECTSTATE_SCALE_UP); // State 1 Champ, State 7 Super Champ
                    c.Speed.SetBaseSpeed(235);
                }

                _go.Destroy();
            }

            _stageNum = 1;
        }
    }

    public override void OnDie(Unit obj)
    {
        _stageNum = -1;
    }
}

[GeneralScript(GameObjectEntry = 100524)]
internal class SolithexBarrier : BasicGameObjectScript
{
    public SolithexBarrier(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        _go.NoRespawn = true;
        _go.SetDormantFlag(DormantFlags.CannotBeTargeted | DormantFlags.CannotBeAttacked, true);
        _go.SendMeTo();
    }
}

[GeneralScript(GameObjectEntry = 2000561)]
internal class SolithexMourkainPillar : BasicGameObjectScript
{
    public SolithexMourkainPillar(
        Unit unit,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository
    )
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        _go.NoRespawn = true;

        obj.Tasks.AddTask(SpawnDeathshadowDrudge, 5000, 0);
    }

    private void SpawnDeathshadowDrudge()
    {
        if (_go.Zone is null)
        {
            return;
        }

        _adds.SpawnCreaturesAroundPos(42211, _unit.WorldPosition, 180);
    }

    public override void OnDie(Unit obj)
    {
        base.OnDie(obj);

        obj.Tasks.RemoveTask(SpawnDeathshadowDrudge);
    }
}
