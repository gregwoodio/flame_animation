import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(GameWidget(game: AnimationGame()));
}

class AnimationGame extends FlameGame with HasTappables {
  late List<CardComponent> deck;

  @override
  Future<void>? onLoad() {
    final redBox = BoxComponent(Colors.red)..position = Vector2(100, 100);
    final greenBox = BoxComponent(Colors.green, isLeft: false)
      ..position = Vector2(400, 400);

    deck = [
      CardComponent(),
      CardComponent(),
      CardComponent(),
      CardComponent(),
      CardComponent(),
    ];

    for (var card in deck) {
      card.position = Vector2(500, 250);
    }

    add(redBox);
    add(greenBox);
    addAll(deck);

    return super.onLoad();
  }
}

class BoxComponent extends PositionComponent with Tappable, Movable {
  final Color color;
  final double _width = 100;
  final double _height = 100;

  bool isLeft;

  @override
  bool get debugMode => true;

  BoxComponent(this.color, {this.isLeft = true}) : super() {
    size = Vector2(_width, _height);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = color;
    final rect = Rect.fromLTWH(0, 0, _width, _height);

    canvas.drawRect(rect, paint);
  }

  @override
  bool onTapUp(TapUpInfo info) {
    if (isLeft) {
      moveTo(Vector2(400, position.y));
    } else {
      moveTo(Vector2(100, position.y));
    }

    isLeft = !isLeft;

    return true;
  }
}

class CardComponent extends PositionComponent
    with Tappable, Movable, HasGameRef<AnimationGame> {
  final double _width = 100;
  final double _height = 140;
  bool hasMoved = false;

  CardComponent() : super() {
    size = Vector2(_width, _height);
  }

  @override
  bool get debugMode => true;

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.white;
    final rect = Rect.fromLTWH(0, 0, _width, _height);

    canvas.drawRect(rect, paint);
  }

  @override
  bool onTapUp(TapUpInfo info) {
    if (!hasMoved) {
      for (var i = 0; i < gameRef.deck.length; i++) {
        var card = gameRef.deck[i];
        card.moveTo(Vector2(i * 105 + 100, 600));
      }
      hasMoved = true;
    } else {
      for (var card in gameRef.deck) {
        card.moveTo(Vector2(500, 250));
      }
      hasMoved = false;
    }

    return true;
  }
}

mixin Movable on PositionComponent {
  Vector2 velocity = Vector2.zero();
  late Vector2 _target;

  @override
  bool get debugMode => true;

  void moveTo(Vector2 target, [double speed = 2500]) {
    _target = target;
    velocity = (_target - position)..scaleTo(speed);
  }

  @override
  void update(double dt) {
    if (velocity == Vector2.zero()) {
      return;
    }

    position.add(velocity * dt);

    // check if position is past target and stop
    if (((velocity.x > 0 && position.x > _target.x) ||
            (velocity.x < 0 && position.x < _target.x) ||
            velocity.x == 0) &&
        ((velocity.y > 0 && position.y > _target.y) ||
            (velocity.y < 0 && position.y < _target.y) ||
            velocity.y == 0)) {
      position.x = _target.x;
      position.y = _target.y;
      velocity = Vector2.zero();
    }
  }
}
