	object_const_def ; object_event constants
	const POKECENTER2F_TRADE_RECEPTIONIST
	const POKECENTER2F_BATTLE_RECEPTIONIST
	const POKECENTER2F_OFFICER

Pokecenter2F_MapScripts:
	db 3 ; scene scripts
	scene_script .Scene0 ; SCENE_DEFAULT
	scene_script .Scene1 ; SCENE_POKECENTER2F_LEAVE_TRADE_CENTER
	scene_script .Scene2 ; SCENE_POKECENTER2F_LEAVE_COLOSSEUM

	db 0 ; callbacks

.Scene0:
	special CheckMysteryGift
	ifequal $0, .Scene0Done
	clearevent EVENT_MYSTERY_GIFT_DELIVERY_GUY
	checkevent EVENT_TEMPORARY_UNTIL_MAP_RELOAD_2
	iftrue .Scene0Done
	prioritysjump Pokecenter2F_AppearMysteryGiftDeliveryGuy

.Scene0Done:
	end

.Scene1:
	prioritysjump Script_LeftCableTradeCenter
	end

.Scene2:
	prioritysjump Script_LeftCableColosseum
	end

Pokecenter2F_AppearMysteryGiftDeliveryGuy:
	appear POKECENTER2F_OFFICER
	setevent EVENT_TEMPORARY_UNTIL_MAP_RELOAD_2
	end

Script_TradeCenterClosed:
	faceplayer
	opentext
	writetext Text_TradeRoomClosed
	waitbutton
	closetext
	end

Script_BattleRoomClosed:
	faceplayer
	opentext
	writetext Text_BattleRoomClosed
	waitbutton
	closetext
	end

LinkReceptionistScript_Trade:
	opentext
	writetext Text_TradeReceptionistIntro
	yesorno
	iffalse .Cancel
	special SetBitsForLinkTradeRequest
	writetext Text_PleaseWait
	special WaitForLinkedFriend
	iffalse .FriendNotReady
	writetext Text_MustSaveGame
	yesorno
	iffalse .DidNotSave
	special TryQuickSave
	iffalse .DidNotSave
	writetext Text_PleaseWait
	special CheckLinkTimeout
	iffalse .LinkTimedOut
	readmem wOtherPlayerLinkMode
	iffalse .LinkedToFirstGen
	special CheckBothSelectedSameRoom
	iffalse .IncompatibleRooms
	special CheckOtherPlayerGender
	writetext Text_PleaseComeIn2
	waitbutton
	closetext
	scall Pokecenter2F_EnterRoom
	warpcheck
	end

.FriendNotReady:
	special WaitForOtherPlayerToExit
	writetext Text_FriendNotReady
	closetext
	end

.LinkedToFirstGen:
	special FailedLinkToPast
	writetext Text_CantLinkToThePast
	special CloseLink
	closetext
	end

.IncompatibleRooms:
	writetext Text_IncompatibleRooms
	special CloseLink
	closetext
	end

.LinkTimedOut:
	writetext Text_LinkTimedOut
	sjump .AbortLink

.DidNotSave:
	writetext Text_PleaseComeAgain
.AbortLink:
	special WaitForOtherPlayerToExit
.Cancel:
	closetext
	end

.Mobile:
	scall .Mobile_TrySave
	iftrue .Mobile_Abort
	scall BattleTradeMobile_WalkIn
	warpcheck
	end

.Mobile_Abort:
	end

.Mobile_TrySave:
	writetext Text_MustSaveGame
	yesorno
	iffalse .Mobile_DidNotSave
	special TryQuickSave
	iffalse .Mobile_DidNotSave
	writetext Text_PleaseComeIn2
	waitbutton
	closetext
	setval FALSE
	end

.Mobile_DidNotSave:
	writetext Text_PleaseComeAgain
	closetext
	setval TRUE
	end

BattleTradeMobile_WalkIn:
	applymovementlasttalked Pokecenter2FMobileMobileMovementData_ReceptionistWalksUpAndLeft_LookDown
	applymovement PLAYER, Pokecenter2FMobileMovementData_PlayerWalksIntoMobileBattleRoom
	end

LinkReceptionistScript_Battle:
	opentext
	writetext Text_BattleReceptionistIntro
	yesorno
	iffalse .Cancel

	special SetBitsForBattleRequest
	writetext Text_PleaseWait
	special WaitForLinkedFriend
	iffalse .FriendNotReady
	writetext Text_MustSaveGame
	yesorno
	iffalse .DidNotSave
	special TryQuickSave
	iffalse .DidNotSave
	writetext Text_PleaseWait
	special CheckLinkTimeout
	iffalse .LinkTimedOut
	readmem wOtherPlayerLinkMode
	iffalse .LinkedToFirstGen
	special CheckBothSelectedSameRoom
	iffalse .IncompatibleRooms
	special CheckOtherPlayerGender
	writetext Text_PleaseComeIn2
	waitbutton
	closetext
	scall Pokecenter2F_EnterRoom
	warpcheck
	end

.FriendNotReady:
	special WaitForOtherPlayerToExit
	writetext Text_FriendNotReady
	closetext
	end

.LinkedToFirstGen:
	special FailedLinkToPast
	writetext Text_CantLinkToThePast
	special CloseLink
	closetext
	end

.IncompatibleRooms:
	writetext Text_IncompatibleRooms
	special CloseLink
	closetext
	end

.LinkTimedOut:
	writetext Text_LinkTimedOut
	sjump .AbortLink

.DidNotSave:
	writetext Text_PleaseComeAgain
.AbortLink:
	special WaitForOtherPlayerToExit
.Cancel:
	closetext
	end

Script_LeftCableTradeCenter:
	special WaitForOtherPlayerToExit
	scall Script_WalkOutOfLinkTradeRoom
	setscene SCENE_DEFAULT
	setmapscene TRADE_CENTER, SCENE_DEFAULT
	end

Script_LeftCableColosseum:
	special WaitForOtherPlayerToExit
	scall Script_WalkOutOfLinkBattleRoom
	setscene SCENE_DEFAULT
	setmapscene COLOSSEUM, SCENE_DEFAULT
	end

Pokecenter2F_EnterRoom:
	applymovementlasttalked Pokecenter2FMovementData_ReceptionistWalksUpAndLeft_LookRight
	applymovement PLAYER, Pokecenter2FMovementData_PlayerTakesThreeStepsUp
	readmem wLinkOtherPlayerGender
	iftrue .Female
	variablesprite SPRITE_LINK_TRAINER, SPRITE_CHRIS
	end

.Female:
	variablesprite SPRITE_LINK_TRAINER, SPRITE_KRIS
	end

Script_WalkOutOfLinkTradeRoom:
	checkflag ENGINE_KRIS_IN_CABLE_CLUB
	iftrue .Female
	applymovement POKECENTER2F_TRADE_RECEPTIONIST, Pokecenter2FMovementData_ReceptionistStepsRightLooksDown_3
	applymovement PLAYER, Pokecenter2FMovementData_PlayerTakesThreeStepsDown
	applymovement POKECENTER2F_TRADE_RECEPTIONIST, Pokecenter2FMovementData_ReceptionistStepsRightAndDown
	end

.Female:
	applymovement POKECENTER2F_TRADE_RECEPTIONIST, Pokecenter2FMovementData_ReceptionistStepsRightLooksDown_3
	applymovement PLAYER, Pokecenter2FMovementData_PlayerTakesOneStepDown_2
	clearflag ENGINE_KRIS_IN_CABLE_CLUB
	playsound SFX_TINGLE
	applymovement PLAYER, Pokecenter2FMovementData_PlayerSpinsClockwiseEndsFacingRight
	setval (PAL_NPC_RED << 4)
	special SetPlayerPalette
	applymovement PLAYER, Pokecenter2FMovementData_PlayerSpinsClockwiseEndsFacingLeft
	special ReplaceKrisSprite
	applymovement PLAYER, Pokecenter2FMovementData_PlayerTakesTwoStepsDown_2
	applymovement POKECENTER2F_TRADE_RECEPTIONIST, Pokecenter2FMovementData_ReceptionistStepsRightAndDown
	end

Script_WalkOutOfLinkBattleRoom:
	checkflag ENGINE_KRIS_IN_CABLE_CLUB
	iftrue .Female
	applymovement POKECENTER2F_BATTLE_RECEPTIONIST, Pokecenter2FMovementData_ReceptionistStepsRightLooksDown_3
	applymovement PLAYER, Pokecenter2FMovementData_PlayerTakesThreeStepsDown
	applymovement POKECENTER2F_BATTLE_RECEPTIONIST, Pokecenter2FMovementData_ReceptionistStepsRightAndDown
	end

.Female:
	applymovement POKECENTER2F_BATTLE_RECEPTIONIST, Pokecenter2FMovementData_ReceptionistStepsRightLooksDown_3
	applymovement PLAYER, Pokecenter2FMovementData_PlayerTakesOneStepDown_2
	clearflag ENGINE_KRIS_IN_CABLE_CLUB
	playsound SFX_TINGLE
	applymovement PLAYER, Pokecenter2FMovementData_PlayerSpinsClockwiseEndsFacingRight
	setval (PAL_NPC_BLUE << 4)
	special SetPlayerPalette
	applymovement PLAYER, Pokecenter2FMovementData_PlayerSpinsClockwiseEndsFacingLeft
	special ReplaceKrisSprite
	applymovement PLAYER, Pokecenter2FMovementData_PlayerTakesTwoStepsDown_2
	applymovement POKECENTER2F_BATTLE_RECEPTIONIST, Pokecenter2FMovementData_ReceptionistStepsRightAndDown
	end

Pokecenter2FLinkRecordSign:
	refreshscreen
	special DisplayLinkRecord
	closetext
	end

Pokecenter2FOfficerScript:
	faceplayer
	opentext
	checkevent EVENT_MYSTERY_GIFT_DELIVERY_GUY
	iftrue .AlreadyGotGift
	writetext Text_MysteryGiftDeliveryGuy_Intro
	yesorno
	iffalse .RefusedGift
	writetext Text_MysteryGiftDeliveryGuy_HereYouGo
	buttonsound
	waitsfx
	special GetMysteryGiftItem
	iffalse .BagIsFull
	itemnotify
	setevent EVENT_MYSTERY_GIFT_DELIVERY_GUY
.AlreadyGotGift:
	writetext Text_MysteryGiftDeliveryGuy_Outro
	waitbutton
	closetext
	end

.BagIsFull:
	writetext Text_MysteryGiftDeliveryGuy_NoRoom
	waitbutton
	closetext
	end

.RefusedGift:
	writetext Text_MysteryGiftDeliveryGuy_SaidNo
	waitbutton
	closetext
	end

Pokecenter2FMovementData_ReceptionistWalksUpAndLeft_LookRight:
	slow_step UP
	slow_step LEFT
	turn_head RIGHT
	step_end

Pokecenter2FMobileMobileMovementData_ReceptionistWalksUpAndLeft_LookDown:
	slow_step UP
	slow_step LEFT
	turn_head DOWN
	step_end

Pokecenter2FMovementData_ReceptionistStepsLeftLooksDown:
	slow_step LEFT
	turn_head DOWN
	step_end

Pokecenter2FMovementData_ReceptionistStepsRightLooksDown:
	slow_step RIGHT
	turn_head DOWN
	step_end

Pokecenter2FMovementData_ReceptionistWalksUpAndLeft_LookRight_2:
	slow_step UP
	slow_step LEFT
	turn_head RIGHT
	step_end

Pokecenter2FMovementData_ReceptionistLooksRight:
	turn_head RIGHT
	step_end

Pokecenter2FMovementData_PlayerTakesThreeStepsUp:
	step UP
	step UP
	step UP
	step_end

Pokecenter2FMovementData_PlayerTakesTwoStepsUp:
	step UP
	step UP
	step_end

Pokecenter2FMovementData_PlayerTakesOneStepUp:
	step UP
	step_end

Pokecenter2FMobileMovementData_PlayerWalksIntoMobileBattleRoom:
	step UP
	step UP
	step RIGHT
	step UP
	step_end

Pokecenter2FMovementData_PlayerTakesTwoStepsUp_2:
	step UP
	step UP
	step_end

Pokecenter2FMovementData_PlayerWalksLeftAndUp:
	step LEFT
	step UP
	step_end

Pokecenter2FMovementData_PlayerWalksRightAndUp:
	step RIGHT
	step UP
	step_end

Pokecenter2FMovementData_PlayerTakesThreeStepsDown:
	step DOWN
	step DOWN
	step DOWN
	step_end

Pokecenter2FMovementData_PlayerTakesTwoStepsDown:
	step DOWN
	step DOWN
	step_end

Pokecenter2FMovementData_PlayerTakesOneStepDown:
	step DOWN
	step_end

Pokecenter2FMovementData_ReceptionistStepsRightAndDown:
	slow_step RIGHT
	slow_step DOWN
	step_end

Pokecenter2FMovementData_ReceptionistStepsRightLooksDown_2:
	slow_step RIGHT
	turn_head DOWN
	step_end

Pokecenter2FMovementData_ReceptionistStepsRightLooksDown_3:
	slow_step UP
	slow_step LEFT
	turn_head RIGHT
	step_end

Pokecenter2FMovementData_ReceptionistStepsLeftLooksRight:
	slow_step LEFT
	turn_head RIGHT
	step_end

Pokecenter2FMobileMovementData_ReceptionistWalksUpAndLeft:
	slow_step UP
	slow_step LEFT
	turn_head RIGHT
	step_end

Pokecenter2FMovementData_PlayerWalksOutOfMobileRoom:
	step DOWN
	step LEFT
	step DOWN
	step DOWN
	step_end

Pokecenter2FMobileMovementData_ReceptionistWalksRightAndDown:
	slow_step RIGHT
	slow_step DOWN
	step_end

Pokecenter2FMovementData_PlayerSpinsClockwiseEndsFacingRight:
	turn_head DOWN
	turn_head LEFT
	turn_head UP
	turn_head RIGHT
	step_end

Pokecenter2FMovementData_PlayerSpinsClockwiseEndsFacingLeft:
	turn_head DOWN
	turn_head LEFT
	turn_head UP
	turn_head RIGHT
	turn_head LEFT
	step_end

Pokecenter2FMovementData_PlayerSpinsClockwiseEndsFacingDown:
	turn_head DOWN
	turn_head LEFT
	turn_head UP
	turn_head RIGHT
	turn_head DOWN
	step_end

Pokecenter2FMovementData_PlayerTakesOneStepDown_2:
	step DOWN
	step_end

Pokecenter2FMovementData_PlayerTakesTwoStepsDown_2:
	step DOWN
	step DOWN
	step_end

Pokecenter2FMovementData_PlayerTakesOneStepUp_2:
	step UP
	step_end

Pokecenter2FMovementData_PlayerTakesOneStepRight:
	step RIGHT
	step_end

Pokecenter2FMovementData_PlayerTakesOneStepLeft:
	step LEFT
	step_end

Pokecenter2FMovementData_ReceptionistStepsLeftLooksRight_2:
	slow_step LEFT
	turn_head RIGHT
	step_end

Pokecenter2FMovementData_ReceptionistStepsRightLooksLeft_2:
	slow_step RIGHT
	turn_head LEFT
	step_end

Text_BattleReceptionistMobile:
	text "Would you like to"
	line "battle over a GAME"

	para "LINK cable or by"
	line "mobile phone?"
	done

Text_TradeReceptionistMobile:
	text "Would you like to"
	line "trade over a GAME"

	para "LINK cable or by"
	line "mobile phone?"
	done

Text_ThisWayToMobileRoom:
	text "This way to the"
	line "MOBILE ROOM."
	done

Text_BattleReceptionistIntro:
	text "Welcome to Cable"
	line "Club Colosseum."

	para "You may battle a"
	line "friend here."

	para "Would you like to"
	line "battle?"
	done

Text_TradeReceptionistIntro:
	text "Welcome to Cable"
	line "Trade Center."

	para "You may trade your"
	line "#mon here with"
	cont "a friend."

	para "Would you like to"
	line "trade?"
	done

Text_TimeCapsuleReceptionistIntro:
	text "Welcome to CABLE"
	line "CLUB TIME CAPSULE."

	para "You can travel to"
	line "the past and trade"
	cont "your #MON."

	para "Would you like to"
	line "trade across time?"
	done

Text_FriendNotReady:
	text "Your friend is not"
	line "ready."
	prompt

Text_MustSaveGame:
	text "Before opening the"
	line "link, you must"
	cont "save your game."
	done

Text_PleaseWait:
	text "Please wait."
	done

Text_LinkTimedOut:
	text "The link has been"
	line "closed because of"
	cont "inactivity."

	para "Please contact"
	line "your friend and"
	cont "come again."
	prompt

Text_PleaseComeAgain:
	text "Please come again."
	prompt

Text_PleaseComeIn:
	text "Please come in."
	prompt

Text_TemporaryStagingInLinkRoom:
	text "We'll put you in"
	line "the link room for"
	cont "the time being."
	done

Text_CantLinkToThePast:
	text "You can't link to"
	line "the past here."
	prompt

Text_IncompatibleRooms:
	text "Incompatible rooms"
	line "were chosen."
	prompt

Text_PleaseComeIn2:
	text "Please come in."
	done

Text_PleaseEnter:
	text "Please enter."
	prompt

Text_RejectNewMon:
	text "Sorry--@"
	text_ram wStringBuffer1
	text_start
	line "can't be taken."
	prompt

Text_RejectMonWithNewMove:
	text "You can't take the"
	line "@"
	text_ram wStringBuffer1
	text " with a"
	cont "@"
	text_ram wStringBuffer2
	text "."
	prompt

Text_RejectMonWithMail:
	text "You can't take the"
	line "@"
	text_ram wStringBuffer1
	text " that"
	cont "has Mail with you."
	prompt

Text_TimeCapsuleClosed:
	text "I'm sorry--the"
	line "TIME CAPSULE is"
	cont "being adjusted."
	done

Text_TradeRoomClosed:
	text "I'm sorry--the"
	line "Trade Machine is"
	cont "being adjusted."
	done

Text_BattleRoomClosed:
	text "I'm sorry--the"
	line "Battle Machine is"
	cont "being adjusted."
	done

Text_MysteryGiftDeliveryGuy_Intro:
	text "Hello! You're"
	line "<PLAYER>, right?"

	para "I have some-"
	line "thing for you."
	done

Text_MysteryGiftDeliveryGuy_HereYouGo:
	text "Here you go!"
	done

Text_MysteryGiftDeliveryGuy_Outro:
	text "We hope to serve"
	line "you again."
	done

Text_MysteryGiftDeliveryGuy_NoRoom:
	text "Oh, you have no"
	line "space for this."

	para "Stop in at any"
	line "#MON CENTER"

	para "across the country"
	line "to pick it up."
	done

Text_MysteryGiftDeliveryGuy_SaidNo:
	text "No? That's very"
	line "strange…"
	done

Text_OhPleaseWait:
	text "Oh, please wait."
	done

Text_ChangeTheLook:
	text "We need to change"
	line "the look here…"
	done

Text_LikeTheLook:
	text "How does this"
	line "style look to you?"
	done

Text_BrokeStadiumRules:
	text "Excuse me!"

	para "For Stadium rules,"
	line "please bring six"

	para "different #mon,"
	line "excluding EGGS."

	para "The six #mon"
	line "must be different."

	para "Also, they must"
	line "not be holding"
	cont "identical items."

	para "Please come back"
	line "when you're ready."
	done

Pokecenter2F_MapEvents:
	db 0, 0 ; filler

	db 3 ; warp events
	warp_event  0,  7, POKECENTER_2F, -1
	warp_event  5,  0, TRADE_CENTER, 1
	warp_event  9,  0, COLOSSEUM, 1

	db 0 ; coord events

	db 1 ; bg events
	bg_event  7,  3, BGEVENT_READ, Pokecenter2FLinkRecordSign

	db 3 ; object events
	object_event  5,  2, SPRITE_LINK_RECEPTIONIST, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, LinkReceptionistScript_Trade, -1
	object_event  9,  2, SPRITE_LINK_RECEPTIONIST, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, LinkReceptionistScript_Battle, -1
	object_event  1,  1, SPRITE_OFFICER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, Pokecenter2FOfficerScript, EVENT_MYSTERY_GIFT_DELIVERY_GUY
