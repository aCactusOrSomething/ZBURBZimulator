part of SBURBSim;

//jack/queen/king/denizen.
//multiround, but only takes 1 tick.
//when call fight method, pass in array of players. only those players are involved in fight.
//whoever calls fight is reponsible for high mobility players to be more likely in a fight.
//should use ALL stats. luck, mobility, freeWill, raw power, relationships, etc. Hope powered up by how screwed things are, for example. (number of corpses, lack of Ecto lack of frog, etc. ).
//denizens have a particular stat that won't matter. Can't beat Cetus in a Luck-Off, she is simply the best there is, for example.
//mini boss = denizen minion;
//before I decide boss stats, need to have AB compile me a list of average player stats. She's getting kinda...busy though. maybe a secret extra area? same page, but on bottom?
//maybe eventually refactor murder mode to use this engine. both players get converted to game entitites for the fight?
//are sprites a game entity attached to player? have same stats as their prototyping would cause. help player fight. can be killed. leave the player entirely after
//denizen minion fight.
class GameEntity {
	var session;
	var name;
	//num alchemy = 0;
	bool armless = false;
	num grist = 0;
	List<dynamic> fraymotifs = [];
	bool usedFraymotifThisTurn = false;
	List<dynamic> buffs = []; //only used in strifes, array of BuffStats (from fraymotifs and eventually weapons)
	bool carapacian = false;
	num sanity = 0; //eventually replace triggerLevel with this (it's polarity is opposite triggerLevel)
	num alchemy = 0; //mostly unused until we get to the Alchemy update.
	bool consort = false;
	bool sprite = false;		//if any stat is -1025, it's considered to be infinitie. denizens use. you can't outluck Cetus, she is simply the best there is.
	num minLuck = 0;
	num currentHP = 0;
	num hp = 0;  //what does infinite hp mean? you need to defeat them some other way. alternate win conditions? or can you only do The Choice?
	num mobility = 0;  //first guardian
	num maxLuck = 0; //rabbit
	num freeWill = 0; //jack has extremely high free will. why he is such a wild card
	List<dynamic> relationships = [];
	num RELATIONSHIPS = 0; //fake as fuck stat so gameEntieties buffing or debuffing relationships have something to do.
	num power = 0;
	bool dead = false;
	var crowned;
	bool abscondable = true; //nice abscond
	bool canAbscond = true; //can't abscond bro
	List<dynamic> playersAbsconded = [];
	bool iAbscond = false;
	bool exiled = false;
	bool lusus = false;
	bool player = false;  //did a player jump in a sprite?
	bool illegal = false; //used only for sprites. whether or not they are reptile/amphibian.
	bool corrupted = false; //if corrupted, name is zalgoed.
		//when tier2 sprites, helpful sprites override the other sprites helpfulnes and help phrase.
		//corrupt sprites maybe activate second corrupt phrase, like glitched out librarians and pomeranians
	num helpfulness = 0; //if 0, cagey riddles. if 1, basically another player. if -1, like calsprite. omg, just shut up.  NOT additive for when double prototyping. most recent prototyping overrides.
	String helpPhrase = "provides the requisite amount of gigglesnort hideytalk to be juuuust barely helpful. ";		

	// more undefined fields... -PL
	var flippingOutOverDeadPlayer = null;
	String flipOutReason = "";
	String causeOfDeath = "";


	GameEntity(this.session, this.name, this.crowned) {}


	bool renderable(){
			return false; //eventually some game entities can be rendered.
		}
	dynamic toString(){
			return this.htmlTitle().replace(new RegExp(r"""\s""", multiLine:true), '').replace(new RegExp(r"""'""", multiLine:true), ''); //no spces probably trying to use this for a div
		}
	void increasePower(){
			//stub for sprites, and maybe later consorts or carapcians
		}
	dynamic getTotalBuffForStat(statName){
        	    num ret = 0;
        	    for(num i = 0; i<this.buffs.length; i++){
        	        var b = this.buffs[i];
        	        if(b.name == statName) ret += b.value;
        	    }
        	    return ret;
        	}
	String humanWordForBuffNamed(statName){
                if(statName == "MANGRIT") return "powerful";
                if(statName == "hp") return "sturdy";
                if(statName == "RELATIONSHIPS") return "friendly";
                if(statName == "mobility") return "fast";
                if(statName == "sanity") return "calm";
                if(statName == "freeWill") return "willful";
                if(statName == "maxLuck") return "lucky";
                if(statName == "minLuck") return "lucky";
                if(statName == "alchemy") return "creative";
                return null;
        	}
	dynamic describeBuffs(){
        	    List<dynamic> ret = [];
        	    var allStats = this.allStats();
        	    for(num i = 0; i<allStats.length; i++){
        	        var b = this.getTotalBuffForStat(allStats[i]);
        	        //only say nothing if equal to zero
        	        if(b>0) ret.add("more "+this.humanWordForBuffNamed(allStats[i]));
        	        if(b<0) ret.add("less " + this.humanWordForBuffNamed(allStats[i]));
        	    }
        	    if(ret.length == 0) return "";
        	    return this.htmlTitleHP() + " is feeling " + turnArrayIntoHumanSentence(ret) + " than normal. ";
        	}
	dynamic getMobility(){
			if(this.crowned){
				return this.mobility + this.crowned.mobility;
			}
			return this.mobility;
		}
	dynamic getMaxLuck(){
			if(this.crowned){
				return this.maxLuck + this.crowned.maxLuck;
			}
			return this.maxLuck;
		}
	void modifyAssociatedStat(modValue, stat){
			//modValue * stat.multiplier.
			if(stat.name == "RELATIONSHIPS"){
				for(num i = 0; i<this.relationships.length; i++){
					this.relationships[i].value += modValue * stat.multiplier;
				}
			}else{
				this[stat.name] += modValue * stat.multiplier;
			}
		}
	dynamic getStat(statName){
			num ret = 0;
			ret += this[statName] ;//for game entitties RELATIONSHIPS will ALSO be a fake as fuck int var thingy.;
			if(statName == "RELATIONSHIPS"){ //in addition to the for loop of doom.
				for(num i = 0; i<this.relationships.length; i++){
					ret += this.relationships[i].value;s
				}
			}
			for(num i = 0; i<this.buffs.length; i++){
				var b = this.buffs[i];
				if(b.name == statName) ret += b.value;
			}
			if(this.crowned) ret += this.crowned.getStat(statName); //so meta.
			return ret;
		}
	dynamic removeAllNonPlayers(players){
			List<dynamic> ret = [];
			for(num i = 0; i< players.length; i++){
				var p = players[i];
				if(!p.carapacian && !p.sprite && !p.consort) ret.add(p);
			}
			return ret;
		}
	void setStatsHash(hashStats){
			for (var key in hashStats){
				this[key] = hashStats[key];
			}
			this.currentHP = Math.max(this.hp, 10); //no negative hp asshole.
		}
	void setStats(minLuck, maxLuck, hp, mobility, sanity, freeWill, power, abscondable, canAbscond, framotifs, grist){
			this.minLuck = minLuck;
			this.hp = hp;
			this.currentHP = this.hp;
			this.mobility = mobility;
			this.maxLuck = maxLuck;
			this.sanity = sanity;
			this.freeWill = freeWill;
			this.power = power;
			this.abscondable = abscondable;
			this.canAbscond = canAbscond;
			this.grist = grist;
		}
	dynamic htmlTitle(){
			String ret = "";
			if(this.crowned != null) ret+="Crowned ";
			var pname = this.name;
			if(pname == "Yaldabaoth"){
				var misNames = ['Yaldobob', 'Yolobroth', 'Yodelbooger', "Yaldabruh", 'Yogertboner','Yodelboth'];
				print("Yaldobooger!!! " + this.session.session_d);
				pname = getRandomElementFromArray(misNames);
			}
			if(this.corrupted) pname = Zalgo.generate(this.name); //will i let denizens and royalty get corrupted???
			return ret + pname; //TODO denizens are aspect colored.
		}
	dynamic htmlTitleHP(){
			String ret = "";
			if(this.crowned != null) ret+="Crowned ";
			var pname = this.name;
			if(this.corrupted) pname = Zalgo.generate(this.name); //will i let denizens and royalty get corrupted???
			return ret + pname +" (" + (this.getStat("currentHP")).round() +" hp, " + (this.getStat("power")).round() + " power)</font>"; //TODO denizens are aspect colored.
		}
	void flipOut(reason){
			this.flippingOutOverDeadPlayer = null;
			this.flipOutReason = reason;
		}
	void addPrototyping(object){
			this.name = object.name + this.name; //sprite becomes puppetsprite.
			this.fraymotifs.addAll(object.fraymotifs);
			if(object.fraymotifs.length == 0){
				var f = new Fraymotif([], object.name + "Sprite Beam!", 1);
				f.effects.add(new FraymotifEffect("power",2,true)); //do damage
				f.effects.add(new FraymotifEffect("hp",1,true)); //heal
				f.flavorText = " An appropriately themed beam of light damages enemies and heals allies. ";
				this.fraymotifs.add(f);
			}
			this.corrupted = object.corrupted;
			this.helpfulness = object.helpfulness; //completely overridden.
			this.helpPhrase = object.helpPhrase;
			this.grist += object.grist;
			this.lusus = object.lusus;
			this.minLuck += object.minLuck;
			this.currentHP += object.currentHP;
			this.hp += object.hp;
			this.mobility += object.mobility;
			this.maxLuck += object.maxLuck;
			this.freeWill += object.freeWill;
			this.power += object.power;
			this.illegal = object.illegal;
			this.minLuck += object.minLuck;
			this.minLuck += object.minLuck;
			this.minLuck += object.minLuck;
			this.player = object.player;
		}
	dynamic allStats(){
			return ["power","hp","RELATIONSHIPS","mobility","sanity","freeWill","maxLuck","minLuck","alchemy"];
		}
	bool willPlayerAbscond(div, player, players){
			var playersInFight = this.getLivingMinusAbsconded(players);
			if(!this.abscondable) return false;
			if(player.doomed) return false; //doomed players accept their fate.
			num reasonsToLeave = 0;
			num reasonsToStay = 2; //grist man.
			reasonsToStay += this.getFriendsFromList(playersInFight).length; // TODO: confirm?
			var hearts = this.getHearts();
			var diamonds = this.getDiamonds();
			for(num i = 0; i<hearts.length; i++){
				if(playersInFight.indexOf(hearts[i] != -1)) reasonsToStay ++;  //extra reason to stay if they are your quadrant.
			}
			for(num i = 0; i<diamonds.length; i++){
				if(playersInFight.indexOf(diamonds[i] != -1)) reasonsToStay ++;  //extra reason to stay if they are your quadrant.
			}
			reasonsToStay += player.power/this.getStat("currentHP"); //if i'm about to finish it off.
			reasonsToLeave += 2 * this.getStat("power")/player.getStat("currentHP");  //if you could kill me in two hits, that's one reason to leave. if you could kill me in one, that's two reasons.

			//print("reasons to stay: " + reasonsToStay + " reasons to leave: " + reasonsToLeave);
			if(reasonsToLeave > reasonsToStay * 2){
				player.sanity += -10;
				player.flipOut("how terrifying " + this.htmlTitle() + " was");
				if(player.mobility > this.mobility){
					//print(" player actually absconds: they had " + player.hp + " and enemy had " + enemy.getStat("power") + this.session.session_id)
					div.append("<br><img src = 'images/sceneIcons/abscond_icon.png'> The " + player.htmlTitleHP() + " absconds right the fuck out of this fight. ");
					this.playersAbsconded.add(player);
					this.remainingPlayersHateYou(div, player, playersInFight);
					return true;
				}else{
					div.append(" The " + player.htmlTitleHP() + " tries to absconds right the fuck out of this fight, but the " + this.htmlTitleHP() + " blocks them. Can't abscond, bro. ")
					return false;
				}
			}else if(reasonsToLeave > reasonsToStay){
				if(player.mobility > this.mobility){
					//print(" player actually absconds: " + this.session.session_id);
					div.append("<br><img src = 'images/sceneIcons/abscond_icon.png'>  Shit. The " + player.htmlTitleHP() + " doesn't know what to do. They don't want to die... They abscond. ");
					this.playersAbsconded.add(player);
					this.remainingPlayersHateYou(div, player, playersInFight);
					return true;
				}else{
					div.append(" Shit. The " + player.htmlTitleHP() + " doesn't know what to do. They don't want to die... Before they can decide whether or not to abscond " + this.htmlTitleHP() + " blocks their escape route. Can't abscond, bro. ")
					return false;
				}
			}
			return false;
		}
	dynamic remainingPlayersHateYou(div, player, players){
				if(players.length == 1){
					return null;
				}
				div.append(" The remaining players are not exactly happy to be abandoned. ");
				for(num i = 0; i<players.length; i++){
					var p = players[i];
					if(p != player && this.playersAbsconded.indexOf(p) == -1){ //don't be a hypocrite and hate them if you already ran.
						var r = p.getRelationshipWith(player);
						if(r) r.value += -5; //could be a sprite, after all.
					}
				}
				return null;
		}
	bool willIAbscond(div, players, numTurns){
				if(!this.canAbscond || numTurns < 2) return false; //can't even abscond. also, don't run away after starting the fight, asshole.
				num playerPower = 0;
				var living = this.getLivingMinusAbsconded(players);
				for(num i = 0; i<living.length; i++){
					playerPower += living[i].power;
				}
				//print("playerPower is: " + playerPower);
				if(playerPower > this.getStat("currentHP")*2){
						this.iAbscond = true;
						//print("absconding when turn number is: " +numTurns);
						return true;
				}
				return false;
		}
	void processAbscond(div, players){
			if(this.iAbscond){
				//print("game entity abscond: " + this.session.session_id);
				div.append("<Br><img src = 'images/sceneIcons/abscond_icon.png'> The " + this.htmlTitleHP() + " has had enough of this bullshit. They just fucking leave. ");
				return;
			}else{
				//print("players abscond: " + this.session.session_id);
				div.append("<Br><img src = 'images/sceneIcons/abscond_icon.png'> The strife is over due to a lack of player presence. ");
				return;
			}

		}
	void rocksFallEverybodyDies(div, players, numTurns){
			print("Rocks fall, everybody dies in session: " + this.session.session_id);
			div.append("<Br><Br> In case you forgot, freaking METEORS have been falling onto the battlefield this whole time. This battle has been going on for so long that, literally, rocks fall, everybody dies.  ");
			var living = findLivingPlayers(players); //dosn't matter if you absconded.
			var spacePlayer = findAspectPlayer(this.session.players, "Space");
			this.session.rocksFell = true;
			spacePlayer.landLevel = 0; //can't deploy a frog if skaia was just destroyed. my test session helpfully reminded me of this 'cause one of the players god tier revived adn then used the sick frog to combo session. ...that...shouldn't happen.
			for(num i = 0; i<living.length; i++){
				var p = living[i];
				p.makeDead("from terminal meteors to the face");
			}

		}
	void summonAuthor(div, players, numTurns){
			print("author is saving AB in session: " + this.session.session_id);
			var divID = (div.attr("id")) + "authorRocks"+players.join("");
			String canvasHTML = "<br><canvas id;='canvas" + divID+"' width='" +canvasWidth + "' height;="+canvasHeight + "'>  </canvas>";
			div.append(canvasHTML);
			//different format for canvas code
			var canvasDiv = querySelector("#canvas"+ divID);
			String chat = "";
			chat += "AB: " + Zalgo.generate("HELP!!!") +"\n";
			chat += "JR: Fuck!\n";
			chat += "JR: What's going on!? \n";
			chat += "JR: What's the problem!?\n";
			chat += "JR: AB come on...fuck! Your console is blank, I can't read your logs, you gotta talk to me!\n";

			chat += "AB: " + Zalgo.generate("INFINITE LOOP! STRIFE. IT KEEPS HAPPENING. FIX THIS.") +"\n";
			chat += "JR: fuck fuck fuck okay okay, i got this, i can fix this, let me turn on the meteors real quick.\n";
			chat += "JR: Okay. There. No more infinite loop. Everybody is dead. \n";
			chat += "AB: Fuck. Shit. I HATE when that happens.\n";
			chat += "JR: Yeah...\n";
			chat += "AB: Like, yeah, it fucking SUCKS for me, but...then the players have to die, too.\n";
			chat += "JR: That's why we're working so hard to balance the system. We'll get there, eventually. Scenes like this'll never trigger. Fights'll end naturally and not just go on forever if players find exploits. \n";
			chat += "AB: Yeah...'cause SBURB is just SO easy to balance. \n'";
			drawChatABJR(canvasDiv, chat);
			var living = this.getLivingMinusAbsconded(players);
			for(num i = 0; i<living.length; i++){
				var p = living[i];
				p.makeDead("causing dear sweet precious sweet, sweet AuthorBot to go into an infinite loop");
			}

		}
	void denizenIsSoNotPuttingUpWithYourShitAnyLonger(div, players, numTurns){
			//print("!!!!!!!!!!!!!!!!!denizen not putting up with your shit: " + this.session.session_id);
				div.append("<Br><Br>" + this.name + " decides that the " + players[0].htmlTitleBasic() + " is being a little baby who poops hard in their diapers and are in no way ready for this fight. The Denizen recommends that they come back after they mature a little bit. The " +players[0].htmlTitleBasic() + "'s ass is kicked so hard they are ejected from the fight, but are not killed.")
				if(seededRandom() > .5){ //players don't HAVE to take the advice after all. assholes.
					this.levelPlayers(players);
					div.append(" They actually seem to be taking " + this.name + "'s advice. ");
				}
		}
	dynamic summonPlayerBackup(div, players, numTurns){
				//if it's a time player/ 50/50 it's a future version of them in a stable time loop
				var living = findLivingPlayers(this.session.players); //who isn't ALREADY in this bullshit strife??? and is alive. and has a sprite (and so is in the medium.)
				var potential = getRandomElementFromArray(living);
				if(!potential) return players;
				if(players.indexOf(potential) == -1 && potential.sprite.name != "sprite"){ //you aren't already in the fight and aren't still on earth/alternaia/beforus/etc.
					if((potential.mobility > getAverageMobility(players) || seededRandom() >.5)){ //you're fast enough to get here, or randomness happened.

						players.push(potential);
						potential.currentHP = Math.max(1, potential.hp) ;//have at least 1 hp, dunkass;
						this.session.availablePlayers.removeFromArray(potential); //you aren't available anymore.
						var divID = (div.attr("id")) + "doomTimeArrival"+players.join("")+numTurns;
						String canvasHTML = "<br><canvas id;='canvas" + divID+"' width='" +canvasWidth + "' height;="+canvasHeight + "'>  </canvas>";
						div.append(canvasHTML);
						//different format for canvas code
						var canvasDiv = querySelector("#canvas"+ divID);
						if(potential.aspect == "Time" && seededRandom() > .50){
							drawTimeGears(canvasDiv, potential);
							//print("summoning a stable time loop player to this fight. " +this.session.session_id);
							div.append("The " + potential.htmlTitleHP() + " has joined the Strife!!! (Don't worry about the time bullshit, they have their stable time loops on LOCK. No doom for them.)");
						}else{
							//print("summoning a player to this fight. " +this.session.session_id);
							div.append("The " + potential.htmlTitleHP() + " has joined the Strife!!!");
						}

						drawSinglePlayer(canvasDiv, potential);
					}
				}

				return players;
		}
	void changeGrimDark(){
			//stubb
		}
	void summonMidnightCrew(div, player, numTurns){

		}
	void summonDoomedTimeClone(div, players, numTurns){
				//print("summoning a doomed time clone to this fight. " +this.session.session_id);
				var timePlayer = findAspectPlayer(this.session.players, "Time");
				var doomedTimeClone = makeDoomedSnapshot(timePlayer);
				players.push(doomedTimeClone);
				if(players.indexOf(timePlayer) !=-1){
					if(timePlayer.dead){
						var living = findLivingPlayers(this.session.players);
						if(living.length == 0){
							//rip knight of time that made me realize this could be a thing.
							div.append("<br><br>A " + doomedTimeClone.htmlTitleHP() + " suddenly warps in from an alternate timeline. They know that everyone is already dead. They know there is nothing they can do. They've tried already. They've tried so many times. They can't bring themselves to give up, but they can't force themselves to watch their friends die again, either. Maybe if they just learn how to kill this asshole, they can go back and do it RIGHT next time. ");
						}else{
							div.append("<br><br>A " + doomedTimeClone.htmlTitleHP() + " suddenly warps in from the future. They come with a dire warning of a doomed timeline. If they don't join this fight right the fuck now, shit gets real. They have sacrificed themselves to change the timeline. YOUR " + doomedTimeClone.htmlTitleBasic() + " is, well, I mean, obviously NOT fine, their corpse is just over there. But... whatever. THIS one is now doomed, as well. Which SHOULD mean they can fight like there is no tomorrow.")
						}

					}else{
						div.append("<br><br>A " + doomedTimeClone.htmlTitleHP() + " suddenly warps in from the future. They come with a dire warning of a doomed timeline. If they don't join this fight right the fuck now, shit gets real. They have sacrificed themselves to change the timeline. YOUR " + doomedTimeClone.htmlTitleBasic() + " is fine, I mean, obviously, they are right there...but THIS one is now doomed. Which SHOULD mean they can fight like there is no tomorrow.")
					}
				}else{
					div.append("<br><br>A " + doomedTimeClone.htmlTitleHP() + " suddenly warps in from the future. They come with a dire warning of a doomed timeline. If they don't join this fight right the fuck now, shit gets real. They have sacrificed themselves to change the timeline. YOUR " + doomedTimeClone.htmlTitleBasic() + " is fine, but THIS one is now doomed. Which SHOULD mean they can fight like there is no tomorrow.")
				}
				String divID = (div.attr("id")) + "doomTimeArrival"+players.join("")+numTurns;
				String canvasHTML = "<br><canvas id;='canvas" + divID+"' width='" +canvasWidth.toString() + "' height;="+canvasHeight.toString() + "'>  </canvas>";
				div.append(canvasHTML);
				//different format for canvas code
				var canvasDiv = querySelector("#canvas"+ divID);
				var pSpriteBuffer = getBufferCanvas(querySelector("#sprite_template"));
				drawTimeGears(pSpriteBuffer, doomedTimeClone);
				drawSinglePlayer(pSpriteBuffer, doomedTimeClone);
				copyTmpCanvasToRealCanvasAtPos(canvasDiv, pSpriteBuffer,0,0);
				timePlayer.doomedTimeClones.push(doomedTimeClone);
				timePlayer.sanity += -10;
				timePlayer.flipOut("their own doomed time clones");
				return players;

		}
	void summonAssHoleMcGee(div, players, numTurns){
			print("!!!!!!!!!!!!!!!!!This is stupid. Summon asshole mcgee in session: " + this.session.session_id);
			div.append("<Br><Br>THIS IS STuPID. EVERYBODY INVOLVED. IN THIS STuPID. STuPID FIGHT. IS NOW DEAD. SuCK IT.  tumut");
			var living = this.getLivingMinusAbsconded(players); //dosn't matter if you absconded.
			for(num i = 0; i<living.length; i++){
				var p = living[i];
				p.makeDead("BEING INVOLVED. IN A STuPID. STuPID FIGHT. THAT WENT ON. FOR WAY TOO LONG.");
			}

		}
	bool fightNeedsToEnd(div, players, numTurns){
			//if this IS a denizen fight, i can assume there is only one player in it
			if(players[0].denizen.name == this.name){
				if(numTurns>5 || (players[0].currentHP < this.getStat("power") && !players[0].godDestiny)){ //denizens are cool with killing players that will godtier.
				//	print("Denizen is fucking done after  " + numTurns +" turns " + this.session.session_id);
					this.denizenIsSoNotPuttingUpWithYourShitAnyLonger(div, players, numTurns);
					return true;
				}else if((players[0].currentHP < this.getStat("power") && players.godDestiny)){
					print("Denizen is fine with killing this player, because they will probably GodTier. " + this.session.session_id);
				}
				return false; //denizen fights can not be interupted and are self limiting
			}

			if(numTurns > 20 && seededRandom() < .05){
				this.summonAssHoleMcGee(div, players, numTurns);
				return true;
			}

			if(numTurns > 30){
				this.summonAuthor(div, players, numTurns);
				return true;
			}
			return false;

		}
	dynamic summonBackUp(div, players, numTurns){
			if(players[0].denizen.name == this.name){
				return players;
			}
			//if i assume a 3 turn fight is "ideal", then have a 1/10 chance of backup each turn.
			var rand =seededRandom();
			if(rand<.05){  //rand isn't great cause might not find  player to summon, or might try summon player already in fight.
				return this.summonPlayerBackup(div, players, numTurns); //will return modded player list;
			}else if(rand < .15 && numTurns >5){
				return this.summonDoomedTimeClone(div,players, numTurns);
			}
			return players;
		}
	void resetFraymotifs(){
			for(num i = 0; i<this.fraymotifs.length; i++){
				this.fraymotifs[i].usable = true;
			}
		}
	void resetEveryonesFraymotifs(players){
			this.resetFraymotifs();
			this.buffs = [];
			for(num i = 0; i<players.length; i++){
				players[i].buffs = [];
				players[i].resetFraymotifs();
			}
		}
	void resetPlayersAvailability(players){
			for(num i = 0; i<players.length; i++){
				players[i].usedFraymotifThisTurn = false;
			}
		}
	dynamic strife(div, players, numTurns){
			this.resetPlayersAvailability(players);
			if(numTurns == 0) div.append("<Br><img src = 'images/sceneIcons/strife_icon.png'>");
			numTurns += 1;
			if(this.name == "Black King" || this.name == "Black Queen"){
				//print("checking to see if rocks fall.");
				this.session.timeTillReckoning += -1; //other fights are a a single tick. maybe do this differently later. have fights be multi tick. but it wouldn't tick for everybody. laws of physics man.
				if(this.session.timeTillReckoning < this.session.reckoningEndsAt){
				  this.rocksFallEverybodyDies(div, players, numTurns);
					this.ending(div, players, numTurns);
					return null;
				}
			}

			if(this.fightNeedsToEnd(div, players, numTurns)){
				 this.ending(div,players, numTurns);
				 return null;
			}

			players = this.summonBackUp(div, players, numTurns);//might do nothing;
			//print(this.name + ": strife! " + numTurns + " turns against: " + getPlayersTitlesNoHTML(players) + this.session.session_id);
			div.append("<br><Br>");
			//as players die or mobility stat changes, might go players, me, me, players or something. double turns.
			if(getAverageMobility(players) > this.getStat("mobility")){ //players turn
				if(!this.fightOverAbscond(div, players) )this.playersTurn(div, players,numTurns);
				if(this.getStat("currentHP") > 0 && !this.fightOverAbscond(div, players)) this.myTurn(div, players,numTurns);
			}else{ //my turn
				if(this.getStat("currentHP") > 0 && !this.fightOverAbscond(div,players))  this.myTurn(div, players,numTurns);
				if(!this.fightOverAbscond(div, players) )this.playersTurn(div, players,numTurns);
			}

			if(this.fightOver(div, players) ){
				this.ending(div,players);
				return null;
			}else{
				if(this.fightOverAbscond(div,players)){
					 	this.processAbscond(div,players);
						this.ending(div,players);
					 	return null;
				}
				return this.strife(div, players,numTurns);
			}
		}
	bool fightOverAbscond(div, players){
			//print("checking if fight is over beause of abscond " + this.playersAbsconded.length);
			if(this.iAbscond){
				return true;
			}
			if(this.playersAbsconded.length == 0) return false;

			var living = findLivingPlayers(players);
			if(living.length == 0) return false;  //technically, they havent absconded
			for (num i = 0; i<living.length; i++){
				//print("has: " + living[i].title() + " run away?")
				if(this.playersAbsconded.indexOf(living[i]) == -1){
					return false; //found living player that hasn't yet absconded.
				}
			}
			return true;

		}
	void playersInteract(players){
			if(this.name == "Black Queen" || this.name == "Black King"){
				return; //whatever, when it's ALL the players too much is going on AND this won't effect things for very long. games over, man.
			}

				for(num i = 0; i<players.length; i++){
					var player1 = players[i];
					for(num j = 0; j < players.length; j ++){
						var player2 = players[j];
						if(player1 != player2){ //sorry time clones, can't buff your player. cause ALL players hae 'clones' in this double for loop
							player1.interactionEffect(player2); //opposite will happen eventually in this double loop.
						}
					}
				}
		}
	void poseAsATeam(div, players){
			//don't pose sprites
			List<dynamic> poseable = [];
			for(num i = 0; i<players.length; i++){
				if(players[i].renderable()) poseable.add(players[i]);
			}
			var divID = (div.attr("id")) + this.session.timeTillReckoning+players[0].id;
			var ch = canvasHeight;
			if(poseable.length > 6){
				ch = canvasHeight*1.5; //a little bigger than two rows, cause time clones
			}
			String canvasHTML = "<br><canvas id;='canvas" + divID+"' width='" +canvasWidth.toString() + "' height;="+ch.toString() + "'>  </canvas>";
			div.appendHtml(canvasHTML);
			//different format for canvas code
			var canvasDiv = querySelector("#canvas"+ divID);
			poseAsATeam(canvasDiv, poseable, 2000);

			if(players[0].dead && players[0].denizen.name == this.name) denizenKill(canvasDiv, players[0]);
		}
	void makeAlive(){
			if(this.dead == false) return; //don't do all this.
			this.dead = false;
			this.currentHP = this.hp;
		}
	void ending(div, players){
			this.resetEveryonesFraymotifs(players);

			this.iAbscond = false;
			this.playersInteract(players);
			this.healPlayers(div,players);


			this.playersAbsconded = [];
			this.poseAsATeam(div,players);
		}
	void healPlayers(div, players){
			for(num i = 0; i<players.length; i++){
				var player = players[i];
				if(!player.doomed &&  !player.dead && player.currentHP < player.hp) player.currentHP = player.hp;
			}
		}
	void levelPlayers(stabbings){
			for(num i = 0; i<stabbings.length; i++){
				stabbings[i].increasePower();
				stabbings[i].increasePower();
				stabbings[i].increasePower();
				stabbings[i].leveledTheHellUp = true;
				stabbings[i].level_index +=2;
			}
		}
	void minorLevelPlayers(stabbings){
			for(num i = 0; i<stabbings.length; i++){
				stabbings[i].increasePower();
			}
		}
	List<dynamic> getLivingMinusAbsconded(players){
			var living = findLivingPlayers(players);
			for(num i = 0; i<this.playersAbsconded.length; i++){
				removeFromArray(this.playersAbsconded[i], living);
			}
			return living;
		}
	bool fightOver(div, players){
			var living = this.getLivingMinusAbsconded(players);
			if(living.length == 0 && players.length > this.playersAbsconded.length){
				var dead = findDeadPlayers(players);
				if(dead.length == 1){
					div.append("<br><br><img src = 'images/sceneIcons/defeat_icon.png'> The strife is over. The " + dead[0].htmlTitle() + " is dead.<br> ");
				}else{
					div.append("<br><br><img src = 'images/sceneIcons/defeat_icon.png'> The strife is over. The players are dead or fled.<br> ");
				}

				this.minorLevelPlayers(players);
				return true;
			}else if(this.getStat("currentHP") <= 0 || this.dead){
				div.append(" <Br><br> <img src = 'images/sceneIcons/victory_icon.png'>The fight is over. " + this.name + " is dead. <br>");
				this.levelPlayers(players) //even corpses
				this.givePlayersGrist(players);
				return true;
			}//TODO have alternate win conditions for denizens???
			return false;
		}
	void givePlayersGrist(players){
			for(num i = 0; i<players.length; i++){
				players.grist += this.grist/players.length;
			}
		}
	void playersTurn(div, players){
			for(num i = 0; i<players.length; i++){  //check all players, abscond or living status can change.
				var player = players[i];
				///print("It is the " + player.titleBasic() + "'s turn. '");
				if(!player.dead && this.getStat("currentHP")>0 && this.playersAbsconded.indexOf(player) == -1){
					 this.playerdecideWhatToDo(div, player,players);  //
				}
			}

			var dead = findDeadPlayers(players);
			//give dead a chance to autoRevive
			for(num i = 0; i<dead.length; i++){
				if(!dead[i].doomed) this.tryAutoRevive(div, dead[i]);
			}
		}
	void tryAutoRevive(div, deadPlayer){

			//first try using pacts
			var undrainedPacts = removeDrainedGhostsFromPacts(deadPlayer.ghostPacts);
			if(undrainedPacts.length > 0){
				print("using a pact to autorevive in session " + this.session.session_id);
				var source = undrainedPacts[0][0];
				source.causeOfDrain = deadPlayer.title();
				String ret = " In the afterlife, the " + deadPlayer.htmlTitleBasic() +" reminds the " + source.htmlTitleBasic() + " of their promise of aid. The ghost agrees to donate their life force to return the " + deadPlayer.htmlTitleBasic() + " to life ";
				if(deadPlayer.godTier) ret += ", but not before a lot of grumbling and arguing about how the pact shouldn't even be VALID anymore since the player is fucking GODTIER, they are going to revive fucking ANYWAY. But yeah, MAYBE it'd be judged HEROIC or some shit. Fine, they agree to go into a ghost coma or whatever. ";
				ret += "It will be a while before the ghost recovers.";
				div.append(ret);
				var myGhost = this.session.afterLife.findClosesToRealSelf(deadPlayer);
				removeFromArray(myGhost, this.session.afterLife.ghosts);
				var canvas = drawReviveDead(div, deadPlayer, source, undrainedPacts[0][1]);
				deadPlayer.makeAlive();
				if(undrainedPacts[0][1] == "Life"){
					deadPlayer.hp += 100; //i won't let you die again.
				}else if(undrainedPacts[0][1] == "Doom"){
					deadPlayer.minLuck += 100; //you've fulfilled the prophecy. you are no longer doomed.
					div.append("The prophecy is fulfilled. ");
				}
			}else if((deadPlayer.aspect == "Doom" || deadPlayer.aspect == "Life")&& (deadPlayer.class_name == "Heir" || deadPlayer.class_name == "Thief")){
				var ghost = this.session.afterLife.findAnyUndrainedGhost();
				var myGhost = this.session.afterLife.findClosesToRealSelf(deadPlayer);
				if(!ghost || ghost == myGhost) return;
				ghost.causeOfDrain = deadPlayer.title();

				removeFromArray(myGhost, this.session.afterLife.ghosts);
				if(deadPlayer.class_name  == "Thief" ){
					print("thief autorevive in session " + this.session.session_id);
					div.append(" The " + deadPlayer.htmlTitleBasic() + " steals the essence of the " + ghost.htmlTitle() + " in order to revive and keep fighting. It will be a while before the ghost recovers.");
				}else if(deadPlayer.class_name  == "Heir" ){
					print("heir autorevive in session " + this.session.session_id);
					div.append(" The " + deadPlayer.htmlTitleBasic() + " inherits the essence and duties of the " + ghost.htmlTitle() + " in order to revive and continue their battle. It will be a while before the ghost recovers.");
				}
				var canvas = drawReviveDead(div, deadPlayer, ghost, deadPlayer.aspect);
				deadPlayer.makeAlive();
				if(deadPlayer.aspect == "Life"){
					deadPlayer.hp += 100; //i won't let you die again.
				}else if(deadPlayer.aspect == "Doom"){
					deadPlayer.minLuck += 100; //you've fulfilled the prophecy. you are no longer doomed.
					div.append("The prophecy is fulfilled. ");
				}
			}
		}
	bool playerHelpGhostRevive(div, player, players){
			if(player.aspect != "Life" && player.aspect != "Doom") return false;
			if(player.class_name != "Rogue" && player.class_name != "Maid") return false;
			var dead = findDeadPlayers(players);
			dead = this.removeAllNonPlayers(dead);
			if(dead.length == 0) return false;
			print(dead.length + " need be helping!!!");
			var deadPlayer = getRandomElementFromArray(dead) ;//heal random 'cause oldest could be doomed time clone';
			if(deadPlayer.doomed) return false; //doomed players can't be healed. sorry.
			//alright. I'm the right player. there's a dead player in this battle. now for the million boondollar question. is there an undrained ghost?
			var ghost = this.session.afterLife.findAnyUndrainedGhost(player);
			var myGhost = this.session.afterLife.findClosesToRealSelf(deadPlayer);
			if(!ghost || ghost == myGhost) return false;
			print("helping a corpse revive during a battle in session: " + this.session.session_id);
			ghost.causeOfDrain = deadPlayer.titleBasic();
			String text = "<Br><Br>The " + player.htmlTitleBasic() + " assists the " + deadPlayer.htmlTitleBasic() + ". ";
			if(player.class_name == "Rogue"){
				text += " The " + deadPlayer.htmlTitleBasic() + " steals the essence of the " + ghost.htmlTitleBasic() + " in order to revive and continue fighting. It will be a while before the ghost recovers.";
			}else if(player.class_name == "Maid"){
				text += " The " + deadPlayer.htmlTitleBasic() + " inherits the essence and duties of the " + ghost.htmlTitleBasic() + " in order to revive and continue their fight. It will be a while before the ghost recovers.";
			}
			div.append(text);
			var canvas = drawReviveDead(div, deadPlayer, ghost, player.aspect);
			if(canvas){
				var pSpriteBuffer = getBufferCanvas(querySelector("#sprite_template"));
				drawSprite(pSpriteBuffer,player);
				copyTmpCanvasToRealCanvasAtPos(canvas, pSpriteBuffer,0,0);
			}
			removeFromArray(myGhost, this.session.afterLife.ghosts);
			deadPlayer.makeAlive();
			if(player.aspect == "Life"){
				player.hp += 100; //i won't let you die again.
			}else if(player.aspect == "Doom"){
				player.minLuck += 100; //you've fulfilled the prophecy. you are no longer doomed.
				div.append("The prophecy is fulfilled. ");
			}
			return null;
		}
	void playerdecideWhatToDo(div, player, players){
			if(player.usedFraymotifThisTurn) return; //already did something.
			if(this.dead == true || this.getStat("currentHP") <= 0) return; // they are dead, stop beating a dead corpse.;
			div.append(player.describeBuffs());
			//for now, only one choice    //free will, triggerLevel and canIAbscond adn mobility all effect what is chosen here.  highTrigger level makes aggrieve way more likely and abscond way less likely. lowFreeWill makes special and fraymotif way less likely. mobility effects whether you try to abascond.
			if(!this.willPlayerAbscond(div,player,players)){
				var undrainedPacts = removeDrainedGhostsFromPacts(player.ghostPacts);
				if(this.playerHelpGhostRevive(div, player, players)){ //MOST players won't do this
					//actually, if that method returned true, it wrote to the screen all on it's own. so dumb. why can't i be consistent?
				}else if(undrainedPacts.length > 0 ){
					var didGhostAttack = this.ghostAttack(div, player, getRandomElementFromArray(undrainedPacts)[0]); //maybe later denizen can do ghost attac, but not for now
					if(!didGhostAttack && !this.useFraymotif(div, player, players, [this])){
						this.aggrieve(div, player, this );
					}
				}else if(!this.useFraymotif(div, player, players, [this])){
					this.aggrieve(div, player, this );
				}
			}
			this.processDeaths(div, players, [this]);
		}
	bool ghostAttack(div, player, ghost){
			if(!ghost) return false;
			if(player.power < this.getStat("currentHP")){
					//print("ghost attack in: " + this.session.session_id);

					this.currentHP += (-1* (ghost.power*5 + player.power)).round(); //not just one attack from the ghost
					div.append("<Br><Br> The " + player.htmlTitleBasic() + " cashes in their promise of aid. The ghost of the " + ghost.htmlTitleBasic() + " unleashes an unblockable ghostly attack channeled through the living player. " + ghost.power + " damage is done to " + this.htmlTitleHP() + ". The ghost will need to rest after this for awhile. " );

					this.drawGhostAttack(div, player, ghost);
					ghost.causeOfDrain = player.title();
					//this.processDeaths(div, player, this);
					return true;
			}
			return false;
		}
	dynamic drawGhostAttack(div, player, ghost){
			String canvasId = div.attr("id") + "attack" +player.chatHandle+ghost.chatHandle+player.power+ghost.power;
			String canvasHTML = "<br><canvas id='" + canvasId +"' width='" +canvasWidth.toString() + "' height="+canvasHeight.toString() + "'>  </canvas>";
			div.appendHtml(canvasHTML);
			var canvas = querySelector("#${canvasId}");
			var pSpriteBuffer = getBufferCanvas(querySelector("#sprite_template"));
			drawSprite(pSpriteBuffer,player);
			var gSpriteBuffer = getBufferCanvas(querySelector("#sprite_template"));
			drawSprite(gSpriteBuffer,ghost);
			//drawSpriteTurnways(gSpriteBuffer,ghost) //KR says looks bad.



			drawWhatever(canvas, "drain_lightning.png");

			copyTmpCanvasToRealCanvasAtPos(canvas, pSpriteBuffer,200,0);
			copyTmpCanvasToRealCanvasAtPos(canvas, gSpriteBuffer,250,0);
			var canvasBuffer = getBufferCanvas(querySelector("#canvas_template"));
			return canvas;
		}
	dynamic chooseTarget(players){
			//TODO more likely to get light, less likely to get void
			var living = this.getLivingMinusAbsconded(players);
			var doomed = findDoomedPlayers(living);

			var ret = getRandomElementFromArray(doomed);
			if(ret){
				//print("targeting a doomed player.");
				return ret;
			}
			//print("targeting slowest player out of: " + living.length);
			//todo more likely to target light, less void.
			ret = findAspectPlayer(players, "Light");
			//can attack light players corpse up to 5 times, randomly.
			if(ret && ret.dead && (seededRandom() > 5 || ret.currentHP < -1 * this.getStat("power")*5)) ret = null;  //only SOMETIMES target light player corpses. after all, that's SUPER lucky for the living.
			if(ret) return ret;
			return findLowestMobilityPlayer(living);
		}
	void myTurn(div, players, numTurns){
			//print("Hp during my turn is: " + this.getStat("currentHP"))
			//free will, triggerLevel and canIAbscond adn mobility all effect what is chosen here.  highTrigger level makes aggrieve way more likely and abscond way less likely. lowFreeWill makes special and fraymotif way less likely. mobility effects whether you try to abascond.
			//special and fraymotif can attack multiple enemies, but aggrieve is one on one.
			var living_enemies = this.getLivingMinusAbsconded(players);
			if(living_enemies.length == 0) return; //there is no one left to fight

            div.append(this.describeBuffs());

			if(!this.willIAbscond(div,players,numTurns) && !this.useFraymotif(div, this,[this], players)){
				var target = this.chooseTarget(players);
				if(target) this.aggrieve(div, this, target );
			}
			this.processDeaths(div, [this], players);
		}
	bool useFraymotif(div, owner, allies, enemies){
			var living_enemies = this.getLivingMinusAbsconded(enemies);
			var living_allies = this.getLivingMinusAbsconded(allies);
			if(seededRandom() > 0.75) return false; //don't use them all at once, dunkass.
			var usableFraymotifs = this.session.fraymotifCreator.getUsableFraymotifs(owner, living_allies, enemies);
			if(owner.crowned){  //ring/scepter has fraymotifs, too.  (maybe shouldn't let humans get thefraymotifs but what the fuck ever. roxyc could do voidy shit.)
				usableFraymotifs = usableFraymotifs.concat(this.session.fraymotifCreator.getUsableFraymotifs(this.crowned, living_allies, enemies));
			}
			if(usableFraymotifs.length == 0) return false;
			
			var mine = owner.getStat("sanity");
			var theirs = getAverageSanity(living_enemies);
			if(mine+200 < theirs && seededRandom() < 0.5){
				print("Too insane to use fraymotifs: " + owner.htmlTitleHP() +" against " + living_enemies[0].htmlTitleHP() + "Mine: " + mine + "Theirs: " + theirs + " in session: " + this.session.session_id)
				div.append(" The " + owner.htmlTitleHP() + " wants to use a Fraymotif, but they are too crazy to focus. ")
				return false;
			}
			mine = owner.getStat("freeWill") ;
			theirs = getAverageFreeWill(living_enemies);
			if(mine +200 < theirs && seededRandom() < 0.5){
				print("Too controlled to use fraymotifs: " + owner.htmlTitleHP() +" against " + living_enemies[0].htmlTitleHP() + "Mine: " + mine + "Theirs: " + theirs + " in session: " + this.session.session_id)
				div.append(" The " + owner.htmlTitleHP() + " wants to use a Fraymotif, but Fate dictates otherwise. ")
				return false;
			}
			
			var chosen = usableFraymotifs[0];
			for(num i = 0; i<usableFraymotifs.length; i++){
				var f = usableFraymotifs[i];
				if(f.tier > chosen.tier){
					chosen = f; //more stronger is more better (refance)
				}else if(f.tier == chosen.tier && f.aspects.length > chosen.aspects.length){
					chosen = f; //all else equal, prefer the one with more members.
				}
			}
			
			
			
			div.append("<Br><br>"+chosen.useFraymotif(owner, living_allies, living_enemies) + "<br><Br>");
			chosen.usable = false;
			return true;
		}
	void aggrieve(div, offense, defense){
			//mobility, luck hp, and power are used here.
			String ret = "<br><Br> The " + offense.htmlTitleHP() + " targets the " +defense.htmlTitleHP() + ". ";
			if(defense.dead) ret += " Apparently their corpse sure is distracting? How luuuuuuuucky for the remaining players!";
			div.append(ret);

			//luck dodge
			//alert("offense roll is: " + offenseRoll + " and defense roll is: " + defenseRoll);
			//print("gonna roll for luck.");
			if(defense.rollForLuck("minLuck") > offense.rollForLuck("minLuck")*10+200){ //adding 10 to try to keep it happening constantly at low levels
				print("Luck counter: " +  defense.htmlTitleHP() + this.session.session_id);
				div.append("The attack backfires and causes unlucky damage. The " + defense.htmlTitleHP() + " sure is lucky!!!!!!!!" );
				offense.currentHP += -1* offense.getStat("power")/10; //damaged by your own power.
				//this.processDeaths(div, offense, defense);
				return;
			}else if(defense.rollForLuck("maxLuck") > offense.rollForLuck("maxLuck")*5+100){
				print("Luck dodge: " +   defense.htmlTitleHP() +this.session.session_id);
				div.append("The attack misses completely after an unlucky distraction.");
				return;
			}
			//mobility dodge
			var rand = getRandomInt(1,100) ;//don't dodge EVERY time. oh god, infinite boss fights. on average, fumble a dodge every 4 turns.;
			if(defense.getStat("mobility") > offense.getStat("mobility") * 10+200 && rand > 25){
				print("Mobility counter: " +   defense.htmlTitleHP() +this.session.session_id);
				ret = ("The " + offense.htmlTitleHP() + " practically appears to be standing still as they clumsily lunge towards the " + defense.htmlTitleHP()  );
				if(defense.getStat("currentHP")> 0 ){
					ret += ". They miss so hard the " + defense.htmlTitleHP() + " has plenty of time to get a counterattack in.";
					offense.currentHP += -1* defense.getStat("power");
				}else{
					ret += ". They miss pretty damn hard. ";
				}
				div.append(ret + " ");
				//this.processDeaths(div, offense, defense);

				return;
			}else if(defense.getStat("mobility") > offense.getStat("mobility")*5+100 && rand > 25){
				print("Mobility dodge: " +   defense.htmlTitleHP() +this.session.session_id);
				div.append(" The " + defense.htmlTitleHP() + " dodges the attack completely. ");
				return;
			}
			//base damage
			var hit = offense.getStat("power");
			num offenseRoll = offense.rollForLuck();
			num defenseRoll = defense.rollForLuck();
			//critical/glancing hit odds.
			if(defenseRoll > offenseRoll*2){ //glancing blow.
				//print("Glancing Hit: " + this.session.session_id);
				hit = hit/2;
				div.append(" The attack manages to not hit anything too vital. ");
			}else if(offenseRoll > defenseRoll*2){
				//print("Critical hit.");
				////print("Critical Hit: " + this.session.session_id);
				hit = hit*2;
				div.append(" Ouch. That's gonna leave a mark. ");
			}else{
				//print("a hit.");
				div.append(" A hit! ");
			}


			defense.currentHP += -1* hit;
			//this.processDeaths(div, offense, defense);
		}
	void processDeaths(div, offense, defense){
			List<dynamic> dead_o = [];
			List<dynamic> dead_d = [];
			for(num i = 0; i<offense.length; i++){
				var o = offense[i];
					if(!o.dead){  //if you are already dead, don't bother.
						for(var j= 0; j<defense.length; j++){
							var d = defense[j];
							if(!d.dead){
								var o_alive = this.checkForAPulse(o,d);
								o.interactionEffect(d);
								if(!this.checkForAPulse(d, o)){
									dead_d.add(d);
								}
								if(!this.checkForAPulse(o, d)){
									dead_o.add(o);
								}
							}
						}
				}
			}
			String ret = "";
			if(dead_o.length > 1){
				ret = " The " + getPlayersTitlesHP(dead_o) + "are dead. ";
			}else if(dead_o.length == 1){
				ret += " The " + getPlayersTitlesHP(dead_o) + "is dead. ";
			}

			if(dead_d.length > 1){
				ret = " The " + getPlayersTitlesHP(dead_d) + "are dead. ";
			}else if(dead_d.length == 1){
				if(dead_d[0].getStat("currentHP") > 0) window.alert("pastJR: why does a player have positive hp yet also is dead???" + this.session.session_id)
				ret += " The " + getPlayersTitlesHP(dead_d) + "is dead. ";
			}

			div.append(ret);
		}
	dynamic htmlTitleBasic(){
				return this.name;
		}
	void getRelationshipWith(){
			//stub for boss fights where an asshole absconds.
		}
	void makeDead(causeOfDeath){
			this.dead = true;
			this.causeOfDeath = causeOfDeath;
		}
	bool checkForAPulse(player, attacker){
			if(player.getStat("currentHP") <= 0){
				//print("Checking hp to see if" + player.htmlTitleHP() +"  is  dead");
				String cod = "fighting the " + attacker.htmlTitle();
				if(this.name == "Jack"){
					cod =  "after being shown too many stabs from Jack";
				}else if(this.name == "Black King"){

					cod = "fighting the Black King";
				}
				player.makeDead(cod);
				//print("Returning that " + player.htmlTitleHP() +"  is  dead");
				return false;
			}
			//print("Returning that " + player.htmlTitleHP() +"  is not dead");
			return true;
		}
	void interactionEffect(player){
			//none
		}
	dynamic rollForLuck(stat){
        		if(!stat){
        		    return getRandomInt(this.getStat("minLuck"), this.getStat("maxLuck"));
        		}else{
        		    //don't care if it's min or max, just compare it to zero.
        		    return getRandomInt(0, this.getStat(stat));
        		}

        }
	void boostAllRelationshipsWithMeBy(amount){

		}
	void boostAllRelationshipsBy(amount){

		}
	List<dynamic> getFriendsFromList(list){
			return [];
		}
	List<dynamic> getHearts(){
			return [];
		}
	List<dynamic> getDiamonds(){
			return [];
		}




}



//maybe it's a player. maybe it's game entity. whatever. copy it.
//take name explicitly 'cause plaeyrs don't have one
dynamic copyGameEntity(object, name){
	var ret = new GameEntity(object.session, name, null);
	ret.corrupted = object.corrupted;
	ret.helpPhrase = object.helpPhrase;
	ret.helpfulness = object.helpfulness; //completely overridden.
	ret.grist = object.grist;
	ret.minLuck = object.minLuck;
	ret.currentHP = object.currentHP;
	ret.hp = object.hp;
	ret.mobility = object.mobility;
	ret.maxLuck = object.maxLuck;
	ret.freeWill = object.freeWill;
	ret.power = object.power;
	ret.illegal = object.illegal;
	ret.minLuck = object.minLuck;
	ret.minLuck = object.minLuck;
	ret.minLuck = object.minLuck;
	ret.player = object.player;
	ret.lusus = object.lusus;
	//idea, custom 'help string'. stretch goal for later. would let me have players help in different ways than a pomeranian would, for example.
	return ret;
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//																												 //
//																												 //
//		AND NOW IT'S TIME TO MAKE A SHIT TON OF GAME ENTITITES TO POSSIBLY SHOVE INTO SPRITES		             //
//																												 //
//																												 //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/*
sooooo...things that go in sprites are gameEntities. Just like jack/Queen/King. And Denizens. Keep. Keep thinking about this.
*/


//make a fuck ton of sprites here. don't need to reinit for sessions because these entitites are never used directly. instead, stuck into a sprite that player has,
//or into ring/scepter.
//an objects stats are zero unless otherwise stated.
//don't bother allocating memory for objects, just leave in array.



//seperate 'cause of witches and bad luck and good luck
//DinceJof -  you prototype your kernel sprite with the ashes of your ancestor. They used to be a SBURB player like you, until they took a scratch to the timeline.
var disastor_objects =[
	new GameEntity(null, "First Guardian",null)  //also a custom fraymotif.
		..hp = 1000
		..currentHP = 1000
		..mobility = 500
		..power = 250
		..helpPhrase = "is fairly helpful with the teleporting and all, but when it speaks- Wow. No. That is not ok. "
		..fraymotifs.add( new Fraymotif([], "Atomic Teleport Spam", 3)
			..effects.add(new FraymotifEffect("mobility",0,false))
			..effects.add(new FraymotifEffect("mobility",2,true))
			..flavorText = " The OWNER shimers with radioactive stars, and then teleports behind the ENEMY, sneak-attacking them. "),


	new GameEntity(null, "Horror Terror",null)  //vast glub
		..hp = 500
		..currentHP = 500
		..corrupted = true  //gives the corrupted status to whoever wears the ring, and the sprite, too. fighting corruption corrupts you.
		..power = 150
		..lusus = true
		..freeWill = 250 //wants to mind control you.
		..helpPhrase = "... Oh god. What is going on. Why does just listening to it make your ears bleed!? "
		..fraymotifs.add( new Fraymotif([],"Vast Glub", 3)
			..effects.add(new FraymotifEffect("freeWill",3,true))
			..flavorText = " A galaxy spanning glub damages everyone. The only hope of survival is to spread the damage across so many enemies that everyone only takes a manageable amount. "),


	new GameEntity(null, "Speaker of the Furthest Ring",null)  //vast glub
		..hp = 1000
		..currentHP = 1000
		..corrupted = true
		..power = 250
		..freeWill = 500 //wants to mind control you.
		..helpPhrase = "whispers madness humankind was not meant to know. Its words are painful, hateful, yet… tempting. It speaks of flames and void, screams and gods. "
		..fraymotifs.add( new Fraymotif([],"Vast Glub", 3)
			..effects.add(new FraymotifEffect("freeWill",3,true))
			..flavorText = " A galaxy spanning glub damages everyone. The only hope of survival is to spread the damage across so many enemies that everyone only takes a manageable amount. "),


	new GameEntity(null, "Clown",null)  //custom fraymotif: can' keep down the clown (heal).
		..hp = 1000
		..currentHP = 1000
		..power = 100
		..minLuck = -250 //unpredictable
		..maxLuck = 250
		..helpfulness = -1
		..helpPhrase = "goes hehehehehehehehehehehehehehehehehehehehehehehehehehe. "
		..fraymotifs.add( new Fraymotif([], "Hee Hee Hee Hoo!", 3)
			..effects.add(new FraymotifEffect("sanity",3,false))
			..effects.add(new FraymotifEffect("sanity",3,true))
			..flavorText = " Oh god! Shut up! Just once! Please shut up! "),


	new GameEntity(null, "Puppet",null)
		..hp = 500
		..helpPhrase =  "is the most unhelpful piece of shit in the world. Oh my god, just once. Please, just shut up. "
		..currentHP = 500
		..helpfulness = -1
		..power = 100
		..sanity = -250 //unpredictable
		..freeWill = 250 //wants to mind control you.
		..mobility = 250
		..minLuck = -250
		..maxLuck = 250
		..fraymotifs.add( new Fraymotif([], "Hee Hee Hee Hoo!", 3)
			..effects.add(new FraymotifEffect("sanity",3,false))
			..effects.add(new FraymotifEffect("sanity",3,true))
			..flavorText = " Oh god! Shut up! Just once! Please shut up! "),


	new GameEntity(null, "Xenomorph",null)  //custom fraymotif: acid blood
		..hp = 500
		..currentHP = 500
		..power = 100
		..mobility = 250
		..fraymotifs.add( new Fraymotif([], "Spawning", 3)
			..effects.add(new FraymotifEffect("alchemy",3,true))
			..flavorText = " Oh god. Where are all those baby monsters coming from. They are everywhere! Fuck! How are they so good at biting??? "),


	new GameEntity(null, "Deadpool",null)  //custom fraymotif: healing factor
		..hp = 500
		..currentHP = 500
		..power = 100
		..mobility = 250
		..helpfulness = 1
		..minLuck = -250
		..maxLuck = 250
		..helpPhrase = "demonstrates that when it comes to providing fourth wall breaking advice to getting through quests and killing baddies, he is pretty much the best there is. "
		..fraymotifs.add( new Fraymotif([],  "Degenerate Regeneration", 3)
			..effects.add(new FraymotifEffect("hp",0,true))
			..flavorText = " Hey there, Observer! Want to see a neat trick? POW! Grew my own head back. Pretty cool, huh? (Now if only JR would let me spam this or make it be castable even while dead, THEN we'd be cooking with petrol) "),


	new GameEntity(null, "Dragon",null)  //custom fraymotif: mighty breath.
		..hp = 500
		..lusus = true
		..currentHP = 500
		..power = 100
		..helpPhrase = "breathes fire and offers condescending, yet useful advice. "
		..fraymotifs.add( new Fraymotif([],  "Mighty Fire Breath", 3)
			..effects.add(new FraymotifEffect("power",3,true))
			..flavorText = " With a mighty breath, OWNER spits all the fires, sick and otherwise."),


	new GameEntity(null, "Teacher",null)
		..hp = 500
		..currentHP = 500
		..power = 100
		..helpfulness = -1
		..helpPhrase = "dials the sprites natural tendency towards witholding information to have you 'figure it out yourself' up to eleven. "
		..fraymotifs.add( new Fraymotif([],  "Lecture", 3)
			..effects.add(new FraymotifEffect("freeWill",3,false))
			..effects.add(new FraymotifEffect("sanity",3,false))
			..flavorText = " OWNER begins a 3 part lecture on why you should probably just give up. It is hypnotic in it's ceaselessness."),


	new GameEntity(null, "Fiduspawn",null)
		..hp = 500
		..currentHP = 500
		..power = 100
		..fraymotifs.add( new Fraymotif([],  "Spawning", 3)
			..effects.add(new FraymotifEffect("alchemy",3,true))
			..flavorText = " Oh god. Where are all those baby monsters coming from. They are everywhere! Fuck! How are they so good at biting??? "),


	new GameEntity(null, "Doll",null)
		..hp = 500
		..currentHP = 500
		..power = 100
		..helpfulness = -1
		..helpPhrase = "stares creepily. It never moves when you're watching it. It's basically the worst, and that's all there is to say on that topic. "
		..fraymotifs.add( new Fraymotif([],  "Disconcerting Ogle", 3)
			..effects.add(new FraymotifEffect("sanity",3,false))
			..effects.add(new FraymotifEffect("sanity",0,true))
			..flavorText = " OWNER is staring at ENEMY. It makes you uncomfortable, the way they are just standing there. And watching.  "),


	new GameEntity(null, "Zombie",null)
		..hp = 500
		..currentHP = 500
		..power = 100
		..fraymotifs.add( new Fraymotif([],  "Rise From The Grave", 3)
			..effects.add(new FraymotifEffect("hp",0,true))
			..flavorText = " You thought the OWNER was pretty hurt, but instead they are just getting going. "),


	new GameEntity(null, "Demon",null)
		..hp = 500
		..currentHP = 500
		..power = 250
		..freeWill = 250 //wants to mind control you.
		..fraymotifs.add( new Fraymotif([],  "Claw Claw MotherFuckers", 3)
			..effects.add(new FraymotifEffect("power",2,true))
			..effects.add(new FraymotifEffect("power",2,true))
			..flavorText = " The OWNER slashes at the ENEMY twice. "),


	new GameEntity(null, "Monster",null)
		..hp = 500
		..currentHP = 500
		..power = 100 //generically scary
		..sanity = -250
		..fraymotifs.add( new Fraymotif([],  "Claw Claw MotherFuckers", 3)
			..effects.add(new FraymotifEffect("power",2,true))
			..effects.add(new FraymotifEffect("power",2,true))
			..flavorText = " The OWNER slashes at the ENEMY twice. "),


	new GameEntity(null, "Vampire",null)
		..hp = 500
		..currentHP = 500
		..power = 250
		..mobility = 100 //vampire fastness
		..fraymotifs.add( new Fraymotif([],  "I Vant to Drink Your Blood", 3)
			..effects.add(new FraymotifEffect("hp",2,true))
			..effects.add(new FraymotifEffect("hp",0,true))//damage you, heal self.
			..flavorText = " The OWNER drains HP from the ENEMY. "),


	new GameEntity(null, "Pumpkin",null)
		..power = 100
		..maxLuck = 5000
		..mobility = 5000  //what pumpkin?
		..helpPhrase = "was kind of helpful, and then kind of didn’t exist. Please don’t think too hard about it, the simulation is barely handling a pumpkin sprite as is. "
		..fraymotifs.add( new Fraymotif([],  "What Pumpkin???", 3)
			..effects.add(new FraymotifEffect("mobility",2,false))
			..effects.add(new FraymotifEffect("mobility",3,true))
			..flavorText = " Everyone tries to hit the OWNER until suddenly they have never been there at all, causing attacks to miss so catastrophically they backfire. "),


	new GameEntity(null, "Werewolf",null)
		..hp = 500
		..currentHP = 500
		..power = 100
		..sanity = -250
		..fraymotifs.add( new Fraymotif([],  "Grim Bark Slash Attack", 3)
			..effects.add(new FraymotifEffect("power",2,true))
			..effects.add(new FraymotifEffect("power",2,true))
			..flavorText = " The OWNER slashes at the ENEMY twice. While being a werewolf. "),


	new GameEntity(null, "Monkey",null)  //just, fuck monkeys in general.
		..hp = 5
		..currentHP = 5
		..power = 100
		..helpfulness = -1
		..maxLuck = -5000  //fuck monkeys
		..minLuck = -5000
		..mobility = 5000
		..helpPhrase = "actively inteferes with quests. Just. Fuck monkeys. "
		..fraymotifs.add( new Fraymotif([],  "Monkey Business", 3)
			..effects.add(new FraymotifEffect("mobility",0,false))
			..effects.add(new FraymotifEffect("mobility",2,true))
			..flavorText = " The OWNER uses their monkey like fastness to attack the ENEMY just way too fucking many times. "),
];


//fortune
var fortune_objects =[
	new GameEntity(null, "Frog",null)
		..power = 20
		..illegal = true
		..mobility = 100
		..helpPhrase = "provides the requisite amount of gigglesnort  hideytalk to be fairly useful, AND the underlings seem to go after it first! Bonus! ",


	new GameEntity(null, "Lizard",null)
		..power = 20
		..illegal = true
		..helpPhrase = "provides the requisite amount of gigglesnort  hideytalk to be fairly useful, AND the underlings seem to go after it first! Bonus! ",


	new GameEntity(null, "Salamander",null)
		..power = 20
		..illegal = true
		..helpPhrase = "provides the requisite amount of gigglesnort  hideytalk to be fairly useful, AND the underlings seem to go after it first! Bonus! ",


	new GameEntity(null, "Iguana",null)
		..power = 20
		..illegal = true
		..helpPhrase = "provides the requisite amount of gigglesnort  hideytalk to be fairly useful, AND the underlings seem to go after it first! Bonus! ",


	new GameEntity(null, "Crocodile",null)
		..power = 50
		..illegal = true
		..helpPhrase = "provides the requisite amount of gigglesnort  hideytalk to be fairly useful, AND the underlings seem to go after it first! Bonus! ",


	new GameEntity(null, "Turtle",null)
		..power = 20
		..illegal = true
		..mobility = -100
		..helpPhrase = "provides the requisite amount of gigglesnort  hideytalk to be fairly useful, AND the underlings seem to go after it first! Bonus! ",


	new GameEntity(null, "Alligator",null)
		..power = 50
		..illegal = true
		..helpPhrase = "provides the requisite amount of gigglesnort  hideytalk to be fairly useful, AND the underlings seem to go after it first! Bonus! ",


	new GameEntity(null, "Snake",null)  //poison fraymotif
		..power = 50
		..armless = true
		..illegal = true
		..helpPhrase = "providessss the requisssssite amount of gigglessssssnort hideytalk to be jusssssst barely helpful. AND the underlings seem to go after it first! Bonus! ",


	new GameEntity(null, "Axolotl",null)  //apparently real ones are good at regeneration?
		..power = 20
		..hp =  50
		..currentHP = 50
		..illegal = true
		..helpPhrase = "provides the requisite amount of gigglesnort  hideytalk to be fairly useful, AND the underlings seem to go after it first! Bonus! ",


	new GameEntity(null, "Newt",null)
		..power = 20
		..illegal = true
		..helpPhrase = "provides the requisite amount of gigglesnort  hideytalk to be fairly useful, AND the underlings seem to go after it first! Bonus! ",

];


//////////////////////lusii are a little stronger in general
List<dynamic> lusus_objects = [
	new GameEntity(null, "Hoofbeast",null)
		..power = 30
		..lusus = true,


	new GameEntity(null, "Meow Beast",null)
		..power = 30
		..lusus = true
		..minLuck = 20
		..maxLuck = 20
		..helpPhrase = "is kind of helpful? Maybe? You can't tell if it loves their player or hates them. ",


	new GameEntity(null, "Bark Beast",null)
		..power = 40
		..lusus = true
		..helpPhrase = "alternates between loud, insistent barks and long, eloquent monologues on the deeper meaning behind each and every fragment of the game. ",


	new GameEntity(null, "Nut Creature",null)
		..power = 30
		..mobility = 30
		..lusus = true,


	new GameEntity(null, "Gobblefiend",null)
		..power = 50 //turkeys are honestly terrifying.
		..lusus = true
		..helpfulness = -1
		..helpPhrase = "is the most unhelpful piece of shit in the world. Oh my god, just once. Please, just shut up. ",


	new GameEntity(null, "Bicyclops",null)  //laser fraymotif?
		..power = 30
		..lusus = true,


	new GameEntity(null, "Centaur",null)
		..power = 50
		..sanity = 50 //lusii in the butler genus simply are unflappable.
		..lusus = true,


	new GameEntity(null, "Fairy Bull",null)
		..power = 1 //kinda useless. like a small dog or something.
		..lusus = true,


	new GameEntity(null, "Slither Beast",null)
		..power = 30
		..lusus = true
		..armless = true,


	new GameEntity(null, "Wiggle Beast",null)
		..power = 30
		..lusus = true,


	new GameEntity(null, "Honkbird",null)
		..power = 30
		..lusus = true,


	new GameEntity(null, "Dig Beast",null)
		..power = 30
		..lusus = true,


	new GameEntity(null, "Cholerbear",null)
		..power = 50
		..lusus = true,


	new GameEntity(null, "Antler Beast",null)
		..power = 30
		..mobility = 30
		..lusus = true,


	new GameEntity(null, "Ram Beast",null)
		..power = 30
		..lusus = true,


	new GameEntity(null, "Crab",null)
		..power = 30
		..lusus = true,


	new GameEntity(null, "Spider",null)
		..power = 30
		..lusus = true,


	new GameEntity(null, "Thief Beast",null)
		..power = 30
		..lusus = true,


	new GameEntity(null, "March Bug",null)
		..power = 30
		..lusus = true,


	new GameEntity(null, "Nibble Vermin",null)
		..power = 30
		..lusus = true,


	new GameEntity(null, "Woolbeast",null)
		..power = 30
		..lusus = true,


	new GameEntity(null, "Hop Beast",null)
		..power = 30
		..maxLuck = 30
		..lusus = true,


	new GameEntity(null, "Stink Creature",null)
		..power = 30
		..lusus = true,


	new GameEntity(null, "Speed Beast",null)
		..power = 30
		..mobility = 50
		..lusus = true,


	new GameEntity(null, "Jump Creature",null)
		..power = 30
		..lusus = true,


	new GameEntity(null, "Fight Beast",null)
		..power = 50
		..lusus = true,


	new GameEntity(null, "Claw Beast",null)
		..power = 50
		..lusus = true,


	new GameEntity(null, "Tooth Beast",null)
		..power = 50
		..lusus = true,


	new GameEntity(null, "Armor Beast",null)
		..power = 30
		..currentHP = 100
		..hp = 100
		..lusus = true,


	new GameEntity(null, "Trap Beast",null)
		..power = 30
		..lusus = true,
];

////////////////////////sea lusii

List<dynamic> sea_lusus_objects = [
	new GameEntity(null, "Zap Beast",null)  //zap fraymotif
		..power = 50
		..lusus = true,


	new GameEntity(null, "Sea Slither Beast",null)
		..power = 30
		..lusus = true
		..armless = true,


	new GameEntity(null, "Electric Beast",null)  //zap fraymotif
		..power = 50
		..lusus = true
		..armless = true,


	new GameEntity(null, "Whale",null)
		..power = 30
		..currentHP = 50
		..hp = 50
		..lusus = true
		..armless = true,


	new GameEntity(null, "Sky Horse",null)
		..power = 30
		..mobility = 20
		..lusus = true,


	new GameEntity(null, "Sea Meow Beast",null)
		..power = 30
		..lusus = true
		..minLuck = -20
		..maxLuck = 20,


	new GameEntity(null, "Sea Hoofbeast",null)
		..power = 30
		..lusus = true,


	new GameEntity(null, "Cuttlefish",null)
		..power = 30
		..lusus = true,


	new GameEntity(null, "Swim Beast",null)
		..power = 30
		..lusus = true,


	new GameEntity(null, "Sea Goat",null)
		..power = 30
		..lusus = true
		..minLuck = 30
		..maxLuck = 20,


	new GameEntity(null, "Light Beast",null)
		..power = 30
		..lusus = true,


	new GameEntity(null, "Dive Beast",null)
		..power = 30
		..lusus = true,


	new GameEntity(null, "Honkbird",null)
		..power = 30
		..lusus = true,


	new GameEntity(null, "Sea Bear",null)
		..power = 30
		..lusus = true,


	new GameEntity(null, "Sea Armorbeast",null)
		..power = 30
		..lusus = true
		..currentHP = 50
		..hp = 50,
];

//regular
List<dynamic> prototyping_objects = [
	new GameEntity(null, "Buggy As Fuck Retro Game",null)
		..power = 20
		..corrupted = true  //no stats, just corrupted. maybe a fraymotif later.
		..helpPhrase = "provides painful, painful sound file malfunctions, why is this even a thing? ",


	new GameEntity(null, "Robot",null)
		..hp = 100
		..currentHP = 100
		..helpfulness = 1
		..helpPhrase = "is <b>more</b> useful than another player. How could a mere human measure up to the awesome logical capabilities of a machine? "
		..freeWill = 100
		..power = 100,


	new GameEntity(null, "Golfer",null)
		..power = 20
		..helpfulness = 1
		..minLuck = 20
		..maxLuck = 20
		..helpPhrase = "provides surprisingly helpful advice, even if they do insist on calling all enemies ‘bogeys’. ",


	new GameEntity(null, "Dutton",null)
		..hp = 10
		..currentHP = 10
		..power = 10
		..helpfulness = 1
		..helpPhrase = "provides transcendent wisdom. "
		..freeWill = 50
		..mobility = 50
		..minLuck = 50
		..maxLuck = 50
		..fraymotifs.add( new Fraymotif([], "Duttobliteration", 2)
			..effects.add(new FraymotifEffect("freeWill",2,true))
			..flavorText = " The ENEMY is obliterated. Probably. A watermark of Charles Dutton appears, stage right. "),

	new GameEntity(null, "Game Bro",null)
		..power = 20
		..helpfulness = 1
		..helpPhrase = "provides rad as fuck tips and tricks for beating SBURB and getting mad snacks, yo. 5 out of 5 hats. ",


	//in joke, lol, google always reports that sessions are crashed. google is a horror terror (see tumblr)
	new GameEntity(null, "Google",null)
		..power = 20
		..helpfulness = 1
		..corrupted = true
		..helpPhrase = "sure knows a lot about everything, but why does it only seem to return results about crashing SBURB?",


	new GameEntity(null, "Game Grl",null)
		..power = 20
		..helpfulness = 1
		..helpPhrase = "provides rad as fuck tips and tricks for beating SBURB and getting mad snacks, yo, but, like, while also being a GIRL? *record scratch*  5 out of 5 lady hats. ",


	new GameEntity(null, "Paperclip",null)
		..power = 20
		..helpfulness = -1
		..helpPhrase = "says: 'It looks like you're trying to play a cosmic game where you breed frogs to create a universe. Would you like me to'-No. 'Would you like me to'-No! 'It looks like you're'-shut up!!! This is not helpful.",


	new GameEntity(null, "WebComicCreator",null)
		..power = 20
		..helpfulness = -1
		..helpPhrase = "refuses to explain anything about SBURB to you, prefering to let you speculate wildly while cackling to himself."
		..fraymotifs.add( new Fraymotif([], "Kill ALL The Characters", 2)
			..effects.add(new FraymotifEffect("freeWill",3,true))
			..flavorText = " All enemies are obliterated. Probably. A watermark of Andrew Hussie appears, stage right. "),


	new GameEntity(null, "KidRock",null)
		..power = 20
		..helpfulness = -1
		..helpPhrase = "does absolutly nothing but sing repetitive, late 90's rock to you."
		..fraymotifs.add( new Fraymotif([], "BANG DA DANG DIGGY DIGGY", 2)
			..effects.add(new FraymotifEffect("power",3,true))  //buffs party and hurts enemies
			..effects.add(new FraymotifEffect("power",1,false))
			..flavorText = " OWNER plays a 90s hit classic, and you can't help but tap your feet. Somehow, this doesn't feel like the true version of this attack."),


	new GameEntity(null, "Sleuth",null)
		..power = 20
		..helpfulness = -1
		..helpPhrase = "suggests the player just input a password to skip all their land's weird puzzle shit. This is not actually a thing you can do."
		..fraymotifs.add( new Fraymotif([], "Sepulchritude", 2)
			..effects.add(new FraymotifEffect("RELATIONSHIPS",1,true))
			..flavorText = " The OWNER decides not to bring that noise just yet. They just heal the party instead. ")
		..fraymotifs.add( new Fraymotif([], "Sepulchritude", 2)
			..effects.add(new FraymotifEffect("RELATIONSHIPS",1,true))
			..flavorText = " THE OWNER just don't have the offensive gravitas for that attack. They just heal the party instead. ")
		..fraymotifs.add( new Fraymotif([], "Sepulchritude", 2)
			..effects.add(new FraymotifEffect("RELATIONSHIPS",3,true))
			..flavorText = " The OWNER finally fucking unleashes their Ultimate Attack. The resplendent light of divine PULCHRITUDE consumes all enemies. ")
		..fraymotifs.add( new Fraymotif([], "Sepulchritude", 2)
			..effects.add(new FraymotifEffect("RELATIONSHIPS",1,true))
			..flavorText = " No, not yet! The OWNER refuses to use Sepulchritude. They just heal the party instead. "),


	new GameEntity(null, "Nick Cage",null)
		..power = 20
		..helpfulness = 1
		..helpPhrase = "demonstrates that when it comes to solving bullshit riddles to get National *cough* I mean SBURBian treasure, he is simply the best there is. ",


	new GameEntity(null, "Praying Mantis",null)
		..power = 20
		..maxLuck = 20,


	new GameEntity(null, "Shitty Comic Character",null)
		..power = 20
		..mobility = 50
		..helpfulness = -1
		..helpPhrase = " is the STAR. It is them. You don't think they have ever once attempted to even talk about the game. How HIGH did you have to BE to prototype this glitchy piece of shit? "
		..fraymotifs.add( new Fraymotif([],"FUCK IM FALLING DOWN ALL THESE STAIRS", 3)
			..effects.add(new FraymotifEffect("mobility",1,false)) //buff to mobility bro
			..flavorText = " It keeps hapening. ")
		..fraymotifs.add( new Fraymotif([],"FUCK IM FALLING DOWN ALL THESE STAIRS", 3)
			..effects.add(new FraymotifEffect("mobility",1,false))
			..flavorText = " I warned you about stairs bro!!! ")
		..fraymotifs.add( new Fraymotif([],"FUCK IM FALLING DOWN ALL THESE STAIRS", 3)
			..effects.add(new FraymotifEffect("mobility",1,false))
			..flavorText = " I told you dog! "),


	new GameEntity(null, "Doctor",null)  //healing fraymotif
		..power = 20
		..helpfulness = 1
		..helpPhrase = "is pretty much as useful as another player. No cagey riddles, just straight answers on how to finish the quests. ",


	new GameEntity(null, "Gerbil",null)
		..power = 20
		..helpfulness = 1
		..helpPhrase = "remains physically adorable and mentally idiotic. Gigglysnort hideytalk ahoy. ",


	new GameEntity(null, "Chinchilla",null)
		..power = 20
		..helpfulness = 1
		..helpPhrase = "remains physically adorable and mentally idiotic. Gigglysnort hideytalk ahoy. ",


	new GameEntity(null, "Rabbit",null)
		..power = 20
		..maxLuck = 100
		..helpPhrase = "remains physically adorable and mentally idiotic. Gigglysnort hideytalk ahoy. ",


	new GameEntity(null, "Tissue",null)
		..helpfulness = -1
		..helpPhrase = "is useless in every possible way. ",


	new GameEntity(null, "Librarian",null)
		..power = 20
		..helpfulness = 1
		..helpPhrase = "Is pretty much as useful as another player. No cagey riddles, just straight answers on where the book on how to finish the quest is, and could you please keep it down? ",


	new GameEntity(null, "Pit Bull",null)
		..power = 50,


	new GameEntity(null, "Butler",null)
		..power = 50  //he will serve you like a man on butler island
		..helpfulness = 1
		..helpPhrase = "is serving their player like a dude on butlersprite island. "
		..sanity = 50,


	new GameEntity(null, "Sloth",null)
		..power = 20
		..mobility = -50
		..helpPhrase = "provides. Slow. But. Useful. Advice.",


	new GameEntity(null, "Cowboy",null)
		..power = 20
		..helpfulness = 1
		..helpPhrase = "provides useful advice, even if they do insist on calling literally everyone 'pardner.' ",


	new GameEntity(null, "Pomeranian",null)
		..power = 1 //pomeranians aren't actually very good at fights.  (trust me, i know)
		..helpfulness = -1
		..helpPhrase = "unhelpfully insists that every rock is probably a boss fight (it isn’t). ",


	new GameEntity(null, "Chihuahua",null)
		..power = 1  //i'm extrapolating here, but I imagine Chihuahua's aren't very good at fights, either.
		..helpfulness = -1
		..helpPhrase = "unhelpfully insists that every rock is probably a boss fight (it isn’t). ",


	new GameEntity(null, "Pony",null)
		..power = 20
		..helpfulness = -1
		..sanity = -1000  //ponyPals taught me that ponys are just flipping their shit, like, 100% of the time.
		..helpPhrase = "is constantly flipping their fucking shit instead of being useful in any way shape or form, as ponies are known for. ",


	new GameEntity(null, "Horse",null)
		..power = 20
		..helpfulness = -1
		..sanity = -100  //probably flip out less than ponys???
		..helpPhrase = "is constantly flipping their fucking shit instead of being useful in any way shape or form, as horses are known for. ",


	new GameEntity(null, "Internet Troll",null)  //needs to have a fraymotif called "u mad, bro" and "butt hurt"
		..power = 20
		..helpfulness = -1
		..sanity = 1000
		..helpPhrase = "actively does its best to hinder their efforts. ",


	new GameEntity(null, "Mosquito",null)
		..power = 20
		..helpfulness = -1
		..helpPhrase = "is a complete dick, buzzing and fussing and biting. What's its deal? ",


	new GameEntity(null, "Fly",null)
		..power = 20
		..helpfulness = -1
		..helpPhrase = "is a complete dick, buzzing and fussing and biting. What's its deal? ",


	new GameEntity(null, "Cow",null)
		..power = 30, //cows kill more people a year than sharks.


	new GameEntity(null, "Bird",null)
		..power = 20
		..mobility = 20
		..helpPhrase = "provides sort of helpful advice when not grabbing random objects to make nests. ",


	new GameEntity(null, "Bug",null)
		..power = 20
		..helpPhrase = "provides the requisite amount of buzzybuz zuzytalk to be juuuust barely helpful. ",


	new GameEntity(null, "Llama",null)
		..power = 20,


	new GameEntity(null, "Penguin",null)
		..power = 20,


	new GameEntity(null, "Husky",null)
		..power = 30
		..helpPhrase = "alternates between loud, insistent barks and long, eloquent monologues on the deeper meaning behind each and every fragment of the game. ",


	new GameEntity(null, "Cat",null)
		..power = 20
		..minLuck = -20
		..maxLuck = 20
		..helpPhrase = "Is kind of helpful? Maybe? You can't tell if it loves their player or hates them. ",


	new GameEntity(null, "Dog",null)
		..power = 30
		..helpPhrase = "alternates between loud, insistent barks and long, eloquent monologues on the deeper meaning behind each and every fragment of the game. ",


	new GameEntity(null, "Pigeon",null)
		..power = 0.5  //pigeons are not famous for their combat prowess. I bet even a pomeranian could beat one up.
		..freeWill = -40,


	new GameEntity(null, "Octopus",null)
		..power = 20
		..mobility = 80, //so many legs! more legs is more faster!!!


	new GameEntity(null, "Fish",null)
		..power = 20
		..armless = true,


	new GameEntity(null, "Kitten",null)
		..power = 20
		..helpPhrase = "is kind of helpful? Maybe? You can't tell if it loves their player or hates them. ",


	new GameEntity(null, "Worm",null)
		..power = 20
		..armless = true,


	new GameEntity(null, "Bear",null)
		..power = 50,


	new GameEntity(null, "Goat",null)
		..power = 20,


	new GameEntity(null, "Rat",null)
		..power = 20,


	new GameEntity(null, "Raccoon",null)
		..power = 20
		..helpfulness = 1
		..helpPhrase = "demonstrates that SBURB basically hides quest items in the same places humans would throw away their garbage. ",


	new GameEntity(null, "Crow",null)
		..power = 20
		..freeWill = 20 //have you ever tried to convince a crow not to do something? not gonna happen.
		..helpPhrase = "provides sort of helpful advice when not grabbing random objects to make nests. ",


	new GameEntity(null, "Chicken",null)
		..power = 20
		..freeWill = -20,  //mike the headless chicken has convinced me that chickens don't really need brains. god that takes me back.


	new GameEntity(null, "Duck",null)
		..power = 20,


	new GameEntity(null, "Sparrow",null)
		..power = 20,


	new GameEntity(null, "Fancy Santa",null)
		..power = 20
		..helpfulness = -1
		..helpPhrase = "goes hohohohohohohohoho. ",


	new GameEntity(null, "Politician",null)
		..power = 20
		..helpfulness = -1
		..helpPhrase = "offers a blueprint for an ECONONY that works for everyone. That would've been more useful before the earth was destroyed.... ",


	new GameEntity(null, "Tiger",null)
		..power = 50
		..helpPhrase = "Provides just enough pants-shitingly terrifying growly-roar meow talk to be useful. ",


	new GameEntity(null, "Sugar Glider",null)
		..power = 20
		..helpPhrase = "remains physically adorable and mentally idiotic. Gigglysnort hideytalk ahoy. ",


	new GameEntity(null, "Rapper",null)
		..power = 20
		..helpfulness = 1
		..helpPhrase = "provides surprisingly helpful advice, even if it does insist on some frankly antiquated slang and rhymes. I mean, civilization is dead, there isn’t exactly a police left to fuck. ",


	new GameEntity(null, "Kangaroo",null)
		..power = 30
		..mobility = 30,


	new GameEntity(null, "Stoner",null)
		..power = 42.0 //blaze it
		..minLuck = -42.0
		..maxLuck = 42.0
		..helpfulness = 1
		..helpPhrase = "is pretty much as useful as another player, assuming that player was higher then a fucking kite. ",

]
..addAll(disastor_objects)
..addAll(fortune_objects)
..addAll(lusus_objects)
..addAll(sea_lusus_objects); //yes, a human absolutely could prototype some troll's lusus. that is a thing that is true.
