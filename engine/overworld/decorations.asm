InitDecorations:
	ld a, DECO_FEATHERY_BED
	ld [wDecoBed], a
	ld a, DECO_TOWN_MAP
	ld [wDecoPoster], a
	ret

_PlayerDecorationMenu:
	ld a, [wWhichIndexSet]
	push af
	ld hl, .MenuHeader
	call LoadMenuHeader
	xor a
	ld [wBuffer5], a
	ld a, $1
	ld [wBuffer6], a
.top_loop
	ld a, [wBuffer6]
	ld [wMenuCursorBuffer], a
	call .FindCategoriesWithOwnedDecos
	call DoNthMenu
	ld a, [wMenuCursorY]
	ld [wBuffer6], a
	jr c, .exit_menu
	ld a, [wMenuSelection]
	ld hl, .pointers
	call MenuJumptable
	jr nc, .top_loop

.exit_menu
	call ExitMenu
	pop af
	ld [wWhichIndexSet], a
	ld a, [wBuffer5]
	ld c, a
	ret

.MenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 5, 0, SCREEN_WIDTH - 1, SCREEN_HEIGHT - 1
	dw .MenuData
	db 1 ; default option

.MenuData:
	db STATICMENU_CURSOR | STATICMENU_WRAP ; flags
	db 0 ; items
	dw wd002
	dw PlaceNthMenuStrings
	dw .pointers

.pointers
	dw DecoBedMenu, .bed
	dw DecoCarpetMenu, .carpet
	dw DecoPlantMenu, .plant
	dw DecoPosterMenu, .poster
	dw DecoConsoleMenu, .game
	dw DecoOrnamentMenu, .ornament
	dw DecoBigDollMenu, .big_doll
	dw DecoExitMenu, .exit

.bed      db "Bed@"
.carpet   db "Carpet@"
.plant    db "Plant@"
.poster   db "Poster@"
.game     db "Game Console@"
.ornament db "Ornament@"
.big_doll db "Big Doll@"
.exit     db "Exit@"

.FindCategoriesWithOwnedDecos:
	xor a
	ld [wWhichIndexSet], a
	call .ClearStringBuffer2
	call .FindOwndDecos
	ld a, 7
	call .AppendToStringBuffer2
	ld hl, wStringBuffer2
	ld de, wd002
	ld bc, ITEM_NAME_LENGTH
	call CopyBytes
	ret

.ClearStringBuffer2:
	ld hl, wStringBuffer2
	xor a
	ld [hli], a
	ld bc, ITEM_NAME_LENGTH - 1
	ld a, -1
	call ByteFill
	ret

.AppendToStringBuffer2:
	ld hl, wStringBuffer2
	inc [hl]
	ld e, [hl]
	ld d, 0
	add hl, de
	ld [hl], a
	ret

.FindOwndDecos:
	ld hl, .dw
.loop
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	or e
	jr z, .done
	push hl
	call _de_
	pop hl
	jr nc, .next
	ld a, [hl]
	push hl
	call .AppendToStringBuffer2
	pop hl
.next
	inc hl
	jr .loop
.done
	ret

.dw
	dwb FindOwnedBeds, 0 ; bed
	dwb FindOwnedCarpets, 1 ; carpet
	dwb FindOwnedPlants, 2 ; plant
	dwb FindOwnedPosters, 3 ; poster
	dwb FindOwnedConsoles, 4 ; game console
	dwb FindOwnedOrnaments, 5 ; ornament
	dwb FindOwnedBigDolls, 6 ; big doll
	dw 0 ; end

Deco_FillTempWithMinusOne:
	xor a
	ld hl, wd002
	ld [hli], a
	ld a, -1
	ld bc, $10
	call ByteFill
	ret

CheckAllDecorationFlags:
.loop
	ld a, [hli]
	cp -1
	jr z, .done
	push hl
	push af
	ld b, CHECK_FLAG
	call DecorationFlagAction
	ld a, c
	and a
	pop bc
	ld a, b
	call nz, AppendDecoIndex
	pop hl
	jr .loop

.done
	ret

AppendDecoIndex:
	ld hl, wd002
	inc [hl]
	ld e, [hl]
	ld d, $0
	add hl, de
	ld [hl], a
	ret

FindOwnedDecosInCategory:
	push bc
	push hl
	call Deco_FillTempWithMinusOne
	pop hl
	call CheckAllDecorationFlags
	pop bc
	ld a, [wd002]
	and a
	ret z

	ld a, c
	call AppendDecoIndex
	ld a, 0
	call AppendDecoIndex
	scf
	ret

DecoBedMenu:
	call FindOwnedBeds
	call PopulateDecoCategoryMenu
	xor a
	ret

FindOwnedBeds:
	ld hl, .beds
	ld c, BEDS
	jp FindOwnedDecosInCategory

.beds
	db DECO_FEATHERY_BED ; 2
	db DECO_PINK_BED ; 3
	db DECO_POLKADOT_BED ; 4
	db DECO_PIKACHU_BED ; 5
	db -1

DecoCarpetMenu:
	call FindOwnedCarpets
	call PopulateDecoCategoryMenu
	xor a
	ret

FindOwnedCarpets:
	ld hl, .carpets
	ld c, CARPETS
	jp FindOwnedDecosInCategory

.carpets
	db DECO_RED_CARPET ; 7
	db DECO_BLUE_CARPET ; 8
	db DECO_YELLOW_CARPET ; 9
	db DECO_GREEN_CARPET ; a
	db -1

DecoPlantMenu:
	call FindOwnedPlants
	call PopulateDecoCategoryMenu
	xor a
	ret

FindOwnedPlants:
	ld hl, .plants
	ld c, PLANTS
	jp FindOwnedDecosInCategory

.plants
	db DECO_MAGNAPLANT ; c
	db DECO_TROPICPLANT ; d
	db DECO_JUMBOPLANT ; e
	db -1

DecoPosterMenu:
	call FindOwnedPosters
	call PopulateDecoCategoryMenu
	xor a
	ret

FindOwnedPosters:
	ld hl, .posters
	ld c, POSTERS
	jp FindOwnedDecosInCategory

.posters
	db DECO_TOWN_MAP ; 10
	db DECO_PIKACHU_POSTER ; 11
	db DECO_CLEFAIRY_POSTER ; 12
	db DECO_JIGGLYPUFF_POSTER ; 13
	db -1

DecoConsoleMenu:
	call FindOwnedConsoles
	call PopulateDecoCategoryMenu
	xor a
	ret

FindOwnedConsoles:
	ld hl, .consoles
	ld c, CONSOLES
	jp FindOwnedDecosInCategory

.consoles
	db DECO_FAMICOM ; 15
	db DECO_SNES ; 16
	db DECO_N64 ; 17
	db DECO_VIRTUAL_BOY ; 18
	db -1

DecoOrnamentMenu:
	call FindOwnedOrnaments
	call PopulateDecoCategoryMenu
	xor a
	ret

FindOwnedOrnaments:
	ld hl, .ornaments
	ld c, DOLLS
	jp FindOwnedDecosInCategory

.ornaments
	db DECO_PIKACHU_DOLL ; 1e
	db DECO_SURF_PIKACHU_DOLL ; 1f
	db DECO_CLEFAIRY_DOLL ; 20
	db DECO_JIGGLYPUFF_DOLL ; 21
	db DECO_BULBASAUR_DOLL ; 22
	db DECO_CHARMANDER_DOLL ; 23
	db DECO_SQUIRTLE_DOLL ; 24
	db DECO_POLIWAG_DOLL ; 25
	db DECO_DIGLETT_DOLL ; 26
	db DECO_STARMIE_DOLL ; 27
	db DECO_MAGIKARP_DOLL ; 28
	db DECO_KOTORA_DOLL ; 29
	db DECO_GENGAR_DOLL ; 2a
	db DECO_CYNDAQUIL_DOLL ; 2b
	db DECO_SWABLU_DOLL ; 2c
	db DECO_LOTAD_DOLL ; 2d
	db DECO_CHIKORITA_DOLL ; 2e
	db DECO_UNOWN_DOLL ; 2f
	db DECO_SKARMINI_DOLL ; 30
	db DECO_TOTODILE_DOLL ; 31
	db DECO_RATTATA_DOLL ; 32
	db DECO_DRATINI_DOLL
	db DECO_LARVITAR_DOLL
	db DECO_GOLD_TROPHY_DOLL ; 33
	db DECO_SILVER_TROPHY_DOLL ; 34
	db -1

DecoBigDollMenu:
	call FindOwnedBigDolls
	call PopulateDecoCategoryMenu
	xor a
	ret

FindOwnedBigDolls:
	ld hl, .big_dolls
	ld c, BIG_DOLLS
	jp FindOwnedDecosInCategory

.big_dolls
	db DECO_BIG_SNORLAX_DOLL ; 1a
	db DECO_BIG_ONIX_DOLL ; 1b
	db DECO_BIG_LAPRAS_DOLL ; 1c
	db DECO_BIG_SALAMENCE_DOLL
	db -1

DecoExitMenu:
	scf
	ret

PopulateDecoCategoryMenu:
	ld a, [wd002]
	and a
	jr z, .empty
	cp 8
	jr nc, .beyond_eight
	xor a
	ld [wWhichIndexSet], a
	ld hl, .NonscrollingMenuHeader
	call LoadMenuHeader
	call DoNthMenu
	jr c, .no_action_1
	call DoDecorationAction2

.no_action_1
	call ExitMenu
	ret

.beyond_eight
	ld hl, wd002
	ld e, [hl]
	dec [hl]
	ld d, 0
	add hl, de
	ld [hl], -1
	call LoadStandardMenuHeader
	ld hl, .ScrollingMenuHeader
	call CopyMenuHeader
	xor a
	ldh [hBGMapMode], a
	call InitScrollingMenu
	xor a
	ld [wMenuScrollPosition], a
	call ScrollingMenu
	ld a, [wMenuJoypad]
	cp 2
	jr z, .no_action_2
	call DoDecorationAction2

.no_action_2
	call ExitMenu
	ret

.empty
	ld hl, .Text_nothing_to_choose
	call MenuTextboxBackup
	ret

.Text_nothing_to_choose:
	; There's nothing to choose.
	text_far _NothingToChooseText
	text_end

.NonscrollingMenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, SCREEN_WIDTH - 1, SCREEN_HEIGHT - 1
	dw .NonscrollingMenuData
	db 1 ; default option

.NonscrollingMenuData:
	db STATICMENU_CURSOR | STATICMENU_WRAP ; flags
	db 0 ; items
	dw wd002
	dw DecorationMenuFunction
	dw DecorationAttributes

.ScrollingMenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 1, 1, SCREEN_WIDTH - 2, SCREEN_HEIGHT - 2
	dw .ScrollingMenuData
	db 1 ; default option

.ScrollingMenuData:
	db SCROLLINGMENU_DISPLAY_ARROWS ; flags
	db 8, 0 ; rows, columns
	db SCROLLINGMENU_ITEMS_NORMAL ; item format
	dbw 0, wd002 ; text pointer
	dba DecorationMenuFunction
	dbw 0, 0
	dbw 0, 0

GetDecorationData:
	ld hl, DecorationAttributes
	ld bc, 6
	call AddNTimes
	ret

GetDecorationName:
	push hl
	call GetDecorationData
	call GetDecoName
	pop hl
	call CopyName2
	ret

DecorationMenuFunction:
	ld a, [wMenuSelection]
	push de
	call GetDecorationData
	call GetDecoName
	pop hl
	call PlaceString
	ret

DoDecorationAction2:
	ld a, [wMenuSelection]
	call GetDecorationData
	ld de, 2 ; function 2
	add hl, de
	ld a, [hl]
	ld hl, .DecoActions
	rst JumpTable
	ret

.DecoActions:
	dw DecoAction_nothing
	dw DecoAction_setupbed
	dw DecoAction_putawaybed
	dw DecoAction_setupcarpet
	dw DecoAction_putawaycarpet
	dw DecoAction_setupplant
	dw DecoAction_putawayplant
	dw DecoAction_setupposter
	dw DecoAction_putawayposter
	dw DecoAction_setupconsole
	dw DecoAction_putawayconsole
	dw DecoAction_setupbigdoll
	dw DecoAction_putawaybigdoll
	dw DecoAction_setupornament
	dw DecoAction_putawayornament

GetDecorationFlag:
	call GetDecorationData
	ld de, 3 ; event flag
	add hl, de
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ret

DecorationFlagAction:
	push bc
	call GetDecorationFlag
	pop bc
	call EventFlagAction
	ret

GetDecorationSprite:
	ld a, c
	call GetDecorationData
	ld de, 5 ; sprite
	add hl, de
	ld a, [hl]
	ld c, a
	ret

INCLUDE "data/decorations/attributes.asm"

INCLUDE "data/decorations/names.asm"

GetDecoName:
	ld a, [hli]
	ld e, [hl]
	ld bc, wStringBuffer2
	push bc
	ld hl, .NameFunctions
	rst JumpTable
	pop de
	ret

.NameFunctions:
	dw .invalid
	dw .plant
	dw .bed
	dw .carpet
	dw .poster
	dw .doll
	dw .bigdoll

.invalid
	ret

.plant
	ld a, e
	jr .getdeconame

.bed
	call .plant
	ld a, _BED
	jr .getdeconame

.carpet
	call .plant
	ld a, _CARPET
	jr .getdeconame

.poster
	ld a, e
	call .getpokename
	ld a, _POSTER
	jr .getdeconame

.doll
	ld a, e
	call .getpokename
	ld a, _DOLL
	jr .getdeconame

.bigdoll
	push de
	ld a, BIG_
	call .getdeconame
	pop de
	ld a, e
	jr .getpokename

.getpokename
	push bc
	ld c, a
	ld b, 0
	ld hl, DecorationAttributePokemonNames
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call GetPokemonIDFromIndex
	ld [wNamedObjectIndexBuffer], a
	call GetPokemonName
	pop bc
	jr .copy

.getdeconame
	call ._getdeconame
	jr .copy

._getdeconame
	push bc
	ld hl, DecorationNames
	call GetNthString
	ld d, h
	ld e, l
	pop bc
	ret

.copy
	ld h, b
	ld l, c
	call CopyName2
	dec hl
	ld b, h
	ld c, l
	ret

DecoAction_nothing:
	scf
	ret

DecoAction_setupbed:
	ld hl, wDecoBed
	jp DecoAction_TrySetItUp

DecoAction_putawaybed:
	ld hl, wDecoBed
	jp DecoAction_TryPutItAway

DecoAction_setupcarpet:
	ld hl, wDecoCarpet
	jp DecoAction_TrySetItUp

DecoAction_putawaycarpet:
	ld hl, wDecoCarpet
	jp DecoAction_TryPutItAway

DecoAction_setupplant:
	ld hl, wDecoPlant
	jp DecoAction_TrySetItUp

DecoAction_putawayplant:
	ld hl, wDecoPlant
	jp DecoAction_TryPutItAway

DecoAction_setupposter:
	ld hl, wDecoPoster
	jp DecoAction_TrySetItUp

DecoAction_putawayposter:
	ld hl, wDecoPoster
	jp DecoAction_TryPutItAway

DecoAction_setupconsole:
	ld hl, wDecoConsole
	jp DecoAction_TrySetItUp

DecoAction_putawayconsole:
	ld hl, wDecoConsole
	jp DecoAction_TryPutItAway

DecoAction_setupbigdoll:
	ld hl, wDecoBigDoll
	jp DecoAction_TrySetItUp

DecoAction_putawaybigdoll:
	ld hl, wDecoBigDoll
	jp DecoAction_TryPutItAway

DecoAction_TrySetItUp:
	ld a, [hl]
	ld [wBuffer1], a
	push hl
	call DecoAction_SetItUp
	jr c, .failed
	ld a, 1
	ld [wBuffer5], a
	pop hl
	ld a, [wMenuSelection]
	ld [hl], a
	xor a
	ret

.failed
	pop hl
	xor a
	ret

DecoAction_SetItUp:
; See if there's anything of the same type already out
	ld a, [wBuffer1]
	and a
	jr z, .nothingthere
; See if that item is already out
	ld b, a
	ld a, [wMenuSelection]
	cp b
	jr z, .alreadythere
; Put away the item that's already out, and set up the new one
	ld a, [wMenuSelection]
	ld hl, wStringBuffer4
	call GetDecorationName
	ld a, [wBuffer1]
	ld hl, wStringBuffer3
	call GetDecorationName
	ld hl, DecoText_PutAwayAndSetUp
	call MenuTextboxBackup
	xor a
	ret

.nothingthere
	ld a, [wMenuSelection]
	ld hl, wStringBuffer3
	call GetDecorationName
	ld hl, DecoText_SetUpTheDeco
	call MenuTextboxBackup
	xor a
	ret

.alreadythere
	ld hl, DecoText_AlreadySetUp
	call MenuTextboxBackup
	scf
	ret

DecoAction_TryPutItAway:
; If there is no item of that type already set, there is nothing to put away.
	ld a, [hl]
	ld [wBuffer1], a
	xor a
	ld [hl], a
	ld a, [wBuffer1]
	and a
	jr z, .nothingthere
; Put it away.
	ld a, $1
	ld [wBuffer5], a
	ld a, [wBuffer1]
	ld [wMenuSelection], a
	ld hl, wStringBuffer3
	call GetDecorationName
	ld hl, DecoText_PutAwayTheDeco
	call MenuTextboxBackup
	xor a
	ret

.nothingthere
	ld hl, DecoText_NothingToPutAway
	call MenuTextboxBackup
	xor a
	ret

DecoAction_setupornament:
	ld hl, UnknownText_0x26e41
	call DecoAction_AskWhichSide
	jr c, .cancel
	call DecoAction_SetItUp_Ornament
	jr c, .cancel
	ld a, $1
	ld [wBuffer5], a
	jr DecoAction_FinishUp_Ornament

.cancel
	xor a
	ret

DecoAction_putawayornament:
	ld hl, DecoText_WhichSide
	call DecoAction_AskWhichSide
	jr nc, .incave
	xor a
	ret

.incave
	call DecoAction_PutItAway_Ornament

DecoAction_FinishUp_Ornament:
	call QueryWhichSide
	ld a, [wSelectedDecoration]
	ld [hl], a
	ld a, [wOtherDecoration]
	ld [de], a
	xor a
	ret

DecoAction_SetItUp_Ornament:
	ld a, [wSelectedDecoration]
	and a
	jr z, .nothingthere
	ld b, a
	ld a, [wMenuSelection]
	cp b
	jr z, .failed
	ld a, b
	ld hl, wStringBuffer3
	call GetDecorationName
	ld a, [wMenuSelection]
	ld hl, wStringBuffer4
	call GetDecorationName
	ld a, [wMenuSelection]
	ld [wSelectedDecoration], a
	call .getwhichside
	ld hl, DecoText_PutAwayAndSetUp
	call MenuTextboxBackup
	xor a
	ret

.nothingthere
	ld a, [wMenuSelection]
	ld [wSelectedDecoration], a
	call .getwhichside
	ld a, [wMenuSelection]
	ld hl, wStringBuffer3
	call GetDecorationName
	ld hl, DecoText_SetUpTheDeco
	call MenuTextboxBackup
	xor a
	ret

.failed
	ld hl, DecoText_AlreadySetUp
	call MenuTextboxBackup
	scf
	ret

.getwhichside
	ld a, [wMenuSelection]
	ld b, a
	ld a, [wOtherDecoration]
	cp b
	ret nz
	xor a
	ld [wOtherDecoration], a
	ret

UnknownText_0x26e41:
	; Which side do you want to put it on?
	text_far _WhichSidePutOnText
	text_end

DecoAction_PutItAway_Ornament:
	ld a, [wSelectedDecoration]
	and a
	jr z, .nothingthere
	ld hl, wStringBuffer3
	call GetDecorationName
	ld a, $1
	ld [wBuffer5], a
	xor a
	ld [wSelectedDecoration], a
	ld hl, DecoText_PutAwayTheDeco
	call MenuTextboxBackup
	xor a
	ret

.nothingthere
	ld hl, DecoText_NothingToPutAway
	call MenuTextboxBackup
	xor a
	ret

DecoText_WhichSide:
	; Which side do you want to put away?
	text_far _WhichSidePutAwayText
	text_end

DecoAction_AskWhichSide:
	call MenuTextbox
	ld hl, MenuHeader_0x26eab
	call GetMenu2
	call ExitMenu
	call CopyMenuData
	jr c, .nope
	ld a, [wMenuCursorY]
	cp 3
	jr z, .nope
	ld [wBuffer2], a
	call QueryWhichSide
	ld a, [hl]
	ld [wSelectedDecoration], a
	ld a, [de]
	ld [wOtherDecoration], a
	xor a
	ret

.nope
	scf
	ret

QueryWhichSide:
	ld hl, wDecoRightOrnament
	ld de, wDecoLeftOrnament
	ld a, [wBuffer2]
	cp 1
	ret z
	push hl
	ld h, d
	ld l, e
	pop de
	ret

MenuHeader_0x26eab:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 13, 7
	dw MenuData_0x26eb3
	db 1 ; default option

MenuData_0x26eb3:
	db STATICMENU_CURSOR ; flags
	db 3 ; items
	db "Right Side@"
	db "Left Side@"
	db "Cancel@"

DecoText_PutAwayTheDeco:
	; Put away the @ .
	text_far _PutAwayTheDecoText
	text_end

DecoText_NothingToPutAway:
	; There's nothing to put away.
	text_far _NothingToPutAwayText
	text_end

DecoText_SetUpTheDeco:
	; Set up the @ .
	text_far _SetUpTheDecoText
	text_end

DecoText_PutAwayAndSetUp:
	; Put away the @ and set up the @ .
	text_far _PutAwayAndSetUpText
	text_end

DecoText_AlreadySetUp:
	; That's already set up.
	text_far _AlreadySetUpText
	text_end

GetDecorationName_c_de:
	ld a, c
	ld h, d
	ld l, e
	call GetDecorationName
	ret

DecorationFlagAction_c:
	ld a, c
	jp DecorationFlagAction

GetDecorationName_c:
	ld a, c
	call GetDecorationID
	ld hl, wStringBuffer1
	push hl
	call GetDecorationName
	pop de
	ret

SetSpecificDecorationFlag:
	ld a, c
	call GetDecorationID
	ld b, SET_FLAG
	call DecorationFlagAction
	ret

GetDecorationID:
	push hl
	push de
	ld e, a
	ld d, 0
	ld hl, DecorationIDs
	add hl, de
	ld a, [hl]
	pop de
	pop hl
	ret

SetAllDecorationFlags:
	ld hl, DecorationIDs
.loop
	ld a, [hli]
	cp -1
	jr z, .done
	push hl
	ld b, SET_FLAG
	call DecorationFlagAction
	pop hl
	jr .loop

.done
	ret

INCLUDE "data/decorations/decorations.asm"

DescribeDecoration::
	ld a, b
	ld hl, .JumpTable
	rst JumpTable
	ret

.JumpTable:
; entries correspond to DECODESC_* constants
	dw DecorationDesc_Poster
	dw DecorationDesc_LeftOrnament
	dw DecorationDesc_RightOrnament
	dw DecorationDesc_GiantOrnament
	dw DecorationDesc_Console

DecorationDesc_Poster:
	ld a, [wDecoPoster]
	ld hl, DecorationDesc_PosterPointers
	ld de, 3
	call IsInArray
	jr c, .nope
	ld de, DecorationDesc_NullPoster
	ld b, BANK(DecorationDesc_NullPoster)
	ret

.nope
	ld b, BANK(DecorationDesc_TownMapPoster)
	inc hl
	ld a, [hli]
	ld d, [hl]
	ld e, a
	ret

DecorationDesc_PosterPointers:
	dbw DECO_TOWN_MAP, DecorationDesc_TownMapPoster
	dbw DECO_PIKACHU_POSTER, DecorationDesc_PikachuPoster
	dbw DECO_CLEFAIRY_POSTER, DecorationDesc_ClefairyPoster
	dbw DECO_JIGGLYPUFF_POSTER, DecorationDesc_JigglypuffPoster
	db -1

DecorationDesc_TownMapPoster:
	opentext
	writetext .TownMapText
	waitbutton
	special OverworldTownMap
	closetext
	end

.TownMapText:
	; It's the TOWN MAP.
	text_far _LookTownMapText
	text_end

DecorationDesc_PikachuPoster:
	jumptext .PikaPosterText

.PikaPosterText:
	; It's a poster of a cute PIKACHU.
	text_far _LookPikachuPosterText
	text_end

DecorationDesc_ClefairyPoster:
	jumptext .ClefairyPosterText

.ClefairyPosterText:
	; It's a poster of a cute CLEFAIRY.
	text_far _LookClefairyPosterText
	text_end

DecorationDesc_JigglypuffPoster:
	jumptext .JigglypuffPosterText

.JigglypuffPosterText:
	; It's a poster of a cute JIGGLYPUFF.
	text_far _LookJigglypuffPosterText
	text_end

DecorationDesc_NullPoster:
	end

DecorationDesc_LeftOrnament:
	ld a, [wDecoLeftOrnament]
	jr DecorationDesc_OrnamentOrConsole

DecorationDesc_RightOrnament:
	ld a, [wDecoRightOrnament]
	jr DecorationDesc_OrnamentOrConsole

DecorationDesc_Console:
	ld a, [wDecoConsole]
	ld c, a
	ld de, wStringBuffer3
	call GetDecorationName_c_de
	ld b, BANK(.OrnamentConsoleScript2)
	ld de, .OrnamentConsoleScript2
	ret

.OrnamentConsoleScript2:
	jumptext .OrnamentConsoleScript2Text

.OrnamentConsoleScript2Text:
	text_far _PlayedTheConsoleText
	text_end

DecorationDesc_OrnamentOrConsole:
	ld c, a
	ld de, wStringBuffer3
	call GetDecorationName_c_de
	ld b, BANK(.OrnamentConsoleScript)
	ld de, .OrnamentConsoleScript
	ret

.OrnamentConsoleScript:
	jumptext .OrnamentConsoleText

.OrnamentConsoleText:
	; It's an adorable @ .
	text_far _LookAdorableDecoText
	text_end

DecorationDesc_GiantOrnament:
	ld b, BANK(.BigDollScript)
	ld de, .BigDollScript
	ret

.BigDollScript:
	jumptext .BigDollText

.BigDollText:
	; A giant doll! It's fluffy and cuddly.
	text_far _LookGiantDecoText
	text_end

ToggleMaptileDecorations:
	; tile coordinates work the same way as for changeblock
	lb de, 0, 4 ; bed coordinates
	ld a, [wDecoBed]
	call SetDecorationTile
	lb de, 7, 4 ; plant coordinates
	ld a, [wDecoPlant]
	call SetDecorationTile
	lb de, 6, 0 ; poster coordinates
	ld a, [wDecoPoster]
	call SetDecorationTile
	call SetPosterVisibility
	lb de, 0, 0 ; carpet top-left coordinates
	call PadCoords_de
	ld a, [wDecoCarpet]
	and a
	ret z
	call _GetDecorationSprite
	ld [hl], a
	push af
	lb de, 0, 2 ; carpet bottom-left coordinates
	call PadCoords_de
	pop af
	inc a
	ld [hli], a ; carpet bottom-left block
	inc a
	ld [hli], a ; carpet bottom-middle block
	dec a
	ld [hl], a ; carpet bottom-right block
	ret

SetPosterVisibility:
	ld b, SET_FLAG
	ld a, [wDecoPoster]
	and a
	jr nz, .ok
	ld b, RESET_FLAG

.ok
	ld de, EVENT_PLAYERS_ROOM_POSTER
	jp EventFlagAction

SetDecorationTile:
	push af
	call PadCoords_de
	pop af
	and a
	ret z
	call _GetDecorationSprite
	ld [hl], a
	ret

ToggleDecorationsVisibility:
	ld de, EVENT_PLAYERS_HOUSE_2F_CONSOLE
	ld hl, wVariableSprites + SPRITE_CONSOLE - SPRITE_VARS
	ld a, [wDecoConsole]
	call ToggleDecorationVisibility
	ld de, EVENT_PLAYERS_HOUSE_2F_DOLL_1
	ld hl, wVariableSprites + SPRITE_DOLL_1 - SPRITE_VARS
	ld a, [wDecoLeftOrnament]
	call ToggleDecorationVisibility
	ld de, EVENT_PLAYERS_HOUSE_2F_DOLL_2
	ld hl, wVariableSprites + SPRITE_DOLL_2 - SPRITE_VARS
	ld a, [wDecoRightOrnament]
	call ToggleDecorationVisibility
	ld de, EVENT_PLAYERS_HOUSE_2F_BIG_DOLL
	ld hl, wVariableSprites + SPRITE_BIG_DOLL - SPRITE_VARS
	ld a, [wDecoBigDoll]
	call ToggleDecorationVisibility
	ret

ToggleDecorationVisibility:
	and a
	jr z, .hide
	call _GetDecorationSprite
	ld [hl], a
	ld b, RESET_FLAG
	jp EventFlagAction

.hide
	ld b, SET_FLAG
	jp EventFlagAction

_GetDecorationSprite:
	ld c, a
	push de
	push hl
	farcall GetDecorationSprite
	pop hl
	pop de
	ld a, c
	ret

PadCoords_de:
; adjusts coordinates, the same way as Script_changeblock
	ld a, d
	add 4
	ld d, a
	ld a, e
	add 4
	ld e, a
	call GetBlockLocation
	ret
