/*
http://mspaintadventures.wikia.com/wiki/Alchemiter

Appropriately for AND combining, an && alchemy result will often demonstrate the functionality of both components
 – e.g. Dave's iShades can be a phone and a rad pair of shades – while an || alchemy result will typically have the
  functionality of only one of the components, but the form of the other – e.g. the Hammerhead Pogo Ride, which is
   just a pogo that happens to be hammer-shaped.
 */

abstract class ItemTrait {
  List<String> descriptions = new List<String>();
  double rank = 1.0;
  ItemTrait(List<String> this.descriptions, this.rank) {
    ItemTraitFactory.allTraits.add(this);
  }

  @override
  String toString() {
    if(this.descriptions.isNotEmpty) return this.descriptions.first;
    return "NULL TRAIT";
  }


}

//what can this do?
class ItemFunctionTrait extends ItemTrait {
  ItemFunctionTrait(List<String> descriptions, double rank) : super(descriptions, rank);
  //TODO eventually has something to do with combat? piercing v slashing etc.

}

//what kind of object are you? Not in name.
class ItemObjectTrait extends ItemAppearanceTrait {
  ItemObjectTrait(List<String> descriptions, double rank) : super(descriptions, rank);
}

//What does it look like?
//TODO eventually tie to images?
class ItemAppearanceTrait extends ItemTrait {
  ItemAppearanceTrait(List<String> descriptions, double rank) : super(descriptions, rank);
}

class CombinedTrait extends ItemTrait implements Comparable<CombinedTrait> {

  //if i can get rid of a word entirely, then it needs to happen.
  //otherwise, the more traits i can get rid of , the better.
  int get priority {
    if(descriptions.isEmpty) return 1300;
    return subTraits.length;
  }

  //naturally sorted by priority
  @override
  int compareTo(CombinedTrait other) {
    return (other.priority - priority).round(); //TODO or is it the otherway around???
  }

  List<ItemTrait> subTraits;
  CombinedTrait(List<String> descriptions, double rank, this.subTraits) : super(descriptions, rank);

  bool traitsMatchMe(Set<ItemTrait> traits) {
    //following https://github.com/dart-lang/sdk/issues/2217
    //return traits.every(subTraits.contains); <-- wrong.
    return subTraits.every(traits.contains); //<-- right

  }

  static Set<ItemTrait> lookForCombinedTraits(Set<ItemTrait> traits) {
    Set<ItemTrait> copiedTraits = new Set<ItemTrait>.from(traits);
    Set<ItemTrait> ret = new Set<ItemTrait>();
    List<CombinedTrait> foundCombinedTraits = new List<CombinedTrait>();
    for(CombinedTrait ct in ItemTraitFactory.combinedTraits) {
      if(ct.traitsMatchMe(copiedTraits)) foundCombinedTraits.add(ct);
    }

    foundCombinedTraits.sort(); //now they are sorted by priority.
    for(CombinedTrait ct in foundCombinedTraits) {
      if(ct.traitsMatchMe(copiedTraits)) {
        ret.add(ct);
        for(ItemTrait t in ct.subTraits) {
          copiedTraits.remove(t);
        }
      }
    }
    //anything i couldn't turn into a combo gets passed through.
    if(copiedTraits.isNotEmpty) ret.addAll(copiedTraits);
    return ret;
    /*
    TODO:

      Go through all combined traits. see if the traits list matches them. if so, add to list.

      Then, sort found combined traits by priority.

      for each combined trait, if you can find it's subtraits in the copied list
        then add it to the foundCombinedTraits and remove it's subtraits from the list.

        return foundCombinedTraits and any remaining copiedTraits.



     */

  }
}

class ItemTraitFactory {
  static Set<ItemTrait> allTraits = new Set<ItemTrait>();

  static Iterable<ItemFunctionTrait> get functionalTraits => allTraits.where((ItemTrait a) => (a is ItemFunctionTrait));
  static Iterable<ItemFunctionTrait> get appearanceTraits => allTraits.where((ItemTrait a) => (a is ItemAppearanceTrait && !(a is ItemObjectTrait)));
  static Iterable<ItemFunctionTrait> get objectTraits => allTraits.where((ItemTrait a) => (a is ItemObjectTrait));
  static Iterable<CombinedTrait> get combinedTraits => allTraits.where((ItemTrait a) => (a is CombinedTrait));


  //these are what shape it has? doubles as both specibus kinds and basic objects.
  static ItemObjectTrait GENERIC;
  static ItemObjectTrait SWORD;
  static ItemObjectTrait HAMMER;
  static ItemObjectTrait RIFLE;
  static ItemObjectTrait PISTOL;
  static ItemObjectTrait BLADE;
  static ItemObjectTrait DAGGER;
  static ItemObjectTrait SANTA;
  static ItemObjectTrait FIST;
  static ItemObjectTrait SICKLE;
  static ItemObjectTrait CHAINSAW;
  static ItemObjectTrait FORK;
  static ItemObjectTrait DICE;
  static ItemObjectTrait NEEDLE;
  static ItemObjectTrait STAFF;
  static ItemObjectTrait WHIP;
  static ItemObjectTrait BOW;
  static ItemObjectTrait CLUB;
  static ItemObjectTrait BROOM;
  static ItemObjectTrait BOOK;
  static ItemObjectTrait ROADSIGN;
  static ItemObjectTrait AXE;
  static ItemObjectTrait LANCE;
  static ItemObjectTrait SHIELD;
  static ItemObjectTrait CANE;
  static ItemObjectTrait YOYO;
  static ItemObjectTrait SLING;
  static ItemObjectTrait SHURIKEN;
  static ItemObjectTrait MACHINEGUN;
  static ItemObjectTrait GRENADE;
  static ItemObjectTrait BALL;
  static ItemObjectTrait TRIDENT;
  static ItemObjectTrait CARD;
  static ItemObjectTrait FRYINGPAN;
  static ItemObjectTrait PILLOW;
  static ItemObjectTrait SHOTGUN;
  static ItemObjectTrait CHAIN;
  static ItemObjectTrait WRENCH;
  static ItemObjectTrait SHOVEL;
  static ItemObjectTrait ROLLINGPIN;
  static ItemObjectTrait PUPPET;
  static ItemObjectTrait RAZOR;
  static ItemObjectTrait PEN;
  static ItemObjectTrait BUST;
  static ItemObjectTrait BOWLING;
  static ItemObjectTrait GOLFCLUB;
  static ItemObjectTrait KNIFE;
  static ItemObjectTrait SCISSOR;
  static ItemObjectTrait SAFE;




  //these would be "color" i guess? material it's made of?
  static ItemAppearanceTrait METAL;
  static ItemAppearanceTrait CLAWS;
  static ItemAppearanceTrait CERAMIC;
  static ItemAppearanceTrait BONE;
  static ItemAppearanceTrait WOOD;
  static ItemAppearanceTrait PLASTIC;
  static ItemAppearanceTrait RUBBER;
  static ItemAppearanceTrait PAPER;
  static ItemAppearanceTrait CLOTH;
  static ItemAppearanceTrait STONE;
  static ItemAppearanceTrait GLASS;
  static ItemAppearanceTrait FLESH;
  static ItemAppearanceTrait FUR;
  static ItemAppearanceTrait UGLY;
  static ItemAppearanceTrait LEGENDARY;

  static ItemFunctionTrait EDGED;
  static ItemFunctionTrait SCARY;
  static ItemFunctionTrait POINTY;
  static ItemFunctionTrait BLUNT;
  static ItemFunctionTrait HEAVY;
  static ItemFunctionTrait SHOOTY;
  static ItemFunctionTrait ONFIRE;
  static ItemFunctionTrait LUCKY;
  static ItemFunctionTrait GLOWING;
  static ItemFunctionTrait OBSCURING;
  static ItemFunctionTrait CALMING;
  static ItemFunctionTrait NUCLEAR;
  static ItemFunctionTrait DOOMED;
  static ItemFunctionTrait EXPLODEY;
  static ItemFunctionTrait COLD;
  static ItemFunctionTrait ZAP;
  static ItemFunctionTrait POISON;
  static ItemFunctionTrait MUSICAL;
  static ItemFunctionTrait VALUABLE;
  static ItemFunctionTrait ENRAGING;
  static ItemFunctionTrait RESTRAINING;
  static ItemFunctionTrait PRETTY;
  static ItemFunctionTrait COMFORTABLE;
  static ItemFunctionTrait UNCOMFORTABLE;
  static ItemFunctionTrait SMART;
  static ItemFunctionTrait ROMANTIC;
  static ItemFunctionTrait FUNNY;
  static ItemFunctionTrait EDIBLE;
  static ItemFunctionTrait COOLK1D;
  static ItemFunctionTrait MAGICAL;
  static ItemFunctionTrait CLASSY;
  static ItemFunctionTrait FAKE;
  static ItemFunctionTrait LOUD;

  static CombinedTrait FORGED;
  static CombinedTrait SPOOPY;
  static CombinedTrait WOLVERINE;
  static CombinedTrait DULLEDGED;
  static CombinedTrait DULLPOINTED;
  static CombinedTrait SOFTHARD;
  static CombinedTrait FOSSILIZED;
  static CombinedTrait ADAMANTIUM;
  static CombinedTrait TATAMI;
  static CombinedTrait MESH;
  static CombinedTrait FOIL;
  static CombinedTrait BEANBAG;
  static CombinedTrait PLEATHER;
  static CombinedTrait PLYWOOD;
  static CombinedTrait ROBOTIC;
  static CombinedTrait ROTTING;
  static CombinedTrait LIGHTVOID;
  static CombinedTrait DOOMLUCK;
  static CombinedTrait CANDY;
  static CombinedTrait COTTONCANDY;
  static CombinedTrait GUM;
  static CombinedTrait EDIBLEPOISON;
  static CombinedTrait MARROW;
  static CombinedTrait TOOTHY;
  static CombinedTrait CRYSTAL;
  static CombinedTrait MARYSUE;
  static CombinedTrait EDGELORD;

  static void init() {
    initAppearances();
    initFunctions();
    initObjects();
    initCombined();//IMPORTANT has to be last cuz references others.
  }

  static void initCombined() {
    FORGED = new CombinedTrait(<String>["forged", "sharpened","honed","filed"], 0.0, <ItemTrait>[METAL, EDGED, POINTY]);
    DULLEDGED = new CombinedTrait(<String>[], 0.0, <ItemTrait>[BLUNT, EDGED]);
    FOSSILIZED = new CombinedTrait(<String>["fossilized"], 0.0, <ItemTrait>[BONE, STONE]);
    ADAMANTIUM = new CombinedTrait(<String>["fossilized"], 0.0, <ItemTrait>[BONE, METAL]);
    DULLPOINTED = new CombinedTrait(<String>[], 0.0, <ItemTrait>[BLUNT, POINTY]);
    SOFTHARD = new CombinedTrait(<String>[], 0.0, <ItemTrait>[COMFORTABLE, UNCOMFORTABLE]);
    TATAMI  = new CombinedTrait(<String>["tatami"], 0.0, <ItemTrait>[CLOTH, WOOD]);
    MESH  = new CombinedTrait(<String>["mesh","chain link"], 0.0, <ItemTrait>[CLOTH, METAL]);
    FOIL  = new CombinedTrait(<String>["foil"], 0.0, <ItemTrait>[PAPER, METAL]);
    BEANBAG  = new CombinedTrait(<String>["beanbag"], 0.0, <ItemTrait>[CLOTH, STONE]);
    PLEATHER  = new CombinedTrait(<String>["pleather","faux fur"], 0.0, <ItemTrait>[FUR, PLASTIC]);
    PLYWOOD = new CombinedTrait(<String>["plywood"], 0.0, <ItemTrait>[WOOD, PAPER]);
    ROBOTIC = new CombinedTrait(<String>["robotic"], 0.0, <ItemTrait>[METAL, FLESH]);
    ROTTING = new CombinedTrait(<String>["rotting","zombie"], 0.0, <ItemTrait>[UGLY, FLESH]);
    LIGHTVOID  = new CombinedTrait(<String>[], 0.0, <ItemTrait>[GLOWING, OBSCURING]);
    DOOMLUCK  = new CombinedTrait(<String>[], 0.0, <ItemTrait>[DOOMED, LUCKY]);
    CANDY = new CombinedTrait(<String>["candy"], 0.0, <ItemTrait>[EDIBLE, GLASS]);
    COTTONCANDY = new CombinedTrait(<String>["cotton candy"], 0.0, <ItemTrait>[EDIBLE, CLOTH]);
    GUM = new CombinedTrait(<String>["gummy"], 0.0, <ItemTrait>[EDIBLE, RUBBER]);
    MARROW = new CombinedTrait(<String>["gummy"], 0.0, <ItemTrait>[EDIBLE, BONE]);
    TOOTHY = new CombinedTrait(<String>["toothy"], 0.0, <ItemTrait>[BONE, CERAMIC]);
    EDIBLEPOISON  = new CombinedTrait(<String>[], 0.0, <ItemTrait>[EDIBLE, POISON]);
    CRYSTAL  = new CombinedTrait(<String>["crystal","diamond","quartz"], 0.0, <ItemTrait>[STONE, GLASS]);
    MARYSUE  = new CombinedTrait(<String>["mary sue","sakura katana chan","shitty oc"], 0.0, <ItemTrait>[COOLK1D, PRETTY, ROMANTIC,FUNNY, SMART, CLASSY, LUCKY, MAGICAL]);
    EDGELORD  = new CombinedTrait(<String>["edge lord","coldsteel the hedgehog"], 0.0, <ItemTrait>[SCARY, OBSCURING, EDGED,LEGENDARY, DOOMED, SMART, CLASSY]);


    SPOOPY = new CombinedTrait(<String>["spoopy","skellington's","creppy"], 0.0, <ItemTrait>[SCARY, COOLK1D]);
    WOLVERINE = new CombinedTrait(<String>["wolverine"], 0.0, <ItemTrait>[BONE, EDGED, POINTY]);


  }

  static void initObjects() {
    //it's sharp, it's pointy and it's a sword
    GENERIC = new ItemObjectTrait(<String>["perfectly generic"], 0.1);
    SWORD = new ItemObjectTrait(<String>["a sword"], 0.4);
    HAMMER = new ItemObjectTrait(<String>["a hammer"], 0.4);
    RIFLE = new ItemObjectTrait(<String>["a rifle"], 0.4);
    PISTOL = new ItemObjectTrait(<String>["a pistol"], 0.4);
    BLADE = new ItemObjectTrait(<String>["a blade"], 0.4);
    DAGGER = new ItemObjectTrait(<String>["a dagger"], 0.4);
    SANTA = new ItemObjectTrait(<String>["a santa"], 0.4);
    FIST = new ItemObjectTrait(<String>["a fist"], 0.4);
    CLAWS = new ItemObjectTrait(<String>["claws"], 0.4);
    GRENADE = new ItemObjectTrait(<String>["a grenade"], 0.4);
    SAFE = new ItemObjectTrait(<String>["a freaking safe"], 0.4);
    BALL = new ItemObjectTrait(<String>["a ball"], 0.4);
    TRIDENT = new ItemObjectTrait(<String>["a trident"], 0.4);
    CARD = new ItemObjectTrait(<String>["a card"], 0.4);
    FRYINGPAN = new ItemObjectTrait(<String>["a frying pan"], 0.4);
    PILLOW = new ItemObjectTrait(<String>["a pillow"], 0.4);
    MACHINEGUN = new ItemObjectTrait(<String>["a machinegun"], 0.4);
    SHURIKEN = new ItemObjectTrait(<String>["a shuriken"], 0.4);
    SLING = new ItemObjectTrait(<String>["a sling"], 0.4);
    YOYO = new ItemObjectTrait(<String>["a yoyo"], 0.4);
    CANE = new ItemObjectTrait(<String>["a cane"], 0.4);
    SHIELD = new ItemObjectTrait(<String>["a shield"], 0.4);
    LANCE = new ItemObjectTrait(<String>["a lance"], 0.4);
    AXE = new ItemObjectTrait(<String>["a ax"], 0.4);
    ROADSIGN = new ItemObjectTrait(<String>["a sign"], 0.4);
    BOOK = new ItemObjectTrait(<String>["a book"], 0.4);
    BROOM = new ItemObjectTrait(<String>["a broom"], 0.4);
    CLUB = new ItemObjectTrait(<String>["a club"], 0.4);
    BOW = new ItemObjectTrait(<String>["a bow"], 0.4);
    WHIP = new ItemObjectTrait(<String>["a whip"], 0.4);
    STAFF = new ItemObjectTrait(<String>["a staff"], 0.4);
    NEEDLE = new ItemObjectTrait(<String>["a needle"], 0.4);
    DICE = new ItemObjectTrait(<String>["dice"], 0.4);
    FORK = new ItemObjectTrait(<String>["a fork"], 0.4);
    CHAINSAW = new ItemObjectTrait(<String>["a chainsaw"], 0.4);
    SICKLE = new ItemObjectTrait(<String>["a sickle"], 0.4);
    SHOTGUN = new ItemObjectTrait(<String>["a shotgun"], 0.4);
    SICKLE = new ItemObjectTrait(<String>["a sickle"], 0.4);
    CHAIN = new ItemObjectTrait(<String>["a chain"], 0.4);
    WRENCH = new ItemObjectTrait(<String>["a wrench"], 0.4);
    SHOVEL = new ItemObjectTrait(<String>["a shovel"], 0.4);
    ROLLINGPIN = new ItemObjectTrait(<String>["a rolling pin"], 0.4);
    PUPPET = new ItemObjectTrait(<String>["a puppet"], 0.4);
    RAZOR = new ItemObjectTrait(<String>["a razor"], 0.4);
    PEN = new ItemObjectTrait(<String>["a pen"], 0.4);
    BUST = new ItemObjectTrait(<String>["a bust"], 0.4);
    BOWLING = new ItemObjectTrait(<String>["a bowling ball"], 0.4);
    GOLFCLUB = new ItemObjectTrait(<String>["a golf club"], 0.4);
    KNIFE = new ItemObjectTrait(<String>["a knife"], 0.4);
    SCISSOR = new ItemObjectTrait(<String>["scissors"], 0.4);
  }

  static void initAppearances() {
    METAL = new ItemAppearanceTrait(<String>["metal"], 0.3);
    CERAMIC = new ItemAppearanceTrait(<String>["ceramic"], -0.3);
    BONE = new ItemAppearanceTrait(<String>["bone"], 0.1);
    WOOD = new ItemAppearanceTrait(<String>["wood"], -0.3);
    PLASTIC = new ItemAppearanceTrait(<String>["plastic"], -0.3);
    RUBBER = new ItemAppearanceTrait(<String>["rubber"], -0.3);
    PAPER = new ItemAppearanceTrait(<String>["paper"], -0.3);
    CLOTH = new ItemAppearanceTrait(<String>["cloth", "fabric"], -0.3);
    GLASS = new ItemAppearanceTrait(<String>["glass"], -0.3);
    FLESH = new ItemAppearanceTrait(<String>["flesh", "meat","muscle"], -0.1);
    FUR = new ItemAppearanceTrait(<String>["fur", "fluff","fuzzy"], -0.1);
    UGLY = new ItemAppearanceTrait(<String>["gross", "ugly","unpleasant"], -0.1);
    STONE = new ItemAppearanceTrait(<String>["stone", "rock", "concrete"], 0.3);
    LEGENDARY = new ItemAppearanceTrait(<String>["legendary"], 13.0);
  }

  static void initFunctions() {
    EDGED = new ItemFunctionTrait(["edged", "sharp", "honed", "keen", "bladed"], 0.3);
    GLOWING = new ItemFunctionTrait(["glowing", "bright", "illuminated"], 0.1);
    OBSCURING = new ItemFunctionTrait(["obscuring", "dark", "shadowy"], 0.1);
    CALMING = new ItemFunctionTrait(["calming", "pale", "placating","shooshing"], 0.1);
    NUCLEAR = new ItemFunctionTrait(["nuclear", "radioactive", "irradiated"], 1.0);
    SCARY = new ItemFunctionTrait(["scary", "horrifying", "terrifying","spooky"], 0.1);
    LUCKY = new ItemFunctionTrait(["lucky", "fortunate", "gambler's", "favored", "charmed"], 0.3);
    DOOMED = new ItemFunctionTrait(["doomed", "cursed", "unlucky"], -0.3);
    POINTY = new ItemFunctionTrait(["pointy", "sharp", "sharpened", "barbed", "piked", "sharpened","pronged", "pointed"], 0.3);
    EXPLODEY = new ItemFunctionTrait(["exploding", "explosive", "detonating", "grenade"], 0.6);
    ZAP = new ItemFunctionTrait(["electrical", "zap", "lightning", "shock"], 0.6);
    RESTRAINING = new ItemFunctionTrait(["restraining", "imprisoning", "restricting"], 0.3);
    VALUABLE = new ItemFunctionTrait(["expensive", "valuable", "bling", "money"], 0.1);
    EDIBLE = new ItemFunctionTrait(["edible", "tasty", "delicious", "savory"], 0.1);
    CLASSY = new ItemFunctionTrait(["classy", "distinguished", "tasteful", "cultured"], 0.1);
    COOLK1D = new ItemFunctionTrait(["cool", "wicked","radical", "awesome", "groovy", "tubular","bitching","sick nasty","bodacious"], 0.1);
    SMART = new ItemFunctionTrait(["intelligent", "smart", "useful", "scientific","encyclopedic"], 0.1);
    ROMANTIC = new ItemFunctionTrait(["romantic","amorous", "passionate","tender","affectionate","lovey-dovey"], 0.1);
    FUNNY = new ItemFunctionTrait(["funny", "hilarious", "SBAHJ", "comedy gold"], 0.1);
    ENRAGING = new ItemFunctionTrait(["annoying", "enraging", "dickish", "asshole"], 0.1);
    MAGICAL = new ItemFunctionTrait(["magical", "mystical", "magickal", "wizardy"], 0.6);
    PRETTY = new ItemFunctionTrait(["pretty", "aesthetic", "fashionable", "beautiful"], 0.1);
    UNCOMFORTABLE = new ItemFunctionTrait(["uncomfortable", "hard","unpleasant"], 0.1);

    COMFORTABLE = new ItemFunctionTrait(["comfortable", "comforting", "soft", "cozy", "snug", "pleasant"], -0.1);
    POISON = new ItemFunctionTrait(["poisonous", "venomous", "draining", "poison"], 0.6);
    COLD = new ItemFunctionTrait(["chilly", "chill", "cold", "freezing", "icy", "frozen", "ice"], 0.6);
    HEAVY = new ItemFunctionTrait(["heavy", "weighs a ton", "heavy","heavy enough to kill a cat"], 0.4);
    ONFIRE = new ItemFunctionTrait(["fire", "burning", "blazing", "hot", "heated", "on fire", "combusting", "flaming", "fiery"], 0.6);
    BLUNT = new ItemFunctionTrait(["blunt", "bludgeoning", "dull"], 0.3);
    SHOOTY = new ItemFunctionTrait(["shooty", "ranged", "projectile", "piercing", "loaded", "full of ammo", "long-range"], 0.3);
    MUSICAL = new ItemFunctionTrait(["musical", "melodic", "harmonious", "tuneful", "euphonious", "mellifluous,"], 0.1);
    LOUD = new ItemFunctionTrait(["loud", "ear splitting", "noisy", "deafening", "thundering"], 0.3);
    FAKE = new ItemFunctionTrait(["fake", "false", "imitation", "simulated", "replica"], -0.3);
  }
}
