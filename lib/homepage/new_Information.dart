import 'package:flutter/material.dart';
import '../Chat/widgets/link_text.dart';

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
        'label': 'No Poverty',
        'description': [
          'SDG 1 aims to eradicate extreme poverty, ensure social protection, and promote equality and resilience for all by 2030.',
          'Extreme poverty is defined as surviving on less than \$2.15 per person per day.',
          'By 2030, 575 million may still live in extreme poverty.',
          'Over 4 billion people lack social protection, including vulnerable groups.',
          'What you can do: Advocate for policies promoting inclusive growth and social protection to combat poverty.'
        ],
        'links': [
          'https://sdgs.un.org/goals/goal1',
          'https://www.bmuv.de/themen/nachhaltigkeit/nachhaltigkeitsziele-sdgs/sdg-1-keine-armut',
          'https://www.un.org/sustainabledevelopment/poverty/',
        ],
      },
      {
        'image': 'assets/icons/17_SDG_Icons/2.png',
        'label': 'Zero Hunger',
        'description': [
          'SDG 2 is striving to achieve zero hunger by 2030, including addressing inequalities, transforming food systems, and mitigating the impact of conflict and the pandemic.',
          'In 2022, 45 million children suffered from wasting, 148 million faced stunted growth, and 37 million were overweight.',
          'A fundamental change in approach is necessary to meet the 2030 nutrition targets and ensure global food security.',
          'How to support this SDG: support local farmers, choose sustainable food, fight food waste, and use your voice as a consumer and voter.'
        ],
        'links': [
          'https://sdgs.un.org/goals/goal2',
          'https://www.fao.org/zero-hunger',
          'https://www.wfp.org/',
        ],
      },
      {
        'image': 'assets/icons/17_SDG_Icons/3.png',
        'label': 'Good Health and Well-being',
        'description': [
          'The aim is to end epidemics of AIDS, tuberculosis, malaria, and other communicable diseases by 2030.',
          'Striving for universal health coverage and access to affordable medicines and vaccines for all.',
          'Inequalities in healthcare access persist, exacerbated by crises like the COVID-19 pandemic.',
          'Childhood vaccinations have declined; 68 million children are under-vaccinated as of 2022.',
          'How to support this SDG: Promote health, advocate for access to care, and hold governments accountable.'
        ],
        'links': [
          'https://sdgs.un.org/goals/goal3',
          'https://unstats.un.org/sdgs/report/2022/Goal-03/',
          'https://www.un.org/sustainabledevelopment/health/',
          'https://www.who.int/',
        ],
      },
      {
        'image': 'assets/icons/17_SDG_Icons/4.png',
        'label': 'Quality Education',
        'description': [
          'The goal is to provide free primary and secondary schooling by 2030 and ensure access to quality higher education.',
          'Progress pre-pandemic was slow, and COVID-19 worsened learning outcomes.',
          'Without action, 84 million children may remain out of school by 2030.',
          'Around 300 million students could lack basic numeracy and literacy skills.',
          'Support this SDG: Advocate for education, free schooling, and improved teaching quality.'
        ],
        'links': [
          'https://sdgs.un.org/goals/goal4',
          'https://unstats.un.org/sdgs/report/2022/goal-04/',
          'https://www.unesco.org/en/sustainable-development/education',
        ],
      },
      {
        'image': 'assets/icons/17_SDG_Icons/5.png',
        'label': 'Gender Equality',
        'description': [
          'SDG 5 aims to achieve gender equality and empower all women and girls.',
          'Women still earn 23% less than men globally and bear unpaid care work.',
          'They also face high rates of violence and exploitation.',
          'Without additional measures, gender equality could take centuries.',
          'Support girls\' education, challenge biases, and promote respectful relationships.'
        ],
        'links': [
          'https://sdgs.un.org/goals/goal5',
          'https://unstats.un.org/sdgs/report/2022/goal-05/',
          'https://spotlightinitiative.org/',
          'https://www.unwomen.org/en',
        ],
      },
      {
        'image': 'assets/icons/17_SDG_Icons/6.png',
        'label': 'Clean Water and Sanitation',
        'description': [
          'Ensure availability and sustainable management of water and sanitation for all.',
          'In 2022, 2.2 billion people lacked safely managed drinking water.',
          '3.4 billion lacked safely managed sanitation, and 1.9 billion lacked basic hygiene services.',
          'Water demand is rising due to population growth and climate change.',
          'Support this SDG: Conserve water, practice good hygiene, and advocate for clean water access.'
        ],
        'links': [
          'https://unstats.un.org/sdgs/report/2022/goal-06/',
          'https://sdgs.un.org/goals/goal6',
          'https://www.unwater.org/',
          'https://www.un.org/en/observances/water-day',
        ],
      },
      {
        'image': 'assets/icons/17_SDG_Icons/7.png',
        'label': 'Affordable and Clean Energy',
        'description': [
          'Ensure access to affordable, reliable, sustainable, and modern energy for all.',
          'Over 660 million people may still lack electricity by 2030.',
          'Nearly 2 billion people rely on polluting fuels for cooking.',
          'Support this SDG: Save electricity, switch to energy-efficient devices, advocate for renewables, and adopt sustainable habits.'
        ],
        'links': [
          'https://sdgs.un.org/goals/goal7',
          'https://unstats.un.org/sdgs/report/2022/goal-07/',
          'https://www.un.org/sustainabledevelopment/energy/',
          'https://www.worldbank.org/en/topic/energy/overview',
        ],
      },
      {
        'image': 'assets/icons/17_SDG_Icons/8.png',
        'label': 'Decent Work and Economic Growth',
        'description': [
          'Promote sustained, inclusive, and sustainable economic growth, full and productive employment, and decent work for all.',
          'In 2022, 23.5% of young people were not in education, employment, or training (NEET).',
          'This rate remains higher than the 2015 level.',
          'Support this SDG: Advocate for decent jobs, fair pay, especially for youth and women, and support education and training programs.'
        ],
        'links': [
          'https://sdgs.un.org/goals/goal8',
          'https://unstats.un.org/sdgs/report/2022/goal-08/',
          'https://www.un.org/sustainabledevelopment/economic-growth/',
          'https://www.worldbank.org/en/topic',
        ],
      },
      {
        'image': 'assets/icons/17_SDG_Icons/9.png',
        'label': 'Industry, Innovation and Infrastructure',
        'description': [
          'Modernize infrastructure to be more sustainable and efficient.',
          'Only 54% of the global population uses the internet; only 19% in least developed countries.',
          'Two out of three jobs are in manufacturing.',
          'Least developed countries have only 1.15% share in global trade.'
        ],
        'links': [
          'https://sdgs.un.org/goals/goal9',
          'https://www.bmuv.de/.../sdg-9-industrie-innovation-und-infrastruktur',
          'https://dashboards.sdgindex.org/rankings',
          'https://www.bmz.de/de/agenda-2030/sdg-9',
          'https://www.un.org/sustainabledevelopment/infrastructure-industrialization/',
        ],
      },
      {
        'image': 'assets/icons/17_SDG_Icons/10.png',
        'label': 'Reduced Inequalities',
        'description': [
          'Reduce income and other inequalities based on origin, politics, religion, etc.',
          'The poorest 40% have less than 25% of global income.',
          'Over 100 million refugees are displaced.',
          '1 in 5 people has faced discrimination.',
          'The poorest 50% of the world own just 2% of global wealth.'
        ],
        'links': [
          'https://sdgs.un.org/goals/goal10',
          'https://unric.org/de/17ziele/sdg-10/',
          'https://www.bmz.de/de/agenda-2030/sdg-10',
          'https://www.un.org/sustainabledevelopment/inequality/',
          'https://www.bundesregierung.de/.../weniger-ungleichheiten-1592836',
        ],
      },
      {
        'image': 'assets/icons/17_SDG_Icons/11.png',
        'label': 'Sustainable Cities and Communities',
        'description': [
          '25% of people live in cities with more than 1 million people.',
          'Over 1 billion live in slums; 2 billion more expected in 30 years.',
          'By 2050, 70% of people will live in urban areas.',
          'Africa currently has only one-third of the needed infrastructure by 2050.'
        ],
        'links': [
          'https://www.bmz.de/de/agenda-2030/sdg-11',
          'https://sdgs.un.org/goals/goal11',
          'https://www.un.org/sustainabledevelopment/cities/',
          'https://www.bundesregierung.de/.../nachhaltige-staedte-gemeinden-1006538',
        ],
      },
      {
        'image': 'assets/icons/17_SDG_Icons/12.png',
        'label': 'Responsible Consumption and Production',
        'description': [
          '1.3 billion tons of food were wasted worldwide in 2023.',
          '17% of produced food is thrown away.',
          'Each person wastes on average 120 kg of food annually.',
          '14% of crops are lost during harvesting, transport, or processing.'
        ],
        'links': [
          'https://www.bmz.de/de/agenda-2030/sdg-12',
          'https://sdgs.un.org/goals/goal12',
          'https://www.un.org/sustainabledevelopment/sustainable-consumption-production/',
          'https://www.bundesregierung.de/.../produzieren-konsumieren-181666',
        ],
      },
      {
        'image': 'assets/icons/17_SDG_Icons/13.png',
        'label': 'Climate Action',
        'description': [
          'Over 700 million people could be displaced due to droughts by 2030.',
          'If climate change continues, sea level could rise by 30–60 cm.',
          'By 2030, another 132 million could flee due to climate effects.',
          'Sea level rise has doubled in speed in the last decade.'
        ],
        'links': [
          'https://sdgs.un.org/goals/goal13',
          'https://unric.org/de/17ziele/sdg-13/',
          'https://www.un.org/sustainabledevelopment/climate-change/',
          'https://www.bundesregierung.de/.../weltweit-klimaschutz-umsetzen-181812',
        ],
      },
      {
        'image': 'assets/icons/17_SDG_Icons/14.png',
        'label': 'Life Below Water',
        'description': [
          'Over one-third of fish stocks are overfished, threatening ecosystems.',
          'Only 8% of oceans are under protection despite covering 70% of Earth.',
          'Nearly 500 million people depend on fisheries.',
          '1 in 5 fish is from illegal, unreported, and unregulated sources.'
        ],
        'links': [
          'https://sdgs.un.org/goals/goal14',
          'https://www.bundesregierung.de/.../leben-unter-wasser-schuetzen-1522310',
          'https://www.bmz.de/de/agenda-2030/sdg-14',
          'https://www.un.org/sustainabledevelopment/oceans/',
        ],
      },
      {
        'image': 'assets/icons/17_SDG_Icons/15.png',
        'label': 'Life on Land',
        'description': [
          'The planet faces the largest extinction since the dinosaurs.',
          '21% of all reptiles are endangered.',
          'Only 17% of land areas are protected.',
          'From 2015 to 2019, 100 million hectares of healthy land were lost.'
        ],
        'links': [
          'https://www.bundesregierung.de/.../leben-an-land-1642288',
          'https://www.un.org/sustainabledevelopment/biodiversity/',
          'https://www.bmz.de/de/agenda-2030/sdg-15',
          'https://sdgs.un.org/goals/goal15',
        ],
      },
      {
        'image': 'assets/icons/17_SDG_Icons/16.png',
        'label': 'Peace, Justice and Strong Institutions',
        'description': [
          'SDG 16 aims to strengthen democracies, economies, and legal systems.',
          '¼ of global population lives in conflict or war.',
          '80% of people live in countries that are not fully free.',
          '70% of exploitation victims are women and girls.'
        ],
        'links': [
          'https://unric.org/de/17ziele/sdg-16/',
          'https://www.un.org/sustainabledevelopment/peace-justice/',
          'https://sdgs.un.org/goals/goal16',
          'https://www.bundesregierung.de/.../institutionen-foerdern-199866',
        ],
      },
      {
        'image': 'assets/icons/17_SDG_Icons/17.png',
        'label': 'Partnerships for the Goals',
        'description': [
          'The goal is to ensure no one is left behind and foster global partnerships.',
          'In 2022, 2 in 3 people used the internet; men outnumbered women by 259 million.',
          'Almost €4 trillion are needed in developing countries to meet the SDGs.',
          'Geopolitical tensions and nationalism hinder global cooperation.'
        ],
        'links': [
          'https://www.bmz.de/de/agenda-2030/sdg-17',
          'https://www.un.org/sustainabledevelopment/globalpartnerships/',
          'https://sdgs.un.org/goals/goal17',
          'https://unric.org/de/17ziele/sdg-17/',
        ],
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xff040324),
      appBar: AppBar(
        title: const Text(
          'The 17 Goals',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff040324),
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
                    backgroundColor: const Color(0xff040324),
                    title: Text(goal['label'],
                        style: const TextStyle(color: Colors.white)),
                    content: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(goal['image']),
                            const SizedBox(height: 10),
                            ...goal['description'].map<Widget>((line) =>
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text("• ",
                                          style:
                                              TextStyle(color: Colors.white)),
                                      Expanded(
                                          child: Text(line,
                                              style: const TextStyle(
                                                  color: Colors.white))),
                                    ],
                                  ),
                                )),
                            const SizedBox(height: 10),
                            const Text('More Information at:',
                                style: TextStyle(color: Colors.white)),
                            ...goal['links']
                                .map<Widget>((url) => LinkText(url)),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xff040324),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff040324),
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
  }
}
