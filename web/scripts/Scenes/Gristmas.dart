import "dart:html";
import "../SBURBSim.dart";


class Gristmas extends Scene {
    int expectedInitialAverageAlchemyValue = 6;
    int expectedMiddleAverageAlchemyValue = 10;
    int expectedEndAverageAlchemyValue = 30;
    Player player;
    int playerSkill;
  Gristmas(Session session) : super(session);

  String gristmasContent() {
      playerSkill = getAlchemySkillNormalized(player);
      String ret = "<br><br>GRISTMAS: ";
      List<AlchemyResult> possibilities = doAlchemy();
      if(!possibilities.isEmpty) {
          // maybe only sort if you are good enough at alchemy???
          possibilities.sort(); //do most promising alchemy first so that you don't use up the items needed for it
          for (AlchemyResult result in possibilities) {
              String tmp = result.apply(player);
              if (tmp != null) ret += "$tmp";
          }
          ret += "<br><br>After all that ridiculousness, they ALSO manage to upgrade their specibus.";
      }else {
          ret += "<br><br>They upgrade their specibus.";
      }

      possibilities = upgradeSpecibus();
      if(possibilities.isEmpty)  return "$ret Wait. The ${player.htmlTitleBasic()} WANTS to do upgrade their specibus, but it's full. Guess they shouldn't have filled it full of junk in the early game. Stupid rules. Stupid limits. This isn't even CANON. ";

      if(!player.specibus.canUpgrade(playerSkill == 3)) ret += "Take that JR, your alchemy limits were arbitrary and non canon so we are just gonna fucking ignore them. After all. What could go wrong?<span class = 'void'>JR: Well for one, you could end up in a never ending spiral of alchemy. Have fun failing to actually beat the game, asshole.</span>";
      //not a for loop, just do once.
      String tmp = possibilities.first.apply(player,true);
      if(tmp != null) {
          ret += "$tmp";
      }else {
          throw "No. How the fuck did this happen. Sylladex has ${player.sylladex.length} things in it, so how did I fail to upgrade my specibus?";
      }
      ret += " It is at rank ${(100*player.specibus.rank).round()/100}.";

    return ret;

  }

  @override
  void renderContent(Element div) {

      String ret = gristmasContent();
      //okay alchemy is a free action otherwise the space players never fucking do anything.
      //session.removeAvailablePlayer(player);
      CanvasElement canvas = new CanvasElement(width: 400, height: 400);
      CanvasElement canvas2 = new CanvasElement(width: 400, height: 300);
      Drawing.drawWhatever(canvas, "Rewards/holyAlchemy.png");
      Drawing.drawSinglePlayer(canvas2, player);
      canvas.context2D.drawImage(canvas2,0,0);
      div.append(canvas);
      appendHtml(div, ret);
  }

  //takes all items in inventory and rubs them on each other.
  List<AlchemyResult> doAlchemy() {
      List<AlchemyResult> ret = new List<AlchemyResult>();
      //REMEMBER: item1 OR item2 is a DIFFERENT THING than the reverse. so you aren't wasting time by doing each item pair twice.
      for(Item item1 in player.sylladex) {
        for(Item item2 in player.sylladex) {
            if(item1 != item2){
                //print("checking ${item1.fullName} for do alchemy");
                if ((item1.canUpgrade(playerSkill == 3) || session.mutator.dreamField)){
                    //print("Okay. No can I REALLY upgrade item1? ${item1.canUpgrade()}");

                    ret.addAll(AlchemyResult.planAlchemy(<Item>[item1, item2],session,playerSkill));
                }
            }else {
                //print("for alchemy ${item1} is ${item2}");
            }
        }
      }
      //WHY the fuck is this sometimes returning 0 without a dream field? oh, cuz only upgrading specibus
      //if(ret.length == 0) print("alchemy size is ${ret.length} dream field is ${session.mutator.dreamField}");
      return ret;
  }

    //takes all items in inventory and rubs them on each other.
    List<AlchemyResult> upgradeSpecibus() {
        List<AlchemyResult> ret = new List<AlchemyResult>();
        //REMEMBER: item1 OR item2 is a DIFFERENT THING than the reverse. so you aren't wasting time by doing each item pair twice.
        for(Item item1 in player.sylladex) {
            ret.addAll(AlchemyResult.planAlchemy(<Item>[player.specibus, item1], session,playerSkill));
        }
        return ret;
    }

  @override
  bool trigger(List<Player> playerList) { //god i hate that player list is still a thing, past jr fucked up.
      playerSkill = 1; //reset
      List<Player> availablePlayers = findLivingPlayers(session.getReadOnlyAvailablePlayers());
      //relative alchemy value matters too.
      //why the fuck is using the reversed list directly suddenly crashing everythign.
      List<Player> players = new List<Player>.from(Stats.ALCHEMY.sortedList(availablePlayers).reversed);
      //List<Player> players = Stats.ALCHEMY.sortedList(availablePlayers);

      //List<Player>players = availablePlayers;
      player = null;
      //print("trying to trigger gristmas for ${players.length} players.");
      for(Player p in players) {
          //print("P is ${p}");
         // print("P stats is ${p.stats}");
         // print("P alchemy is ${p.getStat(Stats.ALCHEMY)}");

          if(player == null && p.getStat(Stats.ALCHEMY) > 0) { //you don't even bother trying alchemy if you can't figure it out
              //session.logger.info("checking gristmas player ${p} with alchemy skill of ${ p.getStat(Stats.ALCHEMY)}");
              //print("trying to trigger, player is not null");
              bool anyItems = false;
              bool goodItems = false;
              if (p.specibus.canUpgrade(playerSkill == 3) || session.mutator.dreamField) {
                 // if(p.specibus.rank>2) session.logger.info("gristmas ${p.title()} has upgrades remaining, not max. Rank: ${p.specibus.rank}, num alchemizations: ${p.specibus.numUpgrades}");

                  //print("trying to trigger, specibus can upgrade");
                  p.sylladex.sort();
                  for (Item i in p.sylladex) {
                      if (i.canUpgrade(playerSkill == 3) || session.mutator.dreamField) {
                          //print("in trigger, upgradeable item for alchemy is ${i.fullName}");
                          anyItems = true;
                      }
                      if (meetsStandards(p,i)) goodItems = true;
                  }
                  if (anyItems && goodItems)  {
                      //session.logger.info("~~~~~~~~~~~~AB: gristmas triggered for player ${p}. alchemy skill of ${ p.getStat(Stats.ALCHEMY)}");
                      player = p;
                      playerSkill = getAlchemySkillNormalized(player);
                  }else {
                     // session.logger.info("AB: gristmas skipped for player ${p}. anyItems $anyItems goodItems $goodItems");

                  }
              }else {
                //session.logger.info("gristmas ${p.title()} has a maxed out specibus. Rank: ${p.specibus.rank}, num alchemizations: ${p.specibus.numUpgrades}");
              }
          }
      }
      return player != null;
  }

  int getAlchemySkillNormalized(Player p) {
      double ratio = 1.0;
      if (p.land != null && !p.land.firstCompleted) ratio = p.getStat(Stats.ALCHEMY) / expectedInitialAverageAlchemyValue;
      if (p.land != null && p.land.firstCompleted && !p.land.thirdCompleted) ratio = p.getStat(Stats.ALCHEMY) / expectedMiddleAverageAlchemyValue;
      if (p.land != null && !p.land.thirdCompleted) ratio = p.getStat(Stats.ALCHEMY) / expectedEndAverageAlchemyValue;
      if (ratio < 1) {
          //session.logger.info("${p} alchemy skill 1, raw value ${ p.getStat(Stats.ALCHEMY)}");
          return 0;
      } else if (ratio < 2) {
          //session.logger.info("${p} alchemy skill 2,raw value ${ p.getStat(Stats.ALCHEMY)}");
          return 1;
      } else {
          //session.logger.info("${p} alchemy skill 3,raw value ${ p.getStat(Stats.ALCHEMY)}");
          return 2;
      }
  }



  //the better you are at alchemy, the higher your standards are.
  bool meetsStandards(Player p, Item i) {
      return true; //<--being picky actually bites players good at alchemy in the ass.
      double ratio = 1.0;
      //depending on how far along you are in your quest, your standards should get higher.
      if(p.land != null && !p.land.firstCompleted) ratio = p.getStat(Stats.ALCHEMY)/expectedInitialAverageAlchemyValue;
      if(p.land != null && p.land.firstCompleted && !p.land.thirdCompleted) ratio = p.getStat(Stats.ALCHEMY)/expectedMiddleAverageAlchemyValue;
      if(p.land != null && !p.land.thirdCompleted) ratio = p.getStat(Stats.ALCHEMY)/expectedEndAverageAlchemyValue;

      //basically, if you'er higher than average, your standards will be higher
      //and if you'er lower than average, your standards will be lower.
      //specibus = 1.0, item = .9 works for somebody with lower skill
      //does not work for somebody with higher.
      //BUT don't be so snobby you don't alchemize things before the final battle.
      return ((i.rank) > p.specibus.rank*ratio) || session.timeTillReckoning < 10;
  }
}