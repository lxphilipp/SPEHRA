import 'package:flutter/material.dart';

class NewInformation extends StatefulWidget {
  const NewInformation({super.key});

  @override
  State<NewInformation> createState() => _NewInformationState();
}

class _NewInformationState extends State<NewInformation> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> goals = [
      {
        'image': 'assets/icons/17_SDG_Icons/1.png',
        'label': 'Keine Armut',
        'description':
            'Ziel ist es hier, bis 2030 extreme Armut zu beseitigen, sozialen Schutz zu gewährleisten und Gleichheit und Widerstandsfähigkeit für alle zu fördern. Sobald eine Person mit weniger als 2,15 US-Dollar am Tag zu überleben hat, zählt sie als extreme Armut. Es können noch bis zu 575 Millionen Menschen in extremer Armut bis 2030 leben. Über 4 Milliarden Menschen sind nicht sozial abgesichert, darunter auch gefährdete Gruppen. Zum ****Beispiel: Kinder, Frauen und Mädchen, ältere Menschen, Menschen mit Behinderungen, Flüchtlinge, indigene Völker und ethnische Minderheiten, sowie Obdachlose . Mögliche Lösung: Für Politik einsetzen, die Ziele wie integratives Wachstum und sozialen Schutz fördern, um die Armut zu bekämpfen.',
      },
      {
        'image': 'assets/icons/17_SDG_Icons/2.png',
        'label': 'Kein Hunger',
        'description':
            'Hier müssen Nahrungsmittel Systeme umgestaltet werden, damit die Hungersnot verringert werden kann. Im Jahr 2022 leiden 230 Millionen Kindern an verschiedenen Krankheiten wie Auszehrung, Wachstumsverzögerungen und Übergewicht. Dafür sind grundlegende Wandel der Herangehensweise erforderlich. Mögliche Lösungen: lokale Landwirte unterstützen, nachhaltige Lebensmittel einkaufen und keine Lebensmittelverschwendung.',
      },
      {
        'image': 'assets/icons/17_SDG_Icons/3.png',
        'label': 'Gute Gesundheit und Wohlergehen',
        'description':
            'Es wird angestrebt, manche Krankheiten komplett zu vernichten, sowie eine allgemeine Gesundheitsversorgung und Impfstoffe für alle zugänglich zu machen. Die Ungleichheiten beim Zugang zur Gesundheitsversorgung werden nochmal durch Krisen, wie zum Beispiel die COVID-19-Pandemie, vor Augen gehalten. Es wird auch nochmal durch die Zahl der Impfungen im Kindesalter und die Zahl der Todesfälle durch Tuberkulose und Malaria, die erheblich gestiegen sind, ersichtlich. Mögliche Lösungen: individuelle und gemeinschaftliche Gesundheit zu unterstützen, sich für den Zugang zu einer hochwertigen medizinischen Versorgung zu engagieren und Regierungen dazu aufzufordern, ihre Gesundheit Zusagen einzuhalten.',
      },
      {
        'image': 'assets/icons/17_SDG_Icons/4.png',
        'label': 'Qualitative Bildung',
        'description':
            'Ziel ist es, eine kostenlose Grund- und Sekundarschulbildung anzubieten, sowie Ungleichheiten zu beseitigen und den allgemeinen Zugang zu einer hochwertigen Hochschulbildung zu gewährleisten. Vor der Pandemie verlief der Fortschritt in der Bildungsqualität nur schleppend. Die Auswirkungen von COVID-19 haben diese Situation weiter verschärft und zu erheblichen Lernrückständen geführt. Ohne gezielte Maßnahmen könnten bis 2030 rund 84 Millionen Kinder keinen Schulzugang erhalten, während etwa 300 Millionen Schüler grundlegende Lese- und Rechenfähigkeiten nicht erlernen könnten. So kann dieses SDG unterstützt werden: Mach dich für Bildung als zentrales Anliegen stark, setze dich für eine kostenlose und verpflichtende Schulbildung für alle ein und fördere Initiativen, die die Qualität des Unterrichts sowie die Bildungsinfrastruktur verbessern.',
      },
      {
        'image': 'assets/icons/17_SDG_Icons/5.png',
        'label': 'Gleichstellung der Geschlechter',
        'description':
            'Hier wird versucht, die Gleichstellung der Geschlechter zu erreichen.Frauen sind heutzutage noch immer mit erheblichen Ungleichheiten konfrontiert. Weltweit verdienen Frauen 23% weniger als Männer, übernehmen die Verantwortung für unbezahlte Pflegearbeit und sind in hohem Maße von Gewalt und Ausbeutung betroffen. Ohne gezielte Maßnahmen könnte es noch viele Generationen dauern, bis Gleichberechtigung in Bereichen wie Kinderheirat, Rechtsschutz, Führungspositionen und politischer Teilhabe vollständig verwirklicht ist. Um dieses SDG zu unterstützen, kann damit angefangen werden die Bildung von Mädchen zu unterstützen, Vorurteile in Frage zu stellen, sich für einen politischen Wandel einzusetzen und initiative zur Bekäpmfung von Gewalt gegen Frauen und Mädchen zu ergreifen.',
      },
      {
        'image': 'assets/icons/17_SDG_Icons/6.png',
        'label': 'Sauberes Wasser und sanitäre Einrichtungen',
        'description':
            'Es wird angestrebt, die Verfügbarkeit und nachhaltige Bewirtschaftung von Wasser und sanitären Einrichtungen für alle zu gewährleisten. Sauberes Wasser, Sanitärversorgung und Hygiene sind essentiell für die Gesundheit und das Wohlbefinden der Menschen. Trotz erzielter Fortschritte hatten im Jahr 2022 jedoch weiterhin 2,2 Milliarden Menschen keinen sicheren Zugang zu Trinkwasser, 3,4 Milliarden fehlten an angemessenen sanitären Einrichtungen, und 1,9 Milliarden konnten keine grundlegenden Hygienedienste nutzen. Gleichzeitig steigt der Wasserbedarf durch das Bevölkerungswachstum und den Klimawandel stetig an. 7. 8. 9. In der Hälfte aller Länder fehlt es nach wie vor an effektiven Strategien für eine nachhaltige Wasserbewirtschaftung. So kann dieses SDG unterstützt werden: Es soll sparsam mit Wasser umgegangen werden, auf gute Hygiene achten und sich für sauberes Wasser in der Gemeinde und bessere sanitäre Einrichtungen eingesetzt werden.',
      },
      {
        'image': 'assets/icons/17_SDG_Icons/7.png',
        'label': 'Bezahlbare und saubere Energie',
        'description':
            'Dieses SDG setzt sich dafür ein, allen Menschen den Zugang zu bezahlbarer, verlässlicher, nachhaltiger und moderner Energie zu ermöglichen. Trotz positiver Entwicklungen werden bis 2030 voraussichtlich noch über 660 Millionen Menschen ohne Zugang zu Strom sein. Zudem werden fast 2 Milliarden Menschen weiterhin auf gesundheitsschädliche und umweltbelastende Brennstoffe zum Kochen angewiesen sein. SDG kann auf diese Art und Weisen unterstützt werden: Energieverbrauch reduzieren, indem ungenutzte Geräte ausgeschaltet und auf energieeffiziente Alternativen gesetzt werden. Sich für den Ausbau erneuerbarer Energien in einer Gemeinde zu engagieren und nachhaltige Praktiken im Alltag zu integrieren.',
      },
      {
        'image': 'assets/icons/17_SDG_Icons/8.png',
        'label': 'Würdevolle Arbeit und Wirtschaftswachstum',
        'description':
            'Dieses SDG setzt sich für ein nachhaltiges und gerechtes Wirtschaftswachstum sowie für gute Arbeitsbedingungen und Beschäftigungsmöglichkeiten für alle ein. Im Jahr 2022 war fast jeder vierte junge Mensch (23,5 %) weder in Ausbildung noch in Beschäftigung oder Weiterbildung. Zwar ist das ein kleiner Rückgang im Vergleich zu 2020, als diese Zahl besonders hoch war, doch sie liegt immer noch über dem Wert von 2015 (22,2 %) und weit entfernt vom Ziel für 2030. SDG unterstützen: Sich für faire Löhne und bessere Arbeitschancen einsetzen, besonders für junge Menschen und Frauen. Bildungs- und Ausbildungsprogramme fördern, damit mehr Menschen Zugang zu guten Jobs bekommen und Maßnahmen für soziale Sicherheit und grundlegende Dienstleistungen für alle unterstützen.',
      },
      {
        'image': 'assets/icons/17_SDG_Icons/9.png',
        'label': 'Industrie, Innovation und Infrastruktur',
        'description':
            'Ziel ist es hier, die Infrastruktur zu modernisieren, sie nachhaltiger zu gestalten und die Ressourcen effizienter zu nutzen. Nur 54% der Bevölkerung nutzen das Internet. Diese Zahl verringert sich um einiges in den am wenigsten entwickelten Ländern, da nur 19% überhaupt Zugang zum Internet haben. In der Fertigungsindustrie werden nur 2 von 3 neu geschaffen. Die am wenigsten entwickelten Länder haben nur einen Anteil von 1,15% vom Welthandel.',
      },
      {
        'image': 'assets/icons/17_SDG_Icons/10.png',
        'label': 'Verringerte Ungleichheit',
        'description':
            'Hier wird darauf abgezielt, Einkommensunterschiede und Unterschiede aufgrund von Politik, Religion, sexueller Orientierung, Herkunft und Behinderung zu verringern. Die ärmsten 40% haben weniger als 25% des internationalen Einkommens über 100 Millionen Flüchtlinge sind auf der Flucht. Jeder 5te Mensch wurde einmal in seinem Leben diskriminiert und die ärmsten 50% der Welt verfügen nur über 2% des weltweiten Wohlstandes. ',
      },
      {
        'image': 'assets/icons/17_SDG_Icons/11.png',
        'label': 'Nachhaltige Städte und Gemeinden',
        'description':
            'Ein Viertel der Weltbevölkerung lebt in Städten mit mindestens einer Millionen Einwohnern. Über eine Milliarde Menschen wohnen in Slums oder vergleichbaren Siedlungen und in den nächsten 30 Jahren könnten weitere 2 Milliarden hinzukommen. Es werden voraussichtlich bis 2050 rund 70% der Weltbevölkerung in Städten leben und Afrika verfügt derzeit erst über ein Drittel der Infrastruktur, die bis dahin notwendig sein wird.',
      },
      {
        'image': 'assets/icons/17_SDG_Icons/12.png',
        'label': 'Verantwortungsvoller Verbrauch und Produktion',
        'description':
            'Im Jahr 2023 werden weltweit rund 1,3 Milliarden Tonnen Lebensmittel verschwendet, was etwa 17 % der gesamten produzierten Lebensmittel ausmacht. Jeder Mensch wirft im Durchschnitt 120 Kilogramm Lebensmittel pro Jahr weg. Darüber hinaus gehen fast 14 % der Ernten bereits bei der Ernte, dem Transport, der Lagerung und der Verarbeitung verloren. Diese enormen Verluste stellen ein ernstes Problem dar, das nicht nur die Umwelt belastet, sondern auch zur weltweiten Nahrungsmittelunsicherheit beiträgt..',
      },
      {
        'image': 'assets/icons/17_SDG_Icons/13.png',
        'label': 'Klimamaßnahmen',
        'description':
            'Wegen der zunehmenden Dürreperioden könnten bis 2030 mehr als 700 Millionen Menschen gezwungen sein, ihre Heimatregionen zu verlassen. Wenn der Klimawandel weiterhin ungebremst voranschreitet, wird der Meeresspiegel voraussichtlich um 30 bis 60 Zentimeter ansteigen. Darüber hinaus könnten bis 2030 zusätzlich etwa 132 Millionen Menschen vor den Auswirkungen des Klimawandels fliehen. Besorgniserregend ist auch, dass sich die Geschwindigkeit des Meeresspiegelanstiegs im vergangenen Jahrzehnt verdoppelt hat, was die Bedrohung für Küstenregionen und Inselstaaten weiter verstärkt.',
      },
      {
        'image': 'assets/icons/17_SDG_Icons/14.png',
        'label': 'Leben Unterwasser',
        'description':
            'Mehr als ein Drittel der weltweiten Fischbestände ist heute überfischt, was die marinen Ökosysteme und die Artenvielfalt gefährdet. Obwohl die Meere etwa 70 % der Erdoberfläche bedecken, stehen lediglich 8 % dieser Gewässer unter Naturschutz. Fast 500 Millionen Menschen sind direkt von der Fischereiindustrie abhängig, sei es für ihren Lebensunterhalt oder ihre Ernährung. Ein besonders besorgniserregender Aspekt ist, dass jeder fünfte gefangene Fisch aus illegaler, nicht gemeldeter und unregulierter Fischerei stammt, was den Druck auf die Meeresressourcen weiter erhöht und den nachhaltigen Fischfang erschwert.',
      },
      {
        'image': 'assets/icons/17_SDG_Icons/15.png',
        'label': 'Leben an Land',
        'description':
            'Die Welt steht derzeit vor dem größten Artensterben seit der Ära der Dinosaurier, was die biologische Vielfalt weltweit ernsthaft gefährdet. Etwa 21 % aller Reptilienarten sind vom Aussterben bedroht, und auch viele andere Tier- und Pflanzenarten sind in Gefahr. Trotz der Bedeutung des Naturschutzes sind lediglich 17 % der globalen Landflächen geschützt, was die Erhaltung der Artenvielfalt erschwert. Zwischen 2015 und 2019 hat die Menschheit mindestens 100 Millionen Hektar gesunde Landflächen verloren, was die ohnehin schon besorgniserregende Lage weiter verschärft.',
      },
      {
        'image': 'assets/icons/17_SDG_Icons/16.png',
        'label': 'Frieden, Gerechtigkeit und starke Institutionen',
        'description':
            'Das 16. SDG hat zum Ziel, Demokratien und die Wirtschaft zu stärken sowie die Gesellschaften und Rechtsstaatlichkeit zu stabilisieren. Aktuell lebt ein Viertel der Weltbevölkerung in Ländern, die sich in Konflikten oder Kriegen befinden, was zu großer Unsicherheit und Instabilität führt. Zudem leben 80 % der Weltbevölkerung in Ländern, die entweder nicht oder nur teilweise frei sind, was die Entwicklung von Demokratie und Menschenrechten erschwert. Besonders besorgniserregend ist, dass 70 % der Opfer von Ausbeutung, meist in Form von sexueller Gewalt, Frauen und Mädchen sind, was auf tief verwurzelte Ungleichheiten und Schutzlücken hinweist.',
      },
      {
        'image': 'assets/icons/17_SDG_Icons/17.png',
        'label': 'Partnerschaft für die Ziele',
        'description':
            'Das letzte SDG verfolgt das Ziel, „niemanden zurückzulassen“ und weltweit Partnerschaften zu fördern, um gemeinsam die Herausforderungen der nachhaltigen Entwicklung zu meistern. Im Jahr 2022 nutzten zwei von drei Menschen weltweit das Internet, doch es gibt immer noch eine erhebliche Geschlechterkluft, da 259 Millionen mehr Männer als Frauen online sind. Um die SDGs bis 2030 in den Entwicklungsländern zu erreichen, sind fast 4 Billionen Euro erforderlich, was die finanzielle Herausforderung deutlich macht. Zudem haben geopolitische Spannungen und der zunehmende Nationalismus in verschiedenen Teilen der Welt die internationale Zusammenarbeit und Koordination erschwert, was den Fortschritt bei der Umsetzung der globalen Ziele erheblich bremst.',
      },
    ];

    return Scaffold(
      backgroundColor: Color(0xff040324),
      appBar: AppBar(
        title: const Text(
          'Die 17 Ziele',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xff040324),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: goals.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final goal = goals[index];
            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Color(0xff040324),
                    title: Text(goal['label'],
                        style: TextStyle(color: Colors.white)),
                    content: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(goal['image']),
                            const SizedBox(height: 10),
                            Text(goal['description'],
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Zurück'),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Color(0xff040324),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xff040324),
                      blurRadius: 6,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(goal['image'], fit: BoxFit.cover),
                ),
              ),
            );
          },
        ),
      ),
    );
    ;
  }
}
