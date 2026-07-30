/// Poort van `NutritionTips` uit TodayView.swift.
class NutritionTips {
  NutritionTips._();

  static const List<String> all = [
    'Wist je dat 1 appel ongeveer 4 g vezels bevat? Een makkelijke manier om dichter bij je dagdoel te komen.',
    'Wist je dat 100 g kipfilet ongeveer 31 g eiwit bevat? Ideaal voor spierherstel na het trainen.',
    'Volkoren brood bevat meer vezels dan wit brood. Dat houdt je langer verzadigd.',
    'Wist je dat 1 ei ongeveer 6 g eiwit bevat? Een goedkope eiwitbron bij elke maaltijd.',
    'Peulvruchten zoals linzen zijn rijk aan zowel eiwit als vezels. Een slimme, plantaardige eiwitbron.',
    'Magere kwark is een van de goedkoopste eiwitbronnen die er zijn.',
    'Wist je dat een banaan ongeveer 3 g vezels bevat? Handig vlak vóór of na het sporten.',
    'Voldoende vezels geven je langer een verzadigd gevoel.',
    'Noten zijn een goede bron van gezonde, onverzadigde vetten.',
    'Wist je dat 100 g Griekse yoghurt ongeveer 10 g eiwit bevat? Een prima eiwitrijk tussendoortje.',
    'Groenten met veel water, zoals komkommer, bevatten weinig calorieën maar geven wel een verzadigd gevoel.',
    'Havermout bevat een combinatie van vezels en langzame koolhydraten. Dat geeft je langdurig energie — ideaal voor duursporters.',
    'Spieren groeien tijdens rust, niet tijdens de training zelf.',
    'Een dieetpauze na een lange cut kan je metabolisme helpen herstellen.',
    'Je gewicht kan van dag tot dag schommelen doordat je vocht vasthoudt.',
    'Progressive overload — geleidelijk zwaarder trainen — is de sleutel tot spiergroei.',
    'Slaap is net zo belangrijk voor een goed herstel als je voeding.',
    'Consistentie gedurende weken of maanden is belangrijker dan die ene perfecte dag of week.',
    'Krachttraining tijdens een cut helpt om je spiermassa te behouden. Goed om te weten.',
    'Een te agressief tekort leidt vaker tot terugval dan een gematigd tekort.',
    'Wist je dat de tomaat botanisch gezien een fruit is, maar in de keuken als groente wordt behandeld?',
    'Wist je dat honing praktisch niet kan bederven — archeologen vonden ooit potten honing van duizenden jaren oud die nog eetbaar waren?',
    'Wist je dat pinda\'s eigenlijk peulvruchten zijn, geen noten?',
    'Wist je dat wortels van oorsprong paars waren, niet oranje?',
    'Wist je dat je smaakpapillen zich ongeveer elke twee weken vernieuwen?',
    'Wist je dat chocolademelk in de 17e eeuw oorspronkelijk als medicijn werd verkocht?',
  ];

  /// Kiest een tip op basis van uur + dag, zodat 'm ook binnen één dag al verschuift.
  static String tip(DateTime date) {
    final hour = date.hour;
    final dayOfYear = date.difference(DateTime(date.year)).inDays + 1;
    return all[(dayOfYear * 24 + hour) % all.length];
  }
}
