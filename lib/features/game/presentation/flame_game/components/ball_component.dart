import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:spitball/features/game/domain/entities/ball.dart';
import 'package:spitball/features/game/domain/entities/tile.dart';
import 'package:spitball/features/game/presentation/bloc/bloc/bloc.dart';

class BallComponent extends SpriteComponent with TapCallbacks, HasGameRef {
  final TileEntity tile;
  final int row;
  final int col;
  final bool isSelected;
  final Function(int, int) onBallTapped;

  final bool triggersEatAnimation;

  BallComponent({
    required this.tile,
    required this.row,
    required this.col,
    required double size,
    required Vector2 position,
    required this.onBallTapped,
    this.isSelected = false,
    this.triggersEatAnimation = false,
  }) : super(size: Vector2.all(size), position: position);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final bool isGreen = tile.ball is BallGreenEntity;
    String prefix = isGreen ? 'green_ball' : 'pink_ball';
    
    if (triggersEatAnimation) {
       // Show eating sprite temporarily
       sprite = await gameRef.loadSprite('${prefix}_eating.png');
       
       // Add a delayed effect to return to idle/selected
       add(
         TimerComponent(
           period: 1.0, 
           removeOnFinish: true,
           onTick: () async {
              if (isSelected) {
                sprite = await gameRef.loadSprite('${prefix}_selected.png');
              } else {
                sprite = await gameRef.loadSprite('${prefix}_idle.png');
              }
           }
         )
       );
       
       // Add a "chomp" scale effect
       add(
         SequenceEffect([
           ScaleEffect.by(Vector2.all(1.2), EffectController(duration: 0.2)),
           ScaleEffect.by(Vector2.all(1.0), EffectController(duration: 0.2)),
         ])
       );

    } else if (isSelected) {
      sprite = await gameRef.loadSprite('${prefix}_selected.png');
    } else {
      sprite = await gameRef.loadSprite('${prefix}_idle.png');
      
      _addIdleEffect();
    }
  }

  void _addIdleEffect() {
      add(
        ScaleEffect.by(
          Vector2.all(1.1),
          EffectController(
            duration: 0.5,
            reverseDuration: 0.5,
            infinite: true,
          ),
        ),
      );
  }

  @override
  void onTapDown(TapDownEvent event) {
    onBallTapped(row, col);
  }
}
