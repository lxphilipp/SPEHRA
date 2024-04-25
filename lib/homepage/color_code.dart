import 'package:flutter/material.dart';

class ColorCode extends StatelessWidget {
  const ColorCode({super.key});

  final fontType = 'OswaldLight';
  final double abstandContainerText = 15;
  final double width = 21;
  final double heigth = 21;
  final double fontsize = 17;
  final double abstand = 15;
  final double abstandObenContainer = 15;
  final double bordercurve = 5;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Erste Reihe
            Column(
              children: [
                Row(
                  children: [
                    Container(
                      height: heigth,
                      width: width,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xffE5243B), width: 3),
                          color: const Color(0xffE5243B).withOpacity(0.25),
                          borderRadius:
                              BorderRadius.all(Radius.circular(bordercurve))),
                    ),
                    SizedBox(
                      width: abstandContainerText,
                    ),
                    Column(
                      children: [
                        Text(
                          'goal 1',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: fontType,
                              fontSize: fontsize),
                        ),
                        /*  Text('No poverty',
                              style: TextStyle(
                                  color: Colors.white, fontFamily: fontType)) */
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: abstandObenContainer,
                ),
                Row(
                  children: [
                    Container(
                      height: heigth,
                      width: width,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xffDDA63A), width: 3),
                          color: const Color(0xffDDA63A).withOpacity(0.25),
                          borderRadius:
                              BorderRadius.all(Radius.circular(bordercurve))),
                    ),
                    SizedBox(
                      width: abstandContainerText,
                    ),
                    Column(
                      children: [
                        Text(
                          'goal 2',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: fontType,
                              fontSize: fontsize),
                        ),
                        /* Text('Zero hunger',
                              style: TextStyle(
                                  color: Colors.white, fontFamily: fontType)) */
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: abstandObenContainer,
                ),
                Row(
                  children: [
                    Container(
                      height: heigth,
                      width: width,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xff4c9F38), width: 3),
                          color: const Color(0xff4c9F38).withOpacity(0.25),
                          borderRadius:
                              BorderRadius.all(Radius.circular(bordercurve))),
                    ),
                    SizedBox(
                      width: abstandContainerText,
                    ),
                    Column(
                      children: [
                        Text(
                          'goal 3',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: fontType,
                              fontSize: fontsize),
                        ),
                        /* Text('Good health and well-beeing',
                              style: TextStyle(
                                  color: Colors.white, fontFamily: fontType)) */
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: abstandObenContainer,
                ),
                Row(
                  children: [
                    Container(
                      height: heigth,
                      width: width,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xffC5192D), width: 3),
                          color: const Color(0xffC5192D).withOpacity(0.25),
                          borderRadius:
                              BorderRadius.all(Radius.circular(bordercurve))),
                    ),
                    SizedBox(
                      width: abstandContainerText,
                    ),
                    Column(
                      children: [
                        Text(
                          'goal 4',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: fontType,
                              fontSize: fontsize),
                        ),
                        /* Text('Quality education',
                              style: TextStyle(
                                  color: Colors.white, fontFamily: fontType)) */
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: abstandObenContainer,
                ),
                Row(
                  children: [
                    Container(
                      height: heigth,
                      width: width,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xffFF3A21), width: 3),
                          color: const Color(0xffFF3A21).withOpacity(0.25),
                          borderRadius:
                              BorderRadius.all(Radius.circular(bordercurve))),
                    ),
                    SizedBox(
                      width: abstandContainerText,
                    ),
                    Column(
                      children: [
                        Text(
                          'goal 5',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: fontType,
                              fontSize: fontsize),
                        ),
                        /* Text('Good health and well-beeing',
                              style: TextStyle(
                                  color: Colors.white, fontFamily: fontType)) */
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: abstandObenContainer,
                ),
                Row(
                  children: [
                    Container(
                      height: heigth,
                      width: width,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xff26BDE2), width: 3),
                          color: const Color(0xff26BDE2).withOpacity(0.25),
                          borderRadius:
                              BorderRadius.all(Radius.circular(bordercurve))),
                    ),
                    SizedBox(
                      width: abstandContainerText,
                    ),
                    Column(
                      children: [
                        Text(
                          'goal 6',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: fontType,
                              fontSize: fontsize),
                        ),
                        /* Text('Quality education',
                              style: TextStyle(
                                  color: Colors.white, fontFamily: fontType)) */
                      ],
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(
              width: 60,
            ),
            //Zweite Reihe
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: heigth,
                      width: width,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xffFFC30B), width: 3),
                          color: const Color(0xffFFC30B).withOpacity(0.25),
                          borderRadius:
                              BorderRadius.all(Radius.circular(bordercurve))),
                    ),
                    SizedBox(
                      width: abstandContainerText,
                    ),
                    Column(
                      children: [
                        Text(
                          'goal 7',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: fontType,
                              fontSize: fontsize),
                        ),
                        /* Text('Good health and well-beeing',
                              style: TextStyle(
                                  color: Colors.white, fontFamily: fontType)) */
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: abstandObenContainer,
                ),
                Row(
                  children: [
                    Container(
                      height: heigth,
                      width: width,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xffA21942), width: 3),
                          color: const Color(0xffA21942).withOpacity(0.25),
                          borderRadius:
                              BorderRadius.all(Radius.circular(bordercurve))),
                    ),
                    SizedBox(
                      width: abstandContainerText,
                    ),
                    Column(
                      children: [
                        Text(
                          'goal 8',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: fontType,
                              fontSize: fontsize),
                        ),
                        /* Text('Quality education',
                              style: TextStyle(
                                  color: Colors.white, fontFamily: fontType)) */
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: abstandObenContainer,
                ),
                Row(
                  children: [
                    Container(
                      height: heigth,
                      width: width,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xffFD6925), width: 3),
                          color: const Color(0xffFD6925).withOpacity(0.25),
                          borderRadius:
                              BorderRadius.all(Radius.circular(bordercurve))),
                    ),
                    SizedBox(
                      width: abstandContainerText,
                    ),
                    Column(
                      children: [
                        Text(
                          'goal 9',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: fontType,
                              fontSize: fontsize),
                        ),
                        /* Text('Quality education',
                              style: TextStyle(
                                  color: Colors.white, fontFamily: fontType)) */
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: abstandObenContainer,
                ),
                Row(
                  children: [
                    Container(
                      height: heigth,
                      width: width,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xffDD1367), width: 3),
                          color: const Color(0xffDD1367).withOpacity(0.25),
                          borderRadius:
                              BorderRadius.all(Radius.circular(bordercurve))),
                    ),
                    SizedBox(
                      width: abstandContainerText,
                    ),
                    Column(
                      children: [
                        Text(
                          'goal 10',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: fontType,
                              fontSize: fontsize),
                        ),
                        /* Text('Quality education',
                              style: TextStyle(
                                  color: Colors.white, fontFamily: fontType)) */
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: abstandObenContainer,
                ),
                Row(
                  children: [
                    Container(
                      height: heigth,
                      width: width,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xffFD9D24), width: 3),
                          color: const Color(0xffFD9D24).withOpacity(0.25),
                          borderRadius:
                              BorderRadius.all(Radius.circular(bordercurve))),
                    ),
                    SizedBox(
                      width: abstandContainerText,
                    ),
                    Column(
                      children: [
                        Text(
                          'goal 11',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: fontType,
                              fontSize: fontsize),
                        ),
                        /* Text('Quality education',
                              style: TextStyle(
                                  color: Colors.white, fontFamily: fontType)) */
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: abstandObenContainer,
                ),
                Row(
                  children: [
                    Container(
                      height: heigth,
                      width: width,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xffBF8B2E), width: 3),
                          color: const Color(0xffBF8B2E).withOpacity(0.25),
                          borderRadius:
                              BorderRadius.all(Radius.circular(bordercurve))),
                    ),
                    SizedBox(
                      width: abstandContainerText,
                    ),
                    Column(
                      children: [
                        Text(
                          'goal 12',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: fontType,
                              fontSize: fontsize),
                        ),
                        /* Text('Quality education',
                              style: TextStyle(
                                  color: Colors.white, fontFamily: fontType)) */
                      ],
                    )
                  ],
                ),
                /*   SizedBox(
                  height: abstandObenContainer,
                ), */
              ],
            ),
            const SizedBox(
              width: 60,
            ),
            //Dritte Reihe
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: heigth,
                      width: width,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xff3F7E44), width: 3),
                          color: const Color(0xff3F7E44).withOpacity(0.25),
                          borderRadius:
                              BorderRadius.all(Radius.circular(bordercurve))),
                    ),
                    SizedBox(
                      width: abstandContainerText,
                    ),
                    Column(
                      children: [
                        Text(
                          'goal 13',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: fontType,
                              fontSize: fontsize),
                        ),
                        /* Text('Quality education',
                              style: TextStyle(
                                  color: Colors.white, fontFamily: fontType)) */
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: abstandObenContainer,
                ),
                Row(
                  children: [
                    Container(
                      height: heigth,
                      width: width,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xff0A97D9), width: 3),
                          color: const Color(0xff0A97D9).withOpacity(0.25),
                          borderRadius:
                              BorderRadius.all(Radius.circular(bordercurve))),
                    ),
                    SizedBox(
                      width: abstandContainerText,
                    ),
                    Column(
                      children: [
                        Text(
                          'goal 14',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: fontType,
                              fontSize: fontsize),
                        ),
                        /* Text('Quality education',
                              style: TextStyle(
                                  color: Colors.white, fontFamily: fontType)) */
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: abstandObenContainer,
                ),
                Row(
                  children: [
                    Container(
                      height: heigth,
                      width: width,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xff56C02B), width: 3),
                          color: const Color(0xff56C02B).withOpacity(0.25),
                          borderRadius:
                              BorderRadius.all(Radius.circular(bordercurve))),
                    ),
                    SizedBox(
                      width: abstandContainerText,
                    ),
                    Column(
                      children: [
                        Text(
                          'goal 15',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: fontType,
                              fontSize: fontsize),
                        ),
                        /* Text('Quality education',
                              style: TextStyle(
                                  color: Colors.white, fontFamily: fontType)) */
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: abstandObenContainer,
                ),
                Row(
                  children: [
                    Container(
                      height: heigth,
                      width: width,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xff00689D), width: 3),
                          color: const Color(0xff00689D).withOpacity(0.25),
                          borderRadius:
                              BorderRadius.all(Radius.circular(bordercurve))),
                    ),
                    SizedBox(
                      width: abstandContainerText,
                    ),
                    Column(
                      children: [
                        Text(
                          'goal 16',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: fontType,
                              fontSize: fontsize),
                        ),
                        /* Text('Quality education',
                              style: TextStyle(
                                  color: Colors.white, fontFamily: fontType)) */
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: abstandObenContainer,
                ),
                Row(
                  children: [
                    Container(
                      height: heigth,
                      width: width,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xff19486A), width: 3),
                          color: const Color(0xff19486A).withOpacity(0.25),
                          borderRadius:
                              BorderRadius.all(Radius.circular(bordercurve))),
                    ),
                    SizedBox(
                      width: abstandContainerText,
                    ),
                    Column(
                      children: [
                        Text(
                          'goal 17',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: fontType,
                              fontSize: fontsize),
                        ),
                        /* Text('Quality education',
                              style: TextStyle(
                                  color: Colors.white, fontFamily: fontType)) */
                      ],
                    )
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
