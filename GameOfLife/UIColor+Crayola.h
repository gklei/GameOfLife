//
//*******
//
//	filename: UIColor+Crayola.h
//	author: Zack Brown
//	date: 28/10/2013
//*******
//

#import <UIKit/UIKit.h>

typedef enum
{
   CCN_crayolaAbsoluteZeroColor,
   CCN_crayolaAlienArmpitColor,
   CCN_crayolaAlloyOrangeColor,
   CCN_crayolaAlmondColor,
   CCN_crayolaAmethystColor,
   CCN_crayolaAntiqueBrassColor,
   CCN_crayolaApricotColor,
   CCN_crayolaAquaPearlColor,
   CCN_crayolaAquamarineColor,
   CCN_crayolaAsparagusColor,
   CCN_crayolaAtomicTangerineColor,
   CCN_crayolaAztecGoldColor,
   CCN_crayolaBabyPowderColor,
   CCN_crayolaBananaColor,
   CCN_crayolaBananaManiaColor,
   CCN_crayolaBdazzledBlueColor,
   CCN_crayolaBeaverColor,
   CCN_crayolaBigDipORubyColor,
   CCN_crayolaBigFootFeetColor,
   CCN_crayolaBittersweetColor,
   CCN_crayolaBittersweetShimmerColor,
   CCN_crayolaBlackColor,
   CCN_crayolaBlackCoralPearlColor,
   CCN_crayolaBlackShadowsColor,
   CCN_crayolaBlastOffBronzeColor,
   CCN_crayolaBlizzardBlueColor,
   CCN_crayolaBlueColor,
   CCN_crayolaBlueBellColor,
   CCN_crayolaBlueGrayColor,
   CCN_crayolaBlueGreenColor,
   CCN_crayolaBlueJeansColor,
   CCN_crayolaBlueVioletColor,
   CCN_crayolaBlueberryColor,
   CCN_crayolaBlushColor,
   CCN_crayolaBoogerBusterColor,
   CCN_crayolaBrickRedColor,
   CCN_crayolaBrightYellowColor,
   CCN_crayolaBrownColor,
   CCN_crayolaBrownSugarColor,
   CCN_crayolaBubbleGumColor,
   CCN_crayolaBurnishedBrownColor,
   CCN_crayolaBurntOrangeColor,
   CCN_crayolaBurntSiennaColor,
   CCN_crayolaCadetBlueColor,
   CCN_crayolaCanaryColor,
   CCN_crayolaCaribbeanGreenColor,
   CCN_crayolaCaribbeanGreenPearlColor,
   CCN_crayolaCarnationPinkColor,
   CCN_crayolaCedarChestColor,
   CCN_crayolaCeriseColor,
   CCN_crayolaCeruleanColor,
   CCN_crayolaCeruleanFrostColor,
   CCN_crayolaCherryColor,
   CCN_crayolaChestnutColor,
   CCN_crayolaChocolateColor,
   CCN_crayolaCinnamonSatinColor,
   CCN_crayolaCitrineColor,
   CCN_crayolaCoconutColor,
   CCN_crayolaCopperColor,
   CCN_crayolaCopperPennyColor,
   CCN_crayolaCornflowerColor,
   CCN_crayolaCosmicCobaltColor,
   CCN_crayolaCottonCandyColor,
   CCN_crayolaCulturedPearlColor,
   CCN_crayolaCyberGrapeColor,
   CCN_crayolaDaffodilColor,
   CCN_crayolaDandelionColor,
   CCN_crayolaDeepSpaceSparkleColor,
   CCN_crayolaDenimColor,
   CCN_crayolaDenimBlueColor,
   CCN_crayolaDesertSandColor,
   CCN_crayolaDingyDungeonColor,
   CCN_crayolaDirtColor,
   CCN_crayolaEerieBlackColor,
   CCN_crayolaEggplantColor,
   CCN_crayolaElectricLimeColor,
   CCN_crayolaEmeraldColor,
   CCN_crayolaEucalyptusColor,
   CCN_crayolaFernColor,
   CCN_crayolaFieryRoseColor,
   CCN_crayolaForestGreenColor,
   CCN_crayolaFreshAirColor,
   CCN_crayolaFrostbiteColor,
   CCN_crayolaFuchsiaColor,
   CCN_crayolaFuzzyWuzzyColor,
   CCN_crayolaGargoyleGasColor,
   CCN_crayolaGiantsClubColor,
   CCN_crayolaGlossyGrapeColor,
   CCN_crayolaGoldColor,
   CCN_crayolaGoldFusionColor,
   CCN_crayolaGoldenrodColor,
   CCN_crayolaGraniteGrayColor,
   CCN_crayolaGrannySmithAppleColor,
   CCN_crayolaGrapeColor,
   CCN_crayolaGrayColor,
   CCN_crayolaGreenColor,
   CCN_crayolaGreenBlueColor,
   CCN_crayolaGreenLizardColor,
   CCN_crayolaGreenSheenColor,
   CCN_crayolaGreenYellowColor,
   CCN_crayolaHeatWaveColor,
   CCN_crayolaHotMagentaColor,
   CCN_crayolaIlluminatingEmeraldColor,
   CCN_crayolaInchwormColor,
   CCN_crayolaIndigoColor,
   CCN_crayolaJadeColor,
   CCN_crayolaJasperColor,
   CCN_crayolaJazzberryJamColor,
   CCN_crayolaJellyBeanColor,
   CCN_crayolaJungleGreenColor,
   CCN_crayolaKeyLimePearlColor,
   CCN_crayolaLapisLazuliColor,
   CCN_crayolaLaserLemonColor,
   CCN_crayolaLavenderColor,
   CCN_crayolaLeatherJacketColor,
   CCN_crayolaLemonColor,
   CCN_crayolaLemonGlacierColor,
   CCN_crayolaLemonYellowColor,
   CCN_crayolaLicoriceColor,
   CCN_crayolaLilacColor,
   CCN_crayolaLilacLusterColor,
   CCN_crayolaLimeColor,
   CCN_crayolaLumberColor,
   CCN_crayolaMacaroniCheeseColor,
   CCN_crayolaMagentaColor,
   CCN_crayolaMagicMintColor,
   CCN_crayolaMagicPotionColor,
   CCN_crayolaMahoganyColor,
   CCN_crayolaMaizeColor,
   CCN_crayolaMalachiteColor,
   CCN_crayolaManateeColor,
   CCN_crayolaMandarinPearlColor,
   CCN_crayolaMangoTangoColor,
   CCN_crayolaMaroonColor,
   CCN_crayolaMauvelousColor,
   CCN_crayolaMelonColor,
   CCN_crayolaMetallicSeaweedColor,
   CCN_crayolaMetallicSunburstColor,
   CCN_crayolaMidnightBlueColor,
   CCN_crayolaMidnightPearlColor,
   CCN_crayolaMistyMossColor,
   CCN_crayolaMoonstoneColor,
   CCN_crayolaMountainMeadowColor,
   CCN_crayolaMulberryColor,
   CCN_crayolaMummysTombColor,
   CCN_crayolaMysticMaroonColor,
   CCN_crayolaMysticPearlColor,
   CCN_crayolaNavyBlueColor,
   CCN_crayolaNeonCarrotColor,
   CCN_crayolaNewCarColor,
   CCN_crayolaOceanBluePearlColor,
   CCN_crayolaOceanGreenPearlColor,
   CCN_crayolaOgreOdorColor,
   CCN_crayolaOliveGreenColor,
   CCN_crayolaOnyxColor,
   CCN_crayolaOrangeColor,
   CCN_crayolaOrangeRedColor,
   CCN_crayolaOrangeSodaColor,
   CCN_crayolaOrangeYellowColor,
   CCN_crayolaOrchidColor,
   CCN_crayolaOrchidPearlColor,
   CCN_crayolaOuterSpaceColor,
   CCN_crayolaOutrageousOrangeColor,
   CCN_crayolaPacificBlueColor,
   CCN_crayolaPeachColor,
   CCN_crayolaPearlyPurpleColor,
   CCN_crayolaPeridotColor,
   CCN_crayolaPeriwinkleColor,
   CCN_crayolaPewterBlueColor,
   CCN_crayolaPiggyPinkColor,
   CCN_crayolaPineColor,
   CCN_crayolaPineGreenColor,
   CCN_crayolaPinkFlamingoColor,
   CCN_crayolaPinkPearlColor,
   CCN_crayolaPinkSherbertColor,
   CCN_crayolaPixiePowderColor,
   CCN_crayolaPlumColor,
   CCN_crayolaPlumpPurpleColor,
   CCN_crayolaPolishedPineColor,
   CCN_crayolaPrincessPerfumeColor,
   CCN_crayolaPurpleHeartColor,
   CCN_crayolaPurpleMountainsMajestyColor,
   CCN_crayolaPurplePizzazzColor,
   CCN_crayolaPurplePlumColor,
   CCN_crayolaQuickSilverColor,
   CCN_crayolaRadicalRedColor,
   CCN_crayolaRawSiennaColor,
   CCN_crayolaRawUmberColor,
   CCN_crayolaRazzleDazzleRoseColor,
   CCN_crayolaRazzmatazzColor,
   CCN_crayolaRazzmicBerryColor,
   CCN_crayolaRedColor,
   CCN_crayolaRedOrangeColor,
   CCN_crayolaRedSalsaColor,
   CCN_crayolaRedVioletColor,
   CCN_crayolaRobinsEggBlueColor,
   CCN_crayolaRoseColor,
   CCN_crayolaRoseDustColor,
   CCN_crayolaRosePearlColor,
   CCN_crayolaRoseQuartzColor,
   CCN_crayolaRoyalPurpleColor,
   CCN_crayolaRubyColor,
   CCN_crayolaRustyRedColor,
   CCN_crayolaSalmonColor,
   CCN_crayolaSalmonPearlColor,
   CCN_crayolaSapphireColor,
   CCN_crayolaSasquatchSocksColor,
   CCN_crayolaScarletColor,
   CCN_crayolaScreaminGreenColor,
   CCN_crayolaSeaGreenColor,
   CCN_crayolaSeaSerpentColor,
   CCN_crayolaSepiaColor,
   CCN_crayolaShadowColor,
   CCN_crayolaShadowBlueColor,
   CCN_crayolaShampooColor,
   CCN_crayolaShamrockColor,
   CCN_crayolaSheenGreenColor,
   CCN_crayolaShimmeringBlushColor,
   CCN_crayolaShinyShamrockColor,
   CCN_crayolaShockingPinkColor,
   CCN_crayolaSilverColor,
   CCN_crayolaSizzlingRedColor,
   CCN_crayolaSizzlingSunriseColor,
   CCN_crayolaSkyBlueColor,
   CCN_crayolaSlimyGreenColor,
   CCN_crayolaSmashedPumpkinColor,
   CCN_crayolaSmokeColor,
   CCN_crayolaSmokeyTopazColor,
   CCN_crayolaSoapColor,
   CCN_crayolaSonicSilverColor,
   CCN_crayolaSpringFrostColor,
   CCN_crayolaSpringGreenColor,
   CCN_crayolaSteelBlueColor,
   CCN_crayolaSteelTealColor,
   CCN_crayolaStrawberryColor,
   CCN_crayolaSugarPlumColor,
   CCN_crayolaSunburntCyclopsColor,
   CCN_crayolaSunglowColor,
   CCN_crayolaSunnyPearlColor,
   CCN_crayolaSunsetOrangeColor,
   CCN_crayolaSunsetPearlColor,
   CCN_crayolaSweetBrownColor,
   CCN_crayolaTanColor,
   CCN_crayolaTartOrangeColor,
   CCN_crayolaTealBlueColor,
   CCN_crayolaThistleColor,
   CCN_crayolaTickleMePinkColor,
   CCN_crayolaTigersEyeColor,
   CCN_crayolaTimberwolfColor,
   CCN_crayolaTropicalRainForestColor,
   CCN_crayolaTulipColor,
   CCN_crayolaTumbleweedColor,
   CCN_crayolaTurquoiseBlueColor,
   CCN_crayolaTurquoisePearlColor,
   CCN_crayolaTwilightLavenderColor,
   CCN_crayolaUnmellowYellowColor,
   CCN_crayolaVioletBlueColor,
   CCN_crayolaVioletPurpleColor,
   CCN_crayolaVioletRedColor,
   CCN_crayolaVividTangerineColor,
   CCN_crayolaVividVioletColor,
   CCN_crayolaWhiteColor,
   CCN_crayolaWildBlueYonderColor,
   CCN_crayolaWildStrawberryColor,
   CCN_crayolaWildWatermelonColor,
   CCN_crayolaWinterSkyColor,
   CCN_crayolaWinterWizardColor,
   CCN_crayolaWintergreenDreamColor,
   CCN_crayolaWisteriaColor,
   CCN_crayolaYellowColor,
   CCN_crayolaYellowGreenColor,
   CCN_crayolaYellowOrangeColor,
   CCN_crayolaYellowSunshineColor,
} CrayolaColorName;

@interface UIColor (Crayola)

// wrap throught the color names
+ (CrayolaColorName)getPreviousColorName:(CrayolaColorName)colorName;
+ (CrayolaColorName)getNextColorName:(CrayolaColorName)colorName;

// get a color from a color name
+ (instancetype)colorForCrayolaColorName:(CrayolaColorName)colorName;
+ (instancetype)getPreviousColor:(CrayolaColorName)colorName;
+ (instancetype)getNextColor:(CrayolaColorName)colorName;


// crayola colors
+ (instancetype)crayolaAbsoluteZeroColor;
+ (instancetype)crayolaAlienArmpitColor;
+ (instancetype)crayolaAlloyOrangeColor;
+ (instancetype)crayolaAlmondColor;
+ (instancetype)crayolaAmethystColor;
+ (instancetype)crayolaAntiqueBrassColor;
+ (instancetype)crayolaApricotColor;
+ (instancetype)crayolaAquaPearlColor;
+ (instancetype)crayolaAquamarineColor;
+ (instancetype)crayolaAsparagusColor;
+ (instancetype)crayolaAtomicTangerineColor;
+ (instancetype)crayolaAztecGoldColor;
+ (instancetype)crayolaBabyPowderColor;
+ (instancetype)crayolaBananaColor;
+ (instancetype)crayolaBananaManiaColor;
+ (instancetype)crayolaBdazzledBlueColor;
+ (instancetype)crayolaBeaverColor;
+ (instancetype)crayolaBigDipORubyColor;
+ (instancetype)crayolaBigFootFeetColor;
+ (instancetype)crayolaBittersweetColor;
+ (instancetype)crayolaBittersweetShimmerColor;
+ (instancetype)crayolaBlackColor;
+ (instancetype)crayolaBlackCoralPearlColor;
+ (instancetype)crayolaBlackShadowsColor;
+ (instancetype)crayolaBlastOffBronzeColor;
+ (instancetype)crayolaBlizzardBlueColor;
+ (instancetype)crayolaBlueColor;
+ (instancetype)crayolaBlueBellColor;
+ (instancetype)crayolaBlueGrayColor;
+ (instancetype)crayolaBlueGreenColor;
+ (instancetype)crayolaBlueJeansColor;
+ (instancetype)crayolaBlueVioletColor;
+ (instancetype)crayolaBlueberryColor;
+ (instancetype)crayolaBlushColor;
+ (instancetype)crayolaBoogerBusterColor;
+ (instancetype)crayolaBrickRedColor;
+ (instancetype)crayolaBrightYellowColor;
+ (instancetype)crayolaBrownColor;
+ (instancetype)crayolaBrownSugarColor;
+ (instancetype)crayolaBubbleGumColor;
+ (instancetype)crayolaBurnishedBrownColor;
+ (instancetype)crayolaBurntOrangeColor;
+ (instancetype)crayolaBurntSiennaColor;
+ (instancetype)crayolaCadetBlueColor;
+ (instancetype)crayolaCanaryColor;
+ (instancetype)crayolaCaribbeanGreenColor;
+ (instancetype)crayolaCaribbeanGreenPearlColor;
+ (instancetype)crayolaCarnationPinkColor;
+ (instancetype)crayolaCedarChestColor;
+ (instancetype)crayolaCeriseColor;
+ (instancetype)crayolaCeruleanColor;
+ (instancetype)crayolaCeruleanFrostColor;
+ (instancetype)crayolaCherryColor;
+ (instancetype)crayolaChestnutColor;
+ (instancetype)crayolaChocolateColor;
+ (instancetype)crayolaCinnamonSatinColor;
+ (instancetype)crayolaCitrineColor;
+ (instancetype)crayolaCoconutColor;
+ (instancetype)crayolaCopperColor;
+ (instancetype)crayolaCopperPennyColor;
+ (instancetype)crayolaCornflowerColor;
+ (instancetype)crayolaCosmicCobaltColor;
+ (instancetype)crayolaCottonCandyColor;
+ (instancetype)crayolaCulturedPearlColor;
+ (instancetype)crayolaCyberGrapeColor;
+ (instancetype)crayolaDaffodilColor;
+ (instancetype)crayolaDandelionColor;
+ (instancetype)crayolaDeepSpaceSparkleColor;
+ (instancetype)crayolaDenimColor;
+ (instancetype)crayolaDenimBlueColor;
+ (instancetype)crayolaDesertSandColor;
+ (instancetype)crayolaDingyDungeonColor;
+ (instancetype)crayolaDirtColor;
+ (instancetype)crayolaEerieBlackColor;
+ (instancetype)crayolaEggplantColor;
+ (instancetype)crayolaElectricLimeColor;
+ (instancetype)crayolaEmeraldColor;
+ (instancetype)crayolaEucalyptusColor;
+ (instancetype)crayolaFernColor;
+ (instancetype)crayolaFieryRoseColor;
+ (instancetype)crayolaForestGreenColor;
+ (instancetype)crayolaFreshAirColor;
+ (instancetype)crayolaFrostbiteColor;
+ (instancetype)crayolaFuchsiaColor;
+ (instancetype)crayolaFuzzyWuzzyColor;
+ (instancetype)crayolaGargoyleGasColor;
+ (instancetype)crayolaGiantsClubColor;
+ (instancetype)crayolaGlossyGrapeColor;
+ (instancetype)crayolaGoldColor;
+ (instancetype)crayolaGoldFusionColor;
+ (instancetype)crayolaGoldenrodColor;
+ (instancetype)crayolaGraniteGrayColor;
+ (instancetype)crayolaGrannySmithAppleColor;
+ (instancetype)crayolaGrapeColor;
+ (instancetype)crayolaGrayColor;
+ (instancetype)crayolaGreenColor;
+ (instancetype)crayolaGreenBlueColor;
+ (instancetype)crayolaGreenLizardColor;
+ (instancetype)crayolaGreenSheenColor;
+ (instancetype)crayolaGreenYellowColor;
+ (instancetype)crayolaHeatWaveColor;
+ (instancetype)crayolaHotMagentaColor;
+ (instancetype)crayolaIlluminatingEmeraldColor;
+ (instancetype)crayolaInchwormColor;
+ (instancetype)crayolaIndigoColor;
+ (instancetype)crayolaJadeColor;
+ (instancetype)crayolaJasperColor;
+ (instancetype)crayolaJazzberryJamColor;
+ (instancetype)crayolaJellyBeanColor;
+ (instancetype)crayolaJungleGreenColor;
+ (instancetype)crayolaKeyLimePearlColor;
+ (instancetype)crayolaLapisLazuliColor;
+ (instancetype)crayolaLaserLemonColor;
+ (instancetype)crayolaLavenderColor;
+ (instancetype)crayolaLeatherJacketColor;
+ (instancetype)crayolaLemonColor;
+ (instancetype)crayolaLemonGlacierColor;
+ (instancetype)crayolaLemonYellowColor;
+ (instancetype)crayolaLicoriceColor;
+ (instancetype)crayolaLilacColor;
+ (instancetype)crayolaLilacLusterColor;
+ (instancetype)crayolaLimeColor;
+ (instancetype)crayolaLumberColor;
+ (instancetype)crayolaMacaroniCheeseColor;
+ (instancetype)crayolaMagentaColor;
+ (instancetype)crayolaMagicMintColor;
+ (instancetype)crayolaMagicPotionColor;
+ (instancetype)crayolaMahoganyColor;
+ (instancetype)crayolaMaizeColor;
+ (instancetype)crayolaMalachiteColor;
+ (instancetype)crayolaManateeColor;
+ (instancetype)crayolaMandarinPearlColor;
+ (instancetype)crayolaMangoTangoColor;
+ (instancetype)crayolaMaroonColor;
+ (instancetype)crayolaMauvelousColor;
+ (instancetype)crayolaMelonColor;
+ (instancetype)crayolaMetallicSeaweedColor;
+ (instancetype)crayolaMetallicSunburstColor;
+ (instancetype)crayolaMidnightBlueColor;
+ (instancetype)crayolaMidnightPearlColor;
+ (instancetype)crayolaMistyMossColor;
+ (instancetype)crayolaMoonstoneColor;
+ (instancetype)crayolaMountainMeadowColor;
+ (instancetype)crayolaMulberryColor;
+ (instancetype)crayolaMummysTombColor;
+ (instancetype)crayolaMysticMaroonColor;
+ (instancetype)crayolaMysticPearlColor;
+ (instancetype)crayolaNavyBlueColor;
+ (instancetype)crayolaNeonCarrotColor;
+ (instancetype)crayolaNewCarColor;
+ (instancetype)crayolaOceanBluePearlColor;
+ (instancetype)crayolaOceanGreenPearlColor;
+ (instancetype)crayolaOgreOdorColor;
+ (instancetype)crayolaOliveGreenColor;
+ (instancetype)crayolaOnyxColor;
+ (instancetype)crayolaOrangeColor;
+ (instancetype)crayolaOrangeRedColor;
+ (instancetype)crayolaOrangeSodaColor;
+ (instancetype)crayolaOrangeYellowColor;
+ (instancetype)crayolaOrchidColor;
+ (instancetype)crayolaOrchidPearlColor;
+ (instancetype)crayolaOuterSpaceColor;
+ (instancetype)crayolaOutrageousOrangeColor;
+ (instancetype)crayolaPacificBlueColor;
+ (instancetype)crayolaPeachColor;
+ (instancetype)crayolaPearlyPurpleColor;
+ (instancetype)crayolaPeridotColor;
+ (instancetype)crayolaPeriwinkleColor;
+ (instancetype)crayolaPewterBlueColor;
+ (instancetype)crayolaPiggyPinkColor;
+ (instancetype)crayolaPineColor;
+ (instancetype)crayolaPineGreenColor;
+ (instancetype)crayolaPinkFlamingoColor;
+ (instancetype)crayolaPinkPearlColor;
+ (instancetype)crayolaPinkSherbertColor;
+ (instancetype)crayolaPixiePowderColor;
+ (instancetype)crayolaPlumColor;
+ (instancetype)crayolaPlumpPurpleColor;
+ (instancetype)crayolaPolishedPineColor;
+ (instancetype)crayolaPrincessPerfumeColor;
+ (instancetype)crayolaPurpleHeartColor;
+ (instancetype)crayolaPurpleMountainsMajestyColor;
+ (instancetype)crayolaPurplePizzazzColor;
+ (instancetype)crayolaPurplePlumColor;
+ (instancetype)crayolaQuickSilverColor;
+ (instancetype)crayolaRadicalRedColor;
+ (instancetype)crayolaRawSiennaColor;
+ (instancetype)crayolaRawUmberColor;
+ (instancetype)crayolaRazzleDazzleRoseColor;
+ (instancetype)crayolaRazzmatazzColor;
+ (instancetype)crayolaRazzmicBerryColor;
+ (instancetype)crayolaRedColor;
+ (instancetype)crayolaRedOrangeColor;
+ (instancetype)crayolaRedSalsaColor;
+ (instancetype)crayolaRedVioletColor;
+ (instancetype)crayolaRobinsEggBlueColor;
+ (instancetype)crayolaRoseColor;
+ (instancetype)crayolaRoseDustColor;
+ (instancetype)crayolaRosePearlColor;
+ (instancetype)crayolaRoseQuartzColor;
+ (instancetype)crayolaRoyalPurpleColor;
+ (instancetype)crayolaRubyColor;
+ (instancetype)crayolaRustyRedColor;
+ (instancetype)crayolaSalmonColor;
+ (instancetype)crayolaSalmonPearlColor;
+ (instancetype)crayolaSapphireColor;
+ (instancetype)crayolaSasquatchSocksColor;
+ (instancetype)crayolaScarletColor;
+ (instancetype)crayolaScreaminGreenColor;
+ (instancetype)crayolaSeaGreenColor;
+ (instancetype)crayolaSeaSerpentColor;
+ (instancetype)crayolaSepiaColor;
+ (instancetype)crayolaShadowColor;
+ (instancetype)crayolaShadowBlueColor;
+ (instancetype)crayolaShampooColor;
+ (instancetype)crayolaShamrockColor;
+ (instancetype)crayolaSheenGreenColor;
+ (instancetype)crayolaShimmeringBlushColor;
+ (instancetype)crayolaShinyShamrockColor;
+ (instancetype)crayolaShockingPinkColor;
+ (instancetype)crayolaSilverColor;
+ (instancetype)crayolaSizzlingRedColor;
+ (instancetype)crayolaSizzlingSunriseColor;
+ (instancetype)crayolaSkyBlueColor;
+ (instancetype)crayolaSlimyGreenColor;
+ (instancetype)crayolaSmashedPumpkinColor;
+ (instancetype)crayolaSmokeColor;
+ (instancetype)crayolaSmokeyTopazColor;
+ (instancetype)crayolaSoapColor;
+ (instancetype)crayolaSonicSilverColor;
+ (instancetype)crayolaSpringFrostColor;
+ (instancetype)crayolaSpringGreenColor;
+ (instancetype)crayolaSteelBlueColor;
+ (instancetype)crayolaSteelTealColor;
+ (instancetype)crayolaStrawberryColor;
+ (instancetype)crayolaSugarPlumColor;
+ (instancetype)crayolaSunburntCyclopsColor;
+ (instancetype)crayolaSunglowColor;
+ (instancetype)crayolaSunnyPearlColor;
+ (instancetype)crayolaSunsetOrangeColor;
+ (instancetype)crayolaSunsetPearlColor;
+ (instancetype)crayolaSweetBrownColor;
+ (instancetype)crayolaTanColor;
+ (instancetype)crayolaTartOrangeColor;
+ (instancetype)crayolaTealBlueColor;
+ (instancetype)crayolaThistleColor;
+ (instancetype)crayolaTickleMePinkColor;
+ (instancetype)crayolaTigersEyeColor;
+ (instancetype)crayolaTimberwolfColor;
+ (instancetype)crayolaTropicalRainForestColor;
+ (instancetype)crayolaTulipColor;
+ (instancetype)crayolaTumbleweedColor;
+ (instancetype)crayolaTurquoiseBlueColor;
+ (instancetype)crayolaTurquoisePearlColor;
+ (instancetype)crayolaTwilightLavenderColor;
+ (instancetype)crayolaUnmellowYellowColor;
+ (instancetype)crayolaVioletBlueColor;
+ (instancetype)crayolaVioletPurpleColor;
+ (instancetype)crayolaVioletRedColor;
+ (instancetype)crayolaVividTangerineColor;
+ (instancetype)crayolaVividVioletColor;
+ (instancetype)crayolaWhiteColor;
+ (instancetype)crayolaWildBlueYonderColor;
+ (instancetype)crayolaWildStrawberryColor;
+ (instancetype)crayolaWildWatermelonColor;
+ (instancetype)crayolaWinterSkyColor;
+ (instancetype)crayolaWinterWizardColor;
+ (instancetype)crayolaWintergreenDreamColor;
+ (instancetype)crayolaWisteriaColor;
+ (instancetype)crayolaYellowColor;
+ (instancetype)crayolaYellowGreenColor;
+ (instancetype)crayolaYellowOrangeColor;
+ (instancetype)crayolaYellowSunshineColor;

@end
