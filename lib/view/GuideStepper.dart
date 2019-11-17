//import 'package:flutter/material.dart';
//import 'package:hasskit/helper/Logger.dart';
//
//class GuideSteps extends StatefulWidget {
//  @override
//  _GuideStepsState createState() => _GuideStepsState();
//}
//
//class _GuideStepsState extends State<GuideSteps> {
//  int _currentStep = 0;
//
//  @override
//  Widget build(BuildContext context) {
//    log.w("Widget build _GuideStepsState");
//
//    return SafeArea(
//      child: Stepper(
//        type: StepperType.horizontal,
//        currentStep: _currentStep,
//        onStepTapped: (int step) => setState(() => _currentStep = step),
//        onStepContinue:
//            _currentStep < 2 ? () => setState(() => _currentStep += 1) : null,
//        onStepCancel:
//            _currentStep > 0 ? () => setState(() => _currentStep -= 1) : null,
//        steps: <Step>[
//          new Step(
//            title: Text(
//              'Connect',
//              overflow: TextOverflow.ellipsis,
//            ),
//            content: Column(
//              children: <Widget>[
//                AspectRatio(
//                  aspectRatio: 1,
//                  child: Image(
//                    image: AssetImage("assets/images/guide-01.png"),
//                  ),
//                ),
//                Container(height: 8),
//                Text(
//                    'Go to Setting Tab and Enter your Home Assistant server adddress. Please make sure the protocol (http or https) and the port (443 or 8123) are correct.'),
//              ],
//            ),
//            isActive: _currentStep >= 0,
//            state: _currentStep >= 0 ? StepState.complete : StepState.disabled,
//          ),
//          new Step(
//            title: Text(
//              'Login',
//              overflow: TextOverflow.ellipsis,
//            ),
//            content: Column(
//              children: <Widget>[
//                AspectRatio(
//                  aspectRatio: 1,
//                  child: Image(
//                    image: AssetImage("assets/images/guide-02.png"),
//                  ),
//                ),
//                Container(height: 8),
//                Text(
//                    "Login with your Home Assistant Account and wait for a few seconds, HassKit will save login token for you. We don't need to login everytime start using this app"),
//              ],
//            ),
//            isActive: _currentStep >= 0,
//            state: _currentStep >= 1 ? StepState.complete : StepState.disabled,
//          ),
//          new Step(
//            title: Text(
//              'Add',
//              overflow: TextOverflow.ellipsis,
//            ),
//            content: Column(
//              children: <Widget>[
//                AspectRatio(
//                  aspectRatio: 1,
//                  child: Image(
//                    image: AssetImage("assets/images/guide-03.png"),
//                  ),
//                ),
//                Container(height: 8),
//                Text(
//                    'Click Add Devices to add Lights, Air Conditioner, Cameras... to your room. You can also change room name, background color...'),
//              ],
//            ),
//            isActive: _currentStep >= 0,
//            state: _currentStep >= 2 ? StepState.complete : StepState.disabled,
//          ),
//        ],
//      ),
//    );
//  }
//}
