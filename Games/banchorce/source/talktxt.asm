;---------------------------------------------------------------;
;                                                               ;
; Banchor                                                       ;
; Talking Text                                                  ;
;                                                               ;
;---------------------------------------------------------------;

talkText:
;        123456789012345678901234567890123456

talkTxt0:
.db     "You found a ",1,COLOUR_DARKRED,"Blunt Sword",1,COLOUR_WHITE,"!",0
.db     255

talkTxt1:
.db     "Can't you read my sign out front",0
.db     "boy? Here, leave me alone and take",0
.db     "this ",1,COLOUR_DARKRED,"Superior Sword",1,COLOUR_WHITE,"... for only",0
.db     GOLDTXT_SUPERIOR_SWORD," gold.",0
.db     254,255

talkTxt2:
.db     "Young warrior, I have here the",0
.db     1,COLOUR_DARKRED,"Legendary Sword",1,COLOUR_WHITE," of Heroes. It can",0
.db     "be yours for ",GOLDTXT_LEGENDARY_SWORD," gold.",0
.db     254,255

talkTxt3:
.db     "You got your ",1,COLOUR_ORANGE,"Wooden Shield",1,COLOUR_WHITE,"!",0
.db     255

talkTxt4:
.db     "Hey kid, I've got this ",1,COLOUR_ORANGE,"Iron Shield",0
.db     "if you want it. Works real good.",0
.db     "Only ",GOLDTXT_IRON_SHIELD," gold.",0
.db     254,255

talkTxt5:
.db     "Brave warrior, do you want this",0
.db     1,COLOUR_YELLOW,"Light Armor",1,COLOUR_WHITE," to reduce your wounds?",0
.db     "For ",GOLDTXT_LIGHT_ARMOR," gold?",0
.db     254,255

talkTxt6:
.db     "Young man, if you wish to journey",0
.db     "on, I suggest you purchase this",0
.db     1,COLOUR_YELLOW,"Heavy Armor",1,COLOUR_WHITE," for ",GOLDTXT_HEAVY_ARMOR," gold. I",0
.db     "guarantee you'll need it.",0
.db     254,255

talkTxt7:
.db     "Noble fighter! Your feet must truly",0
.db     "be tired! These ",1,COLOUR_BLUE,"Aqua Boots",1,COLOUR_WHITE," will bear",0
.db     "you across water for only ",GOLDTXT_AQUA_BOOTS,0
.db     "gold!",0
.db     254,255

talkTxt8:
.db     "To get to Banchor's Fortress you'll",0
.db     "need these ",1,COLOUR_GREEN,"Winged Boots",1,COLOUR_WHITE," to carry you",0
.db     "over the lava moat. Yours for ",GOLDTXT_WINGED_BOOTS,0
.db     "gold!",0
.db     254,255

talkTxt9:
.db     "This ",1,COLOUR_PURPLE,"Ring of Might",1,COLOUR_WHITE," will give your",0
.db     "sword power enough to shatter stones",0
.db     "such as those in this cave! It can",0
.db     "be yours for just ",GOLDTXT_RING_OF_MIGHT," gold.",0
.db     254,255

talkTxt10:
.db     "Do you wish to crush rocks like",0
.db     "these behind me? If so, then this",0
.db     1,COLOUR_PURPLE,"Ring of Thunder",1,COLOUR_WHITE," is for you. It will",0
.db     "cost you ",GOLDTXT_RING_OF_THUNDER," gold.",0
.db     254,255

talkTxt11:
.db     "You found a ",1,COLOUR_RED,"Heart Piece",1,COLOUR_WHITE,"!",0
.db     255

talkTxt12:
.db     "You found a ",1,COLOUR_BLUE,"Crystal",1,COLOUR_WHITE,"!",0
.db     255

talkTxt13:
.db     "Young man, the battles ahead will",0
.db     "drain you immensely. Take this ",1,COLOUR_RED,"heart",0
.db     1,COLOUR_RED,"container",1,COLOUR_WHITE," for ",GOLDTXT_HEART_CONTAINER_1," gold!",0
.db     254,255

talkTxt14:
.db     "You found 1000 gold!",0
.db     255

talkTxt15:
.db     "You found 5000 gold!",0
.db     255

talkTxt16:
.db     "Your life is replenished!",0
.db     255

talkTxt17:
.db     "Drop 150 gold into the well to fill",0
.db     "your all heart containers!",0
.db     254,255

talkTxt18:
.db     "I have nothing left to give you.",0
.db     255

talkTxt19:
.db     "You don't have enough gold!",0
.db     255

talkTxt20:
.db     "GAME OVER",0
.db     255

talkTxt21:
.db     "Rex, get out before the guards catch",0
.db     "you! You must get back to the",0
.db     "village alive! There is a secret",0
.db     "passage that you can use to escape.",0
.db     "Hurry!",0
.db     255

talkTxt22:
.db     "        -- VIRIDIAN CASTLE --",0
.db     255

talkTxt23:
.db     "PASSAGE BEYOND PORT VIRIDIAN IS",0
.db     "STRICTLY PROHIBITED",0
.db     255

talkTxt24:
.db     "King Heath has prohibited anyone",0
.db     "from leaving or entering the",0
.db     "village.",0
.db     255

talkTxt25:
.db     1,COLOUR_YELLOW,"KING HEATH:",0,0
.db     "Thank you for releasing the evil",0
.db     "spirits from me, Rex! You are the",0
.db     "last hope of our Kingdom!",0
.db     "My daughter, Sapphira, was",0
.db     "kidnapped by an evil power. You",0
.db     "must save her and find out what is",0
.db     "causing all this mischief!",0,0
.db     "In this chest is 1 of 7 crystals.",0
.db     "It's purpose I am unsure of but it",0
.db     "must be of some importance!",0
.db     "Go now, to the Village. I am tired",0
.db     "and I must rest...",0
.db     255

talkTxt26:
.db     "You have died in battle!",0
.db     255

talkTxt27:
.db     1,COLOUR_YELLOW,"CHIEF:",0,0
.db     "Rex! How did you escape the",0
.db     "dungeons? You truly are a great",0
.db     "warrior!",0,0,0,0,0,0
.db     "Rex, the name of Banchor is being",0
.db     "whispered again among the people.",0
.db     "You must venture across our great",0
.db     "lands and seek the cause of these",0
.db     "demons that are overrunning our",0
.db     "kingdom!",0,0
.db     "Take the gold in this chest to help",0
.db     "you! Good luck!",0
.db     255

talkTxt28:
.db     "Rex's House",0
.db     255

talkTxt29:
.db     1,COLOUR_YELLOW,"INN-KEEPER:",0,0
.db     "Young lad, I have 3 chests here with",0
.db     "life rejuvinating potions in them.",0
.db     "They are yours to use, but use them",0
.db     "wisely!",0
.db     255

talkTxt30:
.db     "Welcome back Rex! You are our",0
.db     "only hope!",0,0
.db     "There are many demons loose in the",0
.db     "village - be careful!",0
.db     255

talkTxt31:
.db     "North lies the Rocky Desert",0
.db     255

talkTxt32:
.db     "Rex, I am the spirit of Princess",0
.db     "Sapphira, King Heath's daughter.",0
.db     "You will find me as you venture",0
.db     "across the lands. I will always",0
.db     "be ready with useful information!",0
.db     255

talkTxt33:
.db     "This passage leads to the Snowy",0
.db     "Highlands. If you can defeat",0
.db     "Dezemon, he might build a bridge for",0
.db     "you!",0
.db     255

talkTxt34:
.db     "The Rocky Desert is run by Dezemon,",0
.db     "who resides in the Pyramid of",0
.db     "Snakes.",0
.db     255

talkTxt35:
.db     "WENDEG'S PALACE",0
.db     255

talkTxt36:
.db     "Welcome to the Snowy Highlands!",0
.db     "Wendeg rules here.. You must best",0
.db     "him for the way forward to become",0
.db     "clear!",0
.db     255

talkTxt37:
.db     "An old warrior lives in these parts.",0
.db     "Perhaps he has useful equipment!",0
.db     255

talkTxt38:
.db     "DO NOT DISTURB!",0
.db     255

talkTxt39:
.db     "Beware of the fierce creature,",0
.db     "Wendeg, who resides in the Ice",0
.db     "Palace!",0
.db     255

talkTxt40:
.db     "Legend tells of the Ring of Might,",0
.db     "which gives it's wearer the power to",0
.db     "shatter stones!",0
.db     255

talkTxt41:
.db     "BEWARE: Spiders!",0
.db     255

talkTxt42:
.db     "Beyond here lies the great Spider",0
.db     "Forest. Within you can find the Iron",0
.db     "Shield!",0
.db     255

talkTxt43:
.db     "You will need special boots if you",0
.db     "wish to cross water!",0
.db     255

talkTxt44:
.db     "Be careful in the Swamplands, Rex.",0
.db     "In there you will find the mighty",0
.db     "demon, Belkath!",0
.db     255

talkTxt45:
.db     "This is the swamp of Belkath. You",0
.db     "will find the 4th crystal to the",0
.db     "East once she is defeated.",0
.db     255

talkTxt46:
.db     "Somewhere in these swamplands",0
.db     "you will find very useful boots!",0
.db     255

talkTxt47:
.db     "Rex, the crystal that my possessed",0
.db     "father was guarding was indeed one",0
.db     "of the 7 crystals that the wizard",0
.db     "Zehos used to block the portal",0
.db     "between the mortal plane and Hell.",0,0
.db     "When Zehos banished Banchor back",0
.db     "to Hell, it formed a bonding link",0
.db     "between Banchor and the descendants",0
.db     "of Zehos.",0
.db     "My father and I are his descendants,",0
.db     "and this is how Banchor came to",0
.db     "possess my father's body. He also",0
.db     "pulled my body from the mortal plane",0
.db     "into Hell.. Now my spirit is all",0
.db     "that remains here to guide you!",0,0,0,0,0
.db     "The remaining 6 crystals are spread",0
.db     "all across the lands. Banchor has",0
.db     "sent 6 of his most powerful demons",0
.db     "to find and guard them until he is",0
.db     "ready to make the crossing into the",0
.db     "mortal plane.",0,0
.db     "You must defeat them and gather all",0
.db     "7 crystals before it's too late!",0
.db     255

talkTxt48:
.db     "If Banchor gets possession of the 7",0
.db     "crystals, he will be able to cross",0
.db     "into the mortal plane, and all hope",0
.db     "will be lost!",0
.db     255

talkTxt49:
.db     "You must find all 7 crystals to open",0
.db     "the portal to Hell so that you can",0
.db     "defeat Banchor!",0
.db     255

talkTxt50:
.db     "According to legend, the gateway to",0
.db     "Hell is hidden in an ancient chamber",0
.db     "within the Graveyard of Heroes.",0
.db     255

talkTxt51:
.db     "The 5th crystal is guarded by the",0
.db     "demon Anazar. He's lurking deep",0
.db     "within the Forest Temple...",0
.db     255

talkTxt52:
.db     "For Banchor to return to his full",0
.db     "power, he needs to use the power",0
.db     "residing in the 7 crystals combined",0
.db     "with the blood of a descendant of",0
.db     "Zehos. This is why he has kidnapped",0
.db     "me!",0,0,0,0,0
.db     "You must take care not to lose in",0
.db     "battle with Banchor, or he will be",0
.db     "set loose upon humanity!",0
.db     255

talkTxt53:
.db     "Beyond this Valley you will find the",0
.db     "Graveyard of Heroes!",0
.db     255

talkTxt54:
.db     "The gateway to Hell is located",0
.db     "somewhere in this Graveyard.",0
.db     255

talkTxt55:
.db     "The undead demon Durcrux is waiting",0
.db     "for you deep within his tomb...",0
.db     255

talkTxt56:
.db     "Without all 7 crystals, you will not",0
.db     "be able to enter the portal into",0
.db     "Hell and defeat Banchor!",0
.db     255

talkTxt57:      ; Game finished!
;        123456789012345678901234567890123456
.db     1,COLOUR_YELLOW,"PRINCESS SAPPHIRA:",0,0
.db     "Thank you Rex, for defeating the",0
.db     "evil Banchor and freeing me! Our",0
.db     "people will forever remember what",0
.db     "you have done!",0
.db     0,0,0,0

.db     "... With the influence of Banchor",0
.db     "fading, peace returns to the Kingdom",0
.db     "of Viridian.",0,0
.db     "Now known as a hero, Rex decides he",0
.db     "will return to Brill Haven and",0
.db     "inspire others to achieve great",0
.db     "deeds!",0
.db     0,0

.db     0,0
.db     "       THANK YOU FOR PLAYING!",0
.db     0
.db     1,COLOUR_RED,"  BANCHOR: LEGEND OF THE HELLSPAWN",0
.db     0
.db     1,COLOUR_GREEN,"          BY JAMES VERNON          ",0
.db     255

talkTxt58:
.db     "The Aqua Boots will not carry you",0
.db     "over the Lava Rivers in Hell.",0
.db     255

talkTxt59:
.db     "The Ring of Thunder will give you",0
.db     "access to Durcrux's Tomb! Did you",0
.db     "find it on your way here?",0
.db     255

talkTxt60:
.db     "In the Graveyard of Heroes you will",0
.db     "find the Legendary Sword, inside the",0
.db     "Tomb of Zehos!",0
.db     255

talkTxt61:
.db     "Things are not always what they",0
.db     "appear...",0
.db     255

talkTxt62:
.db     "The sewers beneath Brill Haven have",0
.db     "not been explored for many, many,",0
.db     "centuries, since the age of magic.",0
.db     "They are rumoured to contain evil",0
.db     "within, as well as countless magical",0
.db     "secrets.",0
.db     0,0,0,0
.db     "Perhaps one day a band of heroes",0
.db     "will be brave enough to head into",0
.db     "the depths...",0
.db     255

talkTxt63:
.db     "You found 10000 gold!",0
.db     255

talkTxt64:
.db     "Young man, the battles ahead will",0
.db     "drain you immensely. Take this ",1,COLOUR_RED,"heart",0
.db     1,COLOUR_RED,"container",1,COLOUR_WHITE," for ",GOLDTXT_HEART_CONTAINER_2," gold!",0
.db     254,255

talkTxt65:
.db     "Young man, the battles ahead will",0
.db     "drain you immensely. Take this ",1,COLOUR_RED,"heart",0
.db     1,COLOUR_RED,"container",1,COLOUR_WHITE," for ",GOLDTXT_HEART_CONTAINER_3," gold!",0
.db     254,255

talkTxt66:
.db     "You have died in battle and failed",0
.db     "your quest!",0,0
.db     255

talkTxt67:
.db     "The entrance to the Twisted Depths",0
.db     "is on an island. Inside you will",0
.db     "find Margoth - she must be defeated",0
.db     "for the 6th crystal to reveal",0
.db     "itself!",0
.db     255

talkTxt68:
.db     "The 2nd crystal will reveal itself",0
.db     "not too far from the Pyramid of",0
.db     "Snakes once Dezemon is defeated.",0
.db     255

talkTxt69:
.db     "If you can overcome Wendeg, you will",0
.db     "be able to find the Glacial Cavern",0
.db     "entrance, behind the weeds. Inside",0
.db     "is the 3rd crystal!",0
.db     255

talkTxt70:
.db     "The 5th crystal is hidden near a",0
.db     "river where the trees wander!",0
.db     255

talkTxt71:
.db     "Once Margoth is beaten, the 6th",0
.db     "crystal can be found to the South,",0
.db     "not far from a small pond...",0
.db     255

talkTxt72:
.db     "In a secluded, rocky corner of the",0
.db     "Graveyard, you will find the 7th and",0
.db     "final crystal.. But you must face",0
.db     "Durcrux first!",0
.db     255

talkTxt73:
.db     "Have you found the Heavy Armor? It's",0
.db     "somewhere in the Pine Forest, and",0
.db     "will protect you well when you face",0
.db     "Banchor!",0
.db     255

talkTxt74:
.db     "Did you retrieve the Light Armor? It",0
.db     "is in a cave under the Rocky Desert,",0
.db     "but you will need the Ring of Might",0
.db     "to access it..",0
.db     255

talkTxt75:
.db     "The path West is a shortcut back to",0
.db     "the Rocky Desert, once you have the",0
.db     "Ring of Might.",0
.db     255

talkTxt76:
.db     "You'll need the Winged Boots to get",0
.db     "to that cave!",0
.db     255

talkTxt77:      ; Game finished on Hell difficulty!
.db     0,0,0
.db     " Congratulations for completing the",0
.db     "      game on ",1,COLOUR_RED,"Hell",1,COLOUR_WHITE," difficulty!",0
.db     255

.end
