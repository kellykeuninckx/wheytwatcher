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

/// Poort van `BluntCoachMessages` uit TodayView.swift: de botte tegenhanger van
/// [NutritionTips], gebruikt wanneer de "bot-als-een-baksteen"-modus aan staat.
class BluntCoachMessages {
  BluntCoachMessages._();

  /// Alleen tonen als er nog niet gelogd is vandaag — anders klopt de tekst niet.
  static const List<String> loggingReminders = [
    'Nog niet gelogd? De kaboutertjes gaan het niet voor je doen.',
    'Alweer vergeten te loggen? Het zal eens niet.',
    'Niet lullen, maar loggen!',
  ];

  static const List<String> general = [
    'Wil je nou gains of niet? Doe wat je moet doen dan, hop!',
    'Dat vetpercentage gaat niet vanzelf omlaag. Aan de bak, joh.',
    'Consistentie. Ooit van gehoord? Dacht ik al.',
  ];

  /// Botte versies van de voedingsfeitjes — zelfde feit, met een plagerige staart.
  static const List<String> bluntFactTips = [
    "Een appel heeft zo'n 4 g vezels. Dus waar wacht je nog op?",
    '100 g kipfilet levert je zo\'n 31 g eiwit. Aan de bak met die kip.',
    'Volkoren brood heeft meer vezels dan wit. Kies gewoon het volkoren, joh.',
    'Eén ei geeft je zo\'n 6 g eiwit. Bak er nog eentje bij, hop.',
    'Linzen zitten vol eiwit én vezels. Kom op, in de pan ermee.',
    'Magere kwark is spotgoedkoop eiwit. Geen excuus meer.',
    "Een banaan heeft zo'n 3 g vezels. Eet 'm nou gewoon op.",
    'Vezels houden je langer vol. Dus eet ze, in plaats van erover te lezen.',
    'Noten zitten vol gezonde vetten. Neem een handje, geen hele zak.',
    "100 g Griekse yoghurt geeft je zo'n 10 g eiwit. Simpel, toch?",
    "Komkommer en co. vullen goed voor weinig calorieën. Snap je 'm?",
    'Havermout geeft je langdurig energie. Ideaal voor duursporters — dus waar wacht je nog op?',
    'Spieren groeien tijdens rust, niet tijdens de training. Ga dus ook echt slapen.',
    "Een dieetpauze na een lange cut helpt je metabolisme herstellen. Neem 'm dan ook echt.",
    'Je gewicht schommelt door vocht. Niet elke dag paniekeren, joh.',
    'Geleidelijk zwaarder trainen is de sleutel tot spiergroei. Dus voeg dat gewichtje toe.',
    'Slaap is net zo belangrijk als je voeding. Ga op tijd naar bed, dan.',
    'Consistentie over weken telt, niet die ene perfecte dag. Blijf dus gewoon doorgaan.',
    'Krachttraining tijdens een cut behoudt je spiermassa. Sla die training dus niet over.',
    'Een te streng tekort leidt vaker tot terugval. Rustig aan dus, ja?',
  ];

  static String message(DateTime date, {required bool hasLoggedToday}) {
    final pool = hasLoggedToday ? [...general, ...bluntFactTips] : [...loggingReminders, ...general, ...bluntFactTips];
    final hour = date.hour;
    final dayOfYear = date.difference(DateTime(date.year)).inDays + 1;
    return pool[(dayOfYear * 24 + hour) % pool.length];
  }
}
