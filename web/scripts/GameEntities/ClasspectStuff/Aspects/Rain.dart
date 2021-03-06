import '../../../SBURBSim.dart';
import 'Aspect.dart';
import "../../../Lands/FeatureTypes/QuestChainFeature.dart";
import "../../../Lands/Reward.dart";
import "../../../Lands/Quest.dart";


class Rain extends Aspect {
  @override
  AspectPalette palette = new AspectPalette()
    ..accent = '#00FFFF'
    ..aspect_light = '#00ffff'
    ..aspect_dark = '#009090'
    ..shoe_light = '#FEFEFE'
    ..shoe_dark = '#707070'
    ..cloak_light = '#0000FF'
    ..cloak_mid = '#0000b3'
    ..cloak_dark = '#000080'
    ..shirt_light = '#9900ff'
    ..shirt_dark = '#5c0099'
    ..pants_light = '#00FF00'
    ..pants_dark = '#008000';


  @override
  List<String> landNames = new List<String>.unmodifiable(<String>["Neon", "Headaches", "Puddles", "Drip", "Mess", "Ice cream", "Sweets", "Boredom"]);

  @override
  List<String> levels = new List<String>.unmodifiable(<String>["PUDDLE PUMMELLER", "FLOOD FINISHER", "RAINBRO"]);

  @override
  List<String> handles = new List<String>.unmodifiable(<String>["Rainer", "Retriever", "Rower", "Redux", "Rapport"]);

  @override
  List<String> fraymotifNames = new List<String>.unmodifiable(<String>["Chaos", "disorder", "puddle", "Rain", "error", "color", "Swirl", "LOL",]);

  @override
  String denizenSongTitle = "Rudiment"; //a basic pattern used by drummers, such as the roll, the flam, and the paradiddle.

  @override
  String denizenSongDesc = "An erratic beat plays. It is the beat Confusion drums. The OWNER is strengthened and healed. The ENEMY is weakened and hurt. And that is all there is to say on the matter. ";

  @override
  List<String> denizenNames = new List<String>.unmodifiable(<String>['Rain', 'Chaac', 'Tohil', "Q'uq'umatz", "Tlaloc", "Cocijo", "Dzahui", "Mu'ye", "Jaguar", "Quiateot", "Lono", "Indra", "Dodola", "Dudumitsa", "Deng", "Mangwe", "Oya", "Asiaq"]);

  @override
  List<String> symbolicMcguffins = ["rain","chaos", "disorder", "insanity", "discontinuity", "distortion"];
  @override
  List<String> physicalMcguffins = ["rain","raindrop", "noisemaker", "watercolor", "RNG", "neon tube", "faucet", "hose",];


  @override
    @override
    List<AssociatedStat> stats = new List<AssociatedStat>.unmodifiable(<AssociatedStat>[
        new AssociatedStat(Stats.RELATIONSHIPS, -2.0, true),
        new AssociatedStat(Stats.SANITY, -1.0, true),
        new AssociatedStat(Stats.MAX_LUCK, 3.0, true)
    ]);

  Rain(int id) :super(id, "Rain", isCanon: false);

  @override
  String activateCataclysm(Session s, Player p) {
    return s.mutator.rain(s, p);
  }

}