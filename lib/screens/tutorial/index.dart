import 'package:flutter/material.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Play SpitBall'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Game Objective',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'The objective of SpitBall is to eliminate all of your opponent\'s balls from the board. '
              'You can do this by moving your balls to attack opponent balls or by splitting your balls to create more units.',
            ),
            SizedBox(height: 16),
            Text(
              'Playing Your Turn',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '1. Selecting a Ball: Tap on one of your balls. It will become highlighted (animation might apply based on settings).',
            ),
            SizedBox(height: 4),
            Text(
              '2. Moving a Ball: After selecting a ball, tap an adjacent (including diagonals) empty tile or an opponent\'s tile to move your ball there. '
              'If you move to a tile with an opponent\'s ball, a battle occurs.',
            ),
            SizedBox(height: 4),
            Text(
              '3. Splitting a Ball: After selecting a ball, tap an empty tile or an opponent\'s tile that is two steps away in a straight line (not diagonally). '
              'Your selected ball will reduce in size, and a new smaller ball will be sent to the target tile. A ball must be of a certain minimum size to split.',
            ),
            SizedBox(height: 4),
            Text(
              '4. Deselecting: Tap the selected ball again to deselect it.',
            ),
            SizedBox(height: 16),
            Text(
              'Battle Rules',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '- When balls of different colors meet on the same tile, they battle.'
            ),
            SizedBox(height: 4),
            Text(
              '- If your attacking ball is larger than or equal in size to the opponent\'s ball on the tile, your ball wins, takes over the tile, and its new size becomes the sum of both balls involved.',
            ),
            SizedBox(height: 4),
            Text(
              '- If your attacking ball is smaller, your ball is consumed, and the opponent\'s ball on the tile increases in size by the size of your attacking ball.',
            ),
            SizedBox(height: 4),
            Text(
              '- When balls of the same color meet (e.g., after a split or a move to an empty tile that was then occupied by same color), they merge, and their sizes are added up (unless restricted by the "limited move" rule).',
            ),
            SizedBox(height: 16),
             Text(
              'Limited Move Rule',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'If you have very few balls on the board (e.g., 2 or less), you might be restricted from merging balls of the same color. This is to prevent a player from easily forming a single giant ball when they are about to lose.',
            ),
            SizedBox(height: 16),
            Text(
              'Winning the Game',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'You win by capturing all of your opponent\'s balls. Good luck!',
            ),
          ],
        ),
      ),
    );
  }
}
