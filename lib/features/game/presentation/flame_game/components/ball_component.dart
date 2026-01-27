import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:spitball/features/game/domain/entities/ball.dart';
import 'package:spitball/features/game/domain/entities/tile.dart';

enum BallState {
  idle,
  selected,
  eating,
}

class BallComponent extends SpriteAnimationGroupComponent<BallState> with TapCallbacks, HasGameRef {
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

    // Helper to load either a 1-frame (static) or 2-frame (animated) sprite
    Future<SpriteAnimation> loadBallAnimation(String suffix) async {
       final String fileName = '${prefix}_$suffix.png';
       final image = await gameRef.images.load(fileName);
       
       // Check if it's a vertical sprite sheet (2 frames)
       // Assumption: Frame is square-ish. If Height ~= 2 * Width, it's 2 frames.
       // Actually user said 128x256, so yes.
       
       final int amount = (image.height >= image.width * 1.8) ? 2 : 1; 
       
       return SpriteAnimation.fromFrameData(
         image,
         SpriteAnimationData.sequenced(
           amount: amount,
           stepTime: 0.4,
           textureSize: Vector2(image.width.toDouble(), image.width.toDouble()),
           amountPerRow: 1, // Force vertical sprite sheet reading
         ),
       );
    }

    final idleAnim = await loadBallAnimation('idle');
    final selectedAnim = await loadBallAnimation('selected');
    
    // For eating, we might just re-use selected or have a specific one if it exists?
    // User mentioned green_ball_eating.png exists in my file list.
    SpriteAnimation? eatingAnim;
    try {
      // Try loading eating animation regardless of whether it exists, if it fails we fallback
      // Actually standard flame load throws if not found? 
      // Based on file list: green_ball_eating.png exists. pink_ball_eating.png exists.
      eatingAnim = await loadBallAnimation('eating');
    } catch (e) {
      // If missing, fallback to selected
      eatingAnim = selectedAnim;
    }

    animations = {
      BallState.idle: idleAnim,
      BallState.selected: selectedAnim,
      BallState.eating: eatingAnim,
    };

    if (triggersEatAnimation) {
       current = BallState.eating;
       
       // Add a delayed effect to return to idle/selected
       add(
         TimerComponent(
           period: 1.0, 
           removeOnFinish: true,
           onTick: () {
              if (isSelected) {
                current = BallState.selected;
              } else {
                current = BallState.idle;
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
      current = BallState.selected;
    } else {
      current = BallState.idle;
      // Removed manual ScaleEffect for idle as the sprite animation now handles the "bounce/idle" look.
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    onBallTapped(row, col);
  }
}
