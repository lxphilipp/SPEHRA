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
          'SDG 1 aims to eradicate extreme poverty, ensure social protection, and promote equality and resilience for all by 2030. Extreme poverty is defined as surviving on less than \$2.15 per person per day. By 2030, 575 million may still live in extreme poverty.',
          'Over 4 billion people lack social protection, including vulnerable groups.',
          'Advanced economies invest more in essential services than developing ones.',
          'What you can do: Advocate for policies promoting inclusive growth and social protection to combat poverty',
          ' More Information at: '
        ],
        'links': [
          'https://sdgs.un.org/goals/goal1 ',
          'https://www.bmuv.de/themen/nachhaltigkeit/nachhaltigkeitsziele-sdgs/sdg-1-keine-armut',
          'https://www.un.org/sustainabledevelopment/poverty/ ',
        ],
      },
      {
        'image': 'assets/icons/17_SDG_Icons/2.png',
        'label': 'Zero Hunger',
        'description': [
          'SDG 2 is striving to achieve zero hunger by 2030, including addressing inequalities, transforming food systems, and mitigating the impact of conflict and the pandemic through coordinated efforts and policy solutions.',
          'In 2022, 45 million children suffered from wasting, 148 million faced stunted growth, and 37 million were overweight.',
          'A fundamental change in approach is necessary to meet the 2030 nutrition targets and ensure global food security.',
          'How to support this SDG: support local farmers, choose sustainable food, fight food waste, and use your voice as a consumer and voter to achieve Zero Hunger.',
          ' More Information at: '
        ],
        'links': [
          'https://sdgs.un.org/goals/goal2',
          'https://www.fao.org/zero-hunger',
          'https://www.wfp.org/',
        ],
      },
      {
        'image': 'assets/icons/17_SDG_Icons/3.png',
        'label': 'Good Health and Well-Being',
        'description': [
          'The aim is to end epidemics of AIDS, tuberculosis, malaria, and other communicable diseases by 2030, striving for universal health coverage and access to affordable medicines and vaccines for all',
          'Inequalities in healthcare access persist, exacerbated by crises like the COVID-19 pandemic. Childhood vaccinations have declined (68 million children are known to be un- or under-vaccinated as of 2022), and deaths from tuberculosis and malaria have risen.',
          'How to support this SDG: Promote personal and community health, advocate for quality healthcare access, and hold governments accountable for health commitments',
          ' More Information at: '
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
          'The goal is to provide free primary and secondary schooling by 2030, eliminate disparities, and ensure universal access to quality higher education.',
          'Progress towards quality education was slow pre-pandemic, worsened by COVID-19, leading to significant learning losses.',
          'Without additional measures, 84 million children may remain out of school by 2030, and around 300 million students could lack basic numeracy and literacy skills.',
          'How to support this SDG: Advocate for education as a priority, demand free and compulsory schooling for all, and support initiatives to improve teaching quality and infrastructure.',
          ' More Information at: '
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
          'This SDG aims to achieve gender equality and empower all women and girls for a peaceful, prosperous world.',
          'Women still face significant disparities, earning 23% less than men globally, bearing the burden of unpaid care work, and experiencing high rates of violence and exploitation.',
          'Without additional measures, it could take centuries to achieve gender equality in areas like child marriage, legal protection, leadership representation, and political participation.',
          'How to support this SDG: Support girls&apos; education, challenge biases, promote respectful relationships, advocate for policy change, and contribute to initiatives combating violence against women and girls.',
          ' More Information at: '
        ],
        'links': [
          'https://sdgs.un.org/goals/goal5 ',
          'https://unstats.un.org/sdgs/report/2022/goal-05/ ',
          'https://spotlightinitiative.org/',
          'https://www.unwomen.org/en',
        ],
      },
      {
        'image': 'assets/icons/17_SDG_Icons/6.png',
        'label': 'Clean Water and Sanitation',
        'description': [
          'The goal is to ensure the availability and sustainable management of water and sanitation for all.',
          'Safe water, sanitation, and hygiene are fundamental for health and well-being, but despite progress, 2.2 billion people still lacked safely managed drinking water services, 3.4 billion lacked safely managed sanitation services, and 1.9 billion lacked basic hygiene services in 2022, with water demand rising due to population growth and climate change.',
          'One in two countries still lacks effective frameworks for sustainable water management.',
          'How to support this SDG: Conserve water, practice good hygiene, and advocate for clean water and sanitation in your community.',
          ' More Information at: '
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
          'This SDG focuses on actions to ensure access to affordable, reliable, sustainable, and modern energy for all',
          'Despite progress, over 660 million people may still lack electricity, and close to 2 billion may rely on polluting fuels for cooking by 2030.',
          'How to support this SDG: Save electricity by unplugging appliances when not in use and using energy-efficient options. Advocate for renewable energy adoption in your community, and prioritize sustainable practices in your lifestyle choices.',
          ' More Information at: '
        ],
        'links': [
          'https://sdgs.un.org/goals/goal7',
          'https://unstats.un.org/sdgs/report/2022/goal-07/',
          'https://www.un.org/sustainabledevelopment/energy/',
          'https://www.worldbank.org/en/topic/energy/overview ',
        ],
      },
      {
        'image': 'assets/icons/17_SDG_Icons/8.png',
        'label': 'Decent Work and Economic Growth',
        'description': [
          'This SDG promotes sustained, inclusive, and sustainable economic growth, full and productive employment, and decent work for all',
          'Globally, nearly one in four (23.5%) young people were not in education, employment, or training (NEET) in 2022. Although this is a slight decrease since 2020, when the NEET rate was at an all-time high, it remains above the 2015 baseline of 22.2% and a long way from the 2030 target.',
          'How to Support this SDG: Advocate for policies that prioritize equitable pay and decent work opportunities, especially for young people and women. Support initiatives that invest in education and training to match labor market demands, ensuring access to social protection and basic services for all.',
          ' More Information at: '
        ],
        'links': [
          'https://sdgs.un.org/goals/goal8',
          'https://unstats.un.org/sdgs/report/2022/goal-08/',
          'https://www.un.org/sustainabledevelopment/economic-growth/',
          'https://www.worldbank.org/en/topic ',
        ],
      },
      {
        'image': 'assets/icons/17_SDG_Icons/9.png',
        'label': 'Industry, Innovation and Infrastructure ',
        'description': [
          'The goal is to modernize the infrastructure, to make it more sustainable, and to use resources more efficiently',
          'only 54% of the population use the internet. But in the least developed countries only 19% have access to the internet',
          '2 of 3 working places are newly created in the manufacturing industry',
          'the least developed countries only have a share of 1,15% in the world trade',
          ' More Information at: '
        ],
        'links': [
          'https://sdgs.un.org/goals/goal9 ',
          'https://www.bmuv.de/themen/nachhaltigkeit/nachhaltigkeitsziele-sdgs/sdg-9-industrie-innovation-und-infrastruktur ',
          'https://dashboards.sdgindex.org/rankings ',
          'https://www.bmz.de/de/agenda-2030/sdg-9 ',
          'https://www.un.org/sustainabledevelopment/infrastructure-industrialization/ ',
        ],
      },
      {
        'image': 'assets/icons/17_SDG_Icons/10.png',
        'label': 'Reduced Inequalities',
        'description': [
          'the 10th SDG aims to reduce income equalities and equalities based on politics, religion, sexual orientation, origins, and disabilities',
          'the poorest 40% have less than 25% of the international income',
          'over 100 million refugees are on the run ',
          '1 in 5 people has faced discrimination ',
          'the poorest 50% of the world only have 2% of the worldwide wealth',
          ' More Information at: '
        ],
        'links': [
          'https://sdgs.un.org/goals/goal10 ',
          'https://unric.org/de/17ziele/sdg-10/ ',
          'https://www.bmz.de/de/agenda-2030/sdg-10 ',
          'https://www.un.org/sustainabledevelopment/inequality/ ',
          'https://www.bundesregierung.de/breg-de/themen/nachhaltigkeitspolitik/weniger-ungleichheiten-1592836 '
        ],
      },
      {
        'image': 'assets/icons/17_SDG_Icons/11.png',
        'label': 'Sustainable Cities and Communities ',
        'description': [
          '25% of the world&apos;s population live in cities with a population of one million or more',
          'over one billion people live in slums or similar environments (2 billion more are expected in the next 30 years)',
          'by 2050 7 out of 10 people will live in cities',
          'Africa currently only has ⅓ of the infrastructure it will need by 2050',
          ' More Information at: '
        ],
        'links': [
          'https://www.bmz.de/de/agenda-2030/sdg-11 ',
          'https://sdgs.un.org/goals/goal11 ',
          'https://www.un.org/sustainabledevelopment/cities/ ',
          'https://www.bundesregierung.de/breg-de/themen/nachhaltigkeitspolitik/nachhaltige-staedte-gemeinden-1006538 ',
        ],
      },
      {
        'image': 'assets/icons/17_SDG_Icons/12.png',
        'label': 'Responsible Consumption and Production',
        'description': [
          '1,3 billion tons of food got wasted worldwide in 2023',
          '17% of all produced foods are thrown away',
          'on average, each person wastes 120 kilograms of food per year',
          'almost 14% of harvests are lost during harvesting, transport, storage, and processing',
          ' More Information at: '
        ],
        'links': [
          'https://www.bmz.de/de/agenda-2030/sdg-12 ',
          'https://sdgs.un.org/goals/goal12 ',
          'https://www.un.org/sustainabledevelopment/sustainable-consumption-production/ ',
          'https://www.bundesregierung.de/breg-de/themen/nachhaltigkeitspolitik/produzieren-konsumieren-181666 ',
        ],
      },
      {
        'image': 'assets/icons/17_SDG_Icons/13.png',
        'label': 'Climate Action',
        'description': [
          'Due to droughts over 700 million people could be displaced from their home regions by 2030',
          'If the climate change remains unchanged, the sea level will rise by 30-60 centimeters',
          'By 2030 another 132 million people could flee from climate change',
          'The rate of sea-level rise has doubled in the last decade',
          ' More Information at: '
        ],
        'links': [
          'https://sdgs.un.org/goals/goal13 ',
          'https://unric.org/de/17ziele/sdg-13/ ',
          'https://www.un.org/sustainabledevelopment/climate-change/ ',
          'https://www.bundesregierung.de/breg-de/themen/nachhaltigkeitspolitik/weltweit-klimaschutz-umsetzen-181812 ',
          'https://sdgs.un.org/goals/goal13 '
        ],
      },
      {
        'image': 'assets/icons/17_SDG_Icons/14.png',
        'label': 'Life Below Water',
        'description': [
          'More than a third of global fish stocks are overfished',
          '70% of the earth is sea, but only 8% is under nature conservation',
          'Almost 500 million depend on the fishing industry',
          'One in five fish caught originates from illegal, unreported, and unregulated fishing',
          ' More Information at: '
        ],
        'links': [
          'https://sdgs.un.org/goals/goal14 ',
          'https://www.bundesregierung.de/breg-de/themen/nachhaltigkeitspolitik/leben-unter-wasser-schuetzen-1522310 ',
          'https://www.bmz.de/de/agenda-2030/sdg-14 ',
          'https://www.un.org/sustainabledevelopment/oceans/ ',
        ],
      },
      {
        'image': 'assets/icons/17_SDG_Icons/15.png',
        'label': 'Life on Land',
        'description': [
          'The world is currently facing the largest species extinction since the dinosaur age ',
          '21% of all reptile species are endangered',
          'Only 17% of the global land areas are protected',
          'Between 2015 and 2019, the world has lost at least 100 million hectares of healthy land areas',
          ' More Information at: '
        ],
        'links': [
          'https://www.bundesregierung.de/breg-de/themen/nachhaltigkeitspolitik/leben-an-land-1642288 ',
          'https://www.un.org/sustainabledevelopment/biodiversity/ ',
          'https://www.bmz.de/de/agenda-2030/sdg-15',
          'https://sdgs.un.org/goals/goal15 ',
        ],
      },
      {
        'image': 'assets/icons/17_SDG_Icons/16.png',
        'label': 'Peace, Justice and Strong Institutions',
        'description': [
          'The 16th SDG aims to strengthen democracies, and the overall economy and to stabilize societies and laws.',
          '¼ of the global population lives in countries that are in conflict or in war',
          '80% of the global population lives in countries that are not or only partially free.',
          '70% of the victims of (mostly sexual) exploitation are women and girls',
          ' More Information at: '
        ],
        'links': [
          'https://unric.org/de/17ziele/sdg-16/ ',
          'https://www.un.org/sustainabledevelopment/peace-justice/',
          'https://sdgs.un.org/goals/goal16',
          'https://www.bundesregierung.de/breg-de/themen/nachhaltigkeitspolitik/institutionen-foerdern-199866',
        ],
      },
      {
        'image': 'assets/icons/17_SDG_Icons/17.png',
        'label': 'Partnership  for the Goals',
        'description': [
          'The goal of the last SGD is “to ensure no one is left behind” and to build global partnerships.',
          'In 2022, 2 in 3 people used the internet; but it was 259 million more male than female users',
          'Almost 4 trillion Euro are needed, if the developing countries want to reach the SDGs by 2030 ',
          'According to the UN geopolitical tensions and the rise of nationalism in some parts of the world have made it more difficult to achieve international cooperation and coordination',
          ' More Information at: '
        ],
        'links': [
          'https://www.bmz.de/de/agenda-2030/sdg-17 ',
          'https://www.un.org/sustainabledevelopment/globalpartnerships/ ',
          'https://sdgs.un.org/goals/goal17 ',
          'https://unric.org/de/17ziele/sdg-17/ ',
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
