import 'package:jaspr/server.dart';

class Particles extends StatelessComponent {
  const Particles({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'particles', [
      for (int i = 0; i < 15; i++)
        div(classes: 'particle particle-$i', []),
    ]);
  }
}
