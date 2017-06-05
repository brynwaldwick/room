# Presented as a loose schema
# Looking to get the story together and the mechanics

winner_message = "You win! Thank you for playing Room. We hope you'll play again. Say 'sign me up' to sign up for notifications about new chapters. Say 'share on [social_network]' to tell your friends about Room. Welcome back! Until next time..."

module.exports = Story = {
Room:
    inspect: "You are in a room. You see the #Butler's boot as he leaves through the door. You hear a key turn and some burly laughter from outside. A pile of smashed and rotted vegetables sits in a corner. There is a #girl on the floor inscribed in a pool of #blood. \n
        On one wall a #window looks out towards a spindly garden. On one wall is an old wooden #table. On yet another wall is that #door that has already been mentioned."
    Butler:
        inspect: "He has already gone out the #door. He was wearing some painfully expensive shoe but that is all you could see through your stupor."
        talk_to: "He has already gone out the door. You spend a few moments talking to the door; nothing happens."
    Table:
        inspect: "The table is hefty and made from oak. Hewn by the titans of old no doubt. There is a stack of 11 #papers and 3 colored #pens arranged randomly as if somebody just left them there. There is no puzzle here, short of allegory."
        Pens: 'There is a red, green, and blue pen. The green ink is slightly more used than both the others.'
        Papers: "Most are blank. Some have pixel-like boxes, some have more organic shapes. The most prolific are those made of connections and the spaces between them. There is some kind of progression but it's difficult to discern any order."
        pick_up: "It's too heavy."
        move: "It's too heavy."
    Knife:
        inspect: "The knife sits coldly beside the girl's face. The top of the blade is wiped completely clean. The bottom looks to be encrusted in blood."
        pick_up: "You hastily grab the knife. A drop of blood on the handle makes you feel sick and your eyes swim. You stab your thumb shoving it into your pocket and a warm red ribbon splashes onto your pants. Fuck. It's not actually that bad, don't worry."
    Blood: "The blood is tacky and it’s turning brown. She has been dead or dying here for some time now."
    Hair: "Her hair is blonde and looks like something you could use to braid a rope to heaven."
    Dress: "The dress is blue with a white bow."
    Necklace: "The fang of a snake held with silver metal and leather against her neck. The tooth presses against her."
    Mouth: "She's wearing black lipstick. It looks too eager and a bit out of place."
    Shoes: "Felt buckles and finely polished leather. Kate Spade or something asinine thing like that."
    Book: "Something by an author that nobody has ever heard of. 'A Depiction of Worth in Spite of Modern Philosophy'. Sounds like it's a bit much, honestly."
    Girl:
        inspect: "Her name tag says Mary. She’s wearing a blue #dress with a white bow and a tight #necklace. There is a #book under her hand. There were polka dots on her kerchief but it is faded with wear and they are barely visible now. Dried blood is caked in her satin blonde #hair."
        pick_up: "That’s weird."
        move: "You find a tattered love #note covered in blood under the body. The contents are very personal and won't add much to the narrative other than pain."
        # TODO: access rule from context.body_moved
        Note: {
            inspect: "It reads 'You never loved me. I never loved myself. It’s too hard to decide which one of us did this'. Some love note, sounds like a terrible situation."
            pick_up: "You put it into your pocket. You cut your hand on the knife and blood pours onto your pants."
        }
    Window:
        inspect: "Birch panes and brittle blown glass. There is a spindly #garden outside. A #forest stands as an ominous backdrop. A whisper of #smoke from a distant fire floats through the canopy. Mountains. As you approach the window, the #chicken that was busy pecking at the house's foundation screams and runs towards the forest."
        open: "It’s locked"
        Chicken: "The chicken utters profanity and waddles into the forest."
        Forest: "If you look past the trees and try to really grasp it you're likely to see nothing at all."
        Garden: "It's very spindly."
        Smoke: "Signals of some missing connection - passed, past, or otherwise."
    Door:
        state: 'closed'
        inspect: 'White paint is spread across the door in angry strokes. The words are mildly chilling, mostly ambiguous. "Turn back."'
        open: (context) ->
            if context.room_door == 'open'
                return "It's open. There is a ~Hallway outside."
            else
                context.room_door = 'open'
                return "The door opens. There is a ~Hallway outside."
    Hallway:
        inspect: (context) ->
            if context.room_door == 'open'
                return "A crimson red carpet sweeps to the right in a velvet braid."
            else
                return "You cannot see anything through the closed door."
    Egg:
        smash: (context) ->
            if context.egg
                return "#{ENDING}"
            else
                return "Easter came earlier than expected this year."
    neighbors:
        Hallway: (context) ->
            if context.room_door == 'open'
                context.location = 'Hallway'
                return "You walk into the Hallway. #{Story.Hallway.inspect}"
            else
                return 'You cannot go through the closed door.'
Hallway:
    inspect: 'It stretches away from you. There is a #door along the right side and a #door far ahead of you. There is a vague notion of #stairs going up and to the left. A #painting hangs on the wall opposite the #near_door. \n
        A #gargoyle sits on a pedestal in a location that is not relevant. He chuckles quietly with a gravel pitch and clears his throat with anticipation. "The Butler did it, you know" he delivers in a jaunty grunt. "Not really mate, but I found myself unable to resist the irony."'
    Painting:
        inspect: "There is a painting on the wall. Mountains paint a rogue wave as a backdrop. A #dragon curls with an ugly grace over tiny #King_Arther and his horse. Fire screams across the canvas, and a #chicken in the background walks clumsily towards an old logging #road. A blue dress and various other maiden garments are hung in terse rows outside a hut made of lincoln logs in the distance."
        Dragon: "It doesn't actually look the way a real dragon does but the artist certainly put worthy effort into the details. Its neck and back are a slate roof, the scales interwoven gracefully. The burst of fire from his mouth caresses the trees in the distance. Admittedly the perspective is a bit off but the emotion of the scene makes up for it. His eyes gaze longingly towards the #chicken."
        Road: "It looks like what you think a logging road looks like in your mind right now. Two deep ruts with dried grass waving in the wind between them. It curves seductively around the hillside, towards a happier scene, no doubt."
        "King Arthur": "King Arthur is overmatched today but on balance he is a good guy. He will push valiantly towards whichever new challenge dares to rear its head. What is it all for you wonder? People have been asking the chicken that for years and nobody has ever found themselves any kind of satisfying answer, on this side or the next."
        Chicken: "Does there have to be a reason for everything? She sets her eyes on the road ahead of her and lets the seduction of the unknown distance compell her forward."
    Gargoyle:
        inspect: "The @gargoyle has seen better days. Its nose crumbles from the crawl and repeat of decades. It has three horns and carries shadows of old faces. It also carries a #picture of a something..."
        pick_up: "It shakes you away with a gruff expletive. It appears far too heavy to actually hold anyway."
        Picture:
            inspect: "It is a Polaroid of a raven and a girl. A flurry of activity in the background suggests a chicken was at one point framed - with head and alive - in the shot."
            pick_up: "The Gargoyle protests mightily"
            take: "The Gargoyle protests mightily"
        is_character: true
        triggers:
            fall: (context) ->
                context.gargoyle.dead = true
                context.hallway_key = true
                "The gargoyle howls with rage and wobbles towards you. His eyes catch on fire as he falls off the table and his stone base cracks, revealing a golden key. You pick up the key. The gargoyle makes one last sickening sound and lays silent."
    Stairs:
        inspect: "A path towards a dark attic. Cobwebs give you that creepy feeling. The door is profoundly locked and it's pretty dark."
    "Near Door":
        inspect: "It's locked. A modern keyhole looks out of place in this ancient house."
        unlock: (context) ->
            if context.hallway_key
                context.hallway_door = 'unlocked'
                "You push the key into the lock and it turns with a satisfying 'tssk-sflrt'. Seems like it was recently installed."
            else
                "You don't have the key."

        open: (context) ->
                
            if context.hallway_door == 'unlocked'
                context.hallway_door = 'open'
                "The door swings open. The Butler is standing alone in a tiny room holding an antique pistol. He shoots you in the face for being an asshole to the gargoyle. You are dead."
            else
                "It is locked."
    "Far Door":
        inspect: "It's locked. There is a keypad above the handle. The digits 1 through 5 shine out through green LEDs."
        try_code: "The LEDs blink red. The gargoyle says some hilarious discouraging shit."
        open: (context) ->
            if context.hallway_far_door == 'open'
                "It's open. A stone path curls up the hill towards the ~garden."
            else
                context.hallway_far_door = 'open'
                "The door swings open. A stone path curls up the hill towards the ~garden."
    Door: "The #near_door or the #far_door?"
    neighbors:
        Garden: (context) ->
            context.location = 'Garden'
            return "You take the brief stroll towards the garden. #{Story.Garden.inspect}"
        Room: (context) ->
            context.location = 'Room'
            return "You once again enter the #room. A pile of smashed and rotting vegetables sits in a corner. There is a #girl on the floor inscribed in a pool of blood. On one wall a #window looks out towards a spindly garden. On one wall is an old wooden #table. On yet another wall is that door that has already been mentioned."
Garden:
    inspect: "A #gardener flails with a shovel and mutters something about the gargoyle. There is some oddly symbolic activity happening here, where #tomatoes, #corn, and the like reach outward from their festering rows. \n
        Behind you, the house stands with the door to the ~Hallway swinging ajar."
    Gardener:
        inspect: "The @gardener is wearing overalls as you'd expect. He tends the #eggplants carefully, with distracted - largely ineffective - detours to rid the tomato plants of pestilence."
        Overalls: "The brand is 'Thest Jonest'"
        is_character: true
        talk_to:
            ask_about:
                garden: "Mutant vegetables."
                growing: "Mutant vegetables."
                gargoyle: "That fucking gargoyle. Some days I wonder what Mary does in there."
                girl: "Mary was my oldest friend. That fucking gargoyle barely lets me in to see her anymore, like she has to study every hour of every day. I know she had her new boyfriend over last night. Seems to me that every night she is bringing a new version of that same guy home. And I can't come in for tea?"
    Vegetables:
        inspect: "Some kind of mutant symbolism of invasion and rebirth. Corn, tomatoes, eggplants... and the related fauna."
    Corn:
        inspect: "Corn is boring. Squared away rows. Stalks, leaves, ears. If the corn could say what they have heard maybe you could piece together what happened in the Room, but as it stands... what is corn good for? Strong and tall with good ears... not cutting it today."
    Tomatoes:
        inspect: "There is a colony of #worms undergoing an exponential expansion in this region of the garden. The tomato plants are being overrun one by one. Every morning more worms hatch in growing swarms. \n
            On one plant, a dozen #bees work busily to eviscerate a worm for no reason that is immediately apparent. What do bees actually eat? Are they here seeking some other deeper fullfillment? Are they laying eggs in the carcass or something?"
        Worms: "The worms cooperate in a cyclical game of expansion through destruction. They lay eggs in the stalks and fruit of the garden, which hatch in a fury of worms that lay immediate waste to the substrate that made them... \n
            A new plant grows feeble and withers for every new hundred worms that burst to life. These worms multiply in days to devour a new patch, then die en masse when the food abruptly runs out. Why doesn't a worm just stop eating and fucking before the plants start to die irreversibly? \n
            Maybe there's some good reason they act so cooperative. Their rotting colonies fertilize the soil for subsequent ebbs and flows to germinate, so there is that."
        Bees: "The bees are doing unspeakable things. Further inspection demonstrates that the violence is related in some way to reproduction. You briefly wonder what it will look like once all the worms die and more bees come. You quickly admonish yourself... that's a strange intimate fantasy of the worms and bees you are watching. It's hard to believe the nearby #eggplants stand by any of it."
    Eggplants:
        inspect: "The eggplants hang as the royal fruit at the center of the garden. The majority bear voluptuous purple fruit. One plant in the corner of the garden looks like it has sprouted a dozen #eggs off of a remote branch. The eggs are humming."
        Eggs:
            inspect: "A dozen glowing, perfectly elliptical, oddly pastel eggs. Each of the twelve has a tiny mouth and a soul. They are vibrating as a unit at the fundamental frequency of some tiny creature, and they are emitting a wet sound not too different from a vibrating cell phone. They burble away and cast nondescript verbal sounds in your direction."
            talk_to: (context) ->
                ["One of the eggs mentions that they are in fact the gardener, in another life that has yet to exist.",
                "One of the eggs tells you that they are yet to exist.",
                "One of the eggs tells you that they are the girl"]
            pick_up: (context) ->
                context.egg = true
                return "You take the egg that claimed to be the girl. Why did you do that?"
    neighbors:
        Hallway: (context) ->
            context.location = "Hallway"
            return "You return to the hallway from which you emerged earlier in this story. The gargoyle offers a well-practiced greeting. There is a door to the ~Room, the locked #near_door , and the open door leading to the ~Garden"
}


Inventory: {
    knife: false
    gargoyle_key: false
    egg: false
}

ENDING = "The egg screams and crumbles to dust. The dust settles, then animates and morphs to become a tiny figure, sanguine and pink. The figure grows and becomes Mary. \n
Events unfold in a cloud of sparks. Mary pulls her kerchief over her shining blonde hair as you link hands and head out the door. The gargoyle sends a clever goodbye. You tip your hat to the gardener, who is busy breaking apart a clump of worms with a shovel. You and Mary eat by the river and smoke cigarettes into a fountain until the sun comes up. \n
You walk together back to the room, feeling complete. Mary guides your hand to pick up the knife and pulls it towards her soft chest. You violently press and leave here there on the floor. She is choking on blood. The butler enters through the open door behind you and hands you a tomato. You bite into the fruit, laden with eggs and larvae from the garden outside. The room darkens as your mind slows, and you tumble forward onto the floor and into darkness."

