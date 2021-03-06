import "../GameEntities/player.dart";
import "../GameEntities/GameEntity.dart";
export "../GameEntities/Stats/stat.dart";

import "Item.dart";
import "../random_tables.dart";
import "Trait.dart";
import "../random.dart";
import 'dart:collection';

//I expect aspects and interests to have lists of items inside of them.
class Item implements Comparable<Item> {
    //whenever i make a new item, it gets added here. but not if i make a copy. needed for alchemy mini game.
    static List<Item> allUniqueItems = new List<Item>();
    String abDesc;
    String shogunDesc;

    static Iterable<Item> uniqueItemsWithTrait(ItemTrait trait) {
        return Item.allUniqueItems.where((Item a) => (a.traits.contains(trait)));
    }

    //power of item
    @override
    int compareTo(Item other) {
        // print("trying to sort ${this} against ${other}, ret is $ret. other value was ${other.result.rank}, my value was ${result.rank}  ");
        return (other.rank - rank).sign.round(); //higher numbers first
    }

    String baseName;
    bool isCopy;
    //a set is like a list but each thing in it happens exactly one or zero times
    Set<ItemTrait>  traits = new Set<ItemTrait>();

    void modMaxUpgrades(Player p) {
        for(AssociatedStat a in p.associatedStats) {
            if(a.stat == Stats.ALCHEMY) maxUpgrades += a.multiplier.round(); //yes, it might be negative. deal with it.
        }
    }


    //dynamic based on current traits.
    List<String> get descriptors {
        List<String> ret = new List<String>();
        //not based on the session's random, but not going to change each time, either.
        //does mean might have a Flaming Sword turn into a Glowing Fiery Sword but whatevs
        Random rand = new Random(traits.length);
        if(numUpgrades == 0) return ret;
        //TODO if this is slow, then cache result and only reget if dirty flag is set..
        List<ItemTrait> combinedTraits = new List<ItemTrait>.from(CombinedTrait.lookForCombinedTraits(traits));
        combinedTraits.sort((ItemTrait a,ItemTrait b){
          //  print("Sorting a is ${a.ordering} and b is ${b.ordering}");
            return a.ordering - b.ordering.round();
        });
        for(ItemTrait t in combinedTraits) {
            if(t is ItemObjectTrait || t.descriptions.isEmpty) {
                //skip
            }else {
                ret.add(" ${ capitilizeEachWord(rand.pickFrom(t.descriptions))}");
            }
        }
        return ret;
    }




    int numUpgrades = 0;
    int maxUpgrades = 3;

    double get rank {
        double ret = 0.0;
        for(ItemTrait it in traits) {
            ret += it.rank;
        }

        return ret;
    }

    Iterable<ItemTrait> get functionalTraits => traits.where((ItemTrait a) => (a is ItemFunctionTrait));
    Iterable<ItemTrait> get appearanceTraits => traits.where((ItemTrait a) => (a is ItemAppearanceTrait));
    Iterable<ItemTrait> get combinedTraits => traits.where((ItemTrait a) => (a is CombinedTrait));


    String get fullName {
        String ret = "";
        for(String d in descriptors) {
            ret += "$d ";
        }
        return "$ret${baseName}";
    }

    String get fullNameWithUpgrade {
        return "${fullName} ${numUpgrades}/${maxUpgrades}";
    }



    String toString() {
        return fullName;
    }

    Item copy() {
        Item ret =  new Item(baseName, new List<ItemTrait>.from(traits),isCopy:true, abDesc: this.abDesc, shogunDesc:this.shogunDesc);
     //   print("I copied the item. Does it know it's a copy? ${ret.isCopy}");
        ret.numUpgrades = numUpgrades;
        ret.maxUpgrades = maxUpgrades;
        return ret;
    }

    //it takes a master to alchemize with a legendary weapon. high grist cost.
    bool canUpgrade(bool master) {
        //print("Checking number of upgrades remaining for ${baseName}, numUpgrades is ${numUpgrades} and maxUpgrades is ${maxUpgrades}");
        if(maxUpgrades > 0 && numUpgrades< maxUpgrades) {
            if(traits.contains(ItemTraitFactory.LEGENDARY)){ //only a master can handle a legendary thing
                if(!master) return false;
            }
            return true;
        }else {
            return false;
        }
    }

    //most items won't have an abj desc, but some will
    Item(String this.baseName,List<ItemTrait> traitsList, {this.isCopy: false,this.abDesc: null, this.shogunDesc: null}) {
        traits = new Set.from(traitsList);
        if(this.traits.isEmpty)traits.add(ItemTraitFactory.GENERIC); //every item has at least one trait
        Set<CombinedTrait> ct = new Set.from(combinedTraits);
        //if i have any combined traits in me, just use the sub traits.
        for(CombinedTrait it in ct) {
            traits.addAll(it.subTraits);
            traits.remove(it);
        }

        if(!isCopy) {
            //print("this is a unique item, not a copy. $isCopy");
            Item.allUniqueItems.add(this);
        }
    }

    String abDescription(Random rand) {
        if(abDesc != null) {
            return abDesc;
        }else {
            return randomDescription(rand);
        }
    }

    String shogunDescription(Random rand) {
        if(shogunDesc != null) {
            return shogunDesc;
        }else {
            return "Actual Worthless Object";
        }
    }

    //it's sharp, it's pointy and it's a sword.   so can pick the same trait multiple times and just pick different words? Yes.
    String randomDescription(Random rand) {
        if(traits.isEmpty) traits.add(ItemTraitFactory.GENERIC); //don't stay empty
        ItemTrait first = rand.pickFrom(traits);
        ItemTrait second = rand.pickFrom(traits);
        ItemTrait third = rand.pickFrom(traits);

        //try to avoid repetition.
        if (first == second && traits.length > 1) {
            second = getTraitBesides(first);
        }

        if (second == third && traits.length > 1) {
            third = getTraitBesides(second);
        }

        String word1, word2, word3;
        if(first != null)  word1 = rand.pickFrom(first.descriptions);
        if(second != null) word2 = rand.pickFrom(second.descriptions);
        if(third != null) word3 = rand.pickFrom(third.descriptions);


        if(word1 != null && word2 != null && word3 != null) {
            return randomDescriptionWith3Words(rand, word1, word2, word3);
        }else if(word2 != null && word3 != null) {
            return "It's $word2 and it's $word3 and that is all there is to say on the matter.";
        }else if(word3 != null) {
            return "It is the platonic ideal of $word3.";
        }else {
            return "...  What even IS this.";
        }
    }

    //don't be repetitive for specibus, where they are very limited in what they can say
    ItemTrait getTraitBesides(ItemTrait it) {
        List<ItemTrait> reversed = traits.toList();
        //pick most recent trait first.
        for (ItemTrait i in reversed.reversed) {
            if (it != i) {
                return i;
            }
        }
        return it;
    }

    String randomDescriptionWith3Words(Random rand, String word1, String word2, String word3) {
        //learned this trick in shitty card sim.
        List<String> templates = <String>["It's $word1 and it's $word2 and it's $word3. ","It's kind of $word1 but also sorta $word2. It's  $word3.","It's a $word3 but somehow also $word2 and actually maybe also $word1?"];

        return rand.pickFrom(templates);
    }
}

//wrapper for inventory SO THAT I STOP ADDING ITEMS DIRECTLY TO IT INSTEAD OF COPIES.
//and i guess eventually can implement syladdex shenanigans
//probably could have extended list, too, but that seems more compliced. 40+ methods i have to write?
class Sylladex extends Object with IterableMixin<Item> {
    List<Item> inventory;
    Player player;

    Sylladex(this.player, [this.inventory = null]) {
        if(this.inventory == null) inventory = new List<Item>();
    }

    int get length => inventory.length;
    
    void sort() {
        inventory.sort();
    }

    void add(Item item) {
        Item i = item;
        if(Item.allUniqueItems.contains(item)) {
            //print("going to copy an item rather than add it directly");
            i = item.copy();
            //print("Item copied");
        }
        inventory.add(i);
        //print("inventory updated");
        i.modMaxUpgrades(player);
    }



    void addAll(List<Item> items) {
        for(Item i in items) {
            //print("adding ${i.fullName}");
            add(i);
        }
    }

    Item get first => inventory.first;

    void remove(Item item) {
        inventory.remove(item);
    }

    void clear() {
        inventory.clear();
    }

  @override
  Iterator<Item> get iterator => inventory.iterator;
}