var charCreatorHelperGlobalVar;
var playersGlobalVar = [];
var easterEggEngineGlobalVar;
var simulationMode  = false;
var teamsGlobalVar = [];
//for whole tournament
var mvpName = ""
var mvpScore = ""
var lastTeamIndex = -2; //each round starts at index + 2
var tierNumber = 0; //starts at zero before fight, then at 1.
window.onload = function() {
	$(this).scrollTop(0);
	loadNavbar();
	simulationMode = true; //dont' render graphics.
	displayPotentialFighters();
	numSimulationsToDo = 10;
	makeDescriptionList();
}

//hide the teams and button. randomize the teams and reDescribe them to show new order.
//render AB in center, facing left team.
//then, render first team on left of AB, and second team on right of AB.
//then, pass first team to AB (upgrade her to have 'url params' from var as well as actual window location.)
//number to simulate is 10.
//when each session is done, need to call a callback in this file instead of printSTats or whatever (minor AB upgrade)
//callback should note if win (+1 to displayed score), or if grimDark crash (-1 to displayed score, AB flashes corrupt red.)  should also pass MVP value and title (wanna keep track of.)
//when done, callback to this page so it knows to start next team. AB faces right. repeat.
//when both teams done, compare scores, show winner, and strikethrough loser.
//queue up next 2.
//when done, erase all losers, and start again with new teams (teamsGlobalVar should be object[], not string[])
function startTournament(){
	tierNumber ++;
	lastTeamIndex = -2;
	$("#teams").hide();
	$("#roundTitle").css('display', 'inline-block');
	$("#team1").css('display', 'inline-block');
	$("#ab").css('display', 'inline-block');
	$("#team2").css('display', 'inline-block');
	//render team 1 and team2
	teamsGlobalVar = shuffle(teamsGlobalVar); //if these were svgs, could be animated???
	makeDescriptionList();
	displayTeams($("#description"+tierNumber));
	$("#tournamentButtonDiv").hide();
	startRound();
}

function makeDescriptionList(){
	var divHTML = "<div id = 'description"+tierNumber +  "'></div>"
	$("#descriptions").append(divHTML);
	$("#description"+(tierNumber-1)).hide(); //only current is shown.
}

function startRound(){
	lastTeamIndex += 2;
	if(lastTeamIndex >= teamsGlobalVar.length) return doneWithTier();
	var team1 = teamsGlobalVar[lastTeamIndex]
	var team2 = teamsGlobalVar[lastTeamIndex+1]  //if no team 2, they win???
	if(team2 == null) return doneWithRound();
	var team1Title = "<h1 id = 'team1Title'>"+ team1 + "</h1>";
	var team2Title =  "<h1 id = 'team2Title'>"+ team2 + "</h1>";
	$("#roundTitle").html(team1Title +" vs " + team2Title);
	renderTeam(team1, $("#team1"));
	renderTeam(team2, $("#team2"));
	clearTeam($("#team1"))
	clearTeam($("#team2"))
	abLeft();
	fight();
}


function doneWithRound(){
	var team1 = teamsGlobalVar[lastTeamIndex]
	var team2 = teamsGlobalVar[lastTeamIndex+1]
	if(!team2) return doneWithTier();
	if(team1.score() > team2.score()){
		team2.lostRound = true;
	}else if(team1.score() < team2.score()){
		team1.lostRound = true;
	}else{
		team1.lostRound = false;
		team2.lostRound = false; //tie.
	}

	if(team1.lostRound){
		var listDiv = $("#"+team1.name+tierNumber)
		var roundDiv = $("#team1")
		markLoser(listDiv)
		markLoser(roundDiv)
	}
	if(team2.lostRound){
		var listDiv = $("#"+team2.name+tierNumber)
		var roundDiv = $("#team2")
		markLoser(listDiv)
		markLoser(roundDiv)
	}
	//start up next two players.
	//if not even one more player, do "doneWithTier"
	startRound();
}


function clearTeam(teamDiv){
	teamDiv.css('background-color', "white");
	teamDiv.css("text-decoration", "none;")
}

function markLoser(loser){
	console.log("marking loser")
	console.log(loser);
	loser.css('background-color', "grey");
	loser.css("text-decoration", "overline;")
}

function doneWithTier(){
	//remove all losers. clear out all "wonRounds" rerender Combatants. start round up with lastTeamIndex of 0.
	alert("ready for round " + (tierNumber+1) + "?")
	removeLosers();
	startTournament();
}

function removeLosers(){
	var toRemove = [];
	for(var i = 0; i<teamsGlobalVar.length; i++){
		var team  = teamsGlobalVar[i];
		if(team.lostRound){
			toRemove.push(team);
		}
		team.resetStats(); //<--otherwise will think they are done nxt round casue already did 10 sessions.
	}
	for(var i = 0; i<toRemove.length; i++){
		teamsGlobalVar.removeFromArray(toRemove[i]);
	}
}

function fight(){
	$("#story").html("")
	initial_seed = getRandomSeed(); //pick a random session
	Math.seed = initial_seed;
	var team = teamsGlobalVar[lastTeamIndex]
	if(team.numberSessions >= numSimulationsToDo){
			team = teamsGlobalVar[lastTeamIndex+1];
			console.log("switiching teams in fight")
	}
	console.log("number of sessions for team: " + team + " is " + team.numberSessions)

	if(team.numberSessions >= numSimulationsToDo) return doneWithRound();
	//var team2 = teamsGlobalVar[lastTeamIndex+1]  //if no team 2, they win???
	var selfInsert = "";
	if(!isClassOrAspectStuck(team)) selfInsert = "&selfInsertOC=true"
	simulatedParamsGlobalVar = team.name + "=true"+selfInsert; //which session are we checking?
	startSession(aBCallBack);
}

//don't add selfInsertOC to claspect stuck
function isClassOrAspectStuck(team){
	var stuck = team.name.split("Stuck");
	return stuck.length == 2;
}

//what will happen if scratch? Will it return here still?
//need to make sure scratched sessions don't count. (they get stat boost after all)
function aBCallBack(sessionSummary){
	console.log(sessionSummary)
	var team = teamsGlobalVar[lastTeamIndex]
	var teamNum = 1;
	if(team.numberSessions >= numSimulationsToDo){
		console.log("switching to team 2 in callback")
		teamNum = 2;
		team = teamsGlobalVar[lastTeamIndex+1];
		abRight();
	}else{
		abLeft();
	}
	team.numberSessions ++;
	if(sessionSummary.won) team.win ++;
	if(sessionSummary.crashedFromPlayerActions){
		 team.crash ++;
		//grim dark ab turnways if 1
		if(teamNum == 1){
			abLeft(true);
		}else{
			abRight(true);
		}
	}else{
		if(teamNum == 1){
			abLeft();
		}else{
			abRight();
		}
	}
	if(sessionSummary.mvp.power > team.mvp_score){
		team.mvp_name = sessionSummary.mvp.htmlTitle();
		team.mvp_score = sessionSummary.mvp.power;
	}

	if(team.mvp_score > mvpScore){
		mvpScore = team.mvp_score;
		mvpName = team.mvp_name;
	}
	renderTeam(team, $("#team"+teamNum));
	renderGlobalMVP();
	fight();

}

function renderGlobalMVP(){
	$("#globalMVP").html("Overall MVP:  " + mvpName + " with a power of: " + mvpScore +"<br>");
}

function abLeft(glitch){
	if(glitch){
		$("#avatar").attr("src", "images/guide_bot_turnways_glitch.gif");
	}else{
		$("#avatar").attr("src", "images/guide_bot_turnways.png");
	}

	$("#team1Title").css("color", "red");
	$("#team2Title").css("color", "black");
}

function abRight(glitch){
	if(glitch){
		$("#avatar").attr("src", "images/guide_bot_glitch.gif");
	}else{
		$("#avatar").attr("src", "images/guide_bot.png");
	}

	$("#team2Title").css("color", "red");
	$("#team1Title").css("color", "black");
}

function renderTeam(team, div){
	var num = "# of Sessions: " + team.numberSessions
	var win = "<br># of Won Sessions: " + team.win
	var crash = "<br> # of GrimDark Crash Sessions: " + team.crash
	var score = "<br><h1>Score:  " + team.score() + "</h1><hr>";
	var mvp = "<br>MVP:  " + team.mvp_name + " with a power of: " + team.mvp_score;
	if(team.lostRound){
		div.css("text-decoration", "overline;")
	}
	div.html("<div class = 'scoreBoard'>" + score + num + win + crash + mvp + "</div>")
	$("#score_" + team.name+tierNumber).html("Score: " + team.score());
}


//all selected tiers will render example chars and a text explanation.handle up to ALL chosen.
//KnightStuck: randomly generated players that are forced to be Knights only.
//IF use rare session finder, will have to have params ALSO able to come internally, not just from url
//fighters chosen become a "bracket"
//do i want symbols for teams?
function displayPotentialFighters(){
	//tiers are EXACTLY the same name as the param, so can generate a "URL" of the right format, for AB to check.
	var fanTeams = ["reddit","tumblr","discord","creditsBuckaroos","ideasWranglers","patrons","patrons2","patrons3","canon","otherFandoms","creators"];
	var classTeams = ["KnightStuck", "SeerStuck","BardStuck","HeirStuck","MaidStuck","RogueStuck","PageStuck","ThiefStuck","SylphStuck","PrinceStuck","WitchStuck","MageStuck"];
	var aspectTeams = ["BloodStuck", "MindStuck","RageStuck","VoidStuck","TimeStuck","HeartStuck","BreathStuck","LightStuck","SpaceStuck","HopeStuck","LifeStuck","DoomStuck"];
	var teams = fanTeams.concat(classTeams);
	teams = teams.concat(aspectTeams);
	var html = "<b>Choose Combatants!</b><Br><select multiple size = '" + teams.length + "' id = 'tiers' name='tier'>";
	for(var i = 0; i< teams.length; i++){
			html += '<option value="' + teams[i] +'">' + teams[i]+'</option>'
	}
	html += '</select>'
	$("#teams").append(html);
	wireUpTeamSelector();
}

function wireUpTeamSelector(){
	$("#teams").change(function() {
		teamsGlobalVar = [];
		$('#teams :selected').each(function(i, selected){
			teamsGlobalVar.push(new Team($(selected).text()));
		});
		displayTeams($("#description"+tierNumber));
		$("#tournamentButtonDiv").css('display', 'inline-block');
	});

}

//oncoe tournament starts, div should be unique for that tier
function displayTeams(div){
	//when teams are displayed, also make sure button to start tournament is displayed. Hides team selector, shows AB in middle, with current fighters on either sidebar
	//points go up with each won session, AB glitches red with each grim dark crash and a point is lost.
	//loser is crossed off from team description, and next pair go.
	var html = "";

	for(var i = 0; i < teamsGlobalVar.length; i++){
		html +=displayTeamInList(teamsGlobalVar[i]);
	}
	div.html(html);
	
}

function displayTeamInList(team){
	var html = "";
	var divStart = "<div id = '" +team.name + tierNumber+"' class = 'teamDescription'>";
	var divEnd = "</div>";
	html += divStart + getTeamDescription(team) + divEnd;
	return html;
}

//when tournament starts up, drop down is set to none, and this is left most thing.
function getTeamDescription(team){
	console.log("~~~~~~~~~~~~~~~~~~TODO~~~~~~~~~~~~~~~ have icon for each category.");
	var stuck = team.name.split("Stuck");
	if(stuck.length == 2) return "<h1>" +stuck[0] +"Stuck</h1> <div id = 'score_" + team.name + tierNumber +"'></div><hr> A random team of only  " + stuck[0] + " Players. (With Time/Space guaranteed)"

	return "<h1>" + team + "</h1><div id = 'score_" + team.name + tierNumber+"'></div> <hr>Players chosen randomly from the " + team + " fan OCs";

}


function Team(name){
	this.name = name;
	this.numberSessions = 0;
	this.win = 0;
	this.numTotalPartyWipe = 0; //only stat ABJ cares about.
	this.crash = 0;
	this.mvp_name = "";
	this.mvp_score = 0;
	this.lostRound = false; //set to true if they lost.  cause them to render different.
	
	this.resetStats = function(){
		this.numberSessions = 0;
		this.win = 0;
		this.numTotalPartyWipe = 0;
		this.crash = 0;
		this.mvp_name = ""
		this.mvp_score = 0;
		this.lostRound = false;
	}
	
	this.score = function(){
		return this.win - this.crash;
	}
	
	this.scoreABJ = function(){
		this.numTotalPartyWipe;
	}

	this.toString = function(){
		return this.name;
	}
}
