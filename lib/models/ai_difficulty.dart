/// AI difficulty levels for computer opponents.
enum AiDifficulty {
  easy('Easy', 'Random moves, no strategy'),
  medium('Medium', 'Trades optimally, buys dogs when threatened'),
  hard('Hard', 'Calculates optimal paths, times purchases');

  const AiDifficulty(this.label, this.description);

  final String label;
  final String description;
}
